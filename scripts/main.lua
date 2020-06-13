PrefabFiles = {
	"private_arrow_down"
}
Assets = {
	Asset("ATLAS", "images/zuobiao.xml");
	Asset("IMAGE", "images/zuobiao.tex");
	Asset("ANIM", "anim/qm_jiantou.zip");
}


------------------------------------------------------------
-- common
------------------------------------------------------------

local require = GLOBAL.require
local modinit = require("modinit")
modinit("autofish")


------------------------------------------------------------
-- header
------------------------------------------------------------

local push = table.insert
local tjoin = table.concat

local Text = require "widgets/text"
local TextButton = require "widgets/textbutton"
local TextEdit = require "widgets/textedit"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"

ver = ("autofish v1.0")

------------------------------------------------------------
-- config
------------------------------------------------------------

local CFG_COOK_ENABLE = false
local CFG_FISH_ENABLE = true

local require = GLOBAL.require
local _G = GLOBAL

local key_cook = "C"
local key_fish = "J"
local key_spice = "E"


--范围警示齿轮追踪
local COL_RED         = {1,0,0,1}
local COL_GREEN       = {0,1,0,1}
local COL_SPRINGGREEN = {0.5,1,0.7,1}
local COL_ORANGE      = {1,0.5,0,1}
local COL_DARKBLUE    = {0,0,1,1}
local COL_BLUE        = {0,0.4,1,1}
local COL_YELLOW      = {1,0.8,0,1}
local COL_PINK        = {1,0,1,1}
local COL_BLACK       = {0,0,0,1}
local COL_WHITE       = {1,1,1,1}
local COL_BROWN       = {0.5,0.3,0.2,1}

------------------------------------------------------------
-- main
------------------------------------------------------------

local function SetCol(inst,col)
    inst.AnimState:SetMultColour(col[1],col[2],col[3],col[4])
end

local EmptyFunction = function() return 1 end --we have to return a number

local function CJST()
    local inst = GLOBAL.CreateEntity()
    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst.entity:SetCanSleep(false)
    inst.persists = false
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    GLOBAL.MakeInventoryPhysics(inst)
    GLOBAL.RemovePhysicsColliders(inst)
    inst.AnimState:SetBank("qm_jiantou")
    inst.AnimState:SetBuild("qm_jiantou")
    inst.AnimState:PlayAnimation("ldie_1")
    inst.AnimState:SetOrientation(GLOBAL.ANIM_ORIENTATION.OnGround)
    return inst
end



--【荒野猎人】
if GetModConfigData("gan_hunter") == "true" then

----追踪脚印
AddPrefabPostInit("animal_track",function(inst)
	inst._jiantou = inst:DoPeriodicTask(0.5, function()
		if inst and inst:IsValid() and inst.Transform then
			local sss = 2
			local jiaodu = inst.Transform:GetRotation() + 90
			local x,y,z = inst.entity:LocalToWorldSpace(0,0,-40)
			local a = GLOBAL.TheSim:FindEntities(x,0,z, 10, {"dirtpile"}, { "locomotor", "INLIMBO" })
			local sd = CJST()
			sd.Transform:SetPosition(inst.Transform:GetWorldPosition())
			sd.Transform:SetRotation(jiaodu)
			if a[1] ~= nil then
				local x1,y1,z1 = a[1].Transform:GetWorldPosition()
				sss = math.max(math.sqrt(inst:GetDistanceSqToPoint(x1,y1,z1)) / 20,0.01)
				sd:FacePoint(Point(x1,y1,z1))
			end
			sd:DoTaskInTime(sss or 2, sd.Remove)
			sd.AnimState:SetLightOverride(1)
			sd.Physics:SetMotorVel(20,0,0)
		end
	end)
end)

AddPlayersPostInitEasy = function(fn)
	for i,v in ipairs(_G.DST_CHARACTERLIST) do
		AddPrefabPostInit(v,fn)
	end
	for i,v in ipairs(_G.MODCHARACTERLIST) do
		AddPrefabPostInit(v,fn)
	end
end

