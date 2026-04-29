AddCSLuaFile()
SWEP.Base = "weapon_murdh_toolbase"

SWEP.CanBeLocked = true
SWEP.CanBeLockPicked = true
SWEP.SlotCount = 4
SWEP.CanBeOwned = false
SWEP.InitializeInventoryOnInit = true
SWEP.LockpickSounds = {
	"weapons/357/357_reload1.wav",
	"weapons/357/357_reload3.wav",
	"weapons/357/357_reload4.wav",
}
SWEP.ItemsThatCanFit = {}
SWEP.DenyItemsByDefault = false


DEFINE_BASECLASS(SWEP.Base)
ContainerAddBaseFunctions(SWEP)

function SWEP:ContainerValidTransferTarget(ply)
	if (self:GetLocked()) then
		if (not IsValid(self:GetInvOwner())) then return false end
		if (self:GetInvOwner():InventoryContains(self)) then return true end
		if (self:GetInvOwner() ~= ply) then return false end
	end
	return (ply:GetPos():Distance(self:GetPos()) <= self.UseDistance)
end

function SWEP:ContainerCanFit(item)
	if (self.ItemsThatCanFit[item:GetClass()] == nil) then return not self.DenyItemsByDefault end
	return self.ItemsThatCanFit[item:GetClass()]
end

function SWEP:SetupDataTables()
	--BaseClass.SetupDataTables(self)
	self:NetworkVar("Entity", "InvOwner")
	self:NetworkVar("Bool", "Locked")
end

function SWEP:Initialize()
	BaseClass.Initialize(self)
	self:SetLocked(self.CanBeLocked)
	self.timeUntilNextSound = 0
	if (SERVER) then
		if (self.InitializeInventoryOnInit) then
			self:SetupInventory({})
		end
		self:InitContainer()
	end
	self:SetNextPrimaryFire(CurTime() + 2)
end

function SWEP:CanBeOpenedBy(ply)
	return ((ply == self:GetInvOwner()) or (not self:GetLocked()))
end

function SWEP:AssignInvOwner(ply)
	self:SetInvOwner(ply)
	self:SetupInventory({ply})
	self:SetNextPrimaryFire(CurTime() + 1)
end

function SWEP:SetupInventory(owners)
	if (not self:HasInventory()) then
		self:AddInventory(self.SlotCount, owners, not self.CanBeOwned)
	end
end

function SWEP:CanBePickedUpBy(ply)
	return false
end

function SWEP:PrimaryAttack()
	if (not SERVER) then return end
	if (not self:HasInventory()) then return end
	self:AskQuestion(self:GetOwner())
	self:SetNextPrimaryFire(CurTime() + 1)
end

function SWEP:GenerateQuestionResponses(ply)
	local potentialOptions = {}
	if (not self:IsInInventory()) then
		table.insert(potentialOptions,"pickup")
	end
	if (not self:CanBeOpenedBy(ply)) then
		if (self.CanBeLockPicked and self.CanBeLocked) then
			if (not self:IsInInventory()) then
				table.insert(potentialOptions, "lockpick")
			end
		end
	else
		table.insert(potentialOptions, "open")
		if ((not self:GetLocked()) and self.CanBeLocked) then
			table.insert(potentialOptions, "lock")
		end
		if ((not IsValid(self:GetInvOwner())) and self.CanBeOwned) then
			table.insert(potentialOptions, "claim")
		end
	end
	return potentialOptions
end

function SWEP:AskQuestion(ply)
	local potentialOptions = self:GenerateQuestionResponses(ply)
	local checkFunc = nil
	if (self:IsInInventory()) then
		checkFunc = function(ply)
			return self:IsInInventory()
		end
	else
		checkFunc = function(ply)
			return ply:GetPos():Distance(self:GetPos()) <= self.UseDistance
		end
	end
	ply:SendQuestion("#murderhour.interact", potentialOptions, function(ply, message)
		self:MessageResponse(ply,message)
	end, checkFunc)
end

function SWEP:UseOverride(ply)
	if (ply.currentQuestion ~= nil) then return false end
	if (self:IsPlayerHolding()) then return false end
	if (not self:BeingLookedAtBy(ply)) then return false end
	self:AskQuestion(ply)
	return false
end

function SWEP:MessageResponse(ply, message)
	if (message == "open") then
		self:StartTransferWith(ply)
	elseif (message == "pickup") then
		ply:AddToInventory(self)
	elseif (message == "lockpick") then
		self.timeUntilNextSound = 0
		ply:StartActionBar("#murderhour.action.lockpick", CurTime() + 8, true, function(ply)
			return self:LockpickTick(ply)
		end, function(ply, completed)
			self:LockpickFinished(ply, completed)
		end)
	elseif (message == "lock") then
		self:EmitSound(self.LockpickSounds[math.random(1,#self.LockpickSounds)])
		self:SetLocked(true)
	elseif (message == "claim") then
		self:SetInvOwner(ply)
	end
end

function SWEP:LockpickTick(ply)
	if (not self:BeingLookedAtBy(ply)) then return false end
	self.timeUntilNextSound = self.timeUntilNextSound - FrameTime()
	if (self.timeUntilNextSound <= 0) then
		self.timeUntilNextSound = math.random(1,5) / 3
		self:EmitSound(self.LockpickSounds[math.random(1,#self.LockpickSounds)])
	end
	return true
end

function SWEP:LockpickFinished(ply, completed)
	completed = completed and (math.random(1,3) == 1)
	if (completed) then
		self:SetLocked(false)
		if (IsValid(ply)) then
			ply:ChatPrint("Lockpick succeeded!")
		end
	else
		if (IsValid(ply)) then
			ply:ChatPrint("Lockpick failed!")
		end
	end
end

function SWEP:OnTick()
	self:ContainerTick()
end