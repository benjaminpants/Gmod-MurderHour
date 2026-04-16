

function GM:PlaySmallPainForPlayer(ply)
	ply:PlayRandomVoiceline("PainSmall", 60, 10)
end

function GM:PlayBigPainForPlayer(ply)
	ply:PlayRandomVoiceline("PainBig", 80, 100)
end

local playerMeta = FindMetaTable("Player")

function playerMeta:PlayRandomVoiceline(category, soundlevel, priority)
	if (not gamemode.Call("PlayerShouldVoiceline", self)) then return end
	local voicebank = GAMEMODE.Voicelines.Male // placeholder
	local potentialSounds = voicebank[category]
	local chosenSound = potentialSounds[math.random(1, #potentialSounds)]
	if (self.currentVoiceline ~= nil) then
		if (self.currentVoiceline:IsPlaying() and (self.currentVoicelinePriority >= priority)) then
			self:SilenceVoiceline()
		end
	end
	self.currentVoiceline = CreateSound(self, chosenSound)
	self.currentVoicelinePriority = priority
	//self.currentVoicelineSound = chosenSound
	self.currentVoiceline:SetSoundLevel(soundlevel)
	self.currentVoiceline:Play()
end

function playerMeta:SilenceVoiceline()
	if (self.currentVoiceline ~= nil) then
		self.currentVoiceline:Stop()
		self.currentVoiceline = nil
		//self.currentVoicelineSound = nil
	end
	self.currentVoicelinePriority = 0
end


function GM:PlayerShouldVoiceline(ply)
	if (ply:HasStatusEffectAtStrength("blackout",2)) then return false end
	if (not ply:Alive()) then return false end
	return true
end