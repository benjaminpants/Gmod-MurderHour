--models/props_interiors/pot02a.mdl

AddCSLuaFile()
SWEP.Base = "weapon_murdh_chargeweaponbase"

SWEP.ViewModel = "models/weapons/c_stunstick.mdl"
SWEP.WorldModel = "models/props_interiors/pot02a.mdl"
SWEP.HoldType = "normal"
SWEP.UseHands = true
SWEP.IsHolsterable = true
SWEP.Pocketable = false
SWEP.PrintName = "Pan"

SWEP.Primary.ChargeTimes = {2,5,7}
SWEP.GentleDropAngleOff = 180

SWEP.ViewmodelRender = {
{
Model="models/props_interiors/pot02a.mdl", --Model to render.
PosOffset=Vector(2,-2.5,-7), --Position offset.
AngOffset=Angle(0,90,-90), --Angular offset.
Bone="ValveBiped.Bip01_R_Hand", --Bone the model attaches to.
}}
SWEP.WorldmodelRender = {
{
Model="models/props_interiors/pot02a.mdl", --Model to render.
PosOffset=Vector(4.5,-1,-4), --Position offset.
AngOffset=Angle(0,90,-90), --Angular offset.
Bone="ValveBiped.Bip01_R_Hand", --Bone the model attaches to.
}}
SWEP.UsesRenderableSystem = true
SWEP.HideWeaponModel=true
SWEP.HitSounds = {"phx/epicmetal_hard.wav", "phx/epicmetal_hard1.wav", "phx/epicmetal_hard2.wav", "phx/epicmetal_hard3.wav", "phx/epicmetal_hard4.wav", "phx/epicmetal_hard5.wav", "phx/epicmetal_hard6.wav"}

DEFINE_BASECLASS(SWEP.Base)
ContainerAddBaseFunctions(SWEP)

function SWEP:SetupDataTables()
	BaseClass.SetupDataTables(self)
	self:NetworkVar("String", "CurrentRecipe")
	self:NetworkVar("Float", "RecipeCompletionTime")
	self:NetworkVar("Bool", "NeedsStirring")
	self:NetworkVar("Bool", "RecipeFailed")
end

function SWEP:Deploy()
	self:SetAttackStance(false)
	self:OnStanceChanged()
	self:NetworkInventory(self:GetOwner())
end

function SWEP:Initialize()
	BaseClass.Initialize(self)
	if (SERVER) then
		self:AddInventory(6, {}, true)
		self:InitContainer()
		self:SetCurrentRecipe("")
		self:SetRecipeCompletionTime(0)
		self:SetRecipeFailed(false)
	end
	self.stirTimes = {}
	self.stirMissDelay = 0
	self.simmerSound = nil
end

function SWEP:CanBeHolstered()
	if (self:HasContents()) then return false end
	return BaseClass.CanBeHolstered(self)
end

function SWEP:OnStanceChanged()
	local vm = self:GetOwner():GetViewModel()
	if (self:GetAttackStance()) then
		self:SetHoldType("melee2")
		vm:SendViewModelMatchingSequence(vm:LookupSequence("draw"))
		self:SetNextPrimaryFire(CurTime() + 1)
	else
		if (self:HasContents()) then
			self:SetHoldType("passive")
		else
			self:SetHoldType("normal")
		end
		vm:SendViewModelMatchingSequence(vm:LookupSequence("holster"))
	end
end

function SWEP:PrimaryAttack()
	if (self:GetAttackStance()) then
		return BaseClass.PrimaryAttack(self)
	end
	if (SERVER) then
		local owner = self:GetOwner()
		owner:DropWeaponGentlyAndRemoveIfAppropiate(self)
	end
	self:SetNextPrimaryFire(CurTime() + 1)
end

