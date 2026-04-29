AddCSLuaFile()

SWEP.Base = "weapon_murdh_holsterweaponbase"
SWEP.Primary.ChargeTimes = {}
SWEP.Primary.Charges = true
SWEP.Secondary.ChargeTimes = {}
SWEP.Secondary.Charges = false
SWEP.IsHolsterable = true

DEFINE_BASECLASS(SWEP.Base)

function SWEP:SetupDataTables()
	BaseClass.SetupDataTables(self)
	self:NetworkVar("Int", "ChargeLevel")
	self:NetworkVar("Float", "ChargeStart")
end

function SWEP:Initialize()
	BaseClass.Initialize(self)
	self:SetChargeStart(0)
	self.Charging = 0
	self:SetChargeLevel(0)
	if (not self.IsHolsterable) then
		self:SetAttackStance(true)
	end
end

function SWEP:CancelCharge(forceRelease)
	if (forceRelease) then
		local chargeTime = CurTime() - self:GetChargeStart()
		if (self.Charging == 1) then
			self:PrimaryChargeReleased(chargeTime, self:GetChargeLevel())
		else
			self:SecondaryChargeReleased(chargeTime, self:GetChargeLevel())
		end
	end
	self:SetChargeStart(0)
	self.Charging = 0
	self:SetChargeLevel(0)
end

function SWEP:Think()
	if (not self:GetOwner():IsPlayer()) then return end
	if (self:GetChargeStart() > 0) then
		local chargeTime = CurTime() - self:GetChargeStart()
		-- figure out the charge level
		local toCheck = self.Primary
		if (self.Charging == 2) then
			toCheck = self.Secondary
		end
		local chargeLevel = 0
		for i=1, #toCheck.ChargeTimes do
			if (chargeTime < toCheck.ChargeTimes[i]) then
				break
			end
			chargeLevel = i
		end
		if (self:GetChargeLevel() ~= chargeLevel) then
			self:SetChargeLevel(chargeLevel)
			if (self.Charging == 2) then
				self:SecondaryChargeLevelIncreased(chargeLevel)
			else
				self:PrimaryChargeLevelIncreased(chargeLevel)
			end
		end

		if (((self.Charging == 1) and (self:GetOwner():KeyReleased(IN_ATTACK))) or ((self.Charging == 2) and (self:GetOwner():KeyReleased(IN_ATTACK2)))) then
			if (SERVER) then
				SuppressHostEvents(self:GetOwner())
			end
			if (self.Charging == 1) then
				self:PrimaryChargeReleased(chargeTime, chargeLevel)
			else
				self:SecondaryChargeReleased(chargeTime, chargeLevel)
			end
			if (SERVER) then
				SuppressHostEvents(NULL)
			end
			self:SetChargeStart(0)
			self.Charging = 0
			self:SetChargeLevel(0)
		end
	end
end

function SWEP:PrimaryAttack()
	if (not IsFirstTimePredicted()) then return end
	if (not self.Primary.Charges) then return end
	if (!self:GetAttackStance()) then return end
	if (self:GetChargeStart() == 0) then
		self:SetChargeStart(CurTime())
		self.Charging = 1
	end
end

function SWEP:SecondaryAttack()
	if (not IsFirstTimePredicted()) then return end
	if (not self.Secondary.Charges) then return end
	if (!self:GetAttackStance()) then return end
	if (self:GetChargeStart() == 0) then
		self:SetChargeStart(CurTime())
		self.Charging = 2
	end
end

function SWEP:CanBeHolstered()
	if (not self.IsHolsterable) then return false end
	if (self:IsCharging()) then return false end
	return BaseClass.CanBeHolstered(self)
end

function SWEP:PrimaryChargeLevelIncreased(chargeLevel)

end

function SWEP:SecondaryChargeLevelIncreased(chargeLevel)

end

function SWEP:PrimaryChargeReleased(chargeTime, chargeLevel)
	
end

function SWEP:SecondaryChargeReleased(chargeTime, chargeLevel)

end

function SWEP:IsCharging()
	return (self.Charging ~= 0)
end


local outlineSize = 6
local barWidth = 100
local barHeight = 32
local white = Color(255,255,255,255)
function SWEP:DrawHUD()
	if (self:GetChargeStart() == 0) then return end
	local attackType = self.Primary
	if (self.Charging == 2) then
		attackType = self.Secondary
	end
	if (#attackType.ChargeTimes == 0) then return end

	barWidth = ScrW() / 4
	surface.SetDrawColor(0,0,0)
	surface.DrawRect((ScrW() / 2) - (barWidth / 2), (ScrH() * 0.98) - barHeight, barWidth + outlineSize, barHeight + outlineSize)
	

	local chargeTime = CurTime() - self:GetChargeStart()
	local barMax = attackType.ChargeTimes[#attackType.ChargeTimes]
	local barProgress = math.min((chargeTime / barMax),1)

	local chargesCrossed = 0
	for i=1, #attackType.ChargeTimes do
		if (attackType.ChargeTimes[i] < chargeTime) then
			chargesCrossed = chargesCrossed + 1
		end
	end

	-- draw bar and sub bars
	local chargeProgress = math.pow(chargesCrossed / (#attackType.ChargeTimes),1.5)
	surface.SetDrawColor(255,255 - (255 * chargeProgress),255 - (255 * chargeProgress))
	surface.DrawRect((ScrW() / 2) - (barWidth / 2) + (outlineSize / 2), (ScrH() * 0.98) - barHeight + (outlineSize / 2), barWidth * barProgress, barHeight)
	for i=1, (#attackType.ChargeTimes - 1) do
		surface.SetDrawColor(255,0,0,255)
		local showAt = attackType.ChargeTimes[i] / barMax
		if (barProgress >= showAt) then continue end
		surface.DrawRect((ScrW() / 2) - (barWidth / 2) + (outlineSize / 2) + (barWidth * showAt) - 2, (ScrH() * 0.98) - barHeight + (outlineSize / 2), 4, barHeight)
	end
end