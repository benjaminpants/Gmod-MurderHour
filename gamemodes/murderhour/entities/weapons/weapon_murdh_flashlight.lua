AddCSLuaFile()
SWEP.Base = "weapon_murdh_toolbase"

SWEP.ViewModel = "models/weapons/c_shotgun.mdl"
SWEP.WorldModel = "models/maxofs2d/lamp_flashlight.mdl"
SWEP.HoldType = "pistol"
SWEP.UseHands = true
SWEP.PrintName = "Flashlight"

SWEP.UsesRenderableSystem = true

SWEP.ViewmodelRender = {
{
Model="models/maxofs2d/lamp_flashlight.mdl", --Model to render.
PosOffset=Vector(0,0,0), --Position offset.
AngOffset=Angle(0,0,0), --Angular offset.
Bone="ValveBiped.Bip01_R_Hand", --Bone the model attaches to.
}}

SWEP.WorldmodelRender= {
{
Model="models/maxofs2d/lamp_flashlight.mdl", --Model to render.
PosOffset=Vector(16,-3,1), --Position offset.
AngOffset=Angle(0,0,0), --Angular offset.
Bone="ValveBiped.Bip01_R_Hand", --Bone the model attaches to.
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
	owner:AllowFlashlight(true)
	owner:Flashlight(false)
	owner:AllowFlashlight(false)
end