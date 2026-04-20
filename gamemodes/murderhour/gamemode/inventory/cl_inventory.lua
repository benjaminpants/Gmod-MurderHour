net.Receive("NetworkInventory", function()
	local ent = net.ReadEntity()
	if (not IsValid(ent)) then
		print("Got invalid ent in NetworkInventory, presumably network weirdness, ignoring...")
		return
	end
	if (ent.inventory == nil) then
		ent.inventory = MHInventory()
	end
	table.Empty(ent.inventory.contents)
	table.Empty(ent.inventory.owners)
	ent.inventory.limit = net.ReadUInt(8)
	local contentCount = net.ReadUInt(8)
	for i=1, contentCount do
		table.insert(ent.inventory.contents, net.ReadEntity())
	end
	local ownerCount = net.ReadUInt(8)
	for i=1, ownerCount do
		table.insert(ent.inventory.owners, net.ReadPlayer())
	end
end)