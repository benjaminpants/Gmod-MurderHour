include("shared.lua")
include("inventory/cl_inventory.lua")
include("hud.lua")
include("systems/cl_statuseffects.lua")
include("systems/cl_stats.lua")
include("cl_corpses.lua")
include("ui/cl_question.lua")
include("systems/cl_actionbar.lua")

hook.Add("InitPostEntity", "MHDoNetworkHack", function()
	LocalPlayer():ConCommand("murdh_forcenetworkrefresh")
end)

function GM:HUDDrawPickupHistory()
	-- fuck you
end