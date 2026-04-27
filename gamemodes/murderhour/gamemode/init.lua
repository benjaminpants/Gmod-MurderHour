// standard stuff
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("systems/cl_statuseffects.lua")
AddCSLuaFile("cl_corpses.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("hud.lua")
AddCSLuaFile("hud_weaponselector.lua")
AddCSLuaFile("systems/cl_stats.lua")
AddCSLuaFile("inventory/cl_inventory.lua")
AddCSLuaFile("ui/cl_question.lua")
AddCSLuaFile("systems/cl_actionbar.lua")

util.AddNetworkString("PlayerHeartbeat")

include("shared.lua")
include("systems/sv_stats.lua")
include("inventory/sv_inventory.lua")
include("sv_voicelines.lua")
include("sv_corpses.lua")
include("sv_entityreplacer.lua")
include("ui/sv_question.lua")
include("systems/sv_actionbar.lua")

local playerMeta = FindMetaTable("Player")

function playerMeta:ForceGive(weaponClassName)
	GAMEMODE.WepBeingForceGived = true
	return self:Give(weaponClassName)
end

local maxDropDist = 80*80

function playerMeta:DropWeaponGently(weapon)
	local eyeTrace = self:GetEyeTrace()
	if (not eyeTrace.Hit) then
		self:DropWeapon(weapon)
		weapon:SetPos(self:EyePos())
		return
	end
	if (eyeTrace.HitPos:DistToSqr(eyeTrace.StartPos) >= maxDropDist) then
		self:DropWeapon(weapon)
		weapon:SetPos(self:EyePos())
		return
	else
		self:DropWeapon(weapon, nil, Vector(0,0,0))
	end
	--weapon:SetPos(eyeTrace.HitPos)
	weapon:SetAngles(Vector(0,1,0):AngleEx(eyeTrace.HitNormal))
	-- after we figure out (roughly) what the player is trying to aim at, get the position by using a hullcast

	local physOb = weapon:GetPhysicsObject()
	if (not IsValid(physOb)) then
		weapon:SetPos(eyeTrace.HitPos)
		return
	end
	
	local hullTrace = {
		start=eyeTrace.HitPos,
		endpos=eyeTrace.HitPos,
		filter=self
	}
	local hullCast = nil
	hullTrace.mins, hullTrace.maxs = physOb:GetAABB()
	-- keep going up until the start of the trace is no longer inside of something
	while (true) do
		hullTrace.start = hullTrace.start + weapon:GetUp()
		hullCast = util.TraceHull(hullTrace)
		if (hullCast.StartSolid) then continue end
		--[[if (not hullCast.Hit) then	-- the fuck?
			weapon:SetPos(eyeTrace.HitPos)
			print("hullcast didn't hit?? defaulting to eyetrace!")
			return
		end
		print(hullCast.HitPos)]]
		break
	end
	weapon:SetPos(hullCast.HitPos + (weapon:GetUp() * 0.25))
	weapon:EmitSound(util.GetSurfaceData(util.GetSurfaceIndex(physOb:GetMaterial())).impactSoftSound)
	physOb:SetAngleVelocity(Vector(0,0,0))
end

// TODO: move heart system to its own lua file, and rewrite the heart calculation stuff to be more modular so status effects like Energized and Drunk can affect it

function GM:PlayerSpawn(ply)
	ply:SetPlayerColor(HSLToColor(math.random(0,360), math.random(90,100) / 100, math.random(20,100) / 100):ToVector())
	
	local peekeys=table.GetKeys(GAMEMODE.PlayerModels)
	local desiredModel=peekeys[math.random(1,#peekeys)]
	local moreData=GAMEMODE.PlayerModels[desiredModel]
	ply:SetModel(desiredModel)
	local desiredApparel=moreData.AllowedBodyTextures[math.random(1,#moreData.AllowedBodyTextures)]
	--ply:SetSubMaterial(moreData.ClothingIndex,GAMEMODE.PlayerApparel[desiredApparel]) --All my efforts wasted.
	ply:SetNWString("Headwear","none")
	
	ply:SetWalkSpeed(100)
	ply:SetSlowWalkSpeed(70)
	ply:SetRunSpeed(200)
	ply.wasSprintingLastTime = false
	ply:StopSound("player/breathe1.wav")
	ply:SprintEnable()
	ply:InitializeStatusEffects()
	ply:SendStatusEffectsRefresh()
	ply:SetupHands()
	ply.ragdolled = false
	ply.supressDamageSound = false
	ply:ClearCorpse()
	ply:ForceGive("murdh_hands")
	ply:SilenceVoiceline()
	ply.hunger = 100
	ply.thirst = 100
	ply:SetHunger(100)
	ply:AddInventory(3, {ply}, false)
	local suitCase = ply:ForceGive("murdh_suitcase")
	suitCase:AssignInvOwner(ply)
end

include("systems/sv_heartbeat.lua")
include("systems/sv_statuseffects.lua")

function GM:HandleStatuses(ply)
	if (not ply:Alive()) then return end
	if (ply.statuses == nil) then return end
	for i, status in ipairs(ply.statuses) do
		local result = self:CallStatusEffectFunction(ply, status, "OnTick")
		if (result == nil) then
			result = ENUM_STATE_RETURN_CONTINUE
		end
		if (GAMEMODE.StatusEffects[status.id].timed) then
			if (CurTime() >= status.time) then
				result = ENUM_STATE_RETURN_STOP
			end
		end
		if (result == ENUM_STATE_RETURN_CONTINUE) then continue end
		if (result == ENUM_STATE_RETURN_UPDATE) then
			ply:UpdateStatusEffect(status.uuid)
			continue
		end
		if (result == ENUM_STATE_RETURN_STOP) then
			ply:RemoveStatusEffect(status.uuid)
			continue
		end
	end
end

function GM:Tick()
	for _, ply in player.Iterator() do
		
		self:HandleStatuses(ply)
		
		// handle ladder climbing
		if (ply:IsSprinting()) then
			ply:SetLadderClimbSpeed(ply:GetRunSpeed())
		else
			if (ply:IsWalking()) then
				ply:SetLadderClimbSpeed(ply:GetSlowWalkSpeed())
			else
				ply:SetLadderClimbSpeed(ply:GetWalkSpeed())
			end
		end
		if (not self:PlayerCanClimbLadder(ply)) then
			ply:SetLadderClimbSpeed(0)
			ply:ExitLadder()
		end
		// dirty hack. remove
		if (ply:HasStatusEffect("exhausted")) then
			ply:SetJumpPower(100)
		else
			ply:SetJumpPower(200)
		end
		self:PlayerPostMainTick(ply)
	end

	for _, v in ipairs(ents.FindByClass("murdh_*" )) do
		if (v.OnTick ~= nil) then
			v:OnTick()
		end
	end
end

// stored here to assist the garbage collector
local playerStatTab = {
	WalkSpeed = 100,
	SlowWalkSpeed = 70,
	RunSpeed = 200,
	CanSprint = true
}

function GM:PlayerCanClimbLadder(ply)
	if ((ply:HasStatusEffectAtStrength("left_leg_broken", 2)) and (ply:HasStatusEffectAtStrength("right_leg_broken", 2))) then
		return false
	end
	return true
end

function GM:PlayerPostMainTick(ply)
	if (ply.ragdolled) then
		ply:SetPos(ply:GetNWEntity("PlayerCorpse"):GetPos())
	end
	self:HandleHeartbeat(ply)
	if (ply:Alive()) then
		ply:AddHunger(-FrameTime() / 8)
	end
	if (ply.statsChanged) then
		net.Start("PlayerStats")
		net.WriteFloat(ply.hunger)
		net.WriteFloat(ply.thirst)
		net.Send(ply)
		ply.statsChanged = false
	end
end

function GM:EntityTakeDamage(entity, info)
	if (entity:GetNWBool("IsCorpse")) then
		// dead bodies shouldnt give pain to their hosts
		if (entity:GetNWBool("IsDead")) then return true end
		if (info:IsDamageType(DMG_CRUSH) and (info:GetInflictor():IsWorld())) then
			info:ScaleDamage(0.1)
		end
		// dont bother if its a small amount of health
		//if (info:GetDamage() <= 5) then return false end
		entity:GetNWEntity("Owner"):TakeDamageInfo(info)
		return true
	end
	if (not entity:IsPlayer()) then return false end
	if (info:IsDamageType(DMG_DROWNRECOVER)) then return true end // no drown recovery
	if (not info:IsDamageType(DMG_DIRECT)) then
		entity.heartBPM = entity.heartBPM + math.max(info:GetDamage() * 3,10)
		entity.heartBPM = math.min(entity.heartBPM, ((entity.restingBPM * 3)) - 30)
	end
	local chanceThreshold = math.max(math.floor(info:GetDamage()*2),20)
	if (info:IsDamageType(DMG_FALL)) then
		// more damage = higher chance of breaking a leg
		if (math.random(1, entity:Health()) <= chanceThreshold) then
			entity:AddOrUpdateStatusEffect("left_leg_broken", info:GetDamage() * 10, 2)
		end
		if (math.random(1, entity:Health()) <= chanceThreshold) then
			entity:AddOrUpdateStatusEffect("right_leg_broken", info:GetDamage() * 10, 2)
		end
		// this causes the ragdoll to take a ton of damage thus massively reducing survival falls
		/*
		if (entity:HasStatusEffect("left_leg_broken") and entity:HasStatusEffect("right_leg_broken")) then
			entity:AddOrUpdateStatusEffect("blackout", 7, 1)
		end*/
	end
	if (info:IsDamageType(DMG_SLASH)) then
		local strengthToGive = 1
		if (info:GetDamage() >= 25) then
			strengthToGive = 2
		end
		entity:AddOrUpdateStatusEffect("bleed_steady", info:GetDamage() * 3, strengthToGive)
	end
	if (info:IsDamageType(DMG_SHOCK)) then
		if (math.random(1, entity:Health()) <= chanceThreshold) then
			entity:AddOrUpdateStatusEffect("blackout", info:GetDamage() / 2, 1)
		end
	end
	if (info:IsDamageType(DMG_CRUSH)) then
		if (math.random(1, entity:Health() * 3) <= chanceThreshold) then
			entity:AddOrUpdateStatusEffect("blackout", math.min(info:GetDamage()*3,75), 2)
		end
	end
	if (not entity.supressDamageSound) then
		if ((info:GetDamage() >= 25) or (entity:Health() <= 25)) then
			self:PlayBigPainForPlayer(entity)
		else
			self:PlaySmallPainForPlayer(entity)
		end
	else
		entity.supressDamageSound = false
	end
	return false
end

function GM:ScalePlayerDamage(ply, hitgroup, info)
	if (hitgroup == HITGROUP_HEAD) then
		info:ScaleDamage(1.4)
		ply:AddOrUpdateStatusEffect("bleed_spurt",11,3)
	end
	local hitLeg = false
	if (hitgroup == HITGROUP_LEFTLEG) then
		local chanceThreshold = math.max(math.floor(info:GetDamage()),5)*2
		if (math.random(1, ply:Health()) <= chanceThreshold) then
			ply:AddOrUpdateStatusEffect("left_leg_broken", info:GetDamage() * 10, 2)
			hitLeg = true
		end
		info:ScaleDamage(0.4)
	end
	if (hitgroup == HITGROUP_RIGHTLEG) then
		local chanceThreshold = math.max(math.floor(info:GetDamage() * 2),5)
		if (math.random(1, ply:Health()) <= chanceThreshold) then
			ply:AddOrUpdateStatusEffect("right_leg_broken", info:GetDamage() * 10, 2)
			hitLeg = true
		end
		info:ScaleDamage(0.4)
	end
	if (hitLeg) then
		if (ply:IsSprinting()) then
			ply:AddOrUpdateStatusEffect("blackout", 2, 1)
		end
	end
end

function GM:AllowPlayerPickup(ply, ent)
	local activeWeapon = ply:GetActiveWeapon()
	if (not IsValid(activeWeapon)) then return true end
	if (ply:GetActiveWeapon():GetClass() ~= "murdh_hands") then return false end
	return not activeWeapon:GetAttackStance()
end

GM.WepBeingForceGived = false
function GM:PlayerCanPickupWeapon(ply, wep)
	if (wep:IsInInventory()) then return false end
	if (ply:HasWeapon(wep:GetClass()) or (not self:AllowPlayerPickup(ply, wep))) then
		GAMEMODE.WepBeingForceGived = false
		return false
	end
	if (GAMEMODE.WepBeingForceGived == true) then
		GAMEMODE.WepBeingForceGived = false
		if (wep.GoesInInventory) then
			local res = ply:AddToInventory(wep)
			if (ply:GetWeapon(wep:GetClass()) == wep) then
				ply:DropWeapon(wep)
				return true
			end
			return res
		end
		return true
	end
	return false
end

function GM:PlayerSwitchWeapon(ply, oldWep, newWep)
	if (oldWep.Pocketable == nil) then return end
	if (not oldWep.GoesInInventory) then return end
	ply:DropWeapon(oldWep)
	if (not oldWep.Pocketable) then
		ply:RemoveFromInventory(oldWep)
	else
		oldWep:MakeInventoryIntangible()
	end
end

function GM:GeneratePlayerInspectOptions(ply, targetPly, optionTable)
	table.insert(optionTable, "assesscondition")
	table.insert(optionTable, "feelpockets")
end

function GM:OnPlayerInspect(ply, inspectee, response)
	if (response == "assesscondition") then
		ply:StartConnectedActionBarWith(inspectee, "#murderhour.action.assesscondition", "#murderhour.action.beingassessed", CurTime() + 3, function() return true end, function(ply, otherPly, completed)
			if (completed) then
				ply:ChatPrint("Assess condition worked")
			end
		end)
	elseif (response == "feelpockets") then
		ply:StartConnectedActionBarWith(inspectee, "#murderhour.action.feelingpockets", "#murderhour.action.beingpocketsfelt", CurTime() + 2, function() return true end, function(ply, otherPly, completed)
			if (completed) then
				local invAmount = #otherPly.inventory.contents
				local otherWep = otherPly:GetActiveWeapon()
				if (IsValid(otherWep)) then
					if (otherWep:GetClass() ~= "murdh_hands") then
						invAmount = invAmount - 1
					end
				end
				ply:ChatPrintLocalized("murderhour.chatprint.feltpockets", {invAmount, otherPly:Nick()})
			end
		end)
	end
end

function GM:PlayerUse(ply, ent)
	if (ent:IsPlayer()) then
		-- for doctors, assesscondition should provide more detail.
		-- TODO: make it so this invalidates based off distance
		local inspectOptions = {}
		gamemode.Call("GeneratePlayerInspectOptions", ply, ent, inspectOptions)
		ply:SendQuestion("#murderhour.interaction", inspectOptions, function(ply, response)
			gamemode.Call("OnPlayerInspect", ply, ent, response)
		end, function(play)
			return play:GetPos():Distance(ent:GetPos()) <= 64
		end)
	end
	if (ent:IsWeapon()) then
		if (ent.CanBePickedUpBy) then
			if (not ent:CanBePickedUpBy(ply)) then
				if (not ent:UseOverride(ply)) then
					return false
				end
				return
			end
		end
		GAMEMODE.WepBeingForceGived = true
	end
end

hook.Add("PlayerDeathSound", "NoPlayerDeathSound", function( ply )
	return true
end)