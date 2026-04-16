AddCSLuaFile()
SWEP.Base = "murdh_toolbase"
SWEP.DefaultSwitchCooldown = 1


function SWEP:Initialize()
	self:SetAttackFullyDown(true)
	self:SetSwitchCooldown(CurTime())
	self:SetNextPrimaryFire(CurTime())
	self:GetNextSecondaryFire(CurTime())
end


function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 4, "AttackStance")
	self:NetworkVar("Bool", 5, "AttackFullyDown")
	self:NetworkVar("Float", 6, "SwitchCooldown")
end


function SWEP:Reload()
	self:TryToggleStance()
end

function SWEP:TryToggleStance()
	if (not self:CanBeHolstered()) then return false end
	self:SetSwitchCooldown(CurTime() + self.DefaultSwitchCooldown)
	self:SetAttackStance(not self:GetAttackStance())
	if (not self:GetAttackStance()) then
		self:SetAttackFullyDown(false)
	end
	self:OnStanceChanged()
	return true
end

function SWEP:OnStanceChanged()

end

function SWEP:CanBeHolstered()
	if (CurTime() < self:GetSwitchCooldown()) then return false end
	if (CurTime() < self:GetNextPrimaryFire()) then return false end
	if (CurTime() < self:GetNextSecondaryFire()) then return false end
	return true
end