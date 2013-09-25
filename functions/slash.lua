

local _detalhes	= 	_G._detalhes
local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )

local CreateFrame = CreateFrame
local pairs = pairs 
local UIParent = UIParent
local UnitGUID = UnitGUID 
local tonumber= tonumber 
local LoggingCombat = LoggingCombat

SLASH_DETAILS1, SLASH_DETAILS2, SLASH_DETAILS3 = "/details", "/dt", "/d"

function SlashCmdList.DETAILS (msg, editbox)

	local command, rest = msg:match("^(%S*)%s*(.-)$")
	
	if (command == Loc ["STRING_SLASH_NEW"]) then
	
		_detalhes:CriarInstancia()
		
	elseif (command == Loc ["STRING_SLASH_SHOW"]) then
	
		if (_detalhes.opened_windows == 0) then
			_detalhes:CriarInstancia()
		end
	
	elseif (command == Loc ["STRING_SLASH_DISABLE"]) then
	
		_detalhes:CaptureSet (false, "damage", true)
		_detalhes:CaptureSet (false, "heal", true)
		_detalhes:CaptureSet (false, "energy", true)
		_detalhes:CaptureSet (false, "miscdata", true)
		_detalhes:CaptureSet (false, "aura", true)
		print (Loc ["STRING_DETAILS1"] .. Loc ["STRING_SLASH_CAPTUREOFF"])
	
	elseif (command == Loc ["STRING_SLASH_ENABLE"]) then
	
		_detalhes:CaptureSet (true, "damage", true)
		_detalhes:CaptureSet (true, "heal", true)
		_detalhes:CaptureSet (true, "energy", true)
		_detalhes:CaptureSet (true, "miscdata", true)
		_detalhes:CaptureSet (true, "aura", true)
		print (Loc ["STRING_DETAILS1"] .. Loc ["STRING_SLASH_CAPTUREON"])
	
	elseif (command == Loc ["STRING_SLASH_OPTIONS"]) then
	
		if (rest and tonumber (rest)) then
			local instanceN = tonumber (rest)
			if (instanceN > 0 and instanceN <= #_detalhes.tabela_instancias) then
				local instance = _detalhes:GetInstance (instanceN)
				_detalhes:OpenOptionsWindow (instance)
			end
		else
			local lower_instance = _detalhes:GetLowerInstanceNumber()
			print (_detalhes:GetInstance (lower_instance))
			_detalhes:OpenOptionsWindow (_detalhes:GetInstance (lower_instance))
		end
		
	
-------- debug ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	elseif (msg == "time") then
		print ("GetTime()", GetTime())
		print ("time()", time())

	elseif (msg == "copy") then
		_G.DetailsCopy:Show()
		_G.DetailsCopy.MyObject.text:HighlightText()
		_G.DetailsCopy.MyObject.text:SetFocus()
	
	elseif (msg == "garbage") then
		local a = {}
		for i = 1, 10000 do 
			a [i] = {math.random (50000)}
		end
		table.wipe (a)
	
	elseif (msg == "raid") then
	
		local player, realm = "Marleyieu", "Azralon"
	
		local actorName
		if (realm ~= GetRealmName()) then
			actorName = player.."-"..realm
		else
			actorName = player
		end
		
		print (actorName)
	
		local guid = _detalhes:FindGUIDFromName ("Marleyieu")
		print (guid)
		
		for i = 1, GetNumGroupMembers()-1, 1 do 
			local name, realm = UnitName ("party"..i)
			print (name, " -- ", realm)
		end

	elseif (msg == "cacheparser") then
		_detalhes:PrintParserCacheIndexes()
	elseif (msg == "parsercache") then
		_detalhes:PrintParserCacheIndexes()
	
	elseif (msg == "captures") then
		for k, v in pairs (_detalhes.capture_real) do 
			print ("real -",k,":",v)
		end
		for k, v in pairs (_detalhes.capture_current) do 
			print ("current -",k,":",v)
		end
	
	elseif (msg == "slider") then
		
		local f = CreateFrame ("frame", "TESTEDESCROLL", UIParent)
		f:SetPoint ("center", UIParent, "center", 200, -2)
		f:SetWidth (300)
		f:SetHeight (150)
		f:SetBackdrop ({bgFile = "Interface\\AddOns\\Details\\images\\background", tile = true, tileSize = 16, insets = {left = 0, right = 0, top = 0, bottom = 0}})
		f:SetBackdropColor (0, 0, 0, 1)
		f:EnableMouseWheel (true)
		
		local rows = {}
		for i = 1, 7 do 
			local row = CreateFrame ("frame", nil, UIParent)
			row:SetPoint ("topleft", f, "topleft", 10, -(i-1)*21)
			row:SetWidth (200)
			row:SetHeight (20)
			row:SetBackdrop ({bgFile = "Interface\\AddOns\\Details\\images\\background", tile = true, tileSize = 16, insets = {left = 0, right = 0, top = 0, bottom = 0}})
			local t = row:CreateFontString (nil, "overlay", "GameFontHighlightSmall")
			t:SetPoint ("left", row, "left")
			row.text = t
			rows [#rows+1] = row
		end
		
		local data = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20}
		
		
	
	elseif (msg == "bcollor") then
	
		--local instancia = _detalhes.tabela_instancias [1]
		_detalhes.ResetButton.Middle:SetVertexColor (1, 1, 0, 1)
		
		--print (_detalhes.ResetButton:GetHighlightTexture())
		
		local t = _detalhes.ResetButton:GetHighlightTexture()
		t:SetVertexColor (0, 1, 0, 1)
		--print (t:GetObjectType())
		--_detalhes.ResetButton:SetHighlightTexture (t)
		_detalhes.ResetButton:SetNormalTexture (t)
		
		print ("backdrop", _detalhes.ResetButton:GetBackdrop())
		
		_detalhes.ResetButton:SetBackdropColor (0, 0, 1, 1)
		
		--vardump (_detalhes.ResetButton)
	
	elseif (msg == "alert") then
		
		local instancia = _detalhes.tabela_instancias [1]
		local f = function() print ("teste") end
		instancia:InstanceAlert (Loc ["STRING_PLEASE_WAIT"], {[[Interface\COMMON\StreamCircle]], 22, 22, true}, 5, {f, "param1", "param2"})
	
	
	elseif (msg == "comm") then
		
		if (IsInRaid()) then
			for i = 1, GetNumGroupMembers() do 
				local nname, server = UnitName ("raid"..i)
				print (nname, server)
				--nname = nname.."-"..server
			end
		end

	elseif (msg == "teste") then
		
		local a, b = _detalhes:GetEncounterEnd (1098, 3)
		print (a, unpack (b))
		
	elseif (msg == "yesno") then
		--_detalhes:Show()
	
	elseif (msg == "imageedit") then
		
		local callback = function (width, height, overlayColor, alpha, texCoords)
			print (width, height, alpha)
			print ("overlay: ", unpack (overlayColor))
			print ("crop: ", unpack (texCoords))
		end
		
		_detalhes.gump:ImageEditor (callback, "Interface\\TALENTFRAME\\bg-paladin-holy", nil, {1, 1, 1, 1}) -- {0.25, 0.25, 0.25, 0.25}

	elseif (msg == "chat") then
	
		local name, fontSize, r, g, b, a, shown, locked = FCF_GetChatWindowInfo (1);
		print (name,"|",fontSize,"|", r,"|", g,"|", b,"|", a,"|", shown,"|", locked)
		
		--local fontFile, unused, fontFlags = self:GetFont();
		--self:SetFont(fontFile, fontSize, fontFlags);
	
	elseif (msg == "error") then
		a = nil + 1
		
	--> debug
	elseif (command == "resetcapture") then
		_detalhes.capture_real = {
			["damage"] = true,
			["heal"] = true,
			["energy"] = true,
			["miscdata"] = true,
			["aura"] = true,
		}
		_detalhes.capture_current = _detalhes.capture_real
		_detalhes:CaptureRefresh()

	--> debug
	elseif (msg == "opened") then 
		print ("Instances opened: " .. _detalhes.opened_windows)
	
	--> debug, get a guid of something
	elseif (command == "myguid") then --> localize-me
	
		local g = UnitGUID ("player")
		print (type (g))
		print (g)
		print (string.len (g))
		local serial = g:sub (12, 18)
		serial = tonumber ("0x"..serial)
		print (serial)
		
		--tonumber((UnitGUID("target")):sub(-12, -9), 16))
	
	elseif (command == "guid") then --> localize-me
	
		local pass_guid = rest:match("^(%S*)%s*(.-)$")
	
		if (not _detalhes.id_frame) then 
		
			local backdrop = {
			bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
			edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
			tile = true, edgeSize = 1, tileSize = 5,
			}
		
			_detalhes.id_frame = CreateFrame ("Frame", "DetailsID", UIParent)
			_detalhes.id_frame:SetHeight(14)
			_detalhes.id_frame:SetWidth(120)
			_detalhes.id_frame:SetPoint ("center", UIParent, "center")
			_detalhes.id_frame:SetBackdrop(backdrop)
			
			tinsert (UISpecialFrames, "DetailsID")
			
			_detalhes.id_frame.texto = CreateFrame ("editbox", nil, _detalhes.id_frame)
			_detalhes.id_frame.texto:SetPoint ("topleft", _detalhes.id_frame, "topleft")
			_detalhes.id_frame.texto:SetAutoFocus(false)
			_detalhes.id_frame.texto:SetFontObject (GameFontHighlightSmall)			
			_detalhes.id_frame.texto:SetHeight(14)
			_detalhes.id_frame.texto:SetWidth(120)
			_detalhes.id_frame.texto:SetJustifyH("CENTER")
			_detalhes.id_frame.texto:EnableMouse(true)
			_detalhes.id_frame.texto:SetBackdrop(ManualBackdrop)
			_detalhes.id_frame.texto:SetBackdropColor(0, 0, 0, 0.5)
			_detalhes.id_frame.texto:SetBackdropBorderColor(0.3, 0.3, 0.30, 0.80)
			_detalhes.id_frame.texto:SetText ("") --localize-me
			_detalhes.id_frame.texto.perdeu_foco = nil
			
			_detalhes.id_frame.texto:SetScript ("OnEnterPressed", function () 
				_detalhes.id_frame.texto:ClearFocus()
				_detalhes.id_frame:Hide() 
			end)
			
			_detalhes.id_frame.texto:SetScript ("OnEscapePressed", function() 
				_detalhes.id_frame.texto:ClearFocus()
				_detalhes.id_frame:Hide() 
			end)
			
		end
		
		_detalhes.id_frame:Show()
		_detalhes.id_frame.texto:SetFocus()
		
		if (pass_guid == "-") then
			local guid = UnitGUID ("target")
			if (guid) then 
				print (guid.. " -> " .. tonumber (guid:sub(6, 10), 16))
				_detalhes.id_frame.texto:SetText (""..tonumber (guid:sub(6, 10), 16))
				_detalhes.id_frame.texto:HighlightText()
			end
		
		else
			print (pass_guid.. " -> " .. tonumber (pass_guid:sub(6, 10), 16))
			_detalhes.id_frame.texto:SetText (""..tonumber (pass_guid:sub(6, 10), 16))
			_detalhes.id_frame.texto:HighlightText()
		end
		
	--> debug
	elseif (command == "actors") then
	
		local t, filter = rest:match("^(%S*)%s*(.-)$")

		t = tonumber (t)
		if (not t) then
			return print ("not T found.")
		end

		local f = _detalhes.actorsFrame
		if (not f) then
			_detalhes.actorsFrame = _detalhes.gump:NewPanel (UIParent, nil, "DetailsActorsFrame", nil, 300, 600)
			_detalhes.actorsFrame:SetPoint ("center", UIParent, "center", 300, 0)
			_detalhes.actorsFrame.barras = {}
				
			local container_barras_window = CreateFrame ("ScrollFrame", "Details_ActorsBarrasScroll", _detalhes.actorsFrame.widget) 
			local container_barras = CreateFrame ("Frame", "Details_ActorsBarras", container_barras_window)
			_detalhes.actorsFrame.container = container_barras

			container_barras_window:SetBackdrop({
				edgeFile = "Interface\\DialogFrame\\UI-DialogBox-gold-Border", tile = true, tileSize = 16, edgeSize = 5,
				insets = {left = 1, right = 1, top = 0, bottom = 1},})
			container_barras_window:SetBackdropBorderColor (0, 0, 0, 0)
			
			container_barras:SetBackdrop({
				bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
				insets = {left = 1, right = 1, top = 0, bottom = 1},})		
			container_barras:SetBackdropColor (0, 0, 0, 0)

			container_barras:SetAllPoints (container_barras_window)
			container_barras:SetWidth (300)
			container_barras:SetHeight (150)
			container_barras:EnableMouse (true)
			container_barras:SetResizable (false)
			container_barras:SetMovable (true)
			
			container_barras_window:SetWidth (260)
			container_barras_window:SetHeight (550)
			container_barras_window:SetScrollChild (container_barras)
			container_barras_window:SetPoint ("TOPLEFT", _detalhes.actorsFrame.widget, "TOPLEFT", 21, -10)

			_detalhes.gump:NewScrollBar (container_barras_window, container_barras, -10, -17)
			container_barras_window.slider:Altura (560)
			container_barras_window.slider:cimaPoint (0, 1)
			container_barras_window.slider:baixoPoint (0, -3)
			container_barras_window.slider:SetFrameLevel (10)

			container_barras_window.ultimo = 0
			
			container_barras_window.gump = container_barras
			--container_barras_window.slider = slider_gump
		end
		
		local container = _detalhes.tabela_vigente [t]._ActorTable
		print (#container, "actors found.")
		for index, actor in ipairs (container) do 
			
			local row = _detalhes.actorsFrame.barras [index]
			if (not row) then
				row = {text = _detalhes.actorsFrame.container:CreateFontString (nil, "overlay", "GameFontNormal")}
				_detalhes.actorsFrame.barras [index] = row
				row.text:SetPoint ("topleft", _detalhes.actorsFrame.container, "topleft", 0, -index * 15)
			end
			
			if (filter and actor.nome:find (filter)) then
				row.text:SetTextColor (1, 1, 0)
			else
				row.text:SetTextColor (1, 1, 1)
			end
			
			row.text:SetText (actor.nome)
			
		end
	
	--> debug
	elseif (msg == "id") then
		local one, two = rest:match("^(%S*)%s*(.-)$")
		if (one ~= "") then
			print("NPC ID:", one:sub(-12, -9), 16)
			print("NPC ID:", tonumber((one):sub(-12, -9), 16))
		else
			print("NPC ID:", tonumber((UnitGUID("target")):sub(-12, -9), 16) )
		end

	--> debug
	elseif (msg == "debug") then
		if (_detalhes.debug) then
			_detalhes.debug = false
			_detalhes:Msg ("diagnostic mode has been turned off.")
		else
			_detalhes.debug = true
			_detalhes:Msg ("diagnostic mode has been turned on.")
		end
	
	--> debug combat log
	elseif (msg == "combatlog") then
		if (_detalhes.isLoggingCombat) then
			LoggingCombat (false)
			print ("Wow combatlog record turned OFF.")
			_detalhes.isLoggingCombat = nil
		else
			LoggingCombat (true)
			print ("Wow combatlog record turned ON.")
			_detalhes.isLoggingCombat = true
		end
	
	--> debug
	elseif (msg == "tables") then
		_detalhes:tables()
		
	elseif (msg == "gs") then
		_detalhes:teste_grayscale()
	
	else
		
		--if (_detalhes.opened_windows < 1) then
		--	_detalhes:CriarInstancia()
		--end
		
		print (" ")
		print (Loc ["STRING_DETAILS1"] ..  Loc ["STRING_COMMAND_LIST"])
		print ("|cffffaeae/details " .. Loc ["STRING_SLASH_NEW"] .. "|r: " .. Loc ["STRING_SLASH_NEW_DESC"])
		print ("|cffffaeae/details " .. Loc ["STRING_SLASH_SHOW"] .. "|r: " .. Loc ["STRING_SLASH_SHOW_DESC"])
		print ("|cffffaeae/details " .. Loc ["STRING_SLASH_ENABLE"] .. "|r: " .. Loc ["STRING_SLASH_ENABLE_DESC"])
		print ("|cffffaeae/details " .. Loc ["STRING_SLASH_DISABLE"] .. "|r: " .. Loc ["STRING_SLASH_DISABLE_DESC"])
		print ("|cffffaeae/details " .. Loc ["STRING_SLASH_OPTIONS"] .. "|r|cfffcffb0 <instance number>|r: " .. Loc ["STRING_SLASH_OPTIONS_DESC"])
		print (" ")

	end
end

function _detalhes:tables ()
	-- generate a graphviz graph from a lua table structure

	local string_result = ""
	
	local function append( tab, ... )
	  for i = 1, select( '#', ... ) do
	    tab[ #tab + 1 ] = (select( i, ... ))
	  end
	  return tab
	end

	local function abbrev( str, data )
	  local escape = "\\\\"
	  if data.use_html then
	    escape = "\\"
	  end
	  local s = string.gsub( str, "[^%w?!=/+*-_.:,; ]", function( c )
	--  local s = string.gsub( str, "[^%w_]", function( c )
	    return escape .. string.byte( c )
	  end )
	  if string.len( s ) > 20 then
	    s = string.sub( s, 1, 17 ) .. "..."
	  end
	  return "'" .. s .. "'"
	end

	local function update_node_depth( val, data, depth )
	  data.node2depth[ val ] = math.min( data.node2depth[ val ] or depth, depth )
	end

	local function define_node( data, node )
	  assert( not data.node2id[ node.value ] )
	  local id = data.n_nodes
	  data.n_nodes = data.n_nodes + 1
	  data.node2id[ node.value ] = id
	  append( data.nodes, node )
	  return id
	end

	local function define_edge( data, edge )
	  append( data.edges, edge )
	end

	local function get_metatable( val, enabled )
	  if enabled then
	    if type( debug ) == "table" and
	       type( debug.getmetatable ) == "function" then
	      return debug.getmetatable( val )
	    elseif type( getmetatable ) == "function" then
	      return getmetatable( val )
	    end
	  end
	end

	local function get_environment( val, enabled )
	  if enabled then
	    if type( debug ) == "table" and
	       type( debug.getfenv ) == "function" then
	       return debug.getfenv( val )
	    elseif type( getfenv ) == "function" and
		   type( val ) == "function" then
	      return getfenv( val )
	    end
	  end
	end



	-- generate dot code for references
	local function dottify_metatable_ref( val, id1, mt, id2, data )
	  append( data.edges, {
	    A = val, A_id = id1,
	    B = mt, B_id = id2,
	    style = "dashed",
	    arrowtail = "odiamond",
	    label = "metatable",
	    color = "blue"
	  } )
	  data.nodes[ data.node2id[ val ] ].important = true
	  data.nodes[ data.node2id[ mt ] ].important = true
	end
	local function dottify_environment_ref( val, id1, env, id2, data )
	  append( data.edges, {
	    A = val, A_id = id1,
	    B = env, B_id = id2,
	    style = "dotted",
	    arrowtail = "dot",
	    label = "environment",
	    color = "red"
	  } )
	  data.nodes[ data.node2id[ val ] ].important = true
	  data.nodes[ data.node2id[ env ] ].important = true
	end
	local function dottify_upvalue_ref( val, id1, upv, id2, data, name )
	  append( data.edges, {
	    A = val, A_id = id1,
	    B = upv, B_id = id2,
	    style = "dashed",
	    label = name or "#upvalue",
	    color = "green"
	  } )
	  data.nodes[ data.node2id[ val ] ].important = true
	  data.nodes[ data.node2id[ upv ] ].important = true
	end
	local function dottify_ref( val1, id1, val2, id2, data )
	  append( data.edges, {
	    A = val1, A_id = id1,
	    B = val2, B_id = id2,
	    style = "solid",
	    arrowhead = "normal",
	  } )
	end


	-- forward declarations
	local dottify_table, dottify_userdata, dottify_thread, dottify_function


	local function make_label( tab, v, data, id, subid, depth )
	  if type( v ) == "table" then
	    local id2 = dottify_table( v, data, depth+1 )
	    dottify_ref( tab, id..":"..subid, v, id2..":0", data )
	    return tostring( v )
	  elseif type( v ) == "userdata" then
	    local id2 = dottify_userdata( v, data, depth+1 )
	    dottify_ref( tab, id..":"..subid, v, id2, data )
	    return tostring( v )
	  elseif type( v ) == "function" then
	    local id2 = dottify_function( v, data, depth+1 )
	    dottify_ref( tab, id..":"..subid, v, id2, data )
	    return tostring( v )
	  elseif type( v ) == "thread" then
	    local id2 = dottify_thread( v, data, depth+1 )
	    dottify_ref( tab, id..":"..subid, v, id2, data )
	    return tostring( v )
	  elseif type( v ) == "string" then
	    return abbrev( v, data )
	  elseif type( v ) == "number" or type( v ) == "boolean" then
	    return tostring( v )
	  else
	    error( "unsupported primitive lua type" )
	  end
	end


	function dottify_table( tab, data, depth )
	  assert( type( tab ) == "table" )
	  update_node_depth( tab, data, depth )
	  if not data.node2id[ tab ] then
	    local node = {
	      value = tab
	    }
	    local id = define_node( data, node )
	    local label
	    -- build label for this table
	    if data.use_html then
	      node.shape = "plaintext"
	      label = [[<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0"><TR><TD PORT="0" COLSPAN="2" BGCOLOR="lightgrey">]] .. tostring( tab ) .. [[</TD></TR>]]
	    else
	      node.shape = "record"
	      label = "{ <0> " .. tostring( tab )
	    end
	    local handled = {}
	    local n = 1
	    -- first the array part
	    for i,v in ipairs( tab ) do
	      local el_label = make_label( tab, v, data, id, n, depth )
	      if data.use_html then
		label = label .. [[<TR><TD PORT="]] .. n .. [[" COLSPAN="2">]] .. el_label .. [[</TD></TR>]]
	      else
		label = label .. " | <" .. n .. "> " .. el_label
	      end
	      n = n + 1
	      handled[ i ] = true
	    end
	    -- and then the hash part
	    local keys, values = {}, {}
	    for k,v in pairs( tab ) do
	      node.important = true
	      if not handled[ k ] then -- skip array part elements
		local k_label = make_label( tab, k, data, id, "k"..n, depth )
		local v_label = make_label( tab, v, data, id, "v"..n, depth )
		if data.use_html then
		  label = label .. [[ <TR><TD PORT="k]] .. n .. [[">]] .. k_label .. [[</TD><TD PORT="v]] .. n .. [[">]] .. v_label .. [[</TD></TR>]]
		else
		  append( keys, "<k" .. n .. "> " .. k_label )
		  append( values, "<v" .. n .. "> " .. v_label )
		end
		n = n + 1
	      end
	    end
	    if data.use_html then
	      node.label = label .. [[</TABLE>]]
	    else
	      if next( keys ) ~= nil then
		label = label .. " | { { " .. table.concat( keys, " | " ) ..
			" } | { " .. table.concat( values, " | " ) .. " } }"
	      end
	      node.label = label .. " }"
	    end
	    -- and now the metatable
	    local mt = get_metatable( tab, data.show_metatables )
	    if type( mt ) == "table" then
	      local id2 = dottify_table( mt, data, depth+1 )
	      dottify_metatable_ref( tab, id .. ":0", mt, id2 .. ":0", data )
	    end
	  end
	  return data.node2id[ tab ]
	end


	function dottify_userdata( udata, data, depth )
	  assert( type( udata ) == "userdata" )
	  update_node_depth( udata, data, depth )
	  if not data.node2id[ udata ] then
	    local id = define_node( data, {
	      value = udata,
	      label = tostring( udata ),
	      shape = "box"
	    } )
	    -- the metatable
	    local mt = get_metatable( udata, data.show_metatables )
	    if type( mt ) == "table" then
	      local id2 = dottify_table( mt, data, depth+1 )
	      dottify_metatable_ref( udata, id, mt, id2..":0", data )
	    end
	    -- the environment
	    local env = get_environment( udata, data.show_environments )
	    if type( env ) == "table" then
	      local id2 = dottify_table( env, data, depth+1 )
	      dottify_environment_ref( udata, id, env, id2..":0", data )
	    end
	  end
	  return data.node2id[ udata ]
	end


	function dottify_thread( thread, data, depth )
	  assert( type( thread ) == "thread" )
	  update_node_depth( thread, data, depth )
	  if not data.node2id[ thread ] then
	    local id = define_node( data, {
	      value = thread,
	      label = tostring( thread ),
	      shape = "triangle"
	    } )
	    -- the environment
	    local env = get_environment( val, data.show_environments )
	    if type( env ) == "table" then
	      local id2 = dottify_table( env, data, depth+1 )
	      dottify_environment_ref( thread, id, env, id2..":0", data )
	    end
	  end
	  return data.node2id[ thread ]
	end



	function dottify_function( func, data, depth )
	  assert( type( func ) == "function" )
	  update_node_depth( func, data, depth )
	  if not data.node2id[ func ] then
	    local id = define_node( data, {
	      value = func,
	      label = tostring( func ),
	      shape = "ellipse"
	    } )
	    -- the environment
	    local env = get_environment( func, data.show_environments )
	    if type( env ) == "table" then
	      local id2 = dottify_table( env, data, depth+1 )
	      dottify_environment_ref( func, id, env, id2..":0", data )
	    end
	    -- the upvalues
	    if data.show_upvalues and
	       type( debug ) == "table" and
	       type( debug.getupvalue ) == "function" then
	      local n = 1
	      repeat
		local name, upvalue = debug.getupvalue( func, n )
		if type( upvalue ) == "table" then
		  local id2 = dottify_table( upvalue, data, depth+1 )
		  dottify_upvalue_ref( func, id, upvalue, id2..":0", data, name )
		elseif type( upvalue ) == "userdata" then
		  local id2 = dottify_userdata( upvalue, data, depth+1 )
		  dottify_upvalue_ref( func, id, upvalue, id2, data, name )
		elseif type( upvalue ) == "function" then
		  local id2 = dottify_function( upvalue, data, depth+1 )
		  dottify_upvalue_ref( func, id, upvalue, id2, data, name )
		elseif type( upvalue ) == "thread" then
		  local id2 = dottify_thread( upvalue, data, depth+1 )
		  dottify_upvalue_ref( func, id, upvalue, id2, data, name )
		end
		n = n + 1
	      until name == nil
	    end
	  end
	  return data.node2id[ func ]
	end

	local option_names = {
	  "label", "shape", "style", "dir", "arrowhead", "arrowtail", "color",
	  "fillcolor"
	}

	local function process_options( obj )
	  local options = {}
	  for _,opt in ipairs( option_names ) do
	    if obj[ opt ] then
	      local quote_on = "\""
	      local quote_off = "\""
	      if opt == "label" and type( obj[ opt ] ) == "string" and
		 obj[ opt ]:match( "^<.*>$" ) then
		quote_on, quote_off = "<", ">"
	      end
	      append( options, tostring( opt ) .. "=" .. quote_on ..
			       tostring( obj[ opt ] ) .. quote_off )
	    end
	  end
	  return options
	end


	local function write_nodes( file, data )
	  for _,n in ipairs( data.nodes ) do
	    if (data.max_depth <= 0 or
		data.node2depth[ n.value ] <= data.max_depth) and
	       (data.show_unimportant or n.important) then
	      local options = process_options( n )
	      
	       string_result = string_result .. "  " .. tostring( data.node2id[ n.value ] ) .. " [" .. table.concat( options, "," ) .. "];--PULALINHA--" 
	      
	    end
	  end
	end


	local function write_edges( file, data )
	  for _,e in ipairs( data.edges ) do
	    if (data.max_depth <= 0 or
		(data.node2depth[ e.A ] <= data.max_depth and
		 data.node2depth[ e.B ] <= data.max_depth)) and
	       (data.show_unimportant or
		(data.nodes[ data.node2id[ e.A ] ].important and
		 data.nodes[ data.node2id[ e.B ] ].important)) then
	      local id1 = e.A_id or data.node2id[ e.A ]
	      local id2 = e.B_id or data.node2id[ e.B ]
	      local options = process_options( e )
	      
	      string_result = string_result .. "  " .. tostring( id1 ) .. " -> " .. tostring( id2 ) .. " [" .. table.concat( options, "," ) .. "];--PULALINHA--"

	    end
	  end
	end


	-- main function
	local function dottify( filename, val, ... )

	  local data = {
	    n_nodes = 1,
	    node2id = {},
	    node2depth = {},
	    nodes = {},
	    edges = {},
	    show_metatables = true,
	    show_upvalues = true,
	    show_environments = false,
	    use_html = true,
	    show_unimportant = false,
	    max_depth = 0,
	  }
	  for i = 1, select( '#', ... ) do
	    local opt = select( i, ... )
	    if opt == "noenvironments" then
	      data.show_environments = false
	    elseif opt == "nometatables" then
	      data.show_metatables = false
	    elseif opt == "noupvalues" then
	      data.show_upvalues = false
	    elseif opt == "nohtml" then
	      data.use_html = false
	    elseif opt == "environments" then
	      data.show_environments = true
	    elseif opt == "metatables" then
	      data.show_metatables = true
	    elseif opt == "upvalues" then
	      data.show_upvalues = true
	    elseif opt == "html" then
	      data.use_html = true
	    elseif opt == "unimportant" then
	      data.show_unimportant = true
	    elseif type( opt ) == "number" then
	      data.max_depth = opt
	    end
	  end
	  local t = type( val )
	  if t == "table" then
	    local id = dottify_table( val, data, 1 )
	    data.nodes[ id ].important = true
	  elseif t == "function" then
	    local id = dottify_function( val, data, 1 )
	    data.nodes[ id ].important = true
	  elseif t == "thread" then
	    local id = dottify_thread( val, data, 1 )
	    data.nodes[ id ].important = true
	  elseif t == "userdata" then
	    local id = dottify_userdata( val, data, 1 )
	    data.nodes[ id ].important = true
	  else
	    io.stderr:write( "warning: unsuitable value for dotlua!<br>" )
	  end
	  
	  --local file = assert( io.open( filename, "w" ) )
	
	string_result = string_result .. "digraph {--PULALINHA--"
	  
	  --file:write( "digraph {\n" )
	  write_nodes ( o, data )
	  write_edges ( o, data )
	  
	  string_result = string_result .. "}--PULALINHA--"
	  
	  --file:write( "}\n" )
	  --file:close()
	  return o
	end
	
	dottify ( nil, _detalhes, "nohtml")
	
	print ("running...", string.len (string_result))
	
	--_G ["_detalhes_database"].aaaaaaaa = string_result
	
	_detalhes:CopyPaste (string_result)
	

	return dottify
end