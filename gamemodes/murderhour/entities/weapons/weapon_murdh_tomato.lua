AddCSLuaFile()
SWEP.Base = "weapon_murdh_consumablebase" --todo: tomatos should be weapons.

SWEP.ViewModel = "models/weapons/c_bugbait.mdl"
SWEP.WorldModel = "models/foodnhouseholditems/tomato.mdl"
SWEP.UseHands = true
SWEP.PrintName = "Tomato"
SWEP.Purpose = "Tomatooooooo it is a tomatoo.... yeah..."
SWEP.HungerRestore=8
SWEP.ThirstRestore=5
SWEP.Breakable = false
SWEP.IsFoodIngredient = true

SWEP.ViewmodelRender = {
{
Model="models/foodnhouseholditems/tomato.mdl", --Model to render.
PosOffset=Vector(2,-4,1.5), --Position offset.
AngOffset=Angle(0,0,90), --Angular offset.
Bone="ValveBiped.Bip01_R_Hand", --Bone the model attaches to.
}}
SWEP.WorldmodelRender = {
{
Model="models/foodnhouseholditems/tomato.mdl", --Model to render.
PosOffset=Vector(2.5,-3.5,0.1), --Position offset.
AngOffset=Angle(0,0,180), --Angular offset.
Bone="ValveBiped.Bip01_R_Hand", --Bone the model attaches to.
}}

DEFINE_BASECLASS(SWEP.Base)