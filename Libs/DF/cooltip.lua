
local DF = _G ["DetailsFramework"]
if (not DF or not DetailsFrameworkCanLoad) then
	return
end

local SharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0")
local _

--lua locals
local ipairs = ipairs
local wipe = table.wipe
local insert = table.insert
local max = math.max

--api locals
local PixelUtil = PixelUtil or DFPixelUtil
local version = 3

local CONST_MENU_TYPE_MAINMENU = "main"
local CONST_MENU_TYPE_SUBMENU = "sec"
local CONST_COOLTIP_TYPE_MENU = "menu"
local CONST_COOLTIP_TYPE_TOOLTIP = "tooltip"

function DF:CreateCoolTip()
	--if a cooltip is already created with a higher version
	if (_G.GameCooltip2 and _G.GameCooltip2.version >= version) then
		return
	end

	local defaultBackdrop = {bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1,
	tile = true, tileSize = 16, insets = {left = 0, right = 0, top = 0, bottom = 0}}
	local defaultBackdropColor = {0.1215, 0.1176, 0.1294, 0.8000}
	local defaultBackdropBorderColor = {0.05, 0.05, 0.05, 1}

	--initialize
	local CoolTip = {
		version = version,
		debug = false,
	}
	_G.GameCooltip2 = CoolTip
	_G.GameCooltip = CoolTip --back compatibility

	function CoolTip:PrintDebug(...)
		if (CoolTip.debug) then
			print("|cFFFFFF00Cooltip|r:", ...)
			print(debugstack())
		end
	end

	function CoolTip:SetDebug(bDebugState)
		CoolTip.debug = bDebugState
	end

	--containers
	CoolTip.LeftTextTable = {}
	CoolTip.LeftTextTableSub = {}
	CoolTip.RightTextTable = {}
	CoolTip.RightTextTableSub = {}
	CoolTip.LeftIconTable = {}
	CoolTip.LeftIconTableSub = {}
	CoolTip.RightIconTable = {}
	CoolTip.RightIconTableSub = {}
	CoolTip.Banner = {false, false, false}
	CoolTip.TopIconTableSub = {}
	CoolTip.StatusBarTable = {}
	CoolTip.StatusBarTableSub = {}
	CoolTip.WallpaperTable = {}
	CoolTip.WallpaperTableSub = {}
	CoolTip.PopupFrameTable = {}

	--menus
	CoolTip.FunctionsTableMain = {}
	CoolTip.FunctionsTableSub = {}
	CoolTip.ParametersTableMain = {}
	CoolTip.ParametersTableSub = {}
	CoolTip.FixedValue = nil
	CoolTip.SelectedIndexMain = nil
	CoolTip.SelectedIndexSec = {}

	--options table
	CoolTip.OptionsList = {
		["RightTextMargin"] = true,
		["IconSize"] = true,
		["HeightAnchorMod"] = true,
		["WidthAnchorMod"] = true,
		["MinWidth"] = true,
		["FixedWidth"] = true,
		["FixedHeight"] = true,
		["FixedWidthSub"] = true,
		["FixedHeightSub"] = true,
		["AlignAsBlizzTooltip"] = true,
		["AlignAsBlizzTooltipFrameHeightOffset"] = true,
		["IgnoreSubMenu"] = true,
		["IgnoreButtonAutoHeight"] = true,
		["TextHeightMod"] = true,
		["ButtonHeightMod"] = true,
		["ButtonHeightModSub"] = true,
		["YSpacingMod"] = true,
		["YSpacingModSub"] = true,
		["ButtonsYMod"] = true,
		["ButtonsYModSub"] = true,
		["IconHeightMod"] = true,
		["StatusBarHeightMod"] = true,
		["StatusBarTexture"] = true,
		["TextSize"] = true,
		["TextFont"] = true,
		["TextColor"] = true,
		["TextColorRight"] = true,
		["TextShadow"] = true,
		["LeftTextWidth"] = true,
		["RightTextWidth"] = true,
		["LeftTextHeight"] = true,
		["RightTextHeight"] = true,
		["NoFade"] = true,
		["MyAnchor"] = true,
		["Anchor"] = true,
		["RelativeAnchor"] = true,
		["NoLastSelectedBar"] = true,
		["SubMenuIsTooltip"] = true,
		["LeftBorderSize"] = true,
		["RightBorderSize"] = true,
		["HeighMod"] = true,
		["HeighModSub"] = true,
		["IconBlendMode"] = true,
		["IconBlendModeHover"] = true,
		["SubFollowButton"] = true,
		["IgnoreArrows"] = true,
		["SelectedTopAnchorMod"] = true,
		["SelectedBottomAnchorMod"] = true,
		["SelectedLeftAnchorMod"] = true,
		["SelectedRightAnchorMod"] = true,
	}

	CoolTip.AliasList = {
		["VerticalOffset"] = "ButtonsYMod",
		["VerticalPadding"] = "YSpacingMod",
		["LineHeightSizeOffset"] = "ButtonHeightMod",
		["FrameHeightSizeOffset"] = "HeighMod",
	}

	CoolTip.OptionsTable = {}

	--amount of lines current on shown
	CoolTip.Indexes = 0
	--amount of lines current on shown
	CoolTip.IndexesSub = {}
	--amount of lines current on shown
	CoolTip.HaveSubMenu = false
	--amount of lines current on shown on sub menu
	CoolTip.SubIndexes = 0
	--1 tooltip 2 tooltip with bars 3 menu 4 menu + submenus
	CoolTip.Type = 1
	--frame to anchor
	CoolTip.Host = nil
	--last size
	CoolTip.LastSize = 0
	CoolTip.LastIndex = 0
	CoolTip.internalYMod = 0
	CoolTip.internalYMod = 0
	CoolTip.overlapChecked = false

	--defaults
	CoolTip.default_height = 20
	CoolTip.default_text_size = 10.5
	CoolTip.default_text_font = "GameFontHighlight"
	CoolTip.selectedAnchor = {}
	CoolTip.selectedAnchor.left = 2
	CoolTip.selectedAnchor.right = 0
	CoolTip.selectedAnchor.top = 0
	CoolTip.selectedAnchor.bottom = 0

	CoolTip.defaultFont = DF:GetBestFontForLanguage()

	--create frames, self is frame1 or frame2
	local createTooltipFrames = function(self)
		self:SetSize(500, 500)
		self:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
		self:SetBackdrop(defaultBackdrop)
		self:SetBackdropColor(DF:ParseColors(defaultBackdropColor))
		self:SetBackdropBorderColor(DF:ParseColors(defaultBackdropBorderColor))

		if (not self.frameBackgroundTexture) then
			self.frameBackgroundTexture = self:CreateTexture("$parent_FrameBackgroundTexture", "BACKGROUND", nil, 2)
			self.frameBackgroundTexture:SetColorTexture(0, 0, 0, 0)
			self.frameBackgroundTexture:SetAllPoints()
		end

		if (not self.frameWallpaper) then
			self.frameWallpaper = self:CreateTexture("$parent_FrameWallPaper", "BACKGROUND", nil, 4)
			self.frameWallpaper:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
			self.frameWallpaper:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
		end

		if (not self.selectedTop) then
			self.selectedTop = self:CreateTexture("$parent_SelectedTop", "ARTWORK")
			self.selectedTop:SetColorTexture(.5, .5, .5, .75)
			self.selectedTop:SetHeight(3)
		end

		if (not self.selectedBottom) then
			self.selectedBottom = self:CreateTexture("$parent_SelectedBottom", "ARTWORK")
			self.selectedBottom:SetColorTexture(.5, .5, .5, .75)
			self.selectedBottom:SetHeight(3)
		end

		if (not self.selectedMiddle) then
			self.selectedMiddle = self:CreateTexture("$parent_Selected", "ARTWORK")
			self.selectedMiddle:SetColorTexture(.5, .5, .5, .75)
			self.selectedMiddle:SetPoint("TOPLEFT", self.selectedTop, "BOTTOMLEFT")
			self.selectedMiddle:SetPoint("BOTTOMRIGHT", self.selectedBottom, "TOPRIGHT")
		end

		if (not self.upperImage2) then
			self.upperImage2 = self:CreateTexture("$parent_UpperImage2", "ARTWORK")
			self.upperImage2:SetPoint("CENTER", self, "CENTER", 0, -3)
			self.upperImage2:SetPoint("BOTTOM", self, "TOP", 0, -3)
			self.upperImage2:Hide()
		end

		if (not self.upperImage) then
			self.upperImage = self:CreateTexture("$parent_UpperImage", "OVERLAY")
			self.upperImage:SetPoint("CENTER", self, "CENTER", 0, -3)
			self.upperImage:SetPoint("BOTTOM", self, "TOP", 0, -3)
			self.upperImage:Hide()
		end

		if (not self.upperImageText) then
			self.upperImageText = self:CreateFontString("$parent_UpperImageText", "OVERLAY", "GameTooltipHeaderText")
			self.upperImageText:SetJustifyH("LEFT")
			self.upperImageText:SetPoint("LEFT", self.upperImage, "RIGHT", 5, 0)
			DF:SetFontSize(self.upperImageText, 13)
		end

		if (not self.upperImageText2) then
			self.upperImageText2 = self:CreateFontString("$parent_UpperImageText2", "OVERLAY", "GameTooltipHeaderText")
			self.upperImageText2:SetJustifyH("LEFT")
			self.upperImageText2:SetPoint("BOTTOMRIGHT", self, "LEFT", 0, 3)
			DF:SetFontSize(self.upperImageText2, 13)
		end

		if (not self.titleIcon) then
			self.titleIcon = self:CreateTexture("$parent_TitleIcon", "OVERLAY")
			self.titleIcon:SetTexture("Interface\\Challenges\\challenges-main")
			self.titleIcon:SetTexCoord(0.1521484375, 0.563671875, 0.160859375, 0.234375)
			self.titleIcon:SetPoint("CENTER", self, "CENTER")
			self.titleIcon:SetPoint("BOTTOM", self, "TOP", 0, -22)
			self.titleIcon:Hide()
		end

		if (not self.titleText) then
			self.titleText = self:CreateFontString("$parent_TitleText", "OVERLAY", "GameFontHighlightSmall")
			self.titleText:SetJustifyH("LEFT")
			DF:SetFontSize(self.titleText, 10)
			self.titleText:SetPoint("CENTER", self.titleIcon, "CENTER", 0, 6)
		end
	end

	--> main frame
		local frame1 = GameCooltipFrame1
		if (not GameCooltipFrame1) then
			frame1 = CreateFrame("Frame", "GameCooltipFrame1", UIParent, "BackdropTemplate")
		end

		DF.table.addunique(UISpecialFrames, "GameCooltipFrame1")

		if (not frame1.FlashAnimation) then
			DF:CreateFlashAnimation(frame1)
		end

		createTooltipFrames(frame1)

	--> secondary frame
		local frame2 = GameCooltipFrame2
		if (not GameCooltipFrame2) then
			frame2 = CreateFrame("Frame", "GameCooltipFrame2", UIParent, "BackdropTemplate")
		end

		frame2:SetClampedToScreen(true)
		DF.table.addunique(UISpecialFrames, "GameCooltipFrame2")
		createTooltipFrames(frame2)
		frame2:SetPoint("bottomleft", frame1, "bottomright", 4, 0)

		if (not frame2.FlashAnimation) then
			DF:CreateFlashAnimation(frame2)
		end

	CoolTip.frame1 = frame1
	CoolTip.frame2 = frame2
	DF:FadeFrame(frame1, 0)
	DF:FadeFrame(frame2, 0)
	frame1.Lines = {}
	frame2.Lines = {}

----------------------------------------------------------------------
	--Title Function 
----------------------------------------------------------------------

	function CoolTip:SetTitle(frameId, text)
		if (frameId == 1) then
			CoolTip.title1 = true
			CoolTip.title_text = text
		end
	end

	function CoolTip:SetTitleAnchor(frameId, anchorPoint, ...)
		anchorPoint = string.lower(anchorPoint)
		if (frameId == 1) then
			self.frame1.titleIcon:ClearAllPoints()
			self.frame1.titleText:ClearAllPoints()

			if (anchorPoint == "left") then
				self.frame1.titleIcon:SetPoint("left", frame1, "left", ...)
				self.frame1.titleText:SetPoint("left", frame1.titleIcon, "right")

			elseif (anchorPoint == "center") then
				self.frame1.titleIcon:SetPoint("center", frame1, "center")
				self.frame1.titleIcon:SetPoint("bottom", frame1, "top")
				self.frame1.titleText:SetPoint("left", frame1.titleIcon, "right")
				self.frame1.titleText:SetText("TESTE")

				self.frame1.titleText:Show()
				self.frame1.titleIcon:Show()

			elseif (anchorPoint == "right") then
				self.frame1.titleIcon:SetPoint("right", frame1, "right", ...)
				self.frame1.titleText:SetPoint("right", frame1.titleIcon, "left")

			end

		elseif (frameId == 2) then
			self.frame2.titleIcon:ClearAllPoints()
			self.frame2.titleText:ClearAllPoints()

			if (anchorPoint == "left") then
				self.frame2.titleIcon:SetPoint("left", frame2, "left", ...)
				self.frame2.titleText:SetPoint("left", frame2.titleIcon, "right")

			elseif (anchorPoint == "center") then
				self.frame2.titleIcon:SetPoint("center", frame2, "center", ...)
				self.frame2.titleText:SetPoint("left", frame2.titleIcon, "right")

			elseif (anchorPoint == "right") then
				self.frame2.titleIcon:SetPoint("right", frame2, "right", ...)
				self.frame2.titleText:SetPoint("right", frame2.titleIcon, "left")
			end
		end
	end

----------------------------------------------------------------------
	--Button Hide and Show Functions
----------------------------------------------------------------------
	local elapsedTime = 0
	CoolTip.mouseOver = false
	CoolTip.buttonClicked = false

	frame1:SetScript("OnEnter", function(self)
		--is cooltip a menu?
		if (CoolTip.Type ~= 1 and CoolTip.Type ~= 2) then
			CoolTip.active = true
			CoolTip.mouseOver = true
			CoolTip.hadInteractions = true

			self:SetScript("OnUpdate", nil)
			DF:FadeFrame(self, 0)

			if (CoolTip.sub_menus) then
				DF:FadeFrame(frame2, 0)
			end
		end
	end)

	frame2:SetScript("OnEnter", function(self)
		if (CoolTip.OptionsTable.SubMenuIsTooltip) then
			return CoolTip:Close()
		end

		if (CoolTip.Type ~= 1 and CoolTip.Type ~= 2) then
			CoolTip.active = true
			CoolTip.mouseOver = true
			CoolTip.hadInteractions = true

			self:SetScript("OnUpdate", nil)
			DF:FadeFrame(self, 0)
			DF:FadeFrame(frame1, 0)
		end
	end)

	local OnLeaveUpdateFrame1 = function(self, deltaTime)
		elapsedTime = elapsedTime + deltaTime
		if (elapsedTime > 0.7) then
			if (not CoolTip.active and not CoolTip.buttonClicked and self == CoolTip.Host) then
				DF:FadeFrame(self, 1)
				DF:FadeFrame(frame2, 1)

			elseif (not CoolTip.active) then
				DF:FadeFrame(self, 1)
				DF:FadeFrame(frame2, 1)
			end

			self:SetScript("OnUpdate", nil)
			frame2:SetScript("OnUpdate", nil)
		end
	end

	frame1:SetScript("OnLeave", function(self)
		if (CoolTip.Type ~= 1 and CoolTip.Type ~= 2) then
			CoolTip.active = false
			CoolTip.mouseOver = false
			elapsedTime = 0
			self:SetScript("OnUpdate", OnLeaveUpdateFrame1)
		else
			CoolTip.active = false
			CoolTip.mouseOver = false
			elapsedTime = 0
			self:SetScript("OnUpdate", OnLeaveUpdateFrame1)
		end
	end)

	local OnLeaveUpdateFrame2 = function(self, deltaTime)
		elapsedTime = elapsedTime + deltaTime
		if (elapsedTime > 0.7) then
			if (not CoolTip.active and not CoolTip.buttonClicked and self == CoolTip.Host) then
				DF:FadeFrame(self, 1)
				DF:FadeFrame(frame2, 1)

			elseif (not CoolTip.active) then
				DF:FadeFrame(self, 1)
				DF:FadeFrame(frame2, 1)
			end

			self:SetScript("OnUpdate", nil)
			frame1:SetScript("OnUpdate", nil)
		end
	end

	frame2:SetScript("OnLeave", function(self)
		if (CoolTip.Type ~= 1 and CoolTip.Type ~= 2) then
			CoolTip.active = false
			CoolTip.mouseOver = false
			elapsedTime = 0
			self:SetScript("OnUpdate", OnLeaveUpdateFrame2)
		else
			CoolTip.active = false
			CoolTip.mouseOver = false
			elapsedTime = 0
			self:SetScript("OnUpdate", OnLeaveUpdateFrame2)
		end
	end)

	frame1:SetScript("OnHide", function(self)
		CoolTip.active = false
		CoolTip.buttonClicked = false
		CoolTip.mouseOver = false
		--reset parent and  strata
		frame1:SetParent(UIParent)
		frame2:SetParent(UIParent)
		frame1:SetFrameStrata("TOOLTIP")
		frame2:SetFrameStrata("TOOLTIP")
	end)

