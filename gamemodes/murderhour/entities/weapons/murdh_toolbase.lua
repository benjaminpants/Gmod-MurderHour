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

function SWEP:PrimaryAttack()

end

function SWEP:SecondaryAttack()

end

function SWEP:PerformImpact(startPos, trace)
	local data = EffectData()
	data:SetOrigin(trace.HitPos)
	data:SetStart(startPos)
	data:SetSurfaceProp(trace.SurfaceProps)
	data:SetDamageType(DMG_CLUB)
	data:SetHitBox(trace.HitBox)
	if (IsValid(trace.Entity)) then
		data:SetEntIndex(trace.Entity:EntIndex())
	else
		data:SetEntIndex(0)
	end
	data:SetNormal(trace.HitNormal)
	util.Effect("Impact", data)
end

function SWEP:Equip(owner)
	if (owner:IsPlayer()) then
		owner:SelectWeapon(self:GetClass())
	end
end