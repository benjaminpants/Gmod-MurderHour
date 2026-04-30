util.AddNetworkString("PlayerStats")

local statDrainConvar = GetConVar("sv_murdh_naturalstatdrain")

local playerMeta = FindMetaTable("Player")

function playerMeta:SetHunger(hunger)
	if (hunger == self.hunger) then return end
	self.hunger = hunger
	if (self.hunger <= 0) then
		self.hunger = 0
		self:Kill() -- starved
	end
	self.statsChanged = true
end

function playerMeta:AddHunger(amount)
	if ((not statDrainConvar:GetBool()) and (amount < 0)) then return end
	local toSet = math.max(math.min(self:GetHunger() + amount,100),0)
	self:SetHunger(toSet)
end

function playerMeta:SetThirst(thirst)
	if (thirst == self.thirst) then return end
	self.thirst = thirst
	if (self.thirst <= 0) then
		self.thirst = 0
		self:Kill() -- starved
	end
	self.statsChanged = true
end

function playerMeta:AddThirst(amount)
	if ((not statDrainConvar:GetBool()) and (amount < 0)) then return end
	local toSet = math.max(math.min(self:GetThirst() + amount,100),0)
	self:SetThirst(toSet)
end