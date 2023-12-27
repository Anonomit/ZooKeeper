
local ADDON_NAME, Data = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)
local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "enUS", true, not Addon:IsDebugEnabled())
if not L then return end





-- Behavior options
L["Prefer ground-only mounts"] = true
L["Try to avoid using flying mounts in non-flying areas."] = true

L["Allow slow mounts"] = true
L["Use a mount/form even when it doesn't increase speed.|n|nThis is most common when swimming without owning any swimming mounts."] = true

L["Tweak randomizer"] = true
L["Allow ZooKeeper to tweak the randomizer to avoid summoning the same mount/pet consecutively."] = true

L["Only use favorites"] = true
L["Never use a mount/pet that isn't marked as a favorite.|n|nZooKeeper will not be able to use the best mount available if you don't have it favorited.|n|n|cffff2020Make sure you set favorites for every type of mount!"] = true

L["Always dismount"] = true
L["When already mounted and a better mount exists, dismount instead of using the better mount."] = true

L["Use pets that consume reagents."] = true

L["Hide some error messages"] = true
L["Hides the red messages that can happen when you're unable to use an ability."] = true
L["(Not compatible with ErrorFilter)"] = true


-- Class options
L["Use %s spells"] = true
L["Use |cff00ccff%s|r class spells when appropriate."] = true

L["Use %s mounts"] = true
L["Use |cff00ccff%s|r class mounts when appropriate."] = true

L["Use |cff00ccff%s|r when appropriate."] = true

L["Allow risky shapeshifting"] = true
L["Allows you to exit Flight Form in areas where you won't be able to enter it again, such as indoors or around Dalaran.|n|nEnabling this option may lead to accidental falls."] = true

L["Always prefer Flight Form"] = true
L["Use Flight Form even if a faster mount exists."] = true



-- Zone options
L["Require click to confirm"] = true
L["Enable to use a targeting circle.|nDisable to use mouse cursor location."] = true

L["Equip and activate legendary items."] = true

L["Douse the Runes of Warding."] = true

-- L["Toggle hunter ranged weapon"] = true
-- L["Avoid hunter class calls by toggling ranged weapon off before it happens."] = true



-- Deprecated chat commands
L["Due to the collections interface,|nthe command |cff00ccff%s|r is no longer available.|n|n%s"] = true
L["Use |cff00ccff/click ZKM|r instead.|n(ZooKeeper Mount)"] = true
L["Use |cff00ccff/click ZKP|r instead.|n(ZooKeeper Pet)"] = true

