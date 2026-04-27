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

local upVector = Vector(0,0,1)

local midVisibleLight = 6
midVisibleLight = midVisibleLight*midVisibleLight

local function IsPlayerHidden(client)
	local lightColorAt = ((render.GetLightColor(client:GetPos()) + render.GetLightColor(client:GetPos() + (upVector * 32)) + render.GetLightColor(client:GetPos() + (upVector * -32)) / 3)) * 1000
	return lightColorAt:Length2DSqr() <= midVisibleLight
end

function HUD()
	local resRefW = ScrW() / 1920
	local resRefH = ScrH() / 1080

	local client = LocalPlayer()
	
	local plColor = client:GetPlayerColor()
	
	plColor = Color(plColor.x * 255,plColor.y * 255, plColor.z * 255)
	
	--local plHue, plSat, plBright = plColor:ToHSL()
	
	--local bgColor = HSLToColor(plHue,0.46,0.21)
	
	bgColor = plColor
	local outlineSize = 6
	local resHeartSize = (heartSize * resRefW)

	// health

	local healthR = client:Health() / client:GetMaxHealth()

	local healthBarPosX = (ScrW() * heartX) - (resHeartSize / 2) - (12 * resRefW)
	local healthBarPosY = (ScrH() * heartY) + (resHeartSize/2) + (16 * resRefH)
	local healthBarHeight = 32 * resRefH
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
	local statusesToDraw = {}
	if (IsPlayerHidden(client)) then
		table.insert(statusesToDraw, {
			id="hidden",
			progress=1,
			strength=1
		})
	end
	for index=1, #client.statuses do
		local currentStatus = client.statuses[index]
		if (GAMEMODE.StatusEffects[currentStatus.id].hidden_client) then
			continue
		end
		local progress = currentStatus.time
		if (GAMEMODE.StatusEffects[currentStatus.id].timed) then
			progress = (currentStatus.time - CurTime()) / (currentStatus.time - currentStatus.time_applied)
		end
		table.insert(statusesToDraw, {
			id=currentStatus.id,
			progress=progress,
			strength=currentStatus.strength
		})
	end
	// now, draw text
	local i = 0
	for index=1, #statusesToDraw do
		local currentStatus = statusesToDraw[index]
		i = i + 1
		local textX = (ScrW() * heartX) - (resHeartSize / 2) - (12 * resRefW)
		local textY = (ScrH() * heartY) - resHeartSize - ((i) * (24 + outlineSize)) - (outlineSize * 2)
		surface.SetDrawColor(0,0,0)
		surface.DrawRect(textX - (outlineSize / 2),textY - (outlineSize / 2), (barWidth) + outlineSize, 24 + outlineSize)
		surface.SetDrawColor(bgColor:Unpack())
		surface.DrawRect(textX,textY, barWidth * currentStatus.progress, 24)
		draw.DrawText("#murderhour.statuses." .. currentStatus.id .. "_" .. currentStatus.strength .. ".title", "PrimaryHudFont",textX, textY)
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

local midDist = 1024

midDist = midDist*midDist // pre-square distance

function GM:HUDDrawTargetID()
	local trace = LocalPlayer():GetEyeTrace()
	if ( !trace.Hit ) then return end
	if ( !trace.HitNonWorld ) then return end

	local text = "ERROR"
	local font = "PrimaryHudFont"

	local traceIsPlayer = false
	if (trace.Entity:IsPlayer()) then
		text = trace.Entity:Nick()
		traceIsPlayer = true
	else
		if (trace.Entity.GetTargetID ~= nil) then
			text = trace.Entity:GetTargetID()
		else
			return
		end
	end

	if (traceIsPlayer) then
		if (trace.Entity:GetPos():DistToSqr(LocalPlayer():GetPos()) >= midDist) then
			text = "???"
		end
		if (IsPlayerHidden(trace.Entity)) then
			return
		end
	end

	surface.SetFont( font )
	local w, h = surface.GetTextSize( text )

	local MouseX, MouseY = input.GetCursorPos()

	if ( MouseX == 0 && MouseY == 0 || !vgui.CursorVisible() ) then

		MouseX = ScrW() / 2
		MouseY = ScrH() / 2

	end

	local x = MouseX
	local y = MouseY

	x = x - w / 2
	y = y + 30

	-- The fonts internal drop shadow looks lousy with AA on
	draw.SimpleText( text, font, x + 1, y + 1, Color( 0, 0, 0, 120 ) )
	draw.SimpleText( text, font, x + 2, y + 2, Color( 0, 0, 0, 50 ) )
	draw.SimpleText( text, font, x, y, whiteColor)

	--[[
	y = y + h + 5

	-- Draw the health
	text = trace.Entity:Health() .. "%"
	font = "TargetIDSmall"

	surface.SetFont( font )
	w, h = surface.GetTextSize( text )
	x = MouseX - w / 2

	draw.SimpleText( text, font, x + 1, y + 1, Color( 0, 0, 0, 120 ) )
	draw.SimpleText( text, font, x + 2, y + 2, Color( 0, 0, 0, 50 ) )
	draw.SimpleText( text, font, x, y, self:GetTeamColor( trace.Entity ) )]]
	return false
end

include("hud_weaponselector.lua")