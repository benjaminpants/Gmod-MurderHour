local boneBreakSounds = {"npc/barnacle/neck_snap1.wav", "npc/barnacle/neck_snap2.wav"}

hook.Add("SetupMove", "MHBrokenLegsSetupMove", function(ply, mv, cmd)
	local brokenLegValue = 0
	if (ply:HasStatusEffect("left_leg_broken")) then
		brokenLegValue = brokenLegValue + 1
	end
	if (ply:HasStatusEffect("right_leg_broken")) then
		brokenLegValue = brokenLegValue + 1
	end
	if (brokenLegValue >= 1) then
		mv:SetMaxClientSpeed(mv:GetMaxClientSpeed() - math.abs(math.sin(CurTime() * 2) * 40))
	end
	if (brokenLegValue >= 2) then
		mv:SetButtons(bit.band(bit.bor(mv:GetButtons(), IN_DUCK), bit.bnot(IN_JUMP)))
		mv:SetMaxClientSpeed(mv:GetMaxClientSpeed() / 3)
	end
end)

hook.Add("PlayerCanClimbLadder", "MHCanClimbLadderBrokenLegs", function(ply)
	if ((ply:HasStatusEffectAtStrength("left_leg_broken", 2)) and (ply:HasStatusEffectAtStrength("right_leg_broken", 2))) then
		return false
	end
end)

return {
	left_leg_broken = {
		timed=true,
		hidden=false,
		assess_display=true,
		OnAdd = function(ply, _)
			ply:EmitSound(boneBreakSounds[math.random(1,#boneBreakSounds)], 35)
		end
	},
	right_leg_broken = {
		timed=true,
		hidden=false,
		assess_display=true,
		OnAdd = function(ply, _)
			ply:EmitSound(boneBreakSounds[math.random(1,#boneBreakSounds)], 35)
		end
	}
}