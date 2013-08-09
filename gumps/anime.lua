local _detalhes = 		_G._detalhes

--code from blizzard AlertFrames

function _detalhes:PlayGlow (frame)
	frame:Show()
	
	frame.glow:Show()
	frame.glow.animIn:Play()
	frame.shine:Show()
	frame.shine.animIn:Play()
	
	PlaySound ("LFG_Rewards", "master")
end