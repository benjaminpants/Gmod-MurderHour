AddCSLuaFile()
SWEP.Base = "murdh_toolbase"

SWEP.Primary.Damage = 0
SWEP.Primary.BulletForce = 1
SWEP.Primary.BulletCount = 1
SWEP.Primary.Delay = 1
SWEP.Primary.AmmoPerShot = 1
SWEP.Primary.Spread = Vector(0,0,0)
SWEP.Primary.Sound = Sound("Weapon_Glock.Single")
SWEP.Primary.SoundLevel = 75
SWEP.Primary.Recoil = Angle(0,0,0)

DEFINE_BASECLASS(SWEP.Base)

function SWEP:PlayPrimaryFireSound()
	self:EmitSound(self.Primary.Sound, self.Primary.SoundLevel)
end

function SWEP:PrimaryAttack()
	if (not self:CanPrimaryAttack()) then
		return
	end
	local owner = self:GetOwner()
	owner:FireBullets({
		Attacker=owner,
		Inflictor=self,
		Damage=self.Primary.Damage,
		Force=self.Primary.BulletForce,
		Count=self.Primary.BulletCount,
		AmmoType=self.Primary.Ammo,
		Dir=owner:GetAimVector(),
		Src=owner:GetShootPos(),
		IgnoreEntity=owner,
		Spread=self.Primary.Spread,
		Callback=function(attack, trace, dmgInfo)
			self:PrimaryBulletCallback(attack, trace, dmgInfo)
		end
	})
	owner:ViewPunch(self.Primary.Recoil * (math.random(1,20) / 20))
	self:PlayPrimaryFireSound()
	self:DoShootEffects()
	self:TakePrimaryAmmo(self.Primary.AmmoPerShot)
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
end

function SWEP:Reload()
	self:DefaultReload(ACT_VM_RELOAD)
end

function SWEP:DoShootEffects(primary)
	self:ShootEffects()
end

function SWEP:PrimaryBulletCallback(attack, trace, dmgInfo)

end