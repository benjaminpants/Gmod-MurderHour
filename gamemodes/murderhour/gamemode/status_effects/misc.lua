hook.Add("SetupMove", "MHGettingUpSetupMove", function(ply, mv, cmd)
	if ((ply:HasStatusEffect("getting_up"))) then
		mv:SetButtons(bit.band(bit.bor(mv:GetButtons(), IN_DUCK), bit.bnot(IN_JUMP)))
	end
end)

return {
	getting_up = {
		timed=true,
		hidden=false,
		hidden_client=true,
		assess_display=false
	}
}