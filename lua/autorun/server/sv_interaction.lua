include("autorun/sh_interaction.lua")
include("autorun/config/anims_pos.lua")
include("autorun/config/anims_hud.lua")
include("autorun/config/config.lua")
util.AddNetworkString("DemanderAnimation")
util.AddNetworkString("ReinitialiserOsDemande")
util.AddNetworkString("ToggleThirdPerson")
util.AddNetworkString("ToggleFirstPerson")
util.AddNetworkString("LockCameraOfThePlayer")
util.AddNetworkString("ResetCamOnSameAnim")
util.AddNetworkString("UpdateWeaponChange")
util.AddNetworkString("VerifServeurSurveillance")
AddCSLuaFile("autorun/config/anims_hud.lua")
AddCSLuaFile("autorun/config/anims_pos.lua")
AddCSLuaFile("autorun/config/config.lua")
local ancienneArme = ""
hook.Add("PlayerSwitchWeapon", "DetecterChangementArme", function(ply, oldWeapon, newWeapon)
    local animName = ply:GetNW2String("AnimName")
    print(animName)
    if ply:IsValid() and animName ~= nil and animName ~= "Empty" then
        if newWeapon:GetClass() == Config.SwepHand then
            return
        else
            return true
        end
    end
end)

<<<<<<< HEAD
hook.Add("PlayerInitialSpawn", "SetEmptyAnimName", function(ply)
    ply:SetNW2String("AnimName", "Empty")
end)

hook.Add("PlayerDeath", "ResetPlayerAnimationName", function(victim, inflictor, attacker)
    victim:SetNW2String("AnimName", "Empty")
end)

local surveillanceStates = {}
local function SurveillancePlayer(ply, isWalkable)
=======
hook.Add("PlayerInitialSpawn", "SetEmptyAnimName", function(ply) ply:SetNW2String("AnimName", "Empty") end)
hook.Add("PlayerDeath", "ResetPlayerAnimationName", function(victim, inflictor, attacker)
    victim:SetNW2String("AnimName", "Empty")
    print(victim:GetNW2String("AnimName"))
end)

local surveillanceStates = {}
local function SurveillancePlayer(ply)
    print("un tour")
>>>>>>> 45f9a86a933bf78415a07d2c70ee2ea23912a9cd
    -- Vérifie si la surveillance est active pour ce joueur
    if surveillanceStates[ply] == true or not ply:Alive() then
        hook.Remove("Tick", "SurveillancePlayer_" .. ply:EntIndex()) -- Retire le hook spécifique à ce joueur
        surveillanceStates[ply] = nil -- Supprime l'état de surveillance pour ce joueur
        return
    end

    if IsValid(ply) and ply:Alive() then
        local estAccroupi = ply:Crouching()
        local AppuiePasSurUse = ply:KeyDown(IN_USE)
        local AppuiePasSurReload = ply:KeyDown(IN_RELOAD)
        local velocityLength = ply:GetVelocity():Length()
<<<<<<< HEAD

        -- reintegrer les velocité max
        if isWalkable == true and Config.isWalkableAllowedForAllAnims == true then
            MaxVelForAction = Config.ActionWalkableVel
        else
            MaxVelForAction = Config.MaxDefaultActionVel
        end

        if velocityLength > MaxVelForAction or estAccroupi or AppuiePasSurUse or AppuiePasSurReload then
            print(MaxVelForAction, "malvellll")
=======
        -- reintegrer les velocité max
        -- if config.IsWalkable == true and Config.isWalkableAllowedForAllAnims == true then
        --     MaxVelForAction = Config.ActionWalkableVel
        -- else
        --     MaxVelForAction = Config.MaxDefaultActionVel
        -- end
        if velocityLength > 5 or estAccroupi or AppuiePasSurUse or AppuiePasSurReload then
>>>>>>> 45f9a86a933bf78415a07d2c70ee2ea23912a9cd
            net.Start("VerifServeurSurveillance")
            net.Send(ply)
            surveillanceStates[ply] = true -- Marque le joueur comme surveillé
        end
    end
end

<<<<<<< HEAD
local function DeclencherLeHookDeSurveillance(ply, typeAnimation)
    -- Vérifie si le joueur est valide
    if IsValid(ply) then
        -- Définir le hook SetupMove uniquement pour ce joueur
        hook.Add("SetupMove", "MySpeed_" .. ply:EntIndex(), function(ply, mv)
            -- Vérifie si c'est le bon joueur
            mv:SetMaxClientSpeed(1)
            mv:SetButtons(bit.band(mv:GetButtons(), bit.bnot(bit.bor(IN_JUMP, IN_DUCK))))
        end)

        -- Vérifie si le joueur est déjà surveillé, s'il ne l'est pas, ajoute la surveillance
        if not surveillanceStates[ply] then
            local isWalkable -- Déclarer la variable isWalkable à l'extérieur de la boucle for
            for _, animation in ipairs(anim_config) do
                if animation.action == typeAnimation then
                    isWalkable = animation.IsWalkable -- Assigner la valeur à la variable isWalkable
                    print("IsWalkable pour", typeAnimation, ":", isWalkable)
                    break
                end
            end

            -- Ajouter un hook Tick pour surveiller le joueur spécifique
            hook.Add("Tick", "SurveillancePlayer_" .. ply:EntIndex(), function()
                SurveillancePlayer(ply, isWalkable)
            end)

