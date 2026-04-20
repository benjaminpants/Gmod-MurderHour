util.AddNetworkString("CorpseSpawned")

function GM:DoPlayerDeath(ply, attacker, dmg)
	// kill the existing ragdoll instead of making a new one
	ply:RemoveAllStatusEffects()
	ply:SetFakeSpectate(false)
	ply:SilenceVoiceline()
	if (IsValid(ply:GetNWEntity("PlayerCorpse"))) then
		ply:GetNWEntity("PlayerCorpse"):SetNW2Bool("IsDead", true)
		return
	end
	ply:CreateCorpse(true, 1)
	ply:DropEntireInventory()
end

function GM:PlayerDeath(victim, inflictor, attacker)
	self:PlayerSilentDeath(victim, inflictor, attacker)
end

local playerMeta = FindMetaTable("Player")

function playerMeta:CreateRagdoll()
	if (CLIENT) then return nil end
	print("Tried to create Ragdoll! Cancelling...")
end

function playerMeta:ClearCorpse()
	if (IsValid(self:GetNWEntity("PlayerCorpse"))) then
		self:GetNWEntity("PlayerCorpse"):Remove()
		self:SetNWEntity("PlayerCorpse", NULL)
	end
end


function playerMeta:CreateCorpse(dead, velMul)
	self:ClearCorpse()
	local ragdoll = ents.Create("prop_ragdoll")
	ragdoll:SetPos(self:GetPos())
	ragdoll:SetModel(self:GetModel())
	ragdoll:SetAngles(self:GetAngles())
	ragdoll:SetSkin(self:GetSkin())
	ragdoll:Spawn()
	ragdoll:Activate()
	ragdoll:SetNWEntity("Owner", self)
	ragdoll:SetNWVector("PlayerColor", self:GetPlayerColor())
	ragdoll:SetNWBool("IsDead", dead)
	ragdoll:SetNWBool("IsCorpse", true)
	ragdoll:SetNWString("Headwear",self:GetNWString("Headwear"))
	
	/*net.Start("CorpseSpawned")
	net.WriteEntity(ragdoll)
	net.Broadcast()*/

	// position the bones (Thanks TTT!)
    local num = (ragdoll:GetPhysicsObjectCount() - 1)
    local v = self:GetVelocity()

	v:Mul(velMul)

    for i = 0, num do
        local bone = ragdoll:GetPhysicsObjectNum(i)

        if IsValid(bone) then
            local bp, ba = self:GetBonePosition(ragdoll:TranslatePhysBoneToBone(i))

            if bp and ba then
                bone:SetPos(bp)
                bone:SetAngles(ba)
            end
            bone:SetVelocity(v)
        end
    end

	self:SetNWEntity("PlayerCorpse", ragdoll)
	return ragdoll
end

// from https://github.com/Ethorbit/Gmod-Auto-Unstuck/blob/master/lua/autorun/server/AU_AutoUnstuck.lua, unsure of license, may have to replace later.
local function TraceBoundingBox(ply, ignoreme, pos) -- Check if player is blocked using a trace based off player's Bounding Box (Supports all player sizes and models)
    // Maxs and Mins equation that works with all player sizes (ply:GetModelBounds() would not be good enough):
	local duckHullMin, duckHullMax = ply:GetHullDuck()
    local Maxs = Vector(duckHullMin.X / ply:GetModelScale(), duckHullMin.Y / ply:GetModelScale(), duckHullMin.Z / ply:GetModelScale()) 
    local Mins = Vector(duckHullMax.X / ply:GetModelScale(), duckHullMax.Y / ply:GetModelScale(), duckHullMax.Z / ply:GetModelScale())
    local tr = util.TraceHull({    
        start = pos,
        endpos = pos,
        maxs = Maxs, -- Exactly the size the player uses to collide with stuff
        mins = Mins, -- ^
        collisiongroup = COLLISION_GROUP_PLAYER, -- Collides with stuff that players collide with
        mask = MASK_PLAYERSOLID, -- Detects things like map clips
        filter = function(ent) -- Slow but necessary
            if (ent:GetCollisionGroup() != 20 and -- The ent can collide with the player that is stuck
            (ent != ply) and
			(ent != ignoreme)
			) -- The ent is not the player that is stuck
            then return true end -- The ent is not owned by the player that is stuck (AutoUnstuck_If_PersonalEnt ConVar)
        end
    })
    return tr
end

local function TryBonesUntilEscape(corpse, ply)
	local bones = {}
	for i=1, (corpse:GetPhysicsObjectCount() - 1) do
		table.insert(bones, i)
	end
	table.Shuffle(bones)
	table.insert(bones,1,0)
	for i=1, #bones do
		local physObj = corpse:GetPhysicsObject(bones[i])
		local tr = TraceBoundingBox(ply, corpse, physObj:GetPos())
		if (not (tr.Hit)) then
			return physObj
		end
	end
	return nil
end



function playerMeta:Ragdollize(ragdollize)
	if (ragdollize == self.ragdolled) then return end
	self.ragdolled = ragdollize

	if (self.ragdolled) then
		self:SetFakeSpectate(true)
		self:CreateCorpse(false, 1)
		self:DropObject()
		// TODO: insert code to drop actively held weapon if its not pocketable, and if it is, try to pocket it.
		self:DropInvWeapon(self:GetActiveWeapon())
	else
		local physBone = TryBonesUntilEscape(self:GetNWEntity("PlayerCorpse"), self)
		local pos = nil
		local vel = nil
		if (physBone == nil) then
			print("could not find safe spot for player!")
			pos = self:GetNWEntity("PlayerCorpse"):GetPos()
			vel = self:GetNWEntity("PlayerCorpse"):GetVelocity()
		else
			pos = physBone:GetPos()
			vel = physBone:GetVelocity()
		end
		self:SetPos(pos)
		self:SetVelocity(vel)
		self:GetNWEntity("PlayerCorpse"):Remove()
		self:SetFakeSpectate(false)
		// TODO: figure out how to get the player unstuck while snapping them to the floor if its close enough
		self:AddOrUpdateStatusEffect("getting_up", 0.5, 1)
		self:DropToFloor(MASK_PLAYERSOLID, nil, 16)
	end
end



// TODO: make it so this stops the player from doing anything, maybe use FL_Frozen?
function playerMeta:SetFakeSpectate(isSpectate)
	if (isSpectate and (not self:Alive())) then return end
	// "DO NOT use this to make player spectate"
	// I DO WHAT I WANT OLD MAN
	if (isSpectate) then
		self:SetMoveType(MOVETYPE_OBSERVER)
		self:SetRenderMode(RENDERMODE_NONE)
		self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		self:CollisionRulesChanged()
		self:Freeze(true)
	else
		self:SetMoveType(MOVETYPE_WALK)
		self:SetRenderMode(RENDERMODE_NORMAL)
		self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
		self:CollisionRulesChanged()
		self:Freeze(false)
	end
end