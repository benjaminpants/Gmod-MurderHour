local playerMeta = FindMetaTable("Player")

CreateConVar("sv_murdh_naturalstatdrain", 1, {FCVAR_REPLICATED, FCVAR_CHEAT, FCVAR_NOTIFY}, "Should stats drain naturally?", 0, 1)

function playerMeta:GetHunger()
	if (self.hunger == nil) then
		if (SERVER) then
			self:SetHunger(100)
		end
		return 100
	end
	return self.hunger
end

function playerMeta:GetThirst()
	if (self.thirst == nil) then
		if (SERVER) then
			self:SetThirst(100)
		end
		return 100
	end
	return self.thirst
end