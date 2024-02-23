include("autorun/sh_interaction.lua")
include("autorun/config/anims_hud.lua")
include("autorun/config/anims_pos.lua")
include("autorun/config/config.lua")

local previewAnim = "crossarm"
local function CreerFrameMenuAnim(parentPanel)
    local frame = vgui.Create("DFrame", parentPanel)
    frame:SetSize(600, 390)
    frame:SetPos((ScrW() / 2 - parentPanel:GetWide() / 2) + (parentPanel:GetWide() - frame:GetWide()),
        ScrH() / 2 - parentPanel:GetTall() / 2)
    frame:SetTitle("")
    frame:ShowCloseButton(false)
    frame:SetDraggable(false)
    frame.Paint = function(self, w, h)
        draw.RoundedBoxEx(0, 0, 0, w, h, Config.bgPanelColor, true, true, false, false)
        draw.SimpleText(Config.Title, Config.TitreFont, w / 2, 20, Color(255, 255, 255), TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER)
    end
    return frame
end
local function configScrollBar(scrollPanel)
    local scrollBar = scrollPanel:GetVBar()
    scrollBar:SetHideButtons(true)
    scrollBar.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(100, 100, 100))
    end
    scrollBar.btnGrip.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(150, 150, 150))
    end
    scrollBar.btnUp.Paint = function(self, w, h)
    end
    scrollBar.btnDown.Paint = function(self, w, h)
    end
end
local function CreerModelPanel(extensionPanel, w, h)

    local modelPanel = vgui.Create("DModelPanel", extensionPanel)
    local ply = LocalPlayer() -- Récupérer l'entité du joueur local
    local playerModel = ply:GetModel() -- Récupérer le modèle du joueur local
    modelPanel:SetSize(w, h)
    modelPanel:SetAnimated(false)
    modelPanel:SetModel(playerModel)
    modelPanel:SetCamPos(Vector(45, 50, 55))
    modelPanel:SetFOV(60)

    function modelPanel:LayoutEntity(ent)
        if configurationsAnimation and configurationsAnimation[previewAnim] then
            local animConfig = configurationsAnimation[previewAnim]
            for bone, angle in pairs(animConfig) do
                local boneIndex = ent:LookupBone(bone)
                if boneIndex and angle then
                    ent:ManipulateBoneAngles(boneIndex, angle)
                end
            end
        else
            for i = 0, ent:GetBoneCount() - 1 do
                ent:ManipulateBoneAngles(i, Angle(0, 0, 0))
            end
        end
    end
    modelPanel:SetAmbientLight(Color(60, 60, 60, 255))
    modelPanel:SetAnimated(false)
    return modelPanel
end
local function CreerButtonClose(frame, parentPanel)
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
local function OuvrirMenuPanel()
    if not menuOuvert then

        local parentPanel = vgui.Create("DPanel")
        parentPanel:SetSize(850, 390)
        parentPanel:SetPos(ScrW() / 2 - parentPanel:GetWide() / 2, ScrH() / 2 - parentPanel:GetTall() / 2)

        local frame = CreerFrameMenuAnim(parentPanel)

        local extensionPanel = vgui.Create("DPanel", parentPanel)
        extensionPanel:SetSize(parentPanel:GetWide() - frame:GetWide(), frame:GetTall())
        extensionPanel:SetPos(0, 0)
        local modelPanel = CreerModelPanel(extensionPanel, extensionPanel:GetWide(), extensionPanel:GetTall()) -- Appel de la fonction CreerModelPanel
        extensionPanel.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Config.bgExtensionModelColor)
        end

        local closeButton = CreerButtonClose(frame, parentPanel)

        local scrollPanel = vgui.Create("DScrollPanel", frame)
        scrollPanel:SetPos(20, 60)
        scrollPanel:SetSize(frame:GetWide() - 30, frame:GetTall() - 80)
        configScrollBar(scrollPanel)

        local iconLayout = scrollPanel:Add("DIconLayout")
        iconLayout:SetSize(scrollPanel:GetWide(), scrollPanel:GetTall())
        iconLayout:SetSpaceX(3) -- Espacement horizontal entre les carrés
        iconLayout:SetSpaceY(3) -- Espacement vertical entre les carrés

        for _, config in ipairs(anim_config) do
            local carre = iconLayout:Add("DPanel")
            carre:SetSize(180, 140)
            carre.Paint = function(self, w, h)
                draw.RoundedBox(6, 0, 0, w, h, self:IsHovered() and Config.bgHoverButton or Config.bgButton)
                draw.SimpleText(config.nom, "DermaDefault", w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER,
                    TEXT_ALIGN_CENTER)
            end

            carre.OnCursorEntered = function()
                previewAnim = config.action
            end

            -- Définir une fonction pour effectuer une action lorsque le curseur quitte le bouton
            carre.OnCursorExited = function()
                previewAnim = ""
                print('exit')
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
                print("Carré cliqué! Action : " .. config.action)
                local armePrecedente = IsValid(LocalPlayer():GetActiveWeapon()) and
                                           LocalPlayer():GetActiveWeapon():GetClass() or ""
                net.Start("DemanderAnimation")
                net.WriteString(config.action)
                net.SendToServer()
                print("Message envoyé au serveur.")

                hook.Add("Think", "SurveillerMouvementEtArmePourAnimation", function()
                    local joueur = LocalPlayer()

                    -- Vérifier si le joueur a bougé rapidement, changé d'arme ou s'est accroupi
                    local armeActuelle = IsValid(joueur:GetActiveWeapon()) and joueur:GetActiveWeapon():GetClass() or ""
                    local estAccroupi = joueur:Crouching()

                    if joueur:GetVelocity():LengthSqr() > 30000 or
                        (armePrecedente ~= armeActuelle and armeActuelle ~= Config.SwepHand) or estAccroupi then
                        print(
                            "Mouvement rapide détecté ou changement d'arme différent des mains ou accroupissement. Envoi de la demande de réinitialisation des os.")
                        net.Start("ReinitialiserOsDemande")
                        net.SendToServer()
                        hook.Remove("Think", "SurveillerMouvementEtArmePourAnimation")
                    end

                    armePrecedente = armeActuelle
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
    if input.IsKeyDown(KEY_G) then
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

