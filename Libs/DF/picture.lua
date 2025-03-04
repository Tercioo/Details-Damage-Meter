
---@type detailsframework
local detailsFramework = _G["DetailsFramework"]
if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

local _
local APIImageFunctions = false

do
	local metaPrototype = {
		WidgetType = "image",
		dversion = detailsFramework.dversion,
	}

	--check if there's a metaPrototype already existing
	if (_G[detailsFramework.GlobalWidgetControlNames["image"]]) then
		--get the already existing metaPrototype
		local oldMetaPrototype = _G[detailsFramework.GlobalWidgetControlNames["image"]]
		--check if is older
		if ( (not oldMetaPrototype.dversion) or (oldMetaPrototype.dversion < detailsFramework.dversion) ) then
			--the version is older them the currently loading one
			--copy the new values into the old metatable
			for funcName, _ in pairs(metaPrototype) do
				oldMetaPrototype[funcName] = metaPrototype[funcName]
			end
		end
	else
		--first time loading the framework
		_G[detailsFramework.GlobalWidgetControlNames["image"]] = metaPrototype
	end
end

local ImageMetaFunctions = _G[detailsFramework.GlobalWidgetControlNames["image"]]

detailsFramework:Mixin(ImageMetaFunctions, detailsFramework.SetPointMixin)
detailsFramework:Mixin(ImageMetaFunctions, detailsFramework.ScriptHookMixin)

------------------------------------------------------------------------------------------------------------
--metatables

	ImageMetaFunctions.__call = function(object, value)
		return object.image:SetTexture(value)
	end

------------------------------------------------------------------------------------------------------------
--members

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

	ImageMetaFunctions.GetMembers = ImageMetaFunctions.GetMembers or {}
	detailsFramework:Mixin(ImageMetaFunctions.GetMembers, detailsFramework.DefaultMetaFunctionsGet)
	detailsFramework:Mixin(ImageMetaFunctions.GetMembers, detailsFramework.LayeredRegionMetaFunctionsGet)

	ImageMetaFunctions.GetMembers["alpha"] = gmember_alpha
	ImageMetaFunctions.GetMembers["width"] = gmember_width
	ImageMetaFunctions.GetMembers["height"] = gmember_height
	ImageMetaFunctions.GetMembers["texture"] = gmember_texture
	ImageMetaFunctions.GetMembers["blackwhite"] = gmember_saturation
	ImageMetaFunctions.GetMembers["desaturated"] = gmember_saturation
	ImageMetaFunctions.GetMembers["atlas"] = gmember_atlas
	ImageMetaFunctions.GetMembers["texcoord"] = gmember_texcoord

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

	--texture
	local smember_texture = function(object, value)
		if (type(value) == "table") then
			local red, green, blue, alpha = detailsFramework:ParseColors(value)
			object.image:SetTexture(red, green, blue, alpha)
		else
			if (detailsFramework:IsHtmlColor(value)) then
				local red, green, blue, alpha = detailsFramework:ParseColors(value)
				object.image:SetTexture(red, green, blue, alpha)
			else
				object.image:SetTexture(value)
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
		local red, green, blue, alpha = detailsFramework:ParseColors(value)
		object.image:SetColorTexture(red, green, blue, alpha)
	end

	--vertex color
	local smember_vertexcolor = function(object, value)
		local red, green, blue, alpha = detailsFramework:ParseColors(value)
		object.image:SetVertexColor(red, green, blue, alpha)
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

	--gradient
	local smember_gradient = function(object, value)
		if (type(value) == "table" and value.gradient and value.fromColor and value.toColor) then
			object.image:SetColorTexture(1, 1, 1, 1)
			local fromColor = detailsFramework:FormatColor("tablemembers", value.fromColor)
			local toColor = detailsFramework:FormatColor("tablemembers", value.toColor)
			object.image:SetGradient(value.gradient, fromColor, toColor)
		else
			error("texture.gradient expect a table{gradient = 'gradient type', fromColor = 'color', toColor = 'color'}")
		end
	end

	ImageMetaFunctions.SetMembers = ImageMetaFunctions.SetMembers or {}
	detailsFramework:Mixin(ImageMetaFunctions.SetMembers, detailsFramework.DefaultMetaFunctionsSet)
	detailsFramework:Mixin(ImageMetaFunctions.SetMembers, detailsFramework.LayeredRegionMetaFunctionsSet)

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

	function ImageMetaFunctions:SetGradient(gradientType, fromColor, toColor, bInvert)
		fromColor = detailsFramework:FormatColor("tablemembers", fromColor)
		toColor = detailsFramework:FormatColor("tablemembers", toColor)

		if (bInvert) then
			local temp = fromColor
			fromColor = toColor
			toColor = temp
		end

		self.image:SetGradient(gradientType, fromColor, toColor)
	end

