AddCSLuaFile()

// quite a bit of this code is borrowed and heavily modified from weapon_fists.lua

SWEP.PropForce = 80
SWEP.PropForceAddendPerCharge = 20
SWEP.PropUpForce = 200
SWEP.PlayerForce = 100
SWEP.PlayerForceAddendPerCharge = 50
SWEP.HitSize = {
	Min = Vector( -10, -10, -8 ),
	Max = Vector( 10, 10, 8 )
}
SWEP.HitDelay = 0.1

SWEP.Primary.ChargeTimes = {0.5,1,2}

SWEP.Base = "murdh_chargeweaponbase"
SWEP.PrintName = "Hands"

SWEP.ViewModel = Model("models/weapons/c_arms.mdl")
SWEP.WorldModel = ""
SWEP.UseHands = true

SWEP.SwingSound = Sound("WeaponFrag.Throw") -- Sound of the fists swinging
SWEP.HitSound = Sound("Flesh.ImpactHard") -- Sound of the fists hitting an entity
SWEP.Purpose = "The only things you can pick stuff up with! Press Reload to switch to fists!"

SWEP.Slot = 0
SWEP.SlotPos = 0

DEFINE_BASECLASS(SWEP.Base)

function SWEP:Initialize()
	BaseClass.Initialize(self)
	self:SetHoldType("normal")
end

function SWEP:SetupDataTables()
	BaseClass.SetupDataTables(self)
	self:NetworkVar("Float", "NextIdle")
	self:NetworkVar("Bool", "LastWasRight")
	self:NetworkVar("Float", "NextMeleeAttack" )
	self.LastTimePassed = 0
	self.lastChargeLevel = 0
end

function SWEP:PrimaryChargeReleased(chargeTime, chargeLevel)
	local owner = self:GetOwner()

	self:SetNextPrimaryFire(CurTime() + 0.3)
	if (chargeLevel <= 2) then
		self:SwingFist(not self:GetLastWasRight())
		if (chargeLevel >= 1) then
			self:SetNextPrimaryFire(CurTime() + 0.05)
		end
		self:SetNextMeleeAttack(CurTime() + self.HitDelay)
		self.lastChargeLevel = chargeLevel
	end
	
	if (chargeLevel == 3) then
		owner:SetAnimation(PLAYER_ATTACK1)
		local vm = owner:GetViewModel()
		vm:SendViewModelMatchingSequence(vm:LookupSequence("fists_uppercut"))
		self:UpdateNextIdle()
		self:EmitSound(self.SwingSound, 75,70)
		self:SetNextPrimaryFire(CurTime() + 1)
		self:SetNextMeleeAttack(CurTime() + self.HitDelay)
		self.lastChargeLevel = chargeLevel
	end
end

function SWEP:PrimaryAttack()
	BaseClass.PrimaryAttack(self)
	self:SetNextPrimaryFire(CurTime() + 0.1)
	local owner = self:GetOwner()
	if (not IsValid(owner)) then return end
	if (not owner:IsPlayer()) then return end
	if (owner:HasStatusEffect("exhausted")) then
		self:CancelCharge(true)
	end
end

function SWEP:SecondaryAttack()
	self:CancelCharge(false)
end

function SWEP:GetViewModelPosition(pos, ang)
	if (self:IsCharging()) then
		self.LastTimePassed = CurTime() - self:GetChargeStart()
	else
		self.LastTimePassed = math.max(0,math.min(self.LastTimePassed,1.25) - FrameTime())
	end
	local calculatedAlterTime = math.max(math.min((self.LastTimePassed * 4) - 0.5,1),0)
	ang:RotateAroundAxis(ang:Right(), (calculatedAlterTime * 2))
	return pos, ang
end

local phys_pushscale = GetConVar( "phys_pushscale" )

local upward = Vector(0,0,1)

local leftAngle = Angle(0,5,0)
local rightAngle = Angle(0,-5,0)
local upAngle = Angle(-15,0,0)

