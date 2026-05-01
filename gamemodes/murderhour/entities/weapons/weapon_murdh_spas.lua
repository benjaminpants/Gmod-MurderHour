AddCSLuaFile()
SWEP.Base = "weapon_murdh_gunbase"

SWEP.Primary.ClipSize = 6
SWEP.Primary.DefaultClip = 6
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "Pistol"

SWEP.Primary.Damage = 9
SWEP.Primary.BulletCount = 6
SWEP.Primary.Delay = 0.5
SWEP.Primary.AmmoPerShot = 1
SWEP.Primary.Spread = Vector(0.085,0.085,0)
SWEP.Primary.BulletForce = 3
SWEP.Primary.Sound = Sound("weapons/shotgun/shotgun_fire7.wav")
SWEP.Primary.SoundLevel = 60
--SWEP.Primary.SoundPitch = 90
SWEP.Primary.Recoil = Angle(-4,0,0)
SWEP.PrintName = "SPAS-12"
SWEP.HoldType = "shotgun"
SWEP.CSMuzzleFlashes = false

SWEP.ViewModel = "models/weapons/c_shotgun.mdl"
SWEP.WorldModel = "models/weapons/w_shotgun.mdl"
SWEP.UseHands = true
SWEP.Pocketable = false

DEFINE_BASECLASS(SWEP.Base)