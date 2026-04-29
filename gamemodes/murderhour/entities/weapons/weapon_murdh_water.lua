AddCSLuaFile()
SWEP.Base = "weapon_murdh_consumablebase"

SWEP.ViewModel = "models/weapons/c_grenade.mdl" --The equip looks dumb but oh well.
SWEP.WorldModel = "models/props/cs_office/water_bottle.mdl"
SWEP.UseHands = true
SWEP.PrintName = "Water"
SWEP.Purpose = "Remember to stay hydrated!"
SWEP.ThirstRestore=20

SWEP.ViewmodelRender = 
{
Model="models/props/cs_office/water_bottle.mdl", --Model to render.
PosOffset=Vector(3,-2.5,-1.5), --Position offset.
AngOffset=Angle(0,0,180), --Angular offset.
Bone="ValveBiped.Bip01_R_Hand", --Bone the model attaches to.
}

SWEP.WorldmodelRender=
{
Model="models/props/cs_office/water_bottle.mdl", --Model to render.
PosOffset=Vector(3,-1.3,-1.5), --Position offset.
AngOffset=Angle(0,0,180), --Angular offset.
Bone="ValveBiped.Bip01_R_Hand", --Bone the model attaches to.
}

DEFINE_BASECLASS(SWEP.Base)