local playerMeta = FindMetaTable("Player")

function playerMeta:Inspect_FeelPockets(sendResultsTo)
	local invAmount = #self.inventory.contents
	local otherWep = self:GetActiveWeapon()
	if (IsValid(otherWep)) then
		if (otherWep:GetClass() ~= "weapon_murdh_hands") then
			invAmount = invAmount - 1
		end
	end
	sendResultsTo:ChatPrintLocalized("murderhour.chatprint.feltpockets", {invAmount, self:Nick()})
end

function playerMeta:Inspect_AssessCondition(sendResultsTo)
	sendResultsTo:ChatPrint("Assess Condition (Placeholder):")
	sendResultsTo:ChatPrint(self:Health())
end