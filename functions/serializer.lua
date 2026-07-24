
--[[
	Serializer: turns tables into strings and strings back into tables.

	Serialize() sanitizes the table and encodes it (CBOR -> Deflate -> Base64), Deserialize()
	reverses it. Used to store profiles and combat data at rest in the saved variables file
	and to build the strings used by profile import and export.

	SanitizeCopy() builds plain copies of tables: metatables are never carried over; ui frames
	and the __index/__newindex keys left behind by classes are dropped; cycles and shared
	references resolve to a single copy instead of expanding.
]]

local _ = nil
local addonName, Details222 = ...

--forward declaration, the function recurses into sub tables
local sanitizeCopy

---build the plain copy of a table; visited maps tables already copied to their copy so cycles and shared references resolve to a single copy
---@param source table
---@param visited table<table, table>
---@return table
sanitizeCopy = function(source, visited)
	local copy = {}
	visited[source] = copy

	for key, value in next, source do
		if (key ~= "__index" and key ~= "__newindex") then
			if (type(value) == "table") then
				if (type(rawget(value, 0)) ~= "userdata") then --ui frames hold their widget handle as userdata at index 0
					copy[key] = visited[value] or sanitizeCopy(value, visited)
				end
			else
				copy[key] = value
			end
		end
	end

	return copy
end

---create a plain copy of the passed table, safe to be serialized or stored in the saved variables file
---@param source table
---@return table
function Details222.Serializer.SanitizeCopy(source)
	if (type(source) ~= "table") then
		return {}
	end

	return sanitizeCopy(source, {})
end

---sanitize and encode a table into a string (CBOR -> Deflate -> Base64), return nil if the encode failed
---@param sourceTable table
---@return string|nil
function Details222.Serializer.Serialize(sourceTable)
	if (type(sourceTable) ~= "table") then
		return nil
	end

	local sanitizedTable = Details222.Serializer.SanitizeCopy(sourceTable)

	local hasEncoded, encodedString = pcall(function()
		local serializedString = C_EncodingUtil.SerializeCBOR(sanitizedTable)
		local compressedString = C_EncodingUtil.CompressString(serializedString, Enum.CompressionMethod.Deflate)
		return C_EncodingUtil.EncodeBase64(compressedString)
	end)

	if (hasEncoded and type(encodedString) == "string") then
		return encodedString
	end

	return nil
end

---decode a serialized string back into a table, return nil if the string is damaged
---@param encodedString string
---@return table|nil
function Details222.Serializer.Deserialize(encodedString)
	if (type(encodedString) ~= "string") then
		return nil
	end

	local hasDecoded, decodedTable = pcall(function()
		local compressedString = C_EncodingUtil.DecodeBase64(encodedString)
		local serializedString = C_EncodingUtil.DecompressString(compressedString, Enum.CompressionMethod.Deflate)
		return C_EncodingUtil.DeserializeCBOR(serializedString)
	end)

	if (hasDecoded and type(decodedTable) == "table") then
		return decodedTable
	end

	return nil
end
