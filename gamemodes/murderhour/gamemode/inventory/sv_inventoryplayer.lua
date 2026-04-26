local playerMeta = FindMetaTable("Player")

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
	self:AddToInventory(wep)
	self:PickupWeapon(wep)
end