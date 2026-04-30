if (CLIENT) then
	hook.Add("RenderScreenspaceEffects", "MHDrunkEffects", function()
		if (LocalPlayer():GetStatusStrength("drunk") >= 4) then
			DrawMotionBlur(0.02, 0.95, 0.05)
		end
	end)
end

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