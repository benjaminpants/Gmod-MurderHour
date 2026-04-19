AddCSLuaFile()

SWEP.Base = "murdh_toolbase"
SWEP.Spawnable = false
SWEP.WorldModel = "models/weapons/w_grenade.mdl"

SWEP.ViewmodelRender = 
{
Model="models/weapons/w_grenade.mdl", --Model to render.
PosOffset=Vector(0,0,0), --Position offset.
AngOffset=Angle(0,0,0), --Angular offset.
Bone="ValveBiped.Bip01_R_Hand", --Bone the model attaches to.
}
SWEP.WorldmodelRender = nil --For any good GMod rig this can just be the same as the viewmodel render if it's attached to the hand.
SWEP.HideWeaponModel=true

--The visual hiding nightmare--
function SWEP:PreDrawViewModel(vm, wep, ply)
	if self.HideWeaponModel == true then
		vm:SetMaterial("engine/occlusionproxy")
	end
end
function SWEP:OnRemove()
	if IsValid(self.Owner) and CLIENT and self.Owner:IsPlayer() then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			vm:SetMaterial("")
		end
	end
end
function SWEP:Holster(wep)
	if IsValid(self.Owner) and CLIENT and self.Owner:IsPlayer() then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			vm:SetMaterial("")
		end
	end
	return true
end

function SWEP.GeneralRenderFunction(host,renderable) --Host is either the viewmodel or the character.
	if (not IsValid(host)) then return end --Host does not exist.
	if (renderable == nil) then return end --Renderable does not exist.
	local offsetvec = renderable.PosOffset
	local offsetang = renderable.AngOffset
	local boneid = host:LookupBone(renderable.Bone)
	if not boneid then
		return
	end
	local matrix = host:GetBoneMatrix( boneid )
	
	if not matrix then 
		return 
	end
	local newpos, newang = LocalToWorld( offsetvec, offsetang, matrix:GetTranslation(), matrix:GetAngles() )
	local modelexample = ClientsideModel(renderable.Model)
	modelexample:SetNoDraw( true )
	modelexample:SetPos( newpos )
	modelexample:SetAngles( newang )
	modelexample:SetupBones()
	modelexample:DrawModel()
	modelexample:Remove()
end

--The rendering nightmare--
function SWEP:ViewModelDrawn(vm)
	self.GeneralRenderFunction(vm,self.ViewmodelRender)
end

function SWEP:DrawWorldModel()
local vm=self:GetOwner()
self.GeneralRenderFunction(vm,self.ViewmodelRender)
self:DrawModel()
end