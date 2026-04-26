local transferBox = nil
local transferOtherGrid = nil
local transferLocalGrid = nil

local function CreateGridForInventory(parent, x,y,s,inv)
	local grid = vgui.Create( "DGrid", parent )
	grid:SetPos(x,y)
	grid:SetCols(5)
	grid:SetColWide(s)
	grid:SetRowHeight(s)
	for i=1, #inv.contents do
		local weapI = vgui.Create("DWeaponButton" , transferBox)
		weapI:SetSize(s,s)
		weapI:SetText("")
		local invWep = inv.contents[i]
		weapI:SetWeapon(invWep)
		grid:AddItem(weapI)
		weapI.DoClick = function()
			net.Start("NetworkContainerTransfer")
			net.WriteBool(true)
			net.WriteEntity(invWep)
			net.SendToServer()
		end
	end
	return grid
end

local function CreateLocalGrid(localinv)
	transferLocalGrid = CreateGridForInventory(transferBox,4,48 + 64 + 24,64, localinv)
end

local function CreateOtherGrid(otherinv)
	transferOtherGrid = CreateGridForInventory(transferBox,4,48,64, otherinv)
end

-- YUCK! YUCK!
local function CreateTransferUI(localinv, otherinv)
	transferBox = vgui.Create("DFrame")
	transferBox:SetPos((ScrW() / 2) - 200, (ScrH() / 2) - 112) 
	transferBox:SetSize(400, 224) 
	transferBox:SetTitle("Transfer") 
	transferBox:SetVisible(true) 
	transferBox:SetDraggable(false)
	transferBox:ShowCloseButton(true)
	transferBox:MakePopup()
	transferBox.OnClose = function()
		net.Start("NetworkContainerTransfer")
		net.WriteBool(false)
		net.SendToServer()
	end
	local lab = vgui.Create("DLabel", transferBox )
	lab:SetPos(4, 24)
	lab:SetSize(100,24)
	lab:SetText("Container")
	CreateOtherGrid(otherinv)
	lab = vgui.Create("DLabel", transferBox )
	lab:SetPos(4, 48 + 64)
	lab:SetSize(100,24)
	lab:SetText("Your Inventory")
	CreateLocalGrid(localinv)
end


net.Receive("NetworkContainerTransfer", function()
	local client = LocalPlayer()
	if (not net.ReadBool()) then
		if (IsValid(client.containerTransfer)) then
			client.containerTransfer.inventory = nil
		end
		client.containerTransfer = nil
		if (transferBox ~= nil) then
			transferBox:Remove()
			transferBox = nil
			transferOtherGrid = nil
			transferLocalGrid = nil
		end
		return
	end
	local ent = net.ReadEntity()
	if (not IsValid(ent)) then
		print("Got invalid ent in NetworkContainerTransfer! What the fuck?")
		return
	end
	if (ent.inventory == nil) then
		ent.inventory = MHInventory()
	end
	ent.inventory:NetReadInto()
	if (client.containerTransfer ~= ent) then
		CreateTransferUI(client.inventory, ent.inventory)
	else
		transferOtherGrid:Remove()
		CreateOtherGrid(ent.inventory)
	end
	client.containerTransfer = ent
end)

hook.Add("LocalPlayerInventoryUpdated", "ContainerUp", function()
	if (transferLocalGrid ~= nil) then
		transferLocalGrid:Remove()
		CreateLocalGrid(LocalPlayer().inventory)
	end
end)