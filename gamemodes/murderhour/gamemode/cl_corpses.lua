

function GM:GetCorpsePlayerColor(corpse)
	return corpse:GetNWVector("PlayerColor")
end


local function CheckIfCorpse(ent)
	if (not IsValid(ent)) then return end
	// TODO: fix properly with IsCorpse check
	if (ent:GetClass() == "prop_ragdoll") then
		ent.GetPlayerColor = function()
			return gamemode.Call("GetCorpsePlayerColor", ent)
		end
	end
end

hook.Add("OnEntityCreated", "CorpseOnEntityCreated", function(ent)
	CheckIfCorpse(ent)
end)

net.Receive("CorpseSpawned", function()
	print("got corpse spawned")
	local ent = net.ReadEntity()
	print(ent)
	CheckIfCorpse(ent)
end)

local viewTable = {
	origin=Vector(0,0,0),
	angles=Angle(0,0,0)
}
local axisToRotate = Vector(0,1,0)

hook.Add("CalcView", "MHCorpseRagdollFall", function(ply, origin, angles, fov, znear, zfar)
	local corpse = ply:GetNWEntity("PlayerCorpse")
	if (IsValid(corpse)) then
		local eyeAttach = corpse:GetAttachment(corpse:LookupAttachment("eyes"))
		if (eyeAttach == nil) then
			return
		end
		viewTable.origin = eyeAttach.Pos
		viewTable.angles = eyeAttach.Ang
		--viewTable.angles:RotateAroundAxis(viewTable.angles:Right(),0)
		return viewTable
	end
end)

hook.Add("PreDrawViewModel", "MHCorpseHideViewModel", function(vm, ply, weapon, flags)
	if (IsValid(ply:GetNWEntity("PlayerCorpse"))) then
		return true
	end
end)