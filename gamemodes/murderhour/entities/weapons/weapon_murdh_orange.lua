AddCSLuaFile()
SWEP.Base = "weapon_murdh_consumablebase"

SWEP.ViewModel = "models/weapons/c_bugbait.mdl"
SWEP.WorldModel = "models/props/cs_italy/orange.mdl"
SWEP.UseHands = true
SWEP.PrintName = "Orange"
SWEP.Purpose = "Tasty fruit. Can be cut with a knife."
SWEP.HungerRestore=10
SWEP.ThirstRestore=2
SWEP.Breakable = true

SWEP.ViewmodelRender = 
{
Model="models/props/cs_italy/orange.mdl", --Model to render.
PosOffset=Vector(2,-4,1.5), --Position offset.
AngOffset=Angle(0,0,90), --Angular offset.
Bone="ValveBiped.Bip01_R_Hand", --Bone the model attaches to.
}
SWEP.WorldmodelRender = 
{
Model="models/props/cs_italy/orange.mdl", --Model to render.
PosOffset=Vector(2.5,-3.5,0.1), --Position offset.
AngOffset=Angle(0,0,0), --Angular offset.
Bone="ValveBiped.Bip01_R_Hand", --Bone the model attaches to.
}

DEFINE_BASECLASS(SWEP.Base)