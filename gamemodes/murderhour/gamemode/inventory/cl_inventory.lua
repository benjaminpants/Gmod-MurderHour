local inventoryMeta = FindMetaTable("MHInventory")

function inventoryMeta:NetReadInto()
	table.Empty(self.contents)
	table.Empty(self.owners)
	self.limit = net.ReadUInt(8)
	local contentCount = net.ReadUInt(8)
	for i=1, contentCount do
		table.insert(self.contents, net.ReadEntity())
	end
	local ownerCount = net.ReadUInt(8)
	for i=1, ownerCount do
		table.insert(self.owners, net.ReadPlayer())
	end
end

net.Receive("NetworkInventory", function()
	local ent = net.ReadEntity()
	if (not IsValid(ent)) then
		print("Got invalid ent in NetworkInventory, presumably network weirdness, ignoring...")
		return
	end
	if (ent.inventory == nil) then
		ent.inventory = MHInventory()
	end
	ent.inventory:NetReadInto()
	if (ent == LocalPlayer()) then
		hook.Run("LocalPlayerInventoryUpdated")
	end
end)

include("cl_container.lua")