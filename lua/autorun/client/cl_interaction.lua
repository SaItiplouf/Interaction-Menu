include("autorun/sh_interaction.lua")


local anim_config = {
    {action = "crossarm", icone = "", nom = "Bras croisés"},
    {action = "crossarm_back", icone = "", nom = "Bras croisés(dos)"},
    {action = "comlink", icone = "", nom = "Montre"},
    {action = "high_five", icone = "", nom = "High Five"},
    {action = "hololink", icone = "", nom = "Téléphone"},
    {action = "middlefinger", icone = "", nom = "Fuck "},
    {action = "pointindirection", icone = "", nom = "Pointer vers"},
    {action = "salute", icone = "", nom = "Salut "},
}


local function OuvrirMenuPanel()
    if not menuOuvert then





local frame = vgui.Create("DFrame")
frame:SetSize(600, 390)
frame:SetTitle("")
frame:Center()
frame:ShowCloseButton(false)

frame.Paint = function(self, w, h)
    draw.RoundedBoxEx(0, 0, 0, w, h, Color(33, 33, 33), true, true, false, false)
    draw.SimpleText("Interactions", "Trebuchet24", w/2, 20, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end






local closeButton = vgui.Create("DButton", frame)
closeButton:SetText("X")
closeButton:SetFont("DermaLarge")
closeButton:SetColor(Color(255, 255, 255))
closeButton:SetSize(40, 40)
closeButton:SetPos(frame:GetWide() - 40, 0)
closeButton.Paint = function(self, w, h)
    draw.RoundedBoxEx(6, 0, 0, w, h, self:IsHovered() and Color(255, 0, 0) or Color(200, 80, 80), false, false, true, false) -- Seul le coin en bas à gauche est arrondi
end
closeButton.DoClick = function()
    frame:Close()
    menuOuvert = false
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
        draw.SimpleText(config.nom, "DermaDefault", w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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
        net.Start("DemanderAnimation")
        net.WriteString(config.action)
        net.SendToServer()
        print("Message envoyé au serveur.")
        
        -- Surveiller le mouvement après avoir lancé "dance"
       hook.Add("Think", "SurveillerMouvementPourAnimation", function()
           if LocalPlayer():GetVelocity():LengthSqr() > 32000 then
                print("passage dans l'appel client")
                net.Start("ReinitialiserOsDemande")
                net.SendToServer()
                hook.Remove("Think", "SurveillerMouvementPourAnimation") -- Désactiver la surveillance après détection du mouvement
            end
        end)
    frame:Close()
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

hook.Add("Think", "VerifierTouchePressee", VerifierTouchePressee)
