AddCSLuaFile()
SWEP.Base = "weapon_murdh_consumablebase"

SWEP.ViewModel = "models/weapons/c_bugbait.mdl"
SWEP.WorldModel = "models/props_junk/watermelon01_chunk01b.mdl"
SWEP.UseHands = true
SWEP.PrintName = "Melon Slice"
SWEP.Purpose = "The red part tastes good, not so much the rest."
SWEP.HungerRestore=11
SWEP.ThirstRestore=8
SWEP.Breakable = true

SWEP.ViewmodelRender = 
{
Model="models/props_junk/watermelon01_chunk01b.mdl", --Model to render.
PosOffset=Vector(3,-6,0), --Position offset.
AngOffset=Angle(50,0,90), --Angular offset.
Bone="ValveBiped.Bip01_R_Hand", --Bone the model attaches to.
}
SWEP.WorldmodelRender = 
{
Model="models/props_junk/watermelon01_chunk01b.mdl", --Model to render.
PosOffset=Vector(1.85,-3.5,0.1), --Position offset.
AngOffset=Angle(50,0,90), --Angular offset.
Bone="ValveBiped.Bip01_R_Hand", --Bone the model attaches to.
}

DEFINE_BASECLASS(SWEP.Base)