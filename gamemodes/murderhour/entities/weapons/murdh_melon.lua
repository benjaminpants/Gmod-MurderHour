AddCSLuaFile()

SWEP.Base = "murdh_toolbase"
SWEP.UsesRenderableSystem = true
SWEP.HideWeaponModel=true
SWEP.Spawnable = false
SWEP.HoldType="duel"
SWEP.PrintName = "Watermelon"
SWEP.Purpose = "What kind of fruit is this? Cannot be eaten as is."
SWEP.Breakable = true
SWEP.UseHands = true
SWEP.Pocketable = false

SWEP.ViewModel = "models/weapons/cstrike/c_pist_elite.mdl"
SWEP.WorldModel = "models/props_junk/watermelon01.mdl"

SWEP.ViewmodelRender = 
{
Model="models/props_junk/watermelon01.mdl", --Model to render.
PosOffset=Vector(5,-8.25,4), --Position offset.
AngOffset=Angle(0,0,-90), --Angular offset.
Bone="ValveBiped.Bip01_R_Hand", --Bone the model attaches to.
}
SWEP.WorldmodelRender = 
{
Model="models/props_junk/watermelon01.mdl", --Model to render.
PosOffset=Vector(0,-11,0), --Position offset.
AngOffset=Angle(90,0,0), --Angular offset.
Bone="ValveBiped.Bip01_R_Hand", --Bone the model attaches to.
}

function SWEP:PrepareGib(velocity)
	for i=1,3 do
		local entity = ents.Create("murdh_melonslice")
		entity:SetPos(self:GetPos())
		entity:SetAngles(Angle(math.random(-360,360)),Angle(math.random(-360,360)),Angle(math.random(-360,360)))
		entity:Spawn()
	end
	--self:Gib(velocity)
	self:Remove()
end