------------------------------------------------------------------------------------------------------------
--object constructor

	---@class df_image : df_setpoint, texture, df_widgets
	---@field SetGradient fun(gradientType: "vertical"|"horizontal", fromColor: table, toColor: table)
	---@field SetPoint fun(self: table, anchorName1: anchor_name, anchorObject: table?, anchorName2: string?, xOffset: number?, yOffset: number?)
	---@field image texture

	---@class df_gradienttable : table
	---@field gradient "vertical"|"horizontal"
	---@field fromColor table|string
	---@field toColor table|string
	---@field invert boolean?

	---create an object that encapsulates a texture and add additional methods to it
	---this function is an alias of NewImage() with a different name and parameters in different order
	---@param parent frame
	---@param texture texturepath|textureid|df_gradienttable|nil
	---@param width number?
	---@param height number?
	---@param layer drawlayer?
	---@param coords {key1: number, key2: number, key3: number, key4: number}?
	---@param member string?
	---@param name string?
	---@return df_image
	function detailsFramework:CreateTexture(parent, texture, width, height, layer, coords, member, name)
		return detailsFramework:NewImage(parent, texture, width, height, layer, coords, member, name)
	end

	---create an object that encapsulates a texture and add additional methods to it
	---this function is an alias of NewImage() with a different name and parameters in different order
	---@param parent frame
	---@param texture texturepath|textureid|df_gradienttable|nil
	---@param width number?
	---@param height number?
	---@param layer drawlayer?
	---@param coords {key1: number, key2: number, key3: number, key4: number}?
	---@param member string?
	---@param name string?
	---@return df_image
	function detailsFramework:CreateImage(parent, texture, width, height, layer, coords, member, name)
		return detailsFramework:NewImage(parent, texture, width, height, layer, coords, member, name)
	end

	---create an object that encapsulates a texture and add additional methods to it
	---@param parent frame
	---@param texture texturepath|textureid|df_gradienttable|nil
	---@param width number?
	---@param height number?
	---@param layer drawlayer?
	---@param texCoord {key1: number, key2: number, key3: number, key4: number}?
	---@param member string?
	---@param name string?
	---@return df_image
	function detailsFramework:NewImage(parent, texture, width, height, layer, texCoord, member, name)
		if (not parent) then
			return error("DetailsFrameWork: NewImage() parent not found.", 2)
		end

		if (not name) then
			name = "DetailsFrameworkPictureNumber" .. detailsFramework.PictureNameCounter
			detailsFramework.PictureNameCounter = detailsFramework.PictureNameCounter + 1
		end

		if (name:find("$parent")) then
			local parentName = detailsFramework:GetParentName(parent)
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

		ImageObject.image = parent:CreateTexture(name, layer or "overlay")
		ImageObject.widget = ImageObject.image

		detailsFramework:Mixin(ImageObject.image, detailsFramework.WidgetFunctions)

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

		if (texture) then
			if (type(texture) == "table") then
				if (texture.gradient) then
					---@type df_gradienttable
					local gradientTable = texture

					if (detailsFramework.IsDragonflight() or detailsFramework.IsNonRetailWowWithRetailAPI() or detailsFramework.IsWarWow()) then
						ImageObject.image:SetColorTexture(1, 1, 1, 1)
						local fromColor = detailsFramework:FormatColor("tablemembers", gradientTable.fromColor)
						local toColor = detailsFramework:FormatColor("tablemembers", gradientTable.toColor)

						if (gradientTable.invert) then
							local temp = fromColor
							fromColor = toColor
							toColor = temp
						end

						ImageObject.image:SetGradient(gradientTable.gradient, fromColor, toColor)
					else
						local fromR, fromG, fromB, fromA = detailsFramework:ParseColors(gradientTable.fromColor)
						local toR, toG, toB, toA = detailsFramework:ParseColors(gradientTable.toColor)

						if (gradientTable.invert) then
							local temp = fromR
							fromR = toR
							toR = temp
							temp = fromG
							fromG = toG
							toG = temp
							temp = fromB
							fromB = toB
							toB = temp
							temp = fromA
							fromA = toA
							toA = temp
						end

						ImageObject.image:SetColorTexture(1, 1, 1, 1)
						ImageObject.image:SetGradientAlpha(gradientTable.gradient, fromR, fromG, fromB, fromA, toR, toG, toB, toA)
					end
				else
					local r, g, b, a = detailsFramework:ParseColors(texture)
					ImageObject.image:SetColorTexture(r, g, b, a)
				end

			elseif (type(texture) == "string") then
				local isAtlas = C_Texture.GetAtlasInfo(texture)
				if (isAtlas) then
					ImageObject.image:SetAtlas(texture)
				else
					if (detailsFramework:IsHtmlColor(texture)) then
						local r, g, b = detailsFramework:ParseColors(texture)
						ImageObject.image:SetColorTexture(r, g, b)
					else
						ImageObject.image:SetTexture(texture)
					end
				end
			else
				local textureType = type(texture)
				if (textureType == "string" or textureType == "number") then
					ImageObject.image:SetTexture(texture)
				end
			end
		end

		if (texCoord and type(texCoord) == "table" and texCoord[4]) then
			ImageObject.image:SetTexCoord(unpack(texCoord))
		end

		if (width) then
			ImageObject.image:SetWidth(width)
		end
		if (height) then
			ImageObject.image:SetHeight(height)
		end

		ImageObject.HookList = {
		}

		setmetatable(ImageObject, ImageMetaFunctions)

		return ImageObject
	end

