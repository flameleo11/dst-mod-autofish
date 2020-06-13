------------------------------------------------------------
-- base
------------------------------------------------------------

local require = GLOBAL.require
local modinit = require("modinit")
modinit("autofish")

------------------------------------------------------------
-- header
------------------------------------------------------------
require("tprint")

local push = table.insert
local tjoin = table.concat
local trace = print

local easing = require("easing")
local Text = require "widgets/text"
local Widget = require "widgets/widget"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"

this = this or {}
this.key_inited = this.key_inited or {}
this.fishkey = this.fishkey or "J"

this.selected_ents = this.selected_ents or {}
this.color = {x=1,y=1,z=1}

local CFG_FISH_ENABLE = true
local key_fish = "J"
local b_debug = true
local cfg_fadetime = 3;
------------------------------------------------------------
-- utils
------------------------------------------------------------

function show_msg_api(msg, onlyClear)
  -- debug hot reload
  if not (TheFrontEnd and TheFrontEnd.overlayroot) then
    return
  end
  if (b_debug and this.label) then
    TheFrontEnd.overlayroot:RemoveChild(this.label)
    this.label:Hide()
    this.label:Kill()
    this.label = nil
  end

  if (this.update_msg_task) then
    this.update_msg_task:Cancel()
    this.update_msg_task = nil
  end

  if (onlyClear) then
    return
  end

  local label = this.label
  if not (label) then
    label = Text(TALKINGFONT, 32)
    label:Hide()
    label:SetPosition(300, 120, 0)
    if (b_debug) then
      label:SetPosition(300, 240, 0)
    end
    label:SetVAlign(ANCHOR_BOTTOM)
    label:SetHAlign(ANCHOR_LEFT)
    label:SetHAnchor(ANCHOR_LEFT)
    label:SetVAnchor(ANCHOR_BOTTOM)

    this.label = label
    TheFrontEnd.overlayroot:AddChild(label)
  end

  label:SetString(msg)
  label:Show()

  local ontimeover = _f(function (inst)
    inst:Hide()
    this.update_msg_task:Cancel()
    this.update_msg_task = nil
  end)

  this.update_msg_task = ThePlayer:DoTaskInTime(cfg_fadetime,
    function()
      ontimeover(label)
    end,
    0
  )
end

function show_msg(...)
  local arr = {}
  for i,v in ipairs({...}) do
    arr[i] = tostring(v)
  end
  local msg = tjoin(arr, "\n")
  show_msg_api(msg)
  print(msg)
end

