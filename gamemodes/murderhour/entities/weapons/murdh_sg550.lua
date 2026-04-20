AddCSLuaFile()
SWEP.Base = "murdh_gunbase"

SWEP.Primary.ClipSize = 20
SWEP.Primary.DefaultClip = 20
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "Pistol"

SWEP.Primary.Damage = 8
SWEP.Primary.BulletCount = 1
SWEP.Primary.Delay = 0.2
SWEP.Primary.AmmoPerShot = 1
SWEP.Primary.Spread = Vector(0.03,0.03,0)
SWEP.Primary.BulletForce = 3
SWEP.Primary.Sound = Sound("weapons/sg552/sg552-1.wav")
SWEP.Primary.SoundLevel = 60
--SWEP.Primary.SoundPitch = 90
SWEP.Primary.Recoil = Angle(-3,0,0)
SWEP.PrintName = "SG550"
SWEP.HoldType = "ar2"
SWEP.CSMuzzleFlashes = true

SWEP.ViewModel = "models/weapons/cstrike/c_snip_sg550.mdl"
SWEP.WorldModel = "models/weapons/w_snip_sg550.mdl"
SWEP.UseHands = true
SWEP.Pocketable = false

DEFINE_BASECLASS(SWEP.Base)