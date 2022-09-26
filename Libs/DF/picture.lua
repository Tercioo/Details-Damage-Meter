
local DF = _G ["DetailsFramework"]
if (not DF or not DetailsFrameworkCanLoad) then
	return
end

local _
local loadstring = loadstring

local APIImageFunctions = false

do
	local metaPrototype = {
		WidgetType = "image",
		SetHook = DF.SetHook,
		RunHooksForWidget = DF.RunHooksForWidget,

		dversion = DF.dversion,
	}

	--check if there's a metaPrototype already existing
	if (_G[DF.GlobalWidgetControlNames["image"]]) then
		--get the already existing metaPrototype
		local oldMetaPrototype = _G[DF.GlobalWidgetControlNames["image"]]
		--check if is older
		if ( (not oldMetaPrototype.dversion) or (oldMetaPrototype.dversion < DF.dversion) ) then
			--the version is older them the currently loading one
			--copy the new values into the old metatable
			for funcName, _ in pairs(metaPrototype) do
				oldMetaPrototype[funcName] = metaPrototype[funcName]
			end
		end
	else
		--first time loading the framework
		_G[DF.GlobalWidgetControlNames["image"]] = metaPrototype
	end
end

local ImageMetaFunctions = _G[DF.GlobalWidgetControlNames["image"]]

DF:Mixin(ImageMetaFunctions, DF.SetPointMixin)

------------------------------------------------------------------------------------------------------------
--metatables

	ImageMetaFunctions.__call = function(object, value)
		return object.image:SetTexture(value)
	end

