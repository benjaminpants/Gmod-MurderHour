local playerMeta = FindMetaTable("Player")

if (CLIENT) then
	function playerMeta:ChatPrintLocalized(message, data)
		self:ChatPrint(string.format(language.GetPhrase(message), unpack(data)))
	end
	net.Receive("ChatLocalized", function()
		local msg = net.ReadString()
		local count = net.ReadUInt(8)
		local values = {}
		for i=1, count do
			local typ = net.ReadUInt(2)
			if (typ == 0) then
				table.insert(values, net.ReadString())
			elseif (typ == 1) then
				table.insert(values, net.ReadInt(32))
			elseif (typ == 2) then
				table.insert(values, net.ReadFloat())
			else
				table.insert(values, nil)
			end
		end
		LocalPlayer():ChatPrintLocalized(msg, values)
	end)
elseif (SERVER) then
	util.AddNetworkString("ChatLocalized")
	function playerMeta:ChatPrintLocalized(message, data)
		net.Start("ChatLocalized")
		net.WriteString(message)
		if (data == nil) then
			net.WriteUInt(0, 8)
			net.Send(self)
			return
		end
		net.WriteUInt(#data, 8)
		for k, v in ipairs(data) do
			if (type(v) == "string") then
				net.WriteUInt(0,2)
				net.WriteString(v)
			elseif (type(v) == "number") then
				if (v == math.floor(v)) then
					net.WriteUInt(1,2)
					net.WriteInt(v,32)
				else
					net.WriteUInt(2,2)
					net.WriteFloat(v)
				end
			else
				net.WriteUInt(3,2)
			end
		end
		net.Send(self)
	end
end