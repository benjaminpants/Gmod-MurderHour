// TODO: move some of these gamemode functions over to be for the player
// TODO: implement some kind of function for calculating the target heart rate, so it can be modified. (For instance, if holding a weapon, increase the resting heart rate by 10.)

hook.Add("PlayerSpawn", "HeartbeatPlayerSpawn", function(ply)
	// initialize all the appropiate things for heartbeat
	ply.heartBPM = 60
	ply.restingBPM = ply.heartBPM
	ply.heartTimer = 0
	net.Start("PlayerHeartbeat")
		net.WriteFloat(0)
	net.Send(ply)
end)


local heartbeatRestMult = {0}
function GM:CalculateHeartbeatRestMult(ply, baseV)
	heartbeatRestMult[1] = baseV
	self:ModifyHeartbeatRestMult(ply, baseV)
	return heartbeatRestMult[1]
end

function GM:ModifyHeartbeatRestMult(ply, vTab)

end

function GM:HandleHeartbeat(ply)
	if (not ply:Alive()) then return end // you are dead, no big surprise

	// HEART ATTACK TIME
	// TODO: change this to give you the Dying status effect
	if (self:CalculatePracticalHeartBPM(ply) >= (ply.restingBPM * 3)) then
		ply:Kill()
		ply:ChatPrint("You died of a heart attack! (Your BPM was: " .. math.ceil(self:CalculatePracticalHeartBPM(ply)) .. "!)")
		return
	end
	local delta = FrameTime()
	local restMult = 1 // the multiplier for resting, which is how we can go back to our normal heartrate
	if (ply:GetAbsVelocity():Length2DSqr() >= 3) then
		if (ply:IsWalking()) then
			restMult = restMult * 0.8
		else
			restMult = restMult * 0.5
		end
	end

	if (ply:Crouching()) then
		restMult = restMult + 0.1
	end

	// if sprinting, slowly increase bpm
	if (ply:IsSprinting()) then
		if (not ply.wasSprintingLastTime) then
			ply.wasSprintingLastTime = true
			ply.heartBPM = ply.heartBPM + 5
		end
		ply.heartBPM = ply.heartBPM + (delta * 3.5)
		restMult = 0
	else
		ply.wasSprintingLastTime = false
	end
	restMult = self:CalculateHeartbeatRestMult(ply, restMult)
	if (restMult > 0) then
		if (ply.heartBPM > ply.restingBPM) then
			ply.heartBPM = ply.heartBPM - ((delta * 6) * restMult)
			ply.heartBPM = math.max(ply.heartBPM, ply.restingBPM)
		end
		// if our heart rate is below what we expect, raise it.
		// however, with 1 / restMult, the more "rested" we are, the slower our rate will rise
		// so we must exercise!
		if (ply.heartBPM < ply.restingBPM) then
			ply.heartBPM = ply.heartBPM + ((delta * 6) * (1 / restMult))
			ply.heartBPM = math.min(ply.heartBPM, ply.restingBPM)
		end
	end
	local practicalBPM = self:CalculatePracticalHeartBPM(ply)

	if ((practicalBPM > 130) and (not ply:HasStatusEffect("exhausted"))) then
		ply:AddStatusEffect("exhausted")
	end

	ply.heartTimer = ply.heartTimer + ((practicalBPM / 60) * delta)
	if (ply.heartTimer >= 1) then
		ply.heartTimer = 0
		if (practicalBPM > ((ply.restingBPM * 2) - 10)) then
			ply:ViewPunch(Angle(0,((math.random() * 2) - 1) * 0.3,((math.random() * 2) - 1) * 0.3))
		end
		local spurtStrength = ply:GetStatusStrength("bleed_spurt")
		if ((spurtStrength > 0) && (math.random(1,3) ~= 1)) then
			local dmginfo = DamageInfo()
			dmginfo:SetAttacker(ply)
			dmginfo:SetInflictor(ply)
			dmginfo:SetDamageType(DMG_DIRECT)
			dmginfo:SetDamage(spurtStrength * 2)
			//ply.supressDamageSound = true
			ply:EmitSound("physics/flesh/flesh_bloody_impact_hard1.wav", 50)
			ply:TakeDamageInfo(dmginfo)
		end
		//ply:ChatPrint("Heartbeat (" .. ply.heartBPM .. ") " .. math.random(1,100))
		net.Start("PlayerHeartbeat")
		// calculate heartrate difference
		local dif = math.abs(practicalBPM - ply.restingBPM) / ply.restingBPM
		dif = math.pow(dif,3)
		if (ply:HasStatusEffect("exhausted")) then
			dif = dif * 4
		end
		if (ply:IsWalking()) then
			dif = dif + 0.1
		end
		net.WriteFloat(dif)
		net.Send(ply)
		ply:AddThirst(-0.2)
		if (ply:HasStatusEffect("left_leg_broken") or ply:HasStatusEffect("right_leg_broken")) then
			if (ply:IsSprinting()) then
				if (math.random(1,20) == 1) then
					ply:AddOrUpdateStatusEffect("blackout", 3, 1)
				end
			end
		end
		if (ply:Health() < ply:GetMaxHealth()) then
			if (math.random(1,15) == 1) then
				ply:SetHealth(ply:Health() + 1)
				ply:AddHunger(-1)
				ply:AddThirst(-1)
			end
		end
	end
end

function GM:ModifyPracticalHeartBPM(ply, result)
	result[1] = result[1] - (ply:GetStatusStrength("drunk") * 11)
end

// do this to reduce the load on the gc
local heartBPMTable = {0}

function GM:CalculatePracticalHeartBPM(ply)
	heartBPMTable[1] = ply.heartBPM
	self:ModifyPracticalHeartBPM(ply,heartBPMTable)
	return heartBPMTable[1]
end

hook.Add("OnPlayerJump", "HeartBeatOnJump", function(ply, speed)
	if (not SERVER) then return end // server-side check
	ply.heartBPM = ply.heartBPM + (10 * math.pow((speed / 200),2))
end)