------------------------------------------------------------------------------------------------------------
--members

	--shown
	local gmember_shown = function(object)
		return object:IsShown()
	end

	--frame width
	local gmember_width = function(object)
		return object.image:GetWidth()
	end

	--frame height
	local gmember_height = function(object)
		return object.image:GetHeight()
	end

	--texture
	local gmember_texture = function(object)
		return object.image:GetTexture()
	end

	--alpha
	local gmember_alpha = function(object)
		return object.image:GetAlpha()
	end

	--saturation
	local gmember_saturation = function(object)
		return object.image:GetDesaturated()
	end

	--atlas
	local gmember_atlas = function(object)
		return object.image:GetAtlas()
	end

	--texcoords
	local gmember_texcoord = function(object)
		return object.image:GetTexCoord()
	end

	local gmember_drawlayer = function(object)
		return object.image:GetDrawLayer()
	end

	local gmember_sublevel = function(object)
		local _, subLevel = object.image:GetDrawLayer()
		return subLevel
	end

	ImageMetaFunctions.GetMembers = ImageMetaFunctions.GetMembers or {}
	DF:Mixin(ImageMetaFunctions.GetMembers, DF.DefaultMetaFunctionsGet)

	ImageMetaFunctions.GetMembers["shown"] = gmember_shown
	ImageMetaFunctions.GetMembers["alpha"] = gmember_alpha
	ImageMetaFunctions.GetMembers["width"] = gmember_width
	ImageMetaFunctions.GetMembers["height"] = gmember_height
	ImageMetaFunctions.GetMembers["texture"] = gmember_texture
	ImageMetaFunctions.GetMembers["blackwhite"] = gmember_saturation
	ImageMetaFunctions.GetMembers["desaturated"] = gmember_saturation
	ImageMetaFunctions.GetMembers["atlas"] = gmember_atlas
	ImageMetaFunctions.GetMembers["texcoord"] = gmember_texcoord
	ImageMetaFunctions.GetMembers["drawlayer"] = gmember_drawlayer
	ImageMetaFunctions.GetMembers["sublevel"] = gmember_sublevel

	ImageMetaFunctions.__index = function(object, key)
		local func = ImageMetaFunctions.GetMembers[key]
		if (func) then
			return func(object, key)
		end

		local fromMe = rawget(object, key)
		if (fromMe) then
			return fromMe
		end

		return ImageMetaFunctions[key]
	end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	--show
	local smember_show = function(object, value)
		if (value) then
			return object:Show()
		else
			return object:Hide()
		end
	end

	--hide
	local smember_hide = function(object, value)
		if (not value) then
			return object:Show()
		else
			return object:Hide()
		end
	end

	--texture
	local smember_texture = function(object, value)
		if (type (value) == "table") then
			local r, g, b, a = DF:ParseColors(value)
			object.image:SetTexture (r, g, b, a or 1)
		else
			if (DF:IsHtmlColor (value)) then
				local r, g, b, a = DF:ParseColors(value)
				object.image:SetTexture (r, g, b, a or 1)
			else
				object.image:SetTexture (value)
			end
		end
	end

	--width
	local smember_width = function(object, value)
		return object.image:SetWidth(value)
	end

	--height
	local smember_height = function(object, value)
		return object.image:SetHeight(value)
	end

	--alpha
	local smember_alpha = function(object, value)
		return object.image:SetAlpha(value)
	end

	--color
	local smember_color = function(object, value)
		local r, g, b, a = DF:ParseColors(value)
		object.image:SetColorTexture(r, g, b, a or 1)
	end

	--vertex color
	local smember_vertexcolor = function(object, value)
		local r, g, b, a = DF:ParseColors(value)
		object.image:SetVertexColor(r, g, b, a or 1)
	end

	--desaturated
	local smember_desaturated = function(object, value)
		if (value) then
			object:SetDesaturated(true)
		else
			object:SetDesaturated(false)
		end
	end

	--texcoords
	local smember_texcoord = function(object, value)
		if (value) then
			object:SetTexCoord(unpack(value))
		else
			object:SetTexCoord(0, 1, 0, 1)
		end
	end

	--atlas
	local smember_atlas = function(object, value)
		if (value) then
			object:SetAtlas(value)
		end
	end

	--draw layer
	local smember_drawlayer = function(object, value)
		object.image:SetDrawLayer(value)
	end

	--sub level of the draw layer
	local smember_sublevel = function(object, value)
		local drawLayer = object:GetDrawLayer()
		object:SetDrawLayer(drawLayer, value)
	end

	--gradient
	local smember_gradient = function(object, value)
		if (type(value) == "table" and value.gradient and value.fromColor and value.toColor) then
			object.image:SetColorTexture(1, 1, 1, 1)
			local fromColor = DF:FormatColor("tablemembers", value.fromColor)
			local toColor = DF:FormatColor("tablemembers", value.toColor)
			object.image:SetGradient(value.gradient, fromColor, toColor)
		else
			error("texture.gradient expect a table{gradient = 'gradient type', fromColor = 'color', toColor = 'color'}")
		end
	end

	ImageMetaFunctions.SetMembers = ImageMetaFunctions.SetMembers or {}
	DF:Mixin(ImageMetaFunctions.SetMembers, DF.DefaultMetaFunctionsSet)

	ImageMetaFunctions.SetMembers["show"] = smember_show
	ImageMetaFunctions.SetMembers["hide"] = smember_hide
	ImageMetaFunctions.SetMembers["alpha"] = smember_alpha
	ImageMetaFunctions.SetMembers["width"] = smember_width
	ImageMetaFunctions.SetMembers["height"] = smember_height
	ImageMetaFunctions.SetMembers["texture"] = smember_texture
	ImageMetaFunctions.SetMembers["texcoord"] = smember_texcoord
	ImageMetaFunctions.SetMembers["color"] = smember_color
	ImageMetaFunctions.SetMembers["vertexcolor"] = smember_vertexcolor
	ImageMetaFunctions.SetMembers["blackwhite"] = smember_desaturated
	ImageMetaFunctions.SetMembers["desaturated"] = smember_desaturated
	ImageMetaFunctions.SetMembers["atlas"] = smember_atlas
	ImageMetaFunctions.SetMembers["drawlayer"] = smember_drawlayer
	ImageMetaFunctions.SetMembers["sublevel"] = smember_sublevel
	ImageMetaFunctions.SetMembers["gradient"] = smember_gradient

	ImageMetaFunctions.__newindex = function(object, key, value)
		local func = ImageMetaFunctions.SetMembers[key]
		if (func) then
			return func(object, value)
		else
			return rawset(object, key, value)
		end
	end

