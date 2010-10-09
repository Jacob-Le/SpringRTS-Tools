-- $Id: mission_runner.lua 3171 2008-11-06 09:06:29Z det $
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
  return {
    name      = "Mission Runner",
    desc      = "Runs missions built with the mission editor",
    author    = "quantum",
    date      = "Sept 03, 2008",
    license   = "GPL v2 or later",
    layer     = 0,
    enabled   = true --  loaded by default?
  }
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- SYNCED
--
if (gadgetHandler:IsSyncedCode()) then 
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local mission = VFS.Include"mission.lua"
local triggers = mission.triggers -- array
local allTriggers = {unpack(triggers)} -- we'll never remove triggers from here, so the indices will stay correct
local unitGroups = {} -- key: unitID, value: group array
local gaiaTeamID = Spring.GetGaiaTeamID()
local cheatingWasEnabled = false
local scoreSent = false
local score = 0
local gameStarted = false
local events = {} -- key: frame, value: event array
local counters = {} -- key: name, value: count
local countdowns = {} -- key: name, value: frame
local displayedCountdowns = {} -- key: name
local allowTransfer = false

for _, counter in ipairs(mission.counters) do
  counters[counter] = 0
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- overrules the transfer prohibition
local function SpecialTransferUnit(...)
  allowTransfer = true
  Spring.TransferUnit(...)
  allowTransfer = false
end

local function FindFirstLogic(logicType)
  for _, trigger in ipairs(triggers) do
    for _, logicItem in ipairs(trigger.logic) do
      if logicItem.logicType == logicType then
        return logicItem, trigger
      end
    end
  end
end

local function FindAllLogic(logicType)
  local logicItems = {}
  for _, trigger in ipairs(triggers) do
    for _, logicItem in ipairs(trigger.logic) do
      if logicItem.logicType == logicType then
        logicItems[logicItem] = trigger
      end
    end
  end
  return logicItems
end


local function ArraysHaveIntersection(array1, array2)
  for _, item1 in ipairs(array1) do
    for _, item2 in ipairs(array2) do
      if item1 == item2 then return true end
    end
  end
  return false
end


local function RemoveTrigger(trigger)
  for i=1, #triggers do
    if triggers[i] == trigger then
      table.remove(triggers, i)
      break
    end
  end
end


local function ArrayContains(array, item)
  for i=1, #array do
    if item == array[i] then return true end
  end
  return false
end

local function FindUnitsInGroups(searchGroups)
  local results = {}
  for unitID, groups in pairs(unitGroups) do
    if ArraysHaveIntersection(groups, searchGroups) then
      table.insert(results, unitID)
    end
  end
  return results
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

for _, trigger in pairs(triggers) do
  trigger.occurrences = trigger.occurrences or 0
  if trigger.maxOccurrences < 0 then
    trigger.maxOccurrences = math.huge
  elseif trigger.maxOccurrences == 0 then
    RemoveTrigger(trigger)
  end
end

for condition in pairs(FindAllLogic"TimeCondition") do
  condition.args.period = condition.args.frames
end

for condition in pairs(FindAllLogic"UnitCreatedCondition") do
  condition.args.unitDefIDs = {}
  for _, unitName in ipairs(condition.args.units) do
    condition.args.unitDefIDs[UnitDefNames[unitName].id] = true
  end
end

for condition in pairs(FindAllLogic"UnitFinishedCondition") do
  condition.args.unitDefIDs = {}
  for _, unitName in ipairs(condition.args.units) do
    condition.args.unitDefIDs[UnitDefNames[unitName].id] = true
  end
end

local disabledUnitDefIDs = {}
for _, disabledUnitName in ipairs(mission.disabledUnits) do
  disabledUnitDefIDs[UnitDefNames[disabledUnitName].id] = true
end

local function SetCount(set)
  local count = 0
  for _ in pairs(set) do
    count = count + 1
  end
  return count
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function UpdateDisabledUnits(unitID)
  local unitDefID = Spring.GetUnitDefID(unitID)
  for _, buildID in ipairs(UnitDefs[unitDefID].buildOptions) do
    local cmdDescID = Spring.FindUnitCmdDesc(unitID, -buildID)
    if cmdDescID then
      Spring.EditUnitCmdDesc(unitID, cmdDescID, {disabled = disabledUnitDefIDs[buildID] or false})
    end
  end
end


local function UpdateAllDisabledUnits()
  for _, unitID in ipairs(Spring.GetAllUnits()) do
    UpdateDisabledUnits(unitID)
  end
end

