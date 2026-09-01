if (CLIENT) then
	hook.Add("RenderScreenspaceEffects", "MHDrunkEffects", function()
		if (LocalPlayer():GetStatusStrength("drunk") >= 4) then
			DrawMotionBlur(0.02, 0.95, 0.05)
		end
	end)
end

hook.Add("ModifyPracticalHeartBPMAdditive", "MHDrunkModifyBPM", function(ply, result)
	result[1] = result[1] - (ply:GetStatusStrength("drunk") * 11)
end)

hook.Add("SetupMove", "MHDrunkMove", function(ply, mv, cmd)
	if (ply:GetStatusStrength("drunk") > 0) then
		local drunkStrength = ply:GetStatusStrength("drunk")
		local angles = mv:GetMoveAngles()
		local sinPart = math.sin(CurTime() * 1)
		angles.yaw = angles.yaw + (math.sin(CurTime() + math.sin(CurTime()/10)) * (math.pow(drunkStrength,math.min(drunkStrength,3)) + 1))
		mv:SetMoveAngles(angles)
	end
end)

return {
	drunk = {
		timed=true,
		hidden=false,
		assess_display=true,
		OnAdd = function(ply, effectData)
			if (effectData.strength >= 4) then
				effectData.blackout_time = CurTime() + math.random(20,40)
			end
		end,
		OnUpdated = function(ply, effectData)
			if (effectData.strength >= 4) then
				effectData.blackout_time = CurTime() + math.random(20,40)
			end
		end,
		OnTick = function(ply, effectData)
			if (effectData.strength >= 4) then
				if (CurTime() >= effectData.blackout_time) then
					return ENUM_STATE_RETURN_STOP
				end
			end
			return ENUM_STATE_RETURN_CONTINUE
		end,
		OnRemove = function(ply, effectData)
			if (not ply:Alive()) then return end
			if (effectData.strength >= 4) then
				local strength = 2
				if (effectData.strength >= 5) then
					strength = 3
				end
				ply:AddOrUpdateStatusEffect("blackout", math.random(30,60), strength)
			end
		end
	}
}