--todo: need to send a callback when setting a new language, this will be used by the volatile menu to refresh the menu
--todo: compress the language tables that aren't in use
--todo: check cooltip fonts

--[=[
    namespace = DetailsFramework.Language
    Register() = DetailsFramework.Language.Register()

    Register(addonId, languageId[, gameLanguageOnly])
        create a language table within an addon namespace
        @addonId: an identifier, can be any table or string, will be used when getting the table with phrase translations, example: "DetailsLocalization", "Details", "PlaterLoc", _G.Plater
        @languageId: game languages: "deDE", "enUS", "esES", "esMX", "frFR", "itIT", "koKR", "ptBR", "ruRU", "zhCN", "zhTW", or any other value if 'gameLanguageOnly' is false (default)
        @gameLanguageOnly: if true won't allow to register a language not supported by the game, a supported language is any language returnted by GetLocale()
        return value: return a table named languageTable, this table holds translations for the registered language

        The returned table can be used to add localized phrases:
        --example 1:
        local newLanguageTable = DetailsFramework.Language.Register("Details", "enUS", true)
        newLanguageTable["My Phrase"] = "My Phrase"

        --example 2:
        local newLanguageTable = DetailsFramework.Language.Register(_G.Details, "valyrianValyria", false)
        newLanguageTable["STRING_MY_PHRASE"] = "ñuha udrir"

    GetLanguageTable(addonId[, languageId])
        get the languageTable for the requested languageId within the addon namespace
        if languageId is not passed, uses the current language set for the addonId
        the default languageId for the addon is the first language registered with DetailsFramework.Language.Register()
        the languageId will be overrided when the language used by the client is registered with DetailsFramework.Language.Register()
        the default languageId can also be changed by calling DetailsFramework.Language.SetCurrentLanguage() as seen below
        @addonId: an identifier, can be any table or string, will be used when getting the table with phrase translations, example: "DetailsLocalization", "Details", "PlaterLoc", _G.Plater
        @languageId: game languages: "deDE", "enUS", "esES", "esMX", "frFR", "itIT", "koKR", "ptBR", "ruRU", "zhCN", "zhTW", or any other value if 'gameLanguageOnly' is false (default)
        return value: languageTable

        --example 1:
        local languageTable = DetailsFramework.Language.GetLanguageTable("Details")
        fontString:SetText(languageTable["My Phrase"])
        --example 2:
        local languageTable = DetailsFramework.Language.GetLanguageTable("Details", "valyrianValyria")
        fontString:SetText(languageTable["STRING_MY_PHRASE"])

    GetText(addonId, phraseId[, silent])
        get a text from a registered addonId and phraseId, return a localized string and the languageId where the string was found, otherwise return the phraseId
        @addonId: an identifier, can be any table or string, will be used when getting the table with phrase translations, example: "DetailsLocalization", "Details", "PlaterLoc", _G.Plater
        @phraseId: any string to identify the a translated text, example: phraseId: "OPTIONS_FRAME_WIDTH" text: "Adjust the Width of the frame."
        @silent: if true won't error on invalid phrase text and instead use the phraseId as the text, it will still error on invalid addonId

    ShowOptionsHelp()
        print to chat the available options ids, use SetOption to set them

    SetOption(addonId, optionId, value)
        set an option

    SetCurrentLanguage(addonId, languageId)
        set the language used by default when retriving a languageTable with DF.Language.GetLanguageTable() and not passing the second argument (languageId) within the call
        use this in combination with a savedVariable to use a language of the user choice
        @addonId: an identifier, can be any table or string, will be used when getting the table with phrase translations, example: "DetailsLocalization", "Details", "PlaterLoc", _G.Plater
        @languageId: game languages: "deDE", "enUS", "esES", "esMX", "frFR", "itIT", "koKR", "ptBR", "ruRU", "zhCN", "zhTW", or any other value if 'gameLanguageOnly' is false (default)

    CreateLanguageSelector(addonId, parent, callback, selectedLanguage)
        create and return a dropdown (using details framework dropdown widget) to select the laguage
        @addonId: an identifier, can be any table or string, will be used when getting the table with phrase translations, example: "DetailsLocalization", "Details", "PlaterLoc", _G.Plater
        @parent: a frame to use as parent while creating the language selector dropdown
        @callback: a function which will be called when the user select a new language function(languageId) print("new language:", languageId) end
        @selectedLanguage: default selected language

    SetFontForLanguageId(addonId, languageId, fontPath)
    SetFontByAlphabetOrRegion(addonId, latin_FontPath, cyrillic_FontPath, china_FontPath, korean_FontPath, taiwan_FontPath)
        set the font to be used for different languages, if no font is registered for a language, the lib will guess if the font need to be changed and change to a compatible with the language
        if a font name is passed the lib will attempt to retrive from LibSharedMedia
        latin changes the font for "deDE", "enUS", "esES", "esMX", "frFR", "itIT" and "ptBR"
        cyrillic for "ruRU", china for "zhCN", korean for "koKR" and taiwan for "zhTW"
        @addonId: an identifier, can be any table or string, will be used when getting the table with phrase translations, example: "DetailsLocalization", "Details", "PlaterLoc", _G.Plater
        @languageId: game languages: "deDE", "enUS", "esES", "esMX", "frFR", "itIT", "koKR", "ptBR", "ruRU", "zhCN", "zhTW", or any other string value to represent a language already registered

    RegisterObject(addonId, object, phraseId[, silent[, ...]])
        to be registered, the Object need to have a SetText method
        when setting a languageId with DetailsFramework.Language.SetCurrentLanguage(), automatically change the text of all registered Objects
        @addonId: an identifier, can be any table or string, will be used when getting the table with phrase translations, example: "DetailsLocalization", "Details", "PlaterLoc", _G.Plater
        @object: any UIObject or table with SetText method
        @phraseId: any string to identify the a translated text, example: "My Phrase", "STRING_TEXT_LENGTH", text: "This is my phrase"
        @silent: if true won't error on invalid phrase text and instead use the phraseId as the text, it will still error on invalid addonId and Object
        @vararg: arguments to pass for format(text, ...)

    UpdateObjectArguments(addonId, object, ...)
        update the arguments (...) of a registered Object, if no argument passed it'll erase the arguments previously set
        the Object need to be already registered with DetailsFramework.Language.RegisterObject()
        the font string text will be changed to update the text with the new arguments
        @addonId: an identifier, can be any table or string, will be used when getting the table with phrase translations, example: "DetailsLocalization", "Details", "PlaterLoc", _G.Plater
        @object: any UIObject or table with SetText method
        @vararg: arguments to pass for format(text, ...)

    RegisterTableKey(addonId, table, key, phraseId[, silent[, ...]])
        when setting a languageId with DetailsFramework.Language.SetCurrentLanguage(), automatically change the text of all registered tables, table[key] = 'new translated text'
        @addonId: an identifier, can be any table or string, will be used when getting the table with phrase translations, example: "DetailsLocalization", "Details", "PlaterLoc", _G.Plater
        @table: a lua table
        @key: any value except nil or boolean
        @phraseId: any string to identify the a translated text, example: token: "OPTIONS_FRAME_WIDTH" text: "Adjust the Width of the frame."
        @silent: if true won't error on invalid phrase text or table already registered, it will still error on invalid addonId, table, key and phraseId
        @vararg: arguments to pass for format(text, ...)

    UpdateTableKeyArguments(addonId, table, key, ...)
        same as UpdateObjectArguments() but for table keys
        @addonId: an identifier, can be any table or string, will be used when getting the table with phrase translations, example: "DetailsLocalization", "Details", "PlaterLoc", _G.Plater
        @table: a lua table
        @key: any value except nil or boolean
        @vararg: arguments to pass for format(text, ...)

    RegisterObjectWithDefault(addonId, object, phraseId, defaultText[, ...])
        (helper function) register an object if a phraseID is valid or object:SetText(defaultText) is called

    RegisterTableKeyWithDefault(addonId, table, key, phraseId, defaultText[, ...])
        (helper function) register a tableKey if a phraseID is valid or table[key] = defaultText

    CreateLocTable(addonId, phraseId[, shouldRegister = true[, ...]])
        make a table to pass instead of the text while using DetailsFramework widgets
        this avoid to call the register object function right after creating the widget
        also make easy to register the same phraseID in many different widgets

    SetTextWithLocTable(object, locTable)
        set the text of an object using a locTable, the object need the method SetText

    SetTextWithLocTableWithDefault(object, locTable, defaultText)
        set the text from the locTable if passed or use the defaultText

    SetTextIfLocTableOrDefault(object, locTable)
        set the text if locTable is a locTable or SetText(locTable)

    RegisterTableKeyWithLocTable(table, key, locTable[, silence])
        same as RegisterTableKey() but get addonId, phraseId and arguments from the locTable

    RegisterObjectWithLocTable(object, locTable[, silence])
        same as RegisterObject() but get addonId, phraseId and arguments from the locTable

--]=]


---@class addonNamespaceTable : table store language settings for an addon
---@class fontPath : string font path for a font file on the hardware of the user

local DF = _G["DetailsFramework"]
if (not DF or not DetailsFrameworkCanLoad) then
	return
end

local format = string.format
local unpack = table.unpack or unpack
local GetLocale = _G.GetLocale

local CONST_LANGUAGEID_ENUS = "enUS"
local gameLanguage = GetLocale()

local addonNamespaceOptions = {
    ChangeOnlyRegisteredFont = false,
}
local optionsHelp = {
    ChangeOnlyRegisteredFont = "when changing the language, won't change the font if the font isn't registered for the language or region",
}

