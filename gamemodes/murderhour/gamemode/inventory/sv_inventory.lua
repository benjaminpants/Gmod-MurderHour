local inventoryMeta = FindMetaTable("MHInventory")

function inventoryMeta:ShouldNetworkTo(player)
	if (not self.networkToOwnersOnly) then return true end
	for k, v in ipairs(self.owners) do
		if (v == player) then return true end
	end
	return false
end

function inventoryMeta:NetWrite()
	net.WriteUInt(self.limit, 8)
	net.WriteUInt(#self.contents, 8)
	for k, v in ipairs(self.contents) do
		net.WriteEntity(v)
	end
	net.WriteUInt(#self.owners, 8)
	for k, v in ipairs(self.owners) do
		net.WritePlayer(v)
	end
end

function inventoryMeta:Add(entity)
	if (entity:IsInInventory()) then
		error("Attempted to add entity to inventory that was already in inventory!")
		return false
	end
	if (#self.contents >= self.limit) then return false end
	table.insert(self.contents, entity)
	entity:SetNWBool("InInventory", true)
	entity._invOldCGroup = entity:GetCollisionGroup()
	entity:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE) -- might as well not exist!
	entity:CollisionRulesChanged()

	local physOb = entity:GetPhysicsObject()
	if (not IsValid(physOb)) then return true end
	physOb:EnableMotion(false)
	return true
end

function inventoryMeta:Remove(entity)
	if (not entity:IsInInventory()) then
		error("Attempted to remove entity from inventory that isn't in an inventory!")
		return false
	end
	for k, v in ipairs(self.contents) do
		if (v == entity) then
			table.remove(self.contents, k)
			continue
		end
	end
	entity:SetNWBool("InInventory", false)
	entity:SetCollisionGroup(entity._invOldCGroup) -- bring it back
	entity:CollisionRulesChanged()
	local physOb = entity:GetPhysicsObject()
	if (not IsValid(physOb)) then return true end
	physOb:EnableMotion(true)
	physOb:Wake()
	return true
end

local entityMeta = FindMetaTable("Entity")

util.AddNetworkString("NetworkInventory")

function entityMeta:AddInventory(limit, owners, networkToEveryone)
	if (owners == nil) then
		owners = {}
	end
	local inventory = MHInventory(limit)
	inventory.owners = owners
	inventory.networkToOwnersOnly = (not networkToEveryone)
	self.inventory = inventory
	-- TODO: HACK! GET RID OF THIS PROBABLY DOESN'T ACTUALLY FIX THE ISSUE AT ALL
	timer.Simple(0, function()
		self:NetworkInventory()
	end)
end

function entityMeta:NetworkInventory(specificPlayer)
	if (self.inventory == nil) then
		error("Attempted to network entity " .. tostring(self) .. "'s inventory with no inventory!")
		return
	end
	net.Start("NetworkInventory")
	net.WriteEntity(self)
	self.inventory:NetWrite()
	if (specificPlayer ~= nil) then
		net.Send(specificPlayer)
		return
	end
	if (self.inventory.networkToOwnersOnly) then
		net.Send(self.inventory.owners)
	else
		net.Broadcast()
	end
end

function entityMeta:AddToInventory(entity)
	local res = self.inventory:Add(entity)
	self:NetworkInventory()
	return res
end

function entityMeta:RemoveFromInventory(entity)
	local res = self.inventory:Remove(entity)
	self:NetworkInventory()
	return res
end

function entityMeta:InventoryContains(entity)
	return self.inventory:Contains(entity)
end


hook.Add("PlayerDisconnected", "MHPDisconnectCleanup", function(ply)
	if (not ply:HasInventory()) then return end
    for k, v in ipairs(ply.inventory.contents) do
		v:Remove()
	end
end)

include("sv_container.lua")
include("sv_inventoryselect.lua")
include("sv_inventoryplayer.lua")