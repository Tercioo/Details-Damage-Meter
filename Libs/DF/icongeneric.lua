
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
---@field NextIcon number
---@field IconPool table<number, df_icongeneric> table which store the icons created for this iconrow

---@class df_iconrow_generic_options : table
---@field icon_width number? @The width of the icon.
---@field icon_height number? @The height of the icon.
---@field texcoord table? @The texture coordinates of the icon.
---@field show_text boolean? @Whether to show text on the icon.
---@field text_color table? @The color of the text.
---@field text_size number? @The size of the text.
---@field text_font string? @The font of the text.
---@field text_outline string? @The outline style of the text.
---@field text_anchor df_anchor? @The anchor point of the text.
---@field text_alpha_by_percent boolean? @Whether to change the alpha of the text by the percentage of the cooldown.
---@field desc_text boolean? @Whether to show description text.
---@field desc_text_color table? @The color of the description text.
---@field desc_text_size number? @The size of the description text.
---@field desc_text_font string? @The font of the description text.
---@field desc_text_outline string? @The outline style of the description text.
---@field desc_text_anchor string? @The anchor point of the description text.
---@field desc_text_rel_anchor string? @The relative anchor point of the description text.
---@field desc_text_x_offset number? @The x offset of the description text.
---@field desc_text_y_offset number? @The y offset of the description text.
---@field stack_text boolean? @Whether to show stack text.
---@field stack_text_color table? @The color of the stack text.
---@field stack_text_size number? @The size of the stack text.
---@field stack_text_font string? @The font of the stack text.
---@field stack_text_outline string? @The outline style of the stack text.
---@field stack_text_anchor string? @The anchor point of the stack text.
---@field stack_text_rel_anchor string? @The relative anchor point of the stack text.
---@field stack_text_x_offset number? @The x offset of the stack text.
---@field stack_text_y_offset number? @The y offset of the stack text.
---@field left_padding number? @The distance between the right and left sides.
---@field top_padding number? @The distance between the top and bottom sides.
---@field icon_padding number? @The distance between each icon.
---@field backdrop table? @The backdrop options.
---@field backdrop_color table? @The color of the backdrop.
---@field backdrop_border_color table? @The color of the backdrop border.
---@field anchor table? @The anchor options.
---@field grow_direction number? @The direction in which the icons grow.
---@field center_alignment boolean? @Whether to align the icons in the center.
---@field surpress_blizzard_cd_timer boolean? @Whether to suppress the Blizzard cooldown timer.
---@field surpress_tulla_omni_cc boolean? @Whether to suppress the Tulla OmniCC cooldown count.
---@field on_tick_cooldown_update boolean? @Whether to update cooldowns on every tick.
---@field cooldown_max_brightness number? @The maximum brightness of the cooldown, it is adjusted by the percent.
---@field decimal_timer boolean? @Whether to display the timer in decimal format.
---@field show_cooldown boolean? @Whether to show blizzard cooldown animation.
---@field cooldown_reverse boolean? @Whether to reverse the cooldown animation.
---@field cooldown_swipe_enabled boolean? @Whether to enable the cooldown swipe animation.
---@field cooldown_edge_texture string? @The texture for the cooldown edge.
---@field show_horizontal_swipe boolean? @Whether to show the horizontal swipe animation.
---@field swipe_alpha number? @The alpha value for the swipe animation.
---@field swipe_brightness number? @The brightness value for the swipe animation.
---@field swipe_progressive_color boolean? @Whether to use progressive color for the swipe animation. Start on Green and goes to Red, follows percent amount.
---@field swipe_color table? @When the color isn't progressive, this is the color of the swipe
---@field swipe_color_start number[]? @Whether to use yellow color for the swipe animation.
---@field swipe_color_end number[]? @Whether to use red color for the swipe animation.
---@field remove_on_finish boolean? @Whether to remove the icon when the cooldown finishes. Only usable if the icon has a identifier (from setting specific).
---@field first_icon_use_anchor boolean? @The anchor point for the first ico will use the anchor set in options.anchor.

