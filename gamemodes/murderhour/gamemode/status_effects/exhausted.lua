local heartBPMTable = {0}


local exhaustBPM = nil

local function CalculateMinExhaustEnd(ply)
	heartBPMTable[1] = ply.restingBPM
	gamemode.Call("ModifyPracticalHeartBPMAdditive",ply,heartBPMTable)
	gamemode.Call("ModifyPracticalHeartBPM",ply,heartBPMTable)
	if (exhaustBPM == nil) then
		exhaustBPM = GetConVar("sv_murdh_exhaustionbpm")
	end
	return math.min(math.max(heartBPMTable[1], ply.restingBPM),exhaustBPM:GetInt() - 1)
end


return {
	exhausted = {
		timed=false,
		hidden=false,
		assess_display=false,
		OnAdd = function(ply, effectData)
			ply:SprintDisable()
			ply:EmitSound("player/breathe1.wav", 40)
			ply:ViewPunch(Angle(7,0,0))
			effectData.highest_seen = gamemode.Call("CalculatePracticalHeartBPM", ply)
			effectData.time = 1
		end,
		OnRemove = function(ply, _)
			ply:SprintEnable()
			ply:StopSound("player/breathe1.wav")
		end,
		OnTick = function(ply, effectData)
			local playerBPM = gamemode.Call("CalculatePracticalHeartBPM", ply)
			if (playerBPM > effectData.highest_seen) then
				effectData.highest_seen = playerBPM
			end
			local restingBPM = CalculateMinExhaustEnd(ply)
			effectData.time = math.max(playerBPM - restingBPM, 0) / (effectData.highest_seen - restingBPM)
			if ((playerBPM <= restingBPM)) then
				return ENUM_STATE_RETURN_STOP
			end
			return ENUM_STATE_RETURN_UPDATE
		end
	}
}