--For link on private fn
local function GetListener(inst,event,source,offset)
	source = source or inst
	offset = offset or 0
	local w = inst.event_listeners
	if w and w[event] then
		local fns = w[event][source]
		if fns and #fns > offset then
			local fn = fns[#fns-offset]
			return fn, fns, (#fns-offset)
		end
	end
	return EmptyFunction, false
end


local fake_fueled_component = {
	GetPercent = EmptyFunction,
	SetPercent = EmptyFunction,
}
---------------------------

local function OnTrackRemove(inst)
	--print("OnRemove!")
	if not inst.my_children then
		return
	end
	--print("Kill All")
	for child,_ in pairs(inst.my_children) do
		--print("Kill",child)
		child.my_parent = nil
		child:Remove()
	end
	inst.my_children = nil
	if inst.my_children_task then
		inst.my_children_task:Cancel()
	end
end

local LAZY_TICKS = 40
local function TrackUpdate(inst) --inst
	if inst.my_children_stop_update > 0 then
		inst.my_children_stop_update = inst.my_children_stop_update - 1
		return
	end
	if not inst:IsValid() then
		inst.my_children_task:Cancel()
		return
	end
	local x,y,z = inst.Transform:GetWorldPosition()
	local changed = true
	for k,v in pairs(inst.my_children) do
		if not k:IsValid() then
			inst.my_children[k]=nil
		else
			local x0,y0,z0 = k.Transform:GetWorldPosition()
			if math.abs(x-x0) + math.abs(z-z0) < 0.001 then
				changed = false
				break
			else
				k.Transform:SetPosition(x,0,z)
			end
		end
	end
	if changed then

		inst.my_children_no_move = -1800
		for k,v in pairs(inst.my_children) do
			if k.condition_fn and not k.condition_fn() then
				k.my_parent = nil
				inst.my_children[k] = nil
				k:Remove()
			end
		end
	else
		inst.my_children_no_move = inst.my_children_no_move + 1
		if inst.my_children_no_move > LAZY_TICKS then
			--print("Lazy ticks")
			inst.my_children_stop_update = LAZY_TICKS
		end
	end
end


function MyAddChild(inst,prefab,must_track,anim,scale,condition_fn)

	if inst.my_children == nil then
		inst.my_children = {}
	end
	local child = _G.SpawnPrefab(prefab)
	if not (child and child.Transform) then
		return
	end
	if condition_fn and type(condition_fn) == "function" then
		child.condition_fn = condition_fn
	end
	child.my_parent = inst
	inst.my_children[child] = true
	inst:ListenForEvent("onremove", OnTrackRemove)
	--print("Added OnRemove",inst)
	inst:DoTaskInTime(0,function(inst)
		if not inst:IsValid() then

			return
		end
		local x,y,z = inst.Transform:GetWorldPosition()
		child.Transform:SetPosition(x, 0, z)
		if anim ~= nil then
			child.AnimState:PlayAnimation(anim)
		end
		if scale ~= nil then
			child.Transform:SetScale(scale,scale,scale)
		end
		if must_track ~= nil and inst.my_children_task == nil then
			inst.my_children_stop_update = LAZY_TICKS
			inst.my_children_no_move = 0
			inst.my_children_task = inst:DoPeriodicTask(0.01,TrackUpdate)
		end
		--child.AnimState:SetMultColour(r,g,b,a)
	end)
	return child
end



--function MyAddChild(inst,prefab,must_track,anim,scale,condition_fn)

--moon identifiers

--moon_tree
--gestalt
--fruitdragon
--moonspiderden
--moonglassrock
--rock_avocado_bush
--carrat_planted
--sapling_moon
--moon_fissure
--hotspring
--moonglass
--trap_starfish
--reeds
--dead_sea_bones
--driftwood_tall


--gestalt
AddPrefabPostInit("gestalt",function(inst)
	--MyAddChild(inst,"private_arrow_down") --,must_track,anim,scale)
	MyAddChild(inst,"private_arrow_down",true,nil,0)
	local circle = MyAddChild(inst,"private_circle") --,must_track,anim,scale)
	if circle then
		local r = 2
		circle:SetRadius(r)
		SetCol(circle,COL_RED)
	end
end)

--crawlingnightmare
AddPrefabPostInit("crawlingnightmare",function(inst)
	--MyAddChild(inst,"private_arrow_down") --,must_track,anim,scale)
	MyAddChild(inst,"private_arrow_down",true,nil,0)
	local circle = MyAddChild(inst,"private_circle") --,must_track,anim,scale)
	if circle then
		local r = 2
		circle:SetRadius(r)
		SetCol(circle,COL_WHITE)
	end
end)