function split_by_space(s)
  local arr = {}
  for w in s:gmatch("%S+") do
    arr[#arr+1] = w
  end
  return arr
end

------------------------------------------------------------
-- func
------------------------------------------------------------
function GetHandsItem()
  return ThePlayer.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
end
function GetPackback()
  local inv  = ThePlayer.replica.inventory
  return inv:GetEquippedItem(EQUIPSLOTS.BACK or EQUIPSLOTS.BODY)
end

function GetInvItemByPrefab(name)
  local inv  = ThePlayer.replica.inventory
  for i=1, inv:GetNumSlots() do
    local item = inv:GetItemInSlot(i)
    if item and item.prefab == name then
      return item
    end
  end
  return nil
end

function GetItemInPackByPrefab(name)
  local inv  = ThePlayer.replica.inventory
  local pack = inv:GetEquippedItem(EQUIPSLOTS.BACK or EQUIPSLOTS.BODY)
  if not (pack and pack.replica and pack.replica.container) then
    return nil
  end

  local c = pack.replica.container
  for i=1, c:GetNumSlots() do
    local item = c:GetItemInSlot(i)
    if item and item.prefab == "fishingrod" then
      return item
    end
  end
  return nil
end

function GetPlayerItemByName(name)
  local item = GetInvItemByPrefab(name)
  if not (item) then
    item = GetItemInPackByPrefab(name)
  end
  return item
end

function GetFishingItem()
  local inv  = ThePlayer.replica.inventory
  local item = GetHandsItem()
  -- not in hand, equip it
  if not (item and item.prefab == "fishingrod") then
    item = GetPlayerItemByName("fishingrod")
    if (item) then
      inv:ControllerUseItemOnSelfFromInvTile(item)
    end
  end
  return item
end

------------------------------------------------------------
-- main
------------------------------------------------------------


function FishAPI(target)
  local cl = ThePlayer.components.playercontroller
  local ap = ThePlayer.components.playeractionpicker
  local controlmods = cl:EncodeControlMods()
  local pos = target:GetPosition()
  local lmb, rmb = ap:DoGetMouseActions(pos, target)
  local tips = lmb and lmb:GetActionString() or ""

  print("...111......", lmb, tips)
  if not (lmb) then
    return
  end
  print(".....222....", lmb, tips)
  if not (tips == STRINGS.ACTIONS.REEL.CANCEL) then
    pcl:DoAction(lmb)
  print(".....333....", lmb, tips)
    SendRPCToServer(RPC.LeftClick, lmb.action.code,
      pos.x, pos.z, target, false,
      controlmods, false, lmb.action.mod_get);
  end
end

function DoFish2()
  show_msg("HAHA")
end

-- modget("autofish").import("cmd")

function DoFish()
  print(111, "........DoFish..>>>>>>>")
  if this.fishing_task then
    -- this.fishing_task:SetList(nil)
    -- this.fishing_task = nil
    this.fishing_task:Cancel()
    this.fishing_task = nil

    print(22, "........DoFish..>>>>>>>")
    if (this.fishing_update_task) then
      print(333, "........DoFish..>>>>>>>")
      this.fishing_update_task:Cancel()
      this.fishing_update_task = nil
    else
print(44, "........DoFish..>>>>>>>")
    end
    print(55, "........DoFish..>>>>>>>")
    show_msg("fishing (cancel)")
    return
  end
print(66, "........DoFish..>>>>>>>")

  local pos = ThePlayer:GetPosition()
  ThePlayer.zdpr = pos
  local qmc = ThePlayer.components.playercontroller
  local B   = ThePlayer.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
  local ku  = ThePlayer.replica.inventory

  local fishingItem = GetFishingItem()
  if not (fishingItem) then
    ThePlayer.components.talker:Say("i need a fishingrod")
    return
  end
print(77, "........DoFish..>>>>>>>")
  local radius = 20
  local target = FindEntity(ThePlayer, radius, function(inst)
      return (inst.prefab == "pond"
        or inst.prefab == "pond_mos"
        or inst.prefab == "pond_cave"
        or inst.prefab == "oasislake")
    end,
    nil,
    { "INLIMBO", "noauradamage" }
  )
print(88, "........DoFish..>>>>>>>")
  if not (target) then
    ThePlayer.components.talker:Say("No fishable target !")
    return
  end
print(99, "........DoFish..>>>>>>>")
  show_msg("auto fishing :", fishingItem, target)

  local onFishUpdate = _f(function ()
 print(9922103, "........DoFish..>>>>>>>")
    FishAPI(target)
  end)
print(99111, "........DoFish..>>>>>>>")
  local fishProc = _f(function ()
    print(9922100, "........DoFish..>>>>>>>")
    -- wait for equip
    Sleep(0.3)
print(9922101, "........DoFish..>>>>>>>")
    local dt = 0.1
    this.fishing_update_task = ThePlayer:DoPeriodicTask(dt, function()
      print(9922102, "........DoFish..>>>>>>>")
      onFishUpdate()
    end, 0)
  end)
print(99222, "........DoFish..>>>>>>>")
  -- this.fishing_task = ThePlayer:StartThread(fishProc)
  this.fishing_task = ThePlayer:DoTaskInTime(0, function ()
    fishProc()
  end)


  this.action_thread = StartThread(function()
      self.inst:ClearBufferedAction()
      self.auto_fishing = true
      while self.auto_fishing and self.inst:IsValid() and next(self.selected_ents) do
          for pond in pairs(self.selected_ents) do
              local fishingrod = self:GetEquippedItemInHand() or self:GetNewEquippedItemInHand("fishingrod")
              if not fishingrod or self:GetActiveItem() then self.auto_fishing = false break end
              local pos = pond:GetPosition()
              local fish_act = BufferedAction(self.inst, pond, ACTIONS.FISH, fishingrod, pos)
              while not self.inst:HasTag("nibble") do
                  if not self.inst:HasTag("fishing") and self.inst:HasTag("idle") then
                      self:SendAction(fish_act, false, pond)
                  end
                  Sleep(self.action_delay)
              end
              local catch_act = BufferedAction(self.inst, pond, ACTIONS.REEL, fishingrod, pos)
              self:SendAction(catch_act, false, pond)
              Sleep(self.action_delay)
              self:SendActionAndWait(catch_act, false, pond)
              local fish = FindEntity(self.inst, 2, nil, {"fish"})
              if fish then
                  local pickup_act = BufferedAction(self.inst, fish, ACTIONS.PICKUP, nil, fish:GetPosition())
                  self:SendActionAndWait(pickup_act, false, fish)
              end
          end
      end
      self:ClearActionThread()
      self:ClearSelectedEntities()
  end, action_thread_id)

end

-- modget("autofish").import("cmd")


function IsInGameplay()
  if not ThePlayer then
    return
  end
  if not (TheFrontEnd:GetActiveScreen().name == "HUD") then
    return
  end
  return true
end

function IsDST()
  return TheSim:GetGameID() == "DST"
end

function _AddThePlayerInit(fn)
  if IsDST() then
    AddPrefabPostInit("world", function(wrld)
      wrld:ListenForEvent("playeractivated", function(wlrd, player)
        if player == ThePlayer then
          fn()
        end
      end)
    end)
  else
    AddPlayerPostInit(function(player)
      fn()
    end)
  end
end

function regHotkey(key)
  if (this.key_inited[key]) then
    return
  end
  this.key_inited[key] = true

  local keybind = _G["KEY_"..key]
  TheInput:AddKeyDownHandler(keybind, function()
    onPressKey(key)
  end)
end

------------------------------------------------------------
-- main
------------------------------------------------------------

AddClassPostConstruct("widgets/controls", function(self)
  self.inst:DoTaskInTime(0, function ()

  end)
end)

onThePlayerInit = _f(function ()
  regHotkey(this.fishkey)
end)

onPressKey = _f(function (key)
  show_msg(" in auto fish start .....1111......")
  if not IsInGameplay() then return end
  show_msg(" in auto fish start ......222......")
  if not (this.fishkey == key) then
    return
  end
  show_msg(" in auto fish start ......333......")

  DoFish()

end)


onChatCommand = _f(function (params, caller)
  local args = {}
  if (params and params.rest and #params.rest > 0) then
    args = split_by_space(params.rest)
  end

  if (#args == 0) then
    onPressKey(this.fishkey)
    return
  end

  local key = args[1] or "J"
  this.fishkey = string.upper(key)
  regHotkey(this.fishkey)
  show_msg("Autofish key: "..key)

end)

AddUserCommand("torch", {
  prettyget = nil, --default to STRINGS.UI.BUILTINCOMMANDS.BUG.PRETTY
  desc = nil, --default to STRINGS.UI.BUILTINCOMMANDS.BUG.DESC
  permission = COMMAND_PERMISSION.USER,
  slash = false,
  usermenu = false,
  servermenu = false,
  params = {},
  vote = false,
  localfn = function(params, caller)
    onChatCommand(params, caller)
  end,
})

tprint(this.key_inited)




_AddThePlayerInit(function ()
  onThePlayerInit()
end)

if (TheInput and ThePlayer) then
  regHotkey(this.fishkey)
end


--[[
modget("autofish").import("cmd")
modget("autofish").ver


modget("autofish").FishAPI(t_inst)
--]]