
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)




local tinsert   = table.insert
local tblConcat = table.concat









local conditionalMeta = {
  __index = {
    Add = function(self, ...)
      for _, v in ipairs{...} do
        tinsert(self.conditions, v)
      end
      return self
    end,
    Copy = function(self)
      return Addon.Conditional(unpack(self.conditions))
    end,
    Wipe = function(self)
      wipe(self.conditions)
      return self
    end,
  },
  __tostring = function(self)
    return "[" .. tblConcat(self.conditions, ",") .. "]"
  end
}

function Addon.Conditional(...)
  return setmetatable({conditions = {...}}, conditionalMeta)
end


local conditionalsMeta = {
  __index = {
    Add = function(self, ...)
      for _, v in ipairs{...} do
        tinsert(self.conditionals, v)
      end
      return self
    end,
    Wipe = function(self)
      wipe(self.conditionals)
      return self
    end,
  },
  __tostring = function(self)
    local str = ""
    for _, v in ipairs(self.conditionals) do
      str = str .. tostring(v)
    end
    return str
  end
}

function Addon.Conditionals(...)
  return setmetatable({conditionals = {...}}, conditionalsMeta)
end


local LineMeta = {
  __index = {
    Add = function(self, ...)
      local action = ""
      for _, v in ipairs{...} do
        action = action .. tostring(v)
      end
      tinsert(self.actions, action)
      return self
    end,
    Wipe = function(self)
      wipe(self.actions)
      return self
    end,
    IsComplete = function(self)
      return self.command and #self.actions > 0 and true or false
    end
  },
  __tostring = function(self)
    if self:IsComplete() then
      local line = "/" .. self.command .. " "
      for i, v in ipairs(self.actions) do
        if i ~= 1 then
          line = line .. ";"
        end
        line = line .. v
      end
      return line
    end
  end
}

function Addon.Line(command, ...)
  local actions
  if #{...} > 0 then
    actions = tblConcat({...}, "")
  end
  return setmetatable({command = command, actions = {actions}}, LineMeta)
end


local MacroMeta = {
  __index = {
    AddLine = function(self, line)
      line = tostring(line)
      if line then
        tinsert(self.lines, line)
        self.needsUpdate = true
        -- self.text = self.text .. (self.text == "" and "" or "\n") .. line
      end
      return self
    end,
    
    AddDruidLine = Addon.MY_CLASS_FILENAME == "DRUID" and function(self, ...)
      return self:AddLine(...)
    end or nop,
    
    GetLines = function(self)
      return self.lines
    end,
    
    GetLength = function(self)
      return #tostring(self)
    end,
    
    Apply = function(self, parent)
      Addon:BindMacro(parent, self)
      return self
    end,
  },
  __tostring = function(self)
    if self.needsUpdate then
      self.text = tblConcat(self.lines, "\n")
      self.needsUpdate = false
    end
    return self.text
  end
}

function Addon.MacroText()
  return setmetatable({lines = {}, text = "", needsUpdate = false}, MacroMeta)
end