--crawling horror
AddPrefabPostInit("crawlinghorror",function(inst)
	--MyAddChild(inst,"private_arrow_down") --,must_track,anim,scale)
	MyAddChild(inst,"private_arrow_down",true,nil,0)
	local circle = MyAddChild(inst,"private_circle") --,must_track,anim,scale)
	if circle then
		local r = 2
		circle:SetRadius(r)
		SetCol(circle,COL_WHITE)
	end
end)

--nightmarebeaks
AddPrefabPostInit("nightmarebeak",function(inst)
	--MyAddChild(inst,"private_arrow_down") --,must_track,anim,scale)
	MyAddChild(inst,"private_arrow_down",true,nil,0)
	local circle = MyAddChild(inst,"private_circle") --,must_track,anim,scale)
	if circle then
		local r = 2
		circle:SetRadius(r)
		SetCol(circle,COL_WHITE)
	end
end)

--terrorbeak
AddPrefabPostInit("terrorbeak",function(inst)
	--MyAddChild(inst,"private_arrow_down") --,must_track,anim,scale)
	MyAddChild(inst,"private_arrow_down",true,nil,0)
	local circle = MyAddChild(inst,"private_circle") --,must_track,anim,scale)
	if circle then
		local r = 2
		circle:SetRadius(r)
		SetCol(circle,COL_WHITE)
	end
end)
--depth worm
AddPrefabPostInit("worm",function(inst)
	--MyAddChild(inst,"private_arrow_down") --,must_track,anim,scale)
	MyAddChild(inst,"private_arrow_down",true,nil,0)
	local circle = MyAddChild(inst,"private_circle") --,must_track,anim,scale)
	if circle then
		local r = 2
		circle:SetRadius(r)
		SetCol(circle,COL_RED)
	end
end)

--treeguard
AddPrefabPostInit("leif",function(inst)
	--MyAddChild(inst,"private_arrow_down") --,must_track,anim,scale)
	MyAddChild(inst,"private_arrow_down",true,nil,.35)
	local circle = MyAddChild(inst,"private_circle") --,must_track,anim,scale)
	if circle then
		local r = 3
		circle:SetRadius(r)
		SetCol(circle,COL_RED)
	end
end)

--treeguard alt
AddPrefabPostInit("leif_sparse",function(inst)
	--MyAddChild(inst,"private_arrow_down") --,must_track,anim,scale)
	MyAddChild(inst,"private_arrow_down",true,nil,.35)
	local circle = MyAddChild(inst,"private_circle") --,must_track,anim,scale)
	if circle then
		local r = 3
		circle:SetRadius(r)
		SetCol(circle,COL_RED)
	end
end)

--regular wormlight plant
AddPrefabPostInit("wormlight_plant",function(inst)
	--MyAddChild(inst,"private_arrow_down") --,must_track,anim,scale)
	MyAddChild(inst,"private_arrow_down",true,nil,0)
	local circle = MyAddChild(inst,"private_circle") --,must_track,anim,scale)
	if circle then
		local r = 3
		circle:SetRadius(r)
		SetCol(circle,COL_GREEN)
	end
end)

--tentacle
AddPrefabPostInit("tentacle",function(inst)
	--MyAddChild(inst,"private_arrow_down") --,must_track,anim,scale)
	MyAddChild(inst,"private_arrow_down",nil,nil,.30)
	local circle = MyAddChild(inst,"private_circle") --,must_track,anim,scale)
	if circle then
		local r = TUNING.TENTACLE_ATTACK_DIST or 4
		circle:SetRadius(r)
		SetCol(circle,COL_RED)
	end
end)

--Lureplant
AddPrefabPostInit("lureplant",function(inst)
	local circle = MyAddChild(inst,"private_circle") --,must_track,anim,scale)
	if circle then
		circle:SetRadius(11)
	end
end)

AddPrefabPostInit("wasphive",function(inst)
	local circle = MyAddChild(inst,"private_circle") --,must_track,anim,scale)
	if circle then
		circle:SetRadius(10)
		SetCol(circle,COL_ORANGE)
	end
end)

AddPrefabPostInit("dirtpile",function(inst)
	local circle = MyAddChild(inst,"private_circle") --,must_track,anim,scale)
	if circle then
		circle:SetRadius(5)
        SetCol(circle,COL_WHITE)
	end
end)

