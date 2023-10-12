
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)






--   ██████╗██╗      █████╗ ███████╗███████╗███████╗███████╗
--  ██╔════╝██║     ██╔══██╗██╔════╝██╔════╝██╔════╝██╔════╝
--  ██║     ██║     ███████║███████╗███████╗█████╗  ███████╗
--  ██║     ██║     ██╔══██║╚════██║╚════██║██╔══╝  ╚════██║
--  ╚██████╗███████╗██║  ██║███████║███████║███████╗███████║
--   ╚═════╝╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚══════╝

do
  Addon.MY_CLASS_NAME, Addon.MY_CLASS = UnitClassBase"player"
end


--  ██╗      ██████╗  ██████╗ █████╗ ████████╗██╗ ██████╗ ███╗   ██╗███████╗
--  ██║     ██╔═══██╗██╔════╝██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
--  ██║     ██║   ██║██║     ███████║   ██║   ██║██║   ██║██╔██╗ ██║███████╗
--  ██║     ██║   ██║██║     ██╔══██║   ██║   ██║██║   ██║██║╚██╗██║╚════██║
--  ███████╗╚██████╔╝╚██████╗██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║███████║
--  ╚══════╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝

do

  Addon.zones = {
    Oculus = 143,
  }
  
  



  local knowsColdWeatherFlying = nil
  local function KnowsColdWeatherFlying()
    if not knowsColdWeatherFlying then
      knowsColdWeatherFlying = IsSpellKnown(54197)
    end
    return knowsColdWeatherFlying
  end
  
  -- locations in northrend in which a flying mount may not work, despite passing all checks
  local northrendFailureLocations = setmetatable(Addon:MakeLookupTable({
    125, -- Dalaran
    126, -- Dalaran Underbelly
  }, true), {__index = function() return false end})
  
  -- continents in which a flying mount may not work, even though IsFlyableArea() == true
  Addon.flyingFailureLocations = setmetatable({
    [571] = function() -- Northrend
      return KnowsColdWeatherFlying() and northrendFailureLocations[C_Map.GetBestMapForUnit"player"]
    end,
  }, {__index = function() return function() return false end end})
  
  -- locations in which flying requires extra checks such as prequisite skills
  Addon.flightPermissionLocations = setmetatable({
    [571] = KnowsColdWeatherFlying, -- Northrend,
  }, {__index = function() return function() return true end end})
end








--  ██╗████████╗███████╗███╗   ███╗███████╗
--  ██║╚══██╔══╝██╔════╝████╗ ████║██╔════╝
--  ██║   ██║   █████╗  ██╔████╔██║███████╗
--  ██║   ██║   ██╔══╝  ██║╚██╔╝██║╚════██║
--  ██║   ██║   ███████╗██║ ╚═╝ ██║███████║
--  ╚═╝   ╚═╝   ╚══════╝╚═╝     ╚═╝╚══════╝

do
  Addon.items = {
    -- Oculus
    EmeraldEssence = 37815,
    AmberEssence   = 37859,
    RubyEssence    = 37860,
  }
end








--  ███████╗██████╗ ███████╗██╗     ██╗     ███████╗
--  ██╔════╝██╔══██╗██╔════╝██║     ██║     ██╔════╝
--  ███████╗██████╔╝█████╗  ██║     ██║     ███████╗
--  ╚════██║██╔═══╝ ██╔══╝  ██║     ██║     ╚════██║
--  ███████║██║     ███████╗███████╗███████╗███████║
--  ╚══════╝╚═╝     ╚══════╝╚══════╝╚══════╝╚══════╝

do
  Addon.spells = {
    -- Druid shapeshift forms
    CatForm         = 768,
    TravelForm      = 783,
    AquaticForm     = 1066,
    FlightForm      = 33943,
    SwiftFlightForm = 40120,
    
    -- Oculus
    EmeraldEssence = 49345,
    AmberEssence   = 49461,
    RubyEssence    = 49462,
  }
  
  Addon.aurasToCancel = {
    -- Druid shapeshift forms
    BearForm     = 5487,
    DireBearForm = 9634,
    MoonkinForm  = 24858,
    TreeOfLife   = 33891,
  }
  for k, v in pairs(Addon.aurasToCancel) do
    Addon.spells[k] = v
  end
  
  Addon.spellNames = setmetatable({}, {__index = function(self, k) self[k] = GetSpellInfo(Addon.spells[k]) or "?" return self[k] end})
  
  for name in pairs(Addon.spells) do
    nop(Addon.spellNames[name])
  end
end



