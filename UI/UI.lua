


local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)



Addon.UI = {}
local This = Addon.UI

function This:Init()
  self.FavoriteButtons:Init()
  self.FavoriteIcons  :Init()
end

