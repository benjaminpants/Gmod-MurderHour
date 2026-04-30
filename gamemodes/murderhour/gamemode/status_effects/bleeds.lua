local function DoBleedDamage(ply, amount)
	local dmginfo = DamageInfo()
	dmginfo:SetAttacker(ply)
	dmginfo:SetInflictor(ply)
	dmginfo:SetDamageType(DMG_DIRECT)
	dmginfo:SetDamage(amount)
	ply:EmitSound("physics/flesh/flesh_bloody_impact_hard1.wav", 50)
	//ply.supressDamageSound = true
	ply:TakeDamageInfo(dmginfo)
end

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