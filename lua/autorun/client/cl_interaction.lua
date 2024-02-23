include("autorun/sh_interaction.lua")
include("autorun/config/anims_hud.lua")

local function OuvrirMenuPanel()
    if not menuOuvert then

        local parentPanel = vgui.Create("DPanel")
        parentPanel:SetSize(840, 390)
        parentPanel:SetPos(ScrW() / 2 - parentPanel:GetWide() / 2, ScrH() / 2 - parentPanel:GetTall() / 2)
        parentPanel:SetBackgroundColor(COLOR_TEAM_BLUE)

        local frame = vgui.Create("DFrame", parentPanel)
        frame:SetSize(600, 390)
        frame:SetPos((ScrW() / 2 - parentPanel:GetWide() / 2) + (parentPanel:GetWide() - frame:GetWide()),
            ScrH() / 2 - parentPanel:GetTall() / 2) -- Positionner le frame au centre horizontalement à l'intérieur du parentPanel
        frame:SetTitle("")
        frame:ShowCloseButton(false)
        frame:SetDraggable(false) -- Rendre le frame non déplaçable
        frame.Paint = function(self, w, h)
            draw.RoundedBoxEx(0, 0, 0, w, h, Color(33, 33, 33), true, true, false, false)
            draw.SimpleText("Animations", "Trebuchet24", w / 2, 20, Color(255, 255, 255), TEXT_ALIGN_CENTER,
                TEXT_ALIGN_CENTER)
        end

        local extensionPanel = vgui.Create("DPanel", parentPanel)
        extensionPanel:SetSize(parentPanel:GetWide() - frame:GetWide(), frame:GetTall())
        extensionPanel:SetPos(0, 0)
        extensionPanel.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50))
            -- Ajoutez votre code pour la preview et l'icône ici

            local modelPanel = vgui.Create("DModelPanel", extensionPanel)
            modelPanel:SetSize(w, h)
            modelPanel:SetAnimated(false)
            modelPanel:SetModel("models/drem/cch/male_03.mdl")
            modelPanel:SetCamPos(Vector(45, 0, 45))
            modelPanel:SetFOV(60)
            function modelPanel:LayoutEntity(ent)
                return
            end
            modelPanel:SetAmbientLight(Color(0, 0, 0, 10))
            modelPanel:SetAnimated(false)
        end

        local closeButton = vgui.Create("DButton", frame)
        closeButton:SetText("X")
        closeButton:SetFont("Trebuchet18")
        closeButton:SetColor(Color(255, 255, 255))
        closeButton:SetSize(30, 30)
        closeButton:SetPos(frame:GetWide() - 30, 0)
        closeButton.Paint = function(self, w, h)
            draw.RoundedBoxEx(6, 0, 0, w, h, self:IsHovered() and Color(255, 0, 0) or Color(230, 80, 80), false, false,
                true, false)
        end
        closeButton.DoClick = function()
            if IsValid(parentPanel) then
                parentPanel:Remove()
                menuOuvert = false
            end
        end

        local scrollPanel = vgui.Create("DScrollPanel", frame)
        scrollPanel:SetPos(20, 60)
        scrollPanel:SetSize(frame:GetWide() - 30, frame:GetTall() - 80)

        local scrollBar = scrollPanel:GetVBar() -- Récupérer la barre de défilement verticale

        -- Modifier l'apparence de la barre de défilement
        scrollBar.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(100, 100, 100)) -- Dessiner un rectangle arrondi pour la barre de défilement
        end

        scrollBar.btnGrip.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(150, 150, 150)) -- Dessiner un rectangle arrondi pour la poignée de défilement
        end

        scrollBar.btnUp.Paint = function(self, w, h)
        end
        scrollBar.btnDown.Paint = function(self, w, h)
        end

        local iconLayout = scrollPanel:Add("DIconLayout")
        iconLayout:SetSize(scrollPanel:GetWide(), scrollPanel:GetTall())
        iconLayout:SetSpaceX(5) -- Espacement horizontal entre les carrés
        iconLayout:SetSpaceY(5) -- Espacement vertical entre les carrés

        for _, config in ipairs(anim_config) do
            local carre = iconLayout:Add("DPanel")
            carre:SetSize(180, 140)
            carre.Paint = function(self, w, h)
                draw.RoundedBox(6, 0, 0, w, h, self:IsHovered() and Color(150, 80, 80) or Color(60, 60, 60))
                draw.SimpleText(config.nom, "DermaDefault", w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER,
                    TEXT_ALIGN_CENTER)
            end

            if config.icone and config.icone ~= "" then
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
                        (armePrecedente ~= armeActuelle and armeActuelle ~= "weapon_tg_fists") or estAccroupi then
                        print(
                            "Mouvement rapide détecté ou changement d'arme différent de weapon_tg_fists ou accroupissement. Envoi de la demande de réinitialisation des os.")
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

