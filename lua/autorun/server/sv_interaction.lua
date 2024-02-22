include("autorun/sh_interaction.lua")
util.AddNetworkString("DemanderAnimation")
util.AddNetworkString("ReinitialiserOsDemande")

-- Fonction pour réinitialiser les os
local function RéinitialiserOs(ply)
    ply:SetNWBool("EnAnimation", false)
    local nombreOs = ply:GetBoneCount()
    for i = 0, nombreOs - 1 do -- Les indices des os commencent à 0
        ply:ManipulateBoneAngles(i, Angle(0, 0, 0))
        ply:ManipulateBonePosition(i, Vector(0, 0, 0)) -- Réinitialiser la position si nécessaire
    end
end

local configurationsAnimation = {
    crossarm = {
            ["ValveBiped.Bip01_R_Forearm"] = Angle(-43.779933929443,-107.18412780762,15.918969154358),
            ["ValveBiped.Bip01_R_UpperArm"] = Angle(20.256689071655, -57.223915100098, -6.1269416809082),
            ["ValveBiped.Bip01_L_UpperArm"] = Angle(-28.913911819458, -59.408206939697, 1.0253102779388),
            ["ValveBiped.Bip01_R_Thigh"] = Angle(4.7250719070435, -6.0294013023376, -0.46876749396324),
            ["ValveBiped.Bip01_L_Thigh"] = Angle(-7.6583762168884, -0.21996378898621, 0.4060270190239),
            ["ValveBiped.Bip01_L_Forearm"] = Angle(51.038677215576, -120.44165039063, -18.86986541748),
            ["ValveBiped.Bip01_R_Hand"] = Angle(14.424224853516, -33.406204223633, -7.2624106407166),
            ["ValveBiped.Bip01_L_Hand"] = Angle(25.959447860718, 31.564517974854, -14.979378700256),
    },
    crossarm_back = {
            ["ValveBiped.Bip01_R_UpperArm"] = Angle(3.809, 15.382, 2.654),
	        ["ValveBiped.Bip01_R_Forearm"] = Angle(-63.658, 1.8 , -84.928),
	        ["ValveBiped.Bip01_L_UpperArm"] = Angle(3.809, 15.382, 2.654),
	        ["ValveBiped.Bip01_L_Forearm"] = Angle(53.658, -29.718, 31.455),

	        ["ValveBiped.Bip01_R_Thigh"] = Angle(4.829, 0, 0),
	        ["ValveBiped.Bip01_L_Thigh"] = Angle(-8.89, 0, 0),
    },
    comlink = {
            ["ValveBiped.Bip01_R_UpperArm"] = Angle(32.9448, -103.5211, 2.2273),
	        ["ValveBiped.Bip01_R_Forearm"] = Angle(-90.3271, -31.3616, -41.8804),
	        ["ValveBiped.Bip01_R_Hand"] = Angle(0,0,-24),
    },
    high_five = {
        ["ValveBiped.Bip01_L_Forearm"] = Angle(25,-65,25),
	    ["ValveBiped.Bip01_L_UpperArm"] = Angle(-70,-180,70),
    },
    hololink = {
        ["ValveBiped.Bip01_R_UpperArm"] = Angle(10,-20),
	        ["ValveBiped.Bip01_R_Hand"] = Angle(0,1,50),
	        ["ValveBiped.Bip01_Head1"] = Angle(0,-30,-20),
	        ["ValveBiped.Bip01_R_Forearm"] = Angle(0,-65,39.8863),
    },
    middlefinger = {
       ["ValveBiped.Bip01_R_UpperArm"] = Angle(15,-55,-0),
	        ["ValveBiped.Bip01_R_Forearm"] = Angle(0,-55,-0),
	        ["ValveBiped.Bip01_R_Hand"] = Angle(20,20,90),
	        ["ValveBiped.Bip01_R_Finger1"] = Angle(20,-40,-0),
	        ["ValveBiped.Bip01_R_Finger3"] = Angle(0,-30,0),
	        ["ValveBiped.Bip01_R_Finger4"] = Angle(-10,-40,0),
	        ["ValveBiped.Bip01_R_Finger11"] = Angle(-0,-70,-0),
	        ["ValveBiped.Bip01_R_Finger31"] = Angle(0,-70,0),
	        ["ValveBiped.Bip01_R_Finger41"] = Angle(0,-70,0),
	        ["ValveBiped.Bip01_R_Finger12"] = Angle(-0,-70,-0),
	        ["ValveBiped.Bip01_R_Finger32"] = Angle(0,-70,0),
	        ["ValveBiped.Bip01_R_Finger42"] = Angle(0,-70,-0),
    },
    pointindirection = {
            ["ValveBiped.Bip01_R_Finger2"] = Angle(4.151602268219, -52.963024139404, 0.42117667198181),
	        ["ValveBiped.Bip01_R_Finger21"] = Angle(0.00057629722869024, -58.618747711182, 0.001297949347645),
	        ["ValveBiped.Bip01_R_Finger3"] = Angle(4.151602268219, -52.963024139404, 0.42117667198181),
	        ["ValveBiped.Bip01_R_Finger31"] = Angle(0.00057629722869024, -58.618747711182, 0.001297949347645),
	        ["ValveBiped.Bip01_R_Finger4"] = Angle(4.151602268219, -52.963024139404, 0.42117667198181),
	        ["ValveBiped.Bip01_R_Finger41"] = Angle(0.00057629722869024, -58.618747711182, 0.001297949347645),
	        ["ValveBiped.Bip01_R_UpperArm"] = Angle(25.019514083862, -87.288040161133, -0.0012286090059206),
    },
    salute = {
            ["ValveBiped.Bip01_R_UpperArm"] = Angle(80, -95, -77.5),
	        ["ValveBiped.Bip01_R_Forearm"] = Angle(35, -125, -5),
    },
}

