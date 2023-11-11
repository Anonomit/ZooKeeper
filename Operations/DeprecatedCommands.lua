
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)






StaticPopupDialogs["ZOOKEEPER_DEPRECATED_SLASH_COMMAND"] =
{
    text         = L["Due to the collections interface,|nthe command |cff00ccff%s|r is no longer available.|n|n%s"],
    button1      = OKAY,
    timeout      = 0,
    whileDead    = 1,
    hideOnEscape = 1,
};


local function GetMountCommandString()
  return L["Use |cff00ccff/click ZKM|r instead.|n(ZooKeeper Mount)"]
end
local function GetCritterCommandString()
  return L["Use |cff00ccff/click ZKP|r instead.|n(ZooKeeper Pet)"]
end



function Addon:OldMountCommand(...)
  StaticPopup_Show("ZOOKEEPER_DEPRECATED_SLASH_COMMAND", "/mount", GetMountCommandString())
end
function Addon:OldCritterCommand(...)
  StaticPopup_Show("ZOOKEEPER_DEPRECATED_SLASH_COMMAND", "/critter", GetCritterCommandString())
end
function Addon:OldCompanionCommand(...)
  StaticPopup_Show("ZOOKEEPER_DEPRECATED_SLASH_COMMAND", "/companion", GetCritterCommandString())
end






