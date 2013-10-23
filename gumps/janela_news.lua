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
		
		--> text box
		local texto = frame:CreateFontString ("DetailsNewsWindowText", "overlay", "GameFontNormal")
		texto:SetPoint ("topleft", frame, "topleft", 100, -100)
		texto:SetJustifyH ("left")
		texto:SetJustifyV ("top")
		texto:SetTextColor (1, 1, 1)
		texto:SetWidth (400)
		texto:SetHeight (500)
		
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