local function AddEvent(frame, event)
  events[frame] = events[frame] or {}
  table.insert(events[frame], event)
end


local function CustomConditionMet(name)
  for _, trigger in ipairs(triggers) do
    for _, condition in ipairs(trigger.logic) do
      if condition.logicType == "CustomCondition" and trigger.name == name then
        ExecuteTrigger(trigger)
        break
      end
    end
  end
end


local function ExecuteTrigger(trigger, frame)
  if not trigger.enabled then return end
  if math.random() < trigger.probability then
    local createdUnits = {}
    local frame = frame or (Spring.GetGameFrame() + 1) -- events will take place at this frame
    for _, action in ipairs(trigger.logic) do
      local Event
      if action.logicType == "CustomAction" then
        Event = function()
          if action.name == "my custom action name" then
            -- fill in your custom actions
          end
        end
      elseif action.logicType == "DestroyUnitsAction" then
        Event = function()
          for _, unitID in ipairs(FindUnitsInGroups{action.args.group}) do
            Spring.DestroyUnit(unitID, true, not action.args.explode)
          end
        end
      elseif action.logicType == "ExecuteTriggersAction" then
        Event = function()
          for _, triggerIndex in ipairs(action.args.triggers) do
              ExecuteTrigger(allTriggers[triggerIndex])
          end
        end
      elseif action.logicType == "TransferUnitsAction" then
        Event = function()
          for _, unitID in ipairs(FindUnitsInGroups{action.args.group}) do
            SpecialTransferUnit(unitID, action.args.player, false)
          end
        end
      elseif action.logicType == "ModifyResourcesAction" then
        Event = function()
          local category = action.args.category == "metal" and "m" or "e"
          Spring.AddTeamResource(action.args.player, category, action.args.amount)
        end
      elseif action.logicType == "ModifyUnitHealthAction" then
        Event = function()
          for _, unitID in ipairs(FindUnitsInGroups{action.args.group}) do
            Spring.AddUnitDamage(unitID, action.args.damage)
          end
        end
      elseif action.logicType == "MakeUnitsAlwaysVisibleAction" then
        Event = function()
          for _, unitID in ipairs(FindUnitsInGroups{action.args.group}) do
            Spring.SetUnitAlwaysVisible(unitID, true)
          end
        end
      elseif action.logicType == "ModifyCounterAction" then
        Event = function()
          local counter = action.args.counter
          local value = action.args.value
          local n = counters[counter]
          if action.args.action == "Increase" then
             counters[counter] = n + value
          elseif action.args.action == "Reduce" then
             counters[counter] = n - value
          elseif action.args.action == "Set" then
             counters[counter] = value
          elseif action.args.action == "Multiply" then
             counters[counter] = n * value
          end
          for _, trigger in ipairs(triggers) do
            for _, condition in ipairs(trigger.logic) do
              if condition.logicType == "CounterModifiedCondition" then
                local c = condition.args.condition
                local v = condition.args.value
                local n = counters[condition.args.counter]
                if (c == "=" and n == v) or
                   (c == "<" and n < v) or
                   (c == ">" and n > v) or
                   (c == "<=" and n <= v) or 
                   (c == ">=" and n >= v) or
                   (c == "!=" and n ~= v) then
                  ExecuteTrigger(trigger)
                  break
                end
              end
            end
          end
        end
      elseif action.logicType == "DisplayCountersAction" then
        Event = function()
          for counter, value in pairs(counters) do
            Spring.Echo(string.format("Counter %s: %f", counter, value))
          end
        end
      elseif action.logicType == "ModifyScoreAction" then
        Event = function()
          if action.args.action == "Increase Score" then
            score = score + action.args.value
          elseif action.args.action == "Reduce Score" then
            score = score - action.args.value
          elseif action.args.action == "Set Score" then
            score = action.args.value
          elseif action.args.action == "Multiply Score" then
            score = score * action.args.value
          end
          Spring.SetGameRulesParam("score", score)
        end
      elseif action.logicType == "EnableTriggersAction" then
        Event = function()
          for _, triggerIndex in ipairs(action.args.triggers) do
              allTriggers[triggerIndex].enabled = true
          end
        end
      elseif action.logicType == "DisableTriggersAction" then
        Event = function()
          for _, triggerIndex in ipairs(action.args.triggers) do
            allTriggers[triggerIndex].enabled = false
          end
        end
      elseif action.logicType == "WaitAction" then
        frame = frame + action.args.frames
      elseif action.logicType == "StartCountdownAction" then
        Event = function()
          local expiry = Spring.GetGameFrame() + action.args.frames
          countdowns[action.args.countdown] = expiry
          if action.args.display then
            displayedCountdowns[action.args.countdown] = true
            Spring.SetGameRulesParam("countdown:"..action.args.countdown, expiry)
          end
        end
      elseif action.logicType == "CancelCountdownAction" then
        Event = function()
          countdowns[action.args.countdown] = nil
          displayedCountdowns[action.args.countdown] = nil
          Spring.SetGameRulesParam("countdown:"..action.args.countdown, "-1")
        end
      elseif action.logicType == "ModifyCountdownAction" then
        Event = function()
          if countdowns[action.args.countdown] then
            local newExpiry
            if action.args.action == "Extend" then
              newExpiry = countdowns[action.args.countdown] + action.args.frames
            elseif action.args.action == "Anticipate" then
              newExpiry = countdowns[action.args.countdown] - action.args.frames
            else
              error"countdown modify mode not supported"
            end
            if newExpiry < Spring.GetGameFrame() then -- execute immediatly
              countdowns[action.args.countdown] = nil
              displayedCountdowns[action.args.countdown] = nil
              Spring.SetGameRulesParam("countdown:"..action.args.countdown, "-1")
              for _, trigger in ipairs(triggers) do
                for _, condition in ipairs(trigger.logic) do
                  if condition.logicType == "CountdownEndedCondition" and
                     condition.args.countdown == action.args.countdown then
                    ExecuteTrigger(trigger)
                    break
                  end
                end
              end
            else -- change expiry time
              countdowns[action.args.countdown] = newExpiry
              if displayedCountdowns[action.args.countdown] then
                Spring.SetGameRulesParam("countdown:"..action.args.countdown, newExpiry)
              end
            end
          end
          -- todo: execute trigger if countdown has expired! print Spring.Echo
        end
      elseif action.logicType == "CreateUnitsAction" then
        Event = function()
          for _, unit in ipairs(action.args.units) do
            local ud =  UnitDefNames[unit.unitDefName]
            local isBuilding = ud.isBuilding or ud.isFactory or not ud.canMove
            local cardinalHeading = "n"
            if isBuilding then
              if unit.heading > 45 and unit.heading <= 135 then
                cardinalHeading = "e"
              elseif unit.heading > 135 and unit.heading <= 225 then
                cardinalHeading = "s"
              elseif unit.heading > 225 and unit.heading <- 315 then
                cardinalHeading = "w"
              end
            end
            local unitID = Spring.CreateUnit(unit.unitDefName, unit.x, 0, unit.y, "n", unit.player)
            if unitID then
              if not isBuilding then
                Spring.SetUnitRotation(unitID, 0, (unit.heading - 180)/360 * 2 * math.pi, 0)
              end
              table.insert(createdUnits, unitID)
              if unit.groups and next(unit.groups) then
                unitGroups[unitID] = unit.groups
              end
            end
          end
        end
      elseif action.logicType == "ConsoleMessageAction" then
        Event = function()
          Spring.SendMessage(action.args.message)
        end
      elseif action.logicType == "DefeatAction" then
        Event = function()
          for _, unitID in ipairs(Spring.GetTeamUnits(mission.startPlayer)) do
            SpecialTransferUnit(unitID, gaiaTeamID, false)
          end
        end
      elseif action.logicType == "VictoryAction" then
        Event = function()
          for _, unitID in ipairs(Spring.GetAllUnits()) do
            if Spring.GetUnitTeam(unitID) ~= mission.startPlayer then
              SpecialTransferUnit(unitID, gaiaTeamID, false)
            end
          end
        end
      elseif action.logicType == "LockUnitsAction" then
        Event = function()
          for _, disabledUnitName in ipairs(action.args.units) do
            local disabledUnit = UnitDefNames[disabledUnitName]
            if disabledUnit then
              disabledUnitDefIDs[disabledUnit.id] = true
            end
          end
          UpdateAllDisabledUnits()
        end
      elseif action.logicType == "UnlockUnitsAction" then
        Event = function()
          for _, disabledUnitName in ipairs(action.args.units) do
            local disabledUnit = UnitDefNames[disabledUnitName]
            if disabledUnit then
              disabledUnitDefIDs[disabledUnit.id] = nil
            end
          end
          UpdateAllDisabledUnits()
        end
      elseif action.logicType == "PauseAction" or
             action.logicType == "MarkerPointAction" or 
             action.logicType == "SetCameraPointTargetAction" or 
             action.logicType == "GuiMessageAction" or
             action.logicType == "SoundAction" or 
             action.logicType == "SunriseAction" or 
             action.logicType == "SunsetAction" then
        Event = function()
          action.args.logicType = action.logicType
          _G.missionEventArgs = action.args
          SendToUnsynced"MissionEvent"
          _G.missionEventArgs = nil
        end
      elseif action.logicType == "GiveOrdersAction" then
        Event = function()
          local orderedUnits
          if #action.args.groups == 0 then
            orderedUnits = createdUnits
          else
            orderedUnits = FindUnitsInGroups(action.args.groups)
          end
          for _, unitID in ipairs(orderedUnits) do
            for _, order in ipairs(action.args.orders) do
              -- bug workaround: the table needs to be copied before it's used in GiveOrderToUnit
              local x, y, z = order.args[1], order.args[2], order.args[3] 
              Spring.GiveOrderToUnit(unitID, CMD[order.orderType], {x, y, z}, {"shift"})
            end
          end
        end
      elseif action.logicType == "SendScoreAction" then
        Event = function()
          if not (cheatingWasEnabled or scoreSent) then
            Spring.Echo("ID: "..GG.Base64Encode(tostring(math.floor(score))))
            scoreSent = true
          end
        end
      elseif action.logicType == "SetCameraUnitTargetAction" then
        Event = function()
          for unitID, groups in pairs(unitGroups) do
            if ArrayContains(groups, action.args.group) then
              local x, _, y = Spring.GetUnitPosition(unitID)
              local args = {
                x = x,
                y = y,
                logicType = "SetCameraPointTargetAction",
              }
              _G.missionEventArgs = args
              SendToUnsynced"MissionEvent"
              _G.missionEventArgs = nil
            end
          end
        end
      end
      if Event then
        AddEvent(frame, Event) -- schedule event
      end
    end
  end
  trigger.occurrences = trigger.occurrences + 1
  if trigger.maxOccurrences == trigger.occurrences then
    RemoveTrigger(trigger) -- the trigger is no longer needed
  end
