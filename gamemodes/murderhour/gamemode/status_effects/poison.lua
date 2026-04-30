-- effects TODO: vomiting? poison damage over time? cap max health?
return {
	-- level 1 is just "sick", level 2 is "poison", and level 3 is "lethal poison"
	poison = {
		timed=true,
		hidden=false,
		hidden_client=false,
		assess_display=true,
		OnRemove = function(ply, effectData)
			if (not ply:Alive()) then return end
			if (effectData.strength >= 3) then
				ply:AddOrUpdateStatusEffect("blackout", 60, 3)
				return
			end
		end,
	}
}