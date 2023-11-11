
local ADDON_NAME, Data = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)



function Addon:MakeDefaultOptions()
  local fakeAddon = {
    db = {
      profile = {
        fav = {
          ["*"] = false,
        },
        
        behavior = {
          onlyUseFavs = false,
          preferNonFlyingMountsOnGround = true,
          allowSlowMounts = true,
          useTrueRandomization = false,
          hideErrorMessages = true,
        },
        
        class = {
          ["**"] = {
            useForms = true,
            allowedForms = {
              ["*"] = true,
            },
            allowRiskyShapeshifting = false,
          },
          DRUID = {
            alwaysPreferFlightForm = false,
          },
        },
        
        zone = {
          ["**"] = {
            useZoneItems = true,
            ["*"]        = true,
          },
        },
      },


      global = {
        -- Debug options
        debug = false,
        
        debugShowLuaErrors = true,
          
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
