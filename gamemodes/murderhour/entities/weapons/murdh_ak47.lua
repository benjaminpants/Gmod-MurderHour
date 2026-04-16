AddCSLuaFile()
SWEP.Base = "murdh_gunbase"

SWEP.Primary.ClipSize = 24
SWEP.Primary.DefaultClip = 24
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "Pistol"

SWEP.Primary.Damage = 7
SWEP.Primary.BulletForce = 1
SWEP.Primary.BulletCount = 1
SWEP.Primary.Delay = 0.1
SWEP.Primary.AmmoPerShot = 1
SWEP.Primary.Spread = Vector(0.03,0.03,0)
SWEP.Primary.BulletForce = 2
SWEP.Primary.Sound = Sound("Weapon_AK47.Single")
SWEP.Primary.SoundLevel = 60
SWEP.Primary.Recoil = Angle(-2,0,0)
SWEP.PrintName = "AK-47"
SWEP.HoldType = "ar2"
SWEP.CSMuzzleFlashes = true

SWEP.ViewModel = "models/weapons/cstrike/c_rif_ak47.mdl"
SWEP.WorldModel = "models/weapons/w_rif_ak47.mdl"
SWEP.UseHands = true
SWEP.Pocketable = false

DEFINE_BASECLASS(SWEP.Base)