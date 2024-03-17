include("autorun/sh_interaction.lua")
include("autorun/config/anims_hud.lua")
include("autorun/config/anims_pos.lua")
include("autorun/config/config.lua")
local chatOpen = false
local previewAnim = ""
local function ResetBonesEtRetirerLeHook()
    hook.Remove("Think", "SurveillerMouvement")
    net.Start("ReinitialiserOsDemande")
    net.SendToServer()
end

local function sleepingAnim(ent)
<<<<<<< HEAD
    if not IsValid(ent) or not ent:Alive() then
        return
    end
=======
    if not IsValid(ent) or not ent:Alive() then return end
>>>>>>> 45f9a86a933bf78415a07d2c70ee2ea23912a9cd
    -- Obtenez la position du bone "ValveBiped.Bip01_Head1" de l'entité
    local boneIndex = ent:LookupBone("ValveBiped.Bip01_Head1")
    if not boneIndex then -- Vérifiez si le bone existe
        return
    end

    local bonePos, boneAng = ent:GetBonePosition(boneIndex)
    if not bonePos then -- Vérifiez si vous avez pu obtenir la position du bone
        return
    end

    local offset = Vector(0, 0, -15)
    -- Ajustez cet offset selon vos besoins pour placer les particules par rapport au bone
    local pos = bonePos + boneAng:Forward() * offset.x + boneAng:Right() * offset.y + boneAng:Up() * offset.z
    local emitter = ParticleEmitter(pos)
    if emitter then
        local currentTime = CurTime()
        local lastParticleTime = ent.lastParticleTime or 0
        if currentTime - lastParticleTime >= 2 then -- Emit a particle every 3 seconds
            ent.lastParticleTime = currentTime
            local particle = emitter:Add("sleeping_particle.vmt", pos)
            if particle then
                particle:SetVelocity(Vector(math.random(-10, 10), math.random(-10, 10), math.random(1, 2)))
                particle:SetDieTime(3)
                particle:SetStartAlpha(255)
                particle:SetEndAlpha(0)
                particle:SetStartSize(5) -- Augmentez la taille de départ
                particle:SetEndSize(10)
                particle:SetGravity(Vector(0, 0, 10))
                particle:SetColor(255, 0, 0)
                particle:SetCollide(true)
                particle:SetBounce(2)
            end
        end
    end
end

local function CreerFrameMenuAnim(parentPanel)
    local frame = vgui.Create("DFrame", parentPanel)
    frame:SetSize(600, 390)
    frame:SetPos((ScrW() / 2 - parentPanel:GetWide() / 2) + (parentPanel:GetWide() - frame:GetWide()), ScrH() / 2 - parentPanel:GetTall() / 2)
    frame:SetTitle("")
    frame:ShowCloseButton(false)
    frame:SetDraggable(false)
    frame.Paint = function(self, w, h)
        for i = 0, h do
            local gradient = i / h
            local r = Lerp(gradient, 56, 30)
            local g = Lerp(gradient, 55, 30)
            local b = Lerp(gradient, 55, 30)
            surface.SetDrawColor(r, g, b, 240)
            surface.DrawLine(0, i, w, i)
        end

        -- Dessiner le texte au centre
<<<<<<< HEAD
        draw.SimpleText(Config.Title, Config.TitreFont, w / 2, 20, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER)
