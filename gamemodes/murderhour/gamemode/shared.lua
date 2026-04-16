// add all other shared files
if (SERVER) then
	AddCSLuaFile("systems/sh_statuseffects.lua")
	AddCSLuaFile("sh_voicelines.lua")
end

// include all other shared files
include("systems/sh_statuseffects.lua")
include("sh_voicelines.lua")

GM.Name = "Murder Hour"
GM.Author = "N/A"
GM.Email = "N/A"
GM.Website = "N/A"

MurderHour = GM

function GM:Initialize()
	
end