---@class df_iconrow_generic : df_iconrow
---@field SetCooldown fun(self:df_iconrow_generic, iconFrame:df_icongeneric)
---@field OnIconTick fun(iconFrame:df_icongeneric)
---@field FormatCooldownTime fun(thisTime:number)
---@field FormatCooldownTimeDecimal fun(formattedTime:number)
---@field GetIconGrowDirection fun(self:df_iconrow_generic):number
---@field OnOptionChanged fun(self:df_iconrow_generic, optionName:string)
---@field CreateIcon fun(self:df_iconrow_generic, iconName:string)
---@field GetIcon fun(self:df_iconrow_generic)
---@field SetStacks fun(self:df_iconrow_generic, iconFrame:df_icongeneric, bIsShown:boolean, stacksAmount:number?)
---@field AddSpecificIcon fun(self:df_iconrow_generic, identifierKey:any, spellId:number, borderColor:table, startTime:number, duration:number, forceTexture:string, descText:string, count:number, debuffType:string, caster:string, canStealOrPurge:boolean, spellName:string, isBuff:boolean, modRate:number, iconSettings:table)
---@field AddSpecificIconWithTemplate fun(self:df_iconrow_generic, iconTemplateTable:table)
---@field IsIconShown fun(self:df_iconrow_generic, identifierKey:any)
---@field SetIcon fun(self:df_iconrow_generic, spellId:number, borderColor:table, startTime:number, duration:number, iconTexture:string, descText:string, count:number, debuffType:string, caster:string, canStealOrPurge:boolean, spellName:string, isBuff:boolean, modRate:number, iconSettings:table, expirationTime:number?)
---@field RemoveSpecificIcon fun(self:df_iconrow_generic, identifierKey:any)
---@field ClearIcons fun(self:df_iconrow_generic, resetBuffs:boolean?, resetDebuffs:boolean?)
---@field AlignAuraIcons fun(self:df_iconrow_generic)
---@field SetAuraWithIconTemplate fun(self:df_iconrow_generic, auraInfo:aurainfo, iconTemplateTable:table)
---@field IconPool table<number, df_icongeneric>
---@field NextIcon number
---@field AuraCache table<any, boolean>
---@field shownAmount number
---@field options table
---@field SetSpecificAuraWithIconTemplate fun(self:df_iconrow_generic, identifierKey:any, auraInfo:aurainfo, iconTemplateTable:table)

local unpack = unpack
local CreateFrame = CreateFrame
local PixelUtil = PixelUtil
local GetTime = GetTime
local Clamp = detailsFramework.Math.Clamp
local GetSpellInfo = GetSpellInfo or function(spellID) if not spellID then return nil end local si = C_Spell.GetSpellInfo(spellID) if si then return si.name, nil, si.iconID, si.castTime, si.minRange, si.maxRange, si.spellID, si.originalIconID end end

local spellIconCache = {}
local spellNameCache = {}
local emptyTable = {}
local white = {1, 1, 1, 1}

local sortIconByShownState = function(i1, i2)
	return i1:IsShown() and not i2:IsShown()
end

local iconFrameOnHideScript = function(self)
	if (self.cooldownLooper) then
		self.cooldownLooper:Cancel()
	end
end

local checkPointCallback = function(iconFrame)
	if (iconFrame.timeRemaining < 3) then

	end
	return true
end

