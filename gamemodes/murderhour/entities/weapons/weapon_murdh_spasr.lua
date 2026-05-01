AddCSLuaFile()
SWEP.Base = "weapon_murdh_gunbase"

SWEP.Primary.ClipSize = 4
SWEP.Primary.DefaultClip = 4
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "Pistol"

SWEP.Primary.Damage = 9
SWEP.Primary.BulletCount = 12
SWEP.Primary.Delay = 1
SWEP.Primary.AmmoPerShot = 2
SWEP.Primary.Spread = Vector(0.12,0.12,0)
SWEP.Primary.BulletForce = 3
SWEP.Primary.Sound = Sound("weapons/shotgun/shotgun_dbl_fire.wav")
SWEP.Primary.SoundLevel = 70
--SWEP.Primary.SoundPitch = 90
SWEP.Primary.Recoil = Angle(-20,0,0)
SWEP.PrintName = "SPAS-R"
SWEP.HoldType = "shotgun"
SWEP.CSMuzzleFlashes = false

SWEP.ViewModel = "models/weapons/c_shotgun.mdl"
SWEP.WorldModel = "models/weapons/w_shotgun.mdl"
SWEP.UseHands = true
SWEP.Pocketable = false

DEFINE_BASECLASS(SWEP.Base)