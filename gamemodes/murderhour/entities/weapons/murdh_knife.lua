SWEP.Base = "murdh_chargeweaponbase"

SWEP.ViewModel = "models/weapons/cstrike/c_knife_t.mdl"
SWEP.WorldModel = "models/weapons/w_knife_t.mdl"
SWEP.Primary.ChargeTimes = {0.75,4,10}
SWEP.UseHands = true
SWEP.IsHolsterable = false
SWEP.HoldType = "knife"

DEFINE_BASECLASS(SWEP.Base)

function SWEP:PrimaryChargeReleased(chargeTime, chargeLevel)
	local owner = self:GetOwner()
	local vm = owner:GetViewModel()
	self:SetNextPrimaryFire(CurTime() + 0.4)

	owner:LagCompensation(true)

	local shootPos = owner:GetShootPos()
	local endShootPos = shootPos + owner:GetAimVector() * 60

	local trace = self:Trace(shootPos, endShootPos)

	if (trace.Hit) then
		if (SERVER) then
			local dmginfo = DamageInfo()
			dmginfo:SetAttacker(owner)
			dmginfo:SetInflictor(self)
			dmginfo:SetWeapon(self)

			local calculateddmg = 3
			if (chargeLevel == 1) then
				calculateddmg = 6
			elseif (chargeLevel == 2) then
				calculateddmg = 10
			elseif (chargeLevel == 3) then
				calculateddmg = 35
			end
			dmginfo:SetDamageType(DMG_SLASH)

			dmginfo:SetDamage(calculateddmg)
			dmginfo:SetDamagePosition(trace.HitPos)
			trace.Entity:TakeDamageInfo(dmginfo)
			SuppressHostEvents(NULL)
			self:PerformImpact(shootPos, DMG_SLASH, trace)
			SuppressHostEvents(self:GetOwner())
		end
		if (trace.Entity:IsPlayer() or trace.Entity:IsNPC()) then
			if (chargeLevel == 3) then
				self:EmitSound("weapons/knife/knife_stab.wav", 50)
				vm:SendViewModelMatchingSequence(vm:LookupSequence("stab"))
			else
				vm:SendViewModelMatchingSequence(vm:SelectWeightedSequence(ACT_VM_PRIMARYATTACK))
				self:EmitSound("weapons/knife/knife_hit" .. math.random(1,4) .. ".wav", 30)
			end
		else
			vm:SendViewModelMatchingSequence(vm:SelectWeightedSequence(ACT_VM_PRIMARYATTACK))
			self:EmitSound("weapons/knife/knife_hitwall1.wav", 50)
		end
	else
		self:EmitSound("weapons/knife/knife_slash" .. math.random(1,2) .. ".wav", 25)
		if (chargeLevel == 3) then
			vm:SendViewModelMatchingSequence(vm:LookupSequence("stab_miss"))
		end
	end

	owner:LagCompensation(false)

	owner:SetAnimation(PLAYER_ATTACK1)
end

function SWEP:PrimaryChargeLevelIncreased(chargeLevel)
	if (CLIENT) then
		self:EmitSound("weapons/knife/knife_deploy1.wav", 30, 75 + (25 * chargeLevel), 1)
	end
end

function SWEP:Deploy()
	self:EmitSound("weapons/knife/knife_deploy1.wav", 25)
end