----------------------------------------------------------------------
	--Button Creation Functions
----------------------------------------------------------------------
	--self is the new button created
	local createButtonWidgets = function(self)
		self:SetSize(1, 20)

		--status bar
		self.statusbar = CreateFrame("StatusBar", "$Parent_StatusBar", self)
		self.statusbar:SetPoint("LEFT", self, "LEFT", 10, 0)
		self.statusbar:SetPoint("RIGHT", self, "RIGHT", -10, 0)
		self.statusbar:SetPoint("TOP", self, "TOP", 0, 0)
		self.statusbar:SetPoint("BOTTOM", self, "BOTTOM", 0, 0)
		self.statusbar:SetHeight(20)

		local statusbar = self.statusbar

		statusbar.texture = statusbar:CreateTexture("$parent_Texture", "BACKGROUND")
		statusbar.texture:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar")
		statusbar.texture:SetSize(300, 14)
		statusbar:SetStatusBarTexture (statusbar.texture)
		statusbar:SetMinMaxValues (0, 100)

		statusbar.spark = statusbar:CreateTexture("$parent_Spark", "BACKGROUND")
		statusbar.spark:Hide()
		statusbar.spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
		statusbar.spark:SetBlendMode("ADD")
		statusbar.spark:SetSize(12, 24)
		statusbar.spark:SetPoint("LEFT", statusbar, "RIGHT", -20, -1)

		statusbar.background = statusbar:CreateTexture("$parent_Background", "ARTWORK")
		statusbar.background:Hide()
		statusbar.background:SetTexture("Interface\\FriendsFrame\\UI-FriendsFrame-HighlightBar")
		statusbar.background:SetPoint("LEFT", statusbar, "LEFT", -6, 0)
		statusbar.background:SetPoint("RIGHT", statusbar, "RIGHT", 6, 0)
		statusbar.background:SetPoint("TOP", statusbar, "TOP", 0, 0)
		statusbar.background:SetPoint("BOTTOM", statusbar, "BOTTOM", 0, 0)

		self.background = statusbar.background

		statusbar.leftIcon = statusbar:CreateTexture("$parent_LeftIcon", "OVERLAY")
		statusbar.leftIcon:SetSize(16, 16)
		statusbar.leftIcon:SetPoint("LEFT", statusbar, "LEFT", 0, 0)

		statusbar.rightIcon = statusbar:CreateTexture("$parent_RightIcon", "OVERLAY")
		statusbar.rightIcon:SetSize(16, 16)
		statusbar.rightIcon:SetPoint("RIGHT", statusbar, "RIGHT", 0, 0)

		statusbar.spark2 = statusbar:CreateTexture("$parent_Spark2", "OVERLAY")
		statusbar.spark2:SetSize(32, 32)
		statusbar.spark2:SetPoint("LEFT", statusbar, "RIGHT", -17, -1)
		statusbar.spark2:SetBlendMode("ADD")
		statusbar.spark2:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
		statusbar.spark2:Hide()

		statusbar.subMenuArrow = statusbar:CreateTexture("$parent_SubMenuArrow", "OVERLAY")
		statusbar.subMenuArrow:SetSize(12, 12)
		statusbar.subMenuArrow:SetPoint("RIGHT", statusbar, "RIGHT", 3, 0)
		statusbar.subMenuArrow:SetBlendMode("ADD")
		statusbar.subMenuArrow:SetTexture("Interface\\CHATFRAME\\ChatFrameExpandArrow")
		statusbar.subMenuArrow:Hide()

		statusbar.leftText = statusbar:CreateFontString("$parent_LeftText", "OVERLAY", "GameTooltipHeaderText")
		statusbar.leftText:SetJustifyH("LEFT")
		statusbar.leftText:SetPoint("LEFT", statusbar.leftIcon, "RIGHT", 3, 0)
		DF:SetFontSize(statusbar.leftText, 10)

		statusbar.rightText = statusbar:CreateFontString("$parent_TextRight", "OVERLAY", "GameTooltipHeaderText")
		statusbar.rightText:SetJustifyH("RIGHT")
		statusbar.rightText:SetPoint("RIGHT", statusbar.rightIcon, "LEFT", -3, 0)
		DF:SetFontSize(statusbar.leftText, 10)

		--background status bar
		self.statusbar2 = CreateFrame("StatusBar", "$Parent_StatusBarBackground", self)
		self.statusbar2:SetPoint("LEFT", self.statusbar, "LEFT")
		self.statusbar2:SetPoint("RIGHT", self.statusbar, "RIGHT")
		self.statusbar2:SetPoint("TOP", self.statusbar, "TOP")
		self.statusbar2:SetPoint("BOTTOM", self.statusbar, "BOTTOM")

		local statusbar2 = self.statusbar2
		statusbar2.texture = statusbar2:CreateTexture("$parent_Texture", "BACKGROUND")
		statusbar2.texture:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar")
		statusbar2.texture:SetSize(300, 14)
		statusbar2:SetStatusBarTexture (statusbar2.texture)
		statusbar2:SetMinMaxValues (0, 100)

		--on load
		self:RegisterForClicks("LeftButtonDown")
		self.leftIcon = self.statusbar.leftIcon
		self.rightIcon = self.statusbar.rightIcon
		self.texture = self.statusbar.texture
		self.spark = self.statusbar.spark
		self.spark2 = self.statusbar.spark2
		self.leftText = self.statusbar.leftText
		self.rightText = self.statusbar.rightText
		self.statusbar:SetFrameLevel(self:GetFrameLevel()+2)
		self.statusbar2:SetFrameLevel(self.statusbar:GetFrameLevel()-1)
		self.statusbar2:SetValue(0)

		--scripts
		self:SetScript("OnMouseDown", GameCooltipButtonMouseDown)
		self:SetScript("OnMouseUp", GameCooltipButtonMouseUp)
	end

	function GameCooltipButtonMouseDown(button)
		local heightMod = CoolTip.OptionsTable.TextHeightMod or 0
		button.leftText:SetPoint("center", button.leftIcon, "center", 0, 0 + heightMod)
		button.leftText:SetPoint("left", button.leftIcon, "right", 4, -1 + heightMod)
	end

	function GameCooltipButtonMouseUp(button)
		local heightMod = CoolTip.OptionsTable.TextHeightMod or 0
		button.leftText:SetPoint("center", button.leftIcon, "center", 0, 0 + heightMod)
		button.leftText:SetPoint("left", button.leftIcon, "right", 3, 0 + heightMod)
	end

	function CoolTip:CreateButton(index, frame, name)
		local newNutton = CreateFrame("Button", name, frame)
		createButtonWidgets (newNutton)
		frame.Lines[index] = newNutton
		return newNutton
	end

	local OnEnterUpdateButton = function(self, deltaTime)
		elapsedTime = elapsedTime + deltaTime
		if (elapsedTime > 0.001) then
			--search key: ~onenterupdatemain
			CoolTip:ShowSub(self.index)
			CoolTip.lastButtonInteracted = self.index
			self:SetScript("OnUpdate", nil)
		end
	end

	local OnLeaveUpdateButton = function(self, deltaTime)
		elapsedTime = elapsedTime + deltaTime
		if (elapsedTime > 0.7) then
			if (not CoolTip.active and not CoolTip.buttonClicked) then
				DF:FadeFrame(frame1, 1)
				DF:FadeFrame(frame2, 1)
			elseif (not CoolTip.active) then
				DF:FadeFrame(frame1, 1)
				DF:FadeFrame(frame2, 1)
			end
			frame1:SetScript("OnUpdate", nil)
		end
	end

	local OnEnterMainButton = function(self)
		if (CoolTip.Type ~= 1 and CoolTip.Type ~= 2 and not self.isDiv) then
			CoolTip.active = true
			CoolTip.mouseOver = true
			CoolTip.hadInteractions = true

			frame1:SetScript("OnUpdate", nil)
			frame2:SetScript("OnUpdate", nil)

			self.background:Show()

			if (CoolTip.OptionsTable.IconBlendModeHover) then
				self.leftIcon:SetBlendMode(CoolTip.OptionsTable.IconBlendModeHover)
			else
				self.leftIcon:SetBlendMode("BLEND")
			end

			if (CoolTip.PopupFrameTable[self.index]) then
				local onEnter, onLeave, param1, param2 = unpack(CoolTip.PopupFrameTable[self.index])
				if (onEnter) then
					xpcall(onEnter, geterrorhandler(), frame1, param1, param2)
				end

			elseif (CoolTip.IndexesSub[self.index] and CoolTip.IndexesSub[self.index] > 0) then
				if (CoolTip.OptionsTable.SubMenuIsTooltip) then
					CoolTip:ShowSub(self.index)
					self.index = self.ID
				else
					if (CoolTip.lastButtonInteracted) then
						CoolTip:ShowSub(CoolTip.lastButtonInteracted)
					else
						CoolTip:ShowSub(self.index)
					end
					elapsedTime = 0
					self.index = self.ID
					self:SetScript("OnUpdate", OnEnterUpdateButton)
				end
			else
				--hide second frame
				DF:FadeFrame(frame2, 1)
				CoolTip.lastButtonInteracted = nil
			end
		else
			CoolTip.mouseOver = true
			CoolTip.hadInteractions = true
		end
	end

	local OnLeaveMainButton = function(self)
		if (CoolTip.Type ~= 1 and CoolTip.Type ~= 2 and not self.isDiv) then
			CoolTip.active = false
			CoolTip.mouseOver = false
			self:SetScript("OnUpdate", nil)

			self.background:Hide()

			if (CoolTip.OptionsTable.IconBlendMode) then
				self.leftIcon:SetBlendMode(CoolTip.OptionsTable.IconBlendMode)
				self.rightIcon:SetBlendMode(CoolTip.OptionsTable.IconBlendMode)
			else
				self.leftIcon:SetBlendMode("BLEND")
				self.rightIcon:SetBlendMode("BLEND")
			end

			if (CoolTip.PopupFrameTable[self.index]) then
				local onEnter, onLeave, param1, param2 = unpack(CoolTip.PopupFrameTable[self.index])
				if (onLeave) then
					xpcall(onLeave, geterrorhandler(), frame1, param1, param2)
				end
			end

			elapsedTime = 0
			frame1:SetScript("OnUpdate", OnLeaveUpdateButton)
		else
			CoolTip.active = false
			elapsedTime = 0
			frame1:SetScript("OnUpdate", OnLeaveUpdateButton)
			CoolTip.mouseOver = false
		end
	end

	--serach key: ~onenter
	function CoolTip:CreateMainFrameButton(i)
		local newButton = CoolTip:CreateButton(i, frame1, "GameCooltipMainButton" .. i)
		newButton.ID = i
		newButton:SetScript("OnEnter", OnEnterMainButton)
		newButton:SetScript("OnLeave", OnLeaveMainButton)
		return newButton
	end

	--buttons for the secondary frame
	local OnLeaveUpdateButtonSec = function(self, deltaTime)
		elapsedTime = elapsedTime + deltaTime
		if (elapsedTime > 0.7) then
			if (not CoolTip.active and not CoolTip.buttonClicked) then
				DF:FadeFrame(frame1, 1)
				DF:FadeFrame(frame2, 1)
			elseif (not CoolTip.active) then
				DF:FadeFrame(frame1, 1)
				DF:FadeFrame(frame2, 1)
			end
			frame2:SetScript("OnUpdate", nil)
		end
	end

	local OnEnterSecondaryButton = function(self)
		if (CoolTip.OptionsTable.SubMenuIsTooltip) then
			return CoolTip:Close()
		end

		if (CoolTip.Type ~= 1 and CoolTip.Type ~= 2 and not self.isDiv) then
			CoolTip.active = true
			CoolTip.mouseOver = true
			CoolTip.hadInteractions = true

			self.background:Show()

			if (CoolTip.OptionsTable.IconBlendModeHover) then
				self.leftIcon:SetBlendMode(CoolTip.OptionsTable.IconBlendModeHover)
			else
				self.leftIcon:SetBlendMode("BLEND")
			end

			frame1:SetScript("OnUpdate", nil)
			frame2:SetScript("OnUpdate", nil)

			DF:FadeFrame(frame1, 0)
			DF:FadeFrame(frame2, 0)
		else
			CoolTip.mouseOver = true
			CoolTip.hadInteractions = true
		end
	end

	local OnLeaveSecondaryButton = function(self)
		if (CoolTip.Type ~= 1 and CoolTip.Type ~= 2) then
			CoolTip.active = false
			CoolTip.mouseOver = false
			self.background:Hide()

			if (CoolTip.OptionsTable.IconBlendMode) then
				self.leftIcon:SetBlendMode(CoolTip.OptionsTable.IconBlendMode)
				self.rightIcon:SetBlendMode(CoolTip.OptionsTable.IconBlendMode)
			else
				self.leftIcon:SetBlendMode("BLEND")
				self.rightIcon:SetBlendMode("BLEND")
			end

			elapsedTime = 0
			frame2:SetScript("OnUpdate", OnLeaveUpdateButtonSec)
		else
			CoolTip.active = false
			CoolTip.mouseOver = false
			elapsedTime = 0
			frame2:SetScript("OnUpdate", OnLeaveUpdateButtonSec)
		end
	end

	function CoolTip:CreateButtonOnSecondFrame(i)
		local newButton = CoolTip:CreateButton(i, frame2, "GameCooltipSecButton" .. i)
		newButton.ID = i
		newButton:SetScript("OnEnter", OnEnterSecondaryButton)
		newButton:SetScript("OnLeave", OnLeaveSecondaryButton)
		return newButton
	end

----------------------------------------------------------------------
	--Button Click Functions