function SWEP:DoDamage(right, charge)
	local owner = self:GetOwner()
	owner:LagCompensation( true )

	local tr = util.TraceLine( {
		start = owner:GetShootPos(),
		endpos = owner:GetShootPos() + owner:GetAimVector() * 48,
		filter = owner,
		mask = MASK_SHOT_HULL
	})

	if (!IsValid( tr.Entity )) then
		tr = util.TraceHull( {
			start = owner:GetShootPos(),
			endpos = owner:GetShootPos() + owner:GetAimVector() * 48,
			filter = owner,
			mins = self.HitSize.Min,
			maxs = self.HitSize.Max,
			mask = MASK_SHOT_HULL
		} )
	end

	if (tr.Hit) then
		self:EmitSound(self.HitSound)
	end
	local scale = phys_pushscale:GetFloat()

	if (SERVER and IsValid(tr.Entity)) then
		local dmginfo = DamageInfo()

		dmginfo:SetAttacker(owner)

		dmginfo:SetInflictor(self)
		dmginfo:SetWeapon(self)

		local dmg = 1 + charge
		if (charge == 3) then
			dmginfo:SetDamageForce( owner:GetUp() * 5158 * scale + owner:GetForward() * 10012 * scale )
			dmg = 5
		else
			if (not right) then
				dmginfo:SetDamageForce( owner:GetRight() * 4912 * scale + owner:GetForward() * 9998 * scale ) -- Yes we need those specific numbers
			else
				dmginfo:SetDamageForce( owner:GetRight() * -4912 * scale + owner:GetForward() * 9989 * scale )
			end
		end

		dmginfo:SetDamage( istable( dmg ) and math.random( dmg[ 1 ], dmg[ 2 ] ) or dmg )

		dmginfo:SetDamagePosition( tr.HitPos )

		SuppressHostEvents(NULL)
		tr.Entity:TakeDamageInfo( dmginfo )
		SuppressHostEvents(owner)

		if (tr.Entity:IsPlayer()) then
			if (charge == 3) then
				tr.Entity:ViewPunch(upAngle)
			else
				if (right) then
					tr.Entity:ViewPunch(rightAngle * math.max(charge, 0.5))
				else
					tr.Entity:ViewPunch(leftAngle * math.max(charge, 0.5))
				end
			end
		end
	end

	if (IsValid(tr.Entity)) then
		local phys = tr.Entity:GetPhysicsObject()
		if (IsValid(phys) and not tr.Entity:IsPlayer()) then
			phys:ApplyForceOffset(owner:GetAimVector() * (self.PropForce + (self.PropForceAddendPerCharge * charge)) * phys:GetMass() * scale, tr.HitPos )
			if (charge == 3) then
				phys:ApplyForceOffset(upward * self.PropUpForce * phys:GetMass() * scale, tr.HitPos )
			end
		else
			local velocityToAdd = owner:GetAimVector() * (self.PlayerForce + (self.PlayerForceAddendPerCharge * charge))
			velocityToAdd = velocityToAdd - Vector(0,0,velocityToAdd.Z)
			if (charge == 3) then
				velocityToAdd = velocityToAdd + (upward * (self.PlayerForce))
			end
			velocityToAdd = velocityToAdd + tr.Entity:GetVelocity()
			tr.Entity:SetGroundEntity(NULL)
			tr.Entity:SetVelocity(velocityToAdd)
		end
	end

	owner:LagCompensation(false)
end

function SWEP:SwingFist(right)
	self:SetLastWasRight(right)
	local owner = self:GetOwner()

	owner:SetAnimation(PLAYER_ATTACK1)

	local anim = "fists_left"
	if (right) then
		anim = "fists_right"
	end

	local vm = owner:GetViewModel()
	vm:SendViewModelMatchingSequence(vm:LookupSequence(anim))

	self:UpdateNextIdle()

	self:EmitSound(self.SwingSound)
end

function SWEP:ChargeLevelIncreased(chargeLevel)
	if (CLIENT) then
		self:EmitSound("physics/cardboard/cardboard_box_impact_soft7.wav", 30, 50 + (25 * chargeLevel), 1)
	end
end

function SWEP:UpdateNextIdle()
	local vm = self:GetOwner():GetViewModel()
	self:SetNextIdle( CurTime() + vm:SequenceDuration() / vm:GetPlaybackRate() )
end

function SWEP:OnStanceChanged()
	local speed = 2
	local vm = self:GetOwner():GetViewModel()
	if (self:GetAttackStance()) then
		self:SetHoldType("fist")
		vm:SendViewModelMatchingSequence(vm:LookupSequence("fists_draw"))
		vm:SetPlaybackRate(speed)
	else
		self:SetHoldType("normal")
		vm:SendViewModelMatchingSequence(vm:LookupSequence("fists_holster"))
		vm:SetPlaybackRate(speed)
	end
	self:UpdateNextIdle()
	self:SetNextPrimaryFire(CurTime() + (vm:SequenceDuration() / speed))
	self:SetNextSecondaryFire(CurTime() + (vm:SequenceDuration() / speed))
	self:SetSwitchCooldown(CurTime() + (vm:SequenceDuration() / speed))
end

function SWEP:Deploy()
	self:SetAttackStance(false)
	self:SetHoldType("normal")
	local vm = self:GetOwner():GetViewModel()
	vm:SendViewModelMatchingSequence(vm:LookupSequence("reference"))
end

function SWEP:Think()
	BaseClass.Think(self)
	local curTime = CurTime()
	local attackStance = self:GetAttackStance()
	if (curTime > self:GetNextIdle()) then
		if (attackStance) then
			self:PlayIdle()
		end
	end
	if ((self:GetNextMeleeAttack() > 0) and (curTime > self:GetNextMeleeAttack())) then
		self:DoDamage(self:GetLastWasRight(), self.lastChargeLevel)
		self:SetNextMeleeAttack(0)
	end
	local vm = self:GetOwner():GetViewModel()
	if (self:GetAttackFullyDown() == false) then
		if (vm:IsSequenceFinished()) then
			self:SetAttackFullyDown(true)
			vm:SendViewModelMatchingSequence(vm:LookupSequence("reference"))
		end
	end
end

function SWEP:PlayIdle()
	local vm = self:GetOwner():GetViewModel()
	vm:SendViewModelMatchingSequence(vm:LookupSequence("fists_idle_0" .. math.random( 1, 2 )))
	self:UpdateNextIdle()
end