=======
local function DeclencherLeHookDeSurveillance(ply)
    -- Vérifie si le joueur est valide
    if IsValid(ply) then
        -- Vérifie si le joueur est déjà surveillé, s'il ne l'est pas, ajoute la surveillance
        if not surveillanceStates[ply] then
            hook.Add("Tick", "SurveillancePlayer_" .. ply:EntIndex(), function() SurveillancePlayer(ply) end)
>>>>>>> 45f9a86a933bf78415a07d2c70ee2ea23912a9cd
            surveillanceStates[ply] = false -- Initialise l'état de surveillance pour ce joueur
        end
    end
end

-- Fonction pour réinitialiser les os
local function ReinitialiserOs(ply, restaurerArme, disableCam)
    if not disableCam then
        net.Start("ToggleFirstPerson")
        net.Send(ply)
    end

    ply:SetNW2String("AnimName", "Empty") -- Réinitialiser le type d'animation à une chaîne vide
    if restaurerArme and Config.getLastWeapon == true then
        print("set ancienne arme " .. ancienneArme)
        ply:SelectWeapon(ancienneArme) -- Sauvegarder l'arme actuelle
    end
end

net.Receive("DemanderAnimation", function(len, ply)
    local typeAnimation = net.ReadString()
    local ActiveWeapon = ply:GetActiveWeapon()
    if IsValid(ActiveWeapon) and ActiveWeapon.FistsOut == true then
        ActiveWeapon:FistsDown()
<<<<<<< HEAD
        ActiveWeapon:Reload()
=======
        ActiveWeapon:Reload() -- Cela appelle la fonction de rechargement pour fermer les poings
        print("ZDKADIZADUAZUJDAZJDJZADHUAZHDZAODZIKOADUIZADHUZAIDZAIDHUZADUZAIDZAUIDUYAZDUAZU")
>>>>>>> 45f9a86a933bf78415a07d2c70ee2ea23912a9cd
    end

    if IsValid(ActiveWeapon) then
        ancienneArme = ActiveWeapon:GetClass()
    else
        ancienneArme = nil
    end

    surveillanceStates[ply] = false -- Réinitialise l'état de surveillance pour ce joueur
<<<<<<< HEAD
    DeclencherLeHookDeSurveillance(ply, typeAnimation)
    if typeAnimation == ply:GetNW2String("AnimName") then
        ply:SetNW2String("AnimName", "Empty")
    else
=======
    DeclencherLeHookDeSurveillance(ply)
    if typeAnimation == ply:GetNW2String("AnimName") then
        ply:SetNW2String("AnimName", "Empty")
    else
        hook.Add("SetupMove", "MySpeed", function(ply, mv) mv:SetMaxClientSpeed(1) end)
>>>>>>> 45f9a86a933bf78415a07d2c70ee2ea23912a9cd
        ply:SetNW2String("AnimName", typeAnimation)
        if ply:GetNW2String("AnimName") == typeAnimation then
            print("Successfully Set NW2 Value")
        else
<<<<<<< HEAD
            print("Couldn't Set NW2 Value : Previous netstring may be null, here is the actual value: " ..
                      ply:GetNW2String("AnimName"))
=======
            print("Couldn't Set NW2 Value : Previous netstring may be null, here is the actual value: " .. ply:GetNW2String("AnimName"))
>>>>>>> 45f9a86a933bf78415a07d2c70ee2ea23912a9cd
        end
    end

    if IsValid(ply) and ply:IsPlayer() then
<<<<<<< HEAD
        if not ply:HasWeapon(Config.SwepHand) then
            ply:Give(Config.SwepHand)
        end
=======
        if not ply:HasWeapon(Config.SwepHand) then ply:Give(Config.SwepHand) end
>>>>>>> 45f9a86a933bf78415a07d2c70ee2ea23912a9cd
        ply:SelectWeapon(Config.SwepHand)
        net.Start("ToggleThirdPerson")
        net.Send(ply)
    end
end)

net.Receive("ReinitialiserOsDemande", function(len, ply)
    if IsValid(ply) and ply:IsPlayer() then
        print("Surveillance détecté reçue du joueur " .. ply:Nick())
        ReinitialiserOs(ply, true)
    end
end)

net.Receive("ResetCamOnSameAnim", function(len, ply)
    if IsValid(ply) and ply:IsPlayer() and not disableCam then
        net.Start("ToggleFirstPerson")
        net.Send(ply)
        print("Surveillance détecté reçue du joueur cam" .. ply:Nick())
    end
<<<<<<< HEAD
end)
=======
end)
>>>>>>> 45f9a86a933bf78415a07d2c70ee2ea23912a9cd
