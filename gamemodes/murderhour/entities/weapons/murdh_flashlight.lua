AddCSLuaFile()
SWEP.Base = "murdh_toolbase"

SWEP.ViewModel = "models/weapons/c_shotgun.mdl"
SWEP.WorldModel = "models/maxofs2d/lamp_flashlight.mdl"
SWEP.HoldType = "pistol"
SWEP.UseHands = true
SWEP.PrintName = "Flashlight"

DEFINE_BASECLASS(SWEP.Base)

function SWEP:Deploy()
	if (not SERVER) then return end
	self:GetOwner():AllowFlashlight(true)
	self:GetOwner():Flashlight(true)
	self:GetOwner():AllowFlashlight(false)
end

function SWEP:Holster()
	if (not SERVER) then return end
	self:GetOwner():AllowFlashlight(true)
	self:GetOwner():Flashlight(false)
	self:GetOwner():AllowFlashlight(false)
	return true
end

function SWEP:DrawWorldModel(flags)
	if (not self:GetOwner():IsPlayer()) then
		self:DrawModel(flags)
	end
end