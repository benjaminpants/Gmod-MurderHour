--models/griim/foodpack/plate.mdl

AddCSLuaFile()
SWEP.Base = "weapon_murdh_toolbase"

SWEP.ViewModel = "models/griim/foodpack/plate.mdl"
SWEP.WorldModel = "models/griim/foodpack/plate.mdl"
SWEP.HoldType = "pistol"
SWEP.UseHands = false
SWEP.PrintName = "ServingBase"
SWEP.Pocketable = false
SWEP.WorldmodelRender = {
{
	Model="models/griim/foodpack/plate.mdl", --Model to render.
	PosOffset=Vector(3,0,-3), --Position offset.
	AngOffset=Angle(0,0,-180), --Angular offset.
	Bone="ValveBiped.Bip01_R_Hand", --Bone the model attaches to.
}}
SWEP.UsesRenderableSystem = true
SWEP.UsesRenderableSystemInWorld = false
SWEP.Breakable = true
SWEP.StartingServings = 7
SWEP.WepToGive = "weapon_murdh_beer"
SWEP.TurnIntoAfterEmpty = "weapon_murdh_plate"

DEFINE_BASECLASS(SWEP.Base)

function SWEP:SetupDataTables()
	--BaseClass.SetupDataTables(self)
	self:NetworkVar("Int", "RemainingServings")
end

function SWEP:Initialize()
	BaseClass.Initialize(self)
	self:SetRemainingServings(self.StartingServings)
end

function SWEP:AskQuestion(ply)
	local potentialOptions = {"pickup", "takeserving"}
	local checkFunc = nil
	ply:SendQuestion("#murderhour.interact", potentialOptions, function(ply, message)
		self:MessageResponse(ply,message)
	end, function(ply)
		return ply:GetPos():Distance(self:GetPos()) <= self.UseDistance
	end)
end

function SWEP:MessageResponse(ply, message)
	if (message == "pickup") then
		ply:AddToInventory(self)
	elseif (message == "takeserving") then
		self:TakeServing(ply)
	end
end

function SWEP:TakeServing(ply)
	if (self:GetRemainingServings() <= 0) then return end -- stop potential race condition
	local newThing = ents.Create(self.WepToGive)
	newThing:SetPos(self:GetPos())
	newThing:Spawn()
	-- HAS NETWORKING PROBLEMS
	if (ply:AddToInventory(newThing)) then
		if (self:GetRemainingServings() <= 0) then return end -- stop potential race condition
		self:SetRemainingServings(self:GetRemainingServings() - 1)
		if (self:GetRemainingServings() <= 0) then
			local newObj = ents.Create(self.TurnIntoAfterEmpty)
			newObj:SetPos(self:GetPos())
			newObj:SetAngles(self:GetAngles())
			newObj:Spawn()
			self:Remove()
		end
	else
		newThing:Remove()
	end
end

function SWEP:CanBePickedUpBy(ply)
	return false
end

function SWEP:UseOverride(ply)
	if (ply.currentQuestion ~= nil) then return false end
	if (self:IsPlayerHolding()) then return false end
	self:AskQuestion(ply)
	return false
end

local matrix = Matrix()

function SWEP:CalcViewModelView(vm, oldEyePos, oldEyeAng, eyePos, eyeAng)
	matrix:SetTranslation(eyePos)
	matrix:SetAngles(eyeAng)
	eyeAng:RotateAroundAxis(matrix:GetUp(), 90)
	local offRight = 10
	local offUp = -8
	local offForward = 24
	return eyePos + (matrix:GetRight() * offRight) + (matrix:GetUp() * offUp) + (matrix:GetForward() * offForward), eyeAng
end