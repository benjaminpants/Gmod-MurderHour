AddCSLuaFile()
SWEP.Base = "weapon_murdh_applybase"
SWEP.ViewModel = "models/props/cs_office/paper_towels.mdl"
SWEP.WorldModel = "models/props/cs_office/paper_towels.mdl"
SWEP.PrintName = "Bandages"
SWEP.Pocketable = true
SWEP.HoldType = "slam"

SWEP.UseSounds = {"foley/alyx_hug_eli.wav"} -- lol?
SWEP.UseSoundDelay = {0.7,1}

DEFINE_BASECLASS(SWEP.Base)

local matrix = Matrix()

function SWEP:CalcViewModelView(vm, oldEyePos, oldEyeAng, eyePos, eyeAng)
	matrix:SetTranslation(eyePos)
	matrix:SetAngles(eyeAng)
	local offRight = 8
	local offUp = -5
	local offForward = 10
	return eyePos + (matrix:GetRight() * offRight) + (matrix:GetUp() * offUp) + (matrix:GetForward() * offForward), eyeAng
end

function SWEP:PlayUseSound(owner, otherPly)
	BaseClass.PlayUseSound(self)
	owner:SetAnimation(PLAYER_ATTACK1)
end

function SWEP:ActionFinished(owner, otherPly, completed)
	if (not completed) then return end
	otherPly:RemoveAllStatusEffectWithID("bleed_steady")
	otherPly:RemoveAllStatusEffectWithID("bleed_spurt")
end