--spore red
AddPrefabPostInit("spore_medium",function(inst)

	MyAddChild(inst,"private_arrow_down",true,nil,0) --,must_track,anim,scale)
	local circle = MyAddChild(inst,"private_circle") --,must_track,anim,scale)
	if circle then
		local r = 2
		circle:SetRadius(r)
		SetCol(circle,COL_RED)
	end
end)

--spore blue
AddPrefabPostInit("spore_tall",function(inst)

	MyAddChild(inst,"private_arrow_down",true,nil,0) --,must_track,anim,scale)
	local circle = MyAddChild(inst,"private_circle") --,must_track,anim,scale)
	if circle then
		local r = 2
		circle:SetRadius(r)
		SetCol(circle,COL_BLUE)
	end
end)

--spore green
AddPrefabPostInit("spore_small",function(inst)

	MyAddChild(inst,"private_arrow_down",true,nil,0) --,must_track,anim,scale)
	local circle = MyAddChild(inst,"private_circle") --,must_track,anim,scale)
	if circle then
		local r = 2
		circle:SetRadius(r)
		SetCol(circle,COL_GREEN)
	end
end)

--toys
AddPrefabPostInit("lost_toy_1",function(inst)
	MyAddChild(inst,"private_arrow_down",nil,nil,2)
	local circle = MyAddChild(inst,"private_circle") --,must_track,anim,scale)
	if circle then
		circle:SetRadius(5)
	end
end)
AddPrefabPostInit("lost_toy_2",function(inst)
	MyAddChild(inst,"private_arrow_down",nil,nil,1.3)
	local circle = MyAddChild(inst,"private_circle") --,must_track,anim,scale)
	if circle then
		circle:SetRadius(5)
	end
end)
AddPrefabPostInit("lost_toy_7",function(inst)
	MyAddChild(inst,"private_arrow_down",nil,nil,1.3)
	local circle = MyAddChild(inst,"private_circle") --,must_track,anim,scale)
	if circle then
		circle:SetRadius(5)
	end
end)
AddPrefabPostInit("lost_toy_10",function(inst)
	MyAddChild(inst,"private_arrow_down",nil,nil,1.3)
	local circle = MyAddChild(inst,"private_circle") --,must_track,anim,scale)
	if circle then
		circle:SetRadius(5)
	end
end)
AddPrefabPostInit("lost_toy_11",function(inst)
	MyAddChild(inst,"private_arrow_down",nil,nil,1.3)
	local circle = MyAddChild(inst,"private_circle") --,must_track,anim,scale)
	if circle then
		circle:SetRadius(5)
	end
end)
AddPrefabPostInit("lost_toy_14",function(inst)
	MyAddChild(inst,"private_arrow_down",nil,nil,1.3)
	local circle = MyAddChild(inst,"private_circle") --,must_track,anim,scale)
	if circle then
		circle:SetRadius(5)
	end
end)
AddPrefabPostInit("lost_toy_18",function(inst)
	MyAddChild(inst,"private_arrow_down",nil,nil,1.3)
	local circle = MyAddChild(inst,"private_circle") --,must_track,anim,scale)
	if circle then
		circle:SetRadius(5)
	end
end)
AddPrefabPostInit("lost_toy_19",function(inst)
	MyAddChild(inst,"private_arrow_down",nil,nil,1.3)
	local circle = MyAddChild(inst,"private_circle") --,must_track,anim,scale)
	if circle then
		circle:SetRadius(5)
	end
end)
AddPrefabPostInit("lost_toy_42",function(inst)
	MyAddChild(inst,"private_arrow_down",nil,nil,1.3)
	local circle = MyAddChild(inst,"private_circle") --,must_track,anim,scale)
	if circle then
		circle:SetRadius(5)
	end
end)
AddPrefabPostInit("lost_toy_43",function(inst)
	MyAddChild(inst,"private_arrow_down",nil,nil,1.3)
	local circle = MyAddChild(inst,"private_circle") --,must_track,anim,scale)
	if circle then
		circle:SetRadius(5)
	end
end)



--[[AddPrefabPostInit("trap_teeth",function(inst)
	local child = MyAddChild(inst,"private_arrow_down",true) --,must_track,anim,scale)
	child.arr_show = true
	inst.arr_task = inst:DoPeriodicTask(1+math.random()*0.1,function(inst)
		if not inst:IsValid() then
			inst.arr_task:Cancel()
			return
		end
		local show = inst.AnimState:IsCurrentAnimation("idle")
		if show ~= child.arr_show then
			child.arr_show = show
			if show then child:Show() else child:Hide() end
		end
	end)
end)--]]



