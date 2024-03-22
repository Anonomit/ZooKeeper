
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)




local strLower  = string.lower

local tostring = tostring



local L = setmetatable({}, {
  __index = function(self, key)
    rawset(self, key, key)
    Addon:Throwf("%s: Missing automatic translation for '%s'", ADDON_NAME, tostring(key))
    return key
  end,
  __newindex = function(self, key, val)
    if type(val) == "table" then
      -- get the largest index in table
      local max = 1
      for i in pairs(val) do
        if i > max then
          max = i
        end
      end
      -- try adding values from the table in order
      for i = 1, max do
        if val[i] then
          self[key] = val[i]
          if rawget(self, key) then
            return
          else
            Addon:Warnf(ADDON_NAME..": Automatic translation #%d failed for '%s'", i, tostring(key))
          end
        else
          Addon:Warnf(ADDON_NAME..": Automatic translation #%d failed for '%s'", i, tostring(key))
        end
      end
    elseif type(val) == "function" then
      -- use the function return value unless it errors
      local success, val = Addon:xpcall(val)
      if not success then
        Addon:Throwf("%s: Automatic translation error for '%s'", ADDON_NAME, tostring(key))
        return
      end
      rawset(self, key, val)
    else
      rawset(self, key, val)
    end
  end,
})
Addon.L = L


-- L["Options"] = OPTIONS

-- L["Disable"] = DISABLE
-- L["Enabled"] = VIDEO_OPTIONS_ENABLED
-- L["Disabled"] = ADDON_DISABLED
-- L["Modifiers:"] = MODIFIERS_COLON

-- L["never"] = function() strLower(CALENDAR_REPEAT_NEVER) end
-- L["any"]   = function() strLower(SPELL_TARGET_TYPE1_DESC) end
-- L["all"]   = function() strLower(SPELL_TARGET_TYPE12_DESC) end

-- L["SHIFT key"] = SHIFT_KEY
-- L["CTRL key"]  = CTRL_KEY
-- L["ALT key"]   = ALT_KEY

-- L["Features"] = FEATURES_LABEL


-- L["ERROR"] = ERROR_CAPS


L["Enable"]                       = ENABLE
L["Debug"]                        = BINDING_HEADER_DEBUG
L["Display Lua Errors"]           = SHOW_LUA_ERRORS
L["Reload UI"]                    = RELOADUI
L["Hide messages like this one."] = COMBAT_LOG_MENU_SPELL_HIDE
L["Lua Warning"]                  = LUA_WARNING
L["Clear Cache"]                  = BROWSER_CLEAR_CACHE
-- L["Delete"]                       = DELETE




L["Mount"]    = MOUNT
L["Call Pet"] = {function() return format(CALL_PET_SPELL_NAME, PET) end, CLASS_HUNTER_SPELLNAME2}

L["Toggle Mounts Journal"] = BINDING_NAME_TOGGLEMOUNTJOURNAL
L["Toggle Pet Journal"]    = BINDING_NAME_TOGGLEPETJOURNAL
L["Mounts"]                = MOUNTS
L["Pets"]                  = PETS
L["Companions"]            = COMPANIONS
L["No items found"]        = BROWSE_NO_RESULTS
L["Favorites"]             = FAVORITES
L["Remove"]                = REMOVE

L["Reagents"] = MINIMAP_TRACKING_VENDOR_REAGENT

L["Class"] = CLASS

L["Zone"]                   = ZONE
L["Classic"]                = EXPANSION_NAME0
L["The Burning Crusade"]    = EXPANSION_NAME1
L["Wrath of the Lich King"] = EXPANSION_NAME2

L["Item"] = ENCOUNTER_JOURNAL_ITEM

L["Use Item"] = USE_ITEM

L["Legendaries"] = LOOT_JOURNAL_LEGENDARIES

L["Preferences"]   = PREFERENCES