detailsFramework.IconGenericMixin = {
	---create a new icon frame
	---@param self df_iconrow_generic the parent frame
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
        PixelUtil.SetPoint(newIcon.CooldownBrightnessTexture, "topleft", newIcon.Texture, "topleft", 0, 0)
        PixelUtil.SetPoint(newIcon.CooldownBrightnessTexture, "bottomright", newIcon.Texture, "bottomright", 0, 0)

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
		newIcon.CooldownTexture:SetTexture("Interface\\BUTTONS\\GreyscaleRamp64", "CLAMP", "CLAMP", "TRILINEAR")
        newIcon.CooldownTexture:SetHeight(2)
        newIcon.CooldownTexture:SetPoint("bottomleft", newIcon.Texture, "bottomleft", 0, 0)
        newIcon.CooldownTexture:SetPoint("bottomright", newIcon.Texture, "bottomright", 0, 0)
        newIcon.CooldownTexture:Hide()

		newIcon.CooldownEdge = newIcon:CreateTexture(self:GetName() .. "CooldownEdge", "overlay", nil, 7)

        newIcon.CountdownText = newIcon:CreateFontString(self:GetName() .. "CooldownText", "overlay", "GameFontNormal")
        newIcon.CountdownText:SetPoint("center", newIcon, "center", 0, 0)
        newIcon.CountdownText:Hide()

		newIcon.stacks = 0
		newIcon:SetScript("OnHide", iconFrameOnHideScript)

        local cooldownFrame = CreateFrame("cooldown", "$parentCooldownFrame", newIcon, "CooldownFrameTemplate, BackdropTemplate")
        cooldownFrame:SetAllPoints()
        cooldownFrame:EnableMouse(false)
        cooldownFrame:SetFrameLevel(newIcon:GetFrameLevel()+1)
		cooldownFrame.CountdownText = ({cooldownFrame:GetRegions()})[1]
        newIcon.Cooldown = cooldownFrame

		return newIcon
    end,

	---get an icon frame from the pool
	---@param self df_iconrow_generic the parent frame
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
	---@param self df_iconrow_generic the parent frame
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

	IsIconShown = function(self, identifierKey)
		if (not identifierKey or identifierKey == "") then
			return
		end
		if (self.AuraCache[identifierKey]) then
			return true
		end
	end,

	SetSpecificAuraWithIconTemplate = function(self, identifierKey, auraInfo, iconTemplateTable)
		if (not identifierKey or identifierKey == "") then
			return
		end

		if (not self.AuraCache[identifierKey]) then
			---@type df_icongeneric
			local iconFrame = self:SetAuraWithIconTemplate(auraInfo, iconTemplateTable)
			iconFrame.identifierKey = identifierKey
			self.AuraCache[identifierKey] = true
		end
	end,

	---set an icon frame with a template
	---@param self df_iconrow_generic the parent frame
	---@param auraInfo aurainfo
	---@param iconTemplateTable df_icontemplate
	SetAuraWithIconTemplate = function(self, auraInfo, iconTemplateTable)
		local startTime = auraInfo.expirationTime - auraInfo.duration

		---@type df_icongeneric
		return self:SetIcon(auraInfo.spellId, nil, startTime, auraInfo.duration, auraInfo.icon, nil, auraInfo.applications, auraInfo.dispelName, auraInfo.sourceUnit, auraInfo.isStealable, auraInfo.name, auraInfo.isHelpful, auraInfo.timeMod, iconTemplateTable, auraInfo.expirationTime)
	end,

	---set an icon frame with a template
	---@param self df_iconrow_generic the parent frame
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

		if (iconSettings.overrideTexture) then
			spellIcon = iconSettings.overrideTexture
		end

		if (spellIcon) then
			spellName = spellName or actualSpellName or "unknown_aura"
			modRate = modRate or 1

			---@type df_icongeneric
			local iconFrame = self:GetIcon()
			self.shownAmount = self.NextIcon - 1

			iconFrame.expirationTime = expirationTime

			local width = iconSettings.width or self.options.icon_width
			local height = iconSettings.height or self.options.icon_height or width

			--adjust the width and height by scale
			local scale = iconSettings.scale or 1
			width = width * scale
			height = height * scale

			PixelUtil.SetSize(iconFrame, width, height)

			--set the texture points to be all points minus one
			iconFrame.Texture:ClearAllPoints()
			PixelUtil.SetPoint(iconFrame.Texture, "topleft", iconFrame, "topleft", 1, -1)
			PixelUtil.SetPoint(iconFrame.Texture, "bottomright", iconFrame, "bottomright", -1, 1)

			iconFrame.textureWidth = math.max(iconFrame.Texture:GetWidth(), width)
			iconFrame.textureHeight = math.max(iconFrame.Texture:GetHeight(), height) --for some reason, GetHeight() was returning 0 on the first call

			--cache size
			iconFrame.width = width
			iconFrame.height = height

			iconFrame:Show()

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

				if (iconSettings.points) then
					iconFrame.Texture:ClearAllPoints()
					for i = 1, #iconSettings.points do
						local point = iconSettings.points[i]
						iconFrame.Texture:SetPoint(point[1], iconFrame, point[2], point[3], point[4])
					end
					iconFrame.Texture:SetSize(width, height)
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

			iconFrame:SetIgnoreParentAlpha(false)

			if (iconSettings.color) then
				local r, g, b, a = detailsFramework:ParseColors(iconSettings.color)
				iconFrame.Texture:SetVertexColor(r, g, b, a)
				--ignore the param alpha has the settings might have an alpha for it
				iconFrame:SetIgnoreParentAlpha(true)
			else
				iconFrame.Texture:SetVertexColor(1, 1, 1, 1)
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

			if (iconSettings.alpha) then
				iconFrame.Texture:SetAlpha(iconSettings.alpha)
			else
				iconFrame.Texture:SetAlpha(1)
			end

			--iconFrame.Texture:SetBlendMode("ADD")
			iconFrame.CooldownBrightnessTexture:SetTexture(iconFrame.Texture:GetTexture())
			do
				local left, top, c, bottom, right = iconFrame.Texture:GetTexCoord()
				iconFrame.CooldownBrightnessTexture:SetTexCoord(left, right, top, bottom)

				local coords = iconFrame.CooldownBrightnessTexture.cords
				if (coords) then
					coords[1] = left
					coords[2] = right
					coords[3] = top
					coords[4] = bottom
				else
					iconFrame.CooldownBrightnessTexture.cords = {left, right, top, bottom}
				end

				iconFrame.CooldownBrightnessTexture.top = top
				iconFrame.CooldownBrightnessTexture.bottom = bottom

				PixelUtil.SetPoint(iconFrame.CooldownBrightnessTexture, "bottomright", iconFrame.Texture, "bottomright", 0, 0)
			end

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

	---@param self df_iconrow_generic the parent frame
	---@param iconFrame df_icongeneric
	SetCooldown = function(self, iconFrame)
		if (iconFrame.cooldownLooper) then
			iconFrame.cooldownLooper:Cancel()
		end

		local options = iconFrame.options

		--iconFrame:SetScale(3) --debug

		if (options.show_horizontal_swipe) then
			iconFrame.CooldownEdge:Show()
			iconFrame.CooldownTexture:Show()
			iconFrame.CooldownBrightnessTexture:Show()

			iconFrame.CooldownEdge.texture = nil
			iconFrame.CooldownEdge:SetAlpha(0.834)

			PixelUtil.SetSize(iconFrame.CooldownEdge, iconFrame.CooldownTexture:GetWidth(), 2)
			PixelUtil.SetPoint(iconFrame.CooldownEdge, "topleft", iconFrame.CooldownTexture, "topleft", 0, 0)
			PixelUtil.SetPoint(iconFrame.CooldownEdge, "topright", iconFrame.CooldownTexture, "topright", 0, 0)
			PixelUtil.SetHeight(iconFrame.CooldownEdge, 8)

			iconFrame.CooldownEdge:SetTexture(options.swipe_white, "CLAMP", "CLAMP", "TRILINEAR")
			iconFrame.CooldownEdge.texture = options.swipe_white

			local swipe_brightness = options.swipe_brightness
			iconFrame.CooldownBrightnessTexture:SetAlpha(swipe_brightness)

			local swipe_darkness = options.swipe_alpha
			iconFrame.CooldownTexture:SetAlpha(swipe_darkness)
			iconFrame.CooldownTexture:SetVertexColor(unpack(options.swipe_color))
		else
			iconFrame.CooldownEdge:Hide()
			iconFrame.CooldownBrightnessTexture:Hide()
			iconFrame.CooldownTexture:Hide()
		end

		if (options.show_text) then
			detailsFramework:SetFontColor(iconFrame.CountdownText, self.options.text_color)
			detailsFramework:SetFontSize(iconFrame.CountdownText, self.options.text_size)
			detailsFramework:SetFontFace(iconFrame.CountdownText, self.options.text_font)
			detailsFramework:SetFontOutline(iconFrame.CountdownText, self.options.text_outline)
			detailsFramework:SetAnchor(iconFrame.CountdownText, self.options.text_anchor, iconFrame)
			iconFrame.CountdownText:Show()
			iconFrame.CountdownText:SetAlpha(1)
		else
			iconFrame.CountdownText:Hide()
		end

		if (options.show_cooldown) then
			iconFrame.Cooldown:Show()
			iconFrame.Cooldown:SetReverse(options.cooldown_reverse)
			iconFrame.Cooldown:SetDrawSwipe(options.cooldown_swipe_enabled)
			iconFrame.Cooldown:SetEdgeTexture(options.cooldown_edge_texture) --the yellow edge that follows the cooldown animation
			iconFrame.Cooldown:SetHideCountdownNumbers(options.surpress_blizzard_cd_timer)

			iconFrame.Cooldown:SetSwipeTexture([[Interface\Masks\SquareMask]], 0, 0, 0, 0.3)
			--iconFrame.Cooldown:SetSwipeColor(1, 1, 1, 1)
			--iconFrame.Cooldown:SetSwipeColor(0, 0, 0, 0.1)

			--iconFrame.Cooldown:SetDrawEdge(true) --the same shit as above
			--iconFrame.Cooldown:SetDrawSwipe(true)
			--iconFrame.Cooldown:SetDrawBling(true) --edge of the animation, a thin horizontal texture
			--iconFrame.Cooldown:SetEdgeScale(4) --edge of the animation, a thin horizontal texture

			if (not options.surpress_blizzard_cd_timer) then
				detailsFramework:SetFontColor(iconFrame.Cooldown.CountdownText, self.options.text_color)
				detailsFramework:SetFontSize(iconFrame.Cooldown.CountdownText, self.options.text_size)
				detailsFramework:SetFontFace(iconFrame.Cooldown.CountdownText, self.options.text_font)
				detailsFramework:SetFontOutline(iconFrame.Cooldown.CountdownText, self.options.text_outline)
			end
			iconFrame.Cooldown.noCooldownCount = options.surpress_tulla_omni_cc

			CooldownFrame_Set(iconFrame.Cooldown, iconFrame.startTime, iconFrame.duration, true, true, iconFrame.modRate)

			iconFrame.CooldownBrightnessTexture:Show()
		else
			iconFrame.Cooldown:Hide()
		end

		self.OnIconTick(iconFrame)

		local amountOfLoops = math.floor(iconFrame.duration / 0.25)
		local loopEndCallback = nil
		if (iconFrame.options.remove_on_finish) then
			--increase the amount of loops in one, so the last loop will remove the icon
			--otherwise it might finish
			amountOfLoops = amountOfLoops + 1
			local newLooper = detailsFramework.Schedules.NewLooper(0.25, self.OnIconTick, amountOfLoops, loopEndCallback, checkPointCallback, iconFrame)
			iconFrame.cooldownLooper = newLooper
		else
			local newLooper = detailsFramework.Schedules.NewLooper(0.25, self.OnIconTick, amountOfLoops, loopEndCallback, checkPointCallback, iconFrame)
			iconFrame.cooldownLooper = newLooper
		end
	end,

	---@param iconFrame df_icongeneric
	OnIconTick = function(iconFrame)
		local now = GetTime()
		--local percent = (now - iconFrame.startTime) / iconFrame.duration --no mod rate
		local percent = (((now - iconFrame.startTime) / (iconFrame.modRate or 1)) / (iconFrame.duration / (iconFrame.modRate or 1))) or 0
		local options = iconFrame.options
		percent = Saturate(percent)
		--percent = abs(percent - 1)

		iconFrame.timeRemaining = iconFrame.duration - (now - iconFrame.startTime)

		if (percent >= 1) then
			--time expired
			if (options.remove_on_finish) then
				iconFrame:GetParent():RemoveSpecificIcon(iconFrame.identifierKey)
				return
			else
				percent = 1
			end
		end

		if (options.show_horizontal_swipe) then
			local newHeight = math.min(iconFrame.textureHeight * percent, iconFrame.textureHeight)
			iconFrame.CooldownTexture:SetHeight(newHeight)

			PixelUtil.SetPoint(iconFrame.CooldownBrightnessTexture, "bottomright", iconFrame.Texture, "bottomright", 0, newHeight) --iconFrame.textureHeight -
			local left, right, top, bottom = unpack(iconFrame.CooldownBrightnessTexture.cords)
			local newBottomCord = Lerp(iconFrame.CooldownBrightnessTexture.top, iconFrame.CooldownBrightnessTexture.bottom, abs(percent - 1))
			iconFrame.CooldownBrightnessTexture:SetTexCoord(left, right, top, newBottomCord)

			--local newBrightness = Lerp(Saturate(options.cooldown_max_brightness-0.6), options.cooldown_max_brightness, percent)
			--iconFrame.CooldownBrightnessTexture:SetAlpha(newBrightness)

			if (options.swipe_progressive_color) then
				--interpolate from green to red
				--percent goes from 0 to 1, where zero is the start of the cooldown and 1 is the end
				if (options.swipe_color_start and options.swipe_color_end) then
					--use the first and second color
					local r1, g1, b1 = unpack(options.swipe_color_start)
					local r2, g2, b2 = unpack(options.swipe_color_end)
					local r, g, b = detailsFramework.Math.LerpLinearColor(percent, 1, r1, g1, b1, r2, g2, b2)
					iconFrame.CooldownEdge:SetVertexColor(r, g, b, 0.834)
				else
					--use a solid color
					iconFrame.CooldownEdge:SetVertexColor(unpack(options.swipe_color))
				end

				--iconFrame.CooldownEdge:SetVertexColor(percent, math.abs(percent-1), 0, 0.834)
				local alpha = Saturate(0.2 + percent)
				iconFrame.CooldownEdge:SetAlpha(alpha)
			else
				--use a solid color
				iconFrame.CooldownEdge:SetVertexColor(unpack(options.swipe_color))
			end
		end

		if (options.show_cooldown) then
			if (options.cooldown_max_brightness) then
				iconFrame.CooldownBrightnessTexture:SetAlpha(Lerp(0, options.cooldown_max_brightness, percent))
				local swipeAlpha = Saturate(Lerp(0, 1, percent))
				local exponentialCurve = 0.1 * math.exp(3.5 * swipeAlpha)
				exponentialCurve = Saturate(exponentialCurve)
				iconFrame.Cooldown:SetSwipeColor(0, 0, 0, exponentialCurve)
			end
		end

		--show the countdown text
		if (options.show_text) then
			iconFrame.CountdownText:SetText(iconFrame.parentIconRow.FormatCooldownTime((iconFrame.duration - (now - iconFrame.startTime)) / (iconFrame.modRate or 1)))
			if (options.text_alpha_by_percent) then
				iconFrame.CountdownText:SetAlpha(percent)
			end
		end
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

	---@param self df_iconrow_generic the parent frame
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

	---@param self df_iconrow_generic the parent frame
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

	---@param self df_iconrow_generic the parent frame
	AlignAuraIcons = function(self)
		local iconPool = self.IconPool
		local iconAmount = #iconPool
		local countStillShown = 0

		if iconAmount == 0 then
			self:Hide()
		else
			table.sort(iconPool, sortIconByShownState)

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
						if (self.options.first_icon_use_anchor) then
							detailsFramework:SetAnchor(iconFrame, self.options.anchor, self)
						else
							local attachSide = (bIsCenterAligned and "center") or (nWhichSide and not detailsFramework.SideIsCorner[nWhichSide] and "left") or "bottomleft"
							PixelUtil.SetPoint(iconFrame, attachSide, anchorTo, attachSide, 0, 0)
						end
					else
						PixelUtil.SetPoint(iconFrame, "left", anchorTo, "right", xPadding, 0)
					end

				elseif (growDirection == 2) then --grow to left
					if (bIsFirstIcon) then
						if (self.options.first_icon_use_anchor) then
							detailsFramework:SetAnchor(iconFrame, self.options.anchor, self)
						else
							local attachSide = (bIsCenterAligned and "center") or (nWhichSide and not detailsFramework.SideIsCorner[nWhichSide] and "right") or "bottomright"
							PixelUtil.SetPoint(iconFrame, attachSide, anchorTo, attachSide, 0, 0)
						end
					else
						PixelUtil.SetPoint(iconFrame, "right", anchorTo, "left", xPadding, 0)
					end
				end

				width = width + ((iconFrame.width or iconFrame:GetWidth())) + 1 --* iconFrame:GetScale() removed the getscale as now the scale are applied to the width and height
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

	---@param self df_iconrow_generic the parent frame
	GetIconGrowDirection = function(self)
		local side = self.options.anchor.side
		return detailsFramework.GrowDirectionBySide[side]
	end,

	---@param self df_iconrow_generic the parent frame
	OnOptionChanged = function(self, optionName)
		if (self.SetBackdropColor) then
			self:SetBackdropColor(unpack(self.options.backdrop_color))
			self:SetBackdropBorderColor(unpack(self.options.backdrop_border_color))
		end
	end,
}

