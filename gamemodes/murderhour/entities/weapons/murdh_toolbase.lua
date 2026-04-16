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

SWEP.HullMins = Vector(-10, -10, 10)
SWEP.HullMaxs = Vector(10,10,10)

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
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