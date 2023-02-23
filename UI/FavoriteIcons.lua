
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)



Addon.UI.FavoriteIcons = {}
local This = Addon.UI.FavoriteIcons



function This:Init()
  hooksecurefunc("PetPaperDollFrame_UpdateCompanions", function() self:UpdateAll() end)
end



function This.OnLoad(self)
  self.Update = function(self)
    local spellID = self:GetParent().spellID
    self:SetShown(spellID and Addon:GetOption("fav", spellID) or false)
  end
end


do
  local favoriteIcons
  function This:UpdateAll()
    if not favoriteIcons then
      favoriteIcons = {}
      for i = 1, 12 do
        local button = _G["CompanionButton"..i].FavIcon
        if button then
          tinsert(favoriteIcons, button)
        end
      end
    end
    for i, button in ipairs(favoriteIcons) do
      button:Update()
    end
  end
end

