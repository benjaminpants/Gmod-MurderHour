local outlineSize = 6
local barWidth = 100
local barHeight = 32
local white = Color(255,255,255,255)


local chargeStart = 0
local chargeEnd = 100
local title = ""


net.Receive("ActionBar", function()
	if (not net.ReadBool()) then
		title = ""
		return
	end
	title = net.ReadString()
	chargeStart = net.ReadFloat()
	chargeEnd = net.ReadFloat()
end)

local function DrawActionBar()
	if (title == "") then return end

	local client = LocalPlayer()
	local plColor = client:GetPlayerColor()
	local bgColor = Color(plColor.x * 255,plColor.y * 255, plColor.z * 255)
	barWidth = ScrW() / 2.5
	surface.SetDrawColor(0,0,0)
	surface.DrawRect((ScrW() / 2) - (barWidth / 2), (ScrH() * 0.95) - barHeight, barWidth + outlineSize, barHeight + outlineSize)
	

	local chargeTime = CurTime() - chargeStart
	local barMax = chargeEnd - chargeStart
	local barProgress = math.min((chargeTime / barMax),1)
	surface.SetDrawColor(bgColor:Unpack())
	surface.DrawRect((ScrW() / 2) - (barWidth / 2) + (outlineSize / 2), (ScrH() * 0.95) - barHeight + (outlineSize / 2), barWidth * barProgress, barHeight)

	draw.DrawText(title, "PrimaryHudFont",(ScrW() / 2), (ScrH() * 0.95) - (barHeight - outlineSize), colorWhite, TEXT_ALIGN_CENTER)
end

hook.Add("HUDPaint","MHActionBarDraw", DrawActionBar)