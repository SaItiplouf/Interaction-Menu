print("Le fichier shared est exécuté. Côté :", SERVER and "Serveur" or "Client")
if SERVER then
    util.AddNetworkString("WaitingSharedAnimManipulation")
    util.AddNetworkString("SimpleResetBones")
    net.Receive("SimpleResetBones", function(len, ply)
        local steamID = net.ReadString()
        local playerEnt = FindPlayerBySteamID(steamID)
        if IsValid(playerEnt) then
            ResetPlayerBones(playerEnt)
        else
            print("Aucun joueur trouvé pour le SteamID :", steamID)
        end
    end)
end

function GetBonesAnglesPositionsAndResetThem(ent)
    if CLIENT then
        local steamID = ent:SteamID64()
        net.Start("SimpleResetBones")
        net.WriteString(steamID)
        net.SendToServer()
    end
end

function ManipulateBoneOnShared(ply, AnimName)
    if CLIENT then
        if ply:IsPlayer() and ply:Alive() then
            local steamID = ply:SteamID64()
            net.Start("WaitingSharedAnimManipulation")
            net.WriteString(steamID)
            net.WriteString(AnimName)
            net.SendToServer()
        else
            print("error client")
        end
    elseif SERVER then
        local animationData = configurationsAnimation[AnimName]
        if not animationData then
            print("L'animation", AnimName, "n'existe pas dans configurationsAnimation.")
            return
        end

        for nomOs, value in pairs(animationData) do
            local idOs = ply:LookupBone(nomOs)
            if idOs then
                local angleInitial = ply:GetManipulateBoneAngles(idOs)
                local angleFinal = value.Angle or angleInitial
                local position = value.Position
                local startTime = CurTime()
                local duration = 0.5
                timer.Create("Animation_" .. nomOs, 0.01, math.ceil(duration / 0.01), function()
                    local curTime = CurTime()
                    local elapsedTime = curTime - startTime
                    local progress = math.min(1, elapsedTime / duration)
                    local lerpedAngle = LerpAngle(progress, angleInitial, angleFinal)
                    ply:ManipulateBoneAngles(idOs, lerpedAngle)
                    if position then ply:ManipulateBonePosition(idOs, position) end
                    if progress >= 1 then timer.Remove("Animation_" .. nomOs) end
                end)
            end
        end
    end
end

if SERVER then
    net.Receive("WaitingSharedAnimManipulation", function(len, ply)
        local steamID = net.ReadString()
        local AnimName = net.ReadString()
        local playerEnt = FindPlayerBySteamID(steamID)
        if IsValid(playerEnt) then
            ManipulateBoneOnShared(playerEnt, AnimName)
        else
            print("Aucun joueur trouvé pour le SteamID :", steamID)
            print("Nom de l'animation :", AnimName)
        end
    end)
end

function FindPlayerBySteamID(steamID)
    for _, player in ipairs(player.GetAll()) do
        if player:SteamID64() == steamID then return player end
    end
    return nil
end

function ResetPlayerBones(playerEnt)
    print("Reset des os du joueur :", playerEnt:Nick())
    local nombreOs = playerEnt:GetBoneCount()
    for i = 0, nombreOs - 1 do
        playerEnt:ManipulateBoneAngles(i, Angle(0, 0, 0))
        playerEnt:ManipulateBonePosition(i, Vector(0, 0, 0))
    end
end