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

function GM:CanSwitchInventory(ply)
	return (ply:Alive() and (not ply.ragdolled))
end

net.Receive("InventorySelect", function(len, ply)
	if (not gamemode.Call("CanSwitchInventory", ply)) then return end
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
		if (inventory:IsFull()) then
			-- dirty dirty stinky hacker. or weird networking error.
			-- either way just set entityToFind to be the most recently added thing in the inventory as a work around
			entityToFind = inventory.contents[#inventory.contents]
		else
			local hands = ply:GetWeapon("weapon_murdh_hands")
			if (not HolsterWeaponIfExists(ply:GetActiveWeapon(), hands)) then return end
			DropHeldAndRemoveIfAppropiate(ply, ply:GetActiveWeapon())
			ply:SelectWeapon(hands)
			return
		end
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