local debugElabled = false
local printDebug = function(functionName, ...)
    if (debugElabled) then
        print("|cFFFFAA00Languages|r:", "|cFFFFFF00" .. functionName .. "|r", ...)
    end
end

local supportedGameLanguages = {
    ["deDE"] = true,
    [CONST_LANGUAGEID_ENUS] = true,
    ["esES"] = true,
    ["esMX"] = true,
    ["frFR"] = true,
    ["itIT"] = true,
    ["ptBR"] = true,
    ["koKR"] = true,
    ["ruRU"] = true,
    ["zhCN"] = true,
    ["zhTW"] = true,
}

local fontLanguageCompatibility = {
    ["deDE"] = 1,
    [CONST_LANGUAGEID_ENUS] = 1,
    ["esES"] = 1,
    ["esMX"] = 1,
    ["frFR"] = 1,
    ["itIT"] = 1,
    ["ptBR"] = 1,
    ["zhCN"] = 2,
    ["zhTW"] = 3,
    ["koKR"] = 4,
    ["ruRU"] = 5,
}

--this table contains all the registered languages with their name and fonts
--by default it has all languages the game supports
--it is used when the dropdown shows the languages available for an addon, it take from here the name and font
--new non-native game languages registered with DetailsFramework.Language.RegisterLanguage() will be added to this table
local languagesAvailable = {
    deDE = {text = "Deutsch", font = "Fonts\\FRIZQT__.TTF"},
    enUS = {text = "English (US)", font = "Fonts\\FRIZQT__.TTF"},
    esES = {text = "Español (ES)", font = "Fonts\\FRIZQT__.TTF"},
    esMX = {text = "Español (MX)", font = "Fonts\\FRIZQT__.TTF"},
    frFR = {text = "Français", font = "Fonts\\FRIZQT__.TTF"},
    itIT = {text = "Italiano", font = "Fonts\\FRIZQT__.TTF"},
    koKR = {text = "한국어", font = [[Fonts\2002.TTF]]},
    ptBR = {text = "Português (BR)", font = "Fonts\\FRIZQT__.TTF"},
    ruRU = {text = "Русский", font = "Fonts\\FRIZQT___CYR.TTF"},
    zhCN = {text = "简体中文", font = [[Fonts\ARHei.ttf]]},
    zhTW = {text = "繁體中文", font = [[Fonts\ARHei.ttf]]},
}

local ignoredCharacters = {}
local punctuations = ".,;:!?-–—()[]{}'\"`/\\@_+*^%$#&~=<>|"
for character in punctuations:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
    ignoredCharacters[character] = true
end

local accentedLetters = "áàâäãåæçéèêëíìîïñóòôöõøœúùûüýÿ"
for character in accentedLetters:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
    ignoredCharacters[character] = true
end

--store a list of letters, characters and symbols used on each language
---@type table<string, string>
DF.LanguageKnowledge = DF.LanguageKnowledge or {}

local latinAlphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
for character in latinAlphabet:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
    DF.LanguageKnowledge[character] = CONST_LANGUAGEID_ENUS
end

--version 1:
---register the letters and symbols used on phrases
---@param languageId any
---@param languageTable any
local registerCharacters = function(languageId, languageTable)
    for stringId, textString in pairs(languageTable) do
        for character in textString:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
            if (not ignoredCharacters[character]) then
                if (not DF.LanguageKnowledge[character]) then
                    if (fontLanguageCompatibility[languageId] ~= 1) then
                        DF.LanguageKnowledge[character] = languageId
                    end
                end
            end
        end
    end
end

---receives a character and attempt to get its byte code
---@param character string
---@return string, number
local getByteCodeForCharacter = function(character)
    local byteCode = ""
    local amountOfBytes = 0
    for symbolPiece in character:gmatch(".") do --separate each byte, can one, two or three bytes
        byteCode = byteCode .. string.byte(symbolPiece)
        amountOfBytes = amountOfBytes + 1
    end
    return byteCode, amountOfBytes
end

