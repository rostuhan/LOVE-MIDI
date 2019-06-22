class "TimeManager" {
	new = function (self, player)
		self.player = player
		self.time = 1000
		self.currentTempoChangeID = 1
	end,

	update = function (self, dt)
		local song = self.player:getSong()
		local tempoChanges = song:getTempoChanges()
		local timeDivision = song:getTimeDivision()
		
		local newTime = self.time + (self.player:getPlaybackSpeed() * dt * tempoChanges[self.currentTempoChangeID]:getTempo() * timeDivision / 60)	-- 60 means 60 seconds
		
		-- The time between the original time and new time may be passed some tempo change events
		for i = self.currentTempoChangeID+1, #tempoChanges do
			local nextTempoChangeTime = tempoChanges[i]:getTime()
			
			if newTime < tempoChanges[i]:getTime() then
				break
			else
				local previousTempoTimeRegion = nextTempoChangeTime - self.time
				local newTempoTimeRegion = newTime - nextTempoChangeTime
				local newPerPrevTempoRatio = tempoChanges[i]:getTempo() / tempoChanges[i-1]:getTempo()
				newTime = self.time + previousTempoTimeRegion + newPerPrevTempoRatio * newTempoTimeRegion
				
				self.currentTempoChangeID = i
				self.time = newTime
			end
		end
		
		self.time = newTime
	end,

	getTime = function (self)
		return self.time
	end,
	
	-- TODO: remove this method later, it is for debug only
	setTime = function (self, time)
		self.time = time
	end,
}