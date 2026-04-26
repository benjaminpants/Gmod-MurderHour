include("shared.lua")
include("inventory/cl_inventory.lua")
include("hud.lua")
include("systems/cl_statuseffects.lua")
include("systems/cl_stats.lua")
include("cl_corpses.lua")
include("ui/cl_question.lua")
include("systems/cl_actionbar.lua")

hook.Add("InitPostEntity", "MHDoNetworkHack", function()
	LocalPlayer():ConCommand("murdh_forcenetworkrefresh")
end)

function GM:HUDDrawPickupHistory()
	-- fuck you
end

function GM:OnGamemodeLoaded()
	local weaponButtonPanel = {}
	function weaponButtonPanel:PaintOver(w, h)
		if (not IsValid(self.weapon)) then return end
		self.weapon:DrawWeaponSelection((-w/2)+(5*(w/128)),0,w*2,w*2,255)
	end
	function weaponButtonPanel:SetWeapon(weapon)
		self.weapon = weapon
		self:SetTooltip(weapon:GetPrintName())
	end
	vgui.Register("DWeaponButton", weaponButtonPanel, "DButton")
end