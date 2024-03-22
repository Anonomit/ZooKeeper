
local ADDON_NAME, Data = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)



function Addon:MakeDefaultOptions()
  local fakeAddon = {
    db = {
      profile = {
        fav = {
          ["*"] = false,
        },
        discovered = {
          mounts   = {},
          critters = {},
        },
        
        behavior = {
          preferNonFlyingMountsOnGround = true, -- avoid using the ground forms of flying mounts
          allowSlowMounts = true, -- use a mount even when it won't increase movement speed in this situation
          useTrueRandomization = false, -- prevent mount cycling
          onlyUseFavs = false, -- ignore non-favorite mounts
          alwaysDismount = false, -- don't remount when a better version is found
          useReagents = true, -- use pets that consume reagents
          hideErrorMessages = true, -- applies to red error text when using class spells
        },
        
        class = {
          ["**"] = {
            useForms = true, -- use class spells that are not actual mounts
            allowedForms = {
              ["*"] = true,
            },
            useMounts = true, -- only for class-specific mount spells
            allowedMounts = {
              ["*"] = true,
            },
          },
          DRUID = {
            allowRiskyShapeshifting = false, -- determines if a druid can exit flight form in an area where it cannot be recast
            alwaysPreferFlightForm  = false,
          },
          SHAMAN = {
            allowedForms = {
              WaterWalking = false,
            },
          },
        },
        
        zone = {
          ["**"] = {
            useZoneItems = true,
            allowedItems = {
              ["*"] = true,
            },
            atCursor = true,
          },
        },
      },


      global = {
        -- Debug options
        debug = false,
        
        debugShowLuaErrors   = true,
        debugShowLuaWarnings = true,
          
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
