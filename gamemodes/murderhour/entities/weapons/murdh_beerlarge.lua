AddCSLuaFile()
SWEP.Base = "murdh_consumablebase"

SWEP.ViewModel = "models/weapons/c_grenade.mdl"
SWEP.WorldModel = "models/props_junk/garbage_glassbottle001a.mdl"
SWEP.UseHands = true
SWEP.PrintName = "Large Beer"
SWEP.Purpose = "Really drink away your problems. Calms your heart rate, don't overdose."
SWEP.Breakable = true
SWEP.ThirstRestore=20

SWEP.ViewmodelRender = 
{
Model="models/props_junk/garbage_glassbottle001a.mdl", --Model to render.
PosOffset=Vector(4,-3,2), --Position offset.
AngOffset=Angle(0,0,180), --Angular offset.
Bone="ValveBiped.Bip01_R_Hand", --Bone the model attaches to.
}

SWEP.WorldmodelRender=
{
Model="models/props_junk/garbage_glassbottle001a.mdl", --Model to render.
PosOffset=Vector(3,-5,2), --Position offset.
AngOffset=Angle(-15,0,210), --Angular offset.
Bone="ValveBiped.Bip01_R_Hand", --Bone the model attaches to.
}

function SWEP:OnConsume(Owner)
	Owner:AddOrUpdateStatusEffect("drunk", 120, math.min(Owner:GetStatusStrength("drunk")+2,5))
end

DEFINE_BASECLASS(SWEP.Base)