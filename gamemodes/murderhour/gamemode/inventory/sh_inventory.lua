if (MHInventory == nil) then
	MHInventory = {}
	MHInventory.__index = MHInventory
	RegisterMetaTable("MHInventory", MHInventory)
end

local entityMeta = FindMetaTable("Entity")

function entityMeta:HasInventory()
	return self.inventory ~= nil
end

function entityMeta:IsInInventory()
	return (self:GetNWBool("InInventory") == true) // nil != true so this makes it return false if its nil
end

function entityMeta:MakeInventoryIntangible()
	self:SetNWBool("InInventory", true)
	self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE) -- might as well not exist!
	self:CollisionRulesChanged()

	local physOb = self:GetPhysicsObject()
	if (not IsValid(physOb)) then return end
	physOb:EnableMotion(false)
end

function MHInventory:new(limit)
	local tab = {
		contents = {}, -- list of Entities or classnames
		owners = {}, -- player list
		networkToOwnersOnly = true,
		limit=math.min(limit or 255,255)
	}
	setmetatable(tab, MHInventory)
	return tab
end

function MHInventory:Contains(entity)
	for k, v in ipairs(self.contents) do
		if (v == entity) then
			return true
		end
	end
	return false
end

function MHInventory:CanFit(entity)
	return (#self.contents) < self.limit
end

function MHInventory:IsFull(entity)
	return (#self.contents) >= self.limit
end

setmetatable(MHInventory, {__call = MHInventory.new})

include("sh_container.lua")