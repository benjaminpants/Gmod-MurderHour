function GM:ReplaceAllEntites()
	local allPhysProps = ents.FindByClass("prop_physics*") -- any and all prop_physics, including prop_physics and prop_physics_override
	print("-- MURDERHOUR ENTITY REPLACER --")
	print("Found " .. #allPhysProps .. " potential replacements!")
	local replaced = 0
	for k, prop in ipairs(allPhysProps) do
		-- TODO: figure out if there is a way to detect entities/props that have outputs in hammer
		-- TODO: investigate potential edict limit problems since Remove doesn't instantly remove an entity
		if (IsValid(prop:GetParent())) then continue end -- do not replace prop_physics that are parented to something, as this could break map logic
		if (#prop:GetChildren() > 0) then continue end -- do not replace prop_physics that have parents as this could break map logic
		if (GAMEMODE.PropsToReplace[prop:GetModel()] ~= nil) then
			replaced = replaced + 1
			local replaceData = GAMEMODE.PropsToReplace[prop:GetModel()]
			local entity = ents.Create(replaceData.entity)
			if (replaceData.useOriginalModel) then
				entity:SetModel(prop:GetModel())
			end
			entity:SetPos(prop:GetPos())
			entity:SetAngles(prop:GetAngles())
			prop:SetCollisionGroup(COLLISION_GROUP_WORLD) -- prevent potential mess ups
			prop:Remove()
			entity:Spawn()

			local physOb = prop:GetPhysicsObject()
			if (physOb:IsAsleep()) then
				entity:GetPhysicsObject():Sleep()
			end
			entity:SetName(prop:GetName())
			entity:OnLoadedViaReplacement()
			prop:SetName("MHDELETING")
		end
	end
	print(replaced .. " entities replaced!")
	print("----")
end

-- Make sure all model paths here are completely lowercase even if Right-Click copy model tells you otherwise
GM.PropsToReplace = {
	["models/props_junk/glassbottle01a.mdl"]={
		entity="murdh_beer",
		useOriginalModel=true
	},
	["models/props_junk/garbage_glassbottle003a.mdl"]={
		entity="murdh_beer",
		useOriginalModel=false --I like the other one better as it's higher poly.
	},
	["models/props_junk/garbage_glassbottle001a.mdl"]={
		entity="murdh_beerlarge",
		useOriginalModel=true
	},
	["models/props_junk/garbage_glassbottle002a.mdl"]={ 
		entity="murdh_beerlarge",
		useOriginalModel=false --I'm just too lazy to adjust the rendering.
	},
	["models/props/cs_italy/orange.mdl"]={
		entity="murdh_orange",
		useOriginalModel=true
	},
	["models/props/cs_office/water_bottle.mdl"]={
		entity="murdh_water",
		useOriginalModel=true
	},
	["models/props_junk/watermelon01.mdl"]={
		entity="murdh_melon",
		useOriginalModel=true
	},
	["models/props_c17/suitcase_passenger_physics.mdl"]={
		entity="murdh_suitcase",
		useOriginalModel=false
	},
	["models/props_c17/suitcase001a.mdl"]={
		entity="murdh_suitcase",
		useOriginalModel=false
	},
	["models/props_c17/briefcase001a.mdl"]={
		entity="murdh_suitcase",
		useOriginalModel=false
	},
}

-- TODO: move these to hooks
function GM:InitPostEntity()
	self:ReplaceAllEntites()
end

function GM:PostCleanupMap()
	self:ReplaceAllEntites()
end