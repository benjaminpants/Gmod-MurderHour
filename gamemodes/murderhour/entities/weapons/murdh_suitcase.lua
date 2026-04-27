AddCSLuaFile()
SWEP.Base = "murdh_toolbase"

SWEP.ViewModel = "models/props_c17/SuitCase_Passenger_Physics.mdl"
SWEP.WorldModel = "models/props_c17/SuitCase_Passenger_Physics.mdl"
SWEP.HoldType = "normal"
SWEP.UseHands = false
SWEP.PrintName = "Suitcase"
SWEP.Pocketable = false

SWEP.LockpickSounds = {
	"weapons/357/357_reload1.wav",
	"weapons/357/357_reload3.wav",
	"weapons/357/357_reload4.wav",
}

SWEP.WorldmodelRender = 
{
	Model="models/props_c17/SuitCase_Passenger_Physics.mdl", --Model to render.
	PosOffset=Vector(4.5,-0.5,0), --Position offset.
	AngOffset=Angle(-90,-10,9), --Angular offset.
	Bone="ValveBiped.Bip01_R_Hand", --Bone the model attaches to.
}
SWEP.UsesRenderableSystem = true


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

function SWEP:SetupDataTables()
	--BaseClass.SetupDataTables(self)
	self:NetworkVar("Entity", "InvOwner")
	self:NetworkVar("Bool", "Locked")
end

function SWEP:Initialize()
	BaseClass.Initialize(self)
	self:SetLocked(true)
	self.timeUntilNextSound = 0
	local index = ACT_HL2MP_IDLE_SUITCASE
	self.ActivityTranslate[ ACT_MP_STAND_IDLE ]					= index
	self.ActivityTranslate[ ACT_MP_WALK ]						= index + 1
	self.ActivityTranslate[ ACT_MP_RUN ]						= index + 1
	self.ActivityTranslate[ ACT_MP_ATTACK_STAND_PRIMARYFIRE ]	= index + 5
	self.ActivityTranslate[ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ]	= index + 5
	self.ActivityTranslate[ ACT_MP_RELOAD_STAND ]				= index + 6
	self.ActivityTranslate[ ACT_RANGE_ATTACK1 ]					= index + 8 -- Is this right? Is this for NPCs?
	if (SERVER) then
		self:InitContainer()
	end
	self:SetNextPrimaryFire(CurTime() + 2)
end

function SWEP:CanBeOpenedBy(ply)
	return ((ply == self:GetInvOwner()) or (not self:GetLocked()))
end

local potentialContents = {"murdh_melonslice", "murdh_glock", "murdh_knife", "murdh_water", "murdh_beer", "murdh_mp7", "murdh_silencedpistol"}

function SWEP:OnLoadedViaReplacement()
	self:AddInventory(4, {}, false)
	
	-- PLACEHOLDER PLACEHOLDER
	local entitiesToAdd = {}
	local amount = math.random(1,3)
	for i=1, amount do
		local entity = ents.Create(potentialContents[math.random(1,#potentialContents)])
		entity:SetPos(self:GetPos())
		entity:Spawn()
		table.insert(entitiesToAdd, entity)
	end
	-- TODO: ACK HACK!
	timer.Simple(0, function()
		for k, v in ipairs(entitiesToAdd) do
			self:AddToInventory(v)
		end
	end)
end

function SWEP:AssignInvOwner(ply)
	self:SetInvOwner(ply)
	if (not self:HasInventory()) then
		self:AddInventory(4, {ply}, false)
	end
	self:SetNextPrimaryFire(CurTime() + 1)
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

function SWEP:AskQuestion(ply)
	local potentialOptions = {}
	if (not self:IsInInventory()) then
		table.insert(potentialOptions,"pickup")
	end
	if (not self:CanBeOpenedBy(ply)) then
		if (not self:IsInInventory()) then
			table.insert(potentialOptions, "lockpick")
		end
	else
		table.insert(potentialOptions, "open")
		if (not self:GetLocked()) then
			table.insert(potentialOptions, "lock")
		end
		if (not IsValid(self:GetInvOwner())) then
			table.insert(potentialOptions, "claim")
		end
	end
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

function SWEP:GetTargetID()
	local ply = self:GetInvOwner()
	if (not IsValid(ply)) then
		return "Unowned Suitcase"
	else
		return ply:Nick() .. "'s Suitcase"
	end
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
		-- placeholder behavior
		--[[for i=#self.inventory.contents, 1, -1 do
			self.inventory.contents[i]:SetPos(self:GetPos() + Vector(0,0,10))
			self:RemoveFromInventory(self.inventory.contents[i])
		end]]
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

local matrix = Matrix()

function SWEP:CalcViewModelView(vm, oldEyePos, oldEyeAng, eyePos, eyeAng)
	matrix:SetTranslation(eyePos)
	matrix:SetAngles(eyeAng)
	local offRight = 8
	local offUp = -5
	local offForward = 10
	return eyePos + (matrix:GetRight() * offRight) + (matrix:GetUp() * offUp) + (matrix:GetForward() * offForward), eyeAng
end

hook.Add("StartCommand", "MHSuitcaseStartCommand", function(ply, cmd)
	local activeWep = ply:GetActiveWeapon()
	if (not IsValid(activeWep)) then return end
	if (activeWep:GetClass() == "murdh_suitcase") then
		cmd:SetButtons(bit.band(cmd:GetButtons(), bit.bnot(bit.bor(IN_JUMP, IN_DUCK))))
	end
end)