AddPrefabPostInit("buriedtreasurechest",function(inst)

	MyAddChild(inst,"private_arrow_down",false,"green") --,scale)
end)











local player_indicators = {}
local function UpdatePlayerIndicators()
	if not _G.ThePlayer then

		return
	end
	local x0,y0,z0 = _G.ThePlayer.Transform:GetWorldPosition()
	for player,indicator in pairs(player_indicators) do
		if not player:IsValid() or not indicator:IsValid() then
			player_indicators[player] = nil
		else
			local x,y,z = player.Transform:GetWorldPosition()
			local dx,dy = (x-x0), (z-z0)
			if math.abs(dx) > 5 or math.abs(dy) > 5 then
				local alpha = math.deg(math.atan2(dx,dy)) + 180
				indicator.Transform:SetRotation(alpha)
				indicator:Show()
				--check color
				local col = indicator.colours
				local col_new

				if player.name == "Astro" then --admin?
					col_new = {0, 0.4, 1, 1}
				elseif player:HasTag("playerghost") then
					col_new = {0, 0, 1, 1}
				elseif indicator.custom_rgba then
					col_new = indicator.custom_rgba
				else
					col_new = {1, 1, 1, 1}
				end
				if col[1] ~= col_new[1] or col[2] ~= col_new[2] or col[3] ~= col_new[3] or col[4] ~= col_new[4] then
					indicator.colours = col_new
					indicator.AnimState:OverrideMultColour(col_new[1],col_new[2],col_new[3],col_new[4]) --[02:35:44]: Stale Component Reference:
				end
			else
				indicator:Hide()
			end
		end
	end
end


--must_track=true
function AddTrackingIndicator(inst,scale,condition,r,g,b,a)
	inst:DoTaskInTime(0,function(inst)
		if _G.ThePlayer == nil then
			return print("No local player",inst)
		end
		if condition ~= nil and not condition then
			return --print("Bad condition",inst)
		end
		local indicator = MyAddChild(_G.ThePlayer,
			"private_circle", --prefab
			true,
			"up", --arrow up anim
			scale, --scale
			condition --condition function
		)
		if indicator then
			if r ~= nil then
				indicator.custom_rgba = {r,g,b,a}
			end
			player_indicators[inst] = indicator
			inst:ListenForEvent("onremove", function()
				if indicator:IsValid() then
					if indicator.my_parent then
						indicator.my_parent.my_children[indicator] = nil
					end
					indicator.my_parent = nil
					indicator:Remove()
				end
			end)
			UpdatePlayerIndicators()
		end
	end)
end



AddPrefabPostInit("world",function(inst)
	inst:DoPeriodicTask(0.2+0.01*math.random(),function(inst)
		UpdatePlayerIndicators()
	end)
end)

--齿轮部分
-- small tracking arrow icon
-- options are AddTrackingIndicator(inst,scale,condition,r,g,b,a)
-- a has affect on the solidness of center color a=0 removes center


