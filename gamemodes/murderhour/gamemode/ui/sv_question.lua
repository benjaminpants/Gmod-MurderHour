include("sh_question.lua")

util.AddNetworkString("QuestionBackForth")

local playerMeta = FindMetaTable("Player")

function playerMeta:SendQuestion(title, options, callback, validcheck)
	self:CancelQuestion(false)
	self.currentQuestion = {
		title=title,
		options=options,
		callback=callback,
		validcheck=validcheck
	}
	if (#options > 31) then
		error("Attempted to send question: " .. title .. " to " .. self:Nick() .. " with >31 options!")
		return
	end
	net.Start("QuestionBackForth")
	net.WriteBool(true)
	net.WriteString(title)
	net.WriteUInt(#options, 5)
	for i=1, #options do
		net.WriteString(options[i])
	end
	net.Send(self)
end

function playerMeta:CancelQuestion(network)
	if (self.currentQuestion ~= nil) then
		self.currentQuestion.callback(self, "INTERNAL_EXIT")
		self.currentQuestion = nil
		if (network) then
			net.Start("QuestionBackForth")
			net.WriteBool(false)
			net.Send(self)
		end
	end
end

net.Receive("QuestionBackForth", function(len, ply)
	if (ply.currentQuestion == nil) then return end -- player tried to send invalid question
	local response = net.ReadString()
	if (response == "INTERNAL_EXIT") then ply:CancelQuestion(false) return end
	if (not table.HasValue(ply.currentQuestion.options, response)) then return end -- invalid request, don't send to callback
	ply.currentQuestion.callback(ply, response)
	ply.currentQuestion = nil
end)

hook.Add("DoPlayerDeath", "QuestionDoDeath", function(ply)
	ply:CancelQuestion(true)
end)

hook.Add("Tick", "QuestionTick",function()
	for _, ply in player.Iterator() do
		if (ply.currentQuestion == nil) then continue end
		if (ply.currentQuestion.validcheck == nil) then continue end
		if (not ply.currentQuestion.validcheck(ply)) then
			ply:CancelQuestion(true)
		end
	end
end)