end


local function CheckUnitsEnteredGroups(unitID, condition)
  if #condition.args.groups == 0 then return true end -- no group selected: any unit is ok
  if not unitGroups[unitID] then return false end -- group is required but unit has no group
  if ArraysHaveIntersection(condition.args.groups, unitGroups[unitID]) then return true end -- unit has one of the required groups
  return false
end


local function CheckUnitsEnteredPlayer(unitID, condition)
  if #condition.args.players == 0 then return true end -- no player is required: any is ok
  return ArrayContains(condition.args.players, Spring.GetUnitTeam(unitID)) -- unit is is owned by one of the selected players
end


local function CheckUnitsEntered(units, condition)
  local count = 0
  for _, unitID in ipairs(units) do
    if CheckUnitsEnteredGroups(unitID, condition) and 
       CheckUnitsEnteredPlayer(unitID, condition) then
      count = count + 1
    end
  end
  return count >= condition.args.number
end


local function StartsWith(s, startString)
  return string.sub(s, 1, #startString) == startString
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:UnitDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, 
                            weaponID, attackerID, attackerDefID, attackerTeam)
  for triggerIndex=1, #triggers do
    local trigger = triggers[triggerIndex]
    for conditionIndex=1, #trigger.logic do
      local condition = trigger.logic[conditionIndex]
      if condition.logicType == "UnitDamagedCondition" and
         not paralizer and
         (Spring.GetUnitHealth(unitID) < condition.args.value) and
         (condition.args.anyAttacker or ArrayContains(FindUnitsInGroups{condition.args.attackerGroup}, attackerID)) and
         (condition.args.anyVictim or ArrayContains(FindUnitsInGroups{condition.args.victimGroup}, unitID)) then
        ExecuteTrigger(trigger)
        break
      end
    end
  end