function detailsFramework:CreateHighlightTexture(parent, parentKey, alpha, name, texture)
	if (not name) then
		name = "DetailsFrameworkPictureNumber" .. detailsFramework.PictureNameCounter
		detailsFramework.PictureNameCounter = detailsFramework.PictureNameCounter + 1
	end

	local highlightTexture = parent:CreateTexture(name, "highlight")
	highlightTexture:SetTexture(texture or [[Interface\Buttons\WHITE8X8]])
	highlightTexture:SetAlpha(alpha or 0.1)
	highlightTexture:SetBlendMode("ADD")
	highlightTexture:SetAllPoints()

	if (parentKey) then
		parent[parentKey] = highlightTexture
	end

	return highlightTexture
end

---Set an atlas to a texture object
---Accpets a string (atlasname) or a table (atlasinfo)
---@param self table
---@param textureObject texture
---@param atlas atlasinfo|atlasname
---@param useAtlasSize boolean?
---@param filterMode texturefilter?
---@param resetTexCoords boolean?
function detailsFramework:SetAtlas(textureObject, atlas, useAtlasSize, filterMode, resetTexCoords)
	local isAtlas = C_Texture.GetAtlasInfo(type(atlas) == "string" and atlas or "--")
	if (isAtlas and type(atlas) == "string") then
		textureObject:SetAtlas(atlas, useAtlasSize, filterMode, resetTexCoords)
		return
	end

	if (type(atlas) == "table") then
		---@cast atlas df_atlasinfo
		local atlasInfo = atlas

		local atlasName = atlas.atlas
		if (atlasName) then
			isAtlas = C_Texture.GetAtlasInfo(atlasName)
			if (isAtlas) then
				textureObject:SetAtlas(atlasName, useAtlasSize, filterMode, resetTexCoords)
				return
			end
		end

		if (useAtlasSize) then
			if (atlasInfo.width) then
				textureObject:SetWidth(atlasInfo.width)
			end
			if (atlasInfo.height) then
				textureObject:SetHeight(atlasInfo.height)
			end
		end

		textureObject:SetHorizTile(atlasInfo.tilesHorizontally or false)
		textureObject:SetVertTile(atlasInfo.tilesVertically or false)

		textureObject:SetTexture(atlasInfo.file, atlasInfo.tilesHorizontally and "REPEAT" or "CLAMP", atlasInfo.tilesVertically and "REPEAT" or "CLAMP", filterMode or "LINEAR")
		textureObject:SetTexCoord(atlasInfo.leftTexCoord or 0, atlasInfo.rightTexCoord or 1, atlasInfo.topTexCoord or 0, atlasInfo.bottomTexCoord or 1)

		if (atlasInfo.desaturated) then
			textureObject:SetDesaturated(true)
		else
			textureObject:SetDesaturated(false)
			if (atlasInfo.desaturation) then
				textureObject:SetDesaturation(atlasInfo.desaturation)
			end
		end

		if (atlasInfo.colorName) then
			textureObject:SetVertexColor(detailsFramework:ParseColors(atlasInfo.colorName))
		else
			if (atlasInfo.vertexRed or atlasInfo.vertexGreen or atlasInfo.vertexBlue or atlasInfo.vertexAlpha) then
				textureObject:SetVertexColor(atlasInfo.vertexRed or 1, atlasInfo.vertexGreen or 1, atlasInfo.vertexBlue or 1, atlasInfo.vertexAlpha or 1)
			end
		end

	elseif (type(atlas) == "string" or type(atlas) == "number") then
		---@cast atlas string
		textureObject:SetTexture(atlas)
	end
