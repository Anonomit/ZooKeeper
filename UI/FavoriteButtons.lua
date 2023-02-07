
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)



Addon.UI.FavoriteButtons = {}
local This = Addon.UI.FavoriteButtons

function This:Init()
  hooksecurefunc("PetPaperDollFrame_UpdateCompanionPreview", function() Addon.UI.FavoriteButtons:UpdateAll() end)
end



function This.OnLoad(self)
  self.Update = function()
    local selected = PetPaperDollFrame_FindCompanionIndex()
    if selected > 0 then
      local spellID = select(3, GetCompanionInfo(PetPaperDollFrameCompanionFrame.mode, selected))
      self:SetShown(self.fav ~= Addon:GetOption("fav", spellID))
    end
  end
end

function This.OnClick(self)
  local selected = PetPaperDollFrame_FindCompanionIndex()
  if selected > 0 then
    local spellID = select(3, GetCompanionInfo(PetPaperDollFrameCompanionFrame.mode, selected))
    Addon:ToggleOption("fav", spellID)
    This:UpdateAll()
    Addon.UI.FavoriteIcons:UpdateAll()
  end
  PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
end


do
  local favoriteButtons
  function This:UpdateAll()
    if not favoriteButtons then
      favoriteButtons = Addon:MakeLookupTable({[PetPaperDollFrameCompanionFrame.Set] = PetPaperDollFrameCompanionFrame.UnSet}, nil, true)
    end
    local button = next(favoriteButtons, button)
    button:Update()
    next(favoriteButtons, button):Update()
  end
end

