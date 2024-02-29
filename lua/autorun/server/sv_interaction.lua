include("autorun/sh_interaction.lua")
include("autorun/config/anims_pos.lua")
include("autorun/config/config.lua")
util.AddNetworkString("DemanderAnimation")
util.AddNetworkString("ReinitialiserOsDemande")
util.AddNetworkString("ToggleThirdPerson")
util.AddNetworkString("ToggleFirstPerson")
util.AddNetworkString("LockCameraOfThePlayer")
util.AddNetworkString("ResetCamOnSameAnim")
util.AddNetworkString("UpdateWeaponChange")
AddCSLuaFile("autorun/config/anims_hud.lua")
AddCSLuaFile("autorun/config/anims_pos.lua")
AddCSLuaFile("autorun/config/config.lua")
local ancienneArme = ""
hook.Add("PlayerSwitchWeapon", "DetecterChangementArme", function(ply, oldWeapon, newWeapon)
    local animName = ply:GetNW2String("AnimName")
    if ply:IsValid() and animName ~= nil and animName ~= "Empty" then
        if newWeapon:GetClass() == Config.SwepHand then
            return
        else
            return true
        end
    end
end)

hook.Add("PlayerDeath", "ResetPlayerAnimationName", function(victim, inflictor, attacker) victim:SetNW2String("AnimName", "Empty") end)
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
    ancienneArme = ActiveWeapon:GetClass()
    if typeAnimation == ply:GetNW2String("AnimName") then
        ply:SetNW2String("AnimName", "Empty")
    else
        hook.Add("SetupMove", "MySpeed", function(ply, mv) mv:SetMaxClientSpeed(1) end)
        ply:SetNW2String("AnimName", typeAnimation)
        if ply:GetNW2String("AnimName") == typeAnimation then
            print("Successfully Set NW2 Value")
        else
            print("Couldn't Set NW2 Value : Previous netstring may be null, here is the actual value: " .. ply:GetNW2String("AnimName"))
        end
    end

    if IsValid(ply) and ply:IsPlayer() then
        if not ply:HasWeapon(Config.SwepHand) then ply:Give(Config.SwepHand) end
        ply:SelectWeapon(Config.SwepHand)
        net.Start("ToggleThirdPerson")
        net.Send(ply)
    end
end)

net.Receive("ReinitialiserOsDemande", function(len, ply)
    if IsValid(ply) and ply:IsPlayer() then
        print("Surveillance détecté reçue du joueur ")
        ReinitialiserOs(ply, true)
    end
end)

net.Receive("ResetCamOnSameAnim", function(len, ply)
    if IsValid(ply) and ply:IsPlayer() and not disableCam then
        net.Start("ToggleFirstPerson")
        net.Send(ply)
        print("Surveillance détecté reçue du joueur ")
    end
end)