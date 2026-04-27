util.AddNetworkString("InventorySelect")

local function DropHeldAndRemoveIfAppropiate(ply, wep)
	if (not wep.GoesInInventory) then return end
	ply:DropWeaponGently(wep)
	if (not wep.Pocketable) then
		ply:RemoveFromInventory(wep)
	else
		wep:MakeInventoryIntangible()
	end
end

local function HolsterWeaponIfExists(wep, newWep)
	if (not IsValid(wep)) then return true end
	if (wep.Holster == nil) then return true end
	return wep:Holster(newWep)
end

net.Receive("InventorySelect", function(len, ply)
	local inventory = ply.inventory
	local entityToFind = NULL
	local isTossing = (not net.ReadBool())
	if (isTossing) then
		entityToFind = ply:GetActiveWeapon()
		if (not entityToFind.GoesInInventory) then return end
		ply:DropWeaponGently(entityToFind)
		ply:RemoveFromInventory(entityToFind)
		return
	end
	entityToFind = net.ReadEntity()
	-- player selected hands/nothing
	if (not IsValid(entityToFind)) then
		local hands = ply:GetWeapon("murdh_hands")
		if (not HolsterWeaponIfExists(ply:GetActiveWeapon(), hands)) then return end
		DropHeldAndRemoveIfAppropiate(ply, ply:GetActiveWeapon())
		ply:SelectWeapon(hands)
		return
	end
	if (entityToFind == ply:GetActiveWeapon()) then return end
	if (not inventory:Contains(entityToFind)) then return end
	if (not HolsterWeaponIfExists(ply:GetActiveWeapon(), entityToFind)) then return end
	DropHeldAndRemoveIfAppropiate(ply, ply:GetActiveWeapon())
	-- TODO: ACK HACK!
	if (not ply:PickupWeapon(entityToFind)) then
		ply:DropWeapon(entityToFind)
		ply:PickupWeapon(entityToFind)
	end
end)