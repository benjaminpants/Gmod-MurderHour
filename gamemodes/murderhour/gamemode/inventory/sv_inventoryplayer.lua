local playerMeta = FindMetaTable("Player")
local entityMeta = FindMetaTable("Entity")

function playerMeta:DropInvWeapon(wep)
	if (not wep.GoesInInventory) then return end
	self:DropWeapon(wep)
	self:RemoveFromInventory(wep)
end

function playerMeta:DropEntireInventory()
	self:DropInvWeapon(self:GetActiveWeapon())
	for k, v in ipairs(self.inventory.contents) do
		self:DropInvWeapon(v)
	end
end


function playerMeta:PickupWeaponToInv(wep)
	if (not wep.GoesInInventory) then return end
	local activeWep = self:GetActiveWeapon()
	if (IsValid(activeWep)) then
		self:DropWeaponGentlyAndRemoveIfAppropiate(activeWep)
	end
	self:PickupWeapon(wep)
	self:AddToInventory(wep)
end


function playerMeta:AddToInventory(entity)
	local addedSuccessfully = entityMeta.AddToInventory(self, entity)
	if (not addedSuccessfully) then return false end
	if (not entity.Pocketable) then
		self:DropWeaponGentlyAndRemoveIfAppropiate(self:GetActiveWeapon())
		self:PickupWeapon(entity)
	end
	if (self.inventory:IsFull()) then
		-- TODO: evaluate if we should just be checking for hands
		if (self:GetActiveWeapon():GetClass() == "murdh_hands") then
			self:PickupWeapon(entity)
			--self:SelectWeapon(entity)
		end
	end
	return true
end

function playerMeta:RemoveFromInventory(entity)
	local removedSuccessfully = entityMeta.RemoveFromInventory(self, entity)
	if (not removedSuccessfully) then return false end
	if (self:GetActiveWeapon() == entity) then
		self:SelectWeapon("murdh_hands")
	end
	return true
end


function playerMeta:DropWeaponGentlyAndRemoveIfAppropiate(wep)
	if (not wep.GoesInInventory) then return end
	self:DropWeaponGently(wep)
	if (not wep.Pocketable) then
		self:RemoveFromInventory(wep)
	else
		wep:MakeInventoryIntangible()
	end
end

--[[
local oldSelect = playerMeta.SelectWeapon

function playerMeta:SelectWeapon(wep)
	local oldWep = self:GetActiveWeapon()
	oldSelect(self, wep)
	local newWep = self:GetActiveWeapon()
	local oldClass = nil
	local newClass = nil
	if (IsValid(oldWep)) then
		oldClass = oldWep:GetClass()
	end
	if (IsValid()) then
		newClass = newWep:GetClass()
	end
	if ((oldClass == nil) || (newClass == nil)) then return end
	if (oldClass == newClass) then
		hook.Call("PlayerSwitchWeapon", ply, oldWep, newWep)
	end
end]]