include("autorun/sh_interaction.lua")
include("autorun/config/anims_hud.lua")
include("autorun/config/anims_pos.lua")
include("autorun/config/config.lua")

local previewAnim = ""
local originalViewAngle = nil

local function CreerFrameMenuAnim(parentPanel)
    local frame = vgui.Create("DFrame", parentPanel)
    frame:SetSize(600, 390)
    frame:SetPos((ScrW() / 2 - parentPanel:GetWide() / 2) + (parentPanel:GetWide() - frame:GetWide()),
        ScrH() / 2 - parentPanel:GetTall() / 2)
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
        draw.SimpleText(Config.Title, Config.TitreFont, w / 2, 20, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER)

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
                if type(value) == "table" then
                    local angleInitial = ent:GetManipulateBoneAngles(idOs)
                    local angleFinal = value.Angle or angleInitial -- Utiliser l'angle initial si aucun angle n'est spécifié
                    local position = value.Position -- Récupérer la position si elle est spécifiée

                    ent:ManipulateBoneAngles(idOs, angleFinal)

                    -- Manipuler la position si elle est spécifiée
                    if position then
                        ent:ManipulateBonePosition(idOs, position)
                    end

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

    closeButton.Paint = function(self, w, h)
        draw.RoundedBoxEx(6, 0, 0, w, h, self:IsHovered() and Config.bgHoverCloseButton or Config.bgCloseButton, false,
            false, true, false)
    end

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
    scrollBar.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(100, 100, 100))
    end
    scrollBar.btnGrip.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(200, 200, 200))
    end
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
            if input.IsKeyDown(KEY_ESCAPE) then
                print('yo on rentre dedans')
                parentPanel:Remove()
                menuOuvert = false
                hook.Remove("Think", "VerifierEchap")
            end
        end)

        local frame = CreerFrameMenuAnim(parentPanel)

        local extensionPanel = CreerModelEtExtensionPanel(parentPanel, frame)

        local closeButton = CreerButtonClose(parentPanel, frame)

        local scrollPanel = ImportScrollPanel(frame)

        local iconLayout = scrollPanel:Add("DIconLayout")
        iconLayout:SetSize(scrollPanel:GetWide(), scrollPanel:GetTall())
        iconLayout:SetSpaceX(5) -- Espacement horizontal entre les carrés
        iconLayout:SetSpaceY(5) -- Espacement vertical entre les carrés
        for _, config in ipairs(anim_config) do
            local carre = iconLayout:Add("DPanel")
            carre:SetSize(130, 150)
            carre.Paint = function(self, w, h)
                draw.RoundedBox(6, 0, 0, w, h, self:IsHovered() and Config.bgHoverButton or Config.bgButton)
                draw.SimpleText(config.nom, Config.FontButton, w / 2, h / 2, Config.ColorTextButton, TEXT_ALIGN_CENTER,
                    TEXT_ALIGN_CENTER)
            end

            carre.OnCursorEntered = function()
                previewAnim = config.action
            end
            carre.OnCursorExited = function()
                previewAnim = ""
            end

            if Config.ActivateIcon == true and config.icone and config.icone ~= "" then
                local iconImage = vgui.Create("DImage", carre)
                iconImage:SetSize(100, 100)
                iconImage:SetPos((carre:GetWide() - iconImage:GetWide()) / 2, 20)
                iconImage:SetImage(config.icone)
                iconImage:SetMouseInputEnabled(false)
                iconImage:SetVisible(true)
            end

            carre.OnMousePressed = function()
                if LocalPlayer():GetVelocity():LengthSqr() > 1 then
                    return -- Retourner si la vélocité du joueur est supérieure à 0
                end

                print("Carré cliqué! Action : " .. config.action)
                local armePrecedente = IsValid(LocalPlayer():GetActiveWeapon()) and
                                           LocalPlayer():GetActiveWeapon():GetClass() or ""
                net.Start("DemanderAnimation")
                net.WriteString(config.action)

                if Config.LockCameraForAllAnimations == true then
                    net.WriteBool(true)
                else
                    net.WriteBool(config.cameraLocked)
                    originalViewAngle = LocalPlayer():EyeAngles()
                    print(originalViewAngle)
                end
                net.SendToServer()
                print("Message envoyé au serveur.")

                local lockedYaw = nil
                local yawOffset = Config.AngleMaxWhenLocked

                net.Receive("BlockAtEyeTrace", function()
                    -- Verrouiller l'angle de vue lorsque le joueur entre dans le hook
                    local ply = LocalPlayer()
                    local eyeAngles = ply:EyeAngles()
                    lockedYaw = eyeAngles.yaw
                end)

                hook.Add("InputMouseApply", "LockToYawOnly", function(ccmd, x, y, angle)
                    if lockedYaw ~= nil then
                        -- Si l'angle est verrouillé, autoriser le mouvement horizontal avec une petite marge
                        local currentAngle = ccmd:GetViewAngles()
                        local sensitivity = Config.LockedCamSensitivity -- Ajustez la sensibilité selon vos préférences
                        local horizontalOffset = Config.AngleMaxWhenLocked -- Offset autorisé horizontalement par rapport à l'angle verrouillé

                        -- Calculer le nouvel angle de vue en fonction du mouvement horizontal de la souris
                        local newYaw = currentAngle.yaw + x * sensitivity

                        -- Gérer les cas où l'angle dépasse une rotation complète (360 degrés)
                        if newYaw - lockedYaw > 180 then
                            lockedYaw = lockedYaw + 360
                        elseif newYaw - lockedYaw < -180 then
                            lockedYaw = lockedYaw - 360
                        end

                        -- Limiter les angles de vue dans la plage autorisée autour de l'angle verrouillé
                        local minAngle = lockedYaw - horizontalOffset
                        local maxAngle = lockedYaw + horizontalOffset
                        local clampedYaw = math.Clamp(newYaw, minAngle, maxAngle)

                        -- Appliquer les nouveaux angles de vue
                        ccmd:SetViewAngles(Angle(currentAngle.pitch, clampedYaw, currentAngle.roll))

                        return true
                    end
                end)

                hook.Add("Think", "SurveillerMouvementEtArmePourAnimation", function()
                    local joueur = LocalPlayer()

                    -- Vérifier si le joueur a bougé rapidement, changé d'arme ou s'est accroupi
                    local armeActuelle = IsValid(joueur:GetActiveWeapon()) and joueur:GetActiveWeapon():GetClass() or ""
                    local estAccroupi = joueur:Crouching()
                    local nAppuiePasSurUse = joueur:KeyDown(IN_USE)

                    if config.IsWalkable == true and Config.isWalkableAllowedForAllAnims == true then
                        MaxVelForAction = Config.ActionWalkableVel
                    else
                        MaxVelForAction = Config.MaxDefaultActionVel
                    end
                    if joueur:GetVelocity():Length() > MaxVelForAction or
                        (armePrecedente ~= armeActuelle and armeActuelle ~= Config.SwepHand) or estAccroupi or
                        nAppuiePasSurUse then
                        hook.Remove("InputMouseApply", "LockToYawOnly")
                        net.Start("ReinitialiserOsDemande")
                        net.SendToServer()
                        hook.Remove("Think", "SurveillerMouvementEtArmePourAnimation")
                        hook.Add("GetCmdAndResetViewAngle", "RetirerLeHookApresExec", myHook) -- Remplacez "GetCmdAndResetViewAngle" par le nom du hook que vous souhaitez utiliser
                    end
                end)
                parentPanel:Remove()
                menuOuvert = false
            end
        end

        frame:MakePopup()
        menuOuvert = true
    end
end

local function VerifierTouchePressee()
    if input.IsKeyDown(Config.KeyBind) then
        OuvrirMenuPanel()
    end
end

net.Receive("ToggleThirdPerson", function()
    RunConsoleCommand("thirdperson")
end)
net.Receive("ToggleFirstPerson", function()
    RunConsoleCommand("firstperson")
end)

hook.Add("Think", "VerifierTouchePressee", VerifierTouchePressee)

