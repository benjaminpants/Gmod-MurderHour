util.AddNetworkString("PlayerStats")


local playerMeta = FindMetaTable("Player")

function playerMeta:SetHunger(hunger)
	if (hunger == self.hunger) then return end
	self.hunger = hunger
	if (self.hunger <= 0) then
		self.hunger = 0
		self:Kill() -- starved
	end
	net.Start("PlayerStats")
	net.WriteFloat(self.hunger)
	net.Send(self)
end

function playerMeta:AddHunger(amount)
	local toSet = math.max(self:GetHunger() + amount,0)
	self:SetHunger(toSet)
end