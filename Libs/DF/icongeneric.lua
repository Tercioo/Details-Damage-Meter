
local detailsFramework = DetailsFramework

if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

---@class df_icongeneric : table, df_icon
---@field expirationTime number
---@field CooldownBrightnessTexture texture
---@field CooldownTexture texture
---@field CountdownText fontstring
---@field CooldownEdge texture
---@field options table

local unpack = unpack
local CreateFrame = CreateFrame
local PixelUtil = PixelUtil
local GetTime = GetTime

local spellIconCache = {}
local spellNameCache = {}
local emptyTable = {}
local white = {1, 1, 1, 1}

local iconFrameOnHideScript = function(self)
	if (self.cooldownLooper) then
		self.cooldownLooper:Cancel()
	end
end

detailsFramework.IconGenericMixin = {
	---create a new icon frame
	---@param self df_iconrow the parent frame
	---@param iconName string the name of the icon frame
	---@return df_icongeneric
    CreateIcon = function(self, iconName)
		---@type df_icongeneric
        local newIcon = CreateFrame("frame", iconName, self)

		---@type texture
        newIcon.Texture = newIcon:CreateTexture(nil, "artwork", nil, 1)
        PixelUtil.SetPoint(newIcon.Texture, "topleft", newIcon, "topleft", 1, -1)
        PixelUtil.SetPoint(newIcon.Texture, "bottomright", newIcon, "bottomright", -1, 1)

		---@type texture
        newIcon.CooldownBrightnessTexture = newIcon:CreateTexture(nil, "artwork", nil, 2)
		newIcon.CooldownBrightnessTexture:SetBlendMode("ADD")
		newIcon.CooldownBrightnessTexture:SetAlpha(1)
        PixelUtil.SetPoint(newIcon.CooldownBrightnessTexture, "topleft", newIcon, "topleft", 0, 0)
        PixelUtil.SetPoint(newIcon.CooldownBrightnessTexture, "bottomright", newIcon, "bottomright", 0, 0)

		---@type texture
        newIcon.Border = newIcon:CreateTexture(nil, "background")
        newIcon.Border:SetAllPoints()
        newIcon.Border:SetColorTexture(0, 0, 0)

		---@type fontstring
        newIcon.StackText = newIcon:CreateFontString(nil, "overlay", "GameFontNormal")
        newIcon.StackText:SetPoint("bottomright", newIcon, "bottomright", 0, 0)
        newIcon.StackText:Hide()
        newIcon.StackTextShadow = newIcon:CreateFontString(nil, "artwork", "GameFontNormal")
        newIcon.StackTextShadow:SetPoint("center", newIcon.StackText, "center", 0, 0)
		newIcon.StackTextShadow:SetTextColor(0, 0, 0)
        newIcon.StackTextShadow:Hide()

		---@type fontstring
        newIcon.Desc = newIcon:CreateFontString(nil, "overlay", "GameFontNormal")
        newIcon.Desc:SetPoint("bottom", newIcon, "top", 0, 2)
        newIcon.Desc:Hide()

        --create a overlay texture which will indicate the cooldown time
        newIcon.CooldownTexture = newIcon:CreateTexture(self:GetName() .. "CooldownTexture", "overlay", nil, 6)
        newIcon.CooldownTexture:SetColorTexture(1, 1, 1, 1)
        newIcon.CooldownTexture:SetPoint("bottomleft", newIcon.Texture, "bottomleft", 0, 0)
        newIcon.CooldownTexture:SetPoint("bottomright", newIcon.Texture, "bottomright", 0, 0)
        newIcon.CooldownTexture:SetHeight(1)
        newIcon.CooldownTexture:Hide()

		newIcon.CooldownEdge = newIcon:CreateTexture(self:GetName() .. "CooldownEdge", "overlay", nil, 7)

        newIcon.CountdownText = newIcon:CreateFontString(self:GetName() .. "CooldownText", "overlay", "GameFontNormal")
        newIcon.CountdownText:SetPoint("center", newIcon, "center", 0, 0)
        newIcon.CountdownText:Hide()

		newIcon.stacks = 0
		newIcon:SetScript("OnHide", iconFrameOnHideScript)

		return newIcon
    end,

	---get an icon frame from the pool
	---@param self df_iconrow the parent frame
	---@return df_icongeneric
	GetIcon = function(self)
		---@type df_icongeneric
		local iconFrame = self.IconPool[self.NextIcon]

		if (not iconFrame) then
			---@type df_icongeneric
            iconFrame = self:CreateIcon("$parentIcon" .. self.NextIcon)
            iconFrame.parentIconRow = self

            iconFrame.Desc:Hide()
            iconFrame.Texture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            iconFrame.Border:ClearAllPoints()
            iconFrame.Border:SetPoint("topleft", iconFrame, "topleft", -1, 1)
            iconFrame.Border:SetPoint("bottomright", iconFrame, "bottomright", 1, -1)
            iconFrame.Border:SetTexture(130759)
            iconFrame.Border:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
            iconFrame.Border:SetDrawLayer("overlay", 7)

            iconFrame.StackText:SetTextColor(detailsFramework:ParseColors(self.options.stack_text_color))
            detailsFramework:SetFontSize(iconFrame.StackText, self.options.stack_text_size)
            detailsFramework:SetFontFace(iconFrame.StackText, self.options.stack_text_font)
            detailsFramework:SetFontOutline(iconFrame.StackText, self.options.stack_text_outline)
            detailsFramework:SetFontFace(iconFrame.StackTextShadow, self.options.stack_text_font)
            detailsFramework:SetFontSize(iconFrame.StackTextShadow, self.options.stack_text_size+1)

            iconFrame.StackText:ClearAllPoints()
            iconFrame.StackText:SetPoint(self.options.stack_text_anchor or "center", iconFrame, self.options.stack_text_rel_anchor or "center", self.options.stack_text_x_offset or 0, self.options.stack_text_y_offset or 0)

			self.IconPool[self.NextIcon] = iconFrame
			iconFrame = iconFrame
		end

		self.NextIcon = self.NextIcon + 1
		return iconFrame
	end,

	SetStacks = function(self, iconFrame, bIsShown, stacksAmount)
		if (bIsShown) then
			iconFrame.StackText:Show()
			iconFrame.StackTextShadow:Show()
			iconFrame.StackText:SetText(stacksAmount)
			iconFrame.StackTextShadow:SetText(stacksAmount)
			iconFrame.stacks = stacksAmount
		else
			iconFrame.StackText:Hide()
			iconFrame.StackTextShadow:Hide()
			iconFrame.stacks = 0
		end
	end,

	---adds only if not existing already in the cache
	---@param self df_iconrow the parent frame
	AddSpecificIcon = function(self, identifierKey, spellId, borderColor, startTime, duration, forceTexture, descText, count, debuffType, caster, canStealOrPurge, spellName, isBuff, modRate, iconSettings)
		if (not identifierKey or identifierKey == "") then
			return
		end

		if (not self.AuraCache[identifierKey]) then
			---@type df_icongeneric
			local icon = self:SetIcon(spellId, borderColor, startTime, duration, forceTexture, descText, count, debuffType, caster, canStealOrPurge, spellName, isBuff or false, modRate, iconSettings)
			icon.identifierKey = identifierKey
			self.AuraCache[identifierKey] = true
		end
	end,

	AddSpecificIconWithTemplate = function(self, iconTemplateTable)
		self:AddSpecificIcon(iconTemplateTable.id, iconTemplateTable.id, nil, iconTemplateTable.startTime, iconTemplateTable.duration, nil, nil, iconTemplateTable.count, nil, nil, nil, nil, nil, nil, iconTemplateTable)
	end,

	---set an icon frame with a template
	---@param self df_iconrow the parent frame
	---@param aI aurainfo
	---@param iconTemplateTable df_icontemplate
	SetAuraWithIconTemplate = function(self, aI, iconTemplateTable)
		local startTime = aI.expirationTime - aI.duration
		---@type df_icongeneric
		self:SetIcon(aI.spellId, nil, startTime, aI.duration, aI.icon, nil, aI.applications, aI.dispelName, aI.sourceUnit, aI.isStealable, aI.name, aI.isHelpful, aI.timeMod, iconTemplateTable, aI.expirationTime)
	end,

	---set an icon frame with a template
	---@param self df_iconrow the parent frame
	---@return df_icongeneric?
	SetIcon = function(self, spellId, borderColor, startTime, duration, iconTexture, descText, count, debuffType, caster, canStealOrPurge, spellName, isBuff, modRate, iconSettings, expirationTime)
		local actualSpellName, spellIcon = spellNameCache[spellId], spellIconCache[spellId]

		iconSettings = iconSettings or emptyTable

		if (not actualSpellName) then
			actualSpellName, _, spellIcon = GetSpellInfo(spellId)
			spellIconCache[spellId] = spellIcon
			spellNameCache[spellId] = actualSpellName
		end

		if iconTexture then
			spellIcon = iconTexture
		end

		if (not spellIcon) then
			if (iconSettings.texture) then
				spellIcon = iconSettings.texture
			end
		end

		if (spellIcon) then
			spellName = spellName or actualSpellName or "unknown_aura"
			modRate = modRate or 1

			---@type df_icongeneric
			local iconFrame = self:GetIcon()
			self.shownAmount = self.NextIcon - 1

			iconFrame.expirationTime = expirationTime

			local widthFromTexture
			local heightFromTexture

			if (iconFrame.Texture.texture ~= spellIcon or (iconSettings.coords and iconSettings.coords ~= iconFrame.currentCoords)) then
				iconFrame.Texture:SetTexture(spellIcon, "CLAMP", "CLAMP",  iconSettings.textureFilter or "LINEAR") --"TRILINEAR"

				if (iconSettings.coords) then
					iconFrame.Texture:SetTexCoord(unpack(iconSettings.coords))
					iconFrame.currentCoords = iconSettings.coords

				elseif (self.options.texcoord ~= iconFrame.currentCoords) then
					iconFrame.Texture:SetTexCoord(unpack(self.options.texcoord))
					iconFrame.currentCoords = self.options.texcoord
				else
					iconFrame.Texture:SetTexCoord(0, 1, 0, 1)
				end

				iconFrame.Texture:ClearAllPoints()

				if (iconSettings.points) then
					for i = 1, #iconSettings.points do
						local point = iconSettings.points[i]
						iconFrame.Texture:SetPoint(point[1], iconFrame, point[2], point[3], point[4])
					end

					if (iconSettings.width) then
						iconFrame.Texture:SetWidth(iconSettings.width)
						widthFromTexture = iconSettings.width
					else
						iconFrame.Texture:SetWidth(self.options.icon_width)
					end

					if (iconSettings.height or iconSettings.width) then
						iconFrame.Texture:SetHeight(iconSettings.height or iconSettings.width)
						heightFromTexture = iconSettings.height or iconSettings.width
					else
						iconFrame.Texture:SetHeight(self.options.icon_height)
					end
				else
					if (iconSettings.width) then
						iconFrame.Texture:SetWidth(iconSettings.width)
						iconFrame.Texture:SetHeight(iconSettings.height or iconSettings.width)
						widthFromTexture = iconSettings.width
						heightFromTexture = iconSettings.height or iconSettings.width
						PixelUtil.SetPoint(iconFrame.Texture, "center", iconFrame, "center", 0, 0)
					else
						PixelUtil.SetPoint(iconFrame.Texture, "topleft", iconFrame, "topleft", 1, -1)
						PixelUtil.SetPoint(iconFrame.Texture, "bottomright", iconFrame, "bottomright", -1, 1)
					end
				end

				iconFrame.Texture.texture = spellIcon

			elseif (not iconSettings.coords) then
				if (self.options.texcoord ~= iconFrame.currentCoords) then
					iconFrame.Texture:SetTexCoord(unpack(self.options.texcoord))
					iconFrame.currentCoords = self.options.texcoord
				else
					iconFrame.Texture:SetTexCoord(0, 1, 0, 1)
				end
			end

			if (borderColor) then
				iconFrame.Border:Show()
				iconFrame.Border:SetVertexColor(unpack(borderColor))
			else
				if (iconSettings.borderColor) then
					iconFrame.Border:Show()
					iconFrame.Border:SetTexture(iconSettings.borderTexture or 130759)
					iconFrame.Border:SetVertexColor(unpack(iconSettings.borderColor or white))
				else
					iconFrame.Border:Hide()
				end
			end

			if (count and count > 1 and self.options.stack_text) then
				self:SetStacks(iconFrame, true, count)
			else
				self:SetStacks(iconFrame, false)
			end

			iconFrame.stacks = count or 0

			if (iconSettings.scale) then
				iconFrame.Texture:SetScale(iconSettings.scale)
				if (widthFromTexture) then
					widthFromTexture = widthFromTexture * iconSettings.scale
				end
				if (heightFromTexture) then
					heightFromTexture = heightFromTexture * iconSettings.scale
				end
			else
				iconFrame.Texture:SetScale(1)
			end

			if (iconSettings.alpha) then
				iconFrame.Texture:SetAlpha(iconSettings.alpha)
			else
				iconFrame.Texture:SetAlpha(1)
			end

			iconFrame:Show()
			iconFrame.textureWidth = iconFrame.Texture:GetWidth()
			iconFrame.textureHeight = iconFrame.Texture:GetHeight()
			PixelUtil.SetSize(iconFrame, iconFrame.textureWidth, iconFrame.textureHeight)

			--cache size
			iconFrame.width = iconFrame.textureWidth
			iconFrame.height = iconFrame.textureHeight

			--iconFrame.Texture:SetBlendMode("ADD")
			iconFrame.CooldownBrightnessTexture:SetTexture(iconFrame.Texture:GetTexture())
			do
				local left, top, c, bottom, right = iconFrame.Texture:GetTexCoord()
				iconFrame.CooldownBrightnessTexture:SetTexCoord(left, right, top, bottom)
				iconFrame.CooldownBrightnessTexture.cords = {left, right, top, bottom}
				iconFrame.CooldownBrightnessTexture.top = top
				iconFrame.CooldownBrightnessTexture.bottom = bottom
			end

			PixelUtil.SetPoint(iconFrame.CooldownBrightnessTexture, "bottomright", iconFrame, "bottomright", -1, 1)

			--make information available
			iconFrame.spellId = spellId
			iconFrame.startTime = startTime
			iconFrame.duration = duration
			iconFrame.endTime = (startTime and duration and startTime + duration) or 0
			iconFrame.count = count
			iconFrame.debuffType = debuffType
			iconFrame.caster = caster
			iconFrame.canStealOrPurge = canStealOrPurge
			iconFrame.isBuff = isBuff
			iconFrame.spellName = spellName
			iconFrame.modRate = modRate
			iconFrame.options = self.options

			if (startTime and duration and duration > 0) then
				local endTime = startTime + duration
				local now = GetTime()
				if (endTime > now) then
					iconFrame.CooldownTexture:Show()
					iconFrame.CooldownBrightnessTexture:Show()
					iconFrame.CooldownTexture:SetHeight(1)
					self:SetCooldown(iconFrame)
				end
			else
				iconFrame.CooldownBrightnessTexture:Hide()
				iconFrame.CooldownTexture:Hide()
			end

			iconFrame.identifierKey = nil -- only used for "specific" add/remove

			--add the spell into the cache
			self.AuraCache[spellId or -1] = true
			self.AuraCache[spellName] = true
			self.AuraCache.canStealOrPurge = self.AuraCache.canStealOrPurge or canStealOrPurge
			self.AuraCache.hasEnrage = self.AuraCache.hasEnrage or debuffType == "" --yes, enrages are empty-string...

			--show the frame
			self:Show()

			return iconFrame
		end
	end,

	---@param self df_iconrow the parent frame
	---@param iconFrame df_icongeneric
	SetCooldown = function(self, iconFrame)
		if (iconFrame.cooldownLooper) then
			iconFrame.cooldownLooper:Cancel()
		end

		local options = iconFrame.options

		--iconFrame:SetScale(3) --debug

		iconFrame.CooldownEdge:Hide()
		iconFrame.CooldownEdge.texture = nil

		detailsFramework:SetFontColor(iconFrame.CountdownText, self.options.text_color)

		PixelUtil.SetSize(iconFrame.CooldownEdge, iconFrame.CooldownTexture:GetWidth(), 2)
		PixelUtil.SetPoint(iconFrame.CooldownEdge, "topleft", iconFrame.CooldownTexture, "topleft", 0, 0)
		PixelUtil.SetPoint(iconFrame.CooldownEdge, "topright", iconFrame.CooldownTexture, "topright", 0, 0)
		PixelUtil.SetHeight(iconFrame.CooldownEdge, 2)

		local swipe_brightness = options.swipe_brightness
		iconFrame.CooldownBrightnessTexture:SetAlpha(swipe_brightness)

		local swipe_darkness = options.swipe_alpha
		iconFrame.CooldownTexture:SetAlpha(swipe_darkness)
		iconFrame.CooldownTexture:SetVertexColor(unpack(options.swipe_color))

		iconFrame.CooldownEdge:SetAlpha(0.834)

		self.OnIconTick(iconFrame)

		local amountOfLoops = math.floor(iconFrame.duration / 0.5)
		local loopEndCallback = nil
		local checkPointCallback = nil

		local newLooper = detailsFramework.Schedules.NewLooper(0.5, self.OnIconTick, amountOfLoops, loopEndCallback, checkPointCallback, iconFrame)
		iconFrame.cooldownLooper = newLooper
	end,

	---@param iconFrame df_icongeneric
	OnIconTick = function(iconFrame)
		local now = GetTime()
		--local percent = (now - iconFrame.startTime) / iconFrame.duration --no mod rate
		local percent = ((now - iconFrame.startTime) / (iconFrame.modRate or 1)) / (iconFrame.duration / (iconFrame.modRate or 1))
		local options = iconFrame.options
		--percent = abs(percent - 1)

		local newHeight = math.min(iconFrame.textureHeight * percent, iconFrame.textureHeight)
		iconFrame.CooldownTexture:SetHeight(newHeight)

		PixelUtil.SetPoint(iconFrame.CooldownBrightnessTexture, "bottomright", iconFrame, "bottomright", 0, newHeight) --iconFrame.textureHeight - 
		local left, right, top, bottom = unpack(iconFrame.CooldownBrightnessTexture.cords)
		local newBottomCord = Lerp(iconFrame.CooldownBrightnessTexture.top, iconFrame.CooldownBrightnessTexture.bottom, abs(percent - 1))
		iconFrame.CooldownBrightnessTexture:SetTexCoord(left, right, top, newBottomCord)

		if (percent > options.swipe_percent2) then
			if (options.swipe_red and iconFrame.CooldownEdge.texture ~= options.swipe_red) then
				iconFrame.CooldownEdge:Show()
				iconFrame.CooldownEdge:SetTexture(options.swipe_red)
				iconFrame.CooldownEdge.texture = options.swipe_red
			end

		elseif (percent > options.swipe_percent1) then
			if (options.swipe_yellow and iconFrame.CooldownEdge.texture ~= options.swipe_yellow) then
				iconFrame.CooldownEdge:Show()
				iconFrame.CooldownEdge:SetTexture(options.swipe_yellow)
				iconFrame.CooldownEdge.texture = options.swipe_yellow
			end
		end

		--iconFrame.CountdownText:SetText(iconFrame.parentIconRow.FormatCooldownTime(iconFrame.duration - (now - iconFrame.startTime))) --no mod rate
		iconFrame.CountdownText:SetText(iconFrame.parentIconRow.FormatCooldownTime((iconFrame.duration - (now - iconFrame.startTime)) / (iconFrame.modRate or 1)))
		--self.CountdownText:Show()
	end,

	FormatCooldownTime = function(thisTime)
		if (thisTime >= 3600) then
			thisTime = math.floor(thisTime / 3600) .. "h"

		elseif (thisTime >= 60) then
			thisTime = math.floor(thisTime / 60) .. "m"

		else
			thisTime = math.floor(thisTime)
		end
		return thisTime
	end,

	FormatCooldownTimeDecimal = function(formattedTime)
        if formattedTime < 10 then
            return ("%.1f"):format(formattedTime)

        elseif formattedTime < 60 then
            return ("%d"):format(formattedTime)

        elseif formattedTime < 3600 then
            return ("%d:%02d"):format(formattedTime/60%60, formattedTime%60)

        elseif formattedTime < 86400 then
            return ("%dh %02dm"):format(formattedTime/(3600), formattedTime/60%60)

        else
            return ("%dd %02dh"):format(formattedTime/86400, (formattedTime/3600) - (math.floor(formattedTime/86400) * 24))
        end
	end,

	---@param self df_iconrow the parent frame
	---@param identifierKey any
	RemoveSpecificIcon = function(self, identifierKey)
		if (not identifierKey or identifierKey == "") then
			return
		end

		if (not self.AuraCache[identifierKey]) then
			return
		end
		self.AuraCache[identifierKey] = nil

		local iconPool = self.IconPool

		--find and hide the icon frame
		for i = 1, self.NextIcon -1 do
			local iconFrame = iconPool[i]
			if (iconFrame.identifierKey and iconFrame.identifierKey == identifierKey) then
				iconFrame:Hide()
				iconFrame:ClearAllPoints()
				iconFrame.identifierKey = nil
			else
				self.AuraCache[iconFrame.spellId] = true
				self.AuraCache[iconFrame.spellName] = true
				self.AuraCache.canStealOrPurge = self.AuraCache.canStealOrPurge or iconFrame.canStealOrPurge
				self.AuraCache.hasEnrage = self.AuraCache.hasEnrage or iconFrame.debuffType == "" --yes, enrages are empty-string...
			end
		end

		self:AlignAuraIcons()
	end,

	---@param self df_iconrow the parent frame
	ClearIcons = function(self, resetBuffs, resetDebuffs)
		resetBuffs = resetBuffs ~= false
		resetDebuffs = resetDebuffs ~= false
		table.wipe(self.AuraCache)

		local iconPool = self.IconPool

		for i = 1, self.NextIcon -1 do
			local iconFrame = iconPool[i]
			if (iconFrame.isBuff == nil) then
				iconFrame:Hide()
				iconFrame:ClearAllPoints()

			elseif (resetBuffs and iconFrame.isBuff) then
				iconFrame:Hide()
				iconFrame:ClearAllPoints()

			elseif (resetDebuffs and not iconFrame.isBuff) then
				iconFrame:Hide()
				iconFrame:ClearAllPoints()

			else
				self.AuraCache[iconFrame.spellId] = true
				self.AuraCache[iconFrame.spellName] = true
				self.AuraCache.canStealOrPurge = self.AuraCache.canStealOrPurge or iconFrame.canStealOrPurge
				self.AuraCache.hasEnrage = self.AuraCache.hasEnrage or iconFrame.debuffType == "" --yes, enrages are empty-string...
			end
		end

		self:AlignAuraIcons()
	end,

	---@param self df_iconrow the parent frame
	AlignAuraIcons = function(self)
		local iconPool = self.IconPool
		local iconAmount = #iconPool
		local countStillShown = 0

		if iconAmount == 0 then
			self:Hide()
		else
			table.sort(iconPool, function(i1, i2) return i1:IsShown() and not i2:IsShown() end)
			local shownAmount = 0
			for i = 1, iconAmount do
				if iconPool[i]:IsShown() then
					shownAmount = shownAmount + 1
				end
			end

			local width = 0
			local growDirection = self:GetIconGrowDirection()
			local nWhichSide = self.options.anchor.side
			local bIsCenterAligned = detailsFramework.ShouldCenterAlign[nWhichSide]

			--re-anchor not hidden
			for i = 1, shownAmount do
				local bIsFirstIcon = i == 1

				local iconFrame = iconPool[i]
				local anchorTo = bIsFirstIcon and self or self.IconPool[i - 1]
				local xPadding

				if (bIsFirstIcon) then
					xPadding = self.options.left_padding
				else
					xPadding = self.options.icon_padding or 1
					xPadding = xPadding * (growDirection == 2 and -1 or 1)
				end

				countStillShown = countStillShown + (iconFrame:IsShown() and 1 or 0)

				iconFrame:ClearAllPoints()

				if (growDirection == 1) then --grow to right
					if (bIsFirstIcon) then
						local attachSide = (bIsCenterAligned and "center") or (nWhichSide and not detailsFramework.SideIsCorner[nWhichSide] and "left") or "bottomleft"
						PixelUtil.SetPoint(iconFrame, attachSide, anchorTo, attachSide, 0, 0)
					else
						PixelUtil.SetPoint(iconFrame, "left", anchorTo, "right", xPadding, 0)
					end

				elseif (growDirection == 2) then --grow to left
					if (bIsFirstIcon) then
						local attachSide = (bIsCenterAligned and "center") or (nWhichSide and not detailsFramework.SideIsCorner[nWhichSide] and "right") or "bottomright"
						PixelUtil.SetPoint(iconFrame, attachSide, anchorTo, attachSide, 0, 0)
					else
						PixelUtil.SetPoint(iconFrame, "right", anchorTo, "left", xPadding, 0)
					end
				end

				width = width + ((iconFrame.width or iconFrame:GetWidth()) * iconFrame:GetScale()) + 1
			end

			if (bIsCenterAligned) then
				self:SetWidth(width)
			end

			self.shownAmount = shownAmount
		end

		self.NextIcon = countStillShown + 1

		if countStillShown > 0 then
			self:Show()
		end
	end,

	---@param self df_iconrow the parent frame
	GetIconGrowDirection = function(self)
		local side = self.options.anchor.side
		return detailsFramework.GrowDirectionBySide[side]
	end,

	---@param self df_iconrow the parent frame
	OnOptionChanged = function(self, optionName)
		if (self.SetBackdropColor) then
			self:SetBackdropColor(unpack(self.options.backdrop_color))
			self:SetBackdropBorderColor(unpack(self.options.backdrop_border_color))
		end
	end,
}

