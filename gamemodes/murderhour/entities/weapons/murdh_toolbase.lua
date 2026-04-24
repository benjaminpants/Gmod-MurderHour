AddCSLuaFile()

SWEP.Base = "weapon_base"
SWEP.Spawnable = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Pocketable = true
SWEP.HoldType = "normal"
SWEP.SelectSoundOverride = nil

SWEP.HullMins = Vector(-10, -10, 10)
SWEP.HullMaxs = Vector(10,10,10)
SWEP.GoesInInventory = true
SWEP.Breakable = false

--Render options
SWEP.UsesRenderableSystem = false --Should the tool use Bacon's nightmare rendering?
SWEP.ViewmodelRender =  --This is just a template for easier understanding.
{
Model = "models/weapons/w_grenade.mdl", --Model to render.
PosOffset = Vector(0,0,0), --Position offset.
AngOffset = Angle(0,0,0), --Angular offset.
Bone = "ValveBiped.Bip01_R_Hand", --Bone the model attaches to.
}
SWEP.WorldmodelRender = nil --For any good GMod rig this can just be the same as the viewmodel render if it's attached to the hand. --UsesRenderableSystem must be true.
SWEP.HideWeaponModel=false --Can be used without UsesRenderableSystem being true, but why would you do that.

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
	self:AddCallback("PhysicsCollide", self.PhysicsCollide)
	if (self.Breakable) then
		if (SERVER) then
			self:PrecacheGibs()
		end
	end
	if (self.SelectSoundOverride ~= nil) then return end
	local physOb = self:GetPhysicsObject()
	if (not IsValid(physOb)) then return end
	self:SetNWString("WeaponSelect", util.GetSurfaceData(util.GetSurfaceIndex(physOb:GetMaterial())).impactSoftSound)
end

function SWEP:GetSelectSound()
	if (self.SelectSoundOverride ~= nil) then return self.SelectSoundOverride end
	if (self:GetNWString("WeaponSelect") == nil) then return "Player.WeaponSelectionMoveSlot" end
	local sndScript = sound.GetProperties(self:GetNWString("WeaponSelect"))
	if (type(sndScript.sound) == "table") then
		return sndScript.sound[math.random(1, #sndScript.sound)]
	end
	return sndScript.sound
end

function SWEP:PrimaryAttack()

end

function SWEP:SecondaryAttack()

end

function SWEP:PerformImpact(startPos, damageType, trace)
	if (not SERVER) then return end
	if (not trace.Hit) then return end
	local data = EffectData()
	data:SetOrigin(trace.HitPos)
	data:SetStart(startPos)
	data:SetSurfaceProp(trace.SurfaceProps)
	data:SetDamageType(damageType)
	data:SetHitBox(trace.HitBox)
	if (IsValid(trace.Entity)) then
		data:SetEntIndex(trace.Entity:EntIndex())
	else
		data:SetEntIndex(0)
	end
	data:SetNormal(trace.HitNormal)
	util.Effect("Impact", data)
end

function SWEP:Trace(shootPos, endShootPos)
	local ply = self:GetOwner()
	local trace = util.TraceHull({
		start = shootPos,
		endpos = endShootPos,
		filter = ply,
		mask = MASK_SHOT_HULL,
		mins = self.HullMins,
		maxs = self.HullMaxs
	})

	if (!IsValid(trace.Entity)) then
		trace = util.TraceLine({
			start = shootPos,
			endpos = endShootPos,
			filter = ply,
			mask = MASK_SHOT_HULL
		})
	end
	return trace
end

function SWEP:Equip(owner)
	if (owner:IsPlayer()) then
		owner:SelectWeapon(self:GetClass())
	end
end

function SWEP:PhysicsCollide(data, phys)
	if (not self.Breakable) then return end
	if (not SERVER) then return end
	if (data.Speed >= 52) then
		print("broke with: " .. data.Speed)
		local physOb = self:GetPhysicsObject()
		self:EmitSound(util.GetSurfaceData(util.GetSurfaceIndex(physOb:GetMaterial())).breakSound)
		self:GibBreakClient(data.OurOldVelocity)
		self:Remove()
	end
end

--The rendering nightmare--
function SWEP:PreDrawViewModel(vm, wep, ply)
	if self.HideWeaponModel == true then
		vm:SetMaterial("engine/occlusionproxy")
	end
end
function SWEP:OnRemove() --Generally just a good thing to have, rendering enabled or not.
	if IsValid(self.Owner) and CLIENT and self.Owner:IsPlayer() then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			vm:SetMaterial("")
		end
	end
end
function SWEP:Holster(wep) --Same reason as above why this doesn't check UsesRenderableSystem
	if IsValid(self.Owner) and CLIENT and self.Owner:IsPlayer() then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			vm:SetMaterial("")
		end
	end
	return true
end

function SWEP:GeneralRenderFunction(host,renderable, flags) --Host is either the viewmodel or the character.
	if (self.UsesRenderableSystem~=true) then return end
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
function SWEP:ViewModelDrawn(vm, flags)
	if (self.UsesRenderableSystem~=true) then return end
	self:GeneralRenderFunction(vm,self.ViewmodelRender, flags)
end

function SWEP:DrawWorldModel(flags)
	if (not IsValid(self:GetOwner())) or (self.UsesRenderableSystem == false) then --If we're not using the render system, it's prob a bonemergable weapon so render it always.
		self:DrawModel(flags) --So the world model doesn't just vaporize.
	end
	if (self.UsesRenderableSystem==true) and (self.WorldmodelRender~=nil) then
		local vm=self:GetOwner()
		self:GeneralRenderFunction(vm,self.WorldmodelRender, flags)
	end
end