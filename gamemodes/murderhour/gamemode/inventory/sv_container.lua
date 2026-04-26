util.AddNetworkString("NetworkContainerTransfer")

-- override shared definition
function ContainerAddBaseFunctions(tab)
	tab.IsContainer = function(self)
		return true
	end
	tab.ContainerValidTransferTarget = function(self,ply)
		return true
	end
	tab.ContainerSendInvTo = function(self,receivers)
		net.Start("NetworkContainerTransfer")
		net.WriteBool(true)
		net.WriteEntity(self)
		self.inventory:NetWrite() -- write the contents of our inventory
		net.Send(receivers)
	end
	tab.ContainerTick = function(self)
		for i=#self.transferingWith, 1, -1 do
			local ply = self.transferingWith[i]
			if (not (IsValid(ply) and self:ContainerValidTransferTarget(ply))) then
				net.Start("NetworkContainerTransfer")
				net.WriteBool(false)
				net.Send(self.transferingWith[i])
				table.remove(self.transferingWith, i)
				self:ContainerTransferEnded(ply)
			end
		end
	end
	tab.StartTransferWith = function(self,ply)
		if (not (IsValid(ply) and self:ContainerValidTransferTarget(ply))) then return end
		ply.containerTransfer = self
		table.insert(self.transferingWith, ply)
		self:ContainerSendInvTo(ply)
	end
	tab.ContainerTransferEnded = function(self,ply)

	end
	tab.InitContainer = function(self)
		self.transferingWith = {}
	end
end

local entityMeta = FindMetaTable("Entity")

net.Receive("NetworkContainerTransfer", function(len, ply)
	local currentContainer = ply.containerTransfer
	if (not IsValid(currentContainer)) then return end
	if (not (net.ReadBool() and currentContainer:ContainerValidTransferTarget(ply))) then
		ply.containerTransfer = nil
		table.RemoveByValue(currentContainer.transferingWith, ply)
		currentContainer:ContainerTransferEnded(ply)
		net.Start("NetworkContainerTransfer")
		net.WriteBool(false)
		net.Send(ply)
		return
	end
	local targetEnt = net.ReadEntity()
	if (targetEnt == currentContainer) then return end -- DONT PUT CONTAINERS INTO THEMSELVES!
	-- PLACEHOLDER?
	if (targetEnt.IsContainer ~= nil) then
		if (targetEnt:IsContainer()) then return end
	end
	-- if the target is one of our items, the player wants to transfer it to their inventory
	if (currentContainer:InventoryContains(targetEnt)) then
		if (ply.inventory:CanFit(targetEnt)) then
			currentContainer:RemoveFromInventory(targetEnt)
			ply:AddToInventory(targetEnt)
			--[[if (ply.inventory:IsFull() and (ply:GetActiveWeapon():GetClass() == "murdh_hands")) then
				ply:SelectWeapon(targetEnt)
				print("forced select")
			end]]
		end
	elseif (ply:InventoryContains(targetEnt)) then -- if the target is one of their items, they want to deposit it
		if (currentContainer.inventory:CanFit(targetEnt)) then
			ply:DropInvWeapon(targetEnt)
			currentContainer:AddToInventory(targetEnt)
		end
	end
	currentContainer:ContainerSendInvTo(currentContainer.transferingWith)
end)