---receives a character and attempt to get its byte code
---@param character string
---@return string
local getQuickByteCodeForCharacter = function(character)
    local byte1, byte2, byte3, byte4 = string.byte(character, 1, #character)
    return (byte1 or "") .. "" .. (byte2 or "") .. "" .. (byte3 or "") .. "" .. (byte4 or "")
end

--version 2:
---register the letters and symbols used on phrases
---@param languageId any
---@param languageTable any
local registerCharacters = function(languageId, languageTable)
    if (fontLanguageCompatibility[languageId] ~= 1) then
        for stringId, textString in pairs(languageTable) do
            for character in textString:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
                local byteCode, amountOfBytes = getByteCodeForCharacter(character)

                --latin letters and escape sequences always use one byte per character
                if (amountOfBytes >= 2) then --at least 2 bytes
                    if (not DF.LanguageKnowledge[byteCode]) then
                        DF.LanguageKnowledge[byteCode] = languageId
                    end
                end
            end
        end
    end
end

local functionSignature = {
    ["RegisterLanguage"] = "RegisterLanguage(addonID, languageID[, gameLanguageOnly])",
    ["SetCurrentLanguage"] = "SetCurrentLanguage(addonID, languageID)",
    ["GetLanguageTable"] = "GetLanguageTable(addonID[, languageID])",
    ["SetFontByAlphabetOrRegion"] = "SetFontByAlphabetOrRegion(addonId, latin, cyrillic, china, korean, taiwan)",
    ["SetFontForLanguageId"] = "SetFontForLanguageId(addonId, languageId, fontPath)",
    ["GetText"] = "GetText(addonID, phraseID[, silent])",

    ["RegisterObject"] = "RegisterObject(addonID, object, phraseID[, silent[, ...]])",
    ["UpdateObjectArguments"] = "UpdateObjectArguments(addonID, object, ...)",
    ["RegisterTableKey"] = "RegisterTableKey(addonId, table, key, phraseId[[, silent[, ...]])",
    ["UpdateTableKeyArguments"] = "UpdateTableKeyArguments(addonId, table, key, ...)",

    ["RegisterObjectWithDefault"] = "RegisterObjectWithDefault(addonId, object, phraseId, defaultText[, ...])",
    ["RegisterTableKeyWithDefault"] = "RegisterTableKeyWithDefault(addonId, table, key, phraseId, defaultText[, ...])",

    ["SetOption"] = "SetOption(addonId, optionId, value)",

    ["CreateLocTable"] = "CreateLocTable(addonId, phraseId, shouldRegister[, silent[, ...]])",
    ["UnpackLocTable"] = "UnpackLocTable(locTable)",
    ["IsLocTable"] = "IsLocTable(locTable)",
    ["CanRegisterLocTable"] = "CanRegisterLocTable(locTable)",
    ["RegisterObjectWithLocTable"] = "RegisterObjectWithLocTable(object, locTable[, silence])",
    ["RegisterTableKeyWithLocTable"] = "RegisterTableKeyWithLocTable(table, key, locTable[, silence])",
    ["SetTextWithLocTable"] = "SetTextWithLocTable(object, locTable)",
    ["SetTextWithLocTableWithDefault"] = "SetTextWithLocTableWithDefault(object, locTable, defaultText)",
    ["SetTextIfLocTableOrDefault"] = "SetTextIfLocTableOrDefault(object, locTable or string)",
    ["CreateLanguageSelector"] = "DetailsFramework.Language.CreateLanguageSelector",
}

local functionCallPath = {
    ["RegisterLanguage"] = "DetailsFramework.Language.RegisterLanguage",
    ["SetCurrentLanguage"] = "DetailsFramework.Language.SetCurrentLanguage",
    ["GetLanguageTable"] = "DetailsFramework.Language.GetLanguageTable",
    ["SetFontByAlphabetOrRegion"] = "DetailsFramework.Language.SetFontByAlphabetOrRegion",
    ["SetFontForLanguageId"] = "DetailsFramework.Language.SetFontForLanguageId",
    ["GetText"] = "DetailsFramework.Language.GetText",

    ["RegisterObject"] = "DetailsFramework.Language.RegisterObject",
    ["UpdateObjectArguments"] = "DetailsFramework.Language.UpdateObjectArguments",
    ["RegisterTableKey"] = "DetailsFramework.Language.RegisterTableKey",
    ["UpdateTableKeyArguments"] = "DetailsFramework.Language.UpdateTableKeyArguments",

    ["RegisterObjectWithDefault"] = "DetailsFramework.Language.RegisterObjectWithDefault",
    ["RegisterTableKeyWithDefault"] = "DetailsFramework.Language.RegisterTableKeyWithDefault",

    ["SetOption"] = "DetailsFramework.Language.SetOption",

    ["CreateLocTable"] = "DetailsFramework.Language.CreateLocTable",
    ["UnpackLocTable"] = "DetailsFramework.Language.UnpackLocTable",
    ["CanRegisterLocTable"] = "DetailsFramework.Language.CanRegisterLocTable",
    ["RegisterObjectWithLocTable"] = "DetailsFramework.Language.RegisterObjectWithLocTable",
    ["SetTextWithLocTable"] = "DetailsFramework.Language.SetTextWithLocTable",
    ["IsLocTable"] = "DetailsFramework.Language.IsLocTable",
    ["SetTextWithLocTableWithDefault"] = "DetailsFramework.Language.SetTextWithLocTableWithDefault",
    ["SetTextIfLocTableOrDefault"] = "DetailsFramework.Language.SetTextIfLocTableOrDefault",
    ["RegisterTableKeyWithLocTable"] = "DetailsFramework.Language.RegisterTableKeyWithLocTable",
    ["CreateLanguageSelector"] = "CreateLanguageSelector(addonId, parent, callback, selectedLanguage)",
}

local errorText = {
    ["AddonID"] = "require a valid addonID (table or string) on #%d argument",
    ["AddonIDInvalidOrNotRegistered"] = "invalid addonID or no languages registered",
    ["LanguageID"] = "require a languageID supported by the game on #%d argument",
    ["PhraseID"] = "require a string (phrase id) on #%d argument",
    ["LanguageIDInvalid"] = "require a string (language id) on #%d argument",
    ["FontPathInvalid"] = "require a string (font path) on #%d argument",
    ["NoLanguages"] = "no languages registered for addonId",
    ["LanguageIDNotRegistered"] = "languageID not registered",
    ["PhraseIDNotRegistered"] = "phraseID not registered",
    ["InvalidObject"] = "invalid object on #%d argument, object must have SetText method and be an UIObject or table",
    ["ObjectNotRegistered"] = "Object not registered yet",
    ["TableKeyNotRegistered"] = "table not registered yet",
    ["KeyNotRegistered"] = "key not registered yet",
    ["InvalidTable"] = "require a table on #%d argument",
    ["InvalidTableKey"] = "require a table key on #%d argument",
    ["TableKeyAlreadyRegistered"] = "table already registered", --not in use
    ["InvalidLocTable"] = "invalid locTable on #%d argument",
    ["LocTableCantRegister"] = "cannot register object or tableKey, locTable.register == false",
    ["InvalidOptionId"] = "invalid option on #%d argument",
}


--create language namespace
DF.Language = DF.Language or {version = 1}
DF.Language.RegisteredNamespaces = DF.Language.RegisteredNamespaces or {}

DF.Language.LanguageMixin = {
    SetAddonID = function(self, addonId)
        self.addonId = addonId
    end,

    GetAddonID = function(self, addonId)
        return self.addonId
    end,
}

--internal functions
local isValid_AddonID = function(addonId)
    if (type(addonId) ~= "string" and type(addonId) ~= "table") then
        return false
    end
    return true
end

local isValid_LanguageID = function(languageId)
    if (type(languageId) ~= "string") then
        return false
    end
    return true
end

local isValid_PhraseID = function(phraseId)
    return type(phraseId) == "string"
end

local isValid_Text = function(text)
    return type(text) == "string"
end

local isValid_Object = function(object)
    if (type(object) ~= "table" or not object.SetText) then
        return false
    end
    return true
end


--always create a new namespace if isn't registered yet
local getOrCreateAddonNamespace = function(addonId, languageId)
    local addonNamespaceTable = DF.Language.RegisteredNamespaces[addonId]
    if (not addonNamespaceTable) then
        addonNamespaceTable = {
            addonId = addonId,

            --store registered functions to call when the language is changed
            callbacks = {},

            --by default, the current language is the first registered language
            currentLanguageId = languageId,
            languages = {},
            registeredObjects = {},
            tableKeys = setmetatable({}, {__mode = "k"}),
            fonts = {},

            --set when the first language table is registered
            defaultLanguageTable = false,

            options = {},
        }

        DF.table.copy(addonNamespaceTable.options, addonNamespaceOptions)
        DF.Language.RegisteredNamespaces[addonId] = addonNamespaceTable

        printDebug("getOrCreateAddonNamespace", "created new addon namespace for:", addonId)
    end

    --if the language being register is the language being in use by the client, set this language as current language
    --this can be changed later with DF.Language.SetCurrentLanguage(addonId, languageId)
    local clientLanguage = GetLocale()
    if (languageId == clientLanguage) then
        addonNamespaceTable.currentLanguageId = languageId
    end

    return addonNamespaceTable
end


--just get the addon namespace returning nil if not registered yet
local getAddonNamespace = function(addonId)
    return DF.Language.RegisteredNamespaces[addonId]
end

local triggerRegisteredCallbacksForAddonId = function(addonId)
    local addonNamespaceTable = getAddonNamespace(addonId)
    if (not addonNamespaceTable) then
        return
    end

    local callbacks = addonNamespaceTable.callbacks

    for i = 1, #callbacks do
        local callback = callbacks[i]
        --trigger a secure callback using xpcall
        xpcall(callback.callback, _G["geterrorhandler"](), addonId, addonNamespaceTable.currentLanguageId, unpack(callback.payload))
    end
end

--these two are only used for the dropdown create the change the language
--for custom callbacks use DF.Language.RegisterCallback()
local setLanguageChangedCallback = function(addonNamespaceTable, callback)
    printDebug("setLanguageChangedCallback", "addonId:", addonNamespaceTable.addonId, "callbackType:", type(callback))
    addonNamespaceTable.onLanguageChangeCallback = callback
end
local getLanguageChangedCallback = function(addonNamespaceTable)
    return addonNamespaceTable.onLanguageChangeCallback
end

local getLanguageTable = function(addonNamespaceTable, languageId)
    local languageTable = addonNamespaceTable.languages[languageId]
    if (not languageTable) then
        return false
    end
    return languageTable
end

local getRegisteredLanguages = function(addonNamespaceTable)
    return addonNamespaceTable.languages
end

local getCurrentLanguageId = function(addonNamespaceTable)
    return addonNamespaceTable.currentLanguageId
end

local setOption = function(addonNamespaceTable, optionId, value)
    printDebug("setOption", "addonId:", addonNamespaceTable.addonId, "optionId:", optionId, "value:", value, "valueType:", type(value))
    addonNamespaceTable.options[optionId] = value
end

local getRegisteredObjects = function(addonNamespaceTable)
    return addonNamespaceTable.registeredObjects
end

--return a string representing a translated text and the languageId where the string was found
--attempt to get from the current selected language, then from the game language and then from english if the other two fails
--return false if the phraseId isn't found at all
local getText = function(addonNamespaceTable, phraseId)
    local currentLanguageId = getCurrentLanguageId(addonNamespaceTable)
    local languageTable = getLanguageTable(addonNamespaceTable, currentLanguageId)

    local text = phraseId

    --embed phraseId is when the phraseId is within the string but is surrounded by @
    local embedPhraseId = phraseId:match("@(.-)@")

    --get the text from the current language table
    if (languageTable) then
        text = rawget(languageTable, embedPhraseId or phraseId)
        if (isValid_Text(text)) then
            if (embedPhraseId) then
                --replace the embed phraseId with the translated text
                text = phraseId:gsub("@" .. embedPhraseId .. "@", text)
                return text, currentLanguageId
            else
                return text, currentLanguageId
            end
        end
    end

    --the translated string wasn't found on the current language table
    --attempt to get the text from the default language used in the client
    local clientLanguage = GetLocale()
    if (currentLanguageId ~= clientLanguage) then
        languageTable = getLanguageTable(addonNamespaceTable, clientLanguage)
        if (languageTable) then
            text = rawget(languageTable, embedPhraseId or phraseId)
            if (isValid_Text(text)) then
                if (embedPhraseId) then
                    --replace the embed phraseId with the translated text
                    text = phraseId:gsub("@" .. embedPhraseId .. "@", text)
                    return text, currentLanguageId
                else
                    return text, clientLanguage
                end
            end
        end
    end

    --attempt to get from english
    if (currentLanguageId ~= CONST_LANGUAGEID_ENUS and clientLanguage ~= CONST_LANGUAGEID_ENUS) then
        languageTable = getLanguageTable(addonNamespaceTable, CONST_LANGUAGEID_ENUS)
        if (languageTable) then
            text = rawget(languageTable, embedPhraseId or phraseId)
            if (isValid_Text(text)) then
                if (embedPhraseId) then
                    --replace the embed phraseId with the translated text
                    text = phraseId:gsub("@" .. embedPhraseId .. "@", text)
                    return text, CONST_LANGUAGEID_ENUS
                else
                    return text, CONST_LANGUAGEID_ENUS
                end
            end
        end
    end

    return false, CONST_LANGUAGEID_ENUS
end

local setLanguageTableForLanguageId = function(addonNamespaceTable, languageId, languageTable)
    local isFirstLanguage = not next(addonNamespaceTable.languages)
    if (isFirstLanguage) then
        printDebug("setLanguageTableForLanguageId", "(first to be registered) addonId:", addonNamespaceTable.addonId, "languageId:", languageId, "languageTable:", languageTable, "languageIdType:", type(languageId), "languageTableType:", type(languageTable))
        addonNamespaceTable.defaultLanguageTable = languageTable
    else
        printDebug("setLanguageTableForLanguageId", "addonId:", addonNamespaceTable.addonId, "languageId:", languageId, "languageTable:", languageTable, "languageIdType:", type(languageId), "languageTableType:", type(languageTable))

        local defaultLanguageMetatable = {__index = function(table, key)
            local value = rawget(table, key)
            if (value) then
                return value
            end

            local defaultLanguageTable = addonNamespaceTable.defaultLanguageTable
            value = defaultLanguageTable[key]
            if (value) then
                return value
            end

            return key
        end}

        setmetatable(languageTable, defaultLanguageMetatable)
    end

    addonNamespaceTable.languages[languageId] = languageTable
    return languageTable
end

local setCurrentLanguageId = function(addonNamespaceTable, languageId)
    printDebug("setCurrentLanguageId", "addonId:", addonNamespaceTable.addonId, "languageId:", languageId, "languageIdType:", type(languageId))

    addonNamespaceTable.currentLanguageId = languageId

    local callbackFunc = getLanguageChangedCallback(addonNamespaceTable)
    if (callbackFunc) then
        printDebug("setCurrentLanguageId", "addonId:", addonNamespaceTable.addonId, "calling callback", "callbackFuncType:", type(callbackFunc))
        xpcall(callbackFunc, _G["geterrorhandler"](), languageId, addonNamespaceTable.addonId)
    end

    triggerRegisteredCallbacksForAddonId(addonNamespaceTable.addonId)
end

local parseArguments = function(...)
    local argumentAmount = select("#", ...)
    if (argumentAmount > 0) then
        return {...}
    else
        return nil
    end
end

--hold information about a localization, used by registered objects and keyTables, has .phraesId, .arguments and .key (on keyTables)
local createPhraseInfoTable = function(phraseId, key, ...)
    return {
        phraseId = phraseId,
        key = key,
        arguments = parseArguments(...)
    }
end

local updatePhraseInfo_PhraseId = function(phraseInfoTable, phraseId)
    phraseInfoTable.phraseId = phraseId
end

local updatePhraseInfo_Arguments = function(phraseInfoTable, ...)
    phraseInfoTable.arguments = parseArguments(...)
end

---return the fontPath for the languageId or nil if the languageId is not registered for the addon
---@param addonNamespaceTable table
---@param languageId string
---@return fontPath|nil
local getFontForLanguageIdFromAddonNamespace = function(addonNamespaceTable, languageId)
    return addonNamespaceTable.fonts[languageId]
end

local shouldChangeFontForNewLanguage = function(addonNamespaceTable, oldLanguageId, newLanguageId)
    --does it need to change the font?
    local oldLanguageClusterId = fontLanguageCompatibility[oldLanguageId]
    local newLanguageClusterId = fontLanguageCompatibility[newLanguageId]

    if (oldLanguageClusterId == newLanguageClusterId) then
        --does not require to change the font
        return false
    else
        if (addonNamespaceTable.options.ChangeOnlyRegisteredFont) then
            --can change only if the font was previously registered with SetFontForLanguageId() or SetFontByAlphabetOrRegion()
            local languageFontPath = getFontForLanguageIdFromAddonNamespace(addonNamespaceTable, newLanguageId)
            if (languageFontPath) then
                --the font is registered
                return true, languageFontPath
            end
        else
            local languageFontPath = getFontForLanguageIdFromAddonNamespace(addonNamespaceTable, newLanguageId)
            if (languageFontPath) then
                --the font is registered
                return true, languageFontPath
            else
                --the font is not registered for this language, get the default font from the framework
                languageFontPath = DF.Language.GetFontForLanguageID(newLanguageId)
                return true, languageFontPath
            end
        end
    end
end

--get a phraseInfo and text returning a formatted text using arguments if they exists
local getFormattedText = function(phraseInfoTable, text)
    if (phraseInfoTable.arguments) then
        return format(text, unpack(phraseInfoTable.arguments))
    else
        return text
    end
end

local getObjectPhraseInfoTable = function(addonNamespaceTable, object)
    return addonNamespaceTable.registeredObjects[object]
end

local setObject_InternalMembers = function(object, addonId, phraseId, arguments, languageId)
    object.__languageAddonId = addonId or object.__languageAddonId
    object.__languagePhraseId = phraseId or object.__languagePhraseId
    object.__languageArguments = arguments or object.__languageArguments
    object.__languageId = languageId or object.__languageId
end

local setObject_Text = function(addonNamespaceTable, object, phraseInfoTable, text, textLanguageId)
    if (textLanguageId ~= object.__languageId) then
        local bShouldChangeFont, fontPath = shouldChangeFontForNewLanguage(addonNamespaceTable, object.__languageId, textLanguageId)
        if (bShouldChangeFont) then
            if (object:GetObjectType() == "Button") then
                local fontString = object:GetFontString()
                if (fontString) then
                    local font, size, flags = fontString:GetFont()
                    fontString:SetFont(fontPath, size, flags)
                end
            else
                local font, size, flags = object:GetFont()
                object:SetFont(fontPath, size, flags)
            end
            setObject_InternalMembers(object, false, false, false, textLanguageId)
        end
    end

    local formattedText = getFormattedText(phraseInfoTable, text)

    object:SetText(formattedText)
end

--this method only exists on registered Objects
local objectMethod_SetTextByPhraseID = function(object, phraseId, ...)
    local addonId = object.__languageAddonId
    local addonNamespaceTable = getAddonNamespace(addonId)

    local phraseInfoTable = getObjectPhraseInfoTable(addonNamespaceTable, object)
    updatePhraseInfo_PhraseId(phraseInfoTable, phraseId)
    updatePhraseInfo_Arguments(phraseInfoTable, ...)

    local currentLanguageId = getCurrentLanguageId(addonNamespaceTable)

    --when registering a new object, consider the font already set on the obejct to be a font compatible with the client languageId
    setObject_InternalMembers(object, addonId, phraseId, phraseInfoTable.arguments, currentLanguageId)

    local text, textLanguageId = getText(addonNamespaceTable, phraseId)
    setObject_Text(addonNamespaceTable, object, phraseInfoTable, text, textLanguageId)

    return true
end

local registerObject = function(addonNamespaceTable, object, phraseId, ...)
    local phraseInfoTable = getObjectPhraseInfoTable(addonNamespaceTable, object)

    if (phraseInfoTable) then
        --the object is already registered, update the phraseId and arguments
        updatePhraseInfo_PhraseId(phraseInfoTable, phraseId)
        updatePhraseInfo_Arguments(phraseInfoTable, ...)
    else
        phraseInfoTable = createPhraseInfoTable(phraseId, nil, ...)
        addonNamespaceTable.registeredObjects[object] = phraseInfoTable
    end

    local currentLanguageId = getCurrentLanguageId(addonNamespaceTable)

    --save internal information about the language directly in the object
    setObject_InternalMembers(object, addonNamespaceTable.addonId, phraseId, phraseInfoTable.arguments, gameLanguage)

    --give the object a new method
    object.SetTextByPhraseID = objectMethod_SetTextByPhraseID

    return phraseInfoTable
end

--iterate among all registered objects of an addon namespace and set the new text on them
local updateAllRegisteredObjectsText = function(addonNamespaceTable)
    local objects = getRegisteredObjects(addonNamespaceTable)
    for object, phraseInfoTable in pairs(objects) do
        local phraseId = phraseInfoTable.phraseId
        --note: text is always valid when the callstack started at from DF.Language.SetCurrentLanguage
        local text, textLanguageId = getText(addonNamespaceTable, phraseId)
        setObject_Text(addonNamespaceTable, object, phraseInfoTable, text, textLanguageId)
    end
end

--internal tableKey looks like:
--addonNamespaceTable.tableKeys = {} -> this table is a weaktable 'k'
--addonNamespaceTable.tableKeys[table] = {} -> table is a table from code elsewhere, it is used as a key for the internal code here, table created is what stores the keys
--addonNamespaceTable.tableKeys[table][key] -> key is the key from the table elsewhere which points to a string
--addonNamespaceTable.tableKeys[table][key] = {phraseId = phraseId, arguments = {...}, key = key}

--when registring a tableKey in practice, look like:
--Details.StoredStrings = {}; Details.StoredStrings["Height"] = "height": table is 'Details.StoredStrings' key is "Height"
--registerTableKey(_, Details.StoredStrings, "Height", _, _)

local setTableKey_Text = function(table, key, phraseInfoTable, text)
    local formattedText = getFormattedText(phraseInfoTable, text)
    table[key] = formattedText
end

local getTableKeyTable = function(addonNamespaceTable, table)
    return addonNamespaceTable.tableKeys[table]
end

--get the phraseInfo from the addon namespace
local getTableKeyPhraseInfoTable = function(addonNamespaceTable, table, key)
    return addonNamespaceTable.tableKeys[table][key]
end

--get the phraseInfo from the tableKey
local getPhraseInfoFromTableKey = function(tableKeyTable, key)
    return tableKeyTable[key]
end

local isTableKeyRegistered = function(addonNamespaceTable, table)
    return getTableKeyTable(addonNamespaceTable, table) and true
end

--return true if the phraseInfo is present in the tableKey
local isKeyRegisteredInTableKey = function(tableKeyTable, key)
    return getPhraseInfoFromTableKey(tableKeyTable, key) and true
end

local getRegisteredTableKeys = function(addonNamespaceTable)
    return addonNamespaceTable.tableKeys
end

local registerTableKeyTable = function(addonNamespaceTable, table, tableKeyTable)
    addonNamespaceTable.tableKeys[table] = tableKeyTable
end

local registerTableKey = function(addonNamespaceTable, table, key, phraseId, ...) --~registerTableKey
    local tableKeyTable = getTableKeyTable(addonNamespaceTable, table)
    if (not tableKeyTable) then
        tableKeyTable = {}
        registerTableKeyTable(addonNamespaceTable, table, tableKeyTable)
    end

    local phraseInfoTable = getPhraseInfoFromTableKey(tableKeyTable, key)

    if (phraseInfoTable) then
        --the key is already registered for this table, update the phraseId and arguments
        phraseInfoTable.phraseId = phraseId
        phraseInfoTable.arguments = parseArguments(...)
    else
        phraseInfoTable = createPhraseInfoTable(phraseId, key, ...)
        tableKeyTable[key] = phraseInfoTable
    end

    return tableKeyTable
end

--iterate among all registered tableKey of an addon namespace and set the new text on them
local updateAllRegisteredTableKeyText = function(addonNamespaceTable)
    local tableKeys = getRegisteredTableKeys(addonNamespaceTable)
    for table, tableKeyTable in pairs(tableKeys) do
        for key, phraseInfoTable in pairs(tableKeyTable) do
            local phraseId = phraseInfoTable.phraseId
            --note: text is always valid when the callstack started at from DF.Language.SetCurrentLanguage
            local text, textLanguageId = getText(addonNamespaceTable, phraseId)
            setTableKey_Text(table, key, phraseInfoTable, text)
        end
    end
end

local updateTextOnAllObjectsAndTableKeys = function(addonNamespaceTable)
    updateAllRegisteredObjectsText(addonNamespaceTable)
    updateAllRegisteredTableKeyText(addonNamespaceTable)
end

local setFontForLanguageId = function(addonNamespaceTable, languageId, fontPath)
    addonNamespaceTable.fonts[languageId] = fontPath
    --add into the font combatibility table (which fonts can be used for a language)
    if (not fontLanguageCompatibility[languageId]) then
        fontLanguageCompatibility[languageId] = fontPath
    end
end

---when the language has changed for an addon, call all callbacks registered for that addon
---the function will be called with the following parameters: callback(addonId, languageId, unpack(payload))
---@param addonId string
---@param callback function
---@vararg any
---@return boolean
function DF.Language.RegisterCallback(addonId, callback, ...)
    if (not isValid_AddonID(addonId)) then
        error("RegisterCallback() param #1 'addonId' must be a string or a table, got: " .. type(addonId) .. ".")
    end
    if (type(callback) ~= "function") then
        error("RegisterCallback() param #2 'callback' must be a function, got: " .. type(callback) .. ".")
    end

    local addonNamespaceTable = getAddonNamespace(addonId)
    if (not addonNamespaceTable) then
        return false
    end

    addonNamespaceTable.callbacks[#addonNamespaceTable.callbacks+1] = {callback = callback, payload = {...}}
    return true
end

---unregister a registered addon callback
---@param addonId string
---@param callback function
---@return boolean
function DF.Language.UnregisterCallback(addonId, callback)
    if (not isValid_AddonID(addonId)) then
        error("UnregisterCallback() param #1 'addonId' must be a string or a table, got: " .. type(addonId) .. ".")
    end
    if (type(callback) ~= "function") then
        error("UnregisterCallback() param #2 'callback' must be a function, got: " .. type(callback) .. ".")
    end

    local addonNamespaceTable = getAddonNamespace(addonId)
    if (not addonNamespaceTable) then
        return false
    end

    for i = 1, #addonNamespaceTable.callbacks do
        local callbackTable = addonNamespaceTable.callbacks[i]
        if (callbackTable.callback == callback) then
            tremove(addonNamespaceTable.callbacks, i)
            return true
        end
    end
    return false
end

---return the languageId of the text passed, if not found return the default languageId (enUS)
---@param text string
---@return string
function DF.Language.DetectLanguageId(text)
    --if the text is not a string, return the default languageId
    if (type(text) ~= "string") then
        return "enUS"
    end

    for character in text:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
        local byteCode, amountOfBytes = getByteCodeForCharacter(character)
        local languageId = DF.LanguageKnowledge[byteCode]
        if (languageId) then
            return languageId
        end
    end
    return "enUS"
end

---get the languageId set to be used on an addon
---@param addonId string
---@return string
function DF.Language.GetLanguageIdForAddonId(addonId)
    if (not isValid_AddonID(addonId)) then
        error("GetLanguageIdForAddonId() param #1 'addonId' must be a string or a table, got: " .. type(addonId) .. ".")
    end

    local addonNamespaceTable = getAddonNamespace(addonId)
    if (not addonNamespaceTable) then
        return "enUS"
    end

    return addonNamespaceTable.currentLanguageId
end

---check if the key exists in the default language table for the addon
---@param addonId string
---@param key string
---@return boolean
function DF.Language.DoesPhraseIDExistsInDefaultLanguage(addonId, key)  --~DoesPhraseIDExistsInDefaultLanguage
    if (not isValid_AddonID(addonId)) then
        error("DoesPhraseIDExistsInDefaultLanguage() param #1 'addonId' must be a string or a table, got: " .. type(addonId) .. ".")
    end

    local addonNamespaceTable = getAddonNamespace(addonId)
    if (not addonNamespaceTable) then
        return false
    end

    local defaultLanguageTable = addonNamespaceTable.defaultLanguageTable
    if (not defaultLanguageTable) then
        return false
    end

    return rawget(defaultLanguageTable, key) and true
end


---create a language table within an addon namespace
---if bIsNativeGameLanguage is true, languageName and languageFont are required
---@param addonId string an identifier, can be any table or string, will be used when getting the table with phrase translations, example: "DetailsLocalization", "Details", "PlaterLoc", _G.Plater
---@param languageId string game languages: "deDE", "enUS", "esES", "esMX", "frFR", "itIT", "koKR", "ptBR", "ruRU", "zhCN", "zhTW", or any other value if 'gameLanguageOnly' is false (default)
---@param bNotSupportedWoWLanguage boolean if true it indicates that this is not a native game language
---@return table: return a languageTable, this table holds translations for the registered language
function DF.Language.RegisterLanguage(addonId, languageId, bNotSupportedWoWLanguage, languageName, languageFont)  --~RegisterLanguage
    if (not isValid_AddonID(addonId)) then
        error(functionCallPath["RegisterLanguage"] .. ": " .. format(errorText["AddonID"], 1) .. ", use: " .. functionSignature["RegisterLanguage"] .. ".")

    elseif (not bNotSupportedWoWLanguage and not supportedGameLanguages[languageId]) then
        error(functionCallPath["RegisterLanguage"] .. ": " .. format(errorText["LanguageID"], 2) .. ", use: " .. functionSignature["RegisterLanguage"] .. ".")

    elseif (bNotSupportedWoWLanguage) then
        if (not languageName) then
            error(functionCallPath["RegisterLanguage"] .. ": " .. "Invalid Language Name" .. ", use: " .. functionSignature["RegisterLanguage"] .. ".")
        end
        if (not languageFont) then
            error(functionCallPath["RegisterLanguage"] .. ": " .. "Invalid Language Font" .. ", use: " .. functionSignature["RegisterLanguage"] .. ".")
        end

        if (not supportedGameLanguages[languageId]) then
            languagesAvailable[languageId] = {text = languageName, font = languageFont}
        end
    end

    --get the language namespace, the namespace can be a string or a table.
    --if the namespace isn't created yet, this function will create
    local addonNamespaceTable = getOrCreateAddonNamespace(addonId, languageId)

    if (bNotSupportedWoWLanguage) then
        setFontForLanguageId(addonNamespaceTable, languageId, languageFont)
        DF.registeredFontPaths[languageId] = languageFont
    end

    --create a table to hold traslations for this languageId
    local languageTable = {}
    setLanguageTableForLanguageId(addonNamespaceTable, languageId, languageTable)

    --after the language is registered, usualy comes the registration of phrases of the language registered
    --let the phrases be registered and after that register the characters and symbols used on that language
    C_Timer.After(0, function()
        registerCharacters(languageId, languageTable)
    end)

    return languageTable
end


--@addonId: an identifier, can be any table or string, will be used when getting the table with phrase translations, example: "DetailsLocalization", "Details", "PlaterLoc", _G.Plater
--@optionId: the ID of the option, check 
function DF.Language.SetOption(addonId, optionId, value)
    if (not isValid_AddonID(addonId)) then
        error(functionCallPath["SetOption"] .. ": " .. format(errorText["AddonID"], 1) .. ", use: " .. functionSignature["SetOption"] .. ".")
    end

    if (not addonNamespaceOptions[optionId]) then
        error(functionCallPath["SetOption"] .. ": " .. format(errorText["InvalidOptionId"], 2) .. ", use: " .. functionSignature["SetOption"] .. ".")
    end

    local addonNamespaceTable = getAddonNamespace(addonId)
    if (not addonNamespaceTable) then
        error(functionCallPath["SetOption"] .. ": " .. errorText["NoLanguages"] .. ", use: " .. functionSignature["RegisterLanguage"] .. ".")
    end

    setOption(addonNamespaceTable, optionId, value)
end

--print to chat the available option
function DF.Language.ShowOptionsHelp()
    for optionId, descriptionString in pairs(optionsHelp) do
        print(optionId .. ": " .. descriptionString)
    end
end


--@addonId: an identifier, can be any table or string, will be used when getting the table with phrase translations, example: "DetailsLocalization", "Details", "PlaterLoc", _G.Plater
--@languageId: game languages: "deDE", "enUS", "esES", "esMX", "frFR", "itIT", "koKR", "ptBR", "ruRU", "zhCN", "zhTW", or any other string value to represent a language
--@fontPath: a path for a font
function DF.Language.SetFontForLanguageId(addonId, languageId, fontPath)
    if (not isValid_AddonID(addonId)) then
        error(functionCallPath["SetFontForLanguageId"] .. ": " .. format(errorText["AddonID"], 1) .. ", use: " .. functionSignature["SetFontForLanguageId"] .. ".")
    end

    if (not isValid_LanguageID(languageId)) then
        error(functionCallPath["SetFontForLanguageId"] .. ": " .. format(errorText["LanguageIDInvalid"], 2) .. ", use: " .. functionSignature["SetFontForLanguageId"] .. ".")
    end

    if (type(fontPath) ~= "string") then
        error(functionCallPath["SetFontForLanguageId"] .. ": " .. format(errorText["FontPathInvalid"], 3) .. ", use: " .. functionSignature["SetFontForLanguageId"] .. ".")
    end

    local addonNamespaceTable = getAddonNamespace(addonId)
    if (not addonNamespaceTable) then
        error(functionCallPath["SetFontForLanguageId"] .. ": " .. errorText["NoLanguages"] .. ", use: " .. functionSignature["RegisterLanguage"] .. ".")
    end

    setFontForLanguageId(addonNamespaceTable, languageId, fontPath)
end


--@addonId: an identifier, can be any table or string, will be used when getting the table with phrase translations, example: "DetailsLocalization", "Details", "PlaterLoc", _G.Plater
--@regions: accept a font name, ignored is nil is passed
function DF.Language.SetFontByAlphabetOrRegion(addonId, latin, cyrillic, china, korean, taiwan)
    if (not isValid_AddonID(addonId)) then
        error(functionCallPath["SetFontByAlphabetOrRegion"] .. ": " .. format(errorText["AddonID"], 1) .. ", use: " .. functionSignature["SetFontByAlphabetOrRegion"] .. ".")
    end

    local addonNamespaceTable = getAddonNamespace(addonId)
    if (not addonNamespaceTable) then
        error(functionCallPath["SetFontByAlphabetOrRegion"] .. ": " .. errorText["NoLanguages"] .. ", use: " .. functionSignature["RegisterLanguage"] .. ".")
    end

    if (latin) then
        local fontPath = latin
        if (type(fontPath) == "string") then
            setFontForLanguageId(addonNamespaceTable, "deDE", fontPath)
            setFontForLanguageId(addonNamespaceTable, "enUS", fontPath)
            setFontForLanguageId(addonNamespaceTable, "esES", fontPath)
            setFontForLanguageId(addonNamespaceTable, "esMX", fontPath)
            setFontForLanguageId(addonNamespaceTable, "frFR", fontPath)
            setFontForLanguageId(addonNamespaceTable, "itIT", fontPath)
            setFontForLanguageId(addonNamespaceTable, "ptBR", fontPath)
        end
    end

    if (cyrillic) then
        local fontPath = cyrillic
        if (type(fontPath) == "string") then
            setFontForLanguageId(addonNamespaceTable, "ruRU", fontPath)
        end
    end

    if (china) then
        local fontPath = china
        if (type(fontPath) == "string") then
            setFontForLanguageId(addonNamespaceTable, "zhCN", fontPath)
        end
    end

    if (korean) then
        local fontPath = korean
        if (type(fontPath) == "string") then
            setFontForLanguageId(addonNamespaceTable, "zhTW", fontPath)
        end
    end

    if (taiwan) then
        local fontPath = taiwan
        if (type(fontPath) == "string") then
            local taiwanCountryLanguageId = "zhTW"
            setFontForLanguageId(addonNamespaceTable, taiwanCountryLanguageId, fontPath)
        end
    end
end


--get the languageTable for the requested languageId within the addon namespace
--@addonId: an identifier, can be any table or string, will be used when getting the table with phrase translations, example: "DetailsLocalization", "Details", "PlaterLoc", _G.Plater
--@languageId: game languages: "deDE", "enUS", "esES", "esMX", "frFR", "itIT", "koKR", "ptBR", "ruRU", "zhCN", "zhTW", or any other string value to represent a language if 'gameLanguageOnly' is false (default)
--return value: languageTable
function DF.Language.GetLanguageTable(addonId, languageId)
    if (not isValid_AddonID(addonId)) then
        error(functionCallPath["GetLanguageTable"] .. ": " .. format(errorText["AddonID"], 1) .. ", use: " .. functionSignature["GetLanguageTable"] .. ".")
    end

    local addonNamespaceTable = getAddonNamespace(addonId)
    if (not addonNamespaceTable) then
        error(functionCallPath["GetLanguageTable"] .. ": " .. errorText["NoLanguages"] .. ", use: " .. functionSignature["RegisterLanguage"] .. ".")
    end

    --if languageId was not been passed, use the current language
    if (not languageId) then
        languageId = getCurrentLanguageId(addonNamespaceTable)
    end

    local languageTable = getLanguageTable(addonNamespaceTable, languageId)
    if (not languageTable) then
        error(functionCallPath["GetLanguageTable"] .. ": " .. errorText["LanguageIDNotRegistered"] .. ", use: " .. functionSignature["RegisterLanguage"] .. ".")
    end

    return languageTable
end


--set the language used when retriving a languageTable with DF.Language.GetLanguageTable() without passing the second argument (languageId)
--use this in combination with a savedVariable to use a language of the user choice
--@addonId: an identifier, can be any table or string, will be used when getting the table with phrase translations, example: "DetailsLocalization", "Details", "PlaterLoc", _G.Plater
--@languageId: game languages: "deDE", "enUS", "esES", "esMX", "frFR", "itIT", "koKR", "ptBR", "ruRU", "zhCN", "zhTW", or any other string value to represent a language if 'gameLanguageOnly' is false (default)
function DF.Language.SetCurrentLanguage(addonId, newLanguageId)
    if (not isValid_AddonID(addonId)) then
        error(functionCallPath["SetCurrentLanguage"] .. ": " .. format(errorText["AddonID"], 1) .. ", use: " .. functionSignature["SetCurrentLanguage"] .. ".")
    end

    local addonNamespaceTable = getAddonNamespace(addonId)
    if (not addonNamespaceTable) then
        error(functionCallPath["SetCurrentLanguage"] .. ": " .. errorText["NoLanguages"] .. ", use: " .. functionSignature["RegisterLanguage"] .. ".")
    end

    local languageTable = getLanguageTable(addonNamespaceTable, newLanguageId)
    if (not languageTable) then
        error(functionCallPath["SetCurrentLanguage"] .. ": " .. errorText["LanguageIDNotRegistered"] .. ", use: " .. functionSignature["RegisterLanguage"] .. ".")
    end

    setCurrentLanguageId(addonNamespaceTable, newLanguageId)

    --go into the registered objects and KeyTables and change their text
    updateTextOnAllObjectsAndTableKeys(addonNamespaceTable)

    return true
end


--@addonId: an identifier, can be any table or string, will be used when getting the table with phrase translations, example: "DetailsLocalization", "Details", "PlaterLoc", _G.Plater
--@phraseId: any string to identify the a translated text, example: phraseId: "OPTIONS_FRAME_WIDTH" text: "Adjust the Width of the frame."
--@silent: if true won't error on invalid phrase text and instead use the phraseId as the text, it will still error on invalid addonId
function DF.Language.GetText(addonId, phraseId, silent)
    if (not isValid_AddonID(addonId)) then
        error(functionCallPath["GetText"] .. ": " .. format(errorText["AddonID"], 1) .. ", use: " .. functionSignature["GetText"] .. ".")

    elseif (not isValid_PhraseID(phraseId)) then
        error(functionCallPath["GetText"] .. ": " .. format(errorText["PhraseID"], 2) .. ", use: " .. functionSignature["GetText"] .. ".")
    end

    local addonNamespaceTable = getAddonNamespace(addonId)
    if (not addonNamespaceTable) then
        error(functionCallPath["GetText"] .. ": " .. errorText["NoLanguages"] .. ", use: " .. functionSignature["RegisterLanguage"] .. ".")
    end

    local text, textLanguageId = getText(addonNamespaceTable, phraseId)
    if (isValid_Text(text)) then
        return text, textLanguageId
    end

    if (not silent) then
        error(functionCallPath["GetText"] .. ": " .. errorText["PhraseIDNotRegistered"] .. ", use: " .. functionSignature["GetLanguageTable"] .. "['PhraseID'] = 'translated text'.")
    end

    return phraseId
end


--@addonId: an identifier, can be any table or string, will be used when getting the table with phrase translations, example: "DetailsLocalization", "Details", "PlaterLoc", _G.Plater
--@object: any UIObject or table with SetText method
--@phraseId: any string to identify the a translated text, example: token: "OPTIONS_FRAME_WIDTH" text: "Adjust the Width of the frame."
--@silent: if true won't error on invalid phrase text and instead use the phraseId as the text, it will still error on invalid addonId and object
--@vararg: arguments to pass for format(text, ...)
function DF.Language.RegisterObject(addonId, object, phraseId, silent, ...)
    if (not isValid_AddonID(addonId)) then
        error(functionCallPath["RegisterObject"] .. ": " .. format(errorText["AddonID"], 1) .. ", use: " .. functionSignature["RegisterObject"] .. ".")
    end

    if (not isValid_PhraseID(phraseId)) then
        error(functionCallPath["RegisterObject"] .. ": " .. format(errorText["PhraseID"], 3) .. ", use: " .. functionSignature["RegisterObject"] .. ".")
    end

    local addonNamespaceTable = getAddonNamespace(addonId)
    if (not addonNamespaceTable) then
        error(functionCallPath["RegisterObject"] .. ": " .. errorText["NoLanguages"] .. ", use: " .. functionSignature["RegisterLanguage"] .. ".")
    end

    if (not isValid_Object(object)) then
        error(functionCallPath["RegisterObject"] .. ": " .. format(errorText["InvalidObject"], 2) .. ", use: " .. functionSignature["RegisterObject"] .. ".")
    end

    local objectTable = registerObject(addonNamespaceTable, object, phraseId, ...)

    --on being registered the FontObject is not being checked for the current font set on it
    --this causes the font to have a enUS font from when it was created but wronfully signed as having ruRU font
    --causing the fontstring to not change the font when settings the text

    --solution: when registering a font string, get the font on it a attempt to identify the font set on it
    --solution 2: will be most likely to the font to be the default from the client language, e.g. frizz_quadrata_tt if the client is running enUS
    --solution 3: consider the font being used as the languageId of the client

    local text, textLanguageId = getText(addonNamespaceTable, phraseId)
    if (not isValid_Text(text)) then
        if (not silent) then
            error(functionCallPath["RegisterObject"] .. ": " .. errorText["PhraseIDNotRegistered"] .. ", use: " .. functionSignature["GetLanguageTable"] .. "['PhraseID'] = 'translated text'.")
        else
            text = phraseId
        end
    end

    setObject_Text(addonNamespaceTable, object, objectTable, text, textLanguageId)
    return true
end


--@addonId: an identifier, can be any table or string, will be used when getting the table with phrase translations, example: "DetailsLocalization", "Details", "PlaterLoc", _G.Plater
--@object: any UIObject or table with SetText method
--@vararg: arguments to pass for format(text, ...)
function DF.Language.UpdateObjectArguments(addonId, object, ...)
    if (not isValid_AddonID(addonId)) then
        error(functionCallPath["UpdateObjectArguments"] .. ": " .. format(errorText["AddonID"], 1) .. ", use: " .. functionSignature["UpdateObjectArguments"] .. ".")
    end

    local addonNamespaceTable = getAddonNamespace(addonId)
    if (not addonNamespaceTable) then
        error(functionCallPath["UpdateObjectArguments"] .. ": " .. errorText["NoLanguages"] .. ", use: " .. functionSignature["RegisterLanguage"] .. ".")
    end

    if (not isValid_Object(object)) then
        error(functionCallPath["UpdateObjectArguments"] .. ": " .. format(errorText["InvalidObject"], 2) .. ", use: " .. functionSignature["UpdateObjectArguments"] .. ".")
    end

    local phraseInfoTable = getObjectPhraseInfoTable(addonNamespaceTable, object)
    if (not phraseInfoTable) then
        error(functionCallPath["UpdateObjectArguments"] .. ": " .. errorText["ObjectNotRegistered"] .. ", use: " .. functionSignature["RegisterObject"] .. ".")
    end
    updatePhraseInfo_Arguments(phraseInfoTable, ...)

    local text, textLanguageId = getText(addonNamespaceTable, phraseInfoTable.phraseId)
    setObject_Text(addonNamespaceTable, object, phraseInfoTable, text, textLanguageId)
    return true
end


--@addonId: an identifier, can be any table or string, will be used when getting the table with phrase translations, example: "DetailsLocalization", "Details", "PlaterLoc", _G.Plater
--@table: a lua table
--@key: any value except nil or boolean
--@phraseId: any string to identify the a translated text, example: token: "OPTIONS_FRAME_WIDTH" text: "Adjust the Width of the frame."
--@silent: if true won't error on invalid phrase text or table already registered, it will still error on invalid addonId, table, key and phraseId
--@vararg: arguments to pass for format(text, ...)
function DF.Language.RegisterTableKey(addonId, table, key, phraseId, silent, ...) --~RegisterTableKey
    if (not isValid_AddonID(addonId)) then
        error(functionCallPath["RegisterTableKey"] .. ": " .. format(errorText["AddonID"], 1) .. ", use: " .. functionSignature["RegisterTableKey"] .. ".")
    end

    if (type(table) ~= "table") then
        error(functionCallPath["RegisterTableKey"] .. ": " .. format(errorText["InvalidTable"], 2) .. ", use: " .. functionSignature["RegisterTableKey"] .. ".")
    end

    if (key == nil or type(key) == "boolean") then
        error(functionCallPath["RegisterTableKey"] .. ": " .. format(errorText["InvalidTableKey"], 3) .. ", use: " .. functionSignature["RegisterTableKey"] .. ".")
    end

    if (not isValid_PhraseID(phraseId)) then
        error(functionCallPath["RegisterTableKey"] .. ": " .. format(errorText["PhraseID"], 4) .. ", use: " .. functionSignature["RegisterTableKey"] .. ".")
    end

    local addonNamespaceTable = getAddonNamespace(addonId)
    if (not addonNamespaceTable) then
        error(functionCallPath["RegisterTableKey"] .. ": " .. errorText["NoLanguages"] .. ", use: " .. functionSignature["RegisterLanguage"] .. ".")
    end

    local tableKeyTable = registerTableKey(addonNamespaceTable, table, key, phraseId, ...)

    local text, textLanguageId = getText(addonNamespaceTable, phraseId)
    if (not isValid_Text(text)) then
        if (not silent) then
            error(functionCallPath["RegisterTableKey"] .. ": " .. errorText["PhraseIDNotRegistered"] .. ": " .. phraseId .. ", use: " .. functionSignature["GetLanguageTable"] .. "['PhraseID'] = 'translated text'.")
        else
            text = phraseId
        end
    end

    setTableKey_Text(table, key, tableKeyTable, text)
    return true
end

--@addonId: an identifier, can be any table or string, will be used when getting the table with phrase translations, example: "DetailsLocalization", "Details", "PlaterLoc", _G.Plater
--@table: a lua table
--@key: any value except nil or boolean
--@vararg: arguments to pass for format(text, ...)
function DF.Language.UpdateTableKeyArguments(addonId, table, key, ...)
    if (not isValid_AddonID(addonId)) then
        error(functionCallPath["UpdateTableKeyArguments"] .. ": " .. format(errorText["AddonID"], 1) .. ", use: " .. functionSignature["UpdateTableKeyArguments"] .. ".")
    end

    local addonNamespaceTable = getAddonNamespace(addonId)
    if (not addonNamespaceTable) then
        error(functionCallPath["UpdateTableKeyArguments"] .. ": " .. errorText["NoLanguages"] .. ", use: " .. functionSignature["RegisterLanguage"] .. ".")
    end

    if (type(table) ~= "table") then
        error(functionCallPath["UpdateTableKeyArguments"] .. ": " .. format(errorText["InvalidTable"], 2) .. ", use: " .. functionSignature["UpdateTableKeyArguments"] .. ".")
    end

    if (key == nil or type(key) == "boolean") then
        error(functionCallPath["UpdateTableKeyArguments"] .. ": " .. format(errorText["InvalidTableKey"], 3) .. ", use: " .. functionSignature["UpdateTableKeyArguments"] .. ".")
    end

    if (not isTableKeyRegistered(addonNamespaceTable, table)) then
        error(functionCallPath["UpdateTableKeyArguments"] .. ": " .. errorText["TableKeyNotRegistered"] .. ", use: " .. functionSignature["RegisterTableKey"] .. ".")
    end

    local tableKeyTable = getTableKeyTable(addonNamespaceTable, table) --can't nil as the line above checked if it exists

    if (not isKeyRegisteredInTableKey(tableKeyTable, key)) then
        error(functionCallPath["UpdateTableKeyArguments"] .. ": " .. errorText["KeyNotRegistered"] .. ", use: " .. functionSignature["RegisterTableKey"] .. ".")
    end

    local phraseInfo = getPhraseInfoFromTableKey(tableKeyTable, key) --can't nil as the line above checked if it exists
    updatePhraseInfo_Arguments(phraseInfo, key, ...)

    local text, textLanguageId = getText(addonNamespaceTable, phraseInfo.phraseId)
    setTableKey_Text(table, key, tableKeyTable, text)
    return true
end


function DF.Language.RegisterTableKeyWithDefault(addonId, table, key, phraseId, defaultText, ...) --~RegisterTableKeyWithDefault
    if (addonId and phraseId) then
        DetailsFramework.Language.RegisterTableKey(addonId, table, key, phraseId, ...)
    else
        table[key] = defaultText
    end
end


function DF.Language.RegisterObjectWithDefault(addonId, object, phraseId, defaultText, ...)
    if (not isValid_Object(object)) then
        error(functionCallPath["RegisterObjectWithDefault"] .. ": " .. format(errorText["InvalidObject"], 2) .. ", use: " .. functionSignature["RegisterObjectWithDefault"] .. ".")
    end

    if (phraseId) then
        DetailsFramework.Language.RegisterObject(addonId, object, phraseId, ...)
    else
        object:SetText(defaultText)
    end
end


function DF.Language.CreateLocTable(addonId, phraseId, shouldRegister, silent, ...)
    if (not isValid_AddonID(addonId)) then
        error(functionCallPath["CreateLocTable"] .. ": " .. format(errorText["AddonID"], 1) .. ", use: " .. functionSignature["CreateLocTable"] .. ".")
    end

    if (not isValid_PhraseID(phraseId)) then
        error(functionCallPath["CreateLocTable"] .. ": " .. format(errorText["PhraseID"], 2) .. ", use: " .. functionSignature["CreateLocTable"] .. ".")
    end

    local addonNamespaceTable = getAddonNamespace(addonId)
    if (not addonNamespaceTable) then
        error(functionCallPath["CreateLocTable"] .. ": " .. errorText["NoLanguages"] .. ", use: " .. functionSignature["CreateLocTable"] .. ".")
    end

    local text, textLanguageId = getText(addonNamespaceTable, phraseId)
    if (not text) then
        if (not silent) then
            error(functionCallPath["CreateLocTable"] .. ": " .. errorText["PhraseIDNotRegistered"] .. ", use: " .. functionSignature["CreateLocTable"] .. ".")
        end
        return
    end

    if (type(shouldRegister) == "nil") then
        shouldRegister = true
    end

    local newLocTable = {
        addonId = addonId,
        phraseId = phraseId,
        shouldRegister = shouldRegister,
        arguments = parseArguments(...),
    }

    return newLocTable
end

function DF.Language.IsLocTable(locTable)
    if (type(locTable) ~= "table") then
        return false

    elseif (locTable.addonId and locTable.phraseId) then
        return true
    end

    return false
end


function DF.Language.CanRegisterLocTable(locTable)
    if (not DF.Language.IsLocTable(locTable)) then
        error(functionCallPath["CanRegisterLocTable"] .. ": " .. format(errorText["InvalidLocTable"], 1) .. ", use: " .. functionSignature["CanRegisterLocTable"] .. ".")
    end
    return locTable.shouldRegister
end


function DF.Language.UnpackLocTable(locTable)
    if (type(locTable) ~= "table") then
        error(functionCallPath["UnpackLocTable"] .. ": " .. format(errorText["InvalidLocTable"], 1) .. ", use: " .. functionSignature["UnpackLocTable"] .. ".")
    end
    return locTable.addonId, locTable.phraseId, locTable.shouldRegister or false, locTable.arguments
end


function DF.Language.RegisterTableKeyWithLocTable(table, key, locTable, silence)
    if (not DF.Language.IsLocTable(locTable)) then
        error(functionCallPath["RegisterTableKeyWithLocTable"] .. ": " .. format(errorText["InvalidLocTable"], 3) .. ", use: " .. functionSignature["RegisterTableKeyWithLocTable"] .. ".")
    end

    local addonId, phraseId, shouldRegister, arguments = DF.Language.UnpackLocTable(locTable)

    if (not shouldRegister) then
        error(functionCallPath["RegisterTableKeyWithLocTable"] .. ": " .. errorText["LocTableCantRegister"] .. ", use: " .. functionSignature["RegisterTableKeyWithLocTable"] .. ".")
    end

    DF.Language.RegisterTableKey(addonId, table, key, phraseId, silence, arguments and unpack(arguments))
end


function DF.Language.RegisterObjectWithLocTable(object, locTable, silence)
    if (not isValid_Object(object)) then
        error(functionCallPath["RegisterObjectWithLocTable"] .. ": " .. format(errorText["InvalidObject"], 1) .. ", use: " .. functionSignature["RegisterObjectWithLocTable"] .. ".")
    end

    if (not DF.Language.IsLocTable(locTable)) then
        error(functionCallPath["RegisterObjectWithLocTable"] .. ": " .. format(errorText["InvalidLocTable"], 2) .. ", use: " .. functionSignature["RegisterObjectWithLocTable"] .. ".")
    end

    local addonId, phraseId, shouldRegister, arguments = DF.Language.UnpackLocTable(locTable)

    if (not isValid_AddonID(addonId)) then
        error(functionCallPath["RegisterObjectWithLocTable"] .. ": " .. format(errorText["AddonID"], 1) .. ", use: " .. functionSignature["RegisterObjectWithLocTable"] .. ".")
    end

    if (not isValid_PhraseID(phraseId)) then
        error(functionCallPath["RegisterObjectWithLocTable"] .. ": " .. format(errorText["PhraseID"], 2) .. ", use: " .. functionSignature["RegisterObjectWithLocTable"] .. ".")
    end

    if (not shouldRegister) then
        error(functionCallPath["RegisterObjectWithLocTable"] .. ": " .. errorText["LocTableCantRegister"] .. ", use: " .. functionSignature["RegisterObjectWithLocTable"] .. ".")
    end

    DF.Language.RegisterObject(addonId, object, phraseId, silence, arguments and unpack(arguments))
end


function DF.Language.SetTextWithLocTable(object, locTable)
    if (not isValid_Object(object)) then
        error(functionCallPath["SetTextWithLocTable"] .. ": " .. format(errorText["InvalidObject"], 1) .. ", use: " .. functionSignature["SetTextWithLocTable"] .. ".")
    end

    if (not DF.Language.IsLocTable(locTable)) then
        error(functionCallPath["SetTextWithLocTable"] .. ": " .. format(errorText["InvalidLocTable"], 2) .. ", use: " .. functionSignature["SetTextWithLocTable"] .. ".")
    end

    local addonId, phraseId, shouldRegister, arguments = DF.Language.UnpackLocTable(locTable)

    local addonNamespaceTable = getAddonNamespace(addonId)
    if (not addonNamespaceTable) then
        error(functionCallPath["SetTextWithLocTable"] .. ": " .. errorText["AddonIDInvalidOrNotRegistered"] .. ", use: " .. functionSignature["RegisterLanguage"] .. ".")
    end

    if (DF.Language.CanRegisterLocTable(locTable)) then
        DF.Language.RegisterObjectWithLocTable(object, locTable)
        return true
    end

    local text, textLanguageId = getText(addonNamespaceTable, phraseId)

    --can use the locTable instead of the phraseInfoTable because both has the .arguments member
    setObject_Text(addonNamespaceTable, object, locTable, text, textLanguageId)
    return true
end

--use the locTable is valid or set the text using 'defaultText'
--@object: any UIObject or table with SetText method
--@locTable: a locTable created from CreateLocTable()
--@defaultText: a text string
function DF.Language.SetTextWithLocTableWithDefault(object, locTable, defaultText)
    if (not isValid_Object(object)) then
        error(functionCallPath["SetTextWithLocTableWithDefault"] .. ": " .. format(errorText["InvalidObject"], 1) .. ", use: " .. functionSignature["SetTextWithLocTableWithDefault"] .. ".")
    end

    if (not DF.Language.IsLocTable(locTable)) then
        object:SetText(defaultText or "")
    else
        DF.Language.SetTextWithLocTable(object, locTable)
    end
end

--if the second parameter is a regular string, the text set is the string, otherwise it'll handle the locTable and its parameters
--@object: any UIObject or table with SetText method
--@locTable: a locTable created from CreateLocTable()
function DF.Language.SetTextIfLocTableOrDefault(object, locTable)
    if (not isValid_Object(object)) then
        error(functionCallPath["SetTextIfLocTableOrDefault"] .. ": " .. format(errorText["InvalidObject"], 1) .. ", use: " .. functionSignature["SetTextIfLocTableOrDefault"] .. ".")
    end

    if (not DF.Language.IsLocTable(locTable)) then
        local textString = locTable
        object:SetText(textString)
    else
        DF.Language.SetTextWithLocTable(object, locTable)
    end
end

--@addonId: an identifier, can be any table or string, will be used when getting the table with phrase translations, example: "DetailsLocalization", "Details", "PlaterLoc", _G.Plater
--@parent: a frame to use as parent while creating the language selector dropdown
--@callback: a function which will be called when the user select a new language function(languageId) print("new language:", languageId) end
--@selectedLanguage: default selected language
function DF.Language.CreateLanguageSelector(addonId, parent, callback, selectedLanguage)
    if (not isValid_AddonID(addonId)) then
        error(functionCallPath["CreateLanguageSelector"] .. ": " .. format(errorText["AddonID"], 1) .. ", use: " .. functionSignature["CreateLanguageSelector"] .. ".")
    end

    if (type(parent) ~= "table" or not parent.GetObjectType or not parent.CreateTexture) then
        error(functionCallPath["CreateLanguageSelector"] .. ": " .. format("Require a frame on #%2 argument", 2) .. ", use: " .. functionSignature["CreateLanguageSelector"] .. ".")
    end

    local addonNamespaceTable = getAddonNamespace(addonId)
    if (not addonNamespaceTable) then
        error(functionCallPath["CreateLanguageSelector"] .. ": " .. errorText["AddonIDInvalidOrNotRegistered"] .. ", use: " .. functionSignature["RegisterLanguage"] .. ".")
    end

    setLanguageChangedCallback(addonNamespaceTable, callback)

    local allLanguagesRegistered = getRegisteredLanguages(addonNamespaceTable)

    local onSelectLanguage = function(self, addonId, languageId)
        DF.Language.SetCurrentLanguage(addonId, languageId)
        C_Timer.After(0.5, function()
            self:Select(languageId)
        end)
    end

    ---build a table with the all languageIDs registered to show as options in the dropdown
    ---@return table
    local buildOptionsFunc = function()
        ---@type {value: string, label: string, onclick: function, font: string}
        local resultTable = {}

        for languageId in pairs(allLanguagesRegistered) do
            local languageIdInfo = languagesAvailable[languageId]
            if (not languageIdInfo) then
                --for debug
                print("DetailsFramework: languageId is registered but has no languageInfo:", languageId)
            else
                resultTable[#resultTable+1] = {value = languageId, label = languageIdInfo.text, onclick = onSelectLanguage, font = languageIdInfo.font}
            end
        end

        return resultTable
    end

    local languageSelector = DF:CreateDropDown(parent, buildOptionsFunc, selectedLanguage or getCurrentLanguageId(addonNamespaceTable), 120, 20, nil, nil, DF:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE"))
    languageSelector:SetAddonID(addonId)
    languageSelector:SetFixedParameter(addonId)

    local languageLabel = DF:CreateLabel(parent, _G.LANGUAGE  .. ":", 10, "silver")
    languageLabel:SetPoint("right", languageSelector, "left", -3, 0)
    languageSelector.languageLabel = languageLabel

    return languageSelector
end


---return a font (path for a file) which works for the languageId passed, if the languageId is not registered, it'll return a compatible font registered by another addon or the default font
---@param languageId string
---@param addonId string|nil
---@return string
function DF.Language.GetFontForLanguageID(languageId, addonId)
    if (addonId) then
        ---@type addonNamespaceTable
        local addonNamespaceTable = getAddonNamespace(addonId)
        if (not addonNamespaceTable) then
            error(functionCallPath["CreateLanguageSelector"] .. ": " .. errorText["AddonIDInvalidOrNotRegistered"] .. ", use: " .. functionSignature["RegisterLanguage"] .. ".")
        end

        --get the font from the addon namespace table
        ---@type fontPath|nil
        local fontPath = getFontForLanguageIdFromAddonNamespace(addonNamespaceTable, languageId)
        if (fontPath) then
            return fontPath
        end
    end

    local languageIdInfo = languagesAvailable[languageId]
    if (languageIdInfo) then
        return languageIdInfo.font
    end
    return "Fonts\\FRIZQT__.TTF"
end