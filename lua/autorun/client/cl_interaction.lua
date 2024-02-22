include("autorun/sh_interaction.lua")

local anim_config = {
    {action = "muscle", icone = "muscle.png", nom = "Muscle"},
    {action = "dance", icone = "", nom = "Danse"},
    {action = "becon ", icone = "", nom = "Becon"},
    {action = "agree", icone = "", nom = "Agree"},
    {action = "disagree", icone = "", nom = "Disagree "},
    {action = "forward", icone = "", nom = "Forward "},
    {action = "disagree", icone = "", nom = "Disagree "},
    {action = "forward", icone = "", nom = "Forward "},
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

    if config.icone and config.icone ~= "" then -- Vérifiez si le chemin de l'icône est défini et non vide
        local iconImage = vgui.Create("DImage", carre)
        iconImage:SetSize(100, 100) -- Réglez la taille de l'image selon vos besoins
        iconImage:SetPos((carre:GetWide() - iconImage:GetWide()) / 2, 20) -- Ajustez la position de l'image à l'intérieur du carré
        iconImage:SetImage(config.icone) -- Définissez le chemin de l'image à afficher
        iconImage:SetMouseInputEnabled(false) -- Désactivez l'interaction de la souris avec l'image (facultatif)
        iconImage:SetVisible(true) -- Assurez-vous que l'image est visible
    end

    carre.OnMousePressed = function()
        print("Carré cliqué! Action : " .. config.action)
        RunConsoleCommand("act", config.action)
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