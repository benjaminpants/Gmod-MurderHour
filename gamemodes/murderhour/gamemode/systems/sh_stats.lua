local playerMeta = FindMetaTable("Player")


function playerMeta:GetHunger()
	if (self.hunger == nil) then
		if (SERVER) then
			self:SetHunger(100)
		end
		return 100
	end
	return self.hunger
end