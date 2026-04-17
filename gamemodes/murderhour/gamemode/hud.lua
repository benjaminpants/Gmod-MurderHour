include("shared.lua")

surface.CreateFont("PrimaryHudFont", {
	font = "Roboto",
	size = 24,
	weight = 500
})

local heartMat = Material("gui/heartbeat_heart")
local heartBorderMat = Material("gui/heartbeat_heart_border")

function draw.Circle( x, y, radius, seg )
	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 ) -- This is needed for non absolute segment counts
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end

function surface.drawCenteredTexturedSquare(x,y, size)
	surface.DrawTexturedRect(x - (size / 2), y - (size / 2), size, size)
end

local heartTimer = 0
local heartSize = 100
local heartX = 0.05
local heartY = 0.85

local blackColor = Color(0,0,0)
local whiteColor = Color(255,255,255)

function easeOutBack(x)
	local c1 = 1.70158;
	local c3 = c1 + 1;

	return 1 + c3 * math.pow(x - 1, 3) + c1 * math.pow(x - 1, 2);
end

function HUD()
	local resRefW = ScrW() / 1920
	local resRefH = ScrH() / 1080

	local client = LocalPlayer()
	
	local plColor = client:GetPlayerColor()
	
	plColor = Color(plColor.x * 255,plColor.y * 255, plColor.z * 255)
	
	--local plHue, plSat, plBright = plColor:ToHSL()
	
	--local bgColor = HSLToColor(plHue,0.46,0.21)
	
	bgColor = plColor -- fix the missing color data

	local outlineSize = 6

	local resHeartSize = (heartSize * resRefW)

	// health

	local healthR = client:Health() / client:GetMaxHealth()

	surface.SetDrawColor(0,0,0)

	local healthBarPosX = (ScrW() * heartX) - (resHeartSize / 2) - (12 * resRefW)
	local healthBarPosY = (ScrH() * heartY) + (resHeartSize/2) + (16 * resRefH)

	
	surface.DrawRect(healthBarPosX - (outlineSize / 2),healthBarPosY - (outlineSize / 2),resHeartSize * 3 + outlineSize,32 * resRefH + outlineSize)
	surface.SetDrawColor(bgColor:Unpack())
	surface.DrawRect(healthBarPosX,healthBarPosY,resHeartSize * 3 * healthR,32 * resRefH)
	draw.DrawText(client:Health(), "PrimaryHudFont",healthBarPosX + (resHeartSize * 1.5),healthBarPosY + (8 * resRefH), whiteColor, TEXT_ALIGN_CENTER)

	surface.SetMaterial(heartMat)
	surface.SetDrawColor(0,0,0)
	surface.drawCenteredTexturedSquare(ScrW() * heartX, ScrH() * heartY, resHeartSize + outlineSize)
	//draw.Circle(ScrW() * 0.06, ScrH() * 0.9, 100 * resRefW, 32)
	
	surface.SetDrawColor(bgColor:Unpack())
	local minHeartValue = 0.8
	if (not client:Alive()) then
		minHeartValue = 0
	end
	// the code for this animation is random bullshit but it looks really good so im not complaining
	local heartTimerSize = math.max(easeOutBack(heartTimer * heartTimer) - 0.1,minHeartValue)
	if (heartTimerSize ~= 0) then
		surface.drawCenteredTexturedSquare(ScrW() * heartX, ScrH() * heartY, (heartSize * heartTimerSize) * resRefW)
		//draw.Circle(ScrW() * 0.06, ScrH() * 0.9, ((100 * heartTimer) * resRefW) - outlineSize, 32)
	end

	surface.SetMaterial(heartBorderMat)
	surface.SetDrawColor(0,0,0)
	surface.drawCenteredTexturedSquare(ScrW() * heartX, ScrH() * heartY, resHeartSize + outlineSize)

	heartTimer = math.max(heartTimer - FrameTime(),0)

	//draw.RoundedBox(outlineSize,ScrW() * heartX - (resHeartSize / 1.5),(ScrH() * 0.9) - outlineSize,(ScrW() * 0.1) + (outlineSize * 2),ScrH() * 0.07, Color(0,0,0))
	local barWidth = 200
	// now, draw text
	local i = 0
	for index=1, #client.statuses do
		if (GAMEMODE.StatusEffects[client.statuses[index].id].hidden_client) then
			continue
		end
		i = i + 1
		local textX = (ScrW() * heartX) - (resHeartSize / 2) - (12 * resRefW)
		local textY = (ScrH() * heartY) - resHeartSize - ((i - 1) * (24 + outlineSize)) - (outlineSize * 2)
		surface.SetDrawColor(0,0,0)
		surface.DrawRect(textX - (outlineSize / 2),textY - (outlineSize / 2), (barWidth) + outlineSize, 24 + outlineSize)
		surface.SetDrawColor(bgColor:Unpack())
		local progress = client.statuses[index].time
		if (GAMEMODE.StatusEffects[client.statuses[index].id].timed) then
			progress = (client.statuses[index].time - CurTime()) / (client.statuses[index].time - client.statuses[index].time_applied)
		end
		surface.DrawRect(textX,textY, barWidth * progress, 24)
		draw.DrawText("#murderhour.statuses." .. client.statuses[index].id .. "_" .. client.statuses[index].strength .. ".title", "PrimaryHudFont",textX, textY)
	end
end

hook.Add("HUDPaint","MurderHourDrawCustomHud", HUD)

hook.Add("HUDShouldDraw", "MHHideHUD", function( name )
	if (name == "CHudWeaponSelection") then
		--return false
	end
	if (name == "CHudHealth") then
		return false
	end
end)

net.Receive("PlayerHeartbeat", function()
    heartTimer = 1
	local rawDif = net.ReadFloat()
	rawDif = math.min(rawDif,1)
	if (rawDif <= 0.1) then return end -- dont bother
	EmitSound("player/heartbeat_noloop.wav", Vector(0,0,0), -1, CHAN_AUTO, rawDif)
end)