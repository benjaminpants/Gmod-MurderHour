util.AddNetworkString("ActionBar")

local playerMeta = FindMetaTable("Player")

function playerMeta:StartActionBar(title, finishTime, remainStill, tickcallback, finishedcallback)
	self:CancelActionBar(false)
	self.actionBar = {
		title=title,
		time=finishTime,
		tickcallback=tickcallback,
		finishedcallback=finishedcallback,
		still=remainStill
	}
	if (remainStill) then
		self.actionBar.startPos = self:GetPos()
	end
	net.Start("ActionBar")
	net.WriteBool(true)
	net.WriteString(title)
	net.WriteFloat(CurTime())
	net.WriteFloat(finishTime)
	net.Send(self)
end

function playerMeta:CancelActionBar(successful)
	if (self.actionBar ~= nil) then
		self.actionBar.finishedcallback(self, successful)
		self.actionBar = nil
		net.Start("ActionBar")
		net.WriteBool(false)
		net.Send(self)
	end
end

hook.Add("DoPlayerDeath", "ActionBarDoDeath", function(ply)
	ply:CancelActionBar(false)
end)

hook.Add("Tick", "ActionBarTick",function()
	for _, ply in player.Iterator() do
		if (ply.actionBar == nil) then continue end
		if (ply.actionBar.still) then
			if (ply:GetPos():DistToSqr(ply.actionBar.startPos) >= 64) then // 8 units
				ply:CancelActionBar(false)
				continue
			end
		end
		if (not ply.actionBar.tickcallback(ply)) then
			ply:CancelActionBar(false)
			continue
		end
		if (CurTime() >= ply.actionBar.time) then
			ply:CancelActionBar(true)
		end
	end
end)