AddCSLuaFile()
SWEP.Base = "murdh_gunbase"

SWEP.Primary.ClipSize = 2
SWEP.Primary.DefaultClip = 2
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "Pistol"

SWEP.Primary.Damage = 25
SWEP.Primary.BulletForce = 1
SWEP.Primary.BulletCount = 1
SWEP.Primary.Delay = 1.6
SWEP.Primary.AmmoPerShot = 1
SWEP.Primary.Spread = Vector(0.001,0.001,0)
SWEP.Primary.BulletForce = 10
SWEP.Primary.Sound = Sound("Weapon_Scout.Single")
SWEP.Primary.SoundLevel = 60
SWEP.Primary.Recoil = Angle(-10,0,0)
SWEP.PrintName = "Sniper"
SWEP.HoldType = "smg"
SWEP.CSMuzzleFlashes = true

SWEP.ViewModel = "models/weapons/cstrike/c_snip_scout.mdl"
SWEP.WorldModel = "models/weapons/w_snip_scout.mdl"
SWEP.UseHands = true

SWEP.Pocketable = false

DEFINE_BASECLASS(SWEP.Base)

function SWEP:PrimaryBulletCallback(attack, trace, dmgInfo)
	if (not SERVER) then return end
	if (IsValid(trace.Entity)) then
		if (trace.Entity:IsPlayer()) then
			trace.Entity:AddOrUpdateStatusEffect("bleed_steady", math.random(15,30), 3)
		end
	end
end