AddCSLuaFile()

SWEP.Base = "murdh_toolbase"
SWEP.UsesRenderableSystem = true
SWEP.HideWeaponModel=true
SWEP.Spawnable = false
SWEP.HoldType="slam"

SWEP.HungerRestore=0
SWEP.ThirstRestore=0

--Maybe add like a hook or something when consuming food idk.

--VERY PlACEHOLDER
if SERVER then
function SWEP:PrimaryAttack()
	if (not IsFirstTimePredicted()) then return end
	local Owner=self:GetOwner()
	Owner:SetHunger(math.min(Owner:GetHunger()+self.HungerRestore,100))
	self:OnConsume(Owner)
	self:Remove()
end
end


function SWEP:OnConsume(Owner)
--Something cool.
end