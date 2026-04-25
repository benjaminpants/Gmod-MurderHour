
net.Receive("PlayerStats", function()
	LocalPlayer().hunger = net.ReadFloat()
	LocalPlayer().thirst = net.ReadFloat()
end)