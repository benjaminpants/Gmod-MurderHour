ENUM_TEMPERATURE_NONE = 0
ENUM_TEMPERATURE_HOT = 1
ENUM_TEMPERATURE_COLD = 2

GM.CookingRecipes = {
	orange_stew = {
		ingredients = {
			weapon_murdh_orange=3
		},
		requiredTemp=ENUM_TEMPERATURE_HOT,
		cookTime=10,
		stirIntervals = {
			3,
			7,
			8,
			9,
		},
		stirMissDelay=0.4,
		stirVariance=0.25
	}
}

function GM:FindMatchingCookingRecipe(itemlist)
	local toMatchWith = {}
	for k, v in pairs(itemlist) do
		local class = v:GetClass()
		if (toMatchWith[class] == nil) then
			toMatchWith[class] = 0
		end
		toMatchWith[class] = toMatchWith[class] + 1
	end
	for id, recipe in pairs(GAMEMODE.CookingRecipes) do
		if (table.Count(recipe.ingredients) ~= table.Count(toMatchWith)) then continue end
		local invalidRecipe = false
		-- uhh... this is probably bad?
		for k, v in pairs(toMatchWith) do
			if (recipe.ingredients[k] ~= v) then
				invalidRecipe = true
				break
			end
		end
		if (invalidRecipe) then continue end
		return id, recipe
	end
	return nil, nil
end