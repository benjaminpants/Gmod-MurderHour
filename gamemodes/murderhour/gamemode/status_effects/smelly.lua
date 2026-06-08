hook.Add("SetupMove", "MHSmellyMove", function(ply, mv, cmd)
	if (ply:HasStatusEffect("smelly")) then
		mv:SetMaxClientSpeed(mv:GetMaxClientSpeed() * 0.8)
	end
end)

return {
	smelly = {
		timed=true,
		hidden=false,
		hidden_client=false,
		assess_display=true
	}
}