GM.PlayerModels={}
--I thought the hands were stored in the clothing texture but I was wrong.
--So now these tables make me look like a freak.

--THEY CANNOT WEAR BUTTON UPS, THEY WILL WEAR RAGS INSTEAD >:( !?!??!??!
local CivFemWhite={"FC_W_Standard"}
local CivFemBlack={"FC_B_Standard"}
local CivMalWhite={"MC_W_Standard"}
local CivMalBlack={"MC_B_Standard"}

local CivStandardHeadwear={nil,"Beanie"}

--also one of the clothing indexs is messed up, good luck! it's the bald one
GM.PlayerModels=
{
---
["models/player/group01/female_01.mdl"]={
Gender="Female",
AllowedBodyTextures=CivFemWhite,
AllowedHeadwear=CivStandardHeadwear,
ClothingIndex=2,
},
["models/player/group01/female_02.mdl"]={
Gender="Female",
AllowedBodyTextures=CivFemWhite,
AllowedHeadwear=CivStandardHeadwear,
ClothingIndex=3,
},
["models/player/group01/female_03.mdl"]={
Gender="Female",
AllowedBodyTextures=CivFemBlack,
AllowedHeadwear=CivStandardHeadwear,
ClothingIndex=3,
},
["models/player/group01/female_04.mdl"]={
Gender="Female",
AllowedBodyTextures=CivFemWhite,
AllowedHeadwear=CivStandardHeadwear,
ClothingIndex=1,
},
["models/player/group01/female_05.mdl"]={
Gender="Female",
AllowedBodyTextures=CivFemBlack,
AllowedHeadwear=CivStandardHeadwear,
ClothingIndex=2,
},
["models/player/group01/female_06.mdl"]={
Gender="Female",
AllowedBodyTextures=CivFemWhite,
AllowedHeadwear=CivStandardHeadwear,
ClothingIndex=4,
},
---
["models/player/group01/male_01.mdl"]={
Gender="Male",
AllowedBodyTextures=CivMalBlack,
AllowedHeadwear=CivStandardHeadwear,
ClothingIndex=3,
},
["models/player/group01/male_02.mdl"]={
Gender="Male",
AllowedBodyTextures=CivMalWhite,
AllowedHeadwear=CivStandardHeadwear,
ClothingIndex=3,
},
["models/player/group01/male_03.mdl"]={
Gender="Male",
AllowedBodyTextures=CivMalBlack,
AllowedHeadwear=CivStandardHeadwear,
ClothingIndex=4,
},
["models/player/group01/male_04.mdl"]={
Gender="Male",
AllowedBodyTextures=CivMalWhite,
AllowedHeadwear=CivStandardHeadwear,
ClothingIndex=5,
},
["models/player/group01/male_05.mdl"]={
Gender="Male",
AllowedBodyTextures=CivMalWhite,
AllowedHeadwear=CivStandardHeadwear,
ClothingIndex=5,
},
["models/player/group01/male_06.mdl"]={
Gender="Male",
AllowedBodyTextures=CivMalWhite,
AllowedHeadwear=CivStandardHeadwear,
ClothingIndex=1,
},
["models/player/group01/male_07.mdl"]={
Gender="Male",
AllowedBodyTextures=CivMalWhite,
AllowedHeadwear=CivStandardHeadwear,
ClothingIndex=4,
},
["models/player/group01/male_08.mdl"]={
Gender="Male",
AllowedBodyTextures=CivMalWhite,
AllowedHeadwear=CivStandardHeadwear,
ClothingIndex=0,
},
["models/player/group01/male_09.mdl"]={
Gender="Male",
AllowedBodyTextures=CivMalWhite,
AllowedHeadwear=CivStandardHeadwear,
ClothingIndex=0,
},
}

GM.PlayerApparel=
{
--FEMALE-- --why no button up? :(
FC_W_Standard="models/humans/female/group01/players_sheet",
FC_B_Standard="models/humans/female/group01/players_sheet",
--MALE
MC_W_Standard="models/humans/male/group01/players_sheet",
MC_B_Standard="models/humans/male/group01/players_sheet",
-- WHY DO YOU WEAR RAGS?!?!?!?!
--MC_W_ButtonUp="models/humans/male/group02/players_sheet",
--MC_B_ButtonUp="models/humans/male/group02/players_sheet",

}

GM.PlayerHeadwear=
{
Beanie={
Model="models/parts hl2/hl2_cap.mdl",
UsePlayerColor=true,
PosOffset=Vector(2.1, -0.5, 0.422),
AngOffset=Angle(0,110,90),
Bone="ValveBiped.Bip01_Head1",
},
}

local playerMeta = FindMetaTable("Player")
function playerMeta:GetPMInfo()
	return GAMEMODE.PlayerModels[self:GetModel()]
end

hook.Add("PostPlayerDraw", "MurdH_Renderable_Player", function(ply)
	if not IsValid(ply) then return end
	local arenderable=ply:GetNWString("Headwear") --make render on bodies too pls
	if arenderable ~= nil and arenderable ~= "none" then
		local renderable=GAMEMODE.PlayerHeadwear[arenderable]
		if (renderable == nil) then return end -- player is wearing invalid renderable
		local offsetvec = renderable.PosOffset
		local offsetang = renderable.AngOffset
		local boneid = ply:LookupBone(renderable.Bone)
		if not boneid then
			return
		end
		local matrix = ply:GetBoneMatrix( boneid )
	
		if not matrix then 
			return 
		end
		local newpos, newang = LocalToWorld( offsetvec, offsetang, matrix:GetTranslation(), matrix:GetAngles() )
		local modelexample = ClientsideModel(renderable.Model)
		modelexample:SetNoDraw( true )
		modelexample:SetPos( newpos )
		modelexample:SetAngles( newang )
		modelexample:SetupBones()
		modelexample.GetPlayerColor=function() return ply:GetPlayerColor() end
		modelexample:DrawModel()
		modelexample:Remove()
	end
	end)