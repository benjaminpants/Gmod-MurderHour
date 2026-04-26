local selectTime = 0
local selectedSlot = 1

local colorWhite = Color(255,255,255)

function HUD()
	if (selectTime == 0) then return end
	local resRefW = ScrW() / 1920
	local resRefH = ScrH() / 1080

	local client = LocalPlayer()
	
	local plColor = client:GetPlayerColor()
	
	plColor = Color(plColor.x * 255,plColor.y * 255, plColor.z * 255)
	
	--local plHue, plSat, plBright = plColor:ToHSL()
	
	--local bgColor = HSLToColor(plHue,0.46,0.21)
	
	bgColor = plColor -- fix the missing color data

	local outlineSize = 6
	local textX = (ScrW() * 0.05) - (12 * resRefW)
	local textY = ScrH() * 0.05

	local inventory = client.inventory
	if (inventory == nil) then return end
	for i=1, inventory.limit + 1 do
		local textToDraw = "Empty"
		if (i == inventory.limit + 1) then
			textToDraw = "Toss"
		end
		local colorToDraw = colorWhite
		if (i <= #inventory.contents) then
			if (IsValid(inventory.contents[i])) then
				textToDraw = inventory.contents[i]:GetPrintName()
			else
				textToDraw = "[ERROR]"
			end
			if (client:GetActiveWeapon() == inventory.contents[i]) then
				local hue, sat, bright = ColorToHSL(plColor)
				hue = hue + 50
				colorToDraw = colorToDraw:Lerp(HSLToColor(hue, sat, bright), 0.7)
			end
		end
		if (selectedSlot == i) then
			colorToDraw = colorToDraw:Lerp(plColor, math.min(selectTime,0.5))
		end
		draw.DrawText(textToDraw, "BiggerPrimaryHudFont",textX, textY + (i * 26), colorToDraw)
	end
	selectTime = math.max(selectTime - FrameTime(),0)
	if (selectTime == 0) then
		selectedSlot = 0
	end
end

local function ChangeSelectedSlot(setTo)
	local inv = LocalPlayer().inventory
	if (inv == nil) then return end
	selectTime = 2
	selectedSlot = setTo
	selectedSlot = math.min(math.max(selectedSlot,1),inv.limit + 1)
end

local function Select()
	selectTime = 0
	net.Start("InventorySelect")
	local inventory = LocalPlayer().inventory
	if (selectedSlot > inventory.limit) then
		net.WriteBool(false)
	else
		net.WriteBool(true)
		net.WriteEntity(inventory.contents[selectedSlot])
	end
	net.SendToServer()
end

local function PlaySelectSound(ply)
	local inventory = LocalPlayer().inventory
	if (inventory == nil) then return end
	if (selectedSlot > inventory.limit) then
		ply:EmitSound("Player.WeaponSelectionMoveSlot")
		return
	end
	if (selectedSlot > #inventory.contents) then
		ply:EmitSound("Player.WeaponSelectionMoveSlot")
		return
	end
	if (not IsValid(inventory.contents[selectedSlot])) then return end
	ply:EmitSound(inventory.contents[selectedSlot]:GetSelectSound(), 75, 100, 0.25)
end

hook.Add("HUDPaint","MurderHourDrawCustomWeaponSelector", HUD)

hook.Add( "PlayerBindPress", "MHWeaponSelectBind", function(ply, bind, pressed)
	if (bind == "invprev") then
		ChangeSelectedSlot(selectedSlot - 1)
		PlaySelectSound(ply)
	end
	if (bind == "invnext") then
		ChangeSelectedSlot(selectedSlot + 1)
		PlaySelectSound(ply)
	end
	if ((bind == "+attack") and (selectTime > 0)) then
		ply:EmitSound("Player.WeaponSelected")
		Select()
		return true
	end
end)