--  ███╗   ███╗ ██████╗ ██╗   ██╗███╗   ██╗████████╗███████╗
--  ████╗ ████║██╔═══██╗██║   ██║████╗  ██║╚══██╔══╝██╔════╝
--  ██╔████╔██║██║   ██║██║   ██║██╔██╗ ██║   ██║   ███████╗
--  ██║╚██╔╝██║██║   ██║██║   ██║██║╚██╗██║   ██║   ╚════██║
--  ██║ ╚═╝ ██║╚██████╔╝╚██████╔╝██║ ╚████║   ██║   ███████║
--  ╚═╝     ╚═╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚══════╝

do
  --[[
  [spellID] =
  {
    creatureID,
    typeFlags = &1 if flying mount, &2 if usable underwater, &4 if usable on ground and also in flight,
    mountFlags (from Mount.db2 in later expansions),
    groundSpeeds,
    flightSpeeds,
    swimSpeeds,
    faction (added by the code on the bottom of the file),
    function that checks extra conditions for whether the mount is usable, very loosely (added by the code on the bottom of the file),
  }
  
  mountFlags are blizzlike:
  0x1 Server Only
  0x2 Is Self Mount
  0x4 Exclude from Journal if faction doesn't match
  0x8 Allow mounted combat
  0x10 Summon Random: Favor While Underwater
  0x20 Summon Random: Favor While at Water Surface
  0x40 Exclude from Journal if not learned
  0x80 Summon Random: Do NOT Favor When Grounded
  0x100 Show in Spellbook
  0x200 Add to Action Bar on Learn
  0x400 NOT for use as a taxi (non-standard mount anim)
  --]]
  
  Addon.mounts = {
    [458] = {284, 2, 0, 60, 0, 0},
    [459] = {4268, 2, 64, 60, 0, 0},
    [468] = {305, 2, 64, 60, 0, 0},
    [470] = {308, 2, 0, 60, 0, 0},
    [471] = {306, 0, nil, 60, 0, 0},
    [472] = {307, 2, 0, 60, 0, 0},
    [578] = {356, 2, 64, 60, 0, 0},
    [579] = {4270, 2, 64, 100, 0, 0},
    [580] = {358, 2, 0, 60, 0, 0},
    [581] = {359, 2, 64, 60, 0, 0},
    [3363] = {16597, 1, nil, 100, 310, 0},
    [5784] = {304, 2, 0, 60, 0, 0},
    [6648] = {4269, 2, 0, 60, 0, 0},
    [6653] = {4271, 2, 0, 60, 0, 0},
    [6654] = {4272, 2, 0, 60, 0, 0},
    [6777] = {4710, 2, 0, 60, 0, 0},
    [6896] = {4780, 2, 64, 60, 0, 0},
    [6897] = {4778, 2, nil, 60, 0, 0},
    [6898] = {4777, 2, 0, 60, 0, 0},
    [6899] = {4779, 2, 0, 60, 0, 0},
    [8394] = {6074, 2, 0, 60, 0, 0},
    [8395] = {6075, 2, 0, 60, 0, 0},
    [8396] = {6076, 2, nil, 0, 0, 0},
    [8980] = {6486, 0, 64, 60, 0, 0},
    [10787] = {7322, 2, nil, 60, 0, 0},
    [10788] = {7684, 0, nil, 60, 0, 0},
    [10789] = {7687, 2, 0, 60, 0, 0},
    [10790] = {7686, 0, 64, 60, 0, 0},
    [10792] = {7689, 0, nil, 60, 0, 0},
    [10793] = {7690, 2, 0, 60, 0, 0},
    [10795] = {7706, 2, 64, 60, 0, 0},
    [10796] = {7707, 2, 0, 60, 0, 0},
    [10798] = {7703, 2, nil, 60, 0, 0},
    [10799] = {7708, 2, 0, 60, 0, 0},
    [10800] = {7709, 0, nil, 0, 0, 0},
    [10801] = {7710, 0, nil, 0, 0, 0},
    [10802] = {7711, 2, nil, 0, 0, 0},
    [10803] = {7712, 2, nil, 0, 0, 0},
    [10804] = {7713, 2, nil, 0, 0, 0},
    [10873] = {7739, 2, 0, 60, 0, 0},
    [10969] = {7749, 2, 0, 60, 0, 0},
    [13819] = {9158, 2, 4, 60, 0, 0},
    [15779] = {10179, 2, 64, 100, 0, 0},
    [15780] = {10178, 2, 64, 60, 0, 0},
    [15781] = {10180, 2, nil, 60, 0, 0},
    [16055] = {7322, 2, 64, 100, 0, 0},
    [16056] = {10322, 2, 64, 100, 0, 0},
    [16058] = {10336, 2, nil, 60, 0, 0},
    [16059] = {10337, 2, nil, 60, 0, 0},
    [16060] = {10338, 2, nil, 60, 0, 0},
    [16080] = {4270, 2, 64, 100, 0, 0},
    [16081] = {359, 2, 64, 100, 0, 0},
    [16082] = {306, 2, 64, 100, 0, 0},
    [16083] = {305, 2, 64, 100, 0, 0},
    [16084] = {7704, 2, 64, 100, 0, 0},
    [17229] = {11021, 2, 4, 100, 0, 0},
    [17450] = {7706, 2, 64, 100, 0, 0},
    [17453] = {11147, 2, 0, 60, 0, 0},
    [17454] = {10180, 2, 0, 60, 0, 0},
    [17455] = {11148, 2, nil, 60, 0, 0},
    [17456] = {11149, 2, nil, 60, 0, 0},
    [17458] = {10178, 2, nil, 60, 0, 0},
    [17459] = {11150, 2, 64, 100, 0, 0},
    [17460] = {4778, 2, 64, 100, 0, 0},
    [17461] = {4780, 2, 64, 100, 0, 0},
    [17462] = {11153, 2, 0, 60, 0, 0},
    [17463] = {11154, 2, 0, 60, 0, 0},
    [17464] = {11155, 2, 0, 60, 0, 0},
    [17465] = {11156, 2, 0, 100, 0, 0},
    [17481] = {30542, 2, 0, 100, 0, 0},
    [18363] = {11689, 2, 64, 60, 0, 0},
    [18989] = {12149, 2, 0, 60, 0, 0},
    [18990] = {11689, 2, 0, 60, 0, 0},
    [18991] = {12151, 2, 64, 100, 0, 0},
    [18992] = {12148, 2, 64, 100, 0, 0},
    [22717] = {14332, 2, 0, 100, 0, 0},
    [22718] = {14333, 2, 0, 100, 0, 0},
    [22719] = {14334, 2, 0, 100, 0, 0},
    [22720] = {14335, 2, 0, 100, 0, 0},
    [22721] = {14330, 2, 0, 100, 0, 0},
    [22722] = {14331, 2, 0, 100, 0, 0},
    [22723] = {14336, 2, 0, 100, 0, 0},
    [22724] = {14329, 2, 0, 100, 0, 0},
    [23161] = {14505, 2, 0, 100, 0, 0},
    [23214] = {14565, 2, 4, 100, 0, 0},
    [23219] = {14555, 2, 0, 100, 0, 0},
    [23220] = {14557, 2, nil, 100, 0, 0},
    [23221] = {14556, 2, 0, 100, 0, 0},
    [23222] = {14551, 2, 0, 100, 0, 0},
    [23223] = {14552, 2, 0, 100, 0, 0},
    [23225] = {14553, 2, 0, 100, 0, 0},
    [23227] = {14559, 2, 0, 100, 0, 0},
    [23228] = {14560, 2, 0, 100, 0, 0},
    [23229] = {14561, 2, 0, 100, 0, 0},
    [23238] = {14546, 2, 0, 100, 0, 0},
    [23239] = {14548, 2, 0, 100, 0, 0},
    [23240] = {14547, 2, 0, 100, 0, 0},
    [23241] = {14545, 2, 0, 100, 0, 0},
    [23242] = {14543, 2, 0, 100, 0, 0},
    [23243] = {14544, 2, 0, 100, 0, 0},
    [23246] = {14558, 2, 0, 100, 0, 0},
    [23247] = {14542, 2, 0, 100, 0, 0},
    [23248] = {14550, 2, 0, 100, 0, 0},
    [23249] = {14549, 2, 0, 100, 0, 0},
    [23250] = {14540, 2, 0, 100, 0, 0},
    [23251] = {14539, 2, 0, 100, 0, 0},
    [23252] = {14541, 2, 0, 100, 0, 0},
    [23338] = {14602, 2, 0, 100, 0, 0},
    [23509] = {14744, 2, 4, 100, 0, 0},
    [23510] = {14745, 2, 4, 100, 0, 0},
    [24242] = {15090, 2, 0, 100, 0, 0},
    [24252] = {15104, 2, 0, 100, 0, 0},
    [24576] = {18768, 0, nil, 100, 0, 0},
    [25675] = {15524, 0, nil, 60, 0, 0},
    [25858] = {15665, 0, nil, 60, 0, 0},
    [25859] = {15665, 2, nil, 100, 0, 0},
    [25863] = {15711, 2, 64, 100, 0, 0},
    [25953] = {15666, 2, 0, 100, 0, 0},
    [26054] = {15716, 2, 0, 100, 0, 0},
    [26055] = {15714, 2, 0, 100, 0, 0},
    [26056] = {15715, 2, 0, 100, 0, 0},
    [26332] = {15778, 2, nil, 0, 0, 0},
    [26655] = {15711, 2, 64, 100, 0, 0},
    [26656] = {15711, 2, 0, 100, 0, 0},
    [28828] = {16597, 0, 192, 0, 300, 0},
    [29059] = {11195, 2, nil, 100, 0, 0},
    [30174] = {17266, 2, 2192, 0, 0, 0},
    [30829] = {17643, 0, nil, 100, 0, 0},
    [30837] = {14565, 0, nil, 100, 0, 0},
    [31700] = {32568, 0, nil, 0, 280, 0},
    [31973] = {17643, 0, nil, 100, 0, 0},
    [32235] = {18360, 1, 132, 60, 150, 0},
    [32239] = {18357, 1, 132, 60, 150, 0},
    [32240] = {18359, 1, 132, 60, 150, 0},
    [32242] = {18406, 1, 132, 100, 280, 0},
    [32243] = {18363, 1, 132, 60, 150, 0},
    [32244] = {18364, 1, 132, 60, 150, 0},
    [32245] = {18365, 1, 132, 60, 150, 0},
    [32246] = {18377, 1, 132, 100, 280, 0},
    [32289] = {18376, 1, 132, 100, 280, 0},
    [32290] = {18375, 1, 132, 100, 280, 0},
    [32292] = {18362, 1, 132, 100, 280, 0},
    [32295] = {18378, 1, 132, 100, 280, 0},
    [32296] = {18380, 1, 132, 100, 280, 0},
    [32297] = {18379, 1, 132, 100, 280, 0},
    [32345] = {18545, 1, nil, 100, 310, 0},
    [32420] = {18474, 0, nil, 60, 0, 133},
    [33630] = {7749, 2, 64, 60, 0, 0},
    [33631] = {7749, 2, nil, -10, 0, 0},
    [33660] = {19281, 2, 0, 100, 0, 0},
    [34068] = {2188, 0, nil, 0, 0, 400},
    [34406] = {19658, 2, 0, 60, 0, 0},
    [34407] = {19659, 2, nil, 100, 0, 0},
    [34767] = {20030, 2, 4, 100, 0, 0},
    [34769] = {20029, 2, 4, 60, 0, 0},
    [34790] = {20149, 2, 0, 100, 0, 0},
    [34795] = {19280, 2, 0, 60, 0, 0},
    [34896] = {20072, 2, 0, 100, 0, 0},
    [34897] = {20151, 2, 0, 100, 0, 0},
    [34898] = {20152, 2, 0, 100, 0, 0},
    [34899] = {20150, 2, 0, 100, 0, 0},
    [35018] = {20217, 2, 0, 60, 0, 0},
    [35020] = {20220, 2, 0, 60, 0, 0},
    [35022] = {20222, 2, 0, 60, 0, 0},
    [35025] = {20224, 2, 0, 100, 0, 0},
    [35027] = {20223, 2, 0, 100, 0, 0},
    [35028] = {20225, 2, 0, 100, 0, 0},
    [35710] = {20846, 2, 0, 60, 0, 0},
    [35711] = {20847, 2, 0, 60, 0, 0},
    [35712] = {20849, 2, 0, 100, 0, 0},
    [35713] = {20848, 2, 0, 100, 0, 0},
    [35714] = {20850, 2, 0, 100, 0, 0},
    [36702] = {21354, 2, 0, 100, 0, 0},
    [37015] = {21510, 1, 192, 100, 310, 0},
    [39315] = {22510, 2, 0, 100, 0, 0},
    [39316] = {22511, 2, 0, 100, 0, 0},
    [39317] = {22512, 2, 0, 100, 0, 0},
    [39318] = {22513, 2, 0, 100, 0, 0},
    [39319] = {22514, 2, 0, 100, 0, 0},
    [39450] = {7712, 0, nil, 100, 0, 0},
    [39798] = {22958, 1, 0, 100, 280, 0},
    [39800] = {22976, 1, 0, 100, 280, 0},
    [39801] = {22975, 1, 0, 100, 280, 0},
    [39802] = {22977, 1, 0, 100, 280, 0},
    [39803] = {22978, 1, 128, 100, 280, 0},
    [39910] = {22512, 0, nil, 100, 0, 0},
    [39949] = {284, 1, nil, 100, 280, 0},
    [40192] = {18545, 1, 128, 100, 310, 0},
    [40212] = {16597, 1, nil, 100, 280, 0},
    [41252] = {23408, 2, 0, 100, 0, 0},
    [41513] = {23455, 1, 128, 100, 280, 0},
    [41514] = {23456, 1, 128, 100, 280, 0},
    [41515] = {23460, 1, 128, 100, 280, 0},
    [41516] = {23458, 1, 128, 100, 280, 0},
    [41517] = {23457, 1, 128, 100, 280, 0},
    [41518] = {23459, 1, 128, 100, 280, 0},
    [42363] = {23756, 2, nil, 0, 0, 0},
    [42387] = {23756, 2, nil, 0, 0, 0},
    [42667] = {23952, 1, nil, 60, 150, 0},
    [42668] = {30305, 1, nil, 100, 280, 0},
    [42680] = {23966, 2, nil, 60, 0, 0},
    [42683] = {23966, 2, nil, 100, 0, 0},
    [42692] = {23966, 2, nil, 0, 0, 0},
    [42776] = {24003, 2, 64, 60, 0, 0},
    [42777] = {24004, 2, 64, 100, 0, 0},
    [42929] = {21635, 0, nil, 60, 0, 0},
    [43688] = {24379, 2, 64, 100, 0, 0},
    [43810] = {24447, 0, nil, 100, 280, 0},
    [43880] = {24463, 0, nil, 0, 0, 0},
    [43883] = {24462, 0, nil, 0, 0, 0},
    [43899] = {23588, 2, 64, 60, 0, 0},
    [43900] = {24368, 2, 0, 100, 0, 0},
    [43927] = {24488, 1, 128, 100, 280, 0},
    [44151] = {24654, 1, 128, 100, 280, 0},
    [44153] = {24653, 1, 128, 60, 150, 0},
    [44317] = {21510, 1, 192, 100, 310, 0},
    [44655] = {24906, 1, nil, 60, 280, 0},
    [44744] = {24743, 1, 192, 100, 310, 0},
    [44824] = {24906, 1, nil, 60, 150, 0},
    [44825] = {24906, 1, nil, 100, 280, 0},
    [44827] = {24906, 1, nil, 100, 310, 0},
    [45177] = {17266, 0, nil, 0, 0, 0},
    [46197] = {26192, 1, 64, 60, 150, 0},
    [46199] = {26164, 1, 64, 100, 280, 0},
    [46628] = {26131, 2, 0, 100, 0, 0},
    [46980] = {26616, 0, nil, 100, 0, 0},
    [47037] = {26439, 0, nil, 100, 0, 0},
    [47977] = {23966, 2, nil, 0, 0, 0},
    [48023] = {27153, 1, nil, 100, 280, 0},
    [48024] = {27153, 2, nil, 100, 0, 0},
    [48025] = {27153, 2, 0, {60, 100}, {150, 280}, 0},
    [48027] = {26439, 2, 0, 100, 0, 0},
    [48778] = {28302, 2, 0, 100, 0, 0},
    [48954] = {27541, 2, 64, 100, 0, 0},
    [49193] = {27637, 1, 192, 100, 310, 0},
    [49322] = {27684, 2, 0, 100, 0, 0},
    [49378] = {27706, 2, 64, 60, 0, 0},
    [49379] = {27707, 2, 0, 100, 0, 0},
    [49908] = {27902, 0, nil, 0, 0, 0},
    [50281] = {27976, 0, nil, 100, 0, 0},
    [50869] = {30507, 2, nil, 60, 0, 0},
    [50870] = {24368, 2, nil, 60, 0, 0},
    [51412] = {28363, 2, 64, 100, 0, 0},
    [51617] = {27153, 1, nil, 60, 150, 0},
    [51621] = {27153, 2, nil, 60, 0, 0},
    [51960] = {28531, 1, nil, 100, 280, 0},
    [54726] = {29582, 1, nil, 60, 150, 0},
    [54727] = {29582, 1, nil, 100, 280, 0},
    [54729] = {29582, 1, 128, 0, 0, 0},
    [54753] = {29596, 2, 0, 100, 0, 0},
    [55164] = {29767, 2, 64, 100, 280, 0},
    [55293] = {24379, 2, nil, 100, 0, 0},
    [55531] = {29929, 2, 4, 100, 0, 0},
    [58615] = {31124, 1, 192, 100, 310, 0},
    [58819] = {14561, 2, nil, 100, 0, 0},
    [58983] = {31319, 2, 0, {60, 100}, 0, 0},
    [58997] = {31319, 2, nil, 60, 0, 0},
    [58999] = {31319, 2, nil, 100, 0, 0},
    [59567] = {31694, 1, 128, 100, 280, 0},
    [59568] = {31695, 1, 128, 100, 280, 0},
    [59569] = {31717, 1, 128, 100, 280, 0},
    [59570] = {31697, 1, 128, 100, 280, 0},
    [59571] = {31698, 1, 128, 100, 280, 0},
    [59572] = {31699, 2, 64, 100, 0, 0},
    [59573] = {31700, 2, nil, 100, 0, 0},
    [59650] = {31778, 1, 128, 100, 280, 0},
    [59785] = {31849, 2, 4, 100, 0, 0},
    [59788] = {31850, 2, 4, 100, 0, 0},
    [59791] = {31851, 2, 4, 100, 0, 0},
    [59793] = {31852, 2, 4, 100, 0, 0},
    [59797] = {31854, 2, 4, 100, 0, 0},
    [59799] = {31855, 2, 4, 100, 0, 0},
    [59802] = {31857, 2, nil, 100, 0, 0},
    [59804] = {31858, 2, nil, 100, 0, 0},
    [59961] = {31902, 1, 128, 100, 280, 0},
    [59976] = {31912, 1, 192, 100, 310, 0},
    [59996] = {32151, 1, 128, 100, 280, 0},
    [60002] = {32153, 1, 128, 100, 280, 0},
    [60021] = {32156, 1, 192, 100, 310, 0},
    [60024] = {32157, 1, 128, 100, 310, 0},
    [60025] = {32158, 1, 128, 100, 280, 0},
    [60114] = {32206, 2, 4, 100, 0, 0},
    [60116] = {32207, 2, 4, 100, 0, 0},
    [60118] = {32203, 2, 4, 100, 0, 0},
    [60119] = {32205, 2, 4, 100, 0, 0},
    [60120] = {32208, 1, nil, 0, 0, 0},
    [60136] = {32212, 0, 64, 100, 0, 0},
    [60140] = {32213, 0, 64, 100, 0, 0},
    [60424] = {32286, 2, 4, 100, 0, 0},
    [61229] = {32335, 1, 132, 100, 280, 0},
    [61230] = {32336, 1, 132, 100, 280, 0},
    [61289] = {23966, 0, nil, 170, 0, 0},
    [61294] = {32562, 1, 128, 100, 280, 0},
    [61309] = {33030, 1, 1024, 100, 280, 0},
    [61425] = {32633, 2, 4, 100, 0, 0},
    [61442] = {32634, 1, nil, 0, 0, 0},
    [61444] = {32635, 1, nil, 0, 0, 0},
    [61446] = {32636, 1, nil, 0, 0, 0},
    [61447] = {32640, 2, 4, 100, 0, 0},
    [61451] = {33029, 1, 1024, 60, 150, 0},
    [61465] = {31862, 2, 4, 100, 0, 0},
    [61467] = {31861, 2, 4, 100, 0, 0},
    [61469] = {31857, 2, 4, 100, 0, 0},
    [61470] = {31858, 2, 4, 100, 0, 0},
    [61983] = {32931, 0, nil, 100, 0, 0},
    [61996] = {31239, 1, 132, 100, 280, 0},
    [61997] = {32944, 1, 132, 100, 280, 0},
    [62048] = {25064, 1, 192, 100, 280, 0},
    [63232] = {33297, 2, 0, 100, 0, 0},
    [63635] = {33299, 2, 0, 100, 0, 0},
    [63636] = {33408, 2, 0, 100, 0, 0},
    [63637] = {33298, 2, 0, 100, 0, 0},
    [63638] = {33301, 2, 0, 100, 0, 0},
    [63639] = {33416, 2, 0, 100, 0, 0},
    [63640] = {33409, 2, 0, 100, 0, 0},
    [63641] = {33300, 2, 0, 100, 0, 0},
    [63642] = {33418, 2, 0, 100, 0, 0},
    [63643] = {33414, 2, 0, 100, 0, 0},
    [63796] = {33848, 1, 128, 100, 310, 0},
    [63844] = {33857, 1, 128, 100, 280, 0},
    [63956] = {33892, 1, 128, 100, 310, 0},
    [63963] = {33904, 1, 128, 100, 310, 0},
    [64656] = {34154, 2, 64, 100, 0, 0},
    [64657] = {34155, 2, 0, 60, 0, 0},
    [64658] = {356, 2, 0, 60, 0, 0},
    [64659] = {34156, 2, 4, 100, 0, 0},
    [64681] = {32198, 1, nil, 60, 150, 0},
    [64731] = {34187, 2, 2192, 0, 0, 60},
    [64761] = {32208, 1, nil, 60, 150, 0},
    [64927] = {34225, 1, 192, 100, 310, 0},
    [64977] = {34238, 2, 0, 60, 0, 0},
    [64992] = {31319, 2, nil, 60, 0, 0},
    [64993] = {31319, 2, nil, 100, 0, 0},
    [65439] = {34425, 1, 192, 100, 310, 0},
    [65637] = {34551, 2, 0, 100, 0, 0},
    [65638] = {34550, 2, 0, 100, 0, 0},
    [65639] = {34556, 2, 0, 100, 0, 0},
    [65640] = {34557, 2, 0, 100, 0, 0},
    [65641] = {34558, 2, 4, 100, 0, 0},
    [65642] = {34553, 2, 0, 100, 0, 0},
    [65643] = {34554, 2, 0, 100, 0, 0},
    [65644] = {34549, 2, 0, 100, 0, 0},
    [65645] = {34552, 2, 0, 100, 0, 0},
    [65646] = {34555, 2, 0, 100, 0, 0},
    [65917] = {34655, 2, 64, 100, 0, 0},
    [66087] = {35147, 1, 132, 100, 280, 0},
    [66088] = {35148, 1, 132, 100, 280, 0},
    [66090] = {33840, 2, 4, 100, 0, 0},
    [66091] = {33841, 2, 4, 100, 0, 0},
    [66122] = {34655, 2, 64, 100, 0, 0},
    [66123] = {34731, 2, 64, 100, 0, 0},
    [66124] = {34732, 2, 64, 100, 0, 0},
    [66846] = {35169, 2, 0, 100, 0, 0},
    [66847] = {35168, 2, 0, 60, 0, 0},
    [66906] = {35179, 2, 0, 100, 0, 0},
    [66907] = {35180, 2, nil, 60, 0, 0},
    [67336] = {35362, 1, 192, 100, 310, 0},
    [67466] = {35445, 2, 0, 100, 0, 0},
    [68056] = {35809, 2, 4, 100, 0, 0},
    [68057] = {35808, 2, 4, 100, 0, 0},
    [68187] = {35876, 2, 4, 100, 0, 0},
    [68188] = {35878, 2, 4, 100, 0, 0},
    [68768] = {36483, 2, nil, 0, 0, 0},
    [68769] = {36484, 2, nil, 0, 0, 0},
    [69395] = {36837, 1, 128, 100, 310, 0},
    [71342] = {38204, 2, 0, {0, 60, 100}, {150, 310}, 0},
    [71343] = {38204, 2, nil, 0, 0, 0},
    [71344] = {38204, 2, nil, 60, 0, 0},
    [71345] = {38204, 2, nil, 100, 0, 0},
    [71346] = {38204, 1, nil, 60, 150, 0},
    [71347] = {38204, 1, nil, 100, 310, 0},
    [71810] = {38361, 1, 192, 100, 310, 0},
    [72281] = {38545, 2, nil, 60, 0, 0},
    [72282] = {38545, 2, nil, 100, 0, 0},
    [72283] = {38545, 1, nil, 60, 150, 0},
    [72284] = {38545, 1, nil, 100, 310, 0},
    [72286] = {38545, 2, 0, {60, 100}, {150, 310}, 0},
    [72807] = {38695, 1, 128, 100, 310, 0},
    [72808] = {38778, 1, 128, 100, 310, 0},
    [73313] = {39046, 2, 0, 100, 0, 0},
    [74854] = {40165, 1, nil, 60, 150, 0},
    [74855] = {40165, 1, nil, 100, 280, 0},
    [74856] = {40165, 1, 192, {60, 100}, {150, 280}, 0},
    [74918] = {40191, 2, 64, 100, 0, 0},
    [75387] = {40426, 2, nil, 0, 0, 0},
    [75596] = {40533, 1, 1024, 100, 280, 0},
    [75614] = {40625, 2, 0, {60, 100}, {150, 280, 310}, 0},
    [75617] = {40625, 1, nil, 60, 150, 0},
    [75618] = {40625, 1, nil, 100, 280, 0},
    [75619] = {40625, 2, nil, 60, 0, 0},
    [75620] = {40625, 2, nil, 100, 0, 0},
    [75957] = {40725, 3, nil, 100, 150, 0},
    [75972] = {40725, 3, nil, 100, 280, 0},
    [75973] = {40725, 3, 0, 0, 0, 0},
    [76153] = {40625, 1, nil, 100, 310, 0},
    [76154] = {40725, 3, nil, 100, 310, 0},
    
    -- TODO: entirely new mounts are missing creature IDs: GetCompanionInfo(PetPaperDollFrameCompanionFrame.mode, selected)
    [348459] = {1, 2, 0, 0, {150, 280}, 0}, -- Reawakened Phase-Hunter
    [372677] = {1, 4, 0, {60, 100}, {150, 280}, 0}, -- Kalu'ak Whalebone Glider
    [394209] = {1, 4, 0, {60, 100}, {150, 280, 310}}, -- Festering Emerald Drake
  }
  
  local function Set(index, value, ...)
    for i = 1, select("#", ...) do
      local info = Addon.mounts[select(i, ...)]
      if info then
        info[index] = value
      end
    end
  end
  
  Set(2, 6, 48025, 71342, 72286, 75614, 372677) -- Flying mounts that have scripted ground version
  
  -- faction shouldn't be needed
  Set(7, 0, 61447, 68188, 16081, 64658, 22722, 22721, 22724, 16084, 18990, 61230, 60119, 64659, 18989, 61467, 65639, 65645, 68056, 17465, 23251, 59788, 59793, 66846, 6654, 8395, 23509, 32243, 32246, 63641, 63643, 6653, 22718, 23243, 32245, 32297, 55531, 63640, 63642, 10796, 32244, 35020, 59797, 60116, 17450, 23250, 32296, 35027, 61469, 61997, 17463, 64977, 65641, 66091, 23241, 63635, 580, 17462, 18991, 23246, 32295, 35028, 65644, 18992, 23242, 23252, 33660, 35018, 35022, 66088, 23248, 23249, 34795, 64657, 65646, 10799, 16080, 17464, 23247, 35025) -- Horde mounts from Wowhead
  Set(7, 1, 16055, 61425, 16056, 60424, 17229, 16083, 458, 32290, 23225, 61470, 68187, 59799, 61996, 6899, 10789, 32240, 59791, 66090, 6898, 8394, 32292, 61465, 65637, 6648, 63638, 470, 63232, 10793, 10873, 16082, 17459, 17460, 22723, 32235, 32239, 48027, 63637, 17454, 22720, 23222, 23239, 32242, 35711, 60114, 472, 10969, 23221, 23240, 23338, 35710, 35714, 66847, 68057, 6777, 17461, 23219, 23227, 32289, 59785, 15779, 22717, 23510, 61229, 63636, 63639, 65638, 65640, 17453, 22719, 23223, 23229, 23238, 34406, 35712, 35713, 65642, 65643, 66087, 23228, 60118) -- Alliance mounts from Wowhead
  
  -- TODO: this only checks if you have skill rank learned that has the capability of reaching the required skill level. doesn't check if you had leveled it that far
  Set(8, function() return IsSpellKnown(51309) end, 61309, 75596) -- Tailoring 425
  Set(8, function() return IsSpellKnown(51309) or IsSpellKnown(26790) or IsSpellKnown(12180) end, 61451) -- Tailoring 300
  Set(8, function() return IsSpellKnown(51306) or IsSpellKnown(30350) end, 44151) -- Engineering 375
  Set(8, function() return IsSpellKnown(51306) or IsSpellKnown(30350) or IsSpellKnown(12656) end, 44153) -- Engineering 300
  Set(8, function() return UnitClassBase"player" == "DEATHKNIGHT" end, 48778, 54729)
  Set(8, function() return UnitClassBase"player" == "PALADIN" end, 73629, 73630, 69820, 69826, 34767, 34769, 13819, 23214, 66906)
  Set(8, function() return UnitClassBase"player" == "WARLOCK" end, 5784, 23161)
  
  
  Addon.aqMounts = setmetatable(Addon:MakeLookupTable({25953, 26054, 26055, 26056}, true), {__index = function() return false end})
  
  
  
  
  
  -- collections log update has made mounts depend on riding skill. 410 speed mounts appear to be not affected
  for id, data in pairs(Addon.mounts) do
    local groundSpeeds, flightSpeeds, swimSpeeds = data[4], data[5], data[6]
    
    if id == 61451 then
      print(flightSpeeds)
    end
    
    if flightSpeeds == 150 then
      flightSpeeds = {150, 280}
    elseif type(flightSpeeds) == "table" then
      for i, speed in ipairs(flightSpeeds) do
        if speed == 150 and flightSpeeds[i+1] ~= 280 then
          tinsert(flightSpeeds, i, 280)
          break
        end
      end
    end
    if groundSpeeds == 60 then
      groundSpeeds = {60, 100}
    elseif type(groundSpeeds) == "table" then
      for i, speed in ipairs(groundSpeeds) do
        if speed == 60 and groundSpeeds[i+1] ~= 100 then
          tinsert(groundSpeeds, i, 100)
          break
        end
      end
    end
    data[4] = groundSpeeds
    data[5] = flightSpeeds
    data[6] = swimSpeeds
  end
  
  
  
  
end



--  ██████╗ ███████╗ █████╗  ██████╗ ███████╗███╗   ██╗████████╗███████╗
--  ██╔══██╗██╔════╝██╔══██╗██╔════╝ ██╔════╝████╗  ██║╚══██╔══╝██╔════╝
--  ██████╔╝█████╗  ███████║██║  ███╗█████╗  ██╔██╗ ██║   ██║   ███████╗
--  ██╔══██╗██╔══╝  ██╔══██║██║   ██║██╔══╝  ██║╚██╗██║   ██║   ╚════██║
--  ██║  ██║███████╗██║  ██║╚██████╔╝███████╗██║ ╚████║   ██║   ███████║
--  ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝

do
  Addon.companionReagents = {
    [26045] = 17202, -- Tiny Snowman
    [26529] = 17202, -- Winter Reindeer
    [26533] = 17202, -- Father Winter's Helper
    [26541] = 17202, -- Winter's Little Helper
  }
end





