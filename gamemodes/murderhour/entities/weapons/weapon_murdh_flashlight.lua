AddCSLuaFile()
SWEP.Base = "weapon_murdh_toolbase"

SWEP.ViewModel = "models/weapons/c_shotgun.mdl"
SWEP.WorldModel = "models/raviool/flashlight.mdl"
SWEP.HoldType = "pistol"
SWEP.UseHands = true
SWEP.PrintName = "Flashlight"

SWEP.UsesRenderableSystem = true

SWEP.ViewmodelRender = {
{
Model="models/raviool/flashlight.mdl", --Model to render.
PosOffset=Vector(0,0,0), --Position offset.
AngOffset=Angle(0,0,0), --Angular offset.
Bone="ValveBiped.Bip01_R_Hand", --Bone the model attaches to.
}}

SWEP.WorldmodelRender= {
{
Model="models/raviool/flashlight.mdl", --Model to render.
PosOffset=Vector(3,-1.5,-1.5), --Position offset.
AngOffset=Angle(0,0,0), --Angular offset.
Bone="ValveBiped.Bip01_R_Hand", --Bone the model attaches to.
DrawShadow=false
}}

DEFINE_BASECLASS(SWEP.Base)

function SWEP:Deploy()
	if (not SERVER) then return end
	self:GetOwner():AllowFlashlight(true)
	self:GetOwner():Flashlight(true)
	self:GetOwner():AllowFlashlight(false)
end

function SWEP:Holster()
	BaseClass.Holster(self)
	if (not SERVER) then return end
	self:GetOwner():AllowFlashlight(true)
	self:GetOwner():Flashlight(false)
	self:GetOwner():AllowFlashlight(false)
	return true
end

function SWEP:OnDrop(owner)
	if (not SERVER) then return end
	if (not IsValid(owner)) then return end
	if (not owner:IsPlayer()) then return end
	owner:AllowFlashlight(true)
	owner:Flashlight(false)
	owner:AllowFlashlight(false)
end