net.Receive("DemanderAnimation", function(len, ply)
    local typeAnimation = net.ReadString()
    print("Demande d'animation " .. typeAnimation .. " reçue du client.")
    
    if IsValid(ply) and ply:IsPlayer() then
        -- Vérifier si le joueur est déjà en animation
        if ply:GetNWBool("EnAnimation") then
            -- Vérifier si l'animation demandée est la même que celle en cours
            if ply:GetNWString("TypeAnimation") == typeAnimation then
                print("La même animation est déjà en cours, réinitialisation des os uniquement.")
                RéinitialiserOs(ply)
                -- Important : Retourner ici pour ne pas relancer la même animation
                return
            else
                print("Une autre animation est en cours, réinitialisation des os avant de lancer la nouvelle animation.")
                RéinitialiserOs(ply)
            end
        end

        local weapon = ply:GetWeapon("weapon_tg_fists")
        if IsValid(weapon) then
            ply:SetActiveWeapon(weapon)
        else
            ply:Give("weapon_tg_fists")
            ply:SetActiveWeapon("weapon_tg_fists")
        end
        
        if configurationsAnimation[typeAnimation] then
            ply:SetNWBool("EnAnimation", true)
            ply:SetNWString("TypeAnimation", typeAnimation) -- Stocker le type d'animation en cours
            local anglesDesOs = configurationsAnimation[typeAnimation]

            for nomOs, angle in pairs(anglesDesOs) do
                local idOs = ply:LookupBone(nomOs)
                if idOs then
                    ply:ManipulateBoneAngles(idOs, angle)
                end
            end
        end
    end
end)

net.Receive("ReinitialiserOsDemande", function(len, ply)
    if IsValid(ply) and ply:IsPlayer() and ply:GetNWBool("EnAnimation") then
        local typeAnimation = ply:GetNWString("TypeAnimation")
        local osAReinitialiser = configurationsAnimation[typeAnimation] -- Utiliser la configuration spécifique à l'animation
        for nomOs, _ in pairs(osAReinitialiser) do
            local idOs = ply:LookupBone(nomOs)
            if idOs then
                ply:ManipulateBoneAngles(idOs, Angle(0, 0, 0))
            end
        end
    end
end)