function SWEP:PrimaryChargeLevelIncreased(chargeLevel)
	if (CLIENT) then
		self:EmitSound(self.HitSounds[math.random(1, #self.HitSounds)], 30, 125 + (25 * chargeLevel), 1)
	end
end

function SWEP:PrimaryChargeReleased(chargeTime, chargeLevel)
	if (chargeLevel == 0) then return end
	local owner = self:GetOwner()
	local vm = owner:GetViewModel()
	self:SetNextPrimaryFire(CurTime() + 0.1)

	owner:LagCompensation(true)

	local shootPos = owner:GetShootPos()
	local endShootPos = shootPos + owner:GetAimVector() * 70

	local trace = self:Trace(shootPos, endShootPos)

	vm:SendViewModelMatchingSequence(vm:SelectWeightedSequence(ACT_VM_PRIMARYATTACK))
	if (trace.Hit) then
		local volToPlay = 40
		if (chargeLevel >= 3) then
			volToPlay = 70
		end
		self:EmitSound(self.HitSounds[math.random(1, #self.HitSounds)], volToPlay)
		if (SERVER) then
			local dmginfo = DamageInfo()
			dmginfo:SetAttacker(owner)
			dmginfo:SetInflictor(self)
			dmginfo:SetWeapon(self)

			local calculateddmg = 8
			if (chargeLevel == 2) then
				calculateddmg = 12
			else
				calculateddmg = 20
			end
			dmginfo:SetDamageType(DMG_CRUSH)

			dmginfo:SetDamage(calculateddmg)
			dmginfo:SetDamagePosition(trace.HitPos)
			SuppressHostEvents(NULL)
			trace.Entity:TakeDamageInfo(dmginfo)
			self:PerformImpact(shootPos, DMG_CRUSH, trace)
			SuppressHostEvents(self:GetOwner())
			if (trace.Entity:IsPlayer()) then
				if (chargeLevel >= 3) then
					trace.Entity:AddOrUpdateStatusEffect("blackout", 45, 2)
				end
			end
		end
		if (trace.Entity:IsPlayer() and (chargeLevel >= 3)) then
			vm:SendViewModelMatchingSequence(vm:SelectWeightedSequence(ACT_VM_MISSCENTER))
		else
			vm:SendViewModelMatchingSequence(vm:SelectWeightedSequence(ACT_VM_HITCENTER))
		end
	else
		vm:SendViewModelMatchingSequence(vm:SelectWeightedSequence(ACT_VM_MISSCENTER))
		self:EmitSound("WeaponFrag.Throw", 40)
	end

	owner:LagCompensation(false)

	owner:SetAnimation(PLAYER_ATTACK1)
end

function SWEP:CanBePickedUpBy(ply)
	return false
end

function SWEP:HasContents()
	if (self:GetCurrentRecipe() ~= "") then return true end
	if (not self:HasInventory()) then return false end
	return #self.inventory.contents > 0
end

function SWEP:AskQuestion(ply)
	local potentialOptions = {}
	if (self:GetRecipeCompletionTime() == 0) then
		table.insert(potentialOptions, "pickup")
	end
	if (self:GetCurrentRecipe() == "") then
		table.insert(potentialOptions, "putin")
		table.insert(potentialOptions, "mix")
	else
		if (self:GetRecipeFailed()) then
			table.insert(potentialOptions, "trash")
		else
			table.insert(potentialOptions, "stir")
		end
	end
	local checkFunc = nil
	ply:SendQuestion("#murderhour.interact", potentialOptions, function(ply, message)
		self:MessageResponse(ply,message)
	end, function(ply)
		return ply:GetPos():Distance(self:GetPos()) <= self.UseDistance
	end)
end

function SWEP:UseOverride(ply)
	if (ply.currentQuestion ~= nil) then return false end
	if (self:IsPlayerHolding()) then return false end
	self:AskQuestion(ply)
	return false
end

function SWEP:MessageResponse(ply, message)
	if (message == "pickup") then
		ply:AddToInventory(self)
	elseif (message == "putin") then
		self:StartTransferWith(ply)
	elseif (message == "mix") then
		self:TryRecipe()
		self:EmitSound("ambient/water/water_splash1.wav", 50, 200)
	elseif (message == "stir") then
		if (self:GetNeedsStirring()) then
			self:EmitSound("ambient/water/water_splash3.wav", 50, 150) -- WHY IS THIS SOUND NOT PLAYING!!!
			table.remove(self.stirTimes, 1)
			self:SetNeedsStirring(false)
		end
	elseif (message == "trash") then
		self:SetCurrentRecipe("")
		self:EmitSound("ambient/water/water_splash3.wav", 50, 75)
		self.stirTimes = {}
		self.stirMissDelay = 0
	end
end

function SWEP:TryRecipe()
	local id, recipe = gamemode.Call("FindMatchingCookingRecipe", self.inventory.contents)
	if (id == nil) then return end
	for k, v in ipairs(self.inventory.contents) do
		v:Remove()
	end
	self.inventory.contents = {}
	self.stirTimes = {}
	self.stirMissDelay = recipe.stirMissDelay
	for i=1, #recipe.stirIntervals do
		table.insert(self.stirTimes, CurTime() + (recipe.stirIntervals[i] + (recipe.stirVariance + ((math.random() - 0.5) * 2))))
	end
	self:SetRecipeCompletionTime(CurTime() + recipe.cookTime)
	self:SetRecipeFailed(false)
	self:SetCurrentRecipe(id)
	self.simmerSound = CreateSound(self, "player/general/flesh_burn.wav")
	self.simmerSound:SetSoundLevel(45)
	self.simmerSound:Play()
end

function SWEP:OnTick()
	self:ContainerTick()
	if (self:GetRecipeFailed()) then return end -- recipe failed, nothing to be done
	if (self:GetCurrentRecipe() == "") then return end -- no need to do anything, no recipe
	if (CurTime() >= self:GetRecipeCompletionTime()) then
		print("recipe complete!")
		print("todo: create food item(s) and put them in pot?")
		self:SetRecipeCompletionTime(0)
		self:SetCurrentRecipe("")
		self:SetNeedsStirring(false)
		self.simmerSound:Stop()
		return
	end
	if (#self.stirTimes <= 0) then return end
	if (CurTime() >= self.stirTimes[1]) then
		if (not self:GetNeedsStirring()) then
			self:SetNeedsStirring(true)
		end
		if (CurTime() >= (self.stirTimes[1] + self.stirMissDelay)) then
			print("failed!")
			self:SetRecipeFailed(true)
			self:SetRecipeCompletionTime(0)
			self:SetNeedsStirring(false)
			self.simmerSound:Stop()
		end
	end
end

function SWEP:ContainerItemTransfered(self,item,from,to)
	self:EmitSound("physics/metal/metal_grenade_impact_soft3.wav", 35)
end

function SWEP:ContainerCanFit(item)
	return item.IsFoodIngredient
end

function SWEP:GetTargetID()
	local recipe = self:GetCurrentRecipe()
	if (recipe == "") then return nil end
	return recipe
end

local colorWhite = Color(255,255,255,255)
local colorRed = Color(255,0,0,255)
-- Draw some 3D text
local function Draw3DText( pos, ang, scale, text, color )

	cam.Start3D2D( pos, ang, scale )
		-- Actually draw the text. Customize this to your liking.
		draw.DrawText( text, "PrimaryHudFont", 0, 0, color, TEXT_ALIGN_CENTER )
	cam.End3D2D()
end

function SWEP:DrawWorldModel(flags)
	-- Draw the model
	BaseClass.DrawWorldModel(self,flags)

	if (self:IsInInventory() and (not IsValid(self:GetOwner()))) then return end -- dont draw if in inventory AND we aren't actively equipped
	if (IsValid(self:GetOwner())) then return end
	if (not self:GetNeedsStirring()) then return end
	local mins, maxs = self:GetModelBounds()
	local pos = self:GetPos() + Vector( 0, 0, maxs.z + 16 )

	local ang = Angle( 0, LocalPlayer():EyeAngles().yaw - 90, 90 ) -- really bad way to do billboarding

	Draw3DText( pos, ang, 0.3, "STIR!", colorRed )
end

hook.Add("StartCommand", "MHPanStartCommand", function(ply, cmd)
	local activeWep = ply:GetActiveWeapon()
	if (not IsValid(activeWep)) then return end
	if (activeWep:GetClass() == "weapon_murdh_pan") then
		if (activeWep:GetChargeLevel() >= 1) then
			cmd:SetButtons(bit.band(cmd:GetButtons(), bit.bnot(IN_SPEED)))
		end
		if (activeWep:HasContents()) then
			cmd:SetButtons(bit.bor(bit.band(cmd:GetButtons(), bit.bnot(bit.bor(IN_SPEED,IN_JUMP))), IN_WALK))
		end
	end
end)