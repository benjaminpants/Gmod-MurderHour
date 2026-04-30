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
			ply:EmitSound(boneBreakSounds[math.random(1,#boneBreakSounds)])
		end
	}
}