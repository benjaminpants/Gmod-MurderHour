AddCSLuaFile()
SWEP.Base = "weapon_murdh_containerbase"

SWEP.ViewModel = "models/props_c17/SuitCase_Passenger_Physics.mdl"
SWEP.WorldModel = "models/props_c17/SuitCase_Passenger_Physics.mdl"
SWEP.HoldType = "normal"
SWEP.UseHands = false
SWEP.PrintName = "Suitcase"
SWEP.Pocketable = false
SWEP.CanBeLocked = true
SWEP.CanBeLockPicked = true
SWEP.SlotCount = 4
SWEP.CanBeOwned = true
SWEP.InitializeInventoryOnInit = false

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

function SWEP:Initialize()
	BaseClass.Initialize(self)
	local index = ACT_HL2MP_IDLE_SUITCASE
	self.ActivityTranslate[ ACT_MP_STAND_IDLE ]					= index
	self.ActivityTranslate[ ACT_MP_WALK ]						= index + 1
	self.ActivityTranslate[ ACT_MP_RUN ]						= index + 1
	self.ActivityTranslate[ ACT_MP_ATTACK_STAND_PRIMARYFIRE ]	= index + 5
	self.ActivityTranslate[ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ]	= index + 5
	self.ActivityTranslate[ ACT_MP_RELOAD_STAND ]				= index + 6
	self.ActivityTranslate[ ACT_RANGE_ATTACK1 ]					= index + 8 -- Is this right? Is this for NPCs?
end

local potentialContents = {"weapon_murdh_melonslice", "weapon_murdh_glock", "weapon_murdh_knife", "weapon_murdh_water", "weapon_murdh_beer", "weapon_murdh_mp7", "weapon_murdh_silencedpistol"}

function SWEP:OnLoadedViaReplacement()
	self:SetupInventory({})
	
	-- PLACEHOLDER PLACEHOLDER
	local entitiesToAdd = {}
	local amount = math.random(1,3)
	for i=1, amount do
		local entity = ents.Create(potentialContents[math.random(1,#potentialContents)])
		entity:SetPos(self:GetPos())
		entity:Spawn()
		table.insert(entitiesToAdd, entity)
	end
	for k, v in ipairs(entitiesToAdd) do
		self:AddToInventory(v)
	end
end

function SWEP:GetTargetID()
	local ply = self:GetInvOwner()
	if (not IsValid(ply)) then
		return "Unowned Suitcase"
	else
		return ply:Nick() .. "'s Suitcase"
	end
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

--[[
hook.Add("StartCommand", "MHSuitcaseStartCommand", function(ply, cmd)
	local activeWep = ply:GetActiveWeapon()
	if (not IsValid(activeWep)) then return end
	if (activeWep:GetClass() == "weapon_murdh_suitcase") then
		cmd:SetButtons(bit.band(cmd:GetButtons(), bit.bnot(bit.bor(IN_JUMP, IN_DUCK))))
	end
end)]]