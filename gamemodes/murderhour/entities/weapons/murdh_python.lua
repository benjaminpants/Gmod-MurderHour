AddCSLuaFile()
SWEP.Base = "murdh_gunbase"

SWEP.Primary.ClipSize = 6
SWEP.Primary.DefaultClip = 6
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "Pistol"

SWEP.Primary.Damage = 20
SWEP.Primary.BulletCount = 1
SWEP.Primary.Delay = 0.5
SWEP.Primary.AmmoPerShot = 1
SWEP.Primary.Spread = Vector(0.015,0.015,0)
SWEP.Primary.BulletForce = 4
SWEP.Primary.Sound = "weapons/deagle/deagle-1.wav"
SWEP.Primary.SoundLevel = 60
SWEP.Primary.Recoil = Angle(-10,0,0)
SWEP.PrintName = "Python"
SWEP.HoldType = "revolver"
SWEP.CSMuzzleFlashes = true

SWEP.ViewModel = "models/weapons/c_357.mdl"
SWEP.WorldModel = "models/weapons/w_357.mdl"
SWEP.UseHands = true

DEFINE_BASECLASS(SWEP.Base)