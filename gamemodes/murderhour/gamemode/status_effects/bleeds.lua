return {
	bleed_steady = {
		timed=true,
		hidden=false,
		hidden_client=false,
		assess_display=true,
		OnAdd = function(ply, effectData)
			effectData.next_damage = CurTime() + 2
			DoBleedDamage(ply, effectData.strength*effectData.strength)
		end,
		OnTick = function(ply, effectData)
			if (!SERVER) then return end
			if (CurTime() >= effectData.next_damage) then
				effectData.next_damage = CurTime() + 2
				DoBleedDamage(ply, effectData.strength*effectData.strength)
			end
		end
	},
	bleed_spurt = {
		timed=true,
		hidden=false,
		hidden_client=false,
		assess_display=true,
	}
}