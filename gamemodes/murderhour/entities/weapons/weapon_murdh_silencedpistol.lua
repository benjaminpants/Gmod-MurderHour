AddCSLuaFile()
SWEP.Base = "weapon_murdh_gunbase"

SWEP.Primary.ClipSize = 6
SWEP.Primary.DefaultClip = 6
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "Pistol"

SWEP.Primary.Damage = 10
SWEP.Primary.BulletForce = 1
SWEP.Primary.BulletCount = 1
SWEP.Primary.Delay = 0.25
SWEP.Primary.AmmoPerShot = 1
SWEP.Primary.Spread = Vector(0.011,0.011,0)
SWEP.Primary.Sound = "weapons/usp/usp1.wav"
SWEP.Primary.SoundLevel = 30
SWEP.Primary.Recoil = Angle(-1,0,0)
SWEP.PrintName = "Silencer"
SWEP.HoldType = "pistol"
SWEP.CSMuzzleFlashes = true

SWEP.ViewModel = "models/weapons/cstrike/c_pist_usp.mdl"
SWEP.WorldModel = "models/weapons/w_pist_usp_silencer.mdl"
SWEP.UseHands = true

DEFINE_BASECLASS(SWEP.Base)

function SWEP:DoShootEffects(primary)
	BaseClass.DoShootEffects(self, primary)
	local vm = self:GetOwner():GetViewModel()
	vm:SendViewModelMatchingSequence(vm:SelectWeightedSequence(ACT_VM_PRIMARYATTACK_SILENCED))
end

function SWEP:Reload()
	self:DefaultReload(ACT_VM_RELOAD_SILENCED)
end

function SWEP:Deploy()
	local vm = self:GetOwner():GetViewModel()
	vm:SendViewModelMatchingSequence(vm:SelectWeightedSequence(ACT_VM_DRAW_SILENCED))
end