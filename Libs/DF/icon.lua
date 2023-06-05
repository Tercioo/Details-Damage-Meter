
local detailsFramework = DetailsFramework

if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

local unpack = unpack
local CreateFrame = CreateFrame
local PixelUtil = PixelUtil

detailsFramework.IconMixin = {
	---create a new icon frame
	---@param self frame the parent frame
	---@param iconName string the name of the icon frame
	---@return frame
    CreateIcon = function(self, iconName)
        local iconFrame = CreateFrame("frame", iconName, self, "BackdropTemplate")

        iconFrame.Texture = iconFrame:CreateTexture(nil, "artwork")
        PixelUtil.SetPoint(iconFrame.Texture, "topleft", iconFrame, "topleft", 1, -1)
        PixelUtil.SetPoint(iconFrame.Texture, "bottomright", iconFrame, "bottomright", -1, 1)

        iconFrame.Border = iconFrame:CreateTexture(nil, "background")
        iconFrame.Border:SetAllPoints()
        iconFrame.Border:SetColorTexture(0, 0, 0)

        iconFrame:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1})
        iconFrame:SetBackdropBorderColor(0, 0, 0, 0)
        iconFrame:EnableMouse(false)

        local cooldownFrame = CreateFrame("cooldown", "$parentCooldown", iconFrame, "CooldownFrameTemplate, BackdropTemplate")
        cooldownFrame:SetAllPoints()
        cooldownFrame:EnableMouse(false)
        cooldownFrame:SetFrameLevel(iconFrame:GetFrameLevel()+1)
        iconFrame.Cooldown = cooldownFrame

        iconFrame.CountdownText = cooldownFrame:CreateFontString(nil, "overlay", "GameFontNormal")
        iconFrame.CountdownText:SetPoint("center", iconFrame, "center", 0, 0)
        iconFrame.CountdownText:Hide()

        iconFrame.StackText = iconFrame:CreateFontString(nil, "overlay", "GameFontNormal")
        iconFrame.StackText:SetPoint("center", iconFrame, "bottomright", 0, 0)
        iconFrame.StackText:Hide()

        iconFrame.Desc = iconFrame:CreateFontString(nil, "overlay", "GameFontNormal")
        iconFrame.Desc:SetPoint("bottom", iconFrame, "top", 0, 2)
        iconFrame.Desc:Hide()

		return iconFrame
    end,

	GetIcon = function(self)
		local iconFrame = self.IconPool[self.NextIcon]

		if (not iconFrame) then
            local newIconFrame = self:CreateIcon("$parentIcon" .. self.NextIcon)
            newIconFrame.parentIconRow = self
            newIconFrame.Cooldown:SetHideCountdownNumbers(self.options.surpress_blizzard_cd_timer)
            newIconFrame.Cooldown.noCooldownCount = self.options.surpress_tulla_omni_cc

            newIconFrame.CountdownText:ClearAllPoints()
            newIconFrame.CountdownText:SetPoint(self.options.text_anchor or "center", iconFrame, self.options.text_rel_anchor or "center", self.options.text_x_offset or 0, self.options.text_y_offset or 0)
            newIconFrame.StackText:ClearAllPoints()
            newIconFrame.StackText:SetPoint(self.options.stack_text_anchor or "center", iconFrame, self.options.stack_text_rel_anchor or "bottomright", self.options.stack_text_x_offset or 0, self.options.stack_text_y_offset or 0)
            newIconFrame.Desc:ClearAllPoints()
            newIconFrame.Desc:SetPoint(self.options.desc_text_anchor or "bottom", iconFrame, self.options.desc_text_rel_anchor or "top", self.options.desc_text_x_offset or 0, self.options.desc_text_y_offset or 2)

			self.IconPool[self.NextIcon] = newIconFrame
			iconFrame = newIconFrame
		end

		iconFrame:ClearAllPoints()

		local anchor = self.options.anchor
		local anchorTo = self.NextIcon == 1 and self or self.IconPool[self.NextIcon - 1]
		local xPadding = self.NextIcon == 1 and self.options.left_padding or self.options.icon_padding or 1
		local growDirection = self.options.grow_direction

		if (growDirection == 1) then --grow to right
			if (self.NextIcon == 1) then
				PixelUtil.SetPoint(iconFrame, "left", anchorTo, "left", xPadding, 0)
			else
				PixelUtil.SetPoint(iconFrame, "left", anchorTo, "right", xPadding, 0)
			end

		elseif (growDirection == 2) then --grow to left
			if (self.NextIcon == 1) then
				PixelUtil.SetPoint(iconFrame, "right", anchorTo, "right", xPadding, 0)
			else
				PixelUtil.SetPoint(iconFrame, "right", anchorTo, "left", xPadding, 0)
			end

		end

		detailsFramework:SetFontColor(iconFrame.CountdownText, self.options.text_color)

		self.NextIcon = self.NextIcon + 1
		return iconFrame
	end,

	--adds only if not existing already in the cache
	AddSpecificIcon = function(self, identifierKey, spellId, borderColor, startTime, duration, forceTexture, descText, count, debuffType, caster, canStealOrPurge, spellName, isBuff)
		if (not identifierKey or identifierKey == "") then
			return
		end

		if (not self.AuraCache[identifierKey]) then
			local icon = self:SetIcon(spellId, borderColor, startTime, duration, forceTexture, descText, count, debuffType, caster, canStealOrPurge, spellName, isBuff or false)
			icon.identifierKey = identifierKey
			self.AuraCache[identifierKey] = true
		end
	end,

	SetIcon = function(self, spellId, borderColor, startTime, duration, forceTexture, descText, count, debuffType, caster, canStealOrPurge, spellName, isBuff, modRate)
		local actualSpellName, _, spellIcon = GetSpellInfo(spellId)

		if forceTexture then
			spellIcon = forceTexture
		end

		spellName = spellName or actualSpellName or "unknown_aura"
		modRate = modRate or 1

		if (spellIcon) then
			local iconFrame = self:GetIcon()
			iconFrame.Texture:SetTexture(spellIcon)
			iconFrame.Texture:SetTexCoord(unpack(self.options.texcoord))

			if (borderColor) then
				iconFrame:SetBackdropBorderColor(detailsFramework:ParseColors(borderColor))
			else
				iconFrame:SetBackdropBorderColor(0, 0, 0 ,0)
			end

			if (startTime) then
				CooldownFrame_Set(iconFrame.Cooldown, startTime, duration, true, true, modRate)

				if (self.options.show_text) then
					iconFrame.CountdownText:Show()

					local now = GetTime()

					iconFrame.timeRemaining = (startTime + duration - now) / modRate
					iconFrame.expirationTime = startTime + duration

					local formattedTime = (iconFrame.timeRemaining > 0) and self.options.decimal_timer and iconFrame.parentIconRow.FormatCooldownTimeDecimal(iconFrame.timeRemaining) or iconFrame.parentIconRow.FormatCooldownTime(iconFrame.timeRemaining) or ""
					iconFrame.CountdownText:SetText(formattedTime)

					iconFrame.CountdownText:SetPoint(self.options.text_anchor or "center", iconFrame, self.options.text_rel_anchor or "center", self.options.text_x_offset or 0, self.options.text_y_offset or 0)
					detailsFramework:SetFontSize(iconFrame.CountdownText, self.options.text_size)
					detailsFramework:SetFontFace (iconFrame.CountdownText, self.options.text_font)
					detailsFramework:SetFontOutline (iconFrame.CountdownText, self.options.text_outline)

					if self.options.on_tick_cooldown_update then
						iconFrame.lastUpdateCooldown = now
						iconFrame:SetScript("OnUpdate", self.OnIconTick)
					else
						iconFrame:SetScript("OnUpdate", nil)
					end

				else
					iconFrame:SetScript("OnUpdate", nil)
					iconFrame.CountdownText:Hide()
				end

				iconFrame.Cooldown:SetReverse(self.options.cooldown_reverse)
				iconFrame.Cooldown:SetDrawSwipe(self.options.cooldown_swipe_enabled)
				iconFrame.Cooldown:SetEdgeTexture(self.options.cooldown_edge_texture)
				iconFrame.Cooldown:SetHideCountdownNumbers(self.options.surpress_blizzard_cd_timer)
			else
				iconFrame.timeRemaining = nil
				iconFrame.expirationTime = nil
				iconFrame:SetScript("OnUpdate", nil)
				iconFrame.CountdownText:Hide()
			end

			if (descText and self.options.desc_text) then
				iconFrame.Desc:Show()
				iconFrame.Desc:SetText(descText.text)
				iconFrame.Desc:SetTextColor(detailsFramework:ParseColors(descText.text_color or self.options.desc_text_color))
				iconFrame.Desc:SetPoint(self.options.desc_text_anchor or "bottom", iconFrame, self.options.desc_text_rel_anchor or "top", self.options.desc_text_x_offset or 0, self.options.desc_text_y_offset or 2)
				detailsFramework:SetFontSize(iconFrame.Desc, descText.text_size or self.options.desc_text_size)
				detailsFramework:SetFontFace(iconFrame.Desc, self.options.desc_text_font)
				detailsFramework:SetFontOutline(iconFrame.Desc, self.options.desc_text_outline)
			else
				iconFrame.Desc:Hide()
			end

			if (count and count > 1 and self.options.stack_text) then
				iconFrame.StackText:Show()
				iconFrame.StackText:SetText(count)
				iconFrame.StackText:SetTextColor(detailsFramework:ParseColors(self.options.stack_text_color))
				iconFrame.StackText:SetPoint(self.options.stack_text_anchor or "center", iconFrame, self.options.stack_text_rel_anchor or "bottomright", self.options.stack_text_x_offset or 0, self.options.stack_text_y_offset or 0)
				detailsFramework:SetFontSize(iconFrame.StackText, self.options.stack_text_size)
				detailsFramework:SetFontFace(iconFrame.StackText, self.options.stack_text_font)
				detailsFramework:SetFontOutline(iconFrame.StackText, self.options.stack_text_outline)
			else
				iconFrame.StackText:Hide()
			end

			PixelUtil.SetSize(iconFrame, self.options.icon_width, self.options.icon_height)
			iconFrame:Show()

			--update the size of the frame
			self:SetWidth((self.options.left_padding * 2) + (self.options.icon_padding * (self.NextIcon-2)) + (self.options.icon_width * (self.NextIcon - 1)))
			self:SetHeight(self.options.icon_height + (self.options.top_padding * 2))

			--make information available
			iconFrame.spellId = spellId
			iconFrame.startTime = startTime
			iconFrame.duration = duration
			iconFrame.count = count
			iconFrame.debuffType = debuffType
			iconFrame.caster = caster
			iconFrame.canStealOrPurge = canStealOrPurge
			iconFrame.isBuff = isBuff
			iconFrame.spellName = spellName

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

	OnIconTick = function(self, deltaTime)
		local now = GetTime()
		if (self.lastUpdateCooldown + 0.05) <= now then
			self.timeRemaining = self.expirationTime - now
			if self.timeRemaining > 0 then
				if self.parentIconRow.options.decimal_timer then
					self.CountdownText:SetText(self.parentIconRow.FormatCooldownTimeDecimal(self.timeRemaining))
				else
					self.CountdownText:SetText(self.parentIconRow.FormatCooldownTime(self.timeRemaining))
				end
			else
				self.CountdownText:SetText("")
			end
			self.lastUpdateCooldown = now
		end
	end,

	FormatCooldownTime = function(formattedTime)
		if (formattedTime >= 3600) then
			formattedTime = math.floor(formattedTime / 3600) .. "h"

		elseif (formattedTime >= 60) then
			formattedTime = math.floor(formattedTime / 60) .. "m"

		else
			formattedTime = math.floor(formattedTime)
		end
		return formattedTime
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

	RemoveSpecificIcon = function(self, identifierKey)
		if (not identifierKey or identifierKey == "") then
			return
		end

		table.wipe(self.AuraCache)

		local iconPool = self.IconPool
		local countStillShown = 0

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
				countStillShown = countStillShown + 1
			end
		end

		self:AlignAuraIcons()
	end,

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

	AlignAuraIcons = function(self)
		local iconPool = self.IconPool
		local iconAmount = #iconPool
		local countStillShown = 0

		table.sort(iconPool, function(i1, i2) return i1:IsShown() and not i2:IsShown() end)

		if iconAmount == 0 then
			self:Hide()
		else
			--re-anchor not hidden
			for i = 1, iconAmount do
				local iconFrame = iconPool[i]
				local anchor = self.options.anchor
				local anchorTo = i == 1 and self or self.IconPool[i - 1]
				local xPadding = i == 1 and self.options.left_padding or self.options.icon_padding or 1
				local growDirection = self.options.grow_direction

				countStillShown = countStillShown + (iconFrame:IsShown() and 1 or 0)

				iconFrame:ClearAllPoints()
				if (growDirection == 1) then --grow to right
					if (i == 1) then
						PixelUtil.SetPoint(iconFrame, "left", anchorTo, "left", xPadding, 0)
					else
						PixelUtil.SetPoint(iconFrame, "left", anchorTo, "right", xPadding, 0)
					end
				elseif (growDirection == 2) then --grow to left
					if (i == 1) then
						PixelUtil.SetPoint(iconFrame, "right", anchorTo, "right", xPadding, 0)
					else
						PixelUtil.SetPoint(iconFrame, "right", anchorTo, "left", xPadding, 0)
					end
				end
			end
		end

		self.NextIcon = countStillShown + 1
	end,

	GetIconGrowDirection = function(self)
		local side = self.options.anchor.side

		if (side == 1) then
			return 1
		elseif (side == 2) then
			return 2
		elseif (side == 3) then
			return 1
		elseif (side == 4) then
			return 1
		elseif (side == 5) then
			return 2
		elseif (side == 6) then
			return 1
		elseif (side == 7) then
			return 2
		elseif (side == 8) then
			return 1
		elseif (side == 9) then
			return 1
		elseif (side == 10) then
			return 1
		elseif (side == 11) then
			return 2
		elseif (side == 12) then
			return 1
		elseif (side == 13) then
			return 1
		end
	end,

	OnOptionChanged = function(self, optionName)
		self:SetBackdropColor(unpack(self.options.backdrop_color))
		self:SetBackdropBorderColor(unpack(self.options.backdrop_border_color))
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
	surpress_blizzard_cd_timer = false,
	surpress_tulla_omni_cc = false,
	on_tick_cooldown_update = true,
	decimal_timer = false,
	cooldown_reverse = false,
	cooldown_swipe_enabled = true,
	cooldown_edge_texture = "Interface\\Cooldown\\edge",
}

function detailsFramework:CreateIconRow(parent, name, options)
	local newIconRowFrame = CreateFrame("frame", name, parent, "BackdropTemplate")
	newIconRowFrame.IconPool = {}
	newIconRowFrame.NextIcon = 1
	newIconRowFrame.AuraCache = {}

	detailsFramework:Mixin(newIconRowFrame, detailsFramework.IconMixin)
	detailsFramework:Mixin(newIconRowFrame, detailsFramework.OptionsFunctions)

	newIconRowFrame:BuildOptionsTable(default_icon_row_options, options)

	newIconRowFrame:SetSize(newIconRowFrame.options.icon_width, newIconRowFrame.options.icon_height + (newIconRowFrame.options.top_padding * 2))

	newIconRowFrame:SetBackdrop(newIconRowFrame.options.backdrop)
	newIconRowFrame:SetBackdropColor(unpack(newIconRowFrame.options.backdrop_color))
	newIconRowFrame:SetBackdropBorderColor(unpack(newIconRowFrame.options.backdrop_border_color))

	return newIconRowFrame
end