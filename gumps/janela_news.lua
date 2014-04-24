local _detalhes = 		_G._detalhes
local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )

local g =	_detalhes.gump
local _

function _detalhes:OpenNewsWindow()
	local news_window = _detalhes:CreateOrOpenNewsWindow()
	
	news_window:Title (Loc ["STRING_NEWS_TITLE"])
	news_window:Text (Loc ["STRING_VERSION_LOG"])
	news_window:Icon ("Interface\\CHARACTERFRAME\\TempPortrait")
	news_window:Show()
end

function _detalhes:CreateOrOpenNewsWindow()
	local frame = _G.DetailsNewsWindow

	if (not frame) then
		--> construir a janela de news
		frame = CreateFrame ("frame", "DetailsNewsWindow", UIParent)
		frame:SetPoint ("center", UIParent, "center")
		frame:SetFrameStrata ("HIGH")
		frame:SetMovable (true)
		frame:SetWidth (512)
		frame:SetHeight (512)
		tinsert (UISpecialFrames, "DetailsNewsWindow")
		
		frame:SetScript ("OnMouseDown", function() frame:StartMoving() end)
		frame:SetScript ("OnMouseUp", function() frame:StopMovingOrSizing() end)
	
		--> fundo
		local fundo = frame:CreateTexture (nil, "border")
		fundo:SetTexture ("Interface\\Addons\\Details\\images\\whatsnew")
		fundo:SetAllPoints (frame)
		
		--> fechar
		local close = CreateFrame ("Button", "DetailsNewsWindowClose", frame, "UIPanelCloseButton")
		close:SetWidth (32)
		close:SetHeight (32)
		close:SetPoint ("bottomright", frame, "topright", 3, -40)
		close:SetScript ("OnClick", function() frame:Hide() end)
		
		--> avatar
		local avatar = frame:CreateTexture (nil, "background")
		avatar:SetPoint ("topleft", frame, "topleft", 5, -5)
		
		--> titulo
		local titulo = _detalhes.gump:NewLabel (frame, nil, "$parentTitle", nil, "", "GameFontHighlightLeft", 12, {227/255, 186/255, 4/255})
		titulo:SetPoint ("center", frame, "center")
		titulo:SetPoint ("top", frame, "top", 0, -18)
		
		--> reinstall textura
		local textura = _detalhes.gump:NewImage (frame, [[Interface\DialogFrame\DialogAlertIcon]], 64, 64, nil, nil, nil, "$parentExclamacao")
		textura:SetPoint ("topleft", frame, "topleft", 60, -20)
		--> reinstall aviso
		local reinstall = _detalhes.gump:NewLabel (frame, nil, "$parentReinstall", nil, "", "GameFontHighlightLeft", 10)
		reinstall:SetPoint ("left", textura, "right", 2, -2)
		reinstall.text = Loc ["STRING_NEWS_REINSTALL"]
		
		
		local frame_upper = CreateFrame ("scrollframe", nil, frame)
		local frame_lower = CreateFrame ("frame", nil, frame_upper)
		frame_lower:SetSize (380, 390)
		frame_upper:SetPoint ("topleft", frame, "topleft", 85, -100)
		frame_upper:SetWidth (395)
		frame_upper:SetHeight (370)
		frame_upper:SetBackdrop({
				bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", 
				tile = true, tileSize = 16,
				insets = {left = 1, right = 1, top = 0, bottom = 1},})
		frame_upper:SetBackdropColor (.1, .1, .1, .3)
		frame_upper:SetScrollChild (frame_lower)
		
		local slider = CreateFrame ("slider", nil, frame)
		slider.bg = slider:CreateTexture (nil, "background")
		slider.bg:SetAllPoints (true)
		slider.bg:SetTexture (0, 0, 0, 0.5)
		
		slider.thumb = slider:CreateTexture (nil, "OVERLAY")
		slider.thumb:SetTexture ("Interface\\Buttons\\UI-ScrollBar-Knob")
		slider.thumb:SetSize (25, 25)
		
		slider:SetThumbTexture (slider.thumb)
		slider:SetOrientation ("vertical");
		slider:SetSize (16, 369)
		slider:SetPoint ("topleft", frame_upper, "topright")
		slider:SetMinMaxValues (0, 1000)
		slider:SetValue(0)
		slider:SetScript("OnValueChanged", function (self)
		      frame_upper:SetVerticalScroll (self:GetValue())
		end)
  
		frame_upper:EnableMouseWheel (true)
		frame_upper:SetScript("OnMouseWheel", function (self, delta)
		      local current = slider:GetValue()
		      if (IsShiftKeyDown() and (delta > 0)) then
				slider:SetValue(0)
		      elseif (IsShiftKeyDown() and (delta < 0)) then
				slider:SetValue (1000)
		      elseif ((delta < 0) and (current < 1000)) then
				slider:SetValue (current + 20)
		      elseif ((delta > 0) and (current > 1)) then
				slider:SetValue (current - 20)
		      end
		end)
  
		--> text box
		local texto = frame_lower:CreateFontString ("DetailsNewsWindowText", "overlay", "GameFontNormal")
		texto:SetPoint ("topleft", frame_lower, "topleft")
		texto:SetJustifyH ("left")
		texto:SetJustifyV ("top")
		texto:SetTextColor (1, 1, 1)
		texto:SetWidth (380)
		texto:SetHeight (1400)
		
		function frame:Title (title)
			titulo:SetText (title or "")
		end
		
		function frame:Text (text)
			texto:SetText (text or "")
		end
		
		function frame:Icon (path)
			avatar:SetTexture (path or nil)
		end
		
		frame:Hide()
	end
	
	return frame
end