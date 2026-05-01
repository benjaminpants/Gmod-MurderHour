AddCSLuaFile()
SWEP.Base = "weapon_murdh_gunbase"

SWEP.Primary.ClipSize = 15
SWEP.Primary.DefaultClip = 15
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "Pistol"

SWEP.Primary.Damage = 8
SWEP.Primary.BulletCount = 1
SWEP.Primary.Delay = 0.13
SWEP.Primary.AmmoPerShot = 1
SWEP.Primary.Spread = Vector(0.0145,0.0145,0)
SWEP.Primary.BulletForce = 4
SWEP.Primary.Sound = "weapons/pistol/pistol_fire2.wav"
SWEP.Primary.SoundLevel = 60
SWEP.Primary.Recoil = Angle(-1,0,0)
SWEP.PrintName = "Glock"
SWEP.HoldType = "pistol"
SWEP.CSMuzzleFlashes = true

SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.UseHands = true

DEFINE_BASECLASS(SWEP.Base)