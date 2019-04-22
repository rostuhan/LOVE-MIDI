class "Song" {
	private {
		tracks = {},
		systemEvents = {},
		metaEvents = {
			tempoChanges = {},
			timeSignatures = {},
		},
	},
	
	public {
		__construct = function (self, midiSong)
			for i = 1, #midiSong:getTracks() do
				local midiTrack = midiSong:getTrack(i)
				local consumedNoteOffEvent = {}
				
				local track = Track.new()
				self:addTrack(track)
				
				for j = 1, #midiTrack:getEvents() do
					local midiEvent = midiTrack:getEvent(j)
					local time = midiEvent:getTime()
					local type = midiEvent:getType()
					local msg1 = midiEvent:getMsg1()
					local msg2 = midiEvent:getMsg2()
					
					local typeFirstByte = math.floor(type/16)
					local typeSecondByte = type - typeFirstByte
					
					if typeFirstByte == 0x9 and msg2 > 0 then
						-- Note on
						
						-- Search for the first note off event (which has not been used) of the note after the note on event
						-- TODO: Change the implementation of matching note on and note off by using Queue
						for k = j+1, #midiTrack:getEvents() do
							local noteOffEvent = midiTrack:getEvent(k)
							local noteOffTime = noteOffEvent:getTime()
							local noteOffType = noteOffEvent:getType()
							local noteOffMsg1 = noteOffEvent:getMsg1()
							local noteOffMsg2 = noteOffEvent:getMsg2()
					
							local noteOffTypeFirstByte = math.floor(noteOffType/16)
							local noteOffTypeSecondByte = noteOffType - noteOffTypeFirstByte
						
							if noteOffTypeFirstByte == 0x8 or (noteOffTypeFirstByte == 0x9 and msg2 == 0) and not consumedNoteOffEvent[k] and msg1 == noteOffMsg1 and typeSecondByte == noteOffTypeSecondByte then
							
								local note = Note.new(time, noteOffTime, msg1, msg2)
								self.tracks[i]:addNote(note)
								
								consumedNoteOffEvent[k] = true
								break
							end
						end
						
					elseif type == 0xF0 then
						-- System Exclusive Event
					elseif type == 0xFF then	-- Meta Event
						local event = Event.new(time, type, msg1, msg2)
						
						if msg2 == 0x51 then	-- Set Tempo
							self:addTempoChange(event)
							
						elseif msg2 == 0x58 then	-- Time Signature
							self:addTimeSignature(event)
						end
						
					elseif not(typeFirstByte == 0x8 or (typeFirstByte == 0x9 and msg2 == 0)) then
						print(string.format("Unsupported event type: 0x%.2X.", type))
					end
					
				end
			end
		end,
		
		getTracks = function (self)
			return self.tracks
		end,
		
		getSystemEvents = function (self)
			return self.systemEvents
		end,
		
		getMetaEvents = function (self)
			return self.metaEvents
		end,
		
		getTrack = function (self, trackID)
			return self.tracks[trackID]
		end,
		
		getTempoChanges = function (self)
			return self.metaEvents.tempoChanges
		end,
		
		getTimeSignatures = function (self)
			return self.metaEvents.timeSignatures
		end,
		
		addTrack = function (self, track)
			self.tracks[#self.tracks+1] = track
		end,
		
		addTempoChange = function (self, tempoChange)
			self.tempoChangs[#self.tempoChanges+1] = tempoChange
		end,
		
		addTimeSignature = function (self, timeSignature)
			self.timeSignatures[#self.timeSignatures+1] = timeSignature
		end,
	},
}