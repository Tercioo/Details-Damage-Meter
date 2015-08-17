	local _detalhes = _G._detalhes

	--> default weaktable
	_detalhes.weaktable = {__mode = "v"}

	--> globals
	--[[global]] DETAILS_WA_AURATYPE_ICON = 1
	--[[global]] DETAILS_WA_AURATYPE_TEXT = 2
	--[[global]] DETAILS_WA_AURATYPE_BAR = 3
	
	--[[global]] DETAILS_WA_TRIGGER_DEBUFF_PLAYER = 1
	--[[global]] DETAILS_WA_TRIGGER_DEBUFF_TARGET = 2
	--[[global]] DETAILS_WA_TRIGGER_DEBUFF_FOCUS = 3
	
	--[[global]] DETAILS_WA_TRIGGER_BUFF_PLAYER = 4
	--[[global]] DETAILS_WA_TRIGGER_BUFF_TARGET = 5
	--[[global]] DETAILS_WA_TRIGGER_BUFF_FOCUS = 6
	
	--[[global]] DETAILS_WA_TRIGGER_CAST_START = 7
	--[[global]] DETAILS_WA_TRIGGER_CAST_OKEY = 8
	
	--[[global]] DETAILS_WA_TRIGGER_DBM_TIMER = 9
	--[[global]] DETAILS_WA_TRIGGER_BW_TIMER = 10
	
	--weak auras
	local group_prototype_boss_mods = {
		["grow"] = "DOWN",
		["controlledChildren"] = {},
		["animate"] = true,
		["xOffset"] = 0,
		["border"] = "None",
		["yOffset"] = 370,
		["anchorPoint"] = "CENTER",
		["untrigger"] = {},
		["sort"] = "none",
		["actions"] = {
			["start"] = {},
			["finish"] = {},
			["init"] = {},
		},
		["space"] = 2,
		["background"] = "None",
		["expanded"] = true,
		["constantFactor"] = "RADIUS",
		["selfPoint"] = "TOP",
		["borderOffset"] = 16,
		["trigger"] = {
			["type"] = "aura",
			["spellIds"] = {
			},
			["names"] = {
			},
			["debuffType"] = "HELPFUL",
			["unit"] = "player",
		},
		["animation"] = {
			["start"] = {
				["duration_type"] = "seconds",
				["type"] = "none",
			},
			["main"] = {
				["duration_type"] = "seconds",
				["type"] = "none",
			},
			["finish"] = {
				["duration_type"] = "seconds",
				["type"] = "none",
			},
		},
		["id"] = "Details! Boss Mods Group",
		["backgroundInset"] = 0,
		["frameStrata"] = 1,
		["width"] = 359.096801757813,
		["rotation"] = 0,
		["radius"] = 200,
		["numTriggers"] = 1,
		["stagger"] = 0,
		["height"] = 121.503601074219,
		["align"] = "CENTER",
		["load"] = {
			["difficulty"] = {
				["multi"] = {
				},
			},
			["role"] = {
				["multi"] = {
				},
			},
			["use_class"] = false,
			["talent"] = {
				["multi"] = {
				},
			},
			["race"] = {
				["multi"] = {
				},
			},
			["spec"] = {
				["multi"] = {
				},
			},
			["class"] = {
			},
			["size"] = {
				["multi"] = {
				},
			},
		},
		["regionType"] = "dynamicgroup",
	}
	
	local group_prototype = {
		["xOffset"] = -678.999450683594,
		["yOffset"] = 212.765991210938,
		["id"] = "Details! Aura Group",
		["grow"] = "RIGHT",
		["controlledChildren"] = {},
		["animate"] = true,
		["border"] = "None",
		["anchorPoint"] = "CENTER",
		["regionType"] = "dynamicgroup",
		["sort"] = "none",
		["actions"] = {},
		["space"] = 0,
		["background"] = "None",
		["expanded"] = true,
		["constantFactor"] = "RADIUS",
		["trigger"] = {
			["type"] = "aura",
			["spellIds"] = {},
			["unit"] = "player",
			["debuffType"] = "HELPFUL",
			["names"] = {},
		},
		["borderOffset"] = 16,
		
		["animation"] = {
			["start"] = {
				["type"] = "none",
				["duration_type"] = "seconds",
			},
			["main"] = {
				["type"] = "none",
				["duration_type"] = "seconds",
			},
			["finish"] = {
				["type"] = "none",
				["duration_type"] = "seconds",
			},
		},
		["align"] = "CENTER",
		["rotation"] = 0,
		["frameStrata"] = 1,
		["width"] = 199.999969482422,
		["height"] = 20,
		["stagger"] = 0,
		["radius"] = 200,
		["numTriggers"] = 1,
		["backgroundInset"] = 0,
		["selfPoint"] = "LEFT",
		["load"] = {
			["use_combat"] = true,
			["race"] = {
				["multi"] = {},
			},
			["talent"] = {
				["multi"] = {},
			},
			["role"] = {
				["multi"] = {},
			},
			["spec"] = {
				["multi"] = {},
			},
			["class"] = {
				["multi"] = {},
			},
			["size"] = {
				["multi"] = {},
			},
		},
		["untrigger"] = {},
	}
	
	local bar_dbm_timerbar_prototype = {
		["sparkWidth"] = 10,
		["stacksSize"] = 12,
		["xOffset"] = 0,
		["stacksFlags"] = "None",
		["yOffset"] = 239.568542480469,
		["anchorPoint"] = "CENTER",
		["borderColor"] = {1, 1, 1, 0.5},
		["rotateText"] = "NONE",
		["backgroundColor"] = {0, 0, 0, 0.5},
		["fontFlags"] = "OUTLINE",
		["icon_color"] = {1, 1, 1, 1},
		["selfPoint"] = "CENTER",
		["barColor"] = {1, 0, 0, 1},
		["desaturate"] = false,
		["progressPrecision"] = 1,
		["sparkOffsetY"] = 0,
		["load"] = {
			["difficulty"] = {
				["multi"] = {
				},
			},
			["race"] = {
				["multi"] = {
				},
			},
			["talent"] = {
				["multi"] = {
				},
			},
			["role"] = {
				["multi"] = {
				},
			},
			["spec"] = {
				["multi"] = {
				},
			},
			["class"] = {
				["multi"] = {
				},
			},
			["size"] = {
				["multi"] = {
				},
			},
		},
		["timerColor"] = {1, 1, 1, 1},
		["regionType"] = "aurabar",
		["stacks"] = true,
		["texture"] = "Blizzard",
		["textFont"] = "Friz Quadrata TT",
		["zoom"] = 0,
		["spark"] = false,
		["timerFont"] = "Friz Quadrata TT",
		["alpha"] = 1,
		["borderInset"] = 11,
		["textColor"] = {1, 1, 1, 1},
		["borderBackdrop"] = "Blizzard Tooltip",
		["customText"] = "function (expire, duration)\n    return format (\"%.1f\", duration)\nend \n\n",
		["barInFront"] = true,
		["sparkRotationMode"] = "AUTO",
		["displayTextLeft"] = "%n",
		["animation"] = {
			["start"] = {
				["duration_type"] = "seconds",
				["type"] = "none",
			},
			["main"] = {
				["duration_type"] = "seconds",
				["type"] = "none",
			},
			["finish"] = {
				["duration_type"] = "seconds",
				["type"] = "none",
			},
		},
		["trigger"] = {
			["type"] = "custom",
			["custom_hide"] = "timed",
			["subeventSuffix"] = "_CAST_START",
			["custom_type"] = "status",
			["custom"] = "function()\n    if (InCombatLockdown() and aura_env.trigger_at and aura_env.trigger_at <= GetTime() and aura_env.untrigger_at and aura_env.untrigger_at >= GetTime()) then\n        return true\n    else\n        return false\n    end\nend\n",
			["event"] = "Health",
			["unit"] = "player",
			["customDuration"] = "function()\n    if (aura_env.trigger_at and aura_env.trigger_at <= GetTime() and aura_env.untrigger_at and aura_env.untrigger_at >= GetTime()) then\n        return aura_env.untrigger_at - GetTime(), aura_env.countdown_at, true\n    else\n        return 0\n    end\nend\n",
			["customName"] = "function()\n    return aura_env.ability_text\nend",
			["spellIds"] = {
			},
			["customIcon"] = "function()\n    return aura_env.ability_icon    \nend\n",
			["check"] = "update",
			["subeventPrefix"] = "SPELL",
			["names"] = {
			},
			["debuffType"] = "HELPFUL",
		},
		["text"] = true,
		["stickyDuration"] = false,
		["height"] = 40.115104675293,
		["timerFlags"] = "None",
		["sparkBlendMode"] = "ADD",
		["backdropColor"] = {1, 1, 1, 0.5},
		["untrigger"] = {
			["custom"] = "function()\n    return true\nend",
		},
		["actions"] = {
			["start"] = {
			},
			["finish"] = {
			},
			["init"] = {
				["do_custom"] = true,
				["custom"] = "\n\n",
			},
		},
		["textFlags"] = "None",
		["border"] = false,
		["borderEdge"] = "None",
		["sparkOffsetX"] = 0,
		["borderSize"] = 16,
		["stacksFont"] = "Friz Quadrata TT",
		["icon_side"] = "LEFT",
		["inverse"] = false,
		["timer"] = true,
		["sparkHeight"] = 30,
		["sparkRotation"] = 0,
		["displayTextRight"] = "%c",
		["stacksColor"] = {1, 1, 1, 1},
		["timerSize"] = 16,
		["icon"] = true,
		["textSize"] = 16,
		["frameStrata"] = 1,
		["width"] = 370,
		["customTextUpdate"] = "event",
		["sparkColor"] = {1, 1, 1, 1},
		["numTriggers"] = 1,
		["sparkDesature"] = false,
		["orientation"] = "HORIZONTAL",
		["borderOffset"] = 5,
		["auto"] = true,
		["sparkTexture"] = "Interface\\CastingBar\\UI-CastingBar-Spark",	
	}
	
	local icon_dbm_timerbar_prototype = {
		["xOffset"] = -391.000030517578,
		["customText"] = "function (expire, duration)\n    return \"\" .. aura_env.ability_text\nend \n\n",
		["yOffset"] = 300,
		["anchorPoint"] = "CENTER",
		["customTextUpdate"] = "event",
		["actions"] = {
			["start"] = {
			},
			["init"] = {
				["do_custom"] = true,
				["custom"] = "",
			},
			["finish"] = {
			},
		},
		["fontFlags"] = "OUTLINE",
		["selfPoint"] = "CENTER",
		["trigger"] = {
			["unevent"] = "auto",
			["type"] = "custom",
			["subeventPrefix"] = "SPELL",
			["custom_type"] = "status",
			["use_unit"] = true,
			["spellIds"] = {
			},
			["event"] = "Health",
			["unit"] = "player",
			["customDuration"] = "function()\n    if (aura_env.trigger_at and aura_env.trigger_at <= GetTime() and aura_env.untrigger_at and aura_env.untrigger_at >= GetTime()) then\n        return aura_env.untrigger_at - GetTime(), aura_env.countdown_at\n    else\n        return 0\n    end\nend\n",
			["customName"] = "function()\n    return aura_env.ability_name    \nend\n",
			["custom"] = "function()\n    if (InCombatLockdown() and aura_env.trigger_at and aura_env.trigger_at <= GetTime() and aura_env.untrigger_at and aura_env.untrigger_at >= GetTime()) then\n        return true\n    else\n        return false\n    end\nend\n",
			["customIcon"] = "function()\n    return aura_env.ability_icon    \nend\n",
			["check"] = "update",
			["names"] = {
			},
			["subeventSuffix"] = "_CAST_START",
			["debuffType"] = "HELPFUL",
		},
		["desaturate"] = false,
		["font"] = "Friz Quadrata TT",
		["height"] = 194.575485229492,
		["load"] = {
			["difficulty"] = {
				["multi"] = {
				},
			},
			["race"] = {
				["multi"] = {
				},
			},
			["talent"] = {
				["multi"] = {
				},
			},
			["role"] = {
				["multi"] = {
				},
			},
			["spec"] = {
				["multi"] = {
				},
			},
			["class"] = {
				["multi"] = {
				},
			},
			["size"] = {
				["multi"] = {
				},
			},
		},
		["fontSize"] = 20,
		["displayStacks"] = "%c ",
		["regionType"] = "icon",
		["stacksContainment"] = "OUTSIDE",
		["zoom"] = 0,
		["auto"] = true,
		["stacksPoint"] = "BOTTOM",
		["color"] = {1, 1, 1, 1},
		["frameStrata"] = 1,
		["width"] = 186.000091552734,
		["stickyDuration"] = false,
		["untrigger"] = {
			["custom"] = "function()\n    return true\nend",
		},
		["inverse"] = false,
		["numTriggers"] = 1,
		["animation"] = {
			["start"] = {
				["type"] = "none",
				["duration_type"] = "seconds",
			},
			["main"] = {
				["type"] = "none",
				["duration_type"] = "seconds",
			},
			["finish"] = {
				["type"] = "none",
				["duration_type"] = "seconds",
			},
		},
		["icon"] = true,
		["cooldown"] = true,
		["textColor"] = {1, 1, 1, 1},
	}
	
	local text_dbm_timerbar_prototype = {
		["outline"] = true,
		["fontSize"] = 72,
		["color"] = {1, 1, 1, 1},
		["displayText"] = "%c",
		["customText"] = "function()\n    local at = aura_env.untrigger_at\n    if (at) then\n        return \"\" .. aura_env.ability_text .. \"\\n\" .. format (\"%.1f\", at - GetTime())\n    else\n        return \"\"\n    end    \n    \nend",
		["untrigger"] = {
			["custom"] = "function()\n    return true\nend",
		},
		["regionType"] = "text",
		["customTextUpdate"] = "update",
		["init_completed"] = 1,
		["actions"] = {
			["start"] = {
			},
			["finish"] = {
			},
			["init"] = {
				["do_custom"] = true,
				["custom"] = "aura_env.countdown_at = 4\naura_env.ability_name = \"Test Bar\"\naura_env.ability_icon = \"Interface\\\\ICONS\\\\Ability_Mage_FireStarter\"\naura_env.ability_text = \"** Next TEST BAR In **\"\naura_env.aura_global_name = \"Test Bar\"\n\nlocal details_aura_env = _G.DetailsAuraEnv\nlocal details_aura_func_cache = _G.DetailsAuraFuncCache\nif (not details_aura_env) then\n    details_aura_env = {}\n    _G.DetailsAuraEnv = details_aura_env\nend\nif (not details_aura_func_cache) then\n    details_aura_func_cache = {}\n    _G.DetailsAuraFuncCache = details_aura_func_cache\nend\n\ndetails_aura_env [aura_env.aura_global_name] = aura_env\n\naura_env.Calllback_func = function (event, timer_id, message, duration)\n    if (timer_id:find (\"Test Bar\")) then\n        duration = duration:gsub (DBM_CORE_SEC, \"\")\n        duration = tonumber (duration)\n        local aura_env = details_aura_env [\"Test Bar\"]\n        aura_env.trigger_at = GetTime() + duration - aura_env.countdown_at\n        aura_env.untrigger_at = GetTime() + duration\n    end\nend\n\nlocal previous_func = details_aura_func_cache [aura_env.aura_global_name]\nif (previous_func and DBM:IsCallbackRegistered (\"DBM_TimerStart\", previous_func)) then\n    DBM:UnregisterCallback (\"DBM_TimerStart\", previous_func)\nend\n\ndetails_aura_func_cache [aura_env.aura_global_name] = aura_env.Calllback_func\nDBM:RegisterCallback (\"DBM_TimerStart\", aura_env.Calllback_func)",
			},
		},
		["justify"] = "CENTER",
		["selfPoint"] = "CENTER",
		["trigger"] = {
			["type"] = "custom",
			["subeventSuffix"] = "_CAST_START",
			["custom_type"] = "status",
			["spellIds"] = {
			},
			["event"] = "Health",
			["unit"] = "player",
			["customDuration"] = "",
			["customName"] = "",
			["custom"] = "function()\n    if (InCombatLockdown() and aura_env.trigger_at and aura_env.trigger_at <= GetTime() and aura_env.untrigger_at and aura_env.untrigger_at >= GetTime()) then\n        return true\n    else\n        return false\n    end\nend\n",
			["customIcon"] = "",
			["check"] = "update",
			["subeventPrefix"] = "SPELL",
			["names"] = {
			},
			["debuffType"] = "HELPFUL",
		},
		["yOffset"] = 251.43896484375,
		["frameStrata"] = 1,
		["width"] = 43.6800079345703,
		["animation"] = {
			["start"] = {
				["duration_type"] = "seconds",
				["type"] = "none",
			},
			["main"] = {
				["duration_type"] = "seconds",
				["type"] = "none",
			},
			["finish"] = {
				["duration_type"] = "seconds",
				["type"] = "none",
			},
		},
		["font"] = "Friz Quadrata TT",
		["numTriggers"] = 1,
		["xOffset"] = 0.999847412109,
		["height"] = 71.9999771118164,
		["load"] = {
			["use_never"] = false,
			["talent"] = {
				["multi"] = {
				},
			},
			["class"] = {
				["multi"] = {
				},
			},
			["difficulty"] = {
				["multi"] = {
				},
			},
			["role"] = {
				["multi"] = {
				},
			},
			["spec"] = {
				["multi"] = {
				},
			},
			["race"] = {
				["multi"] = {
				},
			},
			["size"] = {
				["multi"] = {
				},
			},
		},
		["anchorPoint"] = "CENTER",
	}
	
	local text_prototype = {
		["outline"] = true,
		["fontSize"] = 12,
		["color"] = {1, 1, 1, 1},
		["displayText"] = "",
		["yOffset"] = 0,
		["anchorPoint"] = "CENTER",
		["customTextUpdate"] = "update",
		["actions"] = {
			["start"] = {
			},
			["finish"] = {
			},
			["init"] = {
			},
		},
		["justify"] = "LEFT",
		["selfPoint"] = "BOTTOM",
		["trigger"] = {
			["type"] = "aura",
			["spellId"] = "0",
			["subeventSuffix"] = "_CAST_START",
			["custom_hide"] = "timed",
			["event"] = "Health",
			["subeventPrefix"] = "SPELL",
			["debuffClass"] = "magic",
			["use_spellId"] = true,
			["spellIds"] = {},
			["name_operator"] = "==",
			["fullscan"] = true,
			["unit"] = "player",
			["names"] = {
				"",
			},
			["debuffType"] = "HARMFUL",
		},
		["untrigger"] = {
		},
		["frameStrata"] = 1,
		["width"] = 31.0000057220459,
		["animation"] = {
			["start"] = {
				["duration_type"] = "seconds",
				["type"] = "none",
			},
			["main"] = {
				["duration_type"] = "seconds",
				["type"] = "none",
			},
			["finish"] = {
				["duration_type"] = "seconds",
				["type"] = "none",
			},
		},
		["font"] = "Friz Quadrata TT",
		["numTriggers"] = 1,
		["xOffset"] = 0,
		["height"] = 11.8704862594604,
		["load"] = {
			["use_combat"] = true,
			["race"] = {
				["multi"] = {
				},
			},
			["talent"] = {
				["multi"] = {
				},
			},
			["role"] = {
				["multi"] = {
				},
			},
			["spec"] = {
				["multi"] = {
				},
			},
			["class"] = {
				["multi"] = {
				},
			},
			["size"] = {
				["multi"] = {
				},
			},
		},
		["regionType"] = "text",
	}
	
	local aurabar_prototype = {
		["sparkWidth"] = 10,
		["stacksSize"] = 12,
		["xOffset"] = 0,
		["stacksFlags"] = "None",
		["yOffset"] = 0,
		["anchorPoint"] = "CENTER",
		["borderColor"] = {1, 1, 1, 0.5},
		["rotateText"] = "NONE",
		["backgroundColor"] = { 0, 0, 0, 0.5,},
		["fontFlags"] = "OUTLINE",
		["icon_color"] = {1, 1, 1, 1},
		["selfPoint"] = "CENTER",
		["barColor"] = {1, 0, 0, 1},
		["desaturate"] = false,
		["sparkOffsetY"] = 0,
		["load"] = {
			["use_combat"] = true,
			["race"] = {
				["multi"] = {
				},
			},
			["talent"] = {
				["multi"] = {
				},
			},
			["role"] = {
				["multi"] = {
				},
			},
			["spec"] = {
				["multi"] = {
				},
			},
			["class"] = {
				["multi"] = {
				},
			},
			["size"] = {
				["multi"] = {
				},
			},
		},
		["timerColor"] = {1, 1, 1, 1},
		["regionType"] = "aurabar",
		["stacks"] = true,
		["texture"] = "Blizzard",
		["textFont"] = "Friz Quadrata TT",
		["zoom"] = 0,
		["spark"] = false,
		["timerFont"] = "Friz Quadrata TT",
		["alpha"] = 1,
		["borderInset"] = 11,
		["textColor"] = {1, 1, 1, 1},
		["borderBackdrop"] = "Blizzard Tooltip",
		["barInFront"] = true,
		["sparkRotationMode"] = "AUTO",
		["displayTextLeft"] = "%n",
		["animation"] = {
			["start"] = {
				["duration_type"] = "seconds",
				["type"] = "none",
			},
			["main"] = {
				["duration_type"] = "seconds",
				["type"] = "none",
			},
			["finish"] = {
				["duration_type"] = "seconds",
				["type"] = "none",
			},
		},
		["trigger"] = {
			["type"] = "aura",
			["spellId"] = "0",
			["subeventSuffix"] = "_CAST_START",
			["custom_hide"] = "timed",
			["event"] = "Health",
			["subeventPrefix"] = "SPELL",
			["debuffClass"] = "magic",
			["use_spellId"] = true,
			["spellIds"] = {},
			["name_operator"] = "==",
			["fullscan"] = true,
			["unit"] = "player",
			["names"] = {
				"",
			},
			["debuffType"] = "HARMFUL",
		},
		["text"] = true,
		["stickyDuration"] = false,
		["height"] = 15,
		["timerFlags"] = "None",
		["sparkBlendMode"] = "ADD",
		["backdropColor"] = {1, 1, 1, 0.5},
		["untrigger"] = {
		},
		["actions"] = {
			["start"] = {
			},
			["finish"] = {
			},
			["init"] = {
			},
		},
		["textFlags"] = "None",
		["border"] = false,
		["borderEdge"] = "None",
		["sparkOffsetX"] = 0,
		["borderSize"] = 16,
		["stacksFont"] = "Friz Quadrata TT",
		["icon_side"] = "RIGHT",
		["textSize"] = 12,
		["timer"] = true,
		["sparkHeight"] = 30,
		["sparkRotation"] = 0,
		["customTextUpdate"] = "update",
		["stacksColor"] = {1, 1, 1, 1},
		["displayTextRight"] = "%p",
		["icon"] = true,
		["inverse"] = false,
		["frameStrata"] = 1,
		["width"] = 200,
		["sparkColor"] = {1, 1, 1, 1},
		["timerSize"] = 12,
		["numTriggers"] = 1,
		["sparkDesature"] = false,
		["orientation"] = "HORIZONTAL",
		["borderOffset"] = 5,
		["auto"] = true,
		["sparkTexture"] = "Interface\\CastingBar\\UI-CastingBar-Spark",
	}
	
	local icon_prototype = {
		["yOffset"] = 202.07,
		["xOffset"] = -296.82,
		["fontSize"] = 14,
		["displayStacks"] = "%s",
		["parent"] = "Details! Aura Group",
		["color"] = {1, 1, 1, 1},
		["stacksPoint"] = "BOTTOMRIGHT",
		["regionType"] = "icon",
		["untrigger"] = {},
		["anchorPoint"] = "CENTER",
		["icon"] = true,
		["numTriggers"] = 1,
		["customTextUpdate"] = "update",
		["id"] = "UNNAMED",
		["actions"] = {},
		["fontFlags"] = "OUTLINE",
		["stacksContainment"] = "INSIDE",
		["zoom"] = 0,
		["auto"] = false,
		["animation"] = {
			["start"] = {
				["duration_type"] = "seconds",
				["type"] = "preset",
				["preset"] = "grow",
			},
			["main"] = {
				["duration_type"] = "seconds",
				["type"] = "preset",
				["preset"] = "pulse",
			},
			["finish"] = {
				["duration_type"] = "seconds",
				["type"] = "none",
			},
		},
		["trigger"] = {
			["type"] = "aura",
			["spellId"] = "0",
			["subeventSuffix"] = "_CAST_START",
			["custom_hide"] = "timed",
			["event"] = "Health",
			["subeventPrefix"] = "SPELL",
			["debuffClass"] = "magic",
			["use_spellId"] = true,
			["spellIds"] = {},
			["name_operator"] = "==",
			["fullscan"] = true,
			["unit"] = "player",
			["names"] = {
				"",
			},
			["debuffType"] = "HARMFUL",
		},
		["desaturate"] = false,
		["frameStrata"] = 1,
		["stickyDuration"] = false,
		["width"] = 192,
		["font"] = "Friz Quadrata TT",
		["inverse"] = false,
		["selfPoint"] = "CENTER",
		["height"] = 192,
		["displayIcon"] = "Interface\\Icons\\Spell_Holiday_ToW_SpiceCloud",
		["load"] = {
			["use_combat"] = true,
			["race"] = {
				["multi"] = {
				},
			},
			["talent"] = {
				["multi"] = {
				},
			},
			["role"] = {
				["multi"] = {
				},
			},
			["spec"] = {
				["multi"] = {
				},
			},
			["class"] = {
				["multi"] = {
				},
			},
			["size"] = {
				["multi"] = {
				},
			},
		},
		["textColor"] = {1, 1, 1, 1},
	}
	
	local actions_prototype = {
		["start"] = {
			["do_glow"] = true,
			["glow_action"] = "show",
			["do_sound"] = true,
			["glow_frame"] = "WeakAuras:Crystalline Barrage Step",
			["sound"] = "Interface\\AddOns\\WeakAuras\\Media\\Sounds\\WaterDrop.ogg",
			["sound_channel"] = "Master",
		},
		["finish"] = {},
	}
	
	local debuff_prototype = {
		["cooldown"] = false,
		["trigger"] = {
			["spellId"] = "0",
			["unit"] = "",
			["spellIds"] = {},
			["debuffType"] = "HARMFUL",
			["names"] = {""},
		},
	}
	local buff_prototype = {
		["cooldown"] = false,
		["trigger"] = {
			["spellId"] = "0",
			["unit"] = "",
			["spellIds"] = {},
			["debuffType"] = "HELPFUL",
			["names"] = {""},
		},
	}
	local cast_prototype = {
		["trigger"] = {
			["type"] = "event",
			["spellId"] = "0",
			["subeventSuffix"] = "_CAST_SUCCESS",
			["unevent"] = "timed",
			["duration"] = "4",
			["event"] = "Combat Log",
			["subeventPrefix"] = "SPELL",
			["use_spellId"] = true,
		}
	}
	
	local stack_prototype = {
		["trigger"] = {
			["countOperator"] = ">=",
			["count"] = "0",
			["useCount"] = true,
		},
	}
	
	local sound_prototype = {
		["actions"] = {
			["start"] = {
				["do_sound"] = true,
				["sound"] = "Interface\\Quiet.ogg",
				["sound_channel"] = "Master",
			},
		},
	}
	
	local sound_prototype_custom = {
		["actions"] = {
			["start"] = {
				["do_sound"] = true,
				["sound"] = " custom",
				["sound_path"] = "Interface\\Quiet.ogg",
				["sound_channel"] = "Master",
			},
		},
	}
	
	local chat_prototype = {
		["actions"] = {
			["start"] = {
				["message"] = "",
				["message_type"] = "SAY",
				["do_message"] = true,
			},
		},
	}
	
	local widget_text_prototype = {
		["fontSize"] = 20,
		["displayStacks"] = "",
		["stacksPoint"] = "BOTTOM",
		["stacksContainment"] = "OUTSIDE",
	}
	
	local glow_prototype = {
		["actions"] = {
			["start"] = {
				["do_glow"] = true,
				["glow_frame"] = "",
				["glow_action"] = "show",
			},
		},
	}
	
	function _detalhes:CreateWeakAura (aura_type, spellid, use_spellid, spellname, name, icon_texture, target, stacksize, sound, chat, icon_text, icon_glow, encounter_id, group, icon_size, other_values)
	
		--> check if wa is installed
		if (not WeakAuras or not WeakAurasSaved) then
			return
		end
		
		--> check if there is a group for our auras
		if (not WeakAurasSaved.displays ["Details! Aura Group"]) then
			local group = _detalhes.table.copy ({}, group_prototype)
			WeakAuras.Add (group)
		end
		
		if (not WeakAurasSaved.displays ["Details! Boss Mods Group"]) then
			local group = _detalhes.table.copy ({}, group_prototype_boss_mods)
			WeakAuras.Add (group)
		end

		--> create the icon table
		local new_aura
		icon_size = icon_size or 40
		
		if (other_values.dbm_timer_id or other_values.bw_timer_id) then
			if (aura_type == "icon") then
				new_aura = _detalhes.table.copy ({}, icon_dbm_timerbar_prototype)
			elseif (aura_type == "aurabar") then
				new_aura = _detalhes.table.copy ({}, bar_dbm_timerbar_prototype)
			elseif (aura_type == "text") then
				new_aura = _detalhes.table.copy ({}, text_dbm_timerbar_prototype)
			end

			new_aura.actions.init.custom = [[
				aura_env.dbm_timer_id = "@dbm_timer_id"
				aura_env.bw_timer_id = "@bw_timer_id"
				
				aura_env.countdown_at = @countdown
				aura_env.ability_name = "@name"
				aura_env.ability_icon = [=[@icon]=]
				aura_env.ability_text = "@text"
				aura_env.aura_global_name = "@gname"

				local details_aura_env = _G.DetailsAuraEnv
				local details_aura_func_cache = _G.DetailsAuraFuncCache

				if (not details_aura_env) then
					details_aura_env = {}
					_G.DetailsAuraEnv = details_aura_env
				end
				if (not details_aura_func_cache) then
					details_aura_func_cache = {}
					_G.DetailsAuraFuncCache = details_aura_func_cache
				end

				if (BigWigs) then
					local old_aura_env = details_aura_env [aura_env.aura_global_name]
					if (old_aura_env) then
						old_aura_env:UnregisterMessage ("BigWigs_StartBar")
					end
				elseif (_G.DBM) then
					local previous_func = details_aura_func_cache [aura_env.aura_global_name]
					if (previous_func and DBM:IsCallbackRegistered ("DBM_TimerStart", previous_func)) then
						DBM:UnregisterCallback ("DBM_TimerStart", previous_func)
					end
				end
				
				details_aura_env [aura_env.aura_global_name] = aura_env

				if (_G.DBM) then
					aura_env.Calllback_func = function (event, timer_id, message, duration)
						local aura_env = DetailsAuraEnv ["@gname"]
						if (timer_id:find (aura_env.dbm_timer_id)) then
							duration = duration:gsub (DBM_CORE_SEC, "")
							duration = tonumber (duration)
							aura_env.trigger_at = GetTime() + duration - aura_env.countdown_at
							aura_env.untrigger_at = GetTime() + duration
						end
					end
					details_aura_func_cache [aura_env.aura_global_name] = aura_env.Calllback_func
					DBM:RegisterCallback ("DBM_TimerStart", aura_env.Calllback_func)
				end
				if (BigWigs) then
					function aura_env:BigWigs_StartBar (event, module, spellid, bar_text, time, icon, ...)
						local aura_env = DetailsAuraEnv ["@gname"]
						if (tostring (spellid) == aura_env.bw_timer_id) then
							duration = time
							aura_env.trigger_at = GetTime() + duration - aura_env.countdown_at
							aura_env.untrigger_at = GetTime() + duration
						end
					end
					BigWigs.RegisterMessage (aura_env, "BigWigs_StartBar")
				end
			]]
			
			local c = new_aura.actions.init.custom
			
			if (other_values.dbm_timer_id) then
				local dbm_tid = tostring (other_values.dbm_timer_id):match ("%d+", 1)
				c = c:gsub ("@dbm_timer_id", dbm_tid)
				c = c:gsub ("@bw_timer_id", "Timer ID Not Set")
				c = c:gsub ("@gname", "DetailsAura_" .. dbm_tid)
				
			elseif (other_values.bw_timer_id) then
				local bw_tid = other_values.bw_timer_id
				c = c:gsub ("@bw_timer_id", bw_tid)
				c = c:gsub ("@dbm_timer_id", "Timer ID Not Set")
				c = c:gsub ("@gname", "DetailsAura_" .. bw_tid)
			end

			if (aura_type == "aurabar") then
				icon_text = icon_text:gsub ("= ", "")
				icon_text = icon_text:gsub (" =", "")
				icon_text = icon_text:gsub ("=", "")
			end
			
			c = c:gsub ("@text", icon_text)
			c = c:gsub ("@icon", icon_texture)
			c = c:gsub ("@name", spellname)
			c = c:gsub ("@countdown", floor (stacksize))
			
			new_aura.actions.init.custom = c

			--> size
			if (aura_type == "icon") then
				new_aura.width = icon_size
				new_aura.height = icon_size
			elseif (aura_type == "aurabar") then
				new_aura.width = min (icon_size, 370)
				new_aura.height = 40
			elseif (aura_type == "text") then
				new_aura.fontSize = min (icon_size, 72)
			end
			
		else
		
			if (aura_type == "icon") then
				new_aura = _detalhes.table.copy ({}, icon_prototype)
			elseif (aura_type == "aurabar") then
				new_aura = _detalhes.table.copy ({}, aurabar_prototype)
			elseif (aura_type == "text") then
				new_aura = _detalhes.table.copy ({}, text_prototype)
				new_aura.displayText = spellname
			end
		
			if (target) then
				if (target == 1) then --Debuff on Player
					local add = _detalhes.table.copy ({}, debuff_prototype)
					add.trigger.spellId = tostring (spellid)
					add.trigger.spellIds[1] = spellid
					add.trigger.names [1] = spellname
					add.trigger.unit = "player"
					_detalhes.table.deploy (new_aura, add)
					
				elseif (target == 2) then --Debuff on Target
					local add = _detalhes.table.copy ({}, debuff_prototype)
					add.trigger.spellId = tostring (spellid)
					add.trigger.spellIds[1] = spellid
					add.trigger.names[1] = spellname
					add.trigger.unit = "target"
					_detalhes.table.deploy (new_aura, add)

				elseif (target == 3) then --Debuff on Focus
					local add = _detalhes.table.copy ({}, debuff_prototype)
					add.trigger.spellId = tostring (spellid)
					add.trigger.spellIds[1] = spellid
					add.trigger.names[1] = spellname
					add.trigger.unit = "focus"
					_detalhes.table.deploy (new_aura, add)
					
				elseif (target == 11) then --Buff on Player
					local add = _detalhes.table.copy ({}, buff_prototype)
					add.trigger.spellId = tostring (spellid)
					add.trigger.spellIds[1] = spellid
					add.trigger.names[1] = spellname
					add.trigger.unit = "player"
					_detalhes.table.deploy (new_aura, add)
					
				elseif (target == 12) then --Buff on Target
					local add = _detalhes.table.copy ({}, buff_prototype)
					add.trigger.spellId = tostring (spellid)
					add.trigger.spellIds[1] = spellid
					add.trigger.names[1] = spellname
					add.trigger.unit = "target"
					_detalhes.table.deploy (new_aura, add)
					
				elseif (target == 13) then --Buff on Focus
					local add = _detalhes.table.copy ({}, buff_prototype)
					add.trigger.spellId = tostring (spellid)
					add.trigger.spellIds[1] = spellid
					add.trigger.names[1] = spellname
					add.trigger.unit = "focus"
					_detalhes.table.deploy (new_aura, add)
					
				elseif (target == 21) then --Spell Cast Started
					local add = _detalhes.table.copy ({}, cast_prototype)
					add.trigger.spellId = tostring (spellid)
					add.trigger.spellName = spellname
					add.trigger.subeventSuffix = "_CAST_START"
					if (not use_spellid) then
						add.trigger.use_spellName = true
						add.trigger.use_spellId = false
					end
					_detalhes.table.deploy (new_aura, add)
					
				elseif (target == 22) then --Spell Cast Successful
					local add = _detalhes.table.copy ({}, cast_prototype)
					add.trigger.spellId = tostring (spellid)
					add.trigger.spellName = spellname
					if (not use_spellid) then
						add.trigger.use_spellName = true
						add.trigger.use_spellId = false
					end
					_detalhes.table.deploy (new_aura, add)
				end
			else
				new_aura.trigger.spellId = tostring (spellid)
				new_aura.trigger.name = spellname
				tinsert (new_aura.trigger.spellIds, spellid)
			end
			
			--> if is a regular auras withour using spells ids
			if (not use_spellid) then
				new_aura.trigger.use_spellId = false
				new_aura.trigger.fullscan = false
				new_aura.trigger.spellId = nil
				new_aura.trigger.spellIds = {}
			end
			
			--> check stack size
			if (stacksize and stacksize >= 1) then
				stacksize = floor (stacksize)
				local add = _detalhes.table.copy ({}, stack_prototype)
				add.trigger.count = tostring (stacksize)
				_detalhes.table.deploy (new_aura, add)
			end
			
			--> icon text
			if (icon_text and icon_text ~= "") then
				if (aura_type == "text") then
					new_aura.displayText = icon_text
				else
					local add = _detalhes.table.copy ({}, widget_text_prototype)
					add.displayStacks = icon_text
					_detalhes.table.deploy (new_aura, add)
				end
			end
			
			--> size
			if (aura_type == "icon") then
				new_aura.width = icon_size
				new_aura.height = icon_size
			elseif (aura_type == "aurabar") then
				new_aura.width = min (icon_size, 250)
				new_aura.height = 24
			elseif (aura_type == "text") then
				new_aura.fontSize = min (icon_size, 24)
			end
		end
		
		new_aura.id = name
		new_aura.displayIcon = icon_texture		
	
		--> load by encounter id
		if (encounter_id) then
			new_aura.load.use_encounterid = true
			new_aura.load.encounterid = tostring (encounter_id)
		end

		--> using sound
		if (sound and type (sound) == "table") then
			local add = _detalhes.table.copy ({}, sound_prototype_custom)
			add.actions.start.sound_path = sound.sound_path
			add.actions.start.sound_channel = sound.sound_channel or "Master"
			_detalhes.table.deploy (new_aura, add)
			
		elseif (sound and sound ~= "" and not sound:find ("Quiet.ogg")) then
			local add = _detalhes.table.copy ({}, sound_prototype)
			add.actions.start.sound = sound
			_detalhes.table.deploy (new_aura, add)
		end
		
		--> chat message
		if (chat and chat ~= "") then
			local add = _detalhes.table.copy ({}, chat_prototype)
			add.actions.start.message = chat
			_detalhes.table.deploy (new_aura, add)
		end
		
		--> check if already exists a aura with this name
		if (WeakAurasSaved.displays [new_aura.id]) then
			for i = 2, 100 do
				if (not WeakAurasSaved.displays [new_aura.id .. " (" .. i .. ")"]) then
					new_aura.id = new_aura.id .. " (" .. i .. ")"
					break
				end
			end
		end
		
		--> check is is using glow effect
		if (icon_glow) then
			local add = _detalhes.table.copy ({}, glow_prototype)
			add.actions.start.glow_frame = "WeakAuras:" .. new_aura.id
			_detalhes.table.deploy (new_aura, add)
		end
		
		--> add the aura on a group
		if (group) then
			new_aura.parent = group
			tinsert (WeakAurasSaved.displays [group].controlledChildren, new_aura.id)
		else
			new_aura.parent = nil
		end
		
		--> add the aura
		WeakAuras.Add (new_aura)
		
		--> check if the options panel has loaded
		local options_frame = WeakAuras.OptionsFrame and WeakAuras.OptionsFrame()
		if (options_frame) then
			if (options_frame and not options_frame:IsShown()) then
				WeakAuras.ToggleOptions()
			end
			WeakAuras.NewDisplayButton (new_aura)
		end

	end
	
	local empty_other_values = {}
	function _detalhes:OpenAuraPanel (spellid, spellname, spellicon, encounterid, triggertype, auratype, other_values)
		
		if (not spellname) then
			spellname = select (1, GetSpellInfo (spellid))
		end

		wipe (empty_other_values)
		other_values = other_values or empty_other_values
		
		if (not DetailsAuraPanel) then
			
			--> check if there is a group for our auras
			if (WeakAuras and WeakAurasSaved) then
				if (not WeakAurasSaved.displays ["Details! Aura Group"]) then
					local group = _detalhes.table.copy ({}, group_prototype)
					WeakAuras.Add (group)
				end
				if (not WeakAurasSaved.displays ["Details! Boss Mods Group"]) then
					local group = _detalhes.table.copy ({}, group_prototype_boss_mods)
					WeakAuras.Add (group)
				end
			end

			local f = CreateFrame ("frame", "DetailsAuraPanel", UIParent, "ButtonFrameTemplate")
			f:SetSize (600, 488)
			f:SetPoint ("center", UIParent, "center")
			f:SetFrameStrata ("HIGH")
			f:SetToplevel (true)
			f:SetMovable (true)
			
			tinsert (UISpecialFrames, "DetailsAuraPanel")
			
			f:SetScript ("OnMouseDown", function(self, button)
				if (self.isMoving) then
					return
				end
				if (button == "RightButton") then
					self:Hide()
				else
					self:StartMoving() 
					self.isMoving = true
				end
			end)
			f:SetScript ("OnMouseUp", function(self, button) 
				if (self.isMoving and button == "LeftButton") then
					self:StopMovingOrSizing()
					self.isMoving = nil
				end
			end)
			
			f.TitleText:SetText ("Create Aura")
			f.portrait:SetTexture ([[Interface\CHARACTERFRAME\TEMPORARYPORTRAIT-FEMALE-BLOODELF]])
			
			local fw = _detalhes:GetFramework()
			
			--aura name
			local name_label = fw:CreateLabel (f, "Aura Name: ", nil, nil, "GameFontNormal")
			local name_textentry = fw:CreateTextEntry (f, _detalhes.empty_function, 150, 20, "AuraName", "$parentAuraName")
			name_textentry:SetPoint ("left", name_label, "right", 2, 0)
			f.name = name_textentry
			
			--aura type
			local on_select_aura_type = function (_, _, aura_type)
				if (f.UpdateLabels) then
					f:UpdateLabels()
				end
			end
			local aura_type_table = {
				{label = "Icon", value = "icon", onclick = on_select_aura_type}, --, icon = aura_on_icon
				{label = "Text", value = "text", onclick = on_select_aura_type},
				{label = "Progress Bar", value = "aurabar", onclick = on_select_aura_type},
			}
			local aura_type_options = function()
				return aura_type_table
			end
			local aura_type = fw:CreateDropDown (f, aura_type_options, 1, 150, 20, "AuraTypeDropdown", "$parentAuraTypeDropdown")
			local aura_type_label = fw:CreateLabel (f, "Aura Type: ", nil, nil, "GameFontNormal")
			aura_type:SetPoint ("left", aura_type_label, "right", 2, 0)
			
			--spellname
			local spellname_label = fw:CreateLabel (f, "Spell Name: ", nil, nil, "GameFontNormal")
			local spellname_textentry = fw:CreateTextEntry (f, _detalhes.empty_function, 150, 20, "SpellName", "$parentSpellName")
			spellname_textentry:SetPoint ("left", spellname_label, "right", 2, 0)
			f.spellname = spellname_textentry
			spellname_textentry.tooltip = "Spell/Debuff/Buff to be tracked."
			
			--spellid
			local auraid_label = fw:CreateLabel (f, "Spell Id: ", nil, nil, "GameFontNormal")
			local auraid_textentry = fw:CreateTextEntry (f, _detalhes.empty_function, 150, 20, "AuraSpellId", "$parentAuraSpellId")
			auraid_textentry:Disable()
			auraid_textentry:SetPoint ("left", auraid_label, "right", 2, 0)
			
			--use spellid
			local usespellid_label = fw:CreateLabel (f, "Use SpellId: ", nil, nil, "GameFontNormal")
			local aura_use_spellid = fw:CreateSwitch (f, function(_, _, state) if (state) then auraid_textentry:Enable() else auraid_textentry:Disable() end end, false, nil, nil, nil, nil, "UseSpellId")
			aura_use_spellid:SetPoint ("left", usespellid_label, "right", 2, 0)
			aura_use_spellid.tooltip = "Use the spell id instead of the spell name, for advanced users."
			
			--aura icon
			local icon_label = fw:CreateLabel (f, "Icon: ", nil, nil, "GameFontNormal")
			local icon_button_func = function (texture)
				f.IconButton.icon.texture = texture
			end
			local icon_pick_button = fw:NewButton (f, nil, "$parentIconButton", "IconButton", 20, 20, function() fw:IconPick (icon_button_func, true) end)
			local icon_button_icon = fw:NewImage (icon_pick_button, [[Interface\ICONS\TEMP]], 19, 19, "background", nil, "icon", "$parentIcon")
			icon_pick_button:InstallCustomTexture()
			
			icon_pick_button:SetPoint ("left", icon_label, "right", 2, 0)
			icon_button_icon:SetPoint ("left", icon_label, "right", 2, 0)
			
			f.icon = icon_button_icon
			
			--target
			local on_select_aura_trigger = function (_, _, aura_trigger)
				if (f.UpdateLabels) then
					f:UpdateLabels()
				end
			end
			
			local aura_on_icon = [[Interface\Buttons\UI-GroupLoot-DE-Down]]
			local aura_on_table = {
				{label = "Debuff on You", value = 1, icon = aura_on_icon, onclick = on_select_aura_trigger},
				{label = "Debuff on Target", value = 2, icon = aura_on_icon, onclick = on_select_aura_trigger},
				{label = "Debuff on Focus", value = 3, icon = aura_on_icon, onclick = on_select_aura_trigger},
				
				{label = "Buff on You", value = 11, icon = aura_on_icon, onclick = on_select_aura_trigger},
				{label = "Buff on Target", value = 12, icon = aura_on_icon, onclick = on_select_aura_trigger},
				{label = "Buff on Focus", value = 13, icon = aura_on_icon, onclick = on_select_aura_trigger},
				
				{label = "Spell Cast Started", value = 21, icon = aura_on_icon, onclick = on_select_aura_trigger},
				{label = "Spell Cast Successful", value = 22, icon = aura_on_icon, onclick = on_select_aura_trigger},
				
				{label = "DBM Time Bar", value = 31, icon = aura_on_icon, onclick = on_select_aura_trigger},
				{label = "BigWigs Time Bar", value = 32, icon = aura_on_icon, onclick = on_select_aura_trigger},
			}
			local aura_on_options = function()
				return aura_on_table
			end
			local aura_on = fw:CreateDropDown (f, aura_on_options, 1, 150, 20, "AuraOnDropdown", "$parentAuraOnDropdown")
			local aura_on_label = fw:CreateLabel (f, "Trigger: ", nil, nil, "GameFontNormal")
			aura_on:SetPoint ("left", aura_on_label, "right", 2, 0)
			
			--stack
			local stack_slider = fw:NewSlider (f, f, "$parentStackSlider", "StackSlider", 150, 20, 0, 30, 1, 0)
			local stack_label = fw:CreateLabel (f, "Stack Size: ", nil, nil, "GameFontNormal")
			stack_slider:SetPoint ("left", stack_label, "right", 2, 0)
			stack_slider.tooltip = "Minimum amount of stacks to trigger the aura."
			
			--sound effect
			local play_sound = function (self, fixedParam, file)
				if (type (file) == "table") then
					PlaySoundFile (file.sound_path, "Master")
				else
					PlaySoundFile (file, "Master")
				end
			end
			
			local sort = function (t1, t2)
				return t1.name < t2.name
			end
			local titlecase = function (first, rest)
				return first:upper()..rest:lower()
			end
			local iconsize = {14, 14}
			
			local game_sounds = {
				["Horde Banner Down"] = [[Sound\event\EVENT_VashjirIntro_HordeBannerDown_01.ogg]],
				["Mast Crack"] = [[Sound\event\EVENT_VashjirIntro_MastCrack_01.ogg]],
				["Orc Attack "] = [[Sound\event\EVENT_VashjirIntro_OrcAttackVox_03.ogg]],
				["Ship Hull Impact"] = [[Sound\event\EVENT_VashjirIntro_ShipHullImpact_03.ogg]],
				["Run! 01"] = [[Sound\character\Scourge\ScourgeVocalFemale\UndeadFemaleFlee01.ogg]],
				["Run! 02"] = [[Sound\creature\HoodWolf\HoodWolfTransformPlayer01.ogg]],
				["Danger!"] = [[Sound\character\Scourge\ScourgeVocalMale\UndeadMaleIncoming01.ogg]],
				["Wing Flap 01"] = [[Sound\creature\Illidan\IllidanWingFlap2.ogg]],
				["Wing Flap 02"] = [[Sound\Universal\BirdFlap1.ogg]],
				["Not Prepared"] = [[Sound\creature\Illidan\BLACK_Illidan_04.ogg]],
				["Cannon Shot"] = [[Sound\DOODAD\AGS_BrassCannon_Custom0.ogg]],
				["Click 01"] = [[Sound\DOODAD\HangingBones_BoneClank06.ogg]],
				["Click 02"] = [[Sound\DOODAD\HangingBones_BoneClank02.ogg]],
				["Click 03"] = [[Sound\DOODAD\HangingBones_BoneClank03.ogg]],
				["Click 04"] = [[Sound\DOODAD\HangingBones_BoneClank09.ogg]],
				["Click 05"] = [[Sound\DOODAD\FX_Emote_Chopping_Wood08.ogg]],
				["Click 06"] = [[Sound\DOODAD\FX_Emote_Chopping_Wood04.ogg]],
				["Click 07"] = [[Sound\DOODAD\FX_BoardTilesDice_02.OGG]],
				["Click 08"] = [[Sound\Spells\IceCrown_Bug_Attack_08.ogg]],
				["Click 09"] = [[Sound\Spells\Tradeskills\BlackSmithCraftingE.ogg]],
				["Chest 01"] = [[Sound\DOODAD\G_BarrelOpen-Chest1.ogg]],
				["Beat 01"] = [[Sound\DOODAD\GO_PA_Kungfugear_bag_Left08.OGG]],
				["Beat 02"] = [[Sound\DOODAD\GO_PA_Kungfugear_bag_Left04.OGG]],
				["Water Drop"] = [[Sound\DOODAD\Hellfire_DW_Pipe_Type4_01.ogg]],
				["Frog"] = [[Sound\EMITTERS\Emitter_Dalaran_Petstore_Frog_01.ogg]],
			}
				
			local sound_options = function()
				local t = {{label = "No Sound", value = "", icon = [[Interface\Buttons\UI-GuildButton-MOTD-Disabled]], iconsize = iconsize}}
				
				local sounds = {}
				local already_added = {}
				
				for name, soundFile in pairs (game_sounds) do
					name = name:gsub ("(%a)([%w_']*)", titlecase)
					if (not already_added [name]) then
						sounds [#sounds+1] = {name = name, file = soundFile, gamesound = true}
						already_added [name] = true
					end
				end
				
				for name, soundFile in pairs (LibStub:GetLibrary("LibSharedMedia-3.0"):HashTable ("sound")) do
					name = name:gsub ("(%a)([%w_']*)", titlecase)
					if (not already_added [name]) then
						sounds [#sounds+1] = {name = name, file = soundFile}
						already_added [name] = true
					end
				end
				
				if (WeakAuras and WeakAuras.sound_types) then
					for soundFile, name in pairs (WeakAuras.sound_types) do
						name = name:gsub ("(%a)([%w_']*)", titlecase)
						if (not already_added [name]) then
							sounds [#sounds+1] = {name = name, file = soundFile}
						end
					end
				end
				
				table.sort (sounds, sort)
				
				for _, sound in ipairs (sounds) do
					if (sound.name:find ("D_")) then --> details sound
						tinsert (t, {color = "orange", label = sound.name, value = sound.file, icon = [[Interface\Buttons\UI-GuildButton-MOTD-Up]], onclick = play_sound, iconsize = iconsize})
					elseif (sound.gamesound) then --> game sound
						tinsert (t, {color = "yellow", label = sound.name, value = {sound_path = sound.file}, icon = [[Interface\Buttons\UI-GuildButton-MOTD-Up]], onclick = play_sound, iconsize = iconsize})
					else
						tinsert (t, {label = sound.name, value = sound.file, icon = [[Interface\Buttons\UI-GuildButton-MOTD-Up]], onclick = play_sound, iconsize = iconsize})
					end
				end
				return t
			end
			local sound_effect = fw:CreateDropDown (f, sound_options, 1, 150, 20, "SoundEffectDropdown", "$parentSoundEffectDropdown")
			local sound_effect_label = fw:CreateLabel (f, "Play Sound: ", nil, nil, "GameFontNormal")
			sound_effect:SetPoint ("left", sound_effect_label, "right", 2, 0)
			sound_effect.tooltip = "Sound played when the aura triggers."
			
			--say something
			local say_something_label = fw:CreateLabel (f, "/Say: ", nil, nil, "GameFontNormal")
			local say_something = fw:CreateTextEntry (f, _detalhes.empty_function, 150, 20, "SaySomething", "$parentSaySomething")
			say_something:SetPoint ("left", say_something_label, "right", 2, 0)
			say_something.tooltip = "Your character /say this phrase when the aura triggers."
			
			--aura text
			local aura_text_label = fw:CreateLabel (f, "Aura Text: ", nil, nil, "GameFontNormal")
			local aura_text = fw:CreateTextEntry (f, _detalhes.empty_function, 150, 20, "AuraText", "$parentAuraText")
			aura_text:SetPoint ("left", aura_text_label, "right", 2, 0)
			aura_text.tooltip = "Text shown at aura's icon right side."
			
			--apply glow
			local useglow_label = fw:CreateLabel (f, "Glow Effect: ", nil, nil, "GameFontNormal")
			local useglow = fw:CreateSwitch (f, function(self, _, state) 
				if (state and self.glow_test) then  
					self.glow_test:Show()
					self.glow_test.animOut:Stop()
					self.glow_test.animIn:Play()
				elseif (self.glow_test) then
					self.glow_test.animIn:Stop()
					self.glow_test.animOut:Play()
				end 
			end, false, nil, nil, nil, nil, "UseGlow")
			useglow:SetPoint ("left", useglow_label, "right", 2, 0)
			useglow.tooltip = "Do not rename the aura on WeakAuras options panel or the glow effect may not work."
			
			useglow.glow_test = CreateFrame ("frame", "DetailsAuraTextGlowTest", useglow.widget, "ActionBarButtonSpellActivationAlert")
			useglow.glow_test:SetPoint ("topleft", useglow.widget, "topleft", -20, 2)
			useglow.glow_test:SetPoint ("bottomright", useglow.widget, "bottomright", 20, -2)
			useglow.glow_test:Hide()

			--encounter id
			local encounterid_label = fw:CreateLabel (f, "Encounter ID: ", nil, nil, "GameFontNormal")
			local encounterid = fw:CreateTextEntry (f, _detalhes.empty_function, 150, 20, "EncounterIdText", "$parentEncounterIdText")
			encounterid:SetPoint ("left", encounterid_label, "right", 2, 0)
			encounterid.tooltip = "Only load this aura for this raid encounter."
			
			--size
			local icon_size_slider = fw:NewSlider (f, f, "$parentIconSizeSlider", "IconSizeSlider", 150, 20, 16, 256, 1, 64)
			local icon_size_label = fw:CreateLabel (f, "Size: ", nil, nil, "GameFontNormal")
			icon_size_slider:SetPoint ("left", icon_size_label, "right", 2, 0)
			icon_size_slider.tooltip = "Icon size, width and height."
			
			--aura addon
			local addon_options = function()
				local t = {}
				if (WeakAuras) then
					tinsert (t, {label = "Weak Auras 2", value = "WA", icon = [[Interface\AddOns\WeakAuras\icon]]})
				end
				return t
			end
			local aura_addon = fw:CreateDropDown (f, addon_options, 1, 150, 20, "AuraAddonDropdown", "$parentAuraAddonDropdown")
			local aura_addon_label = fw:CreateLabel (f, "Addon: ", nil, nil, "GameFontNormal")
			aura_addon:SetPoint ("left", aura_addon_label, "right", 2, 0)
			
			--weakauras - group
			
			local folder_icon = [[Interface\AddOns\Details\images\icons]]
			local folder_texcoord = {435/512, 469/512, 189/512, 241/512}
			local folder_iconsize = {14, 14}

			local sort_func = function (t1, t2) return t1.label < t2.label end
			
			local weakauras_folder_options = function()
				local t = {}
				if (WeakAuras and WeakAurasSaved) then
					for display_name, aura_table in pairs (WeakAurasSaved.displays) do
						if (aura_table.regionType == "dynamicgroup" or aura_table.regionType == "group") then
							tinsert (t, {label = display_name, value = display_name, icon = folder_icon, texcoord = folder_texcoord, iconsize = folder_iconsize})
						end
					end
				end
				table.sort (t, sort_func)
				tinsert (t, 1, {label = "No Group", value = false, icon = folder_icon, texcoord = folder_texcoord, iconcolor = {0.8, 0.2, 0.2}, iconsize = folder_iconsize})
				return t
			end
			
			local weakauras_folder_label = fw:CreateLabel (f, "Weak Auras Group: ", nil, nil, "GameFontNormal")
			local weakauras_folder = fw:CreateDropDown (f, weakauras_folder_options, 1, 150, 20, "WeakaurasFolderDropdown", "$parentWeakaurasFolder")
			weakauras_folder:SetPoint ("left", weakauras_folder_label, "right", 2, 0)
			
			--create
			local create_func = function()
				
				local name = f.AuraName.text
				local aura_type_value = f.AuraTypeDropdown.value
				local spellname = f.SpellName.text
				local use_spellId = f.UseSpellId.value
				local spellid = f.AuraSpellId.text
				local icon = f.IconButton.icon.texture
				local target = f.AuraOnDropdown.value
				local stacksize = f.StackSlider.value
				local sound = f.SoundEffectDropdown.value
				local chat = f.SaySomething.text
				local addon = f.AuraAddonDropdown.value
				local folder = f.WeakaurasFolderDropdown.value
				local iconsize = f.IconSizeSlider.value
				
				local icon_text = f.AuraText.text
				local icon_glow = f.UseGlow.value
				
				local eid = DetailsAuraPanel.EncounterIdText.text
				if (eid == "") then
					eid = nil
				end
				
				if (addon == "WA") then
					_detalhes:CreateWeakAura (aura_type_value, spellid, use_spellId, spellname, name, icon, target, stacksize, sound, chat, icon_text, icon_glow, eid, folder, iconsize, f.other_values)
				else
					_detalhes:Msg ("No Aura Addon selected. Addons currently supported: WeakAuras 2.")
				end
				
				f:Hide()
			end
			
			local create_button = fw:CreateButton (f, create_func, 106, 16, "Create Aura")
			create_button:InstallCustomTexture()
			
			local cancel_button = fw:CreateButton (f, function() name_textentry:ClearFocus(); f:Hide() end, 106, 16, "Cancel")
			cancel_button:InstallCustomTexture()
			
			create_button:SetIcon ([[Interface\Buttons\UI-CheckBox-Check]], nil, nil, nil, {0.125, 0.875, 0.125, 0.875}, nil, 4, 2)
			cancel_button:SetIcon ([[Interface\Buttons\UI-GroupLoot-Pass-Down]], nil, nil, nil, {0.125, 0.875, 0.125, 0.875}, nil, 4, 2)
			
			local x_start = 20
			local x2_start = 320
			local y_start = 21
			
			--aura name and the type
			name_label:SetPoint ("topleft", f, "topleft", x_start, ((y_start*1) + (50)) * -1)
			aura_type_label:SetPoint ("topleft", f, "topleft", x_start, ((y_start*2) + (50)) * -1)
			
			--triggers
			aura_on_label:SetPoint ("topleft", f, "topleft", x_start, ((y_start*4) + (45)) * -1)
			stack_label:SetPoint ("topleft", f, "topleft", x_start, ((y_start*5) + (45)) * -1)
			encounterid_label:SetPoint ("topleft", f, "topleft", x_start, ((y_start*6) + (45)) * -1)
			
			--about the spell
			spellname_label:SetPoint ("topleft", f, "topleft", x_start, ((y_start*8) + (45)) * -1)
			auraid_label:SetPoint ("topleft", f, "topleft", x_start, ((y_start*9) + (45)) * -1)
			usespellid_label:SetPoint ("topleft", f, "topleft", x_start, ((y_start*10) + (45)) * -1)
			
			--configuration
			icon_label:SetPoint ("topleft", f, "topleft", x2_start, ((y_start*1) + (50)) * -1)
			sound_effect_label:SetPoint ("topleft", f, "topleft", x2_start, ((y_start*2) + (50)) * -1)
			say_something_label:SetPoint ("topleft", f, "topleft", x2_start, ((y_start*3) + (50)) * -1)
			aura_text_label:SetPoint ("topleft", f, "topleft", x2_start, ((y_start*4) + (50)) * -1)
			useglow_label:SetPoint ("topleft", f, "topleft", x2_start, ((y_start*5) + (50)) * -1)
			icon_size_label:SetPoint ("topleft", f, "topleft", x2_start, ((y_start*6) + (50)) * -1)
			
			aura_addon_label:SetPoint ("topleft", f, "topleft", x_start, ((y_start*15) + (60)) * -1)
			weakauras_folder_label:SetPoint ("topleft", f, "topleft", x_start, ((y_start*16) + (60)) * -1)

			create_button:SetPoint ("topleft", f, "topleft", x_start, ((y_start*18) + (60)) * -1)
			cancel_button:SetPoint ("topright", f, "topright", x_start*-1, ((y_start*18) + (60)) * -1)
			
			function f:UpdateLabels()
			
				local aura_type = f.AuraTypeDropdown.value
				local trigger = f.AuraOnDropdown.value
				
				f.StackSlider:Enable()
				f.StackSlider.tooltip = "Minimum amount of stacks to trigger the aura."
				f.StackSlider:SetValue (0)
				f.SpellName:Enable()
				f.UseSpellId:Enable()
				
				if (aura_type == "icon") then
					aura_text_label:SetText ("Icon Text: ")
					icon_size_label:SetText ("Width/Height: ")
					
				elseif (aura_type == "text") then
					aura_text_label:SetText ("Text: ")
					icon_size_label:SetText ("Font Size: ")
					
				elseif (aura_type == "aurabar") then
					aura_text_label:SetText ("Left Text: ")
					icon_size_label:SetText ("Bar Width: ")
					
				end

				if (trigger >= 1 and trigger <= 19) then --buff and debuff
					stack_label:SetText ("Stack Size: ")
					
				elseif (trigger >= 20 and trigger <= 29) then --cast start and end
					stack_label:SetText ("Stack Size: ")
					f.StackSlider:Disable()
				
				elseif (trigger >= 30 and trigger <= 39) then --boss mods
					stack_label:SetText ("Remaining Time:")
					f.StackSlider:SetValue (4)
					f.StackSlider.tooltip = "Will trigger when the bar remaining time reach this value."
					f.SpellName:Disable()
					f.UseSpellId:Disable()
				end
			end
		end
		
		DetailsAuraPanel.spellid = spellid
		DetailsAuraPanel.encounterid = encounterid
		DetailsAuraPanel.EncounterIdText.text = encounterid or ""
		
		DetailsAuraPanel.other_values = other_values
		
		DetailsAuraPanel.WeakaurasFolderDropdown:Refresh()
		if (encounterid) then
			DetailsAuraPanel.WeakaurasFolderDropdown:Select ("Details! Aura Group")
			DetailsAuraPanel.IconSizeSlider:SetValue (128)
		else
			DetailsAuraPanel.WeakaurasFolderDropdown:Select (1, true)
			DetailsAuraPanel.IconSizeSlider:SetValue (64)
		end
		
		if (other_values.dbm_timer_id or other_values.bw_timer_id) then
			DetailsAuraPanel.WeakaurasFolderDropdown:Select ("Details! Boss Mods Group")
		end
		
		if (DetailsAuraPanel.other_values.text_size) then
			DetailsAuraPanel.IconSizeSlider:SetValue (DetailsAuraPanel.other_values.text_size)
		end
		
		DetailsAuraPanel.name.text = spellname .. " (d!)"
		DetailsAuraPanel.spellname.text = spellname
		DetailsAuraPanel.AuraSpellId.text = tostring (spellid)
		DetailsAuraPanel.icon.texture = spellicon
		
		DetailsAuraPanel.UseGlow.glow_test.animIn:Stop()
		DetailsAuraPanel.UseGlow.glow_test.animOut:Play()
		DetailsAuraPanel.UseGlow:SetValue (false)
		
		DetailsAuraPanel.StackSlider:SetValue (0)
		DetailsAuraPanel.SoundEffectDropdown:Select (1, true)
		DetailsAuraPanel.AuraText:SetText (DetailsAuraPanel.other_values.text or "")
		DetailsAuraPanel.SaySomething:SetText ("")
		
		if (triggertype and type (triggertype) == "number") then
			DetailsAuraPanel.AuraOnDropdown:Select (triggertype, true)
		else
			DetailsAuraPanel.AuraOnDropdown:Select (1, true)
		end
		
		if (auratype and type (auratype) == "number") then
			DetailsAuraPanel.AuraTypeDropdown:Select (auratype, true)
		else
			DetailsAuraPanel.AuraTypeDropdown:Select (1, true)
		end
		
		DetailsAuraPanel:UpdateLabels()
		
		DetailsAuraPanel:Show()
	end
	
	------------------------------------------------------------------------------------------------------------------
	
	--> get the total of damage and healing of this phase
	function _detalhes:OnCombatPhaseChanged()
	
		local current_combat = _detalhes:GetCurrentCombat()
		local current_phase = current_combat.PhaseData [#current_combat.PhaseData][1]
		
		local phase_damage_container = current_combat.PhaseData.damage [current_phase]
		local phase_healing_container = current_combat.PhaseData.heal [current_phase]
		
		local phase_damage_section = current_combat.PhaseData.damage_section
		local phase_healing_section = current_combat.PhaseData.heal_section
		
		if (not phase_damage_container) then
			phase_damage_container = {}
			current_combat.PhaseData.damage [current_phase] = phase_damage_container
		end
		if (not phase_healing_container) then
			phase_healing_container = {}
			current_combat.PhaseData.heal [current_phase] = phase_healing_container
		end
		
		for index, damage_actor in ipairs (_detalhes.cache_damage_group) do
			local phase_damage = damage_actor.total - (phase_damage_section [damage_actor.nome] or 0)
			phase_damage_section [damage_actor.nome] = damage_actor.total
			phase_damage_container [damage_actor.nome] = (phase_damage_container [damage_actor.nome] or 0) + phase_damage
		end
		
		for index, healing_actor in ipairs (_detalhes.cache_healing_group) do
			local phase_heal = healing_actor.total - (phase_healing_section [healing_actor.nome] or 0)
			phase_healing_section [healing_actor.nome] = healing_actor.total
			phase_healing_container [healing_actor.nome] = (phase_healing_container [healing_actor.nome] or 0) + phase_heal
		end
		
	end
	
	function _detalhes:BossModsLink()
		if (_G.DBM) then
			local dbm_callback_phase = function (event, msg, ...)
			
				local mod = _detalhes.encounter_table.DBM_Mod
				
				if (not mod) then
					local id = _detalhes:GetEncounterIdFromBossIndex (_detalhes.encounter_table.mapid, _detalhes.encounter_table.id)
					if (id) then
						for index, tmod in ipairs (DBM.Mods) do 
							if (tmod.id == id) then
								_detalhes.encounter_table.DBM_Mod = tmod
								mod = tmod
							end
						end
					end
				end
				
				local phase = mod and mod.vb and mod.vb.phase
				if (phase and _detalhes.encounter_table.phase ~= phase) then
					--_detalhes:Msg ("Current phase:", phase)
					
					_detalhes:OnCombatPhaseChanged()
					
					_detalhes.encounter_table.phase = phase
					
					local cur_combat = _detalhes:GetCurrentCombat()
					local time = cur_combat:GetCombatTime()
					if (time > 5) then
						tinsert (cur_combat.PhaseData, {phase, time})
					end
					
					_detalhes:SendEvent ("COMBAT_ENCOUNTER_PHASE_CHANGED", nil, phase)
				end
			end
			
			local dbm_callback_pull = function (event, mod, delay, synced, startHp)
				_detalhes.encounter_table.DBM_Mod = mod
				_detalhes.encounter_table.DBM_ModTime = time()
			end
			
			DBM:RegisterCallback ("DBM_Announce", dbm_callback_phase)
			DBM:RegisterCallback ("pull", dbm_callback_pull)
			
			--DBM:RegisterCallback ("DBM_TimerStart", function (a, b, c, d, e, f, g)
			--	print ("details", a, b, c, d, e, f, g)
			--end)
		end
		
		
		
		LoadAddOn ("BigWigs_Core")
		
		if (BigWigs and not _G.DBM) then
			BigWigs:Enable()
		
			function _detalhes:BigWigs_Message (event, module, key, text, ...)
				
				--print (event, module, key, text, ...)
				
				if (key == "stages") then
					local phase = text:gsub (".*%s", "")
					phase = tonumber (phase)
					--print ("Phase Changed!", phase)
					
					if (phase and type (phase) == "number" and _detalhes.encounter_table.phase ~= phase) then
						--_detalhes:Msg ("Current phase:", phase)
						
						_detalhes:OnCombatPhaseChanged()
						
						_detalhes.encounter_table.phase = phase
						
						local cur_combat = _detalhes:GetCurrentCombat()
						local time = cur_combat:GetCombatTime()
						if (time > 5) then
							tinsert (cur_combat.PhaseData, {phase, time})
						end
						
						_detalhes:SendEvent ("COMBAT_ENCOUNTER_PHASE_CHANGED", nil, phase)
					end
					
				end
			end
			
			BigWigs.RegisterMessage (_detalhes, "BigWigs_Message")
			
			--function _detalhes:BigWigs_StartBar (...)
			--	print (...)
			--end
			--BigWigs.RegisterMessage (_detalhes, "BigWigs_StartBar")
		end
	end	
	
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> details auras

	local aura_prototype = {
		name = "",
		type = "DEBUFF",
		target = "player",
		boss = "0",
		icon = "",
		stack = 0,
		sound = "",
		sound_channel = "",
		chat = "",
		chat_where = "SAY",
		chat_extra = "",
	}
	
	function _detalhes:CreateDetailsAura (name, auratype, target, boss, icon, stack, sound, chat)
	
		local aura_container = _detalhes.details_auras
		
		--already exists
		if (aura_container [name]) then
			_detalhes:Msg ("Aura name already exists.")
			return
		end
		
		--create the new aura
		local new_aura = _detalhes.table.copy ({}, aura_prototype)
		new_aura.type = auratype or new_aura.type
		new_aura.target = auratype or new_aura.target
		new_aura.boss = boss or new_aura.boss
		new_aura.icon = icon or new_aura.icon
		new_aura.stack = math.max (stack or 0, new_aura.stack)
		new_aura.sound = sound or new_aura.sound
		new_aura.chat = chat or new_aura.chat
		
		_detalhes.details_auras [name] = new_aura
		
		return new_aura
	end
	
	function _detalhes:CreateAuraListener()
	
		local listener = _detalhes:CreateEventListener()
		
		function listener:on_enter_combat (event, combat, encounterId)
			
		end
		
		function listener:on_leave_combat (event, combat)
			
		end
		
		listener:RegisterEvent ("COMBAT_PLAYER_ENTER", "on_enter_combat")
		listener:RegisterEvent ("COMBAT_PLAYER_LEAVE", "on_leave_combat")
	
	end
	
	
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> forge

	function _detalhes:OpenForge()
	
		if (not DetailsForge) then
		
			local fw = _detalhes:GetFramework()
			local lower = string.lower
			
			--main frame
			local f = CreateFrame ("frame", "DetailsForge", UIParent, "ButtonFrameTemplate")
			f:SetSize (900, 600)
			f.TitleText:SetText ("Details! Forge")
			--f.portrait:SetTexture ([[Interface\CHARACTERFRAME\TEMPORARYPORTRAIT-FEMALE-BLOODELF]])
			f.portrait:SetTexture ([[Interface\ICONS\INV_Misc_ReforgedArchstone_01]])
			f:SetPoint ("center", UIParent, "center")
			f:SetFrameStrata ("HIGH")
			f:SetToplevel (true)
			f:SetMovable (true)
			tinsert (UISpecialFrames, "DetailsAuraPanel")
			f:SetScript ("OnMouseDown", function(self, button)
				if (self.isMoving) then
					return
				end
				if (button == "RightButton") then
					self:Hide()
				else
					self:StartMoving() 
					self.isMoving = true
				end
			end)
			f:SetScript ("OnMouseUp", function(self, button) 
				if (self.isMoving and button == "LeftButton") then
					self:StopMovingOrSizing()
					self.isMoving = nil
				end
			end)
		
			--modules
			local all_modules = {}
			local spell_already_added = {}
			
			f:SetScript ("OnHide", function()
				for _, module in ipairs (all_modules) do
					if (module.data) then
						wipe (module.data)
					end
				end
				wipe (spell_already_added)
			end)
			
			local no_func = function()end
			local nothing_to_show = {}
			local current_module
			local buttons = {}
			
			function f:InstallModule (module)
				if (module and type (module) == "table") then
					tinsert (all_modules, module)
				end
			end
			
			local all_players_module = {
				name = "All Players",
				desc = "Show a list of all player actors",
				filters_widgets = function()
					if (not DetailsForgeAllPlayersFilterPanel) then
						local w = CreateFrame ("frame", "DetailsForgeAllPlayersFilterPanel", f)
						w:SetSize (600, 20)
						w:SetPoint ("topleft", f, "topleft", 120, -40)
						local label = w:CreateFontString (nil, "overlay", "GameFontHighlightSmall")
						label:SetText ("Player Name: ")
						label:SetPoint ("left", w, "left", 5, 0)
						local entry = fw:CreateTextEntry (w, nil, 120, 20, "entry", "DetailsForgeAllPlayersNameFilter")
						entry:SetHook ("OnTextChanged", function() f:refresh() end)
						entry:SetPoint ("left", label, "right", 2, 0)
					end
					return DetailsForgeAllPlayersFilterPanel
				end,
				search = function()
					local t = {}
					local filter = DetailsForgeAllPlayersNameFilter:GetText()
					for _, actor in ipairs (_detalhes:GetCombat("current"):GetActorList (DETAILS_ATTRIBUTE_DAMAGE)) do
						if (actor:IsGroupPlayer()) then
							if (filter ~= "") then
								filter = lower (filter)
								local actor_name = lower (actor:name())
								if (actor_name:find (filter)) then
									t [#t+1] = actor
								end
							else
								t [#t+1] = actor
							end
						end
					end
					return t
				end,
				header = {
					{name = "Index", width = 40, type = "text", func = no_func},
					{name = "Name", width = 150, type = "entry", func = no_func},
					{name = "Class", width = 100, type = "entry", func = no_func},
					{name = "GUID", width = 230, type = "entry", func = no_func},
					{name = "Flag", width = 100, type = "entry", func = no_func},
				},
				fill_panel = false,
				fill_gettotal = function (self) return #self.module.data end,
				fill_fillrows = function (index, self) 
					local data = self.module.data [index]
					if (data) then
						return {
							index,
							data:name() or "",
							data:class() or "",
							data.serial or "",
							"0x" .. _detalhes:hex (data.flag_original)
						}
					else
						return nothing_to_show
					end
				end,
				fill_name = "DetailsForgeAllPlayersFillPanel",
			}
			f:InstallModule (all_players_module)
			
			-----------------------------------------------
			local all_pets_module = {
				name = "All Pets",
				desc = "Show a list of all pet actors",
				filters_widgets = function()
					if (not DetailsForgeAllPetsFilterPanel) then
						local w = CreateFrame ("frame", "DetailsForgeAllPetsFilterPanel", f)
						w:SetSize (600, 20)
						w:SetPoint ("topleft", f, "topleft", 120, -40)
						--
						local label = w:CreateFontString (nil, "overlay", "GameFontHighlightSmall")
						label:SetText ("Pet Name: ")
						label:SetPoint ("left", w, "left", 5, 0)
						local entry = fw:CreateTextEntry (w, nil, 120, 20, "entry", "DetailsForgeAllPetsNameFilter")
						entry:SetHook ("OnTextChanged", function() f:refresh() end)
						entry:SetPoint ("left", label, "right", 2, 0)
						--
						local label = w:CreateFontString (nil, "overlay", "GameFontHighlightSmall")
						label:SetText ("Owner Name: ")
						label:SetPoint ("left", entry.widget, "right", 20, 0)
						local entry = fw:CreateTextEntry (w, nil, 120, 20, "entry", "DetailsForgeAllPetsOwnerFilter")
						entry:SetHook ("OnTextChanged", function() f:refresh() end)
						entry:SetPoint ("left", label, "right", 2, 0)
					end
					return DetailsForgeAllPetsFilterPanel
				end,
				search = function()
					local t = {}
					local filter_petname = DetailsForgeAllPetsNameFilter:GetText()
					local filter_ownername = DetailsForgeAllPetsOwnerFilter:GetText()
					for _, actor in ipairs (_detalhes:GetCombat("current"):GetActorList (DETAILS_ATTRIBUTE_DAMAGE)) do
						if (actor.owner) then
							local can_add = true
							if (filter_petname ~= "") then
								filter_petname = lower (filter_petname)
								local actor_name = lower (actor:name())
								if (not actor_name:find (filter_petname)) then
									can_add = false
								end
							end
							if (filter_ownername ~= "") then
								filter_ownername = lower (filter_ownername)
								local actor_name = lower (actor.ownerName)
								if (not actor_name:find (filter_ownername)) then
									can_add = false
								end
							end
							if (can_add) then
								t [#t+1] = actor
							end
						end
					end
					return t
				end,
				header = {
					{name = "Index", width = 40, type = "text", func = no_func},
					{name = "Name", width = 150, type = "entry", func = no_func},
					{name = "Owner", width = 150, type = "entry", func = no_func},
					{name = "NpcID", width = 60, type = "entry", func = no_func},
					{name = "GUID", width = 100, type = "entry", func = no_func},
					{name = "Flag", width = 100, type = "entry", func = no_func},
				},
				fill_panel = false,
				fill_gettotal = function (self) return #self.module.data end,
				fill_fillrows = function (index, self) 
					local data = self.module.data [index]
					if (data) then
						return {
							index,
							data:name():gsub ("(<).*(>)", "") or "",
							data.ownerName or "",
							_detalhes:GetNpcIdFromGuid (data.serial),
							data.serial or "",
							"0x" .. _detalhes:hex (data.flag_original)
						}
					else
						return nothing_to_show
					end
				end,
				fill_name = "DetailsForgeAllPetsFillPanel",
			}
			f:InstallModule (all_pets_module)			
			
			-----------------------------------------------
			
			local all_enemies_module = {
				name = "All Enemies",
				desc = "Show a list of all enemies actors",
				filters_widgets = function()
					if (not DetailsForgeAllEnemiesFilterPanel) then
						local w = CreateFrame ("frame", "DetailsForgeAllEnemiesFilterPanel", f)
						w:SetSize (600, 20)
						w:SetPoint ("topleft", f, "topleft", 120, -40)
						--
						local label = w:CreateFontString (nil, "overlay", "GameFontHighlightSmall")
						label:SetText ("Enemy Name: ")
						label:SetPoint ("left", w, "left", 5, 0)
						local entry = fw:CreateTextEntry (w, nil, 120, 20, "entry", "DetailsForgeAllEnemiesNameFilter")
						entry:SetHook ("OnTextChanged", function() f:refresh() end)
						entry:SetPoint ("left", label, "right", 2, 0)
					end
					return DetailsForgeAllEnemiesFilterPanel
				end,
				search = function()
					local t = {}
					local filter = DetailsForgeAllEnemiesNameFilter:GetText()
					for _, actor in ipairs (_detalhes:GetCombat("current"):GetActorList (DETAILS_ATTRIBUTE_DAMAGE)) do
						if (actor:IsNeutralOrEnemy()) then
							if (filter ~= "") then
								filter = lower (filter)
								local actor_name = lower (actor:name())
								if (actor_name:find (filter)) then
									t [#t+1] = actor
								end
							else
								t [#t+1] = actor
							end
						end
					end
					return t
				end,
				header = {
					{name = "Index", width = 40, type = "text", func = no_func},
					{name = "Name", width = 150, type = "entry", func = no_func},
					{name = "NpcID", width = 60, type = "entry", func = no_func},
					{name = "GUID", width = 230, type = "entry", func = no_func},
					{name = "Flag", width = 100, type = "entry", func = no_func},
				},
				fill_panel = false,
				fill_gettotal = function (self) return #self.module.data end,
				fill_fillrows = function (index, self) 
					local data = self.module.data [index]
					if (data) then
						return {
							index,
							data:name(),
							_detalhes:GetNpcIdFromGuid (data.serial),
							data.serial or "",
							"0x" .. _detalhes:hex (data.flag_original)
						}
					else
						return nothing_to_show
					end
				end,
				fill_name = "DetailsForgeAllEnemiesFillPanel",
			}
			f:InstallModule (all_enemies_module)
			
			-----------------------------------------------
			
			local EncounterSpellEvents = EncounterDetailsDB and EncounterDetailsDB.encounter_spells
			
			local all_spells_module = {
				name = "All Spells",
				desc = "Show a list of all spells used",
				filters_widgets = function()
					if (not DetailsForgeAllSpellsFilterPanel) then
						local w = CreateFrame ("frame", "DetailsForgeAllSpellsFilterPanel", f)
						w:SetSize (600, 20)
						w:SetPoint ("topleft", f, "topleft", 120, -40)
						--
						local label = w:CreateFontString (nil, "overlay", "GameFontHighlightSmall")
						label:SetText ("Spell Name: ")
						label:SetPoint ("left", w, "left", 5, 0)
						local entry = fw:CreateTextEntry (w, nil, 120, 20, "entry", "DetailsForgeAllSpellsNameFilter")
						entry:SetHook ("OnTextChanged", function() f:refresh() end)
						entry:SetPoint ("left", label, "right", 2, 0)
						--
						local label = w:CreateFontString (nil, "overlay", "GameFontHighlightSmall")
						label:SetText ("Caster Name: ")
						label:SetPoint ("left", entry.widget, "right", 20, 0)
						local entry = fw:CreateTextEntry (w, nil, 120, 20, "entry", "DetailsForgeAllSpellsCasterFilter")
						entry:SetHook ("OnTextChanged", function() f:refresh() end)
						entry:SetPoint ("left", label, "right", 2, 0)
					end
					return DetailsForgeAllSpellsFilterPanel
				end,
				search = function()
					local t = {}
					local filter_name = DetailsForgeAllSpellsNameFilter:GetText()
					local filter_caster = DetailsForgeAllSpellsCasterFilter:GetText()
					local combat = _detalhes:GetCombat("current")
					local containers = {combat:GetActorList (DETAILS_ATTRIBUTE_DAMAGE), combat:GetActorList (DETAILS_ATTRIBUTE_HEAL), 
					combat:GetActorList (DETAILS_ATTRIBUTE_ENERGY)}
					wipe (spell_already_added)
	
					for _, container in ipairs (containers) do
						for _, actor in ipairs (container) do
							local can_add = true
							if (filter_caster ~= "") then
								filter_caster = lower (filter_caster)
								local actor_name = lower (actor:name())
								if (not actor_name:find (filter_caster)) then
									can_add = false
								end
							end
							if (can_add) then
								for spellid, spell in pairs (actor:GetSpellList()) do
									can_add = true
									if (filter_name ~= "") then
										filter_name = lower (filter_name)
										local spellname = lower (select (1, GetSpellInfo (spellid)) or "-")
										if (not spellname:find (filter_name)) then
											can_add = false
										end
									end
									if (can_add and not spell_already_added [spellid]) then
										spell_already_added [spellid] = true
										tinsert (t, {spell, actor})
									end
								end
							end
						end
					end
					return t
				end,
				header = {
					{name = "Index", width = 40, type = "text", func = no_func},
					{name = "Name", width = 150, type = "entry", func = no_func},
					{name = "SpellID", width = 60, type = "entry", func = no_func},
					{name = "School", width = 60, type = "entry", func = no_func},
					{name = "Caster", width = 100, type = "entry", func = no_func},
					{name = "Event", width = 300, type = "entry", func = no_func},
				},
				fill_panel = false,
				fill_gettotal = function (self) return #self.module.data end,
				fill_fillrows = function (index, self) 
					local data = self.module.data [index]
					if (data) then
						local events = ""
						if (EncounterSpellEvents and EncounterSpellEvents [data[1].id]) then
							for token, _ in pairs (EncounterSpellEvents [data[1].id].token) do
								token = token:gsub ("SPELL_", "")
								events = events .. token .. ",  "
							end
							events = events:sub (1, #events - 3)
						end
						return {
							index,
							select (1, GetSpellInfo (data[1].id)) or "",
							data[1].id or "",
							_detalhes:GetSpellSchoolFormatedName (data[1].spellschool) or "",
							data[2]:name(),
							events
						}
					else
						return nothing_to_show
					end
				end,
				fill_name = "DetailsForgeAllSpellsFillPanel",
			}
			f:InstallModule (all_spells_module)
			
			-----------------------------------------------
			
			local select_module = function (module_number)
			
				if (current_module ~= module_number) then
					local module = all_modules [current_module]
					if (module) then
						local filters = module.filters_widgets()
						filters:Hide()
						local fill_panel = module.fill_panel
						fill_panel:Hide()
					end
				end
				
				for index, button in ipairs (buttons) do
					button.textcolor = "white"
				end
				buttons[module_number].textcolor = "orange"
				
				local module = all_modules [module_number]
				if (module) then
					current_module = module_number
					
					local fillpanel = module.fill_panel
					if (not fillpanel) then
						fillpanel = fw:NewFillPanel (f, module.header, module.fill_name, nil, 740, 480, module.fill_gettotal, module.fill_fillrows, false)
						fillpanel:SetPoint (120, -80)
						fillpanel.module = module
						module.fill_panel = fillpanel
					end
					
					local filters = module.filters_widgets()
					filters:Show()
					
					local data = module.search()
					module.data = data
					
					fillpanel:Show()
					fillpanel:Refresh()
				end
			end
			
			function f:refresh()
				select_module (current_module)
			end

			for i = 1, #all_modules do
				local module = all_modules [i]
				local b = fw:CreateButton (f, select_module, 120, 12, module.name, i)
				b.tooltip = module.desc
				b.textalign = "<"
				b:SetPoint ("topleft", f, "topleft", 10, (i*16*-1) - 67)
				tinsert (buttons, b)
			end

			select_module (1)

		end
		
		DetailsForge:Show()
		
	end

	--_detalhes:ScheduleTimer ("OpenForge", 3)
	