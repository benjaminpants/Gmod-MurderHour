ENUM_STATE_RETURN_STOP = 0
ENUM_STATE_RETURN_CONTINUE = 1
ENUM_STATE_RETURN_UPDATE = 2

GM.StatusEffects = {}

local statusFiles = file.Find("murderhour/gamemode/status_effects/*", "LUA")

for _, v in ipairs(statusFiles) do
	print("Adding status effects from " .. v)
	AddCSLuaFile("murderhour/gamemode/status_effects/" .. v)
	local toAdd = include("murderhour/gamemode/status_effects/" .. v)
	for statid, statdata in pairs(toAdd) do
		GM.StatusEffects[statid] = statdata
		print(" Adding: " .. statid)
	end
end

// some functions that should be shared between client and server
local playerMeta = FindMetaTable("Player")

function playerMeta:HasStatusEffect(id)
	if (self.statuses == nil) then return false end
	for _, v in ipairs(self.statuses) do
		if (v.id == id) then return true end
	end
	return false
end

function playerMeta:GetStatusStrength(id)
	if (self.statuses == nil) then return 0 end
	for _, v in ipairs(self.statuses) do
		if (v.id == id) then return v.strength end
	end
	return 0
end

function playerMeta:HasStatusEffectAtStrength(id, strength)
	return self:GetStatusStrength(id) >= strength
end

function playerMeta:HasStatusEffectAtExactStrength(id, strength)
	return self:GetStatusStrength(id) == strength
end

function playerMeta:GetStatusEffectIndexFromUUID(uuid)
	if (self.statuses == nil) then
		return -1
	end
	for i, v in ipairs(self.statuses) do
		if (v.uuid == uuid) then
			return i
		end
	end
	return -1
end

function playerMeta:GetStatusEffectFromUUID(uuid)
	local index = self:GetStatusEffectIndexFromUUID(uuid)
	if (index == -1) then return nil end
	return self.statuses[index]
end

function GM:SetupMove(ply, mv, cmd)
	local brokenLegValue = 0
	if (ply:HasStatusEffect("left_leg_broken")) then
		brokenLegValue = brokenLegValue + 1
	end
	if (ply:HasStatusEffect("right_leg_broken")) then
		brokenLegValue = brokenLegValue + 1
	end
	if (brokenLegValue >= 1) then
		mv:SetMaxClientSpeed(mv:GetMaxClientSpeed() - math.abs(math.sin(CurTime() * 2) * 40))
	end
	if (brokenLegValue >= 2) then
		mv:SetButtons(bit.band(bit.bor(mv:GetButtons(), IN_DUCK), bit.bnot(IN_JUMP)))
		mv:SetMaxClientSpeed(mv:GetMaxClientSpeed() / 3)
	end
	if ((ply:HasStatusEffect("getting_up")) || (ply:HasStatusEffect("blackout"))) then
		mv:SetButtons(bit.band(bit.bor(mv:GetButtons(), IN_DUCK), bit.bnot(IN_JUMP)))
	end
	// drunk logic
	if (ply:GetStatusStrength("drunk") > 0) then
		local drunkStrength = ply:GetStatusStrength("drunk")
		local angles = mv:GetMoveAngles()
		local sinPart = math.sin(CurTime() * 1)
		angles.yaw = angles.yaw + (math.sin(CurTime() + math.sin(CurTime()/10)) * (math.pow(drunkStrength,math.min(drunkStrength,3)) + 1))
		mv:SetMoveAngles(angles)
	end
end

concommand.Add("murdh_debug_givestatuseffect", function(ply, cmd, args)
	if (not SERVER) then return end
	if (#args < 3) then return end
	if (GAMEMODE.StatusEffects[args[1]] == nil) then return end
	ply:AddOrUpdateStatusEffect(args[1], tonumber(args[2]), tonumber(args[3]))
end, function(cmd, argStr, args)
	local autoComplete = table.GetKeys(GAMEMODE.StatusEffects)
	for i=1, #autoComplete do
		autoComplete[i] = "murdh_debug_givestatuseffect " .. autoComplete[i]
	end
	return autoComplete
end, nil, FCVAR_CHEAT)

if (!SERVER) then return end

// i dont know why these hooks dont work
/*hook.Add("HandleHeartbeat", "BleedHandle", function(ply)
	print(ply)
end)*/