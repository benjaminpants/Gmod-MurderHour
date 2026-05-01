--models/props_interiors/pot02a.mdl

AddCSLuaFile()
SWEP.Base = "weapon_murdh_chargeweaponbase"

SWEP.ViewModel = "models/weapons/c_stunstick.mdl"
SWEP.WorldModel = "models/props_interiors/pot02a.mdl"
SWEP.HoldType = "normal"
SWEP.UseHands = true
SWEP.IsHolsterable = true
SWEP.Pocketable = false
SWEP.PrintName = "Pan"

SWEP.Primary.ChargeTimes = {2,3,7}

SWEP.ViewmodelRender = 
{
Model="models/props_interiors/pot02a.mdl", --Model to render.
PosOffset=Vector(2,-2.5,-7), --Position offset.
AngOffset=Angle(0,90,-90), --Angular offset.
Bone="ValveBiped.Bip01_R_Hand", --Bone the model attaches to.
}
SWEP.WorldmodelRender = 
{
Model="models/props_interiors/pot02a.mdl", --Model to render.
PosOffset=Vector(4.5,-1,-4), --Position offset.
AngOffset=Angle(0,90,-90), --Angular offset.
Bone="ValveBiped.Bip01_R_Hand", --Bone the model attaches to.
}
SWEP.UsesRenderableSystem = true
SWEP.HideWeaponModel=true
SWEP.HitSounds = {"phx/epicmetal_hard.wav", "phx/epicmetal_hard1.wav", "phx/epicmetal_hard2.wav", "phx/epicmetal_hard3.wav", "phx/epicmetal_hard4.wav", "phx/epicmetal_hard5.wav", "phx/epicmetal_hard6.wav"}

DEFINE_BASECLASS(SWEP.Base)


function SWEP:Deploy()
	self:SetAttackStance(false)
	self:OnStanceChanged()
end

function SWEP:OnStanceChanged()
	local vm = self:GetOwner():GetViewModel()
	if (self:GetAttackStance()) then
		self:SetHoldType("melee2")
		vm:SendViewModelMatchingSequence(vm:LookupSequence("draw"))
		self:SetNextPrimaryFire(CurTime() + 1)
	else
		self:SetHoldType("normal")
		vm:SendViewModelMatchingSequence(vm:LookupSequence("holster"))
	end
end

function SWEP:PrimaryAttack()
	if (self:GetAttackStance()) then
		return BaseClass.PrimaryAttack(self)
	end
	if (SERVER) then
		local owner = self:GetOwner()
		owner:DropWeaponGentlyAndRemoveIfAppropiate(self)
	end
	self:SetNextPrimaryFire(CurTime() + 1)
end

function SWEP:PrimaryChargeLevelIncreased(chargeLevel)
	if (CLIENT) then
		self:EmitSound(self.HitSounds[math.random(1, #self.HitSounds)], 30, 125 + (25 * chargeLevel), 1)
	end
end

function SWEP:PrimaryChargeReleased(chargeTime, chargeLevel)
	local owner = self:GetOwner()
	local vm = owner:GetViewModel()
	self:SetNextPrimaryFire(CurTime() + 1)

	owner:LagCompensation(true)

	local shootPos = owner:GetShootPos()
	local endShootPos = shootPos + owner:GetAimVector() * 60

	local trace = self:Trace(shootPos, endShootPos)

	vm:SendViewModelMatchingSequence(vm:SelectWeightedSequence(ACT_VM_PRIMARYATTACK))
	if (trace.Hit) then
		local volToPlay = 40
		if (chargeLevel >= 3) then
			volToPlay = 70
		end
		self:EmitSound(self.HitSounds[math.random(1, #self.HitSounds)], volToPlay)
		if (SERVER) then
			local dmginfo = DamageInfo()
			dmginfo:SetAttacker(owner)
			dmginfo:SetInflictor(self)
			dmginfo:SetWeapon(self)

			local calculateddmg = 5
			if (chargeLevel == 1) then
				calculateddmg = 8
			elseif (chargeLevel == 2) then
				calculateddmg = 12
			else
				calculateddmg = 20
			end
			dmginfo:SetDamageType(DMG_CRUSH)

			dmginfo:SetDamage(calculateddmg)
			dmginfo:SetDamagePosition(trace.HitPos)
			SuppressHostEvents(NULL)
			trace.Entity:TakeDamageInfo(dmginfo)
			self:PerformImpact(shootPos, DMG_CRUSH, trace)
			SuppressHostEvents(self:GetOwner())
			if (trace.Entity:IsPlayer()) then
				if (chargeLevel >= 3) then
					trace.Entity:AddOrUpdateStatusEffect("blackout", 45, 2)
				end
			end
		end
		if (trace.Entity:IsPlayer() and (chargeLevel >= 3)) then
			vm:SendViewModelMatchingSequence(vm:SelectWeightedSequence(ACT_VM_MISSCENTER))
		else
			vm:SendViewModelMatchingSequence(vm:SelectWeightedSequence(ACT_VM_HITCENTER))
		end
	else
		vm:SendViewModelMatchingSequence(vm:SelectWeightedSequence(ACT_VM_MISSCENTER))
		self:EmitSound("WeaponFrag.Throw", 40)
	end

	owner:LagCompensation(false)

	owner:SetAnimation(PLAYER_ATTACK1)
end

hook.Add("StartCommand", "MHPanStartCommand", function(ply, cmd)
	local activeWep = ply:GetActiveWeapon()
	if (not IsValid(activeWep)) then return end
	if (activeWep:GetClass() == "weapon_murdh_pan") then
		if (activeWep:GetChargeLevel() >= 1) then
			cmd:SetButtons(bit.band(cmd:GetButtons(), bit.bnot(IN_SPEED)))
		end
	end
end)