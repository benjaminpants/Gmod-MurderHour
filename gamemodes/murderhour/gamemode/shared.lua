// add all other shared files
if (SERVER) then
	AddCSLuaFile("systems/sh_statuseffects.lua")
	AddCSLuaFile("sh_voicelines.lua")
	AddCSLuaFile("sh_humanoid.lua")
	AddCSLuaFile("systems/sh_stats.lua")
	AddCSLuaFile("inventory/sh_inventory.lua")
end

// include all other shared files
include("systems/sh_statuseffects.lua")
include("systems/sh_stats.lua")
include("inventory/sh_inventory.lua")
include("sh_voicelines.lua")
include("sh_humanoid.lua")

GM.Name = "Murder Hour"
GM.Author = "N/A"
GM.Email = "N/A"
GM.Website = "N/A"

MurderHour = GM


concommand.Add("murdh_forcenetworkrefresh", function(ply, cmd, args)
	if (not SERVER) then return end
	for _, ent in ents.Iterator() do
		if (not ent:HasInventory()) then continue end
		if (ent.inventory:ShouldNetworkTo(ply)) then
			ent:NetworkInventory(ply)
			print("sending networked...")
		end
	end
end, nil, nil, FCVAR_NONE)

function GM:Initialize()
	
end