---@type df_iconrow_generic_options
local default_iconrow_generic_options = {
	icon_width = 20,
	icon_height = 20,
	texcoord = {.1, .9, .1, .9},
	show_text = false,
	text_color = {1, 1, 1, 1},
	text_size = 12,
	text_font = "Arial Narrow",
	text_outline = "NONE",
	text_anchor = {side = 9, x = 0, y = 0},
	text_alpha_by_percent = false,
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

	show_cooldown = false,
	surpress_tulla_omni_cc = false,
	decimal_timer = false, --nop, not in use
	cooldown_reverse = false,
	cooldown_swipe_enabled = true,
	cooldown_edge_texture = "Interface\\Cooldown\\edge",
	cooldown_max_brightness = 0.7,
	surpress_blizzard_cd_timer = false,
	on_tick_cooldown_update = true, --nop, not in use

	show_horizontal_swipe = true,
	swipe_progressive_color = true,
	swipe_alpha = 0.5,
	swipe_brightness = 0.5,
	swipe_color = {0, 0, 0}, --this variable is having conflicts because it's in use by other things
	swipe_color_start = {0, 1, 0},
	swipe_color_end = {1, 0, 0},

	remove_on_finish = false,
	first_icon_use_anchor = false,
}



---@param parent frame
---@param name string?
---@param options table?
---@return df_iconrow_generic
function detailsFramework:CreateIconRowGeneric(parent, name, options)
	local newIconRowFrame = CreateFrame("frame", name, parent, "BackdropTemplate")
	newIconRowFrame.IconPool = {}
	newIconRowFrame.NextIcon = 1
	newIconRowFrame.AuraCache = {}
	newIconRowFrame.shownAmount = 0

	detailsFramework:Mixin(newIconRowFrame, detailsFramework.IconGenericMixin)
	detailsFramework:Mixin(newIconRowFrame, detailsFramework.OptionsFunctions)

	newIconRowFrame:BuildOptionsTable(default_iconrow_generic_options, options)

	newIconRowFrame:SetSize(1, 1)

	newIconRowFrame:SetBackdrop(newIconRowFrame.options.backdrop)
	newIconRowFrame:SetBackdropColor(unpack(newIconRowFrame.options.backdrop_color))
	newIconRowFrame:SetBackdropBorderColor(unpack(newIconRowFrame.options.backdrop_border_color))

	return newIconRowFrame
end