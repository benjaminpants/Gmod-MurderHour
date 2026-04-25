include("shared.lua")

// this code is horrible

surface.CreateFont("PrimaryHudFont", {
	font = "Roboto",
	size = 24,
	weight = 500
})


surface.CreateFont("BiggerPrimaryHudFont", {
	font = "Roboto",
	size = 36,
	weight = 500
})

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
local heartSize = 125
local heartX = 0.05
local heartY = 0.92

local blackColor = Color(0,0,0)
local whiteColor = Color(255,255,255)

function easeOutBack(x)
	local c1 = 1.70158;
	local c3 = c1 + 1;

	return 1 + c3 * math.pow(x - 1, 3) + c1 * math.pow(x - 1, 2);
end

local iconsToDraw = {
	{
		mat=Material("gui/heartbeat_heart"),
		borderMat=Material("gui/heartbeat_heart_border"),
		getFill=function(client)
			local minHeartValue = 0.8
			if (not client:Alive()) then
				minHeartValue = 0
			end
			// the code for this animation is random bullshit but it looks really good so im not complaining
			return math.max(easeOutBack(heartTimer * heartTimer) - 0.1,minHeartValue)
		end
	},
	{
		mat=Material("gui/healthicon"),
		borderMat=Material("gui/healthicon_border"),
		getFill=function(client)
			return client:Health() / client:GetMaxHealth()
		end
	},
	{
		mat=Material("gui/hungericon"),
		borderMat=Material("gui/hungericon_border"),
		getFill=function(client)
			return client:GetHunger() / 100
		end
	},
	{
		mat=Material("gui/thirsticon"),
		borderMat=Material("gui/thirsticon_border"),
		getFill=function(client)
			return client:GetThirst() / 100
		end
	}
}


local function DrawMurderLikeIcon(mat, borderMat, color, x,y, size, outlineSize, fillPercent)
	surface.SetMaterial(mat)
	surface.SetDrawColor(0,0,0)
	surface.drawCenteredTexturedSquare(x, y, size + outlineSize)
	
	surface.SetDrawColor(color:Unpack())
	if (fillPercent ~= 0) then
		surface.drawCenteredTexturedSquare(x,y, (size * fillPercent))
	end

	surface.SetMaterial(borderMat)
	surface.SetDrawColor(0,0,0)
	surface.drawCenteredTexturedSquare(x,y, size + outlineSize)
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

	local healthBarPosX = (ScrW() * heartX) - (resHeartSize / 2) - (12 * resRefW)
	local healthBarPosY = (ScrH() * heartY) + (resHeartSize/2) + (16 * resRefH)
	local healthBarHeight = 32 * resRefH

	--[[
	surface.SetDrawColor(0,0,0)
	surface.DrawRect(healthBarPosX - (outlineSize / 2),healthBarPosY - (outlineSize / 2),resHeartSize * 3 + outlineSize,healthBarHeight + outlineSize)
	surface.SetDrawColor(bgColor:Unpack())
	surface.DrawRect(healthBarPosX,healthBarPosY,resHeartSize * 3 * healthR,healthBarHeight)
	draw.DrawText(client:Health(), "PrimaryHudFont",healthBarPosX + (resHeartSize * 1.5),healthBarPosY + (8 * resRefH), whiteColor, TEXT_ALIGN_CENTER)
	// hunger bar
	surface.SetDrawColor(0,0,0)
	surface.DrawRect(healthBarPosX - (outlineSize / 2),healthBarPosY - (outlineSize / 2) + (healthBarHeight + outlineSize),resHeartSize * 3 + outlineSize,(healthBarHeight / 2) + outlineSize)
	surface.SetDrawColor(bgColor:Unpack())
	surface.DrawRect(healthBarPosX,healthBarPosY + (healthBarHeight + outlineSize),resHeartSize * 3 * (client:GetHunger() / 100),(healthBarHeight / 2))
	draw.DrawText(math.ceil(client:GetHunger()), "PrimaryHudFont",healthBarPosX + (resHeartSize * 1.5),healthBarPosY + (8 * resRefH) + ((healthBarHeight / 1.5) + outlineSize), whiteColor, TEXT_ALIGN_CENTER)
	
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
	surface.drawCenteredTexturedSquare(ScrW() * heartX, ScrH() * heartY, resHeartSize + outlineSize)]]

	DrawMurderLikeIcon(iconsToDraw[1].mat, iconsToDraw[1].borderMat, bgColor, ScrW() * heartX, ScrH() * heartY, resHeartSize, outlineSize, iconsToDraw[1].getFill(client))

	for i=2, #iconsToDraw do
		local vv = math.rad(132 - ((i - 2) * 32))
		local xx = math.sin(vv) * resHeartSize * 0.9
		local yy = math.cos(vv) * resHeartSize
		DrawMurderLikeIcon(iconsToDraw[i].mat, iconsToDraw[i].borderMat, bgColor, (ScrW() * heartX) + xx, (ScrH() * heartY) + yy, resHeartSize / 2, outlineSize, iconsToDraw[i].getFill(client))
	end

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
		return false
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

include("hud_weaponselector.lua")