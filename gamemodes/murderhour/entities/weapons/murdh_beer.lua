AddCSLuaFile()
SWEP.Base = "murdh_consumablebase"

SWEP.ViewModel = "models/weapons/c_grenade.mdl" --The equip looks dumb but oh well.
SWEP.WorldModel = "models/props_junk/GlassBottle01a.mdl"
SWEP.UseHands = true
SWEP.PrintName = "Beer"
SWEP.Purpose = "Drink away your problems. Calms your heart rate, don't overdose."

SWEP.ViewmodelRender = 
{
Model="models/props_junk/GlassBottle01a.mdl", --Model to render.
PosOffset=Vector(3,-3,-1.5), --Position offset.
AngOffset=Angle(0,0,180), --Angular offset.
Bone="ValveBiped.Bip01_R_Hand", --Bone the model attaches to.
}

DEFINE_BASECLASS(SWEP.Base)