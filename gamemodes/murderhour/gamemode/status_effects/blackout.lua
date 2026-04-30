local knockedOutMod = {
	[ "$pp_colour_addr" ] = 0,
	[ "$pp_colour_addg" ] = 0,
	[ "$pp_colour_addb" ] = 0,
	[ "$pp_colour_brightness" ] = 0,
	[ "$pp_colour_contrast" ] = 0.025,
	[ "$pp_colour_colour" ] = 10,
	[ "$pp_colour_mulr" ] = 0,
	[ "$pp_colour_mulg" ] = 0,
	[ "$pp_colour_mulb" ] = 0
}

hook.Add("RenderScreenspaceEffects", "MHKnockoutEffects", function()
	if (LocalPlayer():GetStatusStrength("blackout") > 1) then
		DrawColorModify(knockedOutMod)
	end
end)

return {
	blackout = {
		OnAdd = function(ply, effectData)
			ply:Ragdollize(true)
			-- visually simulate death if we are dying
			if (effectData.strength >= 3) then
				ply:DropEntireInventory()
			end
		end,
		OnRemove = function(ply, effectData)
			if (not ply:Alive()) then return end
			if (effectData.strength >= 3) then
				ply:Kill() // kill the player, bye bye!
				return
			end
			ply:Ragdollize(false)
		end,
		timed=true,
		hidden=false
	}
}