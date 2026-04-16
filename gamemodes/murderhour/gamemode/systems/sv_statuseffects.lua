// TODO: create some system to generate and send status effect ids to client so we can just send those instead of the full name

//file.Find("*.lua")

// technically, i could just calculate the order in which the client sees things, but that can very quickly get messy
// so just sending over another int in the network is better
// using a basic incremental id system because its the simplest way to gurantee collisions as basically impossible
local curUUID = -32768
local function GenerateNewUUID()
	curUUID = curUUID + 1
	if (curUUID > 32767) then
		curUUID = -32768
	end
	return curUUID
end

util.AddNetworkString("PlayerStatusEffectsRefresh")
util.AddNetworkString("PlayerAddStatusEffect")
util.AddNetworkString("PlayerRemoveStatusEffect")
util.AddNetworkString("PlayerUpdateStatusEffect")

local playerMeta = FindMetaTable("Player")

function playerMeta:InitializeStatusEffects()
	self.statuses = {}
end

function playerMeta:SendStatusEffectsRefresh()
	--print("sending refresh")
	net.Start("PlayerStatusEffectsRefresh")
	local toNetStatuses = {}
	// i dont remember if ipairs is consistentant in its order or not. will have to check
	for i=1, #self.statuses do
		if (GAMEMODE.StatusEffects[self.statuses[i].id].hidden) then continue end
		table.insert(toNetStatuses, self.statuses[i])
	end
	net.WriteInt(#toNetStatuses, 32)
	for	i=1, #toNetStatuses do
		net.WriteString(toNetStatuses[i].id)
		net.WriteFloat(toNetStatuses[i].time)
		net.WriteFloat(toNetStatuses[i].time_applied)
		net.WriteInt(toNetStatuses[i].strength, 32)
		net.WriteInt(toNetStatuses[i].uuid, 16)
	end
	net.Send(self)
end

function playerMeta:AddStatusEffectManual(data)
	if (not self:Alive()) then return end
	table.insert(self.statuses, data)
	gamemode.Call("CallStatusEffectFunction", self, data, "OnAdd")
	// dont send add for hidden statuses
	if (GAMEMODE.StatusEffects[data.id].hidden) then
		return
	end
	net.Start("PlayerAddStatusEffect")
	net.WriteString(data.id)
	net.WriteFloat(data.time)
	net.WriteFloat(data.time_applied)
	net.WriteInt(data.strength, 32)
	net.WriteInt(data.uuid, 16)
	net.Send(self)
end

function playerMeta:AddStatusEffect(id, time, strength)
	if (not self:Alive()) then return end
	if (time == nil) then
		time = 0
	end
	if (strength == nil) then
		strength = 1
	end
	local data = {}
	data.id = id
	data.time = CurTime() + time
	data.strength = strength
	data.time_applied = CurTime()
	data.uuid = GenerateNewUUID()
	self:AddStatusEffectManual(data)
end

function playerMeta:AddOrUpdateStatusEffect(id, time, strength)
	if (not self:Alive()) then return end
	if (not self:HasStatusEffect(id)) then
		self:AddStatusEffect(id,time,strength)
		return
	end
	if (self.statuses == nil) then return end
	for i, v in ipairs(self.statuses) do
		if (v.id == id) then
			if (time ~= nil) then
				local calculatedCur = CurTime() + time
				if (v.time < calculatedCur) then
					v.time = calculatedCur
					v.time_applied = CurTime()
				end
			end
			if (strength ~= nil) then
				v.strength = strength
			end
			gamemode.Call("CallStatusEffectFunction", self, v, "OnUpdated")
			self:UpdateStatusEffect(v.uuid)
			return
		end
	end
end

function playerMeta:RemoveStatusEffect(uuid)
	gamemode.Call("CallStatusEffectFunction", self, self:GetStatusEffectFromUUID(uuid), "OnRemove")
	local index = self:GetStatusEffectIndexFromUUID(uuid)
	if (index == -1) then return end
	local statusId = self.statuses[index].id
	table.remove(self.statuses, index)
	// dont send remove for hidden statuses
	if (GAMEMODE.StatusEffects[statusId].hidden) then
		return
	end
	net.Start("PlayerRemoveStatusEffect")
	net.WriteInt(uuid, 16)
	net.Send(self)
end

// handle it like this because then we send one message instead of a ton
function playerMeta:RemoveAllStatusEffects()
	local toRemove = {}
	for i=1, #self.statuses do
		table.insert(toRemove, self.statuses[i].uuid)
	end
	for i=1, #toRemove do
		local index = self:GetStatusEffectIndexFromUUID(toRemove[i])
		gamemode.Call("CallStatusEffectFunction", self, self:GetStatusEffectFromUUID(toRemove[i]), "OnRemove")
		table.remove(self.statuses, index)
	end
	self:SendStatusEffectsRefresh()
end

function playerMeta:UpdateStatusEffect(uuid)
	local index = self:GetStatusEffectIndexFromUUID(uuid)
	// dont send updates for hidden statuses
	if (GAMEMODE.StatusEffects[self.statuses[index].id].hidden) then
		return
	end
	net.Start("PlayerUpdateStatusEffect")
	net.WriteInt(uuid, 16)
	net.WriteFloat(self.statuses[index].time)
	net.WriteFloat(self.statuses[index].time_applied)
	net.WriteInt(self.statuses[index].strength, 32)
	// uuid cant be/shouldnt be changed so no point in writing it here
	net.Send(self)
end

function GM:CallStatusEffectFunction(ply, status, function_name)
	if (self.StatusEffects[status.id][function_name] == nil) then return nil end
	return self.StatusEffects[status.id][function_name](ply, status)
end

/*
Applied Status Effect Structure:
id (string) - identifies the status effect
time (float) - the CurTime when the status effect expires assuming timed is true in the data, otherwise, its treated as how close the status effect is to wearing off, in the range of 0 (done) to 1 (just started)
time_applied (float) the CurTime when this effect was applied
strength (int) - Changes the name of the id and can be used by code called by this status effect to change its effects. used for increasing drunkness for wine
uuid (int) - the unique identifier for this specific status effect. used in networking to send messages about it

Other variables can be added to the status effect structure, but only time and strength will be networked.
*/

/*
Status Effect Data Structure:
id (string) - identifies the status effect, probably should be a key into a table
timed (bool) - determines if the client should treat time as a CurTime or as a range
hidden (bool) - determines if the client should be made aware of the status effect or not.
OnAdd(ply, statuseffectData) - when the effect is applied to the specified player, called before its networked so properties can be changed if invalid
OnRemove(ply, statuseffectData) - called right before the status effect is removed from the specified player. used to undo things done in OnApply
Tick(ply, statuseffectData) - called every tick when the status effect is on the player. returns true if the status effect should remain on the player.
*/