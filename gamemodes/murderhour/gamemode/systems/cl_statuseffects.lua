local cachedStatus = nil

// thank you gmod i really appreciate it
hook.Add("InitPostEntity", "StatusEffectWorkAround", function()
	LocalPlayer().statuses = cachedStatus
	cachedStatus = nil
end)

net.Receive("PlayerStatusEffectsRefresh", function()
	print("received refresh")
	local ply = LocalPlayer()
	local statuses = {}
	local count = net.ReadInt(32)
	for i=1, count do
		local statusData = {}
		statusData["id"] = net.ReadString()
		statusData["time"] = net.ReadFloat()
		statusData["time_applied"] = net.ReadFloat()
		statusData["strength"] = net.ReadInt(32)
		statusData["uuid"] = net.ReadInt(16)
		table.insert(statuses, statusData)
	end
	if (not IsValid(ply)) then
		cachedStatus = statuses
	else
		ply.statuses = statuses
	end
end)

net.Receive("PlayerAddStatusEffect", function()
	local ply = LocalPlayer()
	local statusData = {}
	statusData["id"] = net.ReadString()
	statusData["time"] = net.ReadFloat()
	statusData["time_applied"] = net.ReadFloat()
	statusData["strength"] = net.ReadInt(32)
	statusData["uuid"] = net.ReadInt(16)
	table.insert(ply.statuses, statusData)
end)

net.Receive("PlayerRemoveStatusEffect", function()
	table.remove(LocalPlayer().statuses, LocalPlayer():GetStatusEffectIndexFromUUID(net.ReadInt(16)))
end)

net.Receive("PlayerUpdateStatusEffect", function()
	local status = LocalPlayer():GetStatusEffectFromUUID(net.ReadInt(16))
	status.time = net.ReadFloat()
	status.time_applied = net.ReadFloat()
	status.strength = net.ReadInt(32)
	// uuid cant/shouldnt be changed so no point in getting it here
end)