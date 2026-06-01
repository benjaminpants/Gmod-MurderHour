--models/griim/foodpack/plate.mdl

AddCSLuaFile()
SWEP.Base = "weapon_murdh_toolbase"

SWEP.ViewModel = "models/griim/foodpack/plate.mdl"
SWEP.WorldModel = "models/griim/foodpack/plate.mdl"
SWEP.HoldType = "pistol"
SWEP.UseHands = false
SWEP.PrintName = "Plate"
SWEP.Pocketable = false
SWEP.WorldmodelRender = {
{
	Model="models/griim/foodpack/plate.mdl", --Model to render.
	PosOffset=Vector(3,0,-3), --Position offset.
	AngOffset=Angle(0,0,-180), --Angular offset.
	Bone="ValveBiped.Bip01_R_Hand", --Bone the model attaches to.
}}
SWEP.UsesRenderableSystem = true
SWEP.UsesRenderableSystemInWorld = false
SWEP.Breakable = true

DEFINE_BASECLASS(SWEP.Base)

local matrix = Matrix()

function SWEP:CalcViewModelView(vm, oldEyePos, oldEyeAng, eyePos, eyeAng)
	matrix:SetTranslation(eyePos)
	matrix:SetAngles(eyeAng)
	eyeAng:RotateAroundAxis(matrix:GetUp(), 90)
	local offRight = 10
	local offUp = -8
	local offForward = 24
	return eyePos + (matrix:GetRight() * offRight) + (matrix:GetUp() * offUp) + (matrix:GetForward() * offForward), eyeAng
end