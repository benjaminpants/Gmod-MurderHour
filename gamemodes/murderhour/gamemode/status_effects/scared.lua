hook.Add("ModifyPracticalHeartBPMAdditive", "MHScaredModifyBPM", function(ply, result)
	if (ply:GetStatusStrength("scared") > 0) then
		result[1] = result[1] + (math.pow(ply:GetStatusStrength("scared"),2) * 5) + 5
	end
end)

return {
	scared = {
		timed=true,
		hidden=false,
		assess_display=true,
		OnAdd = function(ply, effectData)
		end,
		OnUpdated = function(ply, effectData)
		end,
		OnTick = function(ply, effectData)
			return ENUM_STATE_RETURN_CONTINUE
		end,
		OnRemove = function(ply, effectData)
			if (not ply:Alive()) then return end
			ply.heartBPM = ply.heartBPM + (math.pow(effectData.strength,2) * 5) + 5
		end
	}
}