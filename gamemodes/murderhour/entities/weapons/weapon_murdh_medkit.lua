AddCSLuaFile()
SWEP.Base = "weapon_murdh_containerbase"

SWEP.ViewModel = "models/muzhik/props/aptechka/aptechka.mdl"
SWEP.WorldModel = "models/muzhik/props/aptechka/aptechka.mdl"
SWEP.HoldType = "normal"
SWEP.UseHands = false
SWEP.PrintName = "Medkit"
SWEP.Pocketable = false
SWEP.CanBeLocked = false
SWEP.CanBeLockPicked = false
SWEP.CanBeOwned = false
SWEP.InitializeInventoryOnInit = true
SWEP.WorldmodelRender = 
{
	Model="models/muzhik/props/aptechka/aptechka.mdl", --Model to render.
	PosOffset=Vector(20,1,-2.5), --Position offset.
	AngOffset=Angle(0,90,-90), --Angular offset.
	Bone="ValveBiped.Bip01_R_Hand", --Bone the model attaches to.
}
SWEP.UsesRenderableSystem = true
SWEP.StartingItems = {"weapon_murdh_bandages", "weapon_murdh_bandages", "weapon_murdh_bandages"}
SWEP.ItemsThatCanFit = {
	weapon_murdh_bandages=true
}
SWEP.DenyItemsByDefault = true

SWEP.SlotCount = #SWEP.StartingItems

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

function SWEP:SetupInventory(owners)
	BaseClass.SetupInventory(self, owners)
	for i=1, #self.StartingItems do
		local entity = ents.Create(self.StartingItems[i])
		entity:SetPos(self:GetPos())
		entity:Spawn()
		self:AddToInventory(entity)
	end
end

local matrix = Matrix()

local upVec = Vector(0,0,1)

function SWEP:CalcViewModelView(vm, oldEyePos, oldEyeAng, eyePos, eyeAng)
	matrix:SetTranslation(eyePos)
	matrix:SetAngles(eyeAng)
	eyeAng:RotateAroundAxis(matrix:GetUp(), 90)
	local offRight = 14
	local offUp = -20
	local offForward = 20
	return eyePos + (matrix:GetRight() * offRight) + (matrix:GetUp() * offUp) + (matrix:GetForward() * offForward), eyeAng
end