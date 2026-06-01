AddCSLuaFile()
SWEP.Base = "weapon_murdh_consumablebase"

SWEP.ViewModel = "models/weapons/c_bugbait.mdl"
SWEP.WorldModel = "models/foodnhouseholditems/watermelon_slice.mdl"
SWEP.UseHands = true
SWEP.PrintName = "Melon Slice"
SWEP.Purpose = "The red part tastes good, not so much the rest."
SWEP.HungerRestore=11
SWEP.ThirstRestore=8
SWEP.Breakable = true
SWEP.IsFoodIngredient = true

SWEP.ViewmodelRender = {
{
Model="models/foodnhouseholditems/watermelon_slice.mdl", --Model to render.
PosOffset=Vector(3,-1,1), --Position offset.
AngOffset=Angle(50,0,90), --Angular offset.
Bone="ValveBiped.Bip01_R_Hand", --Bone the model attaches to.
}}
SWEP.WorldmodelRender = {
{
Model="models/foodnhouseholditems/watermelon_slice.mdl", --Model to render.
PosOffset=Vector(3.25,-5,2), --Position offset.
AngOffset=Angle(25,80,180), --Angular offset.
Bone="ValveBiped.Bip01_R_Hand", --Bone the model attaches to.
}}

DEFINE_BASECLASS(SWEP.Base)