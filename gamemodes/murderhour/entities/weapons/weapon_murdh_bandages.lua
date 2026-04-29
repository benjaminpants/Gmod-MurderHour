AddCSLuaFile()
SWEP.Base = "weapon_murdh_toolbase"
SWEP.ViewModel = "models/props/cs_office/paper_towels.mdl"
SWEP.WorldModel = "models/props/cs_office/paper_towels.mdl"
SWEP.PrintName = "Bandages"
SWEP.Pocketable = true

local matrix = Matrix()

function SWEP:CalcViewModelView(vm, oldEyePos, oldEyeAng, eyePos, eyeAng)
	matrix:SetTranslation(eyePos)
	matrix:SetAngles(eyeAng)
	local offRight = 8
	local offUp = -5
	local offForward = 10
	return eyePos + (matrix:GetRight() * offRight) + (matrix:GetUp() * offUp) + (matrix:GetForward() * offForward), eyeAng
end
