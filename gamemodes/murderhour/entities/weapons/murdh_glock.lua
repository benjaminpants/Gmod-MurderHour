AddCSLuaFile()
SWEP.Base = "murdh_gunbase"

SWEP.Primary.ClipSize = 18
SWEP.Primary.DefaultClip = 18
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "Pistol"

SWEP.Primary.Damage = 8
SWEP.Primary.BulletForce = 1
SWEP.Primary.BulletCount = 1
SWEP.Primary.Delay = 0.15
SWEP.Primary.AmmoPerShot = 1
SWEP.Primary.Spread = Vector(0.01,0.01,0)
SWEP.Primary.BulletForce = 4.5
SWEP.Primary.Sound = "weapons/glock/glock18-1.wav"
SWEP.Primary.SoundLevel = 60
SWEP.Primary.Recoil = Angle(-1,0,0)
SWEP.PrintName = "Glock"
SWEP.HoldType = "revolver"
SWEP.CSMuzzleFlashes = true

SWEP.ViewModel = "models/weapons/cstrike/c_pist_glock18.mdl"
SWEP.WorldModel = "models/weapons/w_pist_glock18.mdl"
SWEP.UseHands = true

DEFINE_BASECLASS(SWEP.Base)