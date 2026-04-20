util.AddNetworkString("InventorySelect")

local function DropHeldAndRemoveIfAppropiate(ply, wep)
	if (not wep.GoesInInventory) then return end
	ply:DropWeapon(wep)
	if (not wep.Pocketable) then
		ply:RemoveFromInventory(wep)
	else
		wep:MakeInventoryIntangible()
	end
end

net.Receive("InventorySelect", function(len, ply)
	local inventory = ply.inventory
	local entityToFind = NULL
	local isTossing = (not net.ReadBool())
	if (isTossing) then
		entityToFind = ply:GetActiveWeapon()
		if (not entityToFind.GoesInInventory) then return end
		ply:DropWeapon(entityToFind)
		ply:RemoveFromInventory(entityToFind)
		return
	end
	entityToFind = net.ReadEntity()
	-- player selected hands/nothing
	if (not IsValid(entityToFind)) then
		DropHeldAndRemoveIfAppropiate(ply, ply:GetActiveWeapon())
		return
	end
	if (entityToFind == ply:GetActiveWeapon()) then return end
	if (not inventory:Contains(entityToFind)) then return end
	DropHeldAndRemoveIfAppropiate(ply, ply:GetActiveWeapon())
	ply:PickupWeapon(entityToFind)
end)