local default_icon_row_options = {
	icon_width = 20,
	icon_height = 20,
	texcoord = {.1, .9, .1, .9},
	show_text = true,
	text_color = {1, 1, 1, 1},
	text_size = 12,
	text_font = "Arial Narrow",
	text_outline = "NONE",
	text_anchor = "center",
	text_rel_anchor = "center",
	text_x_offset = 0,
	text_y_offset = 0,
	desc_text = true,
	desc_text_color = {1, 1, 1, 1},
	desc_text_size = 7,
	desc_text_font = "Arial Narrow",
	desc_text_outline = "NONE",
	desc_text_anchor = "bottom",
	desc_text_rel_anchor = "top",
	desc_text_x_offset = 0,
	desc_text_y_offset = 2,
	stack_text = true,
	stack_text_color = {1, 1, 1, 1},
	stack_text_size = 10,
	stack_text_font = "Arial Narrow",
	stack_text_outline = "NONE",
	stack_text_anchor = "center",
	stack_text_rel_anchor = "bottomright",
	stack_text_x_offset = 0,
	stack_text_y_offset = 0,
	left_padding = 1, --distance between right and left
	top_padding = 1, --distance between top and bottom
	icon_padding = 1, --distance between each icon
	backdrop = {},
	backdrop_color = {0, 0, 0, 0.5},
	backdrop_border_color = {0, 0, 0, 1},
	anchor = {side = 6, x = 2, y = 0},
	grow_direction = 1, --1 = to right 2 = to left
	center_alignment = false, --if true if will align the icons with grow_direction and then set the iconRow width to match the length used by all icons
	surpress_blizzard_cd_timer = false,
	surpress_tulla_omni_cc = false,
	on_tick_cooldown_update = true,
	decimal_timer = false,
	cooldown_reverse = false,
	cooldown_swipe_enabled = true,
	cooldown_edge_texture = "Interface\\Cooldown\\edge",

	swipe_alpha = 0.5,
	swipe_brightness = 0.5,
	swipe_color = {0, 0, 0},
	swipe_yellow = false,
	swipe_red = false,
	swipe_percent1 = 0.75,
	swipe_percent2 = 0.90,

	--first_icon_anchor = "auto",
}

---@param parent frame
---@param name string?
---@param options table?
---@return df_iconrow
function detailsFramework:CreateIconRowGeneric(parent, name, options)
	local newIconRowFrame = CreateFrame("frame", name, parent, "BackdropTemplate")
	newIconRowFrame.IconPool = {}
	newIconRowFrame.NextIcon = 1
	newIconRowFrame.AuraCache = {}
	newIconRowFrame.shownAmount = 0

	detailsFramework:Mixin(newIconRowFrame, detailsFramework.IconGenericMixin)
	detailsFramework:Mixin(newIconRowFrame, detailsFramework.OptionsFunctions)

	newIconRowFrame:BuildOptionsTable(default_icon_row_options, options)

	newIconRowFrame:SetSize(1, 1)

	newIconRowFrame:SetBackdrop(newIconRowFrame.options.backdrop)
	newIconRowFrame:SetBackdropColor(unpack(newIconRowFrame.options.backdrop_color))
	newIconRowFrame:SetBackdropBorderColor(unpack(newIconRowFrame.options.backdrop_border_color))

	return newIconRowFrame
end