----------------------------------------------------------------------
	CoolTip.selectedAnchor.left = 4
	CoolTip.selectedAnchor.right = -4
	CoolTip.selectedAnchor.top = 0
	CoolTip.selectedAnchor.bottom = 0

	function CoolTip:HideSelectedTexture(frame)
		frame.selectedTop:Hide()
		frame.selectedBottom:Hide()
		frame.selectedMiddle:Hide()
	end

	function CoolTip:ShowSelectedTexture(frame)
		frame.selectedTop:Show()
		frame.selectedBottom:Show()
		frame.selectedMiddle:Show()
	end

	function CoolTip:SetSelectedAnchor(frame, button)
		local left = CoolTip.selectedAnchor.left + (CoolTip.OptionsTable.SelectedLeftAnchorMod or 0)
		local right = CoolTip.selectedAnchor.right + (CoolTip.OptionsTable.SelectedRightAnchorMod or 0)

		local top = CoolTip.selectedAnchor.top + (CoolTip.OptionsTable.SelectedTopAnchorMod or 0)
		local bottom = CoolTip.selectedAnchor.bottom + (CoolTip.OptionsTable.SelectedBottomAnchorMod or 0)

		frame.selectedTop:ClearAllPoints()
		frame.selectedBottom:ClearAllPoints()

		frame.selectedTop:SetPoint("topleft", button, "topleft", left+1, top)
		frame.selectedTop:SetPoint("topright", button, "topright", right-1, top)
		frame.selectedBottom:SetPoint("bottomleft", button, "bottomleft", left+1, bottom)
		frame.selectedBottom:SetPoint("bottomright", button, "bottomright", right-1, bottom)

		CoolTip:ShowSelectedTexture(frame)
	end

	local OnClickFunctionMainButton = function(self, button)
		if (CoolTip.IndexesSub[self.index] and CoolTip.IndexesSub[self.index] > 0) then
			CoolTip:ShowSub(self.index)
			CoolTip.lastButtonInteracted = self.index
		end

		CoolTip.buttonClicked = true
		CoolTip:SetSelectedAnchor(frame1, self)

		if (not CoolTip.OptionsTable.NoLastSelectedBar) then
			CoolTip:ShowSelectedTexture(frame1)
		end
		CoolTip.SelectedIndexMain = self.index

		if (CoolTip.FunctionsTableMain[self.index]) then
			local parameterTable = CoolTip.ParametersTableMain[self.index]
			local func = CoolTip.FunctionsTableMain[self.index]
			local okay, errortext = pcall(func, CoolTip.Host, CoolTip.FixedValue, parameterTable[1], parameterTable[2], parameterTable[3], button)
			if (not okay) then
				print ("Cooltip OnClick Error:", errortext)
			end
		end
	end

	local OnClickFunctionSecondaryButton = function(self, button)
		CoolTip.buttonClicked = true
		CoolTip:SetSelectedAnchor(frame2, self)

		if (CoolTip.FunctionsTableSub[self.mainIndex] and CoolTip.FunctionsTableSub[self.mainIndex][self.index]) then
			local parameterTable = CoolTip.ParametersTableSub[self.mainIndex][self.index]
			local func = CoolTip.FunctionsTableSub[self.mainIndex][self.index]
			local okay, errortext = pcall(func, CoolTip.Host, CoolTip.FixedValue, parameterTable[1], parameterTable[2], parameterTable[3], button)
			if (not okay) then
				print("Cooltip OnClick Error:", errortext)
			end
		end

		CoolTip:SetSelectedAnchor(frame1, frame1.Lines[self.mainIndex])

		if (not CoolTip.OptionsTable.NoLastSelectedBar) then
			CoolTip:ShowSelectedTexture(frame1)
		end

		CoolTip.SelectedIndexMain = self.mainIndex
		CoolTip.SelectedIndexSec[self.mainIndex] = self.index
	end

	function CoolTip:TextAndIcon(index, frame, menuButton, leftTextSettings, rightTextSettings, leftIconSettings, rightIconSettings, isSecondFrame)
		--reset width
		menuButton.leftText:SetWidth(0)
		menuButton.leftText:SetHeight(0)
		menuButton.rightText:SetWidth(0)
		menuButton.rightText:SetHeight(0)
		menuButton.rightText:SetPoint("right", menuButton.rightIcon, "left", CoolTip.OptionsTable.RightTextMargin or -3, 0)

		--set text
		if (leftTextSettings) then
			menuButton.leftText:SetText(leftTextSettings[1])
			local r, g, b, a = leftTextSettings[2], leftTextSettings[3], leftTextSettings[4], leftTextSettings[5]

			if (r == 0 and g == 0 and b == 0 and a == 0) then
				if (CoolTip.OptionsTable.TextColor) then
					r, g, b, a = DF:ParseColors(CoolTip.OptionsTable.TextColor)
					DF:SetFontColor(menuButton.leftText, r, g, b, a)
				else
					menuButton.leftText:SetTextColor(1, 1, 1, 1)
				end
			else
				DF:SetFontColor(menuButton.leftText, r, g, b, a)
			end

			if (CoolTip.OptionsTable.TextSize and not leftTextSettings[6]) then
				DF:SetFontSize(menuButton.leftText, CoolTip.OptionsTable.TextSize)
			end

			if (CoolTip.OptionsTable.LeftTextWidth) then
				menuButton.leftText:SetWidth(CoolTip.OptionsTable.LeftTextWidth)
			else
				menuButton.leftText:SetWidth(0)
			end

			if (CoolTip.OptionsTable.LeftTextHeight) then
				menuButton.leftText:SetHeight(CoolTip.OptionsTable.LeftTextHeight)
			else
				menuButton.leftText:SetHeight(0)
			end

			if (CoolTip.OptionsTable.TextFont and not leftTextSettings[7]) then --font
				if (_G[CoolTip.OptionsTable.TextFont]) then
					menuButton.leftText:SetFontObject(_G.GameFontRed or CoolTip.OptionsTable.TextFont)
				else
					local font = SharedMedia:Fetch("font", CoolTip.OptionsTable.TextFont)
					local _, size, flags = menuButton.leftText:GetFont()
					flags = leftTextSettings[8] or CoolTip.OptionsTable.TextShadow or nil
					size = leftTextSettings[6] or CoolTip.OptionsTable.TextSize or size
					menuButton.leftText:SetFont(font, size, flags)
				end

			elseif (leftTextSettings[7]) then
				if (_G[leftTextSettings[7]]) then
					menuButton.leftText:SetFontObject(leftTextSettings[7])
					local fontFace, fontSize, fontFlags = menuButton.leftText:GetFont()
					fontFlags = leftTextSettings[8] or CoolTip.OptionsTable.TextShadow or nil
					fontSize = leftTextSettings[6] or CoolTip.OptionsTable.TextSize or fontSize
					menuButton.leftText:SetFont(fontFace, fontSize, fontFlags)
				else
					local font = SharedMedia:Fetch("font", leftTextSettings[7])
					local fontFace, fontSize, fontFlags = menuButton.leftText:GetFont()
					--fontFace = font or fontFace
					fontFlags = leftTextSettings[8] or CoolTip.OptionsTable.TextShadow or nil
					fontSize = leftTextSettings[6] or CoolTip.OptionsTable.TextSize or fontSize
					menuButton.leftText:SetFont(fontFace, fontSize, fontFlags)
				end
			else
				menuButton.leftText:SetFont(CoolTip.defaultFont, leftTextSettings[6] or CoolTip.OptionsTable.TextSize or 10, leftTextSettings[8] or CoolTip.OptionsTable.TextShadow)
			end

			local heightMod = CoolTip.OptionsTable.TextHeightMod or 0				
			menuButton.leftText:SetPoint("center", menuButton.leftIcon, "center", 0, 0 + heightMod)
			menuButton.leftText:SetPoint("left", menuButton.leftIcon, "right", 3, 0 + heightMod)
		else
			menuButton.leftText:SetText("")
		end

		if (rightTextSettings) then
			menuButton.rightText:SetText(rightTextSettings[1])
			local r, g, b, a = rightTextSettings[2], rightTextSettings[3], rightTextSettings[4], rightTextSettings[5]

			if (r == 0 and g == 0 and b == 0 and a == 0) then
				if (CoolTip.OptionsTable.TextColorRight) then
					r, g, b, a = DF:ParseColors(CoolTip.OptionsTable.TextColorRight)
					DF:SetFontColor(menuButton.rightText, r, g, b, a)
				elseif (CoolTip.OptionsTable.TextColor) then
					r, g, b, a = DF:ParseColors(CoolTip.OptionsTable.TextColor)
					DF:SetFontColor(menuButton.rightText, r, g, b, a)
				else
					menuButton.rightText:SetTextColor(1, 1, 1, 1)
				end
			else
				DF:SetFontColor(menuButton.rightText, r, g, b, a)
			end

			if (CoolTip.OptionsTable.TextSize and not rightTextSettings[6]) then
				DF:SetFontSize(menuButton.rightText, CoolTip.OptionsTable.TextSize)
			end

			if (CoolTip.OptionsTable.RightTextWidth) then
				menuButton.rightText:SetWidth(CoolTip.OptionsTable.RightTextWidth)
			else
				menuButton.rightText:SetWidth(0)
			end

			if (CoolTip.OptionsTable.TextFont and not rightTextSettings[7]) then
				if (_G[CoolTip.OptionsTable.TextFont]) then
					menuButton.rightText:SetFontObject(CoolTip.OptionsTable.TextFont)
				else
					local fontFace = SharedMedia:Fetch("font", CoolTip.OptionsTable.TextFont)
					local _, fontSize, fontFlags = menuButton.rightText:GetFont()
					fontFlags = rightTextSettings[8] or CoolTip.OptionsTable.TextShadow or nil
					fontSize = rightTextSettings[6] or CoolTip.OptionsTable.TextSize or fontSize
					menuButton.rightText:SetFont(fontFace, fontSize, fontFlags)
				end

			elseif (rightTextSettings[7]) then
				if (_G[rightTextSettings[7]]) then
					menuButton.rightText:SetFontObject(rightTextSettings[7])
					local fontFace, fontSize, fontFlags = menuButton.rightText:GetFont()
					fontFlags = rightTextSettings[8] or CoolTip.OptionsTable.TextShadow or nil
					fontSize = rightTextSettings[6] or CoolTip.OptionsTable.TextSize or fontSize
					menuButton.rightText:SetFont(fontFace, fontSize, fontFlags)
				else
					local font = SharedMedia:Fetch("font", rightTextSettings[7])
					local fontFace, fontSize, fontFlags = menuButton.rightText:GetFont()
					fontFlags = rightTextSettings[8] or CoolTip.OptionsTable.TextShadow or nil
					fontSize = rightTextSettings[6] or CoolTip.OptionsTable.TextSize or fontSize
					menuButton.rightText:SetFont(fontFace, fontSize, fontFlags)
				end
			else
				menuButton.rightText:SetFont(CoolTip.defaultFont, rightTextSettings[6] or CoolTip.OptionsTable.TextSize or 10, rightTextSettings[8] or CoolTip.OptionsTable.TextShadow)
			end
		else
			menuButton.rightText:SetText("")
		end

		--left icon
		if (leftIconSettings and leftIconSettings[1]) then
			menuButton.leftIcon:SetTexture(leftIconSettings[1])
			menuButton.leftIcon:SetWidth(leftIconSettings[2])
			menuButton.leftIcon:SetHeight(leftIconSettings[3])
			menuButton.leftIcon:SetTexCoord(leftIconSettings[4], leftIconSettings[5], leftIconSettings[6], leftIconSettings[7])

			local colorRed, colorGreen, colorBlue, colorAlpha = DF:ParseColors(leftIconSettings[8])
			menuButton.leftIcon:SetVertexColor(colorRed, colorGreen, colorBlue, colorAlpha)

			if (CoolTip.OptionsTable.IconBlendMode) then
				menuButton.leftIcon:SetBlendMode(CoolTip.OptionsTable.IconBlendMode)
			else
				menuButton.leftIcon:SetBlendMode("BLEND")
			end

			menuButton.leftIcon:SetDesaturated(leftIconSettings[9])
		else
			menuButton.leftIcon:SetTexture("")
			menuButton.leftIcon:SetWidth(1)
			menuButton.leftIcon:SetHeight(1)
		end

		--right icon
		if (rightIconSettings and rightIconSettings[1]) then
			menuButton.rightIcon:SetTexture(rightIconSettings[1])
			menuButton.rightIcon:SetWidth(rightIconSettings[2])
			menuButton.rightIcon:SetHeight(rightIconSettings[3])
			menuButton.rightIcon:SetTexCoord(rightIconSettings[4], rightIconSettings[5], rightIconSettings[6], rightIconSettings[7])

			local colorRed, colorGreen, colorBlue, colorAlpha = DF:ParseColors(rightIconSettings[8])
			menuButton.rightIcon:SetVertexColor(colorRed, colorGreen, colorBlue, colorAlpha)

			if (CoolTip.OptionsTable.IconBlendMode) then
				menuButton.rightIcon:SetBlendMode(CoolTip.OptionsTable.IconBlendMode)
			else
				menuButton.rightIcon:SetBlendMode("BLEND")
			end

			menuButton.rightIcon:SetDesaturated(rightIconSettings[9])
		else
			menuButton.rightIcon:SetTexture("")
			menuButton.rightIcon:SetWidth(1)
			menuButton.rightIcon:SetHeight(1)
		end

		--overwrite icon size
		if (CoolTip.OptionsTable.IconSize) then
			menuButton.leftIcon:SetWidth(CoolTip.OptionsTable.IconSize)
			menuButton.leftIcon:SetHeight(CoolTip.OptionsTable.IconSize)
			menuButton.rightIcon:SetWidth(CoolTip.OptionsTable.IconSize)
			menuButton.rightIcon:SetHeight(CoolTip.OptionsTable.IconSize)
		end

		menuButton.leftText:SetHeight(0)
		menuButton.rightText:SetHeight(0)

		if (CoolTip.Type == 2) then
			CoolTip:LeftTextSpace(menuButton)
		end
		if (CoolTip.OptionsTable.LeftTextHeight) then
			menuButton.leftText:SetHeight(CoolTip.OptionsTable.LeftTextHeight)
		end
		if (CoolTip.OptionsTable.RightTextHeight) then
			menuButton.rightText:SetHeight(CoolTip.OptionsTable.RightTextHeight)
		end

		--string length
		if (not isSecondFrame) then --main frame
			if (not CoolTip.OptionsTable.FixedWidth) then
				if (CoolTip.Type == 1 or CoolTip.Type == 2) then
					local stringWidth = menuButton.leftText:GetStringWidth() + menuButton.rightText:GetStringWidth() + menuButton.leftIcon:GetWidth() + menuButton.rightIcon:GetWidth() + 10
					if (stringWidth > frame.w) then
						frame.w = stringWidth
					end
				end
			else
				menuButton.leftText:SetWidth(CoolTip.OptionsTable.FixedWidth - menuButton.leftIcon:GetWidth() - menuButton.rightText:GetStringWidth() - menuButton.rightIcon:GetWidth() - 22)
			end
		else
			if (not CoolTip.OptionsTable.FixedWidthSub) then
				if (CoolTip.Type == 1 or CoolTip.Type == 2) then
					local stringWidth = menuButton.leftText:GetStringWidth() + menuButton.rightText:GetStringWidth() + menuButton.leftIcon:GetWidth() + menuButton.rightIcon:GetWidth()
					if (stringWidth > frame.w) then
						frame.w = stringWidth
					end
				end
			else
				menuButton.leftText:SetWidth(CoolTip.OptionsTable.FixedWidthSub - menuButton.leftIcon:GetWidth() - 12)
			end
		end

		local height = max(menuButton.leftIcon:GetHeight(), menuButton.rightIcon:GetHeight(), menuButton.leftText:GetStringHeight(), menuButton.rightText:GetStringHeight())
		if (height > frame.hHeight) then
			frame.hHeight = height
		end
	end

	function CoolTip:RefreshSpark(menuButton)
		menuButton.spark:ClearAllPoints()
		menuButton.spark:SetPoint("LEFT", menuButton.statusbar, "LEFT", (menuButton.statusbar:GetValue() * (menuButton.statusbar:GetWidth() / 100)) - 5, 0)
		menuButton.spark2:ClearAllPoints()
		menuButton.spark2:SetPoint("left", menuButton.statusbar, "left", menuButton.statusbar:GetValue() * (menuButton.statusbar:GetWidth()/100) - 16, 0)
	end

	function CoolTip:StatusBar(menuButton, statusBarSettings)
		if (statusBarSettings) then
			menuButton.statusbar:SetValue(statusBarSettings[1])
			menuButton.statusbar:SetStatusBarColor (statusBarSettings[2], statusBarSettings[3], statusBarSettings[4], statusBarSettings[5])
			menuButton.statusbar:SetHeight(20 + (CoolTip.OptionsTable.StatusBarHeightMod or 0))

			menuButton.spark2:Hide()
			if (statusBarSettings[6]) then
				menuButton.spark:Show()
			else
				menuButton.spark:Hide()
			end

			if (statusBarSettings[7]) then
				menuButton.statusbar2:SetValue(statusBarSettings[7].value)
				menuButton.statusbar2.texture:SetTexture(statusBarSettings[7].texture or [[Interface\RaidFrame\Raid-Bar-Hp-Fill]])
				if (statusBarSettings[7].specialSpark) then
					menuButton.spark2:Show()
				end
				if (statusBarSettings[7].color) then
					local colorRed, colorGreen, colorBlue, colorAlpha = DF:ParseColors(statusBarSettings[7].color)
					menuButton.statusbar2:SetStatusBarColor (colorRed, colorGreen, colorBlue, colorAlpha)
				else
					menuButton.statusbar2:SetStatusBarColor (1, 1, 1, 1)
				end
			else
				menuButton.statusbar2:SetValue(0)
				menuButton.spark2:Hide()
			end

			if (statusBarSettings[8]) then
				local texture = SharedMedia:Fetch("statusbar", statusBarSettings[8], true)
				if (texture) then
					menuButton.statusbar.texture:SetTexture(texture)
				else
					menuButton.statusbar.texture:SetTexture(statusBarSettings[8])
				end
			elseif (CoolTip.OptionsTable.StatusBarTexture) then
				local texture = SharedMedia:Fetch("statusbar", CoolTip.OptionsTable.StatusBarTexture, true)
				if (texture) then
					menuButton.statusbar.texture:SetTexture(texture)
				else
					menuButton.statusbar.texture:SetTexture(CoolTip.OptionsTable.StatusBarTexture)
				end
			else
				menuButton.statusbar.texture:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar")
			end
		else
			menuButton.statusbar:SetValue(0)
			menuButton.statusbar2:SetValue(0)
			menuButton.spark:Hide()
			menuButton.spark2:Hide()
		end

		if (CoolTip.OptionsTable.LeftBorderSize) then
			menuButton.statusbar:SetPoint("left", menuButton, "left", 10 + CoolTip.OptionsTable.LeftBorderSize, 0)
		else
			menuButton.statusbar:SetPoint("left", menuButton, "left", 10, 0)
		end

		if (CoolTip.OptionsTable.RightBorderSize) then
			menuButton.statusbar:SetPoint("right", menuButton, "right", CoolTip.OptionsTable.RightBorderSize + (- 10), 0)
		else
			menuButton.statusbar:SetPoint("right", menuButton, "right", -10, 0)
		end
	end

	function CoolTip:SetupMainButton(menuButton, index)
		menuButton.index = index
		--setup texts and icons
		CoolTip:TextAndIcon(index, frame1, menuButton, CoolTip.LeftTextTable[index], CoolTip.RightTextTable[index], CoolTip.LeftIconTable[index], CoolTip.RightIconTable[index])
		--setup statusbar
		CoolTip:StatusBar(menuButton, CoolTip.StatusBarTable[index])
		--click
		menuButton:RegisterForClicks("LeftButtonDown")

		--string length
		if (not CoolTip.OptionsTable.FixedWidth) then
			local stringWidth = menuButton.leftText:GetStringWidth() + menuButton.rightText:GetStringWidth() + menuButton.leftIcon:GetWidth() + menuButton.rightIcon:GetWidth()
			if (stringWidth > frame1.w) then
				frame1.w = stringWidth
			end
		end

		--register click function
		menuButton:SetScript("OnClick", OnClickFunctionMainButton)
		menuButton:Show()
	end

	function CoolTip:SetupButtonOnSecondFrame(menuButton, index, mainMenuIndex)
		menuButton.index = index
		menuButton.mainIndex = mainMenuIndex

		--setup texts and icons
		CoolTip:TextAndIcon(index, frame2, menuButton, CoolTip.LeftTextTableSub[mainMenuIndex] and CoolTip.LeftTextTableSub[mainMenuIndex][index],
		CoolTip.RightTextTableSub[mainMenuIndex] and CoolTip.RightTextTableSub[mainMenuIndex][index],
		CoolTip.LeftIconTableSub[mainMenuIndex] and CoolTip.LeftIconTableSub[mainMenuIndex][index],
		CoolTip.RightIconTableSub[mainMenuIndex] and CoolTip.RightIconTableSub[mainMenuIndex][index], true)

		--setup statusbar
		CoolTip:StatusBar(menuButton, CoolTip.StatusBarTableSub[mainMenuIndex] and CoolTip.StatusBarTableSub[mainMenuIndex][index])

		--click
		menuButton:RegisterForClicks("LeftButtonDown")

		menuButton:ClearAllPoints()
		menuButton:SetPoint("center", frame2, "center")
		menuButton:SetPoint("top", frame2, "top", 0, (((index-1) * 20) * -1) -3)
		menuButton:SetPoint("left", frame2, "left", -4, 0)
		menuButton:SetPoint("right", frame2, "right", 4, 0)

		DF:FadeFrame(menuButton, 0)

		--string length
		local stringWidth = menuButton.leftText:GetStringWidth() + menuButton.rightText:GetStringWidth() + menuButton.leftIcon:GetWidth() + menuButton.rightIcon:GetWidth()
		if (stringWidth > frame2.w) then
			frame2.w = stringWidth
		end

		menuButton:SetScript("OnClick", OnClickFunctionSecondaryButton)
		menuButton:Show()
		return true
	end

	------------------------------------------------------------------------------------------------------------------

	function CoolTip:SetupWallpaper(wallpaperTable, wallpaper)
		local texture = wallpaperTable[1]
		if (DF:IsHtmlColor(texture) or type(texture) == "table") then
			local color = texture
			local r, g, b, a = DF:ParseColors(color)
			wallpaper:SetColorTexture(r, g, b, a)
		else
			wallpaper:SetTexture(texture)
		end

		wallpaper:SetTexCoord(wallpaperTable[2], wallpaperTable[3], wallpaperTable[4], wallpaperTable[5])

		local color = wallpaperTable[6]
		if (color) then
			local r, g, b, a = DF:ParseColors(color)
			wallpaper:SetVertexColor(r, g, b, a)
		else
			wallpaper:SetVertexColor(1, 1, 1, 1)
		end

		if (wallpaperTable[7]) then
			wallpaper:SetDesaturated(true)
		else
			wallpaper:SetDesaturated(false)
		end

		wallpaper:Show()
	end

	------------------------------------------------------------------------------------------------------------------

	function CoolTip:ShowSub(index)
		if (CoolTip.OptionsTable.IgnoreSubMenu) then
			DF:FadeFrame(frame2, 1)
			return
		end

		frame2:SetHeight(6)
		local amountIndexes = CoolTip.IndexesSub[index]
		if (not amountIndexes) then
			--sub menu called but sub menu indexes is nil
			return
		end

		if (CoolTip.OptionsTable.FixedWidthSub) then
			frame2:SetWidth(CoolTip.OptionsTable.FixedWidthSub)
		end

		frame2.h = CoolTip.IndexesSub[index] * 20
		frame2.hHeight = 0
		frame2.w = 0

		local isTooltip = CoolTip.OptionsTable.SubMenuIsTooltip
		if (isTooltip) then
			frame2:EnableMouse(false)
		else
			frame2:EnableMouse(true)
		end

		for i = 1, CoolTip.IndexesSub[index] do
			local button = frame2.Lines[i]
			if (not button) then
				button = CoolTip:CreateButtonOnSecondFrame(i)
			end
			CoolTip:SetupButtonOnSecondFrame(button, i, index)

			if (isTooltip) then
				button:EnableMouse(false)
			else
				button:EnableMouse(true)
			end
		end

		local selected = CoolTip.SelectedIndexSec[index]
		if (selected) then
			CoolTip:SetSelectedAnchor(frame2, frame2.Lines[selected])
			if (not CoolTip.OptionsTable.NoLastSelectedBar) then
				CoolTip:ShowSelectedTexture(frame2)
			end
		else
			CoolTip:HideSelectedTexture(frame2)
		end

		for i = CoolTip.IndexesSub[index] + 1, #frame2.Lines do
			DF:FadeFrame(frame2.Lines[i], 1)
		end

		local spacing = 0
		if (CoolTip.OptionsTable.YSpacingModSub) then
			spacing = CoolTip.OptionsTable.YSpacingModSub
		end

		--normalize height of all rows
		for i = 1, CoolTip.IndexesSub[index] do
			local menuButton = frame2.Lines[i]

			if (menuButton.leftText:GetText() == "$div") then
				menuButton:SetHeight(4)

				--points
				menuButton:ClearAllPoints()
				menuButton:SetPoint("center", frame2, "center")
				menuButton:SetPoint("left", frame2, "left", -4, 0)
				menuButton:SetPoint("right", frame2, "right", 4, 0)

				menuButton.rightText:SetText("")

				local divisorOffsetTop = tonumber(CoolTip.RightTextTableSub[index][i][2])
				if (not divisorOffsetTop) then
					divisorOffsetTop = 0
				end
				local divisorOffsetBottom = tonumber(CoolTip.RightTextTableSub[index][i][3])
				if (not divisorOffsetBottom) then
					divisorOffsetBottom = 0
				end

				menuButton:SetPoint("top", frame2, "top", 0, ( ( (i-1) * frame2.hHeight) * -1) - 4 + (CoolTip.OptionsTable.ButtonsYModSub or 0) + spacing + (2 + (divisorOffsetTop or 0)))

				if (CoolTip.OptionsTable.YSpacingModSub) then
					spacing = spacing + CoolTip.OptionsTable.YSpacingModSub
				end

				spacing = spacing + 17 + (divisorOffsetBottom or 0)

				menuButton.leftText:SetText("")
				menuButton.isDiv = true

				if (not menuButton.divbar) then
					CoolTip:CreateDivBar(menuButton)
				else
					menuButton.divbar:Show()
				end

				menuButton.divbar:SetPoint("left", menuButton, "left", frame1:GetWidth() * 0.10, 0)
				menuButton.divbar:SetPoint("right", menuButton, "right", -frame1:GetWidth() * 0.10, 0)

			else
				menuButton:SetHeight(frame2.hHeight + (CoolTip.OptionsTable.ButtonHeightModSub or 0))

				--points
				menuButton:ClearAllPoints()
				menuButton:SetPoint("center", frame2, "center")
				menuButton:SetPoint("top", frame2, "top", 0, ( ( (i-1) * frame2.hHeight) * -1) - 4 + (CoolTip.OptionsTable.ButtonsYModSub or 0) + spacing)

				if (CoolTip.OptionsTable.YSpacingModSub) then
					spacing = spacing + CoolTip.OptionsTable.YSpacingModSub
				end

				menuButton:SetPoint("left", frame2, "left", -4, 0)
				menuButton:SetPoint("right", frame2, "right", 4, 0)

				if (menuButton.divbar) then
					menuButton.divbar:Hide()
					menuButton.isDiv = false
				end
			end
		end

		local mod = CoolTip.OptionsTable.HeighModSub or 0
		frame2:SetHeight((frame2.hHeight * CoolTip.IndexesSub[index]) + 12 + (-spacing) + mod)

		if (CoolTip.TopIconTableSub[index]) then
			local upperImageTable = CoolTip.TopIconTableSub[index]
			frame2.upperImage:SetTexture(upperImageTable[1])
			frame2.upperImage:SetWidth(upperImageTable[2])
			frame2.upperImage:SetHeight(upperImageTable[3])
			frame2.upperImage:SetTexCoord(upperImageTable[4], upperImageTable[5], upperImageTable[6], upperImageTable[7])
			frame2.upperImage:Show()
		else
			frame2.upperImage:Hide()
		end

		if (CoolTip.WallpaperTableSub[index]) then
			CoolTip:SetupWallpaper(CoolTip.WallpaperTableSub[index], frame2.frameWallpaper)
		else
			frame2.frameWallpaper:Hide()
		end

		if (not CoolTip.OptionsTable.FixedWidthSub) then
			frame2:SetWidth(frame2.w + 44)
		end

		DF:FadeFrame(frame2, 0)
		CoolTip:CheckOverlap()

		if (CoolTip.OptionsTable.SubFollowButton and not CoolTip.frame2_IsOnLeftside) then
			local button = frame1.Lines[index]
			frame2:ClearAllPoints()
			frame2:SetPoint("left", button, "right", 4, 0)

		elseif (CoolTip.OptionsTable.SubFollowButton and CoolTip.frame2_IsOnLeftside) then
			local button = frame1.Lines[index]
			frame2:ClearAllPoints()
			frame2:SetPoint("right", button, "left", -4, 0)

		elseif (CoolTip.frame2_IsOnLeftside) then
			frame2:ClearAllPoints()
			frame2:SetPoint("bottomright", frame1, "bottomleft", -4, 0)
		else
			frame2:ClearAllPoints()
			frame2:SetPoint("bottomleft", frame1, "bottomright", 4, 0)
		end
	end

	function CoolTip:HideSub()
		DF:FadeFrame(frame2, 1)
	end

	function CoolTip:LeftTextSpace(row)
		row.leftText:SetWidth(row:GetWidth() - 30 - row.leftIcon:GetWidth() - row.rightIcon:GetWidth() - row.rightText:GetStringWidth())
		row.leftText:SetHeight(10)
	end

	--~inicio ~start ~tooltip
	function CoolTip:BuildTooltip()
		--hide sub frame
		DF:FadeFrame(frame2, 1)
		--hide select bar
		CoolTip:HideSelectedTexture(frame1)

		frame1:EnableMouse(false)

		--width
		if (CoolTip.OptionsTable.FixedWidth) then
			frame1:SetWidth(CoolTip.OptionsTable.FixedWidth)
		end

		frame1.w = CoolTip.OptionsTable.FixedWidth or 0
		frame1.hHeight = 0
		frame2.hHeight = 0

		CoolTip.active = true
		for i = 1, CoolTip.Indexes do
			local button = frame1.Lines[i]
			if (not button) then
				button = CoolTip:CreateMainFrameButton(i)
			end

			button.index = i

			--basic stuff
			button:Show()
			button.background:Hide()
			button:SetHeight(CoolTip.OptionsTable.ButtonHeightMod or CoolTip.default_height)
			button:RegisterForClicks()

			--setup texts and icons
			CoolTip:TextAndIcon(i, frame1, button, CoolTip.LeftTextTable[i], CoolTip.RightTextTable[i], CoolTip.LeftIconTable[i], CoolTip.RightIconTable[i])
			--setup statusbar
			CoolTip:StatusBar(button, CoolTip.StatusBarTable[i])
		end

		--hide unused lines
		for i = CoolTip.Indexes+1, #frame1.Lines do
			frame1.Lines[i]:Hide()
		end
		CoolTip.NumLines = CoolTip.Indexes

		local spacing = 0
		if (CoolTip.OptionsTable.YSpacingMod) then
			spacing = CoolTip.OptionsTable.YSpacingMod
		end

		--normalize height of all rows
		local heightValue = -6 + spacing + (CoolTip.OptionsTable.ButtonsYMod or 0)
		for i = 1, CoolTip.Indexes do 
			local menuButton = frame1.Lines[i]

			menuButton:ClearAllPoints()
			menuButton:SetPoint("center", frame1, "center")
			menuButton:SetPoint("left", frame1, "left", -4, 0)
			menuButton:SetPoint("right", frame1, "right", 4, 0)

			if (menuButton.divbar) then
				menuButton.divbar:Hide()
				menuButton.isDiv = false
			end

			--height
			if (CoolTip.OptionsTable.AlignAsBlizzTooltip) then
				local height = max(2, menuButton.leftText:GetStringHeight(), menuButton.rightText:GetStringHeight(), menuButton.leftIcon:GetHeight(), menuButton.rightIcon:GetHeight(), CoolTip.OptionsTable.AlignAsBlizzTooltipForceHeight or 2)
				menuButton:SetHeight(height)
				menuButton:SetPoint("top", frame1, "top", 0, heightValue)
				heightValue = heightValue + ( height * -1)

			elseif (CoolTip.OptionsTable.IgnoreButtonAutoHeight) then

				local height = max(menuButton.leftText:GetStringHeight(), menuButton.rightText:GetStringHeight(), menuButton.leftIcon:GetHeight(), menuButton.rightIcon:GetHeight())
				menuButton:SetHeight(height)
				menuButton:SetPoint("top", frame1, "top", 0, heightValue)

				heightValue = heightValue + ( height * -1) + spacing + (CoolTip.OptionsTable.ButtonsYMod or 0)

			else
				menuButton:SetHeight(frame1.hHeight + (CoolTip.OptionsTable.ButtonHeightMod or 0))
				menuButton:SetPoint("top", frame1, "top", 0, ( ( (i-1) * frame1.hHeight) * -1) - 6 + (CoolTip.OptionsTable.ButtonsYMod or 0) + spacing)
			end

			if (CoolTip.OptionsTable.YSpacingMod and not CoolTip.OptionsTable.IgnoreButtonAutoHeight) then
				spacing = spacing + CoolTip.OptionsTable.YSpacingMod
			end

			menuButton:EnableMouse(false)
		end

		if (not CoolTip.OptionsTable.FixedWidth) then
			if (CoolTip.Type == 2) then --with bars
				if (CoolTip.OptionsTable.MinWidth) then
					local w = frame1.w + 34
					PixelUtil.SetWidth(frame1, math.max(w, CoolTip.OptionsTable.MinWidth))
				else
					PixelUtil.SetWidth(frame1, frame1.w + 34)
				end
			else
				--width stability check
				local width = frame1.w + 24
				if (width > CoolTip.LastSize - 5 and width < CoolTip.LastSize + 5) then
					width = CoolTip.LastSize
				else
					CoolTip.LastSize = width
				end

				if (CoolTip.OptionsTable.MinWidth) then
					PixelUtil.SetWidth(frame1, math.max(width, CoolTip.OptionsTable.MinWidth))
				else
					PixelUtil.SetWidth(frame1, width)
				end
			end
		end

		if (CoolTip.OptionsTable.FixedHeight) then
			PixelUtil.SetHeight(frame1, CoolTip.OptionsTable.FixedHeight)
		else
			if (CoolTip.OptionsTable.AlignAsBlizzTooltip) then
				PixelUtil.SetHeight(frame1, ((heightValue - 10) * -1) + (CoolTip.OptionsTable.AlignAsBlizzTooltipFrameHeightOffset or 0))

			elseif (CoolTip.OptionsTable.IgnoreButtonAutoHeight) then
				PixelUtil.SetHeight(frame1, (heightValue + spacing) * -1)

			else
				PixelUtil.SetHeight(frame1, max( (frame1.hHeight * CoolTip.Indexes) + 8 + ((CoolTip.OptionsTable.ButtonsYMod or 0)*-1), 22 ))
			end
		end

		if (CoolTip.WallpaperTable[1]) then
			CoolTip:SetupWallpaper(CoolTip.WallpaperTable, frame1.frameWallpaper)
		else
			frame1.frameWallpaper:Hide()
		end

		--unhide frame
		DF:FadeFrame(frame1, 0)
		CoolTip:SetMyPoint()

		--fix sparks
		for i = 1, CoolTip.Indexes do
			local menuButton = frame1.Lines[i]
			if (menuButton.spark:IsShown() or menuButton.spark2:IsShown()) then
				CoolTip:RefreshSpark(menuButton)
			end
		end
	end

	function CoolTip:CreateDivBar(button)
		button.divbar = button:CreateTexture(nil, "overlay")
		button.divbar:SetTexture([[Interface\QUESTFRAME\AutoQuest-Parts]])
		button.divbar:SetTexCoord(238/512, 445/512, 0/64, 4/64)
		button.divbar:SetHeight(3)
		button.divbar:SetAlpha(0.1)
		button.divbar:SetDesaturated(true)
	end

	--~inicio ~start ~menu
	function CoolTip:BuildCooltip(host)
		if (CoolTip.Indexes == 0) then
			CoolTip:Reset()
			CoolTip:SetType(CONST_COOLTIP_TYPE_TOOLTIP)
			CoolTip:AddLine("There is no options.")
			CoolTip:ShowCooltip()
			return
		end

		if (CoolTip.OptionsTable.FixedWidth) then
			frame1:SetWidth(CoolTip.OptionsTable.FixedWidth)
		end

		frame1.w = CoolTip.OptionsTable.FixedWidth or 0
		frame1.hHeight = 0
		frame2.hHeight = 0

		frame1:EnableMouse(true)

		if (CoolTip.HaveSubMenu) then
			frame2.w = 0
			frame2:SetHeight(6)
			if (CoolTip.SelectedIndexMain and CoolTip.IndexesSub[CoolTip.SelectedIndexMain] and CoolTip.IndexesSub[CoolTip.SelectedIndexMain] > 0) then
				DF:FadeFrame(frame2, 0)
			else
				DF:FadeFrame(frame2, 1)
			end
		else
			DF:FadeFrame(frame2, 1)
		end

		CoolTip.active = true

		for i = 1, CoolTip.Indexes do
			local menuButton = frame1.Lines[i]
			if (not menuButton) then
				menuButton = CoolTip:CreateMainFrameButton(i)
			end
			CoolTip:SetupMainButton(menuButton, i)
			menuButton.background:Hide()
		end

		--selected texture
		if (CoolTip.SelectedIndexMain) then
			CoolTip:SetSelectedAnchor(frame1, frame1.Lines[CoolTip.SelectedIndexMain])

			if (CoolTip.OptionsTable.NoLastSelectedBar) then
				CoolTip:HideSelectedTexture(frame1)
			else
				CoolTip:ShowSelectedTexture(frame1)
			end
		else
			CoolTip:HideSelectedTexture(frame1)
		end

		if (CoolTip.Indexes < #frame1.Lines) then
			for i = CoolTip.Indexes+1, #frame1.Lines do
				frame1.Lines[i]:Hide()
			end
		end

		CoolTip.NumLines = CoolTip.Indexes

		local spacing = 0
		if (CoolTip.OptionsTable.YSpacingMod) then
			spacing = CoolTip.OptionsTable.YSpacingMod
		end

		if (not CoolTip.OptionsTable.FixedWidth) then
			if (CoolTip.OptionsTable.MinWidth) then
				local w = frame1.w + 24
				frame1:SetWidth(math.max(w, CoolTip.OptionsTable.MinWidth))
			else
				frame1:SetWidth(frame1.w + 24)
			end
		end

		--normalize height of all rows
		for i = 1, CoolTip.Indexes do
			local menuButton = frame1.Lines[i]
			menuButton:EnableMouse(true)

			if (menuButton.leftText:GetText() == "$div") then
				--height
				menuButton:SetHeight(4)
				--points
				menuButton:ClearAllPoints()
				menuButton:SetPoint("left", frame1, "left", -4, 0)
				menuButton:SetPoint("right", frame1, "right", 4, 0)
				menuButton:SetPoint("center", frame1, "center")

				local divisorOffsetTop = tonumber(CoolTip.LeftTextTable[i][2])
				if (not divisorOffsetTop) then
					divisorOffsetTop = 0
				end
				local divisorOffsetBottom = tonumber(CoolTip.LeftTextTable[i][3])
				if (not divisorOffsetBottom) then
					divisorOffsetBottom = 0
				end

				menuButton:SetPoint("top", frame1, "top", 0, ( ( (i-1) * frame1.hHeight) * -1) - 4 + (CoolTip.OptionsTable.ButtonsYMod or 0) + spacing - 4 + divisorOffsetTop)
				if (CoolTip.OptionsTable.YSpacingMod) then
					spacing = spacing + CoolTip.OptionsTable.YSpacingMod
				end

				spacing = spacing + 4 + divisorOffsetBottom

				menuButton.leftText:SetText("")
				menuButton.isDiv = true

				if (not menuButton.divbar) then
					CoolTip:CreateDivBar(menuButton)
				else
					menuButton.divbar:Show()
				end

				menuButton.divbar:SetPoint("left", menuButton, "left", frame1:GetWidth() * 0.10, 0)
				menuButton.divbar:SetPoint("right", menuButton, "right", -frame1:GetWidth() * 0.10, 0)
			else
				--height
				menuButton:SetHeight(frame1.hHeight + (CoolTip.OptionsTable.ButtonHeightMod or 0))
				--points
				menuButton:ClearAllPoints()
				menuButton:SetPoint("center", frame1, "center")
				menuButton:SetPoint("top", frame1, "top", 0, ( ( (i-1) * frame1.hHeight) * -1) - 4 + (CoolTip.OptionsTable.ButtonsYMod or 0) + spacing)
				if (CoolTip.OptionsTable.YSpacingMod) then
					spacing = spacing + CoolTip.OptionsTable.YSpacingMod
				end
				menuButton:SetPoint("left", frame1, "left", -4, 0)
				menuButton:SetPoint("right", frame1, "right", 4, 0)

				if (menuButton.divbar) then
					menuButton.divbar:Hide()
					menuButton.isDiv = false
				end
			end
		end

		if (CoolTip.OptionsTable.FixedHeight) then
			frame1:SetHeight(CoolTip.OptionsTable.FixedHeight)
		else
			local mod = CoolTip.OptionsTable.HeighMod or 0
			frame1:SetHeight(max((frame1.hHeight * CoolTip.Indexes) + 12 + (-spacing) + mod, 22))
		end

		--sub menu arrows
		if (CoolTip.HaveSubMenu and not CoolTip.OptionsTable.IgnoreArrows and not CoolTip.OptionsTable.SubMenuIsTooltip) then
			for i = 1, CoolTip.Indexes do
				if (CoolTip.IndexesSub[i] and CoolTip.IndexesSub[i] > 0) then
					frame1.Lines[i].statusbar.subMenuArrow:Show()
				else
					frame1.Lines[i].statusbar.subMenuArrow:Hide()
				end
			end
			frame1:SetWidth(frame1:GetWidth() + 16)
		end

		frame1:ClearAllPoints()
		CoolTip:SetMyPoint(host)

		if (CoolTip.title1) then
			CoolTip.frame1.titleText:Show()
			CoolTip.frame1.titleIcon:Show()
			CoolTip.frame1.titleText:SetText(CoolTip.title_text)
			CoolTip.frame1.titleIcon:SetWidth(frame1:GetWidth())
			CoolTip.frame1.titleIcon:SetHeight(40)
		end

		if (CoolTip.WallpaperTable[1]) then
			CoolTip:SetupWallpaper(CoolTip.WallpaperTable, frame1.frameWallpaper)
		else
			frame1.frameWallpaper:Hide()
		end

		DF:FadeFrame(frame1, 0)

		for i = 1, CoolTip.Indexes do
			if (CoolTip.SelectedIndexMain and CoolTip.SelectedIndexMain == i) then
				if (CoolTip.HaveSubMenu and CoolTip.IndexesSub[i] and CoolTip.IndexesSub[i] > 0) then
					CoolTip:ShowSub(i)
				end
			end
		end

		return true
	end

	function CoolTip:SetMyPoint(host, xOffset, yOffset)
		local thisXOffset = xOffset or 0
		local thisYOffset = yOffset or 0

		--clear all points
		frame1:ClearAllPoints()

		local anchor = CoolTip.OptionsTable.Anchor or CoolTip.Host
		PixelUtil.SetPoint(frame1, CoolTip.OptionsTable.MyAnchor, anchor, CoolTip.OptionsTable.RelativeAnchor, 0 + thisXOffset + CoolTip.OptionsTable.WidthAnchorMod, 10 + CoolTip.OptionsTable.HeightAnchorMod + thisYOffset)

		if (not xOffset) then
			--check if cooltip is out of screen bounds
			local xCenter = frame1:GetCenter()
			if (xCenter) then
				local screenWidth = GetScreenWidth()
				local frame1WidthHalf = frame1:GetWidth() / 2

				if (xCenter + frame1WidthHalf > screenWidth) then
					--out of right side
					local newXOffset = (xCenter + frame1WidthHalf) - screenWidth
					CoolTip.internalYMod = -newXOffset
					return CoolTip:SetMyPoint(host, -newXOffset, 0)

				elseif (xCenter - frame1WidthHalf < 0) then
					--out of left side
					local newXOffset = xCenter - frame1WidthHalf
					CoolTip.internalYMod = newXOffset * -1
					return CoolTip:SetMyPoint(host, newXOffset * -1, 0)
				end
			end
		end

		if (not yOffset) then
			--check if cooltip is out of screen bounds
			local _, xCenter = frame1:GetCenter()
			local screenHeight = GetScreenHeight()
			local frame1HeightHalf = frame1:GetHeight() / 2

			if (xCenter) then
				if (xCenter + frame1HeightHalf > screenHeight) then
					--out of top side
					local newYOffset = (xCenter + frame1HeightHalf) - screenHeight
					CoolTip.internalYMod = -newYOffset
					return CoolTip:SetMyPoint(host, 0, -newYOffset)

				elseif (xCenter - frame1HeightHalf < 0) then
					--out of bottom side
					local newYOffset = xCenter - frame1HeightHalf
					CoolTip.internalYMod = newYOffset * -1
					return CoolTip:SetMyPoint(host, 0, newYOffset * -1)
				end
			end
		end

		if (frame2:IsShown() and not CoolTip.overlapChecked) then
			local xCenter = frame2:GetCenter()
			if (xCenter) then
				local frame2WidthHalf = frame2:GetWidth() / 2
				local frame1XCenter = frame1:GetCenter()

				if (frame1XCenter) then
					local frame1WidthHalf = frame1:GetWidth() / 2
					local frame1EndPoint = frame1XCenter + frame1WidthHalf - 3
					local frame2StartPoint = xCenter - frame2WidthHalf

					if (frame2StartPoint < frame1EndPoint) then
						local diff = frame2StartPoint - frame1EndPoint --not in use
						CoolTip.overlapChecked = true
						frame2:ClearAllPoints()
						frame2:SetPoint("bottomright", frame1, "bottomleft", 4, 0)
						CoolTip.frame2_IsOnLeftside = true
						--diff
						return CoolTip:SetMyPoint(host, CoolTip.internalYMod , CoolTip.internalYMod)
					end
				end
			end
		end
	end

	function CoolTip:CheckOverlap()
		if (frame2:IsShown()) then
			local xCenter = frame2:GetCenter()
			if (xCenter) then
				local frame2WidthHalf = frame2:GetWidth() / 2
				local frame1XCenter = frame1:GetCenter()
				if (frame1XCenter) then
					local frame1WidthHalf = frame1:GetWidth() / 2
					local frame1EndPoint = frame1XCenter + frame1WidthHalf - 3
					local frame2StartPoint = xCenter - frame2WidthHalf
					if (frame2StartPoint < frame1EndPoint) then
						local diff = frame2StartPoint - frame1EndPoint --not in use
						frame2:ClearAllPoints()
						frame2:SetPoint("bottomright", frame1, "bottomleft", 4, 0)
						CoolTip.frame2_IsOnLeftside = true
					end
				end
			end
		end
	end

	--retrive the left and right text shown on a line
	function CoolTip:GetText(buttonIndex)
		local button1 = frame1.Lines[buttonIndex]
		if (not button1) then
			return "", ""
		else
			return button1.leftText:GetText() or "", button1.rightText:GetText() or ""
		end
	end

	--get the number of lines current shown on cooltip
	function CoolTip:GetNumLines()
		return CoolTip.NumLines or 0
	end

	--remove all options actived, set a option on current cooltip
	function CoolTip:ClearAllOptions()
		for option, _ in pairs(CoolTip.OptionsTable) do
			CoolTip.OptionsTable[option] = nil
		end
		CoolTip:SetOption("MyAnchor", "bottom")
		CoolTip:SetOption("RelativeAnchor", "top")
		CoolTip:SetOption("WidthAnchorMod", 0)
		CoolTip:SetOption("HeightAnchorMod", 0)
	end

	function CoolTip:SetOption(optionName, value)
		--check for name alias
		optionName = CoolTip.AliasList[optionName] or optionName
		--check if this options exists
		if (not CoolTip.OptionsList[optionName]) then
			return CoolTip:PrintDebug("SetOption() option not found:", optionName)
		end
		--set options
		CoolTip.OptionsTable[optionName] = value
	end

	--return the current frame using cooltip
	function CoolTip:GetOwner()
		return CoolTip.Host
	end

	--set the anchor of cooltip, parameters: frame [, cooltip anchor point, frame anchor point[, x mod, y mod]]
	function CoolTip:SetOwner(frame, myPoint, hisPoint, x, y)
		return CoolTip:SetHost(frame, myPoint, hisPoint, x, y)
	end

	function CoolTip:SetHost(frame, myPoint, hisPoint, x, y)
		--check data integrity
		if (type(frame) ~= "table" or not frame.GetObjectType) then
			return CoolTip:PrintDebug("SetHost() need a WOWObject.")
		end

		CoolTip.Host = frame
		CoolTip.frame1:SetFrameLevel(frame:GetFrameLevel() + 1)

		--defaults
		myPoint = myPoint or CoolTip.OptionsTable.MyAnchor or "bottom"
		hisPoint = hisPoint or CoolTip.OptionsTable.hisPoint or "top"

		x = x or CoolTip.OptionsTable.WidthAnchorMod or 0
		y = y or CoolTip.OptionsTable.HeightAnchorMod or 0

		--set options
		if (type(myPoint) == "string") then
			CoolTip:SetOption("MyAnchor", myPoint)
			CoolTip:SetOption("WidthAnchorMod", x)
		elseif (type(myPoint) == "number") then
			CoolTip:SetOption("HeightAnchorMod", myPoint)
		end

		if (type(hisPoint) == "string") then
			CoolTip:SetOption("RelativeAnchor", hisPoint)
			CoolTip:SetOption("HeightAnchorMod", y)
		elseif (type(hisPoint) == "number") then
			CoolTip:SetOption("WidthAnchorMod", hisPoint)
		end
	end

----------------------------------------------------------------------
	--set cooltip type
	--parameters: type(1 = tooltip | 2 = tooltip with bars | 3 = menu)

	--return if the current shown cooltip is a menu
	function CoolTip:IsMenu()
		return CoolTip.frame1:IsShown() and CoolTip.Type == 3
	end

	--return if the current shown cooltip is a tooltip
	function CoolTip:IsTooltip()
		return CoolTip.frame1:IsShown() and (CoolTip.Type == 1 or CoolTip.Type == 2)
	end

	function CoolTip:GetType()
		if (CoolTip.Type == 1 or CoolTip.Type == 2) then
			return CONST_COOLTIP_TYPE_TOOLTIP
		elseif (CoolTip.Type == 3) then
			return CONST_COOLTIP_TYPE_MENU
		else
			return "none"
		end
	end

	function CoolTip:SetType(newType)
		if (type(newType) == "string") then
			if (newType == CONST_COOLTIP_TYPE_TOOLTIP) then
				CoolTip.Type = 1
			elseif (newType == "tooltipbar") then
				CoolTip.Type = 2
			elseif (newType == CONST_COOLTIP_TYPE_MENU) then
				CoolTip.Type = 3
			else
				return CoolTip:PrintDebug("SetType() unknown type.", newType)
			end

		elseif (type(newType) == "number") then
			if (newType == 1) then
				CoolTip.Type = 1
			elseif (newType == 2) then
				CoolTip.Type = 2
			elseif (newType == 3) then
				CoolTip.Type = 3
			else
				return CoolTip:PrintDebug("SetType() unknown type.", newType)
			end
		else
			return CoolTip:PrintDebug("SetType() unknown type.", newType)
		end
	end

	--set a fixed value for menu, the fixedValue is sent with the menu callback function
	function CoolTip:SetFixedParameter(value, injected)
		if (injected ~= nil) then
			local frame = value
			if (frame.dframework) then
				frame = frame.widget
			end
			if (frame.CoolTip) then
				frame.CoolTip.FixedValue = injected
			end
		end
		CoolTip.FixedValue = value
	end

	--set tooltip color
	function CoolTip:SetColor(menuType, ...)
		local colorRed, colorGreen, colorBlue, colorAlpha = DF:ParseColors(...)
		if ((type(menuType) == "string" and menuType == CONST_MENU_TYPE_MAINMENU) or (type(menuType) == "number" and menuType == 1)) then
			frame1.frameBackgroundTexture:SetColorTexture(colorRed, colorGreen, colorBlue, colorAlpha)

			--hide textures from older versions if exists
			if (frame1.frameBackgroundLeft) then
				frame1.frameBackgroundLeft:Hide()
				frame1.frameBackgroundRight:Hide()
				frame1.frameBackgroundCenter:Hide()
			end

		elseif ((type(menuType) == "string" and menuType == CONST_MENU_TYPE_SUBMENU) or (type(menuType) == "number" and menuType == 2)) then
			frame2.frameBackgroundTexture:SetColorTexture(colorRed, colorGreen, colorBlue, colorAlpha)

			--hide textures from older versions if exists
			if (frame2.frameBackgroundLeft) then
				frame2.frameBackgroundLeft:Hide()
				frame2.frameBackgroundRight:Hide()
				frame2.frameBackgroundCenter:Hide()
			end
		else
			return CoolTip:PrintDebug("SetColor() unknown menuType.", menuType)
		end
	end

	--set last selected option
	function CoolTip:SetLastSelected(menuType, index, index2)
		if (CoolTip.Type == 3) then
			if ((type(menuType) == "string" and menuType == CONST_MENU_TYPE_MAINMENU) or (type(menuType) == "number" and menuType == 1)) then
				CoolTip.SelectedIndexMain = index
			elseif ((type(menuType) == "string" and menuType == CONST_MENU_TYPE_SUBMENU) or (type(menuType) == "number" and menuType == 2)) then
				CoolTip.SelectedIndexSec[index] = index2
			else
				return CoolTip:PrintDebug("SetLastSelected() unknown menuType.", menuType)
			end
		else
			return CoolTip:PrintDebug("SetLastSelected() current cooltip isn't a menu.")
		end
	end

	--serack key: ~select
	function CoolTip:Select(menuType, option, mainIndex)
		if (menuType == 1) then --main menu
			local botao = frame1.Lines[option]
			CoolTip.buttonClicked = true
			CoolTip:SetSelectedAnchor(frame1, botao)

		elseif (menuType == 2) then --sub menu
			CoolTip:ShowSub(mainIndex)
			local botao = frame2.Lines[option]
			CoolTip.buttonClicked = true
			CoolTip:SetSelectedAnchor(frame2, botao)
		end
	end

----------------------------------------------------------------------
	--wipe all data ~reset
	function CoolTip:Reset(fromPreset)
		frame2:ClearAllPoints()
		frame2:SetPoint("bottomleft", frame1, "bottomright", 4, 0)
		frame1:SetWidth(170)
		frame2:SetWidth(170)

		frame1:SetParent(UIParent)
		frame2:SetParent(UIParent)
		frame1:SetFrameStrata("TOOLTIP")
		frame2:SetFrameStrata("TOOLTIP")

		CoolTip:HideSelectedTexture(frame1)
		CoolTip:HideSelectedTexture(frame2)

		CoolTip.FixedValue = nil
		CoolTip.HaveSubMenu = false
		CoolTip.SelectedIndexMain = nil
		CoolTip.Indexes =  0
		CoolTip.SubIndexes = 0
		CoolTip.internalYMod = 0
		CoolTip.internalYMod = 0
		CoolTip.current_anchor = nil
		CoolTip.overlapChecked = false
		CoolTip.frame2_IsOnLeftside = nil

		wipe(CoolTip.SelectedIndexSec)
		wipe(CoolTip.IndexesSub)
		wipe(CoolTip.PopupFrameTable)

		wipe(CoolTip.LeftTextTable)
		wipe(CoolTip.LeftTextTableSub)
		wipe(CoolTip.RightTextTable)
		wipe(CoolTip.RightTextTableSub)

		wipe(CoolTip.LeftIconTable)
		wipe(CoolTip.LeftIconTableSub)
		wipe(CoolTip.RightIconTable)
		wipe(CoolTip.RightIconTableSub)

		wipe(CoolTip.StatusBarTable)
		wipe(CoolTip.StatusBarTableSub)

		wipe(CoolTip.FunctionsTableMain)
		wipe(CoolTip.FunctionsTableSub)

		wipe(CoolTip.ParametersTableMain)
		wipe(CoolTip.ParametersTableSub)

		wipe(CoolTip.WallpaperTable)
		wipe(CoolTip.WallpaperTableSub)

		wipe(CoolTip.TopIconTableSub)
		CoolTip.Banner[1] = false
		CoolTip.Banner[2] = false
		CoolTip.Banner[3] = false

		frame1.upperImage:Hide()
		frame1.upperImage2:Hide()
		frame1.upperImageText:Hide()
		frame1.upperImageText2:Hide()
		frame1.frameWallpaper:Hide()
		frame2.frameWallpaper:Hide()
		frame2.upperImage:Hide()

		CoolTip.title1 = nil
		CoolTip.title_text = nil
		CoolTip.frame1.titleText:Hide()
		CoolTip.frame1.titleIcon:Hide()

		CoolTip:ClearAllOptions()
		CoolTip:SetColor(1, "transparent")
		CoolTip:SetColor(2, "transparent")

		for i = 1, #frame1.Lines do
			frame1.Lines[i].statusbar.subMenuArrow:Hide()
		end

		--older versions has these three textures
		if (frame1.frameBackgroundLeft) then
			frame1.frameBackgroundLeft:Hide()
			frame1.frameBackgroundRight:Hide()
			frame1.frameBackgroundCenter:Hide()
		end

		frame1.frameBackgroundTexture:SetColorTexture(0, 0, 0, 0)
		frame2.frameBackgroundTexture:SetColorTexture(0, 0, 0, 0)

		if (not fromPreset) then
			CoolTip:Preset(3, true)
		end
	end

----------------------------------------------------------------------
	--menu functions
	local defaultWhiteColor = {1, 1, 1}
	function CoolTip:AddMenu(menuType, func, param1, param2, param3, leftText, leftIcon, indexUp)
		if (leftText and indexUp and ((type(menuType) == "string" and menuType == CONST_MENU_TYPE_MAINMENU) or (type(menuType) == "number" and menuType == 1))) then
			CoolTip.Indexes = CoolTip.Indexes + 1
			if (not CoolTip.IndexesSub[CoolTip.Indexes]) then
				CoolTip.IndexesSub[CoolTip.Indexes] = 0
			end
			CoolTip.SubIndexes = 0
		end

		--need a previous line
		if (CoolTip.Indexes == 0) then
			return CoolTip:PrintDebug("AddMenu() requires an already added line (Cooltip:AddLine()).")
		end

		--check data integrity
		if (type(func) ~= "function") then
			return CoolTip:PrintDebug("AddMenu() no function passed.")
		end

		if ((type(menuType) == "string" and menuType == CONST_MENU_TYPE_MAINMENU) or (type(menuType) == "number" and menuType == 1)) then
			local parameterTable
			if (CoolTip.isSpecial) then
				parameterTable = {}
				insert(CoolTip.FunctionsTableMain, CoolTip.Indexes, func)
				insert(CoolTip.ParametersTableMain, CoolTip.Indexes, parameterTable)
			else
				CoolTip.FunctionsTableMain[CoolTip.Indexes] = func
				parameterTable = CoolTip.ParametersTableMain[CoolTip.Indexes]
				if (not parameterTable) then
					parameterTable = {}
					CoolTip.ParametersTableMain[CoolTip.Indexes] = parameterTable
				end
			end

			parameterTable[1] = param1
			parameterTable[2] = param2
			parameterTable[3] = param3

			if (leftIcon) then
				local iconTable = CoolTip.LeftIconTable[CoolTip.Indexes]
				if (not iconTable or CoolTip.isSpecial) then
					iconTable = {}
					CoolTip.LeftIconTable[CoolTip.Indexes] = iconTable
				end
				iconTable[1] = leftIcon
				iconTable[2] = 16 --default 16
				iconTable[3] = 16 --default 16
				iconTable[4] = 0 --default 0
				iconTable[5] = 1 --default 1
				iconTable[6] = 0 --default 0
				iconTable[7] = 1 --default 1
				iconTable[8] = defaultWhiteColor
			end

			if (leftText) then
				local lineTable_Left = CoolTip.LeftTextTable[CoolTip.Indexes]
				if (not lineTable_Left or CoolTip.isSpecial) then
					lineTable_Left = {}
					CoolTip.LeftTextTable[CoolTip.Indexes] = lineTable_Left
				end
				lineTable_Left[1] = leftText
				lineTable_Left[2] = 0
				lineTable_Left[3] = 0
				lineTable_Left[4] = 0
				lineTable_Left[5] = 0
				lineTable_Left[6] = false
				lineTable_Left[7] = false
				lineTable_Left[8] = false
			end

		elseif ((type(menuType) == "string" and menuType == CONST_MENU_TYPE_SUBMENU) or (type(menuType) == "number" and menuType == 2)) then
			if (CoolTip.SubIndexes == 0) then
				if (not indexUp or not leftText) then
					return CoolTip:PrintDebug("AddMenu() attempt to add a submenu with a parent.") --error[leftText can't be nil if indexUp are true]
				end
			end

			if (indexUp and leftText) then
				CoolTip.SubIndexes = CoolTip.SubIndexes + 1
				CoolTip.IndexesSub[CoolTip.Indexes] = CoolTip.IndexesSub[CoolTip.Indexes] + 1

			elseif (indexUp and not leftText) then
				return CoolTip:PrintDebug("AddMenu() attempt to add a submenu with a parent.") --error[leftText can't be nil if indexUp are true]
			end

			--menu container
			local subMenuContainerParameters = CoolTip.ParametersTableSub[CoolTip.Indexes]
			if (not subMenuContainerParameters) then
				subMenuContainerParameters = {}
				CoolTip.ParametersTableSub[CoolTip.Indexes] = subMenuContainerParameters
			end

			local subMenuContainerFunctions = CoolTip.FunctionsTableSub[CoolTip.Indexes]
			if (not subMenuContainerFunctions or CoolTip.isSpecial) then
				subMenuContainerFunctions = {}
				CoolTip.FunctionsTableSub[CoolTip.Indexes] = subMenuContainerFunctions
			end

			--menu table
			local subMenuTablesParameters = subMenuContainerParameters[CoolTip.SubIndexes]
			if (not subMenuTablesParameters or CoolTip.isSpecial) then
				subMenuTablesParameters = {}
				subMenuContainerParameters[CoolTip.SubIndexes] = subMenuTablesParameters
			end

			--add
			subMenuContainerFunctions[CoolTip.SubIndexes] = func
			subMenuTablesParameters[1] = param1
			subMenuTablesParameters[2] = param2
			subMenuTablesParameters[3] = param3

			--text and icon
			if (leftIcon) then
				local subMenuContainerIcons = CoolTip.LeftIconTableSub[CoolTip.Indexes]
				if (not subMenuContainerIcons) then
					subMenuContainerIcons = {}
					CoolTip.LeftIconTableSub[CoolTip.Indexes] = subMenuContainerIcons
				end
				local subMenuTablesIcons = subMenuContainerIcons[CoolTip.SubIndexes]
				if (not subMenuTablesIcons or CoolTip.isSpecial) then
					subMenuTablesIcons = {}
					subMenuContainerIcons[CoolTip.SubIndexes] = subMenuTablesIcons
				end

				subMenuTablesIcons[1] = leftIcon
				subMenuTablesIcons[2] = 16 --default 16
				subMenuTablesIcons[3] = 16 --default 16
				subMenuTablesIcons[4] = 0 --default 0
				subMenuTablesIcons[5] = 1 --default 1
				subMenuTablesIcons[6] = 0 --default 0
				subMenuTablesIcons[7] = 1 --default 1
				subMenuTablesIcons[8] = defaultWhiteColor
			end

			if (leftText) then
				local subMenuContainerTexts = CoolTip.LeftTextTableSub[CoolTip.Indexes]
				if (not subMenuContainerTexts) then
					subMenuContainerTexts = {}
					CoolTip.LeftTextTableSub[CoolTip.Indexes] = subMenuContainerTexts
				end
				local subMenuTablesTexts = subMenuContainerTexts[CoolTip.SubIndexes]
				if (not subMenuTablesTexts or CoolTip.isSpecial) then
					subMenuTablesTexts = {}
					subMenuContainerTexts[CoolTip.SubIndexes] = subMenuTablesTexts
				end

				subMenuTablesTexts[1] = leftText
				subMenuTablesTexts[2] = 0
				subMenuTablesTexts[3] = 0
				subMenuTablesTexts[4] = 0
				subMenuTablesTexts[5] = 0
				subMenuTablesTexts[6] = false
				subMenuTablesTexts[7] = false
				subMenuTablesTexts[8] = false
			end

			CoolTip.HaveSubMenu = true
		else
			return CoolTip:PrintDebug("AddMenu() unknown menuType.", menuType)
		end
	end

----------------------------------------------------------------------
	--adds a statusbar to the last line added.
	--only works with cooltip type2 (tooltip with bars)
	--parameters: value [, color red, color green, color blue, color alpha [, glow]]
	--can also use a table or html color name in color red and send glow in color green
	function CoolTip:AddStatusBar(statusbarValue, menuType, colorRed, colorGreen, colorBlue, colorAlpha, statusbarGlow, backgroundBar, barTexture)
		--need a previous line
		if (CoolTip.Indexes == 0) then
			return CoolTip:PrintDebug("AddStatusBar() requires an already added line (Cooltip:AddLine()).")
		end

		--check data integrity
		if (type(statusbarValue) ~= "number") then
			return
		end

		if (type(colorRed) == "table" or type(colorRed) == "string") then
			statusbarGlow, backgroundBar, colorRed, colorGreen, colorBlue, colorAlpha = colorGreen, colorBlue, DF:ParseColors(colorRed)
		elseif (type(colorRed) == "boolean") then
			backgroundBar = colorGreen
			statusbarGlow = colorRed
			colorRed, colorGreen, colorBlue, colorAlpha = 1, 1, 1, 1
		end

		--add
		local frameTable
		local statusbarTable
		if (not menuType or (type(menuType) == "string" and menuType == CONST_MENU_TYPE_MAINMENU) or (type(menuType) == "number" and menuType == 1)) then
			frameTable = CoolTip.StatusBarTable
			if (CoolTip.isSpecial) then
				statusbarTable = {}
				insert(frameTable, CoolTip.Indexes, statusbarTable)
			else
				statusbarTable = frameTable[CoolTip.Indexes]
				if (not statusbarTable) then
					statusbarTable = {}
					insert(frameTable, CoolTip.Indexes, statusbarTable)
				end
			end

		elseif ((type(menuType) == "string" and menuType == "sub") or (type(menuType) == "number" and menuType == 2)) then
			frameTable = CoolTip.StatusBarTableSub
			local subMenuContainerStatusBar = frameTable[CoolTip.Indexes]
			if (not subMenuContainerStatusBar) then
				subMenuContainerStatusBar = {}
				frameTable[CoolTip.Indexes] = subMenuContainerStatusBar
			end

			if (CoolTip.isSpecial) then
				statusbarTable = {}
				insert(subMenuContainerStatusBar, CoolTip.SubIndexes, statusbarTable)
			else
				statusbarTable = subMenuContainerStatusBar[CoolTip.SubIndexes]
				if (not statusbarTable) then
					statusbarTable = {}
					insert(subMenuContainerStatusBar, CoolTip.SubIndexes, statusbarTable)
				end
			end
		else
			return CoolTip:PrintDebug("AddStatusBar() unknown menuType.", menuType)
		end

		statusbarTable[1] = statusbarValue
		statusbarTable[2] = colorRed
		statusbarTable[3] = colorGreen
		statusbarTable[4] = colorBlue
		statusbarTable[5] = colorAlpha
		statusbarTable[6] = statusbarGlow
		statusbarTable[7] = backgroundBar
		statusbarTable[8] = barTexture
	end

	frame1.frameWallpaper:Hide()
	frame2.frameWallpaper:Hide()
	function CoolTip:SetWallpaper(index, texture, texcoord, color, desaturate)
		if (CoolTip.Indexes == 0) then
			return CoolTip:PrintDebug("SetWallpaper() requires an already added line (Cooltip:AddLine()).")
		end

		local frameTable
		local wallpaperTable
		if ((type(index) == "number" and index == 1) or (type(index) == "string" and index == CONST_MENU_TYPE_MAINMENU)) then
			wallpaperTable = CoolTip.WallpaperTable

		elseif ((type(index) == "number" and index == 2) or (type(index) == "string" and index == "sub")) then
			frameTable = CoolTip.WallpaperTableSub
			local subMenuContainerWallpapers = frameTable[CoolTip.Indexes]
			if (not subMenuContainerWallpapers) then
				subMenuContainerWallpapers = {}
				frameTable[CoolTip.Indexes] = subMenuContainerWallpapers
			end
			wallpaperTable = subMenuContainerWallpapers
		end

		wallpaperTable[1] = texture
		if (texcoord) then
			wallpaperTable[2] = texcoord[1]
			wallpaperTable[3] = texcoord[2]
			wallpaperTable[4] = texcoord[3]
			wallpaperTable[5] = texcoord[4]
		else
			wallpaperTable[2] = 0
			wallpaperTable[3] = 1
			wallpaperTable[4] = 0
			wallpaperTable[5] = 1
		end
		wallpaperTable[6] = color
		wallpaperTable[7] = desaturate
	end

	function CoolTip:SetBannerText(index, text, anchor, color, fontSize, fontFace, fontFlag)
		local fontstring
		if (index == 1) then
			fontstring = frame1.upperImageText
		elseif (index == 2) then
			fontstring = frame1.upperImageText2
		end

		fontstring:SetText(text or "")

		if (anchor and index == 1) then
			local myAnchor, hisAnchor, x, y = unpack(anchor)
			fontstring:SetPoint(myAnchor, frame1.upperImage, hisAnchor or myAnchor, x or 0, y or 0)
		elseif (anchor and index == 2) then
			local myAnchor, hisAnchor, x, y = unpack(anchor)
			fontstring:SetPoint(myAnchor, frame1, hisAnchor or myAnchor, x or 0, y or 0)
		end

		if (color) then
			local r, g, b, a = DF:ParseColors(color)
			fontstring:SetTextColor(r, g, b, a)
		end

		local face, size, flags = fontstring:GetFont()
		face = fontFace or DF:GetBestFontForLanguage()
		size = fontSize or 13
		flags = fontFlag or nil
		fontstring:SetFont(face, size, flags)
		fontstring:Show()
	end

	function CoolTip:SetBackdrop(index, backdrop, backdropcolor, bordercolor)
		local frame
		if (index == 1) then
			frame = frame1
		elseif (index == 2) then
			frame = frame2
		end

		if (backdrop) then
			frame:SetBackdrop(backdrop)
		end
		if (backdropcolor) then
			local r, g, b, a = DF:ParseColors(backdropcolor)
			frame:SetBackdropColor(r, g, b, a)
		end
		if (bordercolor) then
			local r, g, b, a = DF:ParseColors(bordercolor)
			frame:SetBackdropBorderColor(r, g, b, a)
		end
	end

	function CoolTip:SetBannerImage(index, texturePath, width, height, anchor, texCoord, overlay)
		local texture
		if (index == 1) then
			texture = frame1.upperImage
		elseif (index == 2) then
			texture = frame1.upperImage2
		end

		if (texturePath) then
			texture:SetTexture(texturePath)
		end

		if (width) then
			texture:SetWidth(width)
		end
		if (height) then
			texture:SetHeight(height)
		end

		if (anchor) then
			if (type(anchor[1]) == "table") then
				for _, anchorPoints in ipairs(anchor) do
					local myAnchor, hisAnchor, x, y = unpack(anchorPoints)
					texture:SetPoint(myAnchor, frame1, hisAnchor or myAnchor, x or 0, y or 0)
				end
			else
				local myAnchor, hisAnchor, x, y = unpack(anchor)
				texture:SetPoint(myAnchor, frame1, hisAnchor or myAnchor, x or 0, y or 0)
			end
		end

		if (texCoord) then
			local L, R, T, B = unpack(texCoord)
			texture:SetTexCoord(L, R, T, B)
		end
		if (overlay) then
			texture:SetVertexColor(unpack(overlay))
		end

		CoolTip.Banner[index] = true
		texture:Show()
	end

----------------------------------------------------------------------
	--adds a icon to the last line added.
	--only works with cooltip type1 and 2 (tooltip and tooltip with bars)
	--parameters: icon [, width [, height [, TexCoords L R T B ]]]
	--texture support string path or texture object

	function CoolTip:AddTexture(iconTexture, menuType, side, iconWidth, iconHeight, L, R, T, B, overlayColor, point, desaturated)
		return CoolTip:AddIcon(iconTexture, menuType, side, iconWidth, iconHeight, L, R, T, B, overlayColor, point, desaturated)
	end

	function CoolTip:AddIcon(iconTexture, menuType, side, iconWidth, iconHeight, L, R, T, B, overlayColor, point, desaturated)
		--need a previous line
		if (CoolTip.Indexes == 0) then
			return CoolTip:PrintDebug("AddIcon() requires an already added line (Cooltip:AddLine()).")
		end
		--check data integrity
		if ((type(iconTexture) ~= "string" and type(iconTexture) ~= "number") and (type(iconTexture) ~= "table" or not iconTexture.GetObjectType or iconTexture:GetObjectType() ~= "Texture")) then
			return CoolTip:PrintDebug("AddIcon() invalid parameters.")
		end

		side = side or 1
		local frameTable
		local iconTable

		if (not menuType or (type(menuType) == "string" and menuType == CONST_MENU_TYPE_MAINMENU) or (type(menuType) == "number" and menuType == 1)) then
			if (not side or (type(side) == "string" and side == "left") or (type(side) == "number" and side == 1)) then
				frameTable = CoolTip.LeftIconTable

			elseif ((type(side) == "string" and side == "right") or (type(side) == "number" and side == 2)) then
				frameTable = CoolTip.RightIconTable
			end

			if (CoolTip.isSpecial) then
				iconTable = {}
				insert(frameTable, CoolTip.Indexes, iconTable)
			else
				iconTable = frameTable[CoolTip.Indexes]
				if (not iconTable) then
					iconTable = {}
					insert(frameTable, CoolTip.Indexes, iconTable)
				end
			end

		elseif ((type(menuType) == "string" and menuType == "sub") or (type(menuType) == "number" and menuType == 2)) then
			if ((type(side) == "string" and side == "left") or (type(side) == "number" and side == 1)) then
				frameTable = CoolTip.LeftIconTableSub

			elseif ((type(side) == "string" and side == "right") or (type(side) == "number" and side == 2)) then
				frameTable = CoolTip.RightIconTableSub

			elseif ((type(side) == "string" and side == "top") or (type(side) == "number" and side == 3)) then
				CoolTip.TopIconTableSub[CoolTip.Indexes] = CoolTip.TopIconTableSub[CoolTip.Indexes] or {}
				CoolTip.TopIconTableSub[CoolTip.Indexes][1] = iconTexture
				CoolTip.TopIconTableSub[CoolTip.Indexes][2] = iconWidth or 16
				CoolTip.TopIconTableSub[CoolTip.Indexes][3] = iconHeight or 16
				CoolTip.TopIconTableSub[CoolTip.Indexes][4] = L or 0
				CoolTip.TopIconTableSub[CoolTip.Indexes][5] = R or 1
				CoolTip.TopIconTableSub[CoolTip.Indexes][6] = T or 0
				CoolTip.TopIconTableSub[CoolTip.Indexes][7] = B or 1
				CoolTip.TopIconTableSub[CoolTip.Indexes][8] = overlayColor or defaultWhiteColor
				CoolTip.TopIconTableSub[CoolTip.Indexes][9] = desaturated
				return
			end

			local subMenuContainerIcons = frameTable[CoolTip.Indexes]
			if (not subMenuContainerIcons) then
				subMenuContainerIcons = {}
				frameTable[CoolTip.Indexes] = subMenuContainerIcons
			end

			if (CoolTip.isSpecial) then
				iconTable = {}
				subMenuContainerIcons[CoolTip.SubIndexes] = iconTable
			else
				iconTable = subMenuContainerIcons[CoolTip.SubIndexes]
				if (not iconTable) then
					iconTable = {}
					subMenuContainerIcons[CoolTip.SubIndexes] = iconTable
				end
			end
		else
			return --error
		end

		iconTable[1] = iconTexture
		iconTable[2] = iconWidth or 16 --default 16
		iconTable[3] = iconHeight or 16 --default 16
		iconTable[4] = L or 0 --default 0
		iconTable[5] = R or 1 --default 1
		iconTable[6] = T or 0 --default 0
		iconTable[7] = B or 1 --default 1
		iconTable[8] = overlayColor or defaultWhiteColor --default 1, 1, 1
		iconTable[9] = desaturated

		return true
	end

----------------------------------------------------------------------
	--popup frame
	function CoolTip:AddPopUpFrame(onShowFunc, onHideFunc, param1, param2)
		--act like a sub menu
		if (CoolTip.Indexes > 0) then
			CoolTip.PopupFrameTable[CoolTip.Indexes] = {onShowFunc or false, onHideFunc or false, param1, param2}
		end
	end

----------------------------------------------------------------------
	--adds a line.
	--only works with cooltip type1 and 2 (tooltip and tooltip with bars)
	--parameters: left text, right text[, L color R, L color G, L color B, L color A[, R color R, R color G, R color B, R color A[, wrap]]] 
	function CoolTip:AddDoubleLine (leftText, rightText, menuType, ColorR1, ColorG1, ColorB1, ColorA1, ColorR2, ColorG2, ColorB2, ColorA2, fontSize, fontFace, fontFlag)
		return CoolTip:AddLine(leftText, rightText, menuType, ColorR1, ColorG1, ColorB1, ColorA1, ColorR2, ColorG2, ColorB2, ColorA2, fontSize, fontFace, fontFlag)
	end

	--adds a line for tooltips
	function CoolTip:AddLine(leftText, rightText, menuType, ColorR1, ColorG1, ColorB1, ColorA1, ColorR2, ColorG2, ColorB2, ColorA2, fontSize, fontFace, fontFlag)
		--check data integrity
		local leftTextType = type(leftText)
		if (leftTextType ~= "string") then
			if (leftTextType == "number") then
				leftText = tostring(leftText)
			else
				leftText = ""
			end
		end

		local rightTextType = type(rightText)
		if (rightTextType ~= "string") then
			if (rightTextType == "number") then
				rightText = tostring(rightText)
			else
				rightText = ""
			end
		end

		if (type(ColorR1) ~= "number") then
			ColorR2, ColorG2, ColorB2, ColorA2, fontSize, fontFace, fontFlag = ColorG1, ColorB1, ColorA1, ColorR2, ColorG2, ColorB2, ColorA2
			if (type(ColorR1) == "boolean" or not ColorR1) then
				ColorR1, ColorG1, ColorB1, ColorA1 = 0, 0, 0, 0
			else
				ColorR1, ColorG1, ColorB1, ColorA1 = DF:ParseColors(ColorR1)
			end
		end

		if (type(ColorR2) ~= "number") then
			fontSize, fontFace, fontFlag = ColorG2, ColorB2, ColorA2
			if (type(ColorR2) == "boolean" or not ColorR2) then
				ColorR2, ColorG2, ColorB2, ColorA2 = 0, 0, 0, 0
			else
				ColorR2, ColorG2, ColorB2, ColorA2 = DF:ParseColors(ColorR2)
			end
		end

		local frameTableLeft
		local frameTableRight
		local lineTable_Left
		local lineTable_Right

		if (not menuType or (type(menuType) == "string" and menuType == CONST_MENU_TYPE_MAINMENU) or (type(menuType) == "number" and menuType == 1)) then
			CoolTip.Indexes = CoolTip.Indexes + 1
			if (not CoolTip.IndexesSub[CoolTip.Indexes]) then
				CoolTip.IndexesSub[CoolTip.Indexes] = 0
			end

			CoolTip.SubIndexes = 0

			frameTableLeft = CoolTip.LeftTextTable
			frameTableRight = CoolTip.RightTextTable

			if (CoolTip.isSpecial) then
				lineTable_Left = {}
				insert(frameTableLeft, CoolTip.Indexes, lineTable_Left)
				lineTable_Right = {}
				insert(frameTableRight, CoolTip.Indexes, lineTable_Right)
			else
				lineTable_Left = frameTableLeft[CoolTip.Indexes]
				lineTable_Right = frameTableRight[CoolTip.Indexes]
				if (not lineTable_Left) then
					lineTable_Left = {}
					insert(frameTableLeft, CoolTip.Indexes, lineTable_Left)
				end
				if (not lineTable_Right) then
					lineTable_Right = {}
					insert(frameTableRight, CoolTip.Indexes, lineTable_Right)
				end
			end

		elseif ((type(menuType) == "string" and menuType == "sub") or (type(menuType) == "number" and menuType == 2)) then
			CoolTip.SubIndexes = CoolTip.SubIndexes + 1
			CoolTip.IndexesSub[CoolTip.Indexes] = CoolTip.IndexesSub[CoolTip.Indexes] + 1
			CoolTip.HaveSubMenu = true

			frameTableLeft = CoolTip.LeftTextTableSub
			frameTableRight = CoolTip.RightTextTableSub

			local subMenuContainerTexts = frameTableLeft[CoolTip.Indexes]
			if (not subMenuContainerTexts) then
				subMenuContainerTexts = {}
				insert(frameTableLeft, CoolTip.Indexes, subMenuContainerTexts)
			end

			if (CoolTip.isSpecial) then
				lineTable_Left = {}
				insert(subMenuContainerTexts, CoolTip.SubIndexes, lineTable_Left)
			else
				lineTable_Left = subMenuContainerTexts[CoolTip.SubIndexes]
				if (not lineTable_Left) then
					lineTable_Left = {}
					insert(subMenuContainerTexts, CoolTip.SubIndexes, lineTable_Left)
				end
			end

			local subMenuContainerTexts = frameTableRight[CoolTip.Indexes]
			if (not subMenuContainerTexts) then
				subMenuContainerTexts = {}
				insert(frameTableRight, CoolTip.Indexes, subMenuContainerTexts)
			end

			if (CoolTip.isSpecial) then
				lineTable_Right = {}
				insert(subMenuContainerTexts, CoolTip.SubIndexes, lineTable_Right)
			else
				lineTable_Right = subMenuContainerTexts[CoolTip.SubIndexes]
				if (not lineTable_Right) then
					lineTable_Right = {}
					insert(subMenuContainerTexts, CoolTip.SubIndexes, lineTable_Right)
				end
			end
		else
			return CoolTip:PrintDebug("AddLine() unknown menuType.", menuType)
		end

		lineTable_Left[1] = leftText
		lineTable_Left[2] = ColorR1
		lineTable_Left[3] = ColorG1
		lineTable_Left[4] = ColorB1
		lineTable_Left[5] = ColorA1
		lineTable_Left[6] = fontSize
		lineTable_Left[7] = fontFace
		lineTable_Left[8] = fontFlag

		lineTable_Right[1] = rightText
		lineTable_Right[2] = ColorR2
		lineTable_Right[3] = ColorG2
		lineTable_Right[4] = ColorB2
		lineTable_Right[5] = ColorA2
		lineTable_Right[6] = fontSize
		lineTable_Right[7] = fontFace
		lineTable_Right[8] = fontFlag
	end

	function CoolTip:AddSpecial(widgetType, index, subIndex, ...)
		local currentIndex = CoolTip.Indexes
		local currentSubIndex = CoolTip.SubIndexes
		CoolTip.isSpecial = true

		widgetType = string.lower(widgetType)

		if (widgetType == "line") then
			if (subIndex) then
				CoolTip.Indexes = index
				CoolTip.SubIndexes = subIndex-1
			else
				CoolTip.Indexes = index-1
			end

			CoolTip:AddLine(...)

			if (subIndex) then
				CoolTip.Indexes = currentIndex
				CoolTip.SubIndexes = currentSubIndex + 1
			else
				CoolTip.Indexes = currentIndex + 1
			end

		elseif (widgetType == "icon") then
			CoolTip.Indexes = index
			if (subIndex) then
				CoolTip.SubIndexes = subIndex
			end

			CoolTip:AddIcon(...)

			CoolTip.Indexes = currentIndex
			if (subIndex) then
				CoolTip.SubIndexes = currentSubIndex
			end

		elseif (widgetType == "statusbar") then
			CoolTip.Indexes = index
			if (subIndex) then
				CoolTip.SubIndexes = subIndex
			end

			CoolTip:AddStatusBar(...)
			CoolTip.Indexes = currentIndex
			if (subIndex) then
				CoolTip.SubIndexes = currentSubIndex
			end

		elseif (widgetType == "menu") then
			CoolTip.Indexes = index
			if (subIndex) then
				CoolTip.SubIndexes = subIndex
			end

			CoolTip:AddMenu(...)

			CoolTip.Indexes = currentIndex
			if (subIndex) then
				CoolTip.SubIndexes = currentSubIndex
			end
		end

		CoolTip.isSpecial = false
	end

	--search key: ~fromline
	function CoolTip:AddFromTable(thisTable)
		for index, menu in ipairs(thisTable) do
			if (menu.func) then
				CoolTip:AddMenu(menu.type or 1, menu.func, menu.param1, menu.param2, menu.param3, nil, menu.icon)

			elseif (menu.statusbar) then
				CoolTip:AddStatusBar(menu.value, menu.type or 1, menu.color, true)

			elseif (menu.icon) then
				CoolTip:AddIcon(menu.icon, menu.type or 1, menu.side or 1, menu.width, menu.height, menu.l, menu.r, menu.t, menu.b, menu.color)

			elseif (menu.textleft or menu.textright or menu.text) then
				CoolTip:AddLine(menu.text, "", menu.type, menu.color, menu.color)
			end
		end
	end

----------------------------------------------------------------------
	--serach key: ~start
	function CoolTip:Show(frame, menuType, color)
		CoolTip.hadInteractions = false
		return CoolTip:ShowCooltip(frame, menuType, color)
	end

	function CoolTip:ShowCooltip(frame, menuType, color)
		frame1:SetFrameStrata("TOOLTIP")
		frame2:SetFrameStrata("TOOLTIP")
		frame1:SetParent(UIParent)
		frame2:SetParent(UIParent)

		CoolTip.hadInteractions = false

		if (frame) then
			--check if is a details framework widget
			if (frame.dframework) then
				frame = frame.widget
			end
			CoolTip:SetHost(frame)
		end

		if (menuType) then
			CoolTip:SetType(menuType)
		end

		if (color) then
			CoolTip:SetColor(1, color)
			CoolTip:SetColor(2, color)
		end

		if (CoolTip.Type == 1 or CoolTip.Type == 2) then
			return CoolTip:BuildTooltip()

		elseif (CoolTip.Type == 3) then
			return CoolTip:BuildCooltip()
		end
	end

	function CoolTip:Hide()
		return CoolTip:Close()
	end

	function CoolTip:Close()
		CoolTip.active = false
		CoolTip.Host = nil
		DF:FadeFrame(frame1, 1)
		DF:FadeFrame(frame2, 1)
	end

	--old function call
	function CoolTip:ShowMe(host, arg2) --drunk code
		--ignore if mouse is within the frame region
		if (CoolTip.mouseOver) then
			return
		end
		if (not host or not arg2) then --hide the frame
			CoolTip:Close()
		end
	end

	--search key: ~inject
	function CoolTip:ExecFunc(host, fromClick)
		if (host.dframework) then
			if (not host.widget.CoolTip) then
				host.widget.CoolTip = host.CoolTip
			end
			host = host.widget
		end

		CoolTip:Reset()
		CoolTip:SetType(host.CoolTip.Type)
		CoolTip:SetFixedParameter(host.CoolTip.FixedValue)
		CoolTip:SetColor(CONST_MENU_TYPE_MAINMENU, host.CoolTip.MainColor or "transparent")
		CoolTip:SetColor(CONST_MENU_TYPE_SUBMENU, host.CoolTip.SubColor or "transparent")

		local okay, errortext = pcall(host.CoolTip.BuildFunc, host, host.CoolTip and host.CoolTip.FixedValue)
		if (not okay) then
			CoolTip:PrintDebug("ExecFunc() injected function error:", errortext)
		end

		CoolTip:SetOwner(host, host.CoolTip.MyAnchor, host.CoolTip.HisAnchor, host.CoolTip.X, host.CoolTip.Y)

		local options = host.CoolTip.Options
		if (type(options) == "function") then
			local runCompleted, returnedOptions = pcall(options)
			if (not runCompleted) then
				errortext = returnedOptions
				CoolTip:PrintDebug("ExecFunc() options function error:", errortext)
				options = nil
			else
				options = returnedOptions
			end
		end

		if (options) then
			if (type(options) == "table") then
				for optionName, optionValue in pairs(options) do
					CoolTip:SetOption(optionName, optionValue)
				end
			else
				CoolTip:PrintDebug("ExecFunc() options function did not returned a table.")
			end
		end

		if (CoolTip.Indexes == 0) then
			if (host.CoolTip.Default) then
				CoolTip:SetType(CONST_COOLTIP_TYPE_TOOLTIP)
				CoolTip:AddLine(host.CoolTip.Default, nil, 1, "white")
			end
		end

		CoolTip:ShowCooltip()

		if (fromClick) then
			frame1:Flash (0.05, 0.05, 0.2, true, 0, 0)
		end
	end

	local wait = 0.2
	local InjectOnUpdateEnter = function(self, deltaTime)
		elapsedTime = elapsedTime + deltaTime
		if (elapsedTime > wait) then
			self:SetScript("OnUpdate", nil)
			CoolTip:ExecFunc(self)
		end
	end

	local InjectOnUpdateLeave = function(self, deltaTime)
		elapsedTime = elapsedTime + deltaTime
		if (elapsedTime > 0.2) then
			if (not CoolTip.mouseOver and not CoolTip.buttonOver and self == CoolTip.Host) then
				CoolTip:ShowMe(false)
			end
			self:SetScript("OnUpdate", nil)
		end
	end

	local InjectOnLeave = function(self)
		CoolTip.buttonOver = false

		if (CoolTip.active) then
			elapsedTime = 0
			self:SetScript("OnUpdate", InjectOnUpdateLeave)
		else
			self:SetScript("OnUpdate", nil)
		end

		if (self.CoolTip.OnLeaveFunc) then
			self.CoolTip.OnLeaveFunc(self)
		end

		if (self.OldOnLeaveScript) then
			self:OldOnLeaveScript()
		end
	end

	local InjectOnEnter = function(self)
		CoolTip.buttonOver = true
		if (CoolTip.active) then
			CoolTip:ExecFunc(self)
		else
			elapsedTime = 0
			wait = self.CoolTip.ShowSpeed or 0.2
			self:SetScript("OnUpdate", InjectOnUpdateEnter)
		end

		if (self.CoolTip.OnEnterFunc) then
			self.CoolTip.OnEnterFunc(self)
		end

		if (self.OldOnEnterScript) then
			self:OldOnEnterScript()
		end
	end

	function CoolTip:CoolTipInject(host, openOnClick)
		if (host.dframework) then
			if (not host.widget.CoolTip) then
				host.widget.CoolTip = host.CoolTip
			end
			host = host.widget
		end

		local coolTable = host.CoolTip
		if (not coolTable) then
			CoolTip:PrintDebug("CoolTipInject() host frame does not have a .CoolTip table.")
			return false
		end

		host.OldOnEnterScript = host:GetScript("OnEnter")
		host.OldOnLeaveScript = host:GetScript("OnLeave")

		host:SetScript("OnEnter", InjectOnEnter)
		host:SetScript("OnLeave", InjectOnLeave)

		if (openOnClick) then
			if (host:GetObjectType() == "Button") then
				host:SetScript("OnClick", function() CoolTip:ExecFunc(host, true) end)
			end
		end

		return true
	end

	--all done
	CoolTip:ClearAllOptions()

	function CoolTip:Preset(presetId, fromReset)
		if (not fromReset) then
			self:Reset(true)
		end

		if (presetId == 1) then
			self:SetOption("TextFont", DF:GetBestFontForLanguage())
			self:SetOption("TextColor", "orange")
			self:SetOption("TextSize", 12)
			self:SetOption("ButtonsYMod", -4)
			self:SetOption("YSpacingMod", -4)
			self:SetOption("IgnoreButtonAutoHeight", true)
			self:SetColor(1, 0.5, 0.5, 0.5, 0.5)

		elseif (presetId == 2) then --used by most of the widgets
			self:SetOption("TextFont", DF:GetBestFontForLanguage())
			self:SetOption("TextColor", "orange")
			self:SetOption("TextSize", 12)
			self:SetOption("FixedWidth", 220)
			self:SetOption("ButtonsYMod", -4)
			self:SetOption("YSpacingMod", -4)
			self:SetOption("IgnoreButtonAutoHeight", true)
			self:SetColor(1, defaultBackdropColor)
			self:SetColor(2, defaultBackdropColor)

			self:SetBackdrop(1, defaultBackdrop, defaultBackdropColor, defaultBackdropBorderColor)
			self:SetBackdrop(2, defaultBackdrop, defaultBackdropColor, defaultBackdropBorderColor)

		elseif (presetId == 3) then --default used when Cooltip:Reset() is called
			self:SetOption("TextFont", DF:GetBestFontForLanguage())
			self:SetOption("TextColor", "orange")
			self:SetOption("TextSize", 12)
			self:SetOption("ButtonsYMod", -4)
			self:SetOption("YSpacingMod", -4)
			self:SetOption("IgnoreButtonAutoHeight", true)
			self:SetColor(1, defaultBackdropColor)
			self:SetColor(2, defaultBackdropColor)

			self:SetBackdrop(1, defaultBackdrop, defaultBackdropColor, defaultBackdropBorderColor)
			self:SetBackdrop(2, defaultBackdrop, defaultBackdropColor, defaultBackdropBorderColor)
		end
	end

	function CoolTip:QuickTooltip(host, ...)
		CoolTip:Preset(2)
		CoolTip:SetHost(host)

		for i = 1, select("#", ...) do
			local line = select(i, ...)
			CoolTip:AddLine(line)
		end

		CoolTip:ShowCooltip()
	end

	function CoolTip:InjectQuickTooltip(host, ...)
		host.CooltipQuickTooltip = {...}
		host:HookScript("OnEnter", function()
			CoolTip:QuickTooltip(host, unpack(host.CooltipQuickTooltip))
		end)
		host:HookScript("OnLeave", function()
			CoolTip:Hide()
		end)
	end
	return CoolTip
end

DF:CreateCoolTip()