end

---get the passed atlas, convert it to string with a texture escape sequence, and return it
---textureHeight overrides the height of the atlas
---textureWidth overrides the width of the atlas
---@param self table
---@param atlas atlasinfo|atlasname
---@param textureHeight number?
---@param textureWidth number?
---@return string
function detailsFramework:CreateAtlasString(atlas, textureHeight, textureWidth)
	local file, width, height, leftTexCoord, rightTexCoord, topTexCoord, bottomTexCoord, r, g, b, a, nativeWidth, nativeHeight = detailsFramework:ParseTexture(atlas)

	nativeWidth = nativeWidth or width or textureWidth
	nativeHeight = nativeHeight or height or textureHeight

	if (not height) then
		return "|T" .. file .. "|t"
	elseif (not width) then
		return "|T" .. file .. ":" .. height .. "|t"
	elseif (not leftTexCoord) then
		return "|T" .. file .. ":" .. height .. ":" .. width .. "|t"
	elseif (not r) then
		--the two zeros are the x and y offset
		--texCoords are multiplied by the heigh and width to get the actual pixel position
		local str = "|T" .. file .. ":" .. (textureHeight or height) .. ":" .. (textureWidth or width) .. ":0:0:" .. nativeWidth .. ":" .. nativeHeight .. ":" .. math.floor(leftTexCoord*nativeWidth) .. ":" .. math.floor(rightTexCoord*nativeWidth) .. ":" .. math.floor(topTexCoord*nativeHeight) .. ":" .. math.floor(bottomTexCoord*nativeHeight) .. "|t"
		return str
	else
		return "|T" .. file .. ":" .. (textureHeight or height) .. ":" .. (textureWidth or width) .. ":0:0:" .. nativeWidth .. ":" .. nativeHeight .. ":" .. math.floor(leftTexCoord*nativeWidth) .. ":" .. math.floor(rightTexCoord*nativeWidth) .. ":" .. math.floor(topTexCoord*nativeHeight) .. ":" .. math.floor(bottomTexCoord*nativeHeight) .. ":" .. r .. ":" .. g .. ":" .. b .. "|t"
	end
