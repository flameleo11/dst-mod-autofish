todo

auto torch attack
scan enemy around
auto feed beefalos

choose record location and run to it

bug , costum to change character special emotes
idle_emotes
skinspuppet.lua
TEST remote server or local func

self:DoEmote(player_emotes_to_choose[self.prefabname], false, true, self.item_equip)
idle_wendy
self:DoEmote(idle_wendy, false, true, true)


if not (this.origin_DoIdleEmote) then
  local SkinsPuppet = GLOBAL.require("widgets/skinspuppet")
  this.origin_DoIdleEmote = SkinsPuppet.DoIdleEmote
end
local DoIdleEmote = _f(function (self, ...)
  this.origin_DoIdleEmote(self, ...)
  if this.wheel_visable then
    self.rolewheel:OnUpdate()
  end
end)
controls.OnUpdate = OnUpdate

local OldOnUpdate = SkinsPuppet.DoIdleEmote
local function OnUpdate(self, ...)
  OldOnUpdate(self, ...)
  if keydown then
    self.gesturewheel:OnUpdate()
  end
end
Controls.OnUpdate = OnUpdate




{ok}
change role prefab
by press key role Wheel


