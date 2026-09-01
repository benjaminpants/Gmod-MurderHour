hook.Add("SetupMove", "MHSmellyMove", function(ply, mv, cmd)
	if (ply:HasStatusEffect("smelly")) then
		mv:SetMaxClientSpeed(mv:GetMaxClientSpeed() * 0.6)
	end
end)

return {
	smelly = {
		timed=true,
		hidden=false,
		hidden_client=false,
		assess_display=true,
		OnAdd = function(ply, effectData)
			effectData.flyTime = CurTime() + math.random(5,100) / 10
		end,
		OnTick = function(ply, effectData)
			if (CurTime() >= effectData.flyTime) then
				ply:EmitSound("ambient/creatures/flies" .. math.random(1,5) .. ".wav")
				effectData.flyTime = CurTime() + math.random(5,100) / 10
				if (effectData.strength <= 1) then return end
				local entsIn = ents.FindInSphere(ply:EyePos(), 256)
				for i, ent in ipairs(entsIn) do
					if (not ent:IsPlayer()) then continue end
					if (ent == ply) then continue end
					local trace = util.TraceLine({
						start = ply:EyePos(),
						endpos = ent:EyePos(),
						filter=ply
					})
					if (trace.Entity == ent) then
						trace.Entity:AddOrUpdateStatusEffect("smelly", math.random(10,15), 1)
					end
				end
			end
		end
	}
}