end

---Receives a texturepath or a textureid or an atlasname or an atlasinfo.
---Parse the data received and return the texture path or id, width, height and texcoords, what is available.
---nativeWidth and nativeHeight are the dimentions of the texture file in pixels.
---@param self table
---@param texture texturepath|textureid|atlasname|atlasinfo
---@param width number?
---@param height number?
---@param leftTexCoord number?
---@param rightTexCoord number?
---@param topTexCoord number?
---@param bottomTexCoord number?
---@param vertexRed number?
---@param vertexGreen number?
---@param vertexBlue number?
---@param vertexAlpha number?
---@return any texture
---@return number? width
---@return number? height
---@return number? leftTexCoord
---@return number? rightTexCoord
---@return number? topTexCoord
---@return number? bottomTexCoord
---@return number? red
---@return number? green
---@return number? blue
---@return number? alpha
---@return number? nativeWidth
---@return number? nativeHeight
function detailsFramework:ParseTexture(texture, width, height, leftTexCoord, rightTexCoord, topTexCoord, bottomTexCoord, vertexRed, vertexGreen, vertexBlue, vertexAlpha)
	local isAtlas
	if (type(texture) == "string") then
		isAtlas = C_Texture.GetAtlasInfo(texture)
	end

	if (isAtlas) then
		--ui atlasinfo
		---@type atlasinfo
		local atlasInfo = isAtlas
		local textureId = atlasInfo.file
		local texturePath = atlasInfo.filename
		return textureId or texturePath, width or atlasInfo.width, height or atlasInfo.height, atlasInfo.leftTexCoord, atlasInfo.rightTexCoord, atlasInfo.topTexCoord, atlasInfo.bottomTexCoord
	end

	if (type(texture) == "table") then
		---@type df_atlasinfo
		local atlasInfo = texture

		local r, g, b, a
		if (type(atlasInfo.colorName) == "string") then
			r, g, b, a = detailsFramework:ParseColors(atlasInfo.colorName)
		else
			r, g, b, a = atlasInfo.vertexRed or vertexRed, atlasInfo.vertexGreen or vertexGreen, atlasInfo.vertexBlue or vertexBlue, atlasInfo.vertexAlpha or vertexAlpha
		end

		local nativeWidth, nativeHeight = atlasInfo.nativeWidth, atlasInfo.nativeHeight
		return atlasInfo.file or atlasInfo.filename, width or atlasInfo.width, height or atlasInfo.height, atlasInfo.leftTexCoord or 0, atlasInfo.rightTexCoord or 1, atlasInfo.topTexCoord or 0, atlasInfo.bottomTexCoord or 1, r, g, b, a, nativeWidth, nativeHeight
	end

	if (type(vertexRed) == "string" or type(vertexRed) == "table") then
		--the color passed is a colorName or a colorTable
		vertexRed, vertexGreen, vertexBlue, vertexAlpha = detailsFramework:ParseColors(vertexRed)
	end

	return texture, width, height, leftTexCoord or 0, rightTexCoord or 1, topTexCoord or 0, bottomTexCoord or 1, vertexRed, vertexGreen, vertexBlue, vertexAlpha
end

