--> details main objects
local _detalhes = 		_G._detalhes
local gump = 			_detalhes.gump

local _rawset = rawset --> lua local
local _rawget = rawget --> lua local
local _setmetatable = setmetatable --> lua local
local _unpack = unpack --> lua local
local _type = type --> lua local
local _math_floor = math.floor --> lua local
local loadstring = loadstring --> lua local

local cleanfunction = function() end
local APIImageFunctions = false
local ImageMetaFunctions = {}


------------------------------------------------------------------------------------------------------------
--> metatables

	ImageMetaFunctions.__call = function (_table, value)
		return self.image:SetTexture (value)
	end
	
------------------------------------------------------------------------------------------------------------
--> members

	--> shown
	local gmember_shown = function (_object)
		return _object:IsShown()
	end
	--> frame width
	local gmember_width = function (_object)
		return _object.image:GetWidth()
	end
	--> frame height
	local gmember_height = function (_object)
		return _object.image:GetHeight()
	end
	--> texture
	local gmember_texture = function (_object)
		return _object.image:GetTexture()
	end
	--> alpha
	local gmember_alpha = function (_object)
		return _object.image:GetAlpha()
	end

	local get_members_function_index = {
		["shown"] = gmember_shown,
		["alpha"] = gmember_alpha,
		["width"] = gmember_width,
		["height"] = gmember_height,
		["texture"] = gmember_texture,
	}
	
	ImageMetaFunctions.__index = function (_table, _member_requested)

		local func = get_members_function_index [_member_requested]
		if (func) then
			return func (_table, _member_requested)
		end
		
		local fromMe = _rawget (_table, _member_requested)
		if (fromMe) then
			return fromMe
		end
		
		return ImageMetaFunctions [_member_requested]
	end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	--> show
	local smember_show = function (_object, _value)
		if (_value) then
			return _object:Show()
		else
			return _object:Hide()
		end
	end
	--> hide
	local smember_hide = function (_object, _value)
		if (not _value) then
			return _object:Show()
		else
			return _object:Hide()
		end
	end
	--> texture
	local smember_texture = function (_object, _value)
		return _object.image:SetTexture (_value)
	end
	--> width
	local smember_width = function (_object, _value)
		return _object.image:SetWidth (_value)
	end
	--> height
	local smember_height = function (_object, _value)
		return _object.image:SetHeight (_value)
	end
	--> alpha
	local smember_alpha = function (_object, _value)
		return _object.image:SetAlpha (_value)
	end	
	--> color
	local smember_color = function (_object, _value)
		local _value1, _value2, _value3 = gump:ParseColors (_value)
		return _object.image:SetTexture (_value1, _value2, _value3)
	end

	local set_members_function_index = {
		["show"] = smember_show,
		["hide"] = smember_hide,
		["alpha"] = smember_alpha,
		["width"] = smember_width,
		["height"] = smember_height,
		["texture"] = smember_texture,
		["color"] = smember_color,
	}
	
	ImageMetaFunctions.__newindex = function (_table, _key, _value)
		local func = set_members_function_index [_key]
		if (func) then
			return func (_table, _value)
		else
			return _rawset (_table, _key, _value)
		end
	end
	
------------------------------------------------------------------------------------------------------------
--> methods
--> show & hide
	function ImageMetaFunctions:IsShown()
		return self.image:IsShown()
	end
	function ImageMetaFunctions:Show()
		return self.image:Show()
	end
	function ImageMetaFunctions:Hide()
		return self.image:Hide()
	end
	
-- setpoint
	function ImageMetaFunctions:SetPoint (v1, v2, v3, v4, v5)
		v1, v2, v3, v4, v5 = gump:CheckPoints (v1, v2, v3, v4, v5, self)
		if (not v1) then
			print ("Invalid parameter for SetPoint")
			return
		end
		return self.widget:SetPoint (v1, v2, v3, v4, v5)
	end

-- sizes
	function ImageMetaFunctions:SetSize (w, h)
		if (w) then
			self.image:SetWidth (w)
		end
		if (h) then
			return self.image:SetHeight (h)
		end
	end
	
------------------------------------------------------------------------------------------------------------
--> scripts

------------------------------------------------------------------------------------------------------------
--> object constructor

function gump:NewImage (parent, container, name, member, w, h, texture, layer)

	if (not parent) then
		return nil
	end
	if (not container) then
		container = parent
	end
	
	if (not name) then
		name = "DetailsPictureNumber" .. gump.PictureNameCounter
		gump.PictureNameCounter = gump.PictureNameCounter + 1
	end
	
	if (name:find ("$parent")) then
		name = name:gsub ("$parent", parent:GetName())
	end
	
	local ImageObject = {type = "image", dframework = true}

	if (member) then
		parent [member] = ImageObject
	end
	
	if (parent.dframework) then
		parent = parent.widget
	end
	if (container.dframework) then
		container = container.widget
	end

	texture = texture or ""
	
	ImageObject.image = parent:CreateTexture (name, layer or "OVERLAY")
	ImageObject.widget = ImageObject.image
	
	if (not APIImageFunctions) then
		APIImageFunctions = true
		local idx = getmetatable (ImageObject.image).__index
		for funcName, funcAddress in pairs (idx) do 
			if (not ImageMetaFunctions [funcName]) then
				ImageMetaFunctions [funcName] = function (object, ...)
					local x = loadstring ( "return _G."..object.image:GetName()..":"..funcName.."(...)")
					return x (...)
				end
			end
		end
	end	
	
	ImageObject.image.MyObject = ImageObject

	if (w) then
		ImageObject.image:SetWidth (w)
	end
	if (h) then
		ImageObject.image:SetHeight (h)
	end
	if (texture) then
		ImageObject.image:SetTexture (texture)
	end
	
	setmetatable (ImageObject, ImageMetaFunctions)
	
	return ImageObject
end