AddCSLuaFile()
SWEP.Base = "weapon_murdh_gunbase"

SWEP.Primary.ClipSize = 20
SWEP.Primary.DefaultClip = 20
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "Pistol"

SWEP.Primary.Damage = 5
SWEP.Primary.BulletForce = 1
SWEP.Primary.BulletCount = 1
SWEP.Primary.Delay = 0.065
SWEP.Primary.AmmoPerShot = 1
SWEP.Primary.Spread = Vector(0.055,0.055,0)
SWEP.Primary.Sound = Sound("weapons/smg1/smg1_fire1.wav")
SWEP.Primary.SoundLevel = 60
SWEP.Primary.Recoil = Angle(-1.5,0,0)
SWEP.PrintName = "MP7"
SWEP.Purpose = "Light submachine gun with an extendable stock and folding grip."
SWEP.HoldType = "ar2"
SWEP.CSMuzzleFlashes = false

SWEP.ViewModel = "models/weapons/c_smg1.mdl"
SWEP.WorldModel = "models/weapons/w_smg1.mdl"
SWEP.UseHands = true

DEFINE_BASECLASS(SWEP.Base)