end


function gadget:AllowUnitTransfer(unitID, unitDefID, oldTeam, newTeam, capture)
  return allowTransfer
end


function gadget:GameFrame(n)
  if not gameStarted then
    -- start with a clean slate
    for _, unitID in ipairs(Spring.GetAllUnits()) do
      if Spring.GetUnitTeam(unitID) ~= gaiaTeamID then
        Spring.DestroyUnit(unitID, false, true)
      end
    end
    for _, trigger in ipairs(triggers) do
      for _, condition in ipairs(trigger.logic) do
        if condition.logicType == "GameStartedCondition" then
          ExecuteTrigger(trigger, n)
        end
      end
    end
    gameStarted = true
  end
  
  
  if events[n] then -- list of events to run at this frame
    for _, Event in ipairs(events[n]) do
      Event(n) -- run event
    end
    events[n] = nil
  end
  
  for countdown, expiry in pairs(countdowns) do
    if n == expiry then
      countdowns[countdown] = nil
      displayedCountdowns[countdown] = nil
      for _, trigger in ipairs(triggers) do
        for _, condition in ipairs(trigger.logic) do
          if condition.logicType == "CountdownEndedCondition" and
             condition.args.countdown == countdown then
            ExecuteTrigger(trigger)
            break
          end
        end
      end
    end
    for _, trigger in ipairs(triggers) do
      for _, condition in ipairs(trigger.logic) do
        if condition.logicType == "CountdownTickCondition" and
           condition.args.countdown == countdown and 
           (expiry - n) % condition.args.frames == 0 then
          ExecuteTrigger(trigger)
          break
        end
        if condition.logicType == "TimeLeftInCountdownCondition" and
           condition.args.countdown == countdown and 
           (expiry - n) < condition.args.frames then
          ExecuteTrigger(trigger)
          break
        end
      end
    end
  end
  
  
  for _, trigger in pairs(triggers) do
    for _, condition in ipairs(trigger.logic) do
      local args = condition.args
      if condition.logicType == "TimeCondition" and args.frames == n then 
        args.frames = n + args.period
        -- gadgets still skip frames sometimes? todo: check
        ExecuteTrigger(trigger)
        break
      end
    end
  end
  
  if Spring.IsCheatingEnabled() then
    if not cheatingWasEnabled then
      cheatingWasEnabled = true
      Spring.Echo "The score will not be saved."
    end
  end
  
  if (n+3)%30 == 0 then
    for _, trigger in pairs(triggers) do
      for _, condition in ipairs(trigger.logic) do
        if condition.logicType == "UnitsAreInAreaCondition" then
          local areas = condition.args.areas
          for _, area in ipairs(areas) do
            local units
            if area.category == "cylinder" then
              units = Spring.GetUnitsInCylinder(area.x, area.y, area.r)
            elseif area.category == "rectangle" then
              units = Spring.GetUnitsInRectangle(area.x, area.y, area.x + area.width, area.y + area.height)
            else
              error "area category not supported"
            end
            if CheckUnitsEntered(units, condition) then
              ExecuteTrigger(trigger)
              break
            end
          end
        end
      end
    end
  end