--[[ this was the original setup on gears, red arrow with white outline is default

	AddPrefabPostInit("gears",function(inst)
		AddTrackingIndicator(inst,1.5) --,nil, 0, 0.4, 1, 1)
	end)

	AddTrackingIndicator(inst,1.5,nil, 0, 0.4, 1, 1) makes a blue outline on a black arrow

	AddTrackingIndicator(inst,1.5,nil, 0, 1, 0, .5) black arrow green outline

	AddTrackingIndicator(inst,1.5,nil, 0, 0, 0, 0) not visible

	AddTrackingIndicator(inst,1.5,nil, 0, 0, 0, 1) solid black arrow
	AddTrackingIndicator(inst,1.5,nil, 0, 0, 0, .5) faded black arrow

	AddTrackingIndicator(inst,1.5,nil, 1, 1, 1, 1) red arrow white outline
	AddTrackingIndicator(inst,1.5,nil, 1, 1, 1, 0) another default red center white outline
	AddTrackingIndicator(inst,1.5,nil, 1, 0, 0, 0) weakly visible red line

	AddTrackingIndicator(inst,1.5,nil, 0, 1, 1, 0) teal outside hollow inside
	AddTrackingIndicator(inst,1.5,nil, 0, 1, 1, 1) teal out red inside

	AddTrackingIndicator(inst,1.5,nil, 0, 0, 0.2, 0) very faint whitish line
	AddTrackingIndicator(inst,1.5,nil, 0, 0, 1, 0) faint violet line

	AddTrackingIndicator(inst,1.5,nil, 0, .25, .8, 0) light blueish outline hollow inside
	AddTrackingIndicator(inst,1.5,nil, 0, .35, 1, 0) hollow inside offwhite border
]]

	AddPrefabPostInit("dirtpile",function(inst)
		--AddTrackingIndicator(inst,1.5,nil, 0, 0.4, 1, .5) --blue outline
		AddTrackingIndicator(inst,1.5,nil, 0, 0.4, 1, 1) --blue outline
	end)

	AddPrefabPostInit("pighead",function(inst)
		AddTrackingIndicator(inst,2.5,nil, .40, 0, 0, 0) --red smear
	end)

	AddPrefabPostInit("livingtree",function(inst)
		AddTrackingIndicator(inst,1.75,nil, .1, 1, 0, 0) --green outline mix inside
	end)

	AddPrefabPostInit("walrus_camp",function(inst)
		AddTrackingIndicator(inst,1.75,nil, .5, .6, .7, .8) --red and white default with less sharpness
	end)

	--toy section
	AddPrefabPostInit("lost_toy_1",function(inst)
		AddTrackingIndicator(inst,2,nil, 0, 1, 1, 0) --teal
	end)
	AddPrefabPostInit("lost_toy_2",function(inst)
		AddTrackingIndicator(inst,2,nil, 0, 1, 1, 0) --teal
	end)
	AddPrefabPostInit("lost_toy_7",function(inst)
		AddTrackingIndicator(inst,2,nil, 0, 1, 1, 0) --teal
	end)
	AddPrefabPostInit("lost_toy_10",function(inst)
		AddTrackingIndicator(inst,2,nil, 0, 1, 1, 0) --teal
	end)
	AddPrefabPostInit("lost_toy_11",function(inst)
		AddTrackingIndicator(inst,2,nil, 0, 1, 1, 0) --teal
	end)
	AddPrefabPostInit("lost_toy_14",function(inst)
		AddTrackingIndicator(inst,2,nil, 0, 1, 1, 0) --teal
	end)
	AddPrefabPostInit("lost_toy_18",function(inst)
		AddTrackingIndicator(inst,2,nil, 0, 1, 1, 0) --teal
	end)
	AddPrefabPostInit("lost_toy_19",function(inst)
		AddTrackingIndicator(inst,2,nil, 0, 1, 1, 0) --teal
	end)
	AddPrefabPostInit("lost_toy_42",function(inst)
		AddTrackingIndicator(inst,2,nil, 0, 1, 1, 0) --teal
	end)
	AddPrefabPostInit("lost_toy_43",function(inst)
		AddTrackingIndicator(inst,2,nil, 0, 1, 1, 0) --teal
	end)

function AddBossIndicator(inst)
	if _G.ThePlayer == nil
	then
	return
	else
		AddTrackingIndicator(inst,2.8)
		--print('Found Boss:',inst.prefab and inst.prefab:upper())
		_G.ThePlayer.components.talker:Say("Found entity: "..tostring(inst.prefab and inst.prefab:upper()))
		--print(tostring(_G.ThePlayer))
	end