=======
        draw.SimpleText(Config.Title, Config.TitreFont, w / 2, 20, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
>>>>>>> 45f9a86a933bf78415a07d2c70ee2ea23912a9cd
    end
    return frame
end

local function CreerModelEtExtensionPanel(parentPanel, frame)
    local extensionFrame = vgui.Create("DFrame", parentPanel)
    extensionFrame:SetSize(parentPanel:GetWide() - frame:GetWide(), frame:GetTall())
    extensionFrame:SetPos(0, 0)
    extensionFrame:SetAlpha(255) -- Définir l'opacité de l'extensionFrame à 255
    extensionFrame:SetTitle("") -- Supprime le titre
    extensionFrame:ShowCloseButton(false) -- Supprime le bouton de fermeture
    extensionFrame:SetDraggable(false) -- Empêche le déplacement
    extensionFrame.Paint = function(self, w, h)
        -- Dessiner un rectangle avec une couleur de fond et une opacité spécifiées
        draw.RoundedBox(0, 0, 0, w, h, Color(33, 33, 33, 240)) -- Couleur de fond avec une opacité de 200
        -- Appliquer un effet de flou à l'arrière-plan du panneau
    end

    local modelPanel = vgui.Create("DModelPanel", extensionFrame)
    modelPanel:SetSize(parentPanel:GetWide() - frame:GetWide(), frame:GetTall())
    modelPanel:SetAnimated(false)
    modelPanel:SetModel(LocalPlayer():GetModel())
    modelPanel:SetCamPos(Vector(55, 50, 55))
    modelPanel:SetFOV(50)
    function modelPanel:LayoutEntity(ent)
        local animConfig = configurationsAnimation[previewAnim]
        if not animConfig then
            for i = 0, ent:GetBoneCount() - 1 do
                ent:ManipulateBoneAngles(i, Angle(0, 0, 0))
                ent:ManipulateBonePosition(i, Vector(0, 0, 0))
            end
            return
        end

        for nomOs, value in pairs(animConfig) do
            local idOs = ent:LookupBone(nomOs)
            if idOs then
                -- Manipuler l'angle si il est spécifié
                if type(value) == "table" and value.Angle then
                    local angleInitial = ent:GetManipulateBoneAngles(idOs)
                    local angleFinal = value.Angle or angleInitial -- Utiliser l'angle initial si aucun angle n'est spécifié
                    ent:ManipulateBoneAngles(idOs, angleFinal)
                end

                if type(value) == "table" and value.Position then
                    -- Manipuler la position si elle est spécifiée
                    ent:ManipulateBonePosition(idOs, value.Position)
                end
            end
        end
    end

    modelPanel:SetAmbientLight(Color(60, 60, 60, 255))
    modelPanel:SetAnimated(false)
    return extensionFrame, modelPanel
end

local function CreerButtonClose(parentPanel, frame)
    local closeButton = vgui.Create("DButton", frame)
    closeButton:SetText("X")
    closeButton:SetFont("Trebuchet18")
    closeButton:SetColor(Color(255, 255, 255))
    closeButton:SetSize(30, 30)
    closeButton:SetPos(frame:GetWide() - 30, 0)
<<<<<<< HEAD
    closeButton.Paint = function(self, w, h)
        draw.RoundedBoxEx(6, 0, 0, w, h, self:IsHovered() and Config.bgHoverCloseButton or Config.bgCloseButton, false,
            false, true, false)
    end
=======
    closeButton.Paint = function(self, w, h) draw.RoundedBoxEx(6, 0, 0, w, h, self:IsHovered() and Config.bgHoverCloseButton or Config.bgCloseButton, false, false, true, false) end
>>>>>>> 45f9a86a933bf78415a07d2c70ee2ea23912a9cd
    closeButton.DoClick = function()
        if IsValid(parentPanel) then
            parentPanel:Remove()
            menuOuvert = false
        end
    end
end

local function ImportScrollPanel(frame)
    local scrollPanel = vgui.Create("DScrollPanel", frame)
    scrollPanel:SetPos(20, 60)
    scrollPanel:SetSize(frame:GetWide() - 30, frame:GetTall() - 80)
    local scrollBar = scrollPanel:GetVBar()
    scrollBar:SetHideButtons(true)
    scrollBar.Paint = function(self, w, h) draw.RoundedBox(4, 0, 0, w, h, Color(100, 100, 100)) end
    scrollBar.btnGrip.Paint = function(self, w, h) draw.RoundedBox(4, 0, 0, w, h, Color(200, 200, 200)) end
    return scrollPanel
end

local function myHook()
    if IsValid(LocalPlayer()) then
        angle = LocalPlayer():EyeAngles()
        local ccmd = LocalPlayer():GetCurrentCommand()
        if ccmd then
            ccmd:SetViewAngles(angle) -- Rétablir l'angle de vue initial
        end
    end

    hook.Remove("GetCmdAndResetViewAngle", "RetirerLeHookApresExec")
end

local function OuvrirMenuPanel()
    if not menuOuvert then
        local parentPanel = vgui.Create("DPanel")
        parentPanel:SetSize(850, 390)
        parentPanel:SetPos(ScrW() / 2 - parentPanel:GetWide() / 2, ScrH() / 2 - parentPanel:GetTall() / 2)
        parentPanel.Paint = function(self, w, h)
            surface.SetDrawColor(255, 255, 255, 0)
            surface.DrawRect(0, 0, w, h)
            Derma_DrawBackgroundBlur(self, CurTime())
        end

        hook.Add("Think", "VerifierEchap", function()
            if input.IsKeyDown(KEY_ESCAPE) and menuOuvert == true then
                print("yo on rentre dedans")
                menuOuvert = false
                parentPanel:Remove()
                hook.Remove("Think", "VerifierEchap")
            end
        end)

        local frame = CreerFrameMenuAnim(parentPanel)
        extensionPanel = CreerModelEtExtensionPanel(parentPanel, frame)
        closeButton = CreerButtonClose(parentPanel, frame)
        local scrollPanel = ImportScrollPanel(frame)
        local iconLayout = scrollPanel:Add("DIconLayout")
        iconLayout:SetSize(scrollPanel:GetWide(), scrollPanel:GetTall())
        iconLayout:SetSpaceX(5) -- Espacement horizontal entre les carrés
        iconLayout:SetSpaceY(5) -- Espacement vertical entre les carrés
        for _, config in ipairs(anim_config) do
            local carre = iconLayout:Add("DPanel")
            carre:SetSize(105, 105)
            carre.Paint = function(self, w, h)
                draw.RoundedBox(6, 0, 0, w, h, self:IsHovered() and Config.bgHoverButton or Config.bgButton)
                draw.SimpleText(config.nom, Config.FontButton, w / 2, h / 2, Config.ColorTextButton, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
<<<<<<< HEAD
=======

            carre.OnCursorEntered = function() previewAnim = config.action end
            carre.OnCursorExited = function() previewAnim = "" end
>>>>>>> 45f9a86a933bf78415a07d2c70ee2ea23912a9cd
            if Config.ActivateIcon == true and config.icone and config.icone ~= "" then
                local iconImage = vgui.Create("DImage", carre)
                iconImage:SetSize(100, 100)
                iconImage:SetPos((carre:GetWide() - iconImage:GetWide()) / 2, 20)
                iconImage:SetImage(config.icone)
                iconImage:SetMouseInputEnabled(false)
                iconImage:SetVisible(true)
            end

            carre.OnMousePressed = function()
<<<<<<< HEAD
                if LocalPlayer():GetVelocity():LengthSqr() > 1 or ply:InVehicle() or ply:Crouching() then
=======
                if LocalPlayer():GetVelocity():LengthSqr() > 1 or ply:InVehicle() then
>>>>>>> 45f9a86a933bf78415a07d2c70ee2ea23912a9cd
                    return -- Retourner si la vélocité du joueur est supérieure à 0
                end

                print("Carré cliqué! Action : " .. config.action)
                net.Start("DemanderAnimation")
                net.WriteString(config.action)
<<<<<<< HEAD

=======
>>>>>>> 45f9a86a933bf78415a07d2c70ee2ea23912a9cd
                local lockedYaw = nil
                if Config.LockCameraForAllAnimations == true or config.cameraLocked == true then
                    ply = LocalPlayer()
                    originalViewAngle = LocalPlayer():EyeAngles()
                    local eyeAngles = ply:EyeAngles()
                    lockedYaw = eyeAngles.yaw
                    yawOffset = Config.AngleMaxWhenLocked
                end
<<<<<<< HEAD

                net.SendToServer()
                print("Message envoyé au serveur.")

                hook.Add("CreateMove", "DisableUseKey", function(cmd)
                    cmd:SetButtons(bit.band(cmd:GetButtons(), bit.bnot(IN_USE)))
                end)
                timer.Simple(1, function()
                    hook.Remove("CreateMove", "DisableUseKey")
                end)
                hook.Add("CreateMove", "BlockReload", function(cmd)
                    if bit.band(cmd:GetButtons(), IN_RELOAD) ~= 0 then
                        cmd:SetButtons(bit.band(cmd:GetButtons(), bit.bnot(IN_RELOAD)))
                    end
                end)
=======
>>>>>>> 45f9a86a933bf78415a07d2c70ee2ea23912a9cd

                net.SendToServer()
                print("Message envoyé au serveur.")
                hook.Add("InputMouseApply", "LockToYawOnly", function(ccmd, x, y, angle)
                    if lockedYaw ~= nil then
                        -- Si l'angle est verrouillé, autoriser le mouvement horizontal avec une petite marge
                        local currentAngle = ccmd:GetViewAngles()
                        local sensitivity = Config.LockedCamSensitivity -- Ajustez la sensibilité selon vos préférences
                        local horizontalOffset = Config.AngleMaxWhenLocked -- Offset autorisé horizontalement par rapport à l'angle verrouillé
                        -- Inverser la direction de la rotation horizontale
                        x = x * -1
                        -- Calculer le nouvel angle de vue en fonction du mouvement horizontal de la souris
                        local newYaw = currentAngle.yaw + x * sensitivity
                        -- Gérer les cas où l'angle dépasse une rotation complète (360 degrés)
<<<<<<< HEAD
                        lockedYaw = (newYaw - lockedYaw > 180) and (lockedYaw + 360) or
                                        ((newYaw - lockedYaw < -180) and (lockedYaw - 360) or lockedYaw)
=======
                        lockedYaw = (newYaw - lockedYaw > 180) and (lockedYaw + 360) or ((newYaw - lockedYaw < -180) and (lockedYaw - 360) or lockedYaw)
>>>>>>> 45f9a86a933bf78415a07d2c70ee2ea23912a9cd
                        -- Limiter les angles de vue dans la plage autorisée autour de l'angle verrouillé
                        local minAngle = lockedYaw - horizontalOffset
                        local maxAngle = lockedYaw + horizontalOffset
                        local clampedYaw = math.Clamp(newYaw, minAngle, maxAngle)
                        -- Appliquer les nouveaux angles de vue
                        ccmd:SetViewAngles(Angle(currentAngle.pitch, clampedYaw, currentAngle.roll))
                        return true
                    end
                end)

<<<<<<< HEAD
                net.Receive("VerifServeurSurveillance", function()
                    hook.Remove("InputMouseApply", "LockToYawOnly")
                    hook.Remove("CreateMove", "BlockReload")
=======
                -- hook.Add("Think", "SurveillerMouvement", function()
                --     local joueur = LocalPlayer()
                --     local estAccroupi = joueur:Crouching()
                --     local nAppuiePasSurUse = joueur:KeyDown(IN_USE)
                --     local nAppuiePasSurReload = joueur:KeyDown(IN_RELOAD)
                --     if config.IsWalkable == true and Config.isWalkableAllowedForAllAnims == true then
                --         MaxVelForAction = Config.ActionWalkableVel
                --     else
                --         MaxVelForAction = Config.MaxDefaultActionVel
                --     end
                -- end)
                net.Receive("VerifServeurSurveillance", function()
                    hook.Remove("InputMouseApply", "LockToYawOnly")
>>>>>>> 45f9a86a933bf78415a07d2c70ee2ea23912a9cd
                    ResetBonesEtRetirerLeHook()
                    hook.Add("GetCmdAndResetViewAngle", "RetirerLeHookApresExec", myHook)
                end)

                parentPanel:Remove()
                menuOuvert = false
            end
        end

        frame:MakePopup()
        menuOuvert = true
    end
end

<<<<<<< HEAD
hook.Add("StartChat", "HasStartedTyping", function(isTeamChat)
    chatOpen = true
end)
hook.Add("FinishChat", "HasStoppedTyping", function()
    chatOpen = false
end)
=======
hook.Add("StartChat", "HasStartedTyping", function(isTeamChat) chatOpen = true end)
hook.Add("FinishChat", "HasStoppedTyping", function() chatOpen = false end)
>>>>>>> 45f9a86a933bf78415a07d2c70ee2ea23912a9cd
local function VerifierTouchePressee()
    local ply = LocalPlayer()
    if input.IsKeyDown(KEY_G) and not ply:InVehicle() and ply:Alive() and chatOpen == false then
        OuvrirMenuPanel() -- Ouvrir le menu
    end
end

<<<<<<< HEAD
net.Receive("ToggleThirdPerson", function()
    RunConsoleCommand("thirdperson")
end)
net.Receive("ToggleFirstPerson", function()
    RunConsoleCommand("firstperson")
end)
hook.Add("Think", "VerifierTouchePressee", VerifierTouchePressee)
local function OnPlayerNetworkedVarChanged(ent, name, oldVal, newVal)
    print("Le joueur " .. ent:Nick() .. " a changé la valeur de la netvar '" .. name .. "' de '" .. tostring(oldVal) ..
              "' à '" .. tostring(newVal) .. "'.")
=======
net.Receive("ToggleThirdPerson", function() RunConsoleCommand("thirdperson") end)
net.Receive("ToggleFirstPerson", function() RunConsoleCommand("firstperson") end)
hook.Add("Think", "VerifierTouchePressee", VerifierTouchePressee)
local function OnPlayerNetworkedVarChanged(ent, name, oldVal, newVal)
    print("Le joueur " .. ent:Nick() .. " a changé la valeur de la netvar '" .. name .. "' de '" .. tostring(oldVal) .. "' à '" .. tostring(newVal) .. "'.")
>>>>>>> 45f9a86a933bf78415a07d2c70ee2ea23912a9cd
    if name == "AnimName" and ent:IsPlayer() and ent:Alive() then
        if newVal == "Empty" then
            GetBonesAnglesPositionsAndResetThem(ent)
            if ent == LocalPlayer() then
<<<<<<< HEAD
                hook.Remove("InputMouseApply", "LockToYawOnly")
=======
>>>>>>> 45f9a86a933bf78415a07d2c70ee2ea23912a9cd
                net.Start("ResetCamOnSameAnim")
                net.SendToServer()
            else
                print("Aren't concerned by anim reset")
            end

            if oldVal == "sleeping" and ent:Alive() then
                timer.Remove("SleepingParticleEmitterTimer_" .. ent:EntIndex()) -- Retire le timer spécifique à cette entité
            end
        else
            if configurationsAnimation[newVal] then
                if oldVal ~= "Empty" then
                    -- resetting bones before new anim to avoid glitching
                    GetBonesAnglesPositionsAndResetThem(ent)
                end

                if newVal == "sleeping" and ent:Alive() then
                    local timerName = "SleepingParticleEmitterTimer_" .. ent:EntIndex() -- Nom unique du timer pour cette entité
<<<<<<< HEAD
                    timer.Create(timerName, 1, 0, function()
                        sleepingAnim(ent)
                    end)
=======
                    timer.Create(timerName, 1, 0, function() sleepingAnim(ent) end)
>>>>>>> 45f9a86a933bf78415a07d2c70ee2ea23912a9cd
                else
                    local timerName = "SleepingParticleEmitterTimer_" .. ent:EntIndex() -- Nom unique du timer pour cette entité
                    timer.Remove(timerName)
                end

                -- Appelez la fonction ManipulateBoneOnShared avec les informations nécessaires
                ManipulateBoneOnShared(ent, newVal)
            end
        end
    else
        print("error")
    end
end

-- Ajoutez le hook pour surveiller les changements de netvars du joueur local
<<<<<<< HEAD
hook.Add("EntityNetworkedVarChanged", "MonitorPlayerNetworkedVarChanges", OnPlayerNetworkedVarChanged)
=======
hook.Add("EntityNetworkedVarChanged", "MonitorPlayerNetworkedVarChanges", OnPlayerNetworkedVarChanged)
>>>>>>> 45f9a86a933bf78415a07d2c70ee2ea23912a9cd
