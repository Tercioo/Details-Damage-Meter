
local detailsFramework = _G["DetailsFramework"]
if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

--note: this scroll bar is using legacy code and shouldn't be used on creating new stuff
do
	function detailsFramework:CreateScrollBar(master, scrollContainer, x, y)
		return detailsFramework:NewScrollBar(master, scrollContainer, x, y)
	end

	function detailsFramework:NewScrollBar(parent, scrollContainer, x, y)
		local newSlider = CreateFrame("Slider", nil, parent, "BackdropTemplate")
		newSlider.scrollMax = 560

		newSlider:SetPoint("TOPLEFT", parent, "TOPRIGHT", x, y)
		newSlider.ativo = true

		newSlider.bg = newSlider:CreateTexture(nil, "BACKGROUND")
		newSlider.bg:SetAllPoints(true)
		newSlider.bg:SetTexture(0, 0, 0, 0)

		newSlider.thumb = newSlider:CreateTexture(nil, "OVERLAY")
		newSlider.thumb:SetTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
		newSlider.thumb:SetSize(29, 30)
		newSlider:SetThumbTexture(newSlider.thumb)
		newSlider:SetOrientation("VERTICAL")
		newSlider:SetSize(16, 100)
		newSlider:SetMinMaxValues(0, newSlider.scrollMax)
		newSlider:SetValue(0)
		newSlider.ultimo = 0

		local upButton = CreateFrame("Button", nil, parent,"BackdropTemplate")

		upButton:SetPoint("BOTTOM", newSlider, "TOP", 0, -12)
		upButton.x = 0
		upButton.y = -12

		upButton:SetWidth(29)
		upButton:SetHeight(32)
		upButton:SetNormalTexture("Interface\\BUTTONS\\UI-ScrollBar-ScrollUpButton-Up")
		upButton:SetPushedTexture("Interface\\BUTTONS\\UI-ScrollBar-ScrollUpButton-Down")
		upButton:SetDisabledTexture("Interface\\BUTTONS\\UI-ScrollBar-ScrollUpButton-Disabled")
		upButton:Show()
		upButton:Disable()

		local downDutton = CreateFrame("Button", nil, parent,"BackdropTemplate")
		downDutton:SetPoint("TOP", newSlider, "BOTTOM", 0, 12)
		downDutton.x = 0
		downDutton.y = 12

		downDutton:SetWidth(29)
		downDutton:SetHeight(32)
		downDutton:SetNormalTexture("Interface\\BUTTONS\\UI-ScrollBar-ScrollDownButton-Up")
		downDutton:SetPushedTexture("Interface\\BUTTONS\\UI-ScrollBar-ScrollDownButton-Down")
		downDutton:SetDisabledTexture("Interface\\BUTTONS\\UI-ScrollBar-ScrollDownButton-Disabled")	
		downDutton:Show()
		downDutton:Disable()

		parent.baixo = downDutton
		parent.cima = upButton
		parent.slider = newSlider

		downDutton:SetScript("OnMouseDown", function(self)
			if (not newSlider:IsEnabled()) then
				return
			end

			local current = newSlider:GetValue()
			local minValue, maxValue = newSlider:GetMinMaxValues()
			if (current + 5 < maxValue) then
				newSlider:SetValue(current + 5)
			else
				newSlider:SetValue(maxValue)
			end
			self.precionado = true
			self.last_up = -0.3
			self:SetScript("OnUpdate", function(self, elapsed)
				self.last_up = self.last_up + elapsed
				if (self.last_up > 0.03) then
					self.last_up = 0
					local current = newSlider:GetValue()
					local minValue, maxValue = newSlider:GetMinMaxValues()
					if (current + 2 < maxValue) then
						newSlider:SetValue(current + 2)
					else
						newSlider:SetValue(maxValue)
					end
				end
			end)
		end)

		downDutton:SetScript("OnMouseUp", function(self)
			self.precionado = false
			self:SetScript("OnUpdate", nil)
		end)

		upButton:SetScript("OnMouseDown", function(self)
			if (not newSlider:IsEnabled()) then
				return
			end

			local current = newSlider:GetValue()
			if (current - 5 > 0) then
				newSlider:SetValue(current - 5)
			else
				newSlider:SetValue(0)
			end

			self.precionado = true
			self.last_up = -0.3
			self:SetScript("OnUpdate", function(self, elapsed)
				self.last_up = self.last_up + elapsed
				if (self.last_up > 0.03) then
					self.last_up = 0
					local current = newSlider:GetValue()
					if (current - 2 > 0) then
						newSlider:SetValue(current - 2)
					else
						newSlider:SetValue(0)
					end
				end
			end)
		end)

		upButton:SetScript("OnMouseUp", function(self)
			self.precionado = false
			self:SetScript("OnUpdate", nil)
		end)

		upButton:SetScript("OnEnable", function(self)
			local current = newSlider:GetValue()
			if (current == 0) then
				upButton:Disable()
			end
		end)

		newSlider:SetScript("OnValueChanged", function(self)
			local current = self:GetValue()
			parent:SetVerticalScroll(current)

			local minValue, maxValue = newSlider:GetMinMaxValues()

			if (current == minValue) then
				upButton:Disable()
			elseif (not upButton:IsEnabled()) then
				upButton:Enable()
			end

			if (current == maxValue) then
				downDutton:Disable()
			elseif (not downDutton:IsEnabled()) then
				downDutton:Enable()
			end
		end)

		newSlider:SetScript("OnShow", function(self)
			upButton:Show()
			downDutton:Show()
		end)

		newSlider:SetScript("OnDisable", function(self)
			upButton:Disable()
			downDutton:Disable()
		end)

		newSlider:SetScript("OnEnable", function(self)
			upButton:Enable()
			downDutton:Enable()
		end)

		parent:SetScript("OnMouseWheel", function(self, delta)
			if (not newSlider:IsEnabled()) then
				return
			end

			local current = newSlider:GetValue()
			if (delta < 0) then
				local minValue, maxValue = newSlider:GetMinMaxValues()
				if (current + (parent.wheel_jump or 20) < maxValue) then
					newSlider:SetValue(current + (parent.wheel_jump or 20))
				else
					newSlider:SetValue(maxValue)
				end
			elseif (delta > 0) then
				if (current + (parent.wheel_jump or 20) > 0) then
					newSlider:SetValue(current - (parent.wheel_jump or 20))
				else
					newSlider:SetValue(0)
				end
			end
		end)

		function newSlider:Altura(height)
			self:SetHeight(height)
		end

		function newSlider:Update(desativar)
			if (desativar) then
				newSlider:Disable()
				newSlider:SetValue(0)
				newSlider.ativo = false
				parent:EnableMouseWheel(false)
				return
			end

			self.scrollMax = scrollContainer:GetHeight() - parent:GetHeight()
			if (self.scrollMax > 0) then
				newSlider:SetMinMaxValues(0, self.scrollMax)
				if (not newSlider.ativo) then
					newSlider:Enable()
					newSlider.ativo = true
					parent:EnableMouseWheel(true)
				end
			else
				newSlider:Disable()
				newSlider:SetValue(0)
				newSlider.ativo = false
				parent:EnableMouseWheel(false)
			end
		end

		function newSlider:cimaPoint(x, y)
			upButton:SetPoint("BOTTOM", newSlider, "TOP", x, y - 12)
		end

		function newSlider:baixoPoint(x, y)
			downDutton:SetPoint("TOP", newSlider, "BOTTOM", x, y + 12)
		end

		return newSlider
	end
