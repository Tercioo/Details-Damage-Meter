--> details main objects
local _detalhes = 		_G._detalhes
local gump = 			_detalhes.gump

local _type = type
local _unpack = unpack

gump.LabelNameCounter = 1
gump.PictureNameCounter = 1

gump.debug = false

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> points
function gump:CheckPoints (v1, v2, v3, v4, v5, object)

	--bg_esq:SetPoint ("topleft", DmgRankFrame, 10, -215)

	if (not v1 and not v2) then
		return "topleft", object.widget:GetParent(), "topleft", 0, 0
	end
	
	if (_type (v1) == "string") then
		local frameGlobal = _G [v1]
		if (frameGlobal and frameGlobal.GetObjectType) then
			return gump:CheckPoints (frameGlobal, v2, v3, v4, v5, object)
		end
		
	elseif (_type (v2) == "string") then
		local frameGlobal = _G [v2]
		if (frameGlobal and frameGlobal.GetObjectType) then
			return gump:CheckPoints (v1, frameGlobal, v3, v4, v5, object)
		end
	end
	
	if (_type (v1) == "string" and _type (v2) == "table") then --> :setpoint ("left", frame, _, _, _)
		if (not v3 or _type (v3) == "number") then --> :setpoint ("left", frame, 10, 10)
			v1, v2, v3, v4, v5 = v1, v2, v1, v3, v4
		--else
			--> :setpoint ("left", frame, "left", 10, 10)
		end
		
	elseif (_type (v1) == "string" and _type (v2) == "number") then --> :setpoint ("topleft", x, y)
		v1, v2, v3, v4, v5 = v1, object.widget:GetParent(), v1, v2, v3
		
	elseif (_type (v1) == "number") then --> :setpoint (x, y) 
		v1, v2, v3, v4, v5 = "topleft", object.widget:GetParent(), "topleft", v1, v2

	elseif (_type (v1) == "table") then --> :setpoint (frame, x, y)
		v1, v2, v3, v4, v5 = "topleft", v1, "topleft", v2, v3
		
	end
	
	if (not v2) then
		v2 = object.widget:GetParent()
	elseif (v2.dframework) then
		v2 = v2.widget
	end
	
	return v1 or "topleft", v2, v3 or "topleft", v4 or 0, v5 or 0
end
	

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> color scheme

function gump:NewColor (_colorname, _colortable, _green, _blue, _alpha)

	if (_type (_colorname) ~= "string") then
		return _detalhes:NewError ("color name must be a string.")
	end

	if (gump.alias_text_colors [_colorname]) then
		return _detalhes:NewError (_colorname .. " already exists.")
	end
	
	if (_type (_colortable) == "table") then
		if (_colortable[1] and _colortable[2] and _colortable[3]) then
			_colortable[4] = _colortable[4] or 1
			gump.alias_text_colors [_colorname] = _colortable
		else
			return _detalhes:NewError ("invalid color table.")
		end
	elseif (_colortable and _green and _blue) then
		_alpha = _alpha or 1
		gump.alias_text_colors [_colorname] = {_colortable, _green, _blue, _alpha}
	else
		return _detalhes:NewError ("invalid parameter.")
	end
	
	return true
end

function gump:ParseColors (_arg1, _arg2, _arg3, _arg4)
	if (_type (_arg1) == "table") then
		_arg1, _arg2, _arg3, _arg4 = _unpack (_arg1)
	elseif (_type (_arg1) == "string") then
		local color = gump.alias_text_colors [_arg1]
		if (color) then
			_arg1, _arg2, _arg3, _arg4 = _unpack (color)
		else
			_arg1, _arg2, _arg3, _arg4 = _unpack (gump.alias_text_colors.none)
		end
	end
	
	if (not _arg4) then
		_arg4 = 1
	end
	
	return _arg1, _arg2, _arg3, _arg4
end