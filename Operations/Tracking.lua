
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)





function Addon:StartTracking()
  Addon.onOptionSetHandlers["WipeUsableMounts"] = Addon.WipeUsableMounts
  Addon.onOptionSetHandlers["WipeUsablePets"]   = Addon.WipeUsablePets
  
  self:RegisterEvent("COMPANION_UPDATE", function(self, category)
    if category == "MOUNT" then
      Addon.WipeUsableMounts()
    elseif category == "CRITTER" then
      Addon.WipeUsablePets()
    end
  end)
  self:RegisterEvent("MOUNT_JOURNAL_USABILITY_CHANGED", function()
    Addon.WipeUsableMounts()
    Addon.WipeUsablePets()
  end)
end