end

--constants
local SCROLLBAR2_DEFAULTS = {
	width = 16,
	backdrop_color = {0.1, 0.1, 0.1, 1.0},
	border_color = {0.0, 0.0, 0.0, 0.3},
	thumb_color = {0.5, 0.5, 0.5, 0.95},
	thumb_hover_color = {0.7, 0.7, 0.7, 0.95},
	wheel_step = 20,
	min_thumb_height = 12,
	show_step_buttons = true,
	step_amount = 1,
	step_repeat_initial_delay = 0.3,
	step_repeat_rate = 0.05,
	step_button_height = 16,
}

---@class df_scrollbar2_options : table
---@field width number?
---@field backdrop_color number[]?
---@field border_color number[]?
---@field thumb_color number[]?
---@field thumb_hover_color number[]?
---@field wheel_step number?
---@field min_thumb_height number?
---@field show_step_buttons boolean?
---@field step_amount number?
---@field step_repeat_initial_delay number?
---@field step_repeat_rate number?
---@field step_button_height number?

---@class df_scrollbar2 : frame
---@field Track frame
---@field Thumb button
---@field StepUpButton button?
---@field StepDownButton button?
---@field Options df_scrollbar2_options
---@field OnScrollChange fun(scrollBar:df_scrollbar2, value:number)?
---@field maxValue number
---@field currentValue number
---@field visibleRatio number
---@field dragGrabOffset number
---@field SetRange fun(self:df_scrollbar2, maxValue:number)
---@field GetRange fun(self:df_scrollbar2):number
---@field SetValue fun(self:df_scrollbar2, value:number)
---@field GetValue fun(self:df_scrollbar2):number
---@field SetVisibleRatio fun(self:df_scrollbar2, ratio:number)
---@field GetVisibleRatio fun(self:df_scrollbar2):number
---@field SetOnScrollChange fun(self:df_scrollbar2, callback:function)
---@field EnableMouseWheelOn fun(self:df_scrollbar2, frame:frame)
---@field UpdateThumbHeight fun(self:df_scrollbar2)
---@field UpdateThumbPosition fun(self:df_scrollbar2)
---@field StartDrag fun(self:df_scrollbar2, mouseButton:string)
---@field HandleDragUpdate fun(self:df_scrollbar2)
---@field StopDrag fun(self:df_scrollbar2)
---@field JumpToCursor fun(self:df_scrollbar2, mouseButton:string)
---@field Step fun(self:df_scrollbar2, direction:number)
---@field UpdateStepButtonStates fun(self:df_scrollbar2)