end
--boss

  AddPrefabPostInit("antlion",AddBossIndicator)
  --AddPrefabPostInit("antlion_spawner",AddBossIndicator)
  AddPrefabPostInit("spat",AddBossIndicator)
  AddPrefabPostInit("warg",AddBossIndicator)
  AddPrefabPostInit("bearger",AddBossIndicator)
  --AddPrefabPostInit("walrus",AddBossIndicator)



	function GetEquippedItem(self, eslot)
		return self._equipspreview ~= nil and self._equipspreview[eslot] or
			(self._equips[eslot] ~= nil and self._equips[eslot]:value() or nil)
	end
	local back = _G.EQUIPSLOTS.BACK or _G.EQUIPSLOTS.BODY --compatible with "Extra Equip Slots" mod
	function GetOverflowContainer(self)
		local item = GetEquippedItem(self, back)
		return item ~= nil and item.replica.container or nil
	end
	function Count(item)
		return item.replica.stackable ~= nil and item.replica.stackable:StackSize() or 1
	end

	--local inv_rep = require "components/inventory_replica"
	local function MyUpdateInventory(inst,result_table)
		local new_inventory = result_table or {nil,nil,nil,nil,nil,nil,nil,nil,nil,nil}
		if inst._activeitem ~= nil then
			new_inventory[inst._activeitem.prefab] = Count(inst._activeitem) or 0
		end
		if inst._itemspreview ~= nil then
			for i, v in ipairs(inst._items) do
				local item = inst._itemspreview[i]
				if item ~= nil and item.prefab then
					if not new_inventory[item.prefab] then
						new_inventory[item.prefab] = 0
					end
					new_inventory[item.prefab] = new_inventory[item.prefab] + Count(item)
				end
			end
		else
			for i, v in ipairs(inst._items) do
				local item = v:value()
				if item ~= nil and item ~= inst._activeitem and item.prefab then
					if not new_inventory[item.prefab] then
						new_inventory[item.prefab] = 0
					end
					new_inventory[item.prefab] = new_inventory[item.prefab] + Count(item)
				end
			end
		end

		local overflow = GetOverflowContainer(inst)
		if overflow ~= nil and overflow.classified then
			--_G.arr(overflow,3)
			overflow.classified:MyUpdateInventoryContainer(new_inventory)
		end

		if not result_table then
			return new_inventory
		end
	end
	AddPrefabPostInit("inventory_classified",function(inst)
		inst.MyUpdateInventory = MyUpdateInventory
	end)

	local function MyUpdateInventoryContainer(inst, result_table)
		local count = 0
		if inst._itemspreview ~= nil then
			for i, v in ipairs(inst._items) do
				local item = inst._itemspreview[i]
				if item ~= nil and item.prefab then
					if not result_table[item.prefab] then
						result_table[item.prefab] = 0
					end
					result_table[item.prefab] = result_table[item.prefab] + Count(item)
				end
			end
		else
			for i, v in ipairs(inst._items) do
				local item = v:value()
				if item ~= nil and item.prefab then
					if not result_table[item.prefab] then
						result_table[item.prefab] = 0
					end
					result_table[item.prefab] = result_table[item.prefab] + Count(item)
				end
			end
		end
		return result_table
	end
	AddPrefabPostInit("container_classified",function(inst)
		inst.MyUpdateInventoryContainer = MyUpdateInventoryContainer
	end)

	local save_local --local inventory
	local function UpdateRecipes(inst)
		inst.count_gold = (save_local.goldnugget or 0)
			+ (save_local.spear or save_local.hambat or save_local.cane or save_local.armorwood or save_local.footballhat
				or save_local.goldenshovel or save_local.goldenaxe or save_local.goldenpickaxe
				or save_local.heatrock or 0)*100
		inst.count_flints = (save_local.flint or 0)
			+ (save_local.rocks or 0)*0.5
			+ (save_local.log or 0)*0.5
	end
	local OnTickFn = function(inst)
		if not inst:IsValid() then
			inst.recipes_task:Cancel()
			return
		end
		if inst.replica.inventory and inst.replica.inventory.classified then
			save_local = inst.replica.inventory.classified:MyUpdateInventory()
			inst.save_local = save_local
			UpdateRecipes(inst)
		end
	end
	AddPlayersPostInitEasy(function(inst)
		--print("THEPLAYER == "..tostring(_G.ThePlayer))
		local init_timer
		init_timer = inst:DoPeriodicTask(0.3,function(inst)
			if not _G.ThePlayer then
				return
			end
			init_timer:Cancel()
			if inst==_G.ThePlayer then
				inst.recipes_task = inst:DoPeriodicTask(0.5+math.random()*0.1,OnTickFn)
			end
		end)
	end)
end


AddPrefabPostInit("dirtpile",function(inst)
	MyAddChild(inst,"private_arrow_down",false,"green") --,scale)
	local circle = MyAddChild(inst,"private_circle") --,must_track,anim,scale)
	if circle then
		circle:SetRadius(4)
	end
	AddTrackingIndicator(inst,1.5)
end)

--[[AddPrefabPostInit("cane",function(inst)
	AddTrackingIndicator(inst,1.7)
end)]]--

AddPrefabPostInit("gears",function(inst)
	AddTrackingIndicator(inst,1.5,nil, 0, 0.4, 1, 1)
end)

print(ver)