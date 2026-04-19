// add all other shared files
if (SERVER) then
	AddCSLuaFile("systems/sh_statuseffects.lua")
	AddCSLuaFile("sh_voicelines.lua")
	AddCSLuaFile("sh_humanoid.lua")
	AddCSLuaFile("systems/sh_stats.lua")
end

// include all other shared files
include("systems/sh_statuseffects.lua")
include("systems/sh_stats.lua")
include("sh_voicelines.lua")
include("sh_humanoid.lua")

GM.Name = "Murder Hour"
GM.Author = "N/A"
GM.Email = "N/A"
GM.Website = "N/A"

MurderHour = GM

function GM:Initialize()
	
end