---Use the passed arguments to create a table imitate an atlasinfo
---@param self table
---@param file any
---@param width number? width of the texture
---@param height number? height of the texture
---@param leftTexCoord number? left texture coordinate to use with SetTexCoord as firt parameter
---@param rightTexCoord number? right texture coordinate to use with SetTexCoord as second parameter
---@param topTexCoord number? top texture coordinate to use with SetTexCoord as third parameter
---@param bottomTexCoord number? bottom texture coordinate to use with SetTexCoord as fourth parameter
---@param tilesHorizontally boolean? if the texture should tile horizontally, used with texture:SetHorizTile(value)
---@param tilesVertically boolean? if the texture should tile vertically, used with texture:SetVertTile(value)
---@param vertexRed number|string? red color to use with SetVertexColor or a color name to be parsed with ParseColors
---@param vertexGreen number? green color to use with SetVertexColor
---@param vertexBlue number? blue color to use with SetVertexColor
---@param vertexAlpha number? alpha color to use with SetVertexColor
---@param desaturated boolean? if the texture should be desaturated
---@param desaturation number? the amount of desaturation to use with SetDesaturation
---@param alpha number? the alpha to use with SetAlpha
---@return df_atlasinfo
function detailsFramework:CreateAtlas(file, width, height, leftTexCoord, rightTexCoord, topTexCoord, bottomTexCoord, tilesHorizontally, tilesVertically, vertexRed, vertexGreen, vertexBlue, vertexAlpha, desaturated, desaturation, alpha)
	---@type df_atlasinfo
	local atlasInfo = {
		file = file,
		width = width or 64,
		height = height or 64,
		leftTexCoord = leftTexCoord or 0,
		rightTexCoord = rightTexCoord or 1,
		topTexCoord = topTexCoord or 0,
		bottomTexCoord = bottomTexCoord or 1,
		tilesHorizontally = tilesHorizontally or false,
		tilesVertically = tilesVertically or false,
		desaturated = desaturated,
		desaturation = desaturation,
		alpha = alpha,
	}

	--parse the colors passed
	if (vertexRed) then
		if (type(vertexRed) == "string") then
			atlasInfo.colorName = vertexRed
		else
			atlasInfo.vertexRed = vertexRed
			atlasInfo.vertexGreen = vertexGreen
			atlasInfo.vertexBlue = vertexBlue
			atlasInfo.vertexAlpha = vertexAlpha
		end
	end

	return atlasInfo
end

---Return the texture passed can be parsed as a texture
---@param self table
---@param texture any
---@param bCheckTextureObject boolean?
---@return boolean
function detailsFramework:IsTexture(texture, bCheckTextureObject)
	--if is a string, can be a path or an atlasname, so can be parsed
	if (type(texture) == "string") then
		return true
	end

	--if is a number, can be parsed
	if (type(texture) == "number") then
		return true
	end

	if (type(texture) == "table") then
		--gradient texture
		if (texture.gradient) then
			return true
		end

		--part of an atlasinfo
		if (texture.file or texture.filename) then
			return true
		end

		if (bCheckTextureObject) then
			--check if is a texture object
			if (texture.GetTexture and texture.GetObjectType and texture:GetObjectType() == "Texture") then
				return true
			end
		end
	end

	return false
end

---Return if the table passed has the structure of an atlasinfo
---@param self table
---@param atlasTale table
---@return boolean
function detailsFramework:TableIsAtlas(atlasTale)
	if (type(atlasTale) == "table") then
		if (atlasTale.file or atlasTale.filename) then
			return true
		end
	end
	return false
end

---Receives a texture object and a texture to use as mask
---If the mask texture is not created, it will be created and added to a key named MaskTexture
---@param self table
---@param texture texture
---@param maskTexture string|number|table
function detailsFramework:SetMask(texture, maskTexture)
	if (not texture.MaskTexture) then
		local parent = texture:GetParent()
		local maskTextureObject = parent:CreateMaskTexture(nil, "artwork")
		maskTextureObject:SetAllPoints(texture.widget or texture)
		texture:AddMaskTexture(maskTextureObject)
		texture.MaskTexture = maskTextureObject
	end

	--is this a game texture atlas?
	if (type(maskTexture) == "string") then
		local isAtlas = C_Texture.GetAtlasInfo(maskTexture)
		if (isAtlas) then
			texture.MaskTexture:SetAtlas(maskTexture)
			return
		end

	elseif (type(maskTexture) == "table") then
		local bIsAtlas = detailsFramework:TableIsAtlas(maskTexture)
		if (bIsAtlas) then
			detailsFramework:SetAtlas(texture.MaskTexture, maskTexture)
			return
		end
	end

	texture.MaskTexture:SetTexture(maskTexture)
end

