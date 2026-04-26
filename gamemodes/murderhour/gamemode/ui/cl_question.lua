include("sh_question.lua")

local currentQuestionPrompt = nil

local function ButtonPressed(b)
	net.Start("QuestionBackForth")
	net.WriteString(b)
	net.SendToServer()
	currentQuestionPrompt:Remove()
	currentQuestionPrompt = nil
end

net.Receive("QuestionBackForth", function()
	if (not net.ReadBool()) then
		if (currentQuestionPrompt ~= nil) then
			currentQuestionPrompt:Remove()
			currentQuestionPrompt = nil
		end
		return
	end
	local questionTitle = net.ReadString()
	local buttonCount = net.ReadUInt(5)
	local buttons = {}
	for i=1, buttonCount do
		table.insert(buttons, net.ReadString())
	end
	if (currentQuestionPrompt ~= nil) then
		currentQuestionPrompt:Remove()
	end
	currentQuestionPrompt = vgui.Create("DFrame")
	currentQuestionPrompt:SetPos((ScrW() / 2) - 125, (ScrH() / 2) - 200) 
	currentQuestionPrompt:SetSize(250, 400) 
	currentQuestionPrompt:SetTitle(questionTitle) 
	currentQuestionPrompt:SetVisible(true) 
	currentQuestionPrompt:SetDraggable(false)
	currentQuestionPrompt:ShowCloseButton(true)
	currentQuestionPrompt.OnClose = function()
		ButtonPressed("INTERNAL_EXIT")
	end

	local topPart = 24
	local splitPerThing = (400-topPart)/buttonCount
	for i=1, buttonCount do
		local button = vgui.Create("DButton", currentQuestionPrompt)
		button:SetText("#murderhour.interaction." .. buttons[i])
		button:SetTextColor(Color(0,0,0))
		button:SetPos(0,topPart + (i-1)*splitPerThing)
		button:SetSize(250, splitPerThing)
		button.DoClick = function()
			local s = buttons[i]
			ButtonPressed(s)
		end
	end

	currentQuestionPrompt:MakePopup()
end)