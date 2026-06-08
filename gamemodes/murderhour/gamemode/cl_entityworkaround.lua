EntityWorkaround = {}
EntityWorkaround.Callbacks = {}

function EntityWorkaround.WaitForEnt(id, callback)
	if (IsValid(Entity(id))) then
		callback(Entity(id))
		return true
	end
	if (id == 0) then
		callback(NULL)
		return true
	end
	EntityWorkaround.Callbacks[id] = callback
	return false
end

-- are entities ALWAYS networked even if instantly deleted? probably not an issue for our usecase but something i'd like to be aware of

hook.Add("OnEntityCreated", "EntityWorkaroundEntityCreated", function(ent)
	local entInd = ent:EntIndex()
	if (EntityWorkaround.Callbacks[entInd]) then
		EntityWorkaround.Callbacks[entInd](ent)
		EntityWorkaround.Callbacks[entInd] = nil
	end
end)