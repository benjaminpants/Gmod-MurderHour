AddCSLuaFile()
SWEP.Base = "weapon_murdh_toolbase"
SWEP.Range = 80
SWEP.UsageTime = 5
SWEP.SelfUsageTime = nil
SWEP.CanSelfApply = true
SWEP.CanApplyToBodies = true
SWEP.ActionTitles = {"#murderhour.action.placeholder", "#murderhour.action.beingplaceholdered"}

SWEP.UseSounds = {"friends/message.wav"}

SWEP.UseSoundDelay = {0.3,1}

DEFINE_BASECLASS(SWEP.Base)

function SWEP:Initialize()
	BaseClass.Initialize(self)
	self.timeUntilNextSound = 0
end

function SWEP:PrimaryAttack()
	if (not SERVER) then return end
	local owner = self:GetOwner()
	local eyePos = owner:EyePos()
	local trace = self:Trace(eyePos, eyePos + (owner:GetAimVector() * self.Range))
	if (not trace.Hit) then return end
	local otherPly = trace.Entity
	if (not IsValid(otherPly)) then return end
	if ((otherPly:GetNWBool("IsCorpse") and not otherPly:GetNWBool("IsDead")) and self.CanApplyToBodies) then
		otherPly = otherPly:GetNWEntity("Owner")
	end
	if (not otherPly:IsPlayer()) then return end
	self.timeUntilNextSound = 0
	if (not self:ActionStart(owner, otherPly)) then return end
	owner:StartConnectedActionBarWith(otherPly, self.ActionTitles[1], self.ActionTitles[2], CurTime() + self.UsageTime, function(ply, other)
		return self:ActionTick(ply, other)
	end, function(ply, other, completed)
		self:ActionFinished(ply, other, completed)
	end)
	self:SetNextPrimaryFire(CurTime() + 0.2)
	self:SetNextSecondaryFire(CurTime() + 0.2)
end

function SWEP:SecondaryAttack()
	if (not self.CanSelfApply) then return end
	if (not SERVER) then return end
	local owner = self:GetOwner()
	self.timeUntilNextSound = 0
	if (not self:ActionStart(owner, otherPly)) then return end
	owner:StartActionBar(self.ActionTitles[1], CurTime() + (self.SelfUsageTime or self.UsageTime), true, function(ply)
		return self:ActionTick(ply, ply)
	end, function(ply, completed)
		self:ActionFinished(ply, ply, completed)
	end)
	self:SetNextPrimaryFire(CurTime() + 0.2)
	self:SetNextSecondaryFire(CurTime() + 0.2)
end

function SWEP:ActionStart(owner, otherPly)
	return true
end

function SWEP:ActionTick(owner, otherPly)
	if (owner:GetActiveWeapon() ~= self) then return false end
	self.timeUntilNextSound = self.timeUntilNextSound - FrameTime()
	if (self.timeUntilNextSound <= 0) then
		self.timeUntilNextSound = math.Rand(self.UseSoundDelay[1],self.UseSoundDelay[2])
		self:PlayUseSound(owner, otherPly)
	end
	return true
end

function SWEP:PlayUseSound(owner, otherPly)
	self:EmitSound(self.UseSounds[math.random(1,#self.UseSounds)])
end

function SWEP:ActionFinished(owner, otherPly, completed)

end