end


function gadget:TeamDied(teamID)
  for _, trigger in ipairs(triggers) do
    for _, condition in ipairs(trigger.logic) do
      if condition.logicType == "PlayerDiedCondition" and condition.args.playerNumber == teamID then
        ExecuteTrigger(trigger)
        break
      end
    end
  end
end


function gadget:UnitDestroyed(unitID)
  if unitGroups[unitID] then
    for _, trigger in ipairs(triggers) do
      for _, condition in ipairs(trigger.logic) do
        if condition.logicType == "UnitDestroyedCondition" and 
          ArraysHaveIntersection(condition.args.groups, unitGroups[unitID]) then
          ExecuteTrigger(trigger)
          break
        end
      end
    end
    unitGroups[unitID] = nil
  end
end


function gadget:UnitFinished(unitID, unitDefID, unitTeam)
  for _, trigger in ipairs(triggers) do
    for _, condition in ipairs(trigger.logic) do
      if condition.logicType == "UnitFinishedCondition" and condition.args.unitDefIDs[unitDefID] then
        if not next(condition.args.players) or ArrayContains(condition.args.players, unitTeam) then
          ExecuteTrigger(trigger)
          break
        end
      end
    end
  end
end

function gadget:UnitCreated(unitID, unitDefID, unitTeam)
  for _, trigger in ipairs(triggers) do
    for _, condition in ipairs(trigger.logic) do
      if condition.logicType == "UnitCreatedCondition" and condition.args.unitDefIDs[unitDefID] then
        if not next(condition.args.players) or ArrayContains(condition.args.players, unitTeam) then
          ExecuteTrigger(trigger)
          break
        end
      end
    end
  end
  UpdateDisabledUnits(unitID)
end



function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
  -- prevent widgets from building disabled units
  if disabledUnitDefIDs[-cmdID] then
    return false
  end
  return true
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- 
-- UNSYNCED
--
else
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function WrapToLuaUI()
  if Script.LuaUI"MissionEvent" then
    local missionEventArgs = {}
    for k, v in spairs(SYNCED.missionEventArgs) do
      missionEventArgs[k] = v
    end
    Script.LuaUI.MissionEvent(missionEventArgs)
  end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:Initialize()
  gadgetHandler:AddSyncAction('MissionEvent', WrapToLuaUI)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
end
