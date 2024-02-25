include("autorun/sh_interaction.lua")
include("autorun/config/anims_pos.lua")
include("autorun/config/config.lua")

util.AddNetworkString("DemanderAnimation")
util.AddNetworkString("ReinitialiserOsDemande")
util.AddNetworkString("ToggleThirdPerson")
util.AddNetworkString("ToggleFirstPerson")
util.AddNetworkString("BlockAtEyeTrace")
util.AddNetworkString("CallbackReset")

local ancienneArme = ""

-- Fonction pour réinitialiser les os
local function ReinitialiserOs(ply, restaurerArme, disableCam)
    if restaurerArme and Config.getLastWeapon == true then
        print("set ancienne arme" .. ancienneArme)
        ply:SelectWeapon(ancienneArme) -- Sauvegarder l'arme actuelle
    end
    if not disableCam then
        net.Start("ToggleFirstPerson")
        net.Send(ply)
    end

    ply:SetNWBool("EnAnimation", false)
    ply:SetNWString("TypeAnimation", "") -- Réinitialiser le type d'animation à une chaîne vide
    local nombreOs = ply:GetBoneCount()
    for i = 0, nombreOs - 1 do
        ply:ManipulateBoneAngles(i, Angle(0, 0, 0))
        ply:ManipulateBonePosition(i, Vector(0, 0, 0))
    end

end

net.Receive("DemanderAnimation", function(len, ply)
    local typeAnimation = net.ReadString()
    local isCameraLocked = net.ReadBool()

    print("Demande d'animation " .. typeAnimation .. " reçue du client.")

    if IsValid(ply) and ply:IsPlayer() then
        if ply:GetNWBool("EnAnimation") then
            -- Vérifier si l'animation demandée est la même que celle en cours
            if ply:GetNWString("TypeAnimation") == typeAnimation then
                print("La même animation est déjà en cours, réinitialisation des os uniquement.")
                ReinitialiserOs(ply)
                -- Important : Retourner ici pour ne pas relancer la même animation
                return
            else
                print(
                    "Une autre animation est en cours, réinitialisation des os avant de lancer la nouvelle animation.")
                ReinitialiserOs(ply, false, true)
            end
        end

        ancienneArme = ply:GetActiveWeapon():GetClass()

        if not ply:HasWeapon(Config.SwepHand) then
            ply:Give(Config.SwepHand)
        end

        ply:SelectWeapon(Config.SwepHand)

        if configurationsAnimation[typeAnimation] then
            ply:SetNWBool("EnAnimation", true)
            ply:SetNWString("TypeAnimation", typeAnimation) -- Stocker le type d'animation en cours

            net.Start("ToggleThirdPerson")
            net.Send(ply)

            for nomOs, value in pairs(configurationsAnimation[typeAnimation]) do

                local idOs = ply:LookupBone(nomOs)
                if idOs then
                    -- Manipuler l'angle si il est spécifié
                    if type(value) == "table" then
                        if isCameraLocked == true then
                            net.Start("BlockAtEyeTrace")
                            net.Send(ply)
                        end

                        local angleInitial = ply:GetManipulateBoneAngles(idOs)
                        local angleFinal = value.Angle or angleInitial -- Utiliser l'angle initial si aucun angle n'est spécifié
                        local position = value.Position -- Récupérer la position si elle est spécifiée

                        local startTime = CurTime()
                        local duration = 0.5 -- Durée de l'animation en secondes (à ajuster selon vos besoins)

                        timer.Create("Animation_" .. nomOs, 0.01, math.ceil(duration / 0.01), function()
                            local elapsedTime = CurTime() - startTime
                            local progress = math.min(1, elapsedTime / duration) -- Progression de l'animation de 0 à 1

                            -- Interpolation entre l'angle initial et l'angle final
                            local lerpedAngle = LerpAngle(progress, angleInitial, angleFinal)

                            ply:ManipulateBoneAngles(idOs, lerpedAngle)

                            -- Manipuler la position si elle est spécifiée
                            if position then
                                ply:ManipulateBonePosition(idOs, position)
                            end

                            if progress >= 1 then
                                timer.Remove("Animation_" .. nomOs) -- Supprimer le timer une fois l'animation terminée
                            end
                        end)
                    end
                end
            end
        end

    end
end)

net.Receive("ReinitialiserOsDemande", function(len, ply)
    if IsValid(ply) and ply:IsPlayer() then
        ReinitialiserOs(ply, true)

        net.Start("CallbackReset")
        net.Send(ply)
    end
end)