--mixin for df_scrollbar2. Holds public API + drag helpers; applied to the
--instance via detailsFramework:Mixin inside CreateScrollBar2.
---@class df_scrollbar2_mixin
detailsFramework.ScrollBar2Mixin = {

	--sets the maximum scrollable value. caller drives this from content size minus visible size.
	--clamps currentValue to the new max; fires OnScrollChange if the value actually changed.
	---@param self df_scrollbar2
	---@param maxValue number
	SetRange = function(self, maxValue)
		if (maxValue < 0) then
			maxValue = 0
		end

		self.maxValue = maxValue
		local valueChanged = false

		if (self.currentValue > self.maxValue) then
			self.currentValue = self.maxValue
			valueChanged = true
		end

		self:UpdateThumbHeight()
		self:UpdateThumbPosition()
		self:UpdateStepButtonStates()

		if (valueChanged and self.OnScrollChange) then
			self.OnScrollChange(self, self.currentValue)
		end
	end,

	--returns the current maximum scrollable value.
	---@param self df_scrollbar2
	---@return number
	GetRange = function(self)
		return self.maxValue
	end,

	--sets the current scroll value, clamped to [0, maxValue]. fires OnScrollChange on change.
	---@param self df_scrollbar2
	---@param value number
	SetValue = function(self, value)
		if (value < 0) then
			value = 0
		end

		if (value > self.maxValue) then
			value = self.maxValue
		end

		local valueChanged = value ~= self.currentValue
		self.currentValue = value
		self:UpdateThumbPosition()
		self:UpdateStepButtonStates()

		if (valueChanged and self.OnScrollChange) then
			self.OnScrollChange(self, value)
		end
	end,

	--scrolls by one step in the given direction (-1 = up, +1 = down). routes through SetValue
	--so the thumb position, callback dispatch, and step-button disabled state all stay in sync.
	---@param self df_scrollbar2
	---@param direction number
	Step = function(self, direction)
		self:SetValue(self.currentValue + direction * self.Options.step_amount)
	end,

	--enables/disables the step buttons based on whether scrolling in that direction is possible.
	--no-op when step buttons were disabled in options. called from SetValue and SetRange.
	---@param self df_scrollbar2
	UpdateStepButtonStates = function(self)
		if (not self.StepUpButton) then
			return
		end

		if (self.currentValue <= 0) then
			self.StepUpButton:Disable()
		else
			self.StepUpButton:Enable()
		end

		if (self.currentValue >= self.maxValue) then
			self.StepDownButton:Disable()
		else
			self.StepDownButton:Enable()
		end
	end,

	--returns the current scroll value.
	---@param self df_scrollbar2
	---@return number
	GetValue = function(self)
		return self.currentValue
	end,

	--sets the visible/total ratio (0..1). drives the thumb height: small ratio = small thumb.
	---@param self df_scrollbar2
	---@param ratio number
	SetVisibleRatio = function(self, ratio)
		if (ratio < 0) then
			ratio = 0
		end

		if (ratio > 1) then
			ratio = 1
		end

		self.visibleRatio = ratio
		self:UpdateThumbHeight()
		self:UpdateThumbPosition()
	end,

	--returns the current visible/total ratio.
	---@param self df_scrollbar2
	---@return number
	GetVisibleRatio = function(self)
		return self.visibleRatio
	end,

	--registers the callback fired on every value change. signature: function(scrollBar, value).
	---@param self df_scrollbar2
	---@param callback fun(scrollBar:df_scrollbar2, value:number)
	SetOnScrollChange = function(self, callback)
		self.OnScrollChange = callback
	end,

	--wires mouse wheel input on the given frame to step the scrollbar value.
	---@param self df_scrollbar2
	---@param frame frame
	EnableMouseWheelOn = function(self, frame)
		frame:EnableMouseWheel(true)
		local scrollBar = self
		frame:SetScript("OnMouseWheel", function(wheelFrame, delta)
			local step = scrollBar.Options.wheel_step
			scrollBar:SetValue(scrollBar.currentValue - delta * step)
		end)
	end,

	--recalculates thumb height from track height * visible ratio, clamped by min_thumb_height
	--floor and trackHeight ceiling.
	---@param self df_scrollbar2
	UpdateThumbHeight = function(self)
		local trackHeight = self.Track:GetHeight()
		local thumbHeight = math.floor(trackHeight * self.visibleRatio)

		if (thumbHeight < self.Options.min_thumb_height) then
			thumbHeight = self.Options.min_thumb_height
		end

		if (thumbHeight > trackHeight) then
			thumbHeight = trackHeight
		end

		self.Thumb:SetHeight(thumbHeight)
	end,

	--positions the thumb based on currentValue / maxValue. thumb top sits at trackTop minus
	--(progress * draggableRange), where draggableRange = trackHeight - thumbHeight.
	---@param self df_scrollbar2
	UpdateThumbPosition = function(self)
		local trackHeight = self.Track:GetHeight()
		local thumbHeight = self.Thumb:GetHeight()
		local draggableRange = trackHeight - thumbHeight

		if (draggableRange < 0) then
			draggableRange = 0
		end

		local progress = 0
		if (self.maxValue > 0) then
			progress = self.currentValue / self.maxValue
		end

		local thumbOffset = math.floor(progress * draggableRange + 0.5)
		self.Thumb:ClearAllPoints()
		self.Thumb:SetPoint("topleft", self.Track, "topleft", 0, -thumbOffset)
		self.Thumb:SetPoint("topright", self.Track, "topright", 0, -thumbOffset)
	end,

	--begins a thumb drag: records the cursor-to-thumb-top offset and hooks OnUpdate.
	---@param self df_scrollbar2
	---@param mouseButton string
	StartDrag = function(self, mouseButton)
		if (mouseButton ~= "LeftButton") then
			return
		end

		local _, cursorY = GetCursorPosition()
		local scale = self.Thumb:GetEffectiveScale()
		cursorY = cursorY / scale
		self.dragGrabOffset = cursorY - self.Thumb:GetTop()

		local scrollBar = self
		self.Thumb:SetScript("OnUpdate", function()
			scrollBar:HandleDragUpdate()
		end)
	end,

	--runs each frame while the thumb is being dragged. polls IsMouseButtonDown to catch
	--releases off-frame where OnMouseUp would not fire on the thumb.
	---@param self df_scrollbar2
	HandleDragUpdate = function(self)
		if (not IsMouseButtonDown("LeftButton")) then
			self:StopDrag()
			return
		end

		local _, cursorY = GetCursorPosition()
		local scale = self.Thumb:GetEffectiveScale()
		cursorY = cursorY / scale

		--target thumb top derived from cursor and grab offset; clamp so the thumb stays
		--inside the track's draggable range (trackHeight - thumbHeight).
		local newThumbTop = cursorY - self.dragGrabOffset
		local trackTop = self.Track:GetTop()
		local trackHeight = self.Track:GetHeight()
		local thumbHeight = self.Thumb:GetHeight()
		local offsetFromTop = trackTop - newThumbTop

		if (offsetFromTop < 0) then
			offsetFromTop = 0
		end

		local maxOffset = trackHeight - thumbHeight
		if (offsetFromTop > maxOffset) then
			offsetFromTop = maxOffset
		end

		local progress = 0
		if (maxOffset > 0) then
			progress = offsetFromTop / maxOffset
		end

		self:SetValue(progress * self.maxValue)
	end,

	--ends a drag by unhooking the thumb's OnUpdate.
	---@param self df_scrollbar2
	StopDrag = function(self)
		self.Thumb:SetScript("OnUpdate", nil)
	end,

	--maps a track-relative cursor click to a scroll percentage and applies it.
	--no-op when the click landed on the thumb (the thumb's own OnMouseDown handles that path).
	---@param self df_scrollbar2
	---@param mouseButton string
	JumpToCursor = function(self, mouseButton)
		if (mouseButton ~= "LeftButton") then
			return
		end

		if (self.Thumb:IsMouseOver()) then
			return
		end

		local _, cursorY = GetCursorPosition()
		cursorY = cursorY / self.Track:GetEffectiveScale()

		local trackHeight = self.Track:GetHeight()
		local clickOffset = self.Track:GetTop() - cursorY
		local progress = 0

		if (trackHeight > 0) then
			progress = clickOffset / trackHeight
		end

		if (progress < 0) then
			progress = 0
		end

		if (progress > 1) then
			progress = 1
		end

		self:SetValue(progress * self.maxValue)
	end,
}

--creates a new scrollbar widget built from plain frames (Track + Thumb), replacing the
--FauxScrollFrame Slider model used elsewhere. Provides 1:1 cursor-to-thumb dragging,
--proportional thumb height, and predictable hit-testing. The caller drives the model by
--calling SetRange/SetVisibleRatio and reacts to scroll changes via SetOnScrollChange.
---@param parent frame
---@param trackHeight number
---@param onScrollChange fun(scrollBar:df_scrollbar2, value:number)?
---@param options df_scrollbar2_options?
---@return df_scrollbar2
function detailsFramework:CreateScrollBar2(parent, trackHeight, onScrollChange, options)
	--merge caller options over defaults so the rest of the code never sees nil keys.
	local finalOptions = {}
	for key, value in pairs(SCROLLBAR2_DEFAULTS) do
		finalOptions[key] = value
	end

	if (options) then
		for key, value in pairs(options) do
			finalOptions[key] = value
		end
	end

	---@type df_scrollbar2
	local scrollBar = CreateFrame("frame", nil, parent)
	scrollBar:SetSize(finalOptions.width, trackHeight)

	--track is a clickable child that contains the thumb. clicks outside the thumb jump
	--the scroll position to wherever the cursor landed on the track. when step buttons are
	--enabled the track is inset top/bottom to leave room for them; otherwise it fills the
	--whole scrollbar frame.
	local track = CreateFrame("frame", nil, scrollBar, "BackdropTemplate")
	if (finalOptions.show_step_buttons) then
		local stepInset = finalOptions.step_button_height
		track:SetPoint("topleft", scrollBar, "topleft", 0, -stepInset)
		track:SetPoint("bottomright", scrollBar, "bottomright", 0, stepInset)
	else
		track:SetAllPoints(scrollBar)
	end

	track:EnableMouse(true)
	track:SetBackdrop({
		bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
		edgeFile = [[Interface\Buttons\WHITE8X8]],
		edgeSize = 1,
	})
	track:SetBackdropColor(unpack(finalOptions.backdrop_color))
	track:SetBackdropBorderColor(unpack(finalOptions.border_color))

	--thumb is a button parented to the track. drag handlers clamp it to track bounds.
	local thumb = CreateFrame("button", nil, track, "BackdropTemplate")
	thumb:SetPoint("topleft", track, "topleft", 0, 0)
	thumb:SetPoint("topright", track, "topright", 0, 0)
	thumb:SetHeight(finalOptions.min_thumb_height)
	thumb:SetBackdrop({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]]})
	thumb:SetBackdropColor(unpack(finalOptions.thumb_color))

	--instance state
	scrollBar.Track = track
	scrollBar.Thumb = thumb
	scrollBar.Options = finalOptions
	scrollBar.maxValue = 0
	scrollBar.currentValue = 0
	scrollBar.visibleRatio = 1
	scrollBar.dragGrabOffset = 0
	scrollBar.OnScrollChange = onScrollChange

	detailsFramework:Mixin(scrollBar, detailsFramework.ScrollBar2Mixin)

	--thumb hover tinting
	thumb:SetScript("OnEnter", function(thumbSelf)
		thumbSelf:SetBackdropColor(unpack(finalOptions.thumb_hover_color))
	end)

	thumb:SetScript("OnLeave", function(thumbSelf)
		thumbSelf:SetBackdropColor(unpack(finalOptions.thumb_color))
	end)

	--script wiring delegates to mixin methods so the logic stays in one inspectable place.
	thumb:RegisterForClicks("LeftButtonDown", "LeftButtonUp")
	thumb:SetScript("OnMouseDown", function(thumbSelf, mouseButton)
		scrollBar:StartDrag(mouseButton)
	end)

	thumb:SetScript("OnMouseUp", function(thumbSelf, mouseButton)
		if (mouseButton == "LeftButton") then
			scrollBar:StopDrag()
		end
	end)

	track:SetScript("OnMouseDown", function(trackSelf, mouseButton)
		scrollBar:JumpToCursor(mouseButton)
	end)

	--track OnSizeChanged keeps the thumb height/position in sync when the scrollbar grows
	--or shrinks via anchor propagation (e.g. parent window resize). without this, the thumb
	--keeps the proportional size computed at the previous trackHeight until the next caller
	--SetVisibleRatio call.
	track:SetScript("OnSizeChanged", function()
		scrollBar:UpdateThumbHeight()
		scrollBar:UpdateThumbPosition()
	end)

	--optional step buttons. when shown, an up arrow sits above the track and a down arrow
	--below it, both wired to scrollBar:Step which routes through SetValue so the thumb,
	--callback, and disabled-state logic all stay consistent with mouse-wheel/drag input.
	--hold-to-scroll: OnMouseDown fires one immediate step, then OnUpdate fires repeats
	--after an initial delay. IsMouseButtonDown polling catches releases off-button where
	--OnMouseUp would not fire (matches the thumb-drag release detection).
	if (finalOptions.show_step_buttons) then
		local stepUpButton = CreateFrame("button", nil, scrollBar)
		stepUpButton:SetPoint("topleft", scrollBar, "topleft", 0, 0)
		stepUpButton:SetPoint("topright", scrollBar, "topright", 0, 0)
		stepUpButton:SetHeight(finalOptions.step_button_height)
		stepUpButton:SetNormalTexture([[Interface\Buttons\Arrow-Up-Up]])
		stepUpButton:SetPushedTexture([[Interface\Buttons\Arrow-Up-Down]])
		stepUpButton:SetDisabledTexture([[Interface\Buttons\Arrow-Up-Disabled]])
		stepUpButton:SetHighlightTexture([[Interface\Buttons\UI-Common-MouseHilight]], "ADD")
		stepUpButton:RegisterForClicks("LeftButtonDown", "LeftButtonUp")

		local stepDownButton = CreateFrame("button", nil, scrollBar)
		stepDownButton:SetPoint("bottomleft", scrollBar, "bottomleft", 0, 0)
		stepDownButton:SetPoint("bottomright", scrollBar, "bottomright", 0, 0)
		stepDownButton:SetHeight(finalOptions.step_button_height)
		stepDownButton:SetNormalTexture([[Interface\Buttons\Arrow-Down-Up]])
		stepDownButton:SetPushedTexture([[Interface\Buttons\Arrow-Down-Down]])
		stepDownButton:SetDisabledTexture([[Interface\Buttons\Arrow-Down-Disabled]])
		stepDownButton:SetHighlightTexture([[Interface\Buttons\UI-Common-MouseHilight]], "ADD")
		stepDownButton:RegisterForClicks("LeftButtonDown", "LeftButtonUp")

		scrollBar.StepUpButton = stepUpButton
		scrollBar.StepDownButton = stepDownButton

		local startHold = function(stepButton, direction)
			scrollBar:Step(direction)
			--countdown until the next repeated step. starts at the initial delay; subsequent
			--repeats reset to step_repeat_rate so the cadence matches WoW's native scrollbars.
			stepButton.holdElapsed = 0
			stepButton.nextStepAt = finalOptions.step_repeat_initial_delay
			stepButton:SetScript("OnUpdate", function(handlerButton, elapsed)
				if (not IsMouseButtonDown("LeftButton")) then
					handlerButton:SetScript("OnUpdate", nil)
					return
				end

				handlerButton.holdElapsed = handlerButton.holdElapsed + elapsed
				if (handlerButton.holdElapsed >= handlerButton.nextStepAt) then
					scrollBar:Step(direction)
					handlerButton.holdElapsed = 0
					handlerButton.nextStepAt = finalOptions.step_repeat_rate
				end
			end)
		end

		local stopHold = function(stepButton)
			stepButton:SetScript("OnUpdate", nil)
		end

		stepUpButton:SetScript("OnMouseDown", function(buttonSelf, mouseButton)
			if (mouseButton == "LeftButton") then
				startHold(buttonSelf, -1)
			end
		end)

		stepUpButton:SetScript("OnMouseUp", function(buttonSelf, mouseButton)
			if (mouseButton == "LeftButton") then
				stopHold(buttonSelf)
			end
		end)

		stepDownButton:SetScript("OnMouseDown", function(buttonSelf, mouseButton)
			if (mouseButton == "LeftButton") then
				startHold(buttonSelf, 1)
			end
		end)

		stepDownButton:SetScript("OnMouseUp", function(buttonSelf, mouseButton)
			if (mouseButton == "LeftButton") then
				stopHold(buttonSelf)
			end
		end)

		scrollBar:UpdateStepButtonStates()
	end

	return scrollBar
end
