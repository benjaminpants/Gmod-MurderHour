
net.Receive("PlayerStats", function()
	local hunger = net.ReadFloat()
	LocalPlayer().hunger = hunger
end)