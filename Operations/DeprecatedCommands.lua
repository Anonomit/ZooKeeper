
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)






StaticPopupDialogs["ZOOKEEPER_OLD_SLASH_COMMAND"] =
{
    text         = "Due to the collections interface,|nthe command |cff00ccff%s|r is no longer available.|n|n%s",
    button1      = OKAY,
    timeout      = 0,
    whileDead    = 1,
    hideOnEscape = 1,
};


local function GetMountCommandString()
  return "Use |cff00ccff/click ZKM|r instead.|n(ZooKeeper Mount)"
end
local function GetCritterCommandString()
  return "Use |cff00ccff/click ZKP|r instead.|n(ZooKeeper Pet)"
end



function Addon:OldMountCommand(...)
  StaticPopup_Show("ZOOKEEPER_OLD_SLASH_COMMAND", "/mount", GetMountCommandString())
end
function Addon:OldCritterCommand(...)
  StaticPopup_Show("ZOOKEEPER_OLD_SLASH_COMMAND", "/critter", GetCritterCommandString())
end
function Addon:OldCompanionCommand(...)
  StaticPopup_Show("ZOOKEEPER_OLD_SLASH_COMMAND", "/companion", GetCritterCommandString())
end






