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

--> WatchFrame copy, got removed on WoD
local function DetailsTutorialAlertFrame_OnFinishSlideIn (frame)
	frame.ScrollChild.Shine:Show();
	frame.ScrollChild.IconShine:Show();
	frame.ScrollChild.Shine.Flash:Play();
	frame.ScrollChild.IconShine.Flash:Play();
end

local function DetailsTutorialAlertFrame_OnUpdate (frame, timestep)
	local animData = frame.animData;
	local height = animData.height;
	local scrollStart = animData.scrollStart;
	local scrollEnd = animData.scrollEnd;
	local endTime = animData.slideInTime + (animData.endDelay or 0);

	if (frame.startDelay) then
		frame.startDelay = frame.startDelay - timestep;
		if (frame.startDelay <= 0) then
			frame.startDelay = nil;
		else
			return;
		end
	end

	if (frame.isFirst) then
		height = height + 10;
		scrollEnd = scrollEnd - 10;
	end

	frame.totalTime = frame.totalTime+timestep;
	if (frame.totalTime > endTime) then
		frame.totalTime = endTime;
	end

	local scrollPos = scrollEnd;
	if (animData.slideInTime and animData.slideInTime > 0) then
		height = height*(frame.totalTime/animData.slideInTime);
		scrollPos = scrollStart + (scrollEnd-scrollStart)*(frame.totalTime/animData.slideInTime);
	end
	if ( animData.reverse ) then
		height = max(animData.height - height, 1);
	end
	frame:SetHeight(height);
	frame:UpdateScrollChildRect();
	frame:SetVerticalScroll(floor(scrollPos+0.5));

	if (frame.totalTime >= endTime) then
		frame:SetScript("OnUpdate", nil);
		if ( animData.onFinishFunc ) then
			animData.onFinishFunc(frame);
		end
	end
end

function DetailsTutorialAlertFrame_SlideInFrame (frame, animType)
	frame.totalTime = 0;
	frame.animData = { height = 72, scrollStart = 65, scrollEnd = -9, slideInTime = 0.4, onFinishFunc = DetailsTutorialAlertFrame_OnFinishSlideIn };
	frame.slideInTime = frame.animData.slideInTime;
	frame:SetHeight(1);
	if ( frame.animData.reverse ) then
		frame:SetHeight(frame.animData["height"]);
	else
		frame:SetHeight(1);
	end
	frame.startDelay = frame.animData.startDelay;
	frame:SetScript("OnUpdate", DetailsTutorialAlertFrame_OnUpdate);
end