------------------------------------------------------------------------------------------------------------
--methods
	--size
	function ImageMetaFunctions:SetSize(width, height)
		if (width) then
			self.image:SetWidth(width)
		end
		if (height) then
			return self.image:SetHeight(height)
		end
	end

	function ImageMetaFunctions:SetGradient(gradientType, fromColor, toColor)
		fromColor = DF:FormatColor("tablemembers", fromColor)
		toColor = DF:FormatColor("tablemembers", toColor)
		self.image:SetGradient(gradientType, fromColor, toColor)
	end

------------------------------------------------------------------------------------------------------------
--object constructor

	function DF:CreateTexture(parent, texture, width, height, layer, coords, member, name)
		return DF:NewImage(parent, texture, width, height, layer, coords, member, name)
	end

	function DF:CreateImage(parent, texture, width, height, layer, coords, member, name)
		return DF:NewImage(parent, texture, width, height, layer, coords, member, name)
	end

	function DF:NewImage(parent, texture, width, height, layer, texCoord, member, name)
		if (not parent) then
			return error("Details! FrameWork: parent not found.", 2)
		end

		if (not name) then
			name = "DetailsFrameworkPictureNumber" .. DF.PictureNameCounter
			DF.PictureNameCounter = DF.PictureNameCounter + 1
		end

		if (name:find("$parent")) then
			local parentName = DF.GetParentName(parent)
			name = name:gsub("$parent", parentName)
		end

		local ImageObject = {type = "image", dframework = true}

		if (member) then
			parent[member] = ImageObject
		end

		if (parent.dframework) then
			parent = parent.widget
		end

		texture = texture or ""

		ImageObject.image = parent:CreateTexture(name, layer or "OVERLAY")
		ImageObject.widget = ImageObject.image

		DF:Mixin(ImageObject.image, DF.WidgetFunctions)

		if (not APIImageFunctions) then
			APIImageFunctions = true
			local idx = getmetatable(ImageObject.image).__index
			for funcName, funcAddress in pairs(idx) do
				if (not ImageMetaFunctions[funcName]) then
					ImageMetaFunctions[funcName] = function(object, ...)
						local x = loadstring( "return _G['" .. object.image:GetName() .. "']:" .. funcName .. "(...)")
						return x(...)
					end
				end
			end
		end

		ImageObject.image.MyObject = ImageObject

		if (width) then
			ImageObject.image:SetWidth(width)
		end
		if (height) then
			ImageObject.image:SetHeight(height)
		end

		if (texture) then
			if (type(texture) == "table") then
				if (texture.gradient) then
					if (DF.IsDragonflight()) then
						ImageObject.image:SetColorTexture(1, 1, 1, 1)
						local fromColor = DF:FormatColor("tablemembers", texture.fromColor)
						local toColor = DF:FormatColor("tablemembers", texture.toColor)
						ImageObject.image:SetGradient(texture.gradient, fromColor, toColor)
					else
						local fromR, fromG, fromB, fromA = DF:ParseColors(texture.fromColor)
						local toR, toG, toB, toA = DF:ParseColors(texture.toColor)
						ImageObject.image:SetColorTexture(1, 1, 1, 1)
						ImageObject.image:SetGradientAlpha(texture.gradient, fromR, fromG, fromB, fromA, toR, toG, toB, toA)
					end
				else
					local r, g, b, a = DF:ParseColors(texture)
					ImageObject.image:SetColorTexture(r, g, b, a)
				end

			elseif (type(texture) == "string") then
				local isAtlas = C_Texture.GetAtlasInfo(texture)
				if (isAtlas) then
					ImageObject.image:SetAtlas(texture)
				else
					if (DF:IsHtmlColor(texture)) then
						local r, g, b = DF:ParseColors(texture)
						ImageObject.image:SetColorTexture(r, g, b)
					else
						ImageObject.image:SetTexture(texture)
					end
				end
			else
				ImageObject.image:SetTexture(texture)
			end
		end

		if (texCoord and type(texCoord) == "table" and texCoord[4]) then
			ImageObject.image:SetTexCoord(unpack(texCoord))
		end

		ImageObject.HookList = {
		}

		setmetatable(ImageObject, ImageMetaFunctions)

		return ImageObject
	end
