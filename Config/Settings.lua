
local ADDON_NAME, Data = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)




function Addon:MakeDefaultOptions()
  local fakeAddon = {
    db = {
      profile = {
        
        fav = {
          ["*"] = false,
        },
        
        -- Debug options
        debug = false,
          
        debugOutput = {
          ["*"] = false,
        },
        
        
        fix = {
          InterfaceOptionsFrameForMe  = true,
          InterfaceOptionsFrameForAll = false,
        },
      },
    },
  }
  return fakeAddon.db
end
