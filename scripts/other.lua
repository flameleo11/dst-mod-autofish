PrefabFiles = {
	"private_arrow_down"
}

------------------------------------------------------------
-- header
------------------------------------------------------------

local require = GLOBAL.require
local modinit = require("modinit")
modinit("autofish")


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
------------------------------------------------------------
-- main
------------------------------------------------------------

if GetModConfigData("gan_view") == "true" then
    AddClassPostConstruct(
        "cameras/followcamera",
        function(Camera)
            Camera.old = Camera.SetDefault
            function Camera:SetDefault()
                if Camera.target ~= nil and Camera.target.entity and Camera.target.entity:GetParent() ~= nil then
                    Camera.maxdist = 250
                end
            end
        end
    )
end

--[[ commented out because mod is already overstuffed
--sanity filter section (removed)
if GetModConfigData("gan_brain") == "true" then
    AddPrefabPostInit("forest", function(inst)
        inst:RemoveComponent("colourcube")
        inst:AddComponent("colourcube2")
    end)
    AddPrefabPostInit("cave", function(inst)
        inst:RemoveComponent("colourcube")
        inst:AddComponent("colourcube2")
    end)
-- 消除画面周边
    local PlayerHud = GLOBAL.require("screens/playerhud")
    function PlayerHud:GoInsane()
        self:GoSane()
    end
-- 消除脑残声音
    AddPrefabPostInit("forest", function(inst)
        inst:RemoveComponent("ambientsound")
        inst:AddComponent("ambientsound2")
    end)
    AddPrefabPostInit("cave", function(inst)
        inst:RemoveComponent("ambientsound")
        inst:AddComponent("ambientsound2")
    end)
end
]]
local Text = GLOBAL.require "widgets/text"
local TextButton = GLOBAL.require "widgets/textbutton"
local TextEdit = GLOBAL.require "widgets/textedit"
local Image = GLOBAL.require "widgets/image"
local ImageButton = GLOBAL.require "widgets/imagebutton"

local Ass = {}
GLOBAL.table.insert(Ass, Asset("ATLAS", "images/zuobiao.xml"))
GLOBAL.table.insert(Ass, Asset("IMAGE", "images/zuobiao.tex"))
GLOBAL.table.insert(Ass, Asset("ANIM", "anim/qm_jiantou.zip"))
Assets = Ass

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

AddClassPostConstruct(
    "widgets/controls",
    function(self)
        self.inst:DoTaskInTime(
            0,
            function()
                ---------------------------------------------------------------------------
                ---【匠心名厨】
                if CFG_COOK_ENABLE then
                    GLOBAL.TheInput:AddKeyDownHandler(
                        key_cook,
                        function()
                            if GLOBAL.ThePlayer.pzz then
                                GLOBAL.ThePlayer.pzz:SetList(nil)
                                GLOBAL.ThePlayer.pzz = nil
                                return
                            end
                            GLOBAL.ThePlayer.zdpr = GLOBAL.ThePlayer:GetPosition()
                            local ccc = 0.01
                            local beibao = GLOBAL.EQUIPSLOTS.BACK or GLOBAL.EQUIPSLOTS.BODY --Shang
                            local B = GLOBAL.ThePlayer.replica.inventory:GetEquippedItem(beibao)
                            if B ~= nil then
                                for i = 1, 4 do
                                    if not (B and B.replica.container:GetItemInSlot(i)) then
                                        return false
                                    end
                                end
                            end

                            GLOBAL.ThePlayer.pzz =
                                GLOBAL.ThePlayer:StartThread(
                                function()
                                    local qid = true
                                    local pos = GLOBAL.ThePlayer.zdpr
                                    while qid do
                                        local C = nil
                                        local beibao = GLOBAL.EQUIPSLOTS.BACK or GLOBAL.EQUIPSLOTS.BODY --Shang
                                        local B = GLOBAL.ThePlayer.replica.inventory:GetEquippedItem(beibao)
                                        if B ~= nil then
                                            for i = 1, 4 do
                                                if not B.replica.container:GetItemInSlot(i) then
                                                    qid = false
                                                    GLOBAL.ThePlayer.pzz:SetList(nil)
                                                    GLOBAL.ThePlayer.pzz = nil
                                                    return
                                                end
                                            end
                                        end

                                        --FindEntity definition
                                        -- function FindEntity(inst, radius, fn, musttags, canttags, mustoneoftags)
                                        -- if inst ~= nil and inst:IsValid() then
                                        -- local x, y, z = inst.Transform:GetWorldPosition()
                                        -- --print("FIND", inst, radius, musttags and #musttags or 0, canttags and #canttags or 0, mustoneoftags and #mustoneoftags or 0)
                                        -- local ents = TheSim:FindEntities(x, y, z, radius, musttags, canttags, mustoneoftags) -- or we could include a flag to the search?
                                        -- for i, v in ipairs(ents) do
                                        -- if v ~= inst and v.entity:IsVisible() and (fn == nil or fn(v, inst)) then
                                        -- return v
                                        -- end
                                        -- end
                                        -- end
                                        -- end

                                        if _G.ThePlayer.prefab ~= "warly" then -- if not warly then do the non warly routine
                                            C =
                                                GLOBAL.FindEntity(
                                                GLOBAL.ThePlayer,
                                                20,
                                                function(guy)
                                                    return guy.replica and guy.replica.container and
                                                        guy.prefab == "cookpot" and
                                                        guy.replica.container:IsOpenedBy(GLOBAL.ThePlayer) and
                                                        guy:GetDistanceSqToPoint(pos:Get()) < 14 * 14
                                                end,
                                                {"structure"},
                                                {"INLIMBO", "noauradamage"}
                                            )

                                            if C ~= nil then
                                                ccc = 0.01
                                                local aa = 1
                                                local bb = 0
                                                local E = C ~= nil and C.replica.container:GetItemInSlot(aa)
                                                while B ~= nil and C ~= nil and not C.replica.container:IsFull() and
                                                    bb < 100 and
                                                    aa < 5 and
                                                    C.replica.container:IsOpenedBy(GLOBAL.ThePlayer) do
                                                    bb = bb + 1
                                                    if not C.replica.container:GetItemInSlot(aa) then
                                                        B.replica.container:MoveItemFromAllOfSlot(aa, C)
                                                    else
                                                        aa = aa + 1
                                                    end
                                                    GLOBAL.Sleep(0.01)
                                                end
                                                if C and C.replica.container:IsOpenedBy(GLOBAL.ThePlayer) then
                                                    GLOBAL.SendRPCToServer(
                                                        GLOBAL.RPC.DoWidgetButtonAction,
                                                        GLOBAL.ACTIONS.COOK.code,
                                                        C,
                                                        GLOBAL.ACTIONS.COOK.mod_name
                                                    )
                                                end
                                            end

                                            if not C then
                                                C =
                                                    GLOBAL.FindEntity(
                                                    GLOBAL.ThePlayer,
                                                    20,
                                                    function(guy)
                                                        return guy.replica and guy.replica.container and
                                                            guy.prefab == "cookpot" and
                                                            guy:GetDistanceSqToPoint(pos:Get()) < 14 * 14 and
                                                            GLOBAL.ThePlayer.components.playeractionpicker:DoGetMouseActions(
                                                                nil,
                                                                guy
                                                            ) and
                                                            (GLOBAL.ThePlayer.components.playeractionpicker:DoGetMouseActions(
                                                                nil,
                                                                guy
                                                            ).action == GLOBAL.ACTIONS.RUMMAGE or
                                                                GLOBAL.ThePlayer.components.playeractionpicker:DoGetMouseActions(
                                                                    nil,
                                                                    guy
                                                                ).action == GLOBAL.ACTIONS.HARVEST)
                                                    end,
                                                    {"structure"},
                                                    {"INLIMBO", "noauradamage"}
                                                )

                                                if C ~= nil then
                                                    ccc = 0.01
                                                    local A = C:GetPosition()
                                                    local controlmods =
                                                        GLOBAL.ThePlayer.components.playercontroller:EncodeControlMods()
                                                    local E, F =
                                                        GLOBAL.ThePlayer.components.playeractionpicker:DoGetMouseActions(
                                                        A,
                                                        C
                                                    )
                                                    if E ~= nil then
                                                        GLOBAL.SendRPCToServer(
                                                            GLOBAL.RPC.LeftClick,
                                                            E.action.code,
                                                            A.x,
                                                            A.z,
                                                            C,
                                                            false,
                                                            controlmods,
                                                            nil,
                                                            E.action.mod_name
                                                        )
                                                        if E and E.action == GLOBAL.ACTIONS.RUMMAGE then
                                                            ccc = 0.7
                                                        end
                                                    end
                                                end
                                            end
                                            GLOBAL.Sleep(ccc)
                                        else -- else warly so do the warly routine
                                            C =
                                                GLOBAL.FindEntity(
                                                GLOBAL.ThePlayer,
                                                20,
                                                function(guy)
                                                    return guy.replica and guy.replica.container and
                                                        (guy.prefab == "cookpot" or guy.prefab == "portablecookpot") and
                                                        guy.replica.container:IsOpenedBy(GLOBAL.ThePlayer) and
                                                        guy:GetDistanceSqToPoint(pos:Get()) < 14 * 14
                                                end,
                                                {"structure"},
                                                {"INLIMBO", "noauradamage"}
                                            )

                                            if C ~= nil then
                                                ccc = 0.01
                                                local aa = 1
                                                local bb = 0
                                                local E = C ~= nil and C.replica.container:GetItemInSlot(aa)
                                                while B ~= nil and C ~= nil and not C.replica.container:IsFull() and
                                                    bb < 100 and
                                                    aa < 5 and
                                                    C.replica.container:IsOpenedBy(GLOBAL.ThePlayer) do
                                                    bb = bb + 1
                                                    if not C.replica.container:GetItemInSlot(aa) then
                                                        B.replica.container:MoveItemFromAllOfSlot(aa, C)
                                                    else
                                                        aa = aa + 1
                                                    end
                                                    GLOBAL.Sleep(0.01)
                                                end
                                                if C and C.replica.container:IsOpenedBy(GLOBAL.ThePlayer) then
                                                    GLOBAL.SendRPCToServer(
                                                        GLOBAL.RPC.DoWidgetButtonAction,
                                                        GLOBAL.ACTIONS.COOK.code,
                                                        C,
                                                        GLOBAL.ACTIONS.COOK.mod_name
                                                    )
                                                end
                                            end

                                            if not C then
                                                C =
                                                    GLOBAL.FindEntity(
                                                    GLOBAL.ThePlayer,
                                                    20,
                                                    function(guy)
                                                        return guy.replica and guy.replica.container and
                                                            (guy.prefab == "cookpot" or guy.prefab == "portablecookpot") and
                                                            guy:GetDistanceSqToPoint(pos:Get()) < 14 * 14 and
                                                            GLOBAL.ThePlayer.components.playeractionpicker:DoGetMouseActions(
                                                                nil,
                                                                guy
                                                            ) and
                                                            (GLOBAL.ThePlayer.components.playeractionpicker:DoGetMouseActions(
                                                                nil,
                                                                guy
                                                            ).action == GLOBAL.ACTIONS.RUMMAGE or
                                                                GLOBAL.ThePlayer.components.playeractionpicker:DoGetMouseActions(
                                                                    nil,
                                                                    guy
                                                                ).action == GLOBAL.ACTIONS.HARVEST)
                                                    end,
                                                    {"structure"},
                                                    {"INLIMBO", "noauradamage"}
                                                )

                                                if C ~= nil then
                                                    ccc = 0.01
                                                    local A = C:GetPosition()
                                                    local controlmods =
                                                        GLOBAL.ThePlayer.components.playercontroller:EncodeControlMods()
                                                    local E, F =
                                                        GLOBAL.ThePlayer.components.playeractionpicker:DoGetMouseActions(
                                                        A,
                                                        C
                                                    )
                                                    if E ~= nil then
                                                        GLOBAL.SendRPCToServer(
                                                            GLOBAL.RPC.LeftClick,
                                                            E.action.code,
                                                            A.x,
                                                            A.z,
                                                            C,
                                                            false,
                                                            controlmods,
                                                            nil,
                                                            E.action.mod_name
                                                        )
                                                        if E and E.action == GLOBAL.ACTIONS.RUMMAGE then
                                                            ccc = 0.7
                                                        end
                                                    end
                                                end
                                            end
                                            GLOBAL.Sleep(ccc)
                                        end --ends warly conditional if
                                    end --end while loop
                                end
                            ) --end startthread
                        end
                    ) --end for keydownhandler
                end --ends the if that enables cook section

                --spice section
                if CFG_COOK_ENABLE then
                    GLOBAL.TheInput:AddKeyDownHandler(
                        key_spice,
                        function()
                            if GLOBAL.ThePlayer.pzz then
                                GLOBAL.ThePlayer.pzz:SetList(nil)
                                GLOBAL.ThePlayer.pzz = nil
                                return
                            end
                            GLOBAL.ThePlayer.zdpr = GLOBAL.ThePlayer:GetPosition()
                            local ccc = 0.01
                            local beibao = GLOBAL.EQUIPSLOTS.BACK or GLOBAL.EQUIPSLOTS.BODY --Shang
                            local B = GLOBAL.ThePlayer.replica.inventory:GetEquippedItem(beibao)
                            if B ~= nil then
                                for i = 1, 2 do
                                    if not (B and B.replica.container:GetItemInSlot(i)) then
                                        return false
                                    end
                                end
                            end

                            GLOBAL.ThePlayer.pzz =
                                GLOBAL.ThePlayer:StartThread(
                                function()
                                    local qid = true
                                    local pos = GLOBAL.ThePlayer.zdpr
                                    while qid do
                                        local C = nil
                                        local beibao = GLOBAL.EQUIPSLOTS.BACK or GLOBAL.EQUIPSLOTS.BODY --Shang
                                        local B = GLOBAL.ThePlayer.replica.inventory:GetEquippedItem(beibao)
                                        if B ~= nil then
                                            for i = 1, 2 do
                                                if not B.replica.container:GetItemInSlot(i) then
                                                    qid = false
                                                    GLOBAL.ThePlayer.pzz:SetList(nil)
                                                    GLOBAL.ThePlayer.pzz = nil
                                                    return
                                                end
                                            end
                                        end

                                        --FindEntity definition
                                        -- function FindEntity(inst, radius, fn, musttags, canttags, mustoneoftags)
                                        -- if inst ~= nil and inst:IsValid() then
                                        -- local x, y, z = inst.Transform:GetWorldPosition()
                                        -- --print("FIND", inst, radius, musttags and #musttags or 0, canttags and #canttags or 0, mustoneoftags and #mustoneoftags or 0)
                                        -- local ents = TheSim:FindEntities(x, y, z, radius, musttags, canttags, mustoneoftags) -- or we could include a flag to the search?
                                        -- for i, v in ipairs(ents) do
                                        -- if v ~= inst and v.entity:IsVisible() and (fn == nil or fn(v, inst)) then
                                        -- return v
                                        -- end
                                        -- end
                                        -- end
                                        -- end

                                        if _G.ThePlayer.prefab == "warly" then --only do this as warly
                                            C =
                                                GLOBAL.FindEntity(
                                                GLOBAL.ThePlayer,
                                                20,
                                                function(guy)
                                                    return guy.replica and guy.replica.container and
                                                        (guy.prefab == "portablespicer") and
                                                        guy.replica.container:IsOpenedBy(GLOBAL.ThePlayer) and
                                                        guy:GetDistanceSqToPoint(pos:Get()) < 14 * 14
                                                end,
                                                {"structure"},
                                                {"INLIMBO", "noauradamage"}
                                            )

                                            if C ~= nil then
                                                ccc = 0.01
                                                local aa = 1
                                                local bb = 0
                                                local E = C ~= nil and C.replica.container:GetItemInSlot(aa)
                                                while B ~= nil and C ~= nil and not C.replica.container:IsFull() and
                                                    bb < 100 and
                                                    aa < 5 and
                                                    C.replica.container:IsOpenedBy(GLOBAL.ThePlayer) do
                                                    bb = bb + 1
                                                    if not C.replica.container:GetItemInSlot(aa) then
                                                        B.replica.container:MoveItemFromAllOfSlot(aa, C)
                                                    else
                                                        aa = aa + 1
                                                    end
                                                    GLOBAL.Sleep(0.01)
                                                end
                                                if C and C.replica.container:IsOpenedBy(GLOBAL.ThePlayer) then
                                                    GLOBAL.SendRPCToServer(
                                                        GLOBAL.RPC.DoWidgetButtonAction,
                                                        GLOBAL.ACTIONS.COOK.code,
                                                        C,
                                                        GLOBAL.ACTIONS.COOK.mod_name
                                                    )
                                                end
                                            end

                                            if not C then
                                                C =
                                                    GLOBAL.FindEntity(
                                                    GLOBAL.ThePlayer,
                                                    20,
                                                    function(guy)
                                                        return guy.replica and guy.replica.container and
                                                            (guy.prefab == "portablespicer") and
                                                            guy:GetDistanceSqToPoint(pos:Get()) < 14 * 14 and
                                                            GLOBAL.ThePlayer.components.playeractionpicker:DoGetMouseActions(
                                                                nil,
                                                                guy
                                                            ) and
                                                            (GLOBAL.ThePlayer.components.playeractionpicker:DoGetMouseActions(
                                                                nil,
                                                                guy
                                                            ).action == GLOBAL.ACTIONS.RUMMAGE or
                                                                GLOBAL.ThePlayer.components.playeractionpicker:DoGetMouseActions(
                                                                    nil,
                                                                    guy
                                                                ).action == GLOBAL.ACTIONS.HARVEST)
                                                    end,
                                                    {"structure"},
                                                    {"INLIMBO", "noauradamage"}
                                                )

                                                if C ~= nil then
                                                    ccc = 0.01
                                                    local A = C:GetPosition()
                                                    local controlmods =
                                                        GLOBAL.ThePlayer.components.playercontroller:EncodeControlMods()
                                                    local E, F =
                                                        GLOBAL.ThePlayer.components.playeractionpicker:DoGetMouseActions(
                                                        A,
                                                        C
                                                    )
                                                    if E ~= nil then
                                                        GLOBAL.SendRPCToServer(
                                                            GLOBAL.RPC.LeftClick,
                                                            E.action.code,
                                                            A.x,
                                                            A.z,
                                                            C,
                                                            false,
                                                            controlmods,
                                                            nil,
                                                            E.action.mod_name
                                                        )
                                                        if E and E.action == GLOBAL.ACTIONS.RUMMAGE then
                                                            ccc = 0.7
                                                        end
                                                    end
                                                end
                                            end
                                            GLOBAL.Sleep(ccc)
                                        else
                                            return -- else not warly so end it
                                        end --ends warly conditional if
                                    end --end while loop
                                end
                            )
                        end
                    ) --end for keydownhandler
                end --ends the if that enables spice section

                ------------------------------------------------------------------------
                ---【大漠渔夫】
                if CFG_FISH_ENABLE then
                	local keybind = _G["KEY_"..key_fish]
                    GLOBAL.TheInput:AddKeyDownHandler(
                        keybind,
                        function()
                            print(".............fish ", 111)
                            if GLOBAL.ThePlayer.diaoyu then
                                GLOBAL.ThePlayer.diaoyu:SetList(nil)
                                GLOBAL.ThePlayer.diaoyu = nil
                                print(".............fish ", 222)
                                return
                            end

                            print(".............fish ", 333)
                            GLOBAL.ThePlayer.zdpr = GLOBAL.ThePlayer:GetPosition()
                            local pos = GLOBAL.ThePlayer.zdpr
                            local qmc = GLOBAL.ThePlayer.components.playercontroller
                            local B = GLOBAL.ThePlayer.replica.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HANDS)
                            local ku = GLOBAL.ThePlayer.replica.inventory
                            ----
                            local function zhuangbei()
                                local sousuo = nil
                                for i = 1, ku:GetNumSlots() do
                                    local sou_1 = ku:GetItemInSlot(i)
                                    if sou_1 and sou_1.prefab == "fishingrod" then
                                        sousuo = sou_1
                                        break
                                    end
                                end
                                local beibao = GLOBAL.EQUIPSLOTS.BACK or GLOBAL.EQUIPSLOTS.BODY --Shang
                                local Bbao = GLOBAL.ThePlayer.replica.inventory:GetEquippedItem(beibao)
                                if Bbao and Bbao.replica and Bbao.replica.container and not sousuo then
                                    for i = 1, Bbao.replica.container:GetNumSlots() do
                                        local sou_1 = Bbao.replica.container:GetItemInSlot(i)
                                        if sou_1 and sou_1.prefab == "fishingrod" then
                                            sousuo = sou_1
                                            break
                                        end
                                    end
                                else
                                    -- /drive_d/SteamLibrary/steamapps/common/Don't Starve Together/mods/workshop-1781023085/modmain.lua
                                    print("[mode error] in 1781023085/modmain.lua:396", Bbao)
                                end
                                return sousuo
                            end
                            -----
                            if not B or B.prefab ~= "fishingrod" then
                                local C = zhuangbei()
                                if not C then
                                    return
                                end
                                ku:ControllerUseItemOnSelfFromInvTile(C)
                            end

                            GLOBAL.ThePlayer.diaoyu =
                                GLOBAL.ThePlayer:StartThread(
                                function()
                                    local qid = true
                                    local ccc = 0.1
                                    while qid do
                                        local ku = GLOBAL.ThePlayer.replica.inventory
                                        local beibao = GLOBAL.EQUIPSLOTS.BACK or GLOBAL.EQUIPSLOTS.BODY --Shang
                                        local Bbao = GLOBAL.ThePlayer.replica.inventory:GetEquippedItem(beibao)
                                        local B =
                                            GLOBAL.ThePlayer.replica.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HANDS)
                                        if not B or B.prefab ~= "fishingrod" then
                                            local C = zhuangbei()
                                            if not C then
                                                return
                                            end
                                            ku:ControllerUseItemOnSelfFromInvTile(C)
                                            GLOBAL.Sleep(0.3)
                                        end
                                        local C = nil
                                        C =
                                            GLOBAL.FindEntity(
                                            GLOBAL.ThePlayer,
                                            20,
                                            function(guy)
                                                return (guy.prefab == "pond" or guy.prefab == "pond_mos" or
                                                    guy.prefab == "pond_cave" or
                                                    guy.prefab == "oasislake") and
                                                    guy:GetDistanceSqToPoint(pos:Get()) < 14 * 14
                                            end,
                                            nil,
                                            {"INLIMBO", "noauradamage"}
                                        )
                                        if C ~= nil and qid then
                                            local A = C:GetPosition()
                                            local controlmods = qmc:EncodeControlMods()
                                            local E, F =
                                                GLOBAL.ThePlayer.components.playeractionpicker:DoGetMouseActions(A, C)
                                            if E then
                                                local S = E and E:GetActionString() or ""
                                                if S ~= GLOBAL.STRINGS.ACTIONS.REEL.CANCEL then
                                                    qmc:DoAction(E)
                                                    GLOBAL.Sleep(0.1)
                                                    GLOBAL.SendRPCToServer(
                                                        GLOBAL.RPC.LeftClick,
                                                        E.action.code,
                                                        A.x,
                                                        A.z,
                                                        C,
                                                        false,
                                                        controlmods,
                                                        false,
                                                        E.action.mod_name
                                                    )
                                                end
                                            end
                                        else
                                            qid = false
                                            GLOBAL.ThePlayer.diaoyu:SetList(nil)
                                            GLOBAL.ThePlayer.diaoyu = nil
                                        end
                                        GLOBAL.Sleep(ccc)
                                    end
                                end
                            )
                        end
                    )
                end
                --对应fisherman
                ---------------------------------------------------------------------------
            end
        )
    end
)

--【荒野猎人】
if GetModConfigData("gan_hunter") == "true" then
    ----追踪脚印
    AddPrefabPostInit(
        "animal_track",
        function(inst)
            inst._jiantou =
                inst:DoPeriodicTask(
                0.5,
                function()
                    if inst and inst:IsValid() and inst.Transform then
                        local sss = 2
                        local jiaodu = inst.Transform:GetRotation() + 90
                        local x, y, z = inst.entity:LocalToWorldSpace(0, 0, -40)
                        local a = GLOBAL.TheSim:FindEntities(x, 0, z, 10, {"dirtpile"}, {"locomotor", "INLIMBO"})
                        local sd = CJST()
                        sd.Transform:SetPosition(inst.Transform:GetWorldPosition())
                        sd.Transform:SetRotation(jiaodu)
                        if a[1] ~= nil then
                            local x1, y1, z1 = a[1].Transform:GetWorldPosition()
                            sss = math.max(math.sqrt(inst:GetDistanceSqToPoint(x1, y1, z1)) / 20, 0.01)
                            sd:FacePoint(Point(x1, y1, z1))
                        end
                        sd:DoTaskInTime(sss or 2, sd.Remove)
                        sd.AnimState:SetLightOverride(1)
                        sd.Physics:SetMotorVel(20, 0, 0)
                    end
                end
            )
        end
    )

    --范围警示齿轮追踪
    local COL_RED = {1, 0, 0, 1}
    local COL_GREEN = {0, 1, 0, 1}
    local COL_SPRINGGREEN = {0.5, 1, 0.7, 1}
    local COL_ORANGE = {1, 0.5, 0, 1}
    local COL_DARKBLUE = {0, 0, 1, 1}
    local COL_BLUE = {0, 0.4, 1, 1}
    local COL_YELLOW = {1, 0.8, 0, 1}
    local COL_PINK = {1, 0, 1, 1}
    local COL_BLACK = {0, 0, 0, 1}
    local COL_WHITE = {1, 1, 1, 1}
    local COL_BROWN = {0.5, 0.3, 0.2, 1}

    local function SetCol(inst, col)
        inst.AnimState:SetMultColour(col[1], col[2], col[3], col[4])
    end

    _G = GLOBAL
    local EmptyFunction = function()
        return 1
    end --we have to return a number
    print("PRIVATE MOD STARTED")

    AddPlayersPostInitEasy = function(fn)
        for i, v in ipairs(_G.DST_CHARACTERLIST) do
            AddPrefabPostInit(v, fn)
        end
        for i, v in ipairs(_G.MODCHARACTERLIST) do
            AddPrefabPostInit(v, fn)
        end
    end

    --AddPrefabPostInit("flint",function(inst)
    --    inst.GetShowItemInfo = function(inst)
    --        return "Test String."
    --    end
    --end)

    --For link on private fn
    local function GetListener(inst, event, source, offset)
        source = source or inst
        offset = offset or 0
        local w = inst.event_listeners
        if w and w[event] then
            local fns = w[event][source]
            if fns and #fns > offset then
                local fn = fns[#fns - offset]
                return fn, fns, (#fns - offset)
            end
        end
        return EmptyFunction, false
    end

    local fake_fueled_component = {
        GetPercent = EmptyFunction,
        SetPercent = EmptyFunction
    }

    --[[AddPrefabPostInit("heatrock",function(inst)
	if not inst.components.fueled then
		--print('ERROR infinite heatrock: component "fueled" already removed by another mod')
		--client side
		return
	end
	local old_fn, success = GetListener(inst,"temperaturedelta") --link to old fn
	if not success then
		print("ERROR infinite heatrock: no target function")
		return
	end
	inst:RemoveEventCallback("temperaturedelta",old_fn) --i hope we completely removed old listener
	inst:RemoveComponent("fueled") --remove the component
	inst:ListenForEvent("temperaturedelta", function(inst,data) --add custom "fake" listener
		if inst.components.fueled then
			--ERROR: some mod added "fueled" component. We can't overwrite it or game will crash.
			old_fn(inst,data)
			return
		end
		inst.components.fueled = fake_fueled_component
		old_fn(inst,data)
		inst.components.fueled = nil
	end)
end)--]]
    if false then --Disabled
        local io, os = _G.io, _G.os
        local gift_info = {}
        local function SaveInfo()
            local f = io.open("gifts_info.json", "w")
            if f ~= nil then
                f:write(_G.json.encode(gift_info))
                f:close()
            else
                print("ERROR: Can't write gifts_info file.")
            end
        end
        do
            local f = io.open("gifts_info.json", "r")
            if f ~= nil then
                local content = f:read("*all")
                f:close()
                local info = _G.json.decode(content)
                if info then
                    gift_info = info
                else
                    print("ERROR in decoding gifts_info file.")
                end
            else
                print("WARNING: Can't read gifts_info file.")
                SaveInfo()
            end
        end
        _G.rawset(_G, "gift_info", gift_info)

        local function UpdateGiftData()
            local inst = _G.ThePlayer
            if inst == nil then
                return
            end
            if gift_info[inst.userid] == nil then
                gift_info[inst.userid] = {}
            end
            local data = gift_info[inst.userid]
            local time_playing = 0
            local logins_to_game = 0
            table.insert(data, {tostring(inst.name), os.date(), time_playing, logins_to_game, os.time()})
            if #data > 20 then
                table.remove(data, 1)
            end
            SaveInfo()
        end

        --[[local function FindUpvalue(fn, upvalue_name, member_check, no_print)
		local info = _G.debug.getinfo(fn, "u")
		local nups = info and info.nups
		if not nups then return end
		local getupvalue = _G.debug.getupvalue
		local s = ''
		for i = 1, nups do
			local name, val = getupvalue(fn, i)
			if (name == upvalue_name)
				and ((not member_check) or (type(val)=="table" and val[member_check])) --Надежная проверка
			then
				return val, true
			end
		end
		if not no_print then
			print("CRITICAL ERROR: Can't find variable "..tostring(upvalue_name).."!")
		end
	end
	local RPC_HANDLERS = FindUpvalue(_G.SendRPCToServer, "RPC_HANDLERS")
	local old_DoneOpenGift = RPC_HANDLERS[_G.RPC.DoneOpenGift]
	RPC_HANDLERS[_G.RPC.DoneOpenGift] = function(player, usewardrobe, ...)
		old_DoneOpenGift(player, usewardrobe, ...)
		UpdateGiftData(player)
	end
	local giftreceiver = _G.require "components/giftreceiver"
	local old_OnStopOpenGift = giftreceiver.OnStopOpenGift
	function giftreceiver:OnStopOpenGift(...)
		if _G.ThePlayer and _G.ThePlayer == self.inst then
			UpdateGiftData(self.inst)
		end
		return old_OnStopOpenGift(self,...)
	end--]]
        local giftitempopup = _G.require "screens/giftitempopup"
        local old_ShowMenu = giftitempopup.ShowMenu
        function giftitempopup:ShowMenu(...)
            print("popup - ShowMenu")
            old_ShowMenu(self, ...)
            _G.rawset(_G, "gift_popup", self) -- gift_popup.menu.items[1].onclick()
            self.menu.items[1].onclick()
        end
        local old_

        local giftitemtoast = _G.require "widgets/giftitemtoast"
        local old_OnClickEnabled = giftitemtoast.OnClickEnabled
        function giftitemtoast:OnClickEnabled(...)
            _G.rawset(_G, "gift_toast", self)
            print("toast - OnClickEnabled - ready to open gift!")
            old_OnClickEnabled(self, ...)
            self.inst:DoTaskInTime(
                0,
                function(inst)
                    if self.shown and self.enabled then
                        self:DoOpenGift()
                    else
                        print(
                            "ERROR clicking: shown = " .. tostring(self.shown) .. ", enabled=" .. tostring(self.enabled)
                        )
                    end
                end
            )
        end
        local old_DoOpenGift = giftitemtoast.DoOpenGift
        function giftitemtoast:DoOpenGift(...)
            local date_str = os.date()
            print("TOAST - DoOpenGift - GIFT!!! " .. date_str .. ", " .. ThePlayer.name .. ", " .. ThePlayer.userid)
            old_DoOpenGift(self, ...)
            UpdateGiftData()
        end
    end
    --AddPlayersPostInitEasy(function(inst)
    --	inst:ListenForEvent("giftreceiverupdate",function(inst,data)
    --		print("GIFT EVENT!!! numitems="..data.numitems..", active="..tostring(data.active))
    --	end)
    --end)

    ---------------------------

    local TEST_SERVER_NAME = "Test World"
    local IS_TEST_MODE = (_G.TheNet:GetServerName() == TEST_SERVER_NAME)
    --print("NAME:",_G.TheNet:GetServerName())
    --print("IS_TEST_MODE",IS_TEST_MODE)

    if not _G.rawget(_G, "inv") then
    --print("PRIVATE ERROR: Cheats mod is not enabled.")
    --return
    end

    --print("GetIsClient",_G.TheNet:GetIsClient())

    --if not _G.TheNet:GetIsClient() then
    if false and not _G.TheNet:GetIsClient() then --dirty hack
        print("dirty hack")
        AddPrefabPostInit(
            "world",
            function(inst)
                print("TEST AddPrefabPostInit")
                print(tostring(modinfo.all_clients_require_mod), tostring(modinfo.client_only_mod))
                if IS_TEST_MODE then
                    print("test mode")
                    inst:WatchWorldState(
                        "cycles",
                        function(w)
                            if w.state.iswinter and _G.rawget(_G, "next_season") then
                                _G.next_season()
                            end
                        end
                    )
                    if _G.rawget(_G, "inv") and _G.rawget(_G, "MakePhantom") then
                        --inst.fire_forever_task:Cancel()
                        print("Making total superman...")
                        inst.admin_init_task =
                            inst:DoPeriodicTask(
                            0.1,
                            function(inst)
                                local player = _G.AllPlayers[1]
                                if not player then
                                    return
                                end
                                print("Player found = " .. tostring(player))
                                _G.inv(1)
                                _G.MakePhantom(true)
                                inst.admin_init_task:Cancel()
                                inst.admin_init_task = nil
                                --do return end
                                local x, y, z = player.Transform:GetWorldPosition()
                                local ents = _G.TheSim:FindEntities(x, y, z, 30, {"structure"})
                                for i, v in ipairs(ents) do
                                    if v.components.burnable and not v:HasTag("campfire") then
                                        v:RemoveComponent("burnable")
                                    end
                                    if v.components.workable then
                                        v:RemoveComponent("workable")
                                    end
                                end
                                local is_seeds_fn = function(v)
                                    return v.prefab == "seeds"
                                end
                                local seeds_fn
                                seeds_fn = function(player)
                                    --print("seeds_fn")
                                    local seeds = player.components.inventory:FindItem(is_seeds_fn)
                                    --print("seeds",tostring(seeds))
                                    if not seeds then
                                        local seeds_item = _G.SpawnPrefab("seeds")
                                        --print("seeds_item",tostring(seeds_item))
                                        if seeds_item then
                                            seeds_item.components.stackable.stacksize = 40
                                            player.components.inventory:GiveItem(seeds_item)
                                        end
                                        seeds = player.components.inventory:FindItem(is_seeds_fn)
                                    end
                                    if not seeds then
                                        print("ERROR: can't give seeds and eat")
                                        return
                                    end
                                    player.components.eater:Eat(seeds)
                                    player:DoTaskInTime((1 + 3.5 * math.random()) * 60, seeds_fn)
                                    return true
                                end
                                player:DoTaskInTime(2, seeds_fn)
                            end
                        )
                        inst.fire_forever_task =
                            inst:DoPeriodicTask(
                            0.4,
                            function(inst)
                                local player = _G.AllPlayers[1]
                                if not player then
                                    return
                                end
                                local x, y, z = player.Transform:GetWorldPosition()
                                local ents = _G.TheSim:FindEntities(x, y, z, 30, {"structure"})
                                for i, v in ipairs(ents) do
                                    local f = v.components.fueled
                                    if f and f.maxfuel > f.currentfuel * 1.95 then
                                        f:DoDelta(f.maxfuel * 0.05)
                                    end
                                end
                            end
                        )
                    else
                        print("Private mod error on init")
                        print(tostring(_G.rawget(_G, "inv")), tostring(_G.rawget(_G, "MakePhantom")))
                    end
                    return
                end
                --_G.scale(0.1)
            end
        )
    end

    if IS_TEST_MODE then
        local function DelInst0(inst)
            inst:DoTaskInTime(0, inst.Remove)
        end
        AddPrefabPostInit("hound", DelInst0)
        AddPrefabPostInit("firehound", DelInst0)
        AddPrefabPostInit("icehound", DelInst0)
        AddPrefabPostInit("frog", DelInst0)
    end

    local function OnTrackRemove(inst)
        --print("OnRemove!")
        if not inst.my_children then
            return
        end
        --print("Kill All")
        for child, _ in pairs(inst.my_children) do
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
        local x, y, z = inst.Transform:GetWorldPosition()
        local changed = true
        for k, v in pairs(inst.my_children) do
            if not k:IsValid() then
                inst.my_children[k] = nil
            else
                local x0, y0, z0 = k.Transform:GetWorldPosition()
                if math.abs(x - x0) + math.abs(z - z0) < 0.001 then
                    changed = false
                    break
                else
                    k.Transform:SetPosition(x, 0, z)
                end
            end
        end
        if changed then
            inst.my_children_no_move = -1800
            for k, v in pairs(inst.my_children) do
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

    local function MyAddChild(inst, prefab, must_track, anim, scale, condition_fn)
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
        inst:DoTaskInTime(
            0,
            function(inst)
                if not inst:IsValid() then
                    return
                end
                local x, y, z = inst.Transform:GetWorldPosition()
                child.Transform:SetPosition(x, 0, z)
                if anim ~= nil then
                    child.AnimState:PlayAnimation(anim)
                end
                if scale ~= nil then
                    child.Transform:SetScale(scale, scale, scale)
                end
                if must_track ~= nil and inst.my_children_task == nil then
                    inst.my_children_stop_update = LAZY_TICKS
                    inst.my_children_no_move = 0
                    inst.my_children_task = inst:DoPeriodicTask(0.01, TrackUpdate)
                end
                --child.AnimState:SetMultColour(r,g,b,a)
            end
        )
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
    AddPrefabPostInit(
        "gestalt",
        function(inst)
            --MyAddChild(inst,"private_arrow_down") --,must_track,anim,scale)
            MyAddChild(inst, "private_arrow_down", true, nil, 0)
            local circle = MyAddChild(inst, "private_circle") --,must_track,anim,scale)
            if circle then
                local r = 2
                circle:SetRadius(r)
                SetCol(circle, COL_RED)
            end
        end
    )

    --crawlingnightmare
    AddPrefabPostInit(
        "crawlingnightmare",
        function(inst)
            --MyAddChild(inst,"private_arrow_down") --,must_track,anim,scale)
            MyAddChild(inst, "private_arrow_down", true, nil, 0)
            local circle = MyAddChild(inst, "private_circle") --,must_track,anim,scale)
            if circle then
                local r = 2
                circle:SetRadius(r)
                SetCol(circle, COL_WHITE)
            end
        end
    )

    --crawling horror
    AddPrefabPostInit(
        "crawlinghorror",
        function(inst)
            --MyAddChild(inst,"private_arrow_down") --,must_track,anim,scale)
            MyAddChild(inst, "private_arrow_down", true, nil, 0)
            local circle = MyAddChild(inst, "private_circle") --,must_track,anim,scale)
            if circle then
                local r = 2
                circle:SetRadius(r)
                SetCol(circle, COL_WHITE)
            end
        end
    )

    --nightmarebeaks
    AddPrefabPostInit(
        "nightmarebeak",
        function(inst)
            --MyAddChild(inst,"private_arrow_down") --,must_track,anim,scale)
            MyAddChild(inst, "private_arrow_down", true, nil, 0)
            local circle = MyAddChild(inst, "private_circle") --,must_track,anim,scale)
            if circle then
                local r = 2
                circle:SetRadius(r)
                SetCol(circle, COL_WHITE)
            end
        end
    )

    --terrorbeak
    AddPrefabPostInit(
        "terrorbeak",
        function(inst)
            --MyAddChild(inst,"private_arrow_down") --,must_track,anim,scale)
            MyAddChild(inst, "private_arrow_down", true, nil, 0)
            local circle = MyAddChild(inst, "private_circle") --,must_track,anim,scale)
            if circle then
                local r = 2
                circle:SetRadius(r)
                SetCol(circle, COL_WHITE)
            end
        end
    )
    --depth worm
    AddPrefabPostInit(
        "worm",
        function(inst)
            --MyAddChild(inst,"private_arrow_down") --,must_track,anim,scale)
            MyAddChild(inst, "private_arrow_down", true, nil, 0)
            local circle = MyAddChild(inst, "private_circle") --,must_track,anim,scale)
            if circle then
                local r = 2
                circle:SetRadius(r)
                SetCol(circle, COL_RED)
            end
        end
    )

    --treeguard
    AddPrefabPostInit(
        "leif",
        function(inst)
            --MyAddChild(inst,"private_arrow_down") --,must_track,anim,scale)
            MyAddChild(inst, "private_arrow_down", true, nil, .35)
            local circle = MyAddChild(inst, "private_circle") --,must_track,anim,scale)
            if circle then
                local r = 3
                circle:SetRadius(r)
                SetCol(circle, COL_RED)
            end
        end
    )

    --treeguard alt
    AddPrefabPostInit(
        "leif_sparse",
        function(inst)
            --MyAddChild(inst,"private_arrow_down") --,must_track,anim,scale)
            MyAddChild(inst, "private_arrow_down", true, nil, .35)
            local circle = MyAddChild(inst, "private_circle") --,must_track,anim,scale)
            if circle then
                local r = 3
                circle:SetRadius(r)
                SetCol(circle, COL_RED)
            end
        end
    )

    --regular wormlight plant
    AddPrefabPostInit(
        "wormlight_plant",
        function(inst)
            --MyAddChild(inst,"private_arrow_down") --,must_track,anim,scale)
            MyAddChild(inst, "private_arrow_down", true, nil, 0)
            local circle = MyAddChild(inst, "private_circle") --,must_track,anim,scale)
            if circle then
                local r = 3
                circle:SetRadius(r)
                SetCol(circle, COL_GREEN)
            end
        end
    )

    --tentacle
    AddPrefabPostInit(
        "tentacle",
        function(inst)
            --MyAddChild(inst,"private_arrow_down") --,must_track,anim,scale)
            MyAddChild(inst, "private_arrow_down", nil, nil, .30)
            local circle = MyAddChild(inst, "private_circle") --,must_track,anim,scale)
            if circle then
                local r = TUNING.TENTACLE_ATTACK_DIST or 4
                circle:SetRadius(r)
                SetCol(circle, COL_RED)
            end
        end
    )

    --Lureplant
    AddPrefabPostInit(
        "lureplant",
        function(inst)
            local circle = MyAddChild(inst, "private_circle") --,must_track,anim,scale)
            if circle then
                circle:SetRadius(11)
            end
        end
    )

    AddPrefabPostInit(
        "wasphive",
        function(inst)
            local circle = MyAddChild(inst, "private_circle") --,must_track,anim,scale)
            if circle then
                circle:SetRadius(10)
                SetCol(circle, COL_ORANGE)
            end
        end
    )

    AddPrefabPostInit(
        "dirtpile",
        function(inst)
            local circle = MyAddChild(inst, "private_circle") --,must_track,anim,scale)
            if circle then
                circle:SetRadius(5)
                SetCol(circle, COL_WHITE)
            end
        end
    )

    --spore red
    AddPrefabPostInit(
        "spore_medium",
        function(inst)
            MyAddChild(inst, "private_arrow_down", true, nil, 0) --,must_track,anim,scale)
            local circle = MyAddChild(inst, "private_circle") --,must_track,anim,scale)
            if circle then
                local r = 2
                circle:SetRadius(r)
                SetCol(circle, COL_RED)
            end
        end
    )

    --spore blue
    AddPrefabPostInit(
        "spore_tall",
        function(inst)
            MyAddChild(inst, "private_arrow_down", true, nil, 0) --,must_track,anim,scale)
            local circle = MyAddChild(inst, "private_circle") --,must_track,anim,scale)
            if circle then
                local r = 2
                circle:SetRadius(r)
                SetCol(circle, COL_BLUE)
            end
        end
    )

    --spore green
    AddPrefabPostInit(
        "spore_small",
        function(inst)
            MyAddChild(inst, "private_arrow_down", true, nil, 0) --,must_track,anim,scale)
            local circle = MyAddChild(inst, "private_circle") --,must_track,anim,scale)
            if circle then
                local r = 2
                circle:SetRadius(r)
                SetCol(circle, COL_GREEN)
            end
        end
    )

    --toys
    AddPrefabPostInit(
        "lost_toy_1",
        function(inst)
            MyAddChild(inst, "private_arrow_down", nil, nil, 2)
            local circle = MyAddChild(inst, "private_circle") --,must_track,anim,scale)
            if circle then
                circle:SetRadius(5)
            end
        end
    )
    AddPrefabPostInit(
        "lost_toy_2",
        function(inst)
            MyAddChild(inst, "private_arrow_down", nil, nil, 1.3)
            local circle = MyAddChild(inst, "private_circle") --,must_track,anim,scale)
            if circle then
                circle:SetRadius(5)
            end
        end
    )
    AddPrefabPostInit(
        "lost_toy_7",
        function(inst)
            MyAddChild(inst, "private_arrow_down", nil, nil, 1.3)
            local circle = MyAddChild(inst, "private_circle") --,must_track,anim,scale)
            if circle then
                circle:SetRadius(5)
            end
        end
    )
    AddPrefabPostInit(
        "lost_toy_10",
        function(inst)
            MyAddChild(inst, "private_arrow_down", nil, nil, 1.3)
            local circle = MyAddChild(inst, "private_circle") --,must_track,anim,scale)
            if circle then
                circle:SetRadius(5)
            end
        end
    )
    AddPrefabPostInit(
        "lost_toy_11",
        function(inst)
            MyAddChild(inst, "private_arrow_down", nil, nil, 1.3)
            local circle = MyAddChild(inst, "private_circle") --,must_track,anim,scale)
            if circle then
                circle:SetRadius(5)
            end
        end
    )
    AddPrefabPostInit(
        "lost_toy_14",
        function(inst)
            MyAddChild(inst, "private_arrow_down", nil, nil, 1.3)
            local circle = MyAddChild(inst, "private_circle") --,must_track,anim,scale)
            if circle then
                circle:SetRadius(5)
            end
        end
    )
    AddPrefabPostInit(
        "lost_toy_18",
        function(inst)
            MyAddChild(inst, "private_arrow_down", nil, nil, 1.3)
            local circle = MyAddChild(inst, "private_circle") --,must_track,anim,scale)
            if circle then
                circle:SetRadius(5)
            end
        end
    )
    AddPrefabPostInit(
        "lost_toy_19",
        function(inst)
            MyAddChild(inst, "private_arrow_down", nil, nil, 1.3)
            local circle = MyAddChild(inst, "private_circle") --,must_track,anim,scale)
            if circle then
                circle:SetRadius(5)
            end
        end
    )
    AddPrefabPostInit(
        "lost_toy_42",
        function(inst)
            MyAddChild(inst, "private_arrow_down", nil, nil, 1.3)
            local circle = MyAddChild(inst, "private_circle") --,must_track,anim,scale)
            if circle then
                circle:SetRadius(5)
            end
        end
    )
    AddPrefabPostInit(
        "lost_toy_43",
        function(inst)
            MyAddChild(inst, "private_arrow_down", nil, nil, 1.3)
            local circle = MyAddChild(inst, "private_circle") --,must_track,anim,scale)
            if circle then
                circle:SetRadius(5)
            end
        end
    )

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
    AddPrefabPostInit(
        "buriedtreasurechest",
        function(inst)
            MyAddChild(inst, "private_arrow_down", false, "green") --,scale)
        end
    )

    --[[
local function CheckCircleLeaf(inst)
	if not inst:HasTag("monster") then --Проверяем, является ли дерево Энтом. Если нет, то пока.
		return
	end
	if inst.my_children then --Вероятно уже есть круг.
		return
	end
	local circle = MyAddChild(inst,"private_circle")
	if circle then
		circle:SetRadius(4) --3.7
	end
end

AddPrefabPostInit("deciduoustree",function(inst)
	if not inst.components.growable then
		return
	end
	local old_DoGrowth = inst.components.growable.DoGrowth
	inst.components.growable.DoGrowth = function(self,...)
		CheckCircleLeaf(self.inst)
		return old_DoGrowth(self,...)
	end
	local old_StopGrowing = inst.components.growable.StopGrowing
	inst.components.growable.StopGrowing = function(self,...)
		CheckCircleLeaf(self.inst)
		return old_StopGrowing(self,...)
	end
end)
--]]
    local player_indicators = {}

    local function UpdatePlayerIndicators()
        if not _G.ThePlayer then
            return
        end
        local x0, y0, z0 = _G.ThePlayer.Transform:GetWorldPosition()
        for player, indicator in pairs(player_indicators) do
            if not player:IsValid() or not indicator:IsValid() then
                player_indicators[player] = nil
            else
                local x, y, z = player.Transform:GetWorldPosition()
                local dx, dy = (x - x0), (z - z0)
                if math.abs(dx) > 5 or math.abs(dy) > 5 then
                    local alpha = math.deg(math.atan2(dx, dy)) + 180
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
                        indicator.AnimState:OverrideMultColour(col_new[1], col_new[2], col_new[3], col_new[4]) --[02:35:44]: Stale Component Reference:
                    end
                else
                    indicator:Hide()
                end
            end
        end
    end

    --must_track=true
    local function AddTrackingIndicator(inst, scale, condition, r, g, b, a)
        inst:DoTaskInTime(
            0,
            function(inst)
                if _G.ThePlayer == nil then
                    return print("No local player", inst)
                end
                if condition ~= nil and not condition then
                    return --print("Bad condition",inst)
                end
                local indicator =
                    MyAddChild(
                    _G.ThePlayer,
                    "private_circle", --prefab
                    true,
                    "up", --arrow up anim
                    scale, --scale
                    condition --condition function
                )
                if indicator then
                    if r ~= nil then
                        indicator.custom_rgba = {r, g, b, a}
                    end
                    player_indicators[inst] = indicator
                    inst:ListenForEvent(
                        "onremove",
                        function()
                            if indicator:IsValid() then
                                if indicator.my_parent then
                                    indicator.my_parent.my_children[indicator] = nil
                                end
                                indicator.my_parent = nil
                                indicator:Remove()
                            end
                        end
                    )
                    UpdatePlayerIndicators()
                end
            end
        )
    end
    --

    --[[AddPlayersPostInitEasy(function(inst)
	AddTrackingIndicator(inst,2)
end)]] AddPrefabPostInit(
        "world",
        function(inst)
            inst:DoPeriodicTask(
                0.2 + 0.01 * math.random(),
                function(inst)
                    UpdatePlayerIndicators()
                end
            )
        end
    )

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
    AddPrefabPostInit(
        "dirtpile",
        function(inst)
            --AddTrackingIndicator(inst,1.5,nil, 0, 0.4, 1, .5) --blue outline
            AddTrackingIndicator(inst, 1.5, nil, 0, 0.4, 1, 1) --blue outline
        end
    )

    AddPrefabPostInit(
        "pighead",
        function(inst)
            AddTrackingIndicator(inst, 2.5, nil, .40, 0, 0, 0) --red smear
        end
    )

    AddPrefabPostInit(
        "livingtree",
        function(inst)
            AddTrackingIndicator(inst, 1.75, nil, .1, 1, 0, 0) --green outline mix inside
        end
    )

    AddPrefabPostInit(
        "walrus_camp",
        function(inst)
            AddTrackingIndicator(inst, 1.75, nil, .5, .6, .7, .8) --red and white default with less sharpness
        end
    )

    --toy section
    AddPrefabPostInit(
        "lost_toy_1",
        function(inst)
            AddTrackingIndicator(inst, 2, nil, 0, 1, 1, 0) --teal
        end
    )
    AddPrefabPostInit(
        "lost_toy_2",
        function(inst)
            AddTrackingIndicator(inst, 2, nil, 0, 1, 1, 0) --teal
        end
    )
    AddPrefabPostInit(
        "lost_toy_7",
        function(inst)
            AddTrackingIndicator(inst, 2, nil, 0, 1, 1, 0) --teal
        end
    )
    AddPrefabPostInit(
        "lost_toy_10",
        function(inst)
            AddTrackingIndicator(inst, 2, nil, 0, 1, 1, 0) --teal
        end
    )
    AddPrefabPostInit(
        "lost_toy_11",
        function(inst)
            AddTrackingIndicator(inst, 2, nil, 0, 1, 1, 0) --teal
        end
    )
    AddPrefabPostInit(
        "lost_toy_14",
        function(inst)
            AddTrackingIndicator(inst, 2, nil, 0, 1, 1, 0) --teal
        end
    )
    AddPrefabPostInit(
        "lost_toy_18",
        function(inst)
            AddTrackingIndicator(inst, 2, nil, 0, 1, 1, 0) --teal
        end
    )
    AddPrefabPostInit(
        "lost_toy_19",
        function(inst)
            AddTrackingIndicator(inst, 2, nil, 0, 1, 1, 0) --teal
        end
    )
    AddPrefabPostInit(
        "lost_toy_42",
        function(inst)
            AddTrackingIndicator(inst, 2, nil, 0, 1, 1, 0) --teal
        end
    )
    AddPrefabPostInit(
        "lost_toy_43",
        function(inst)
            AddTrackingIndicator(inst, 2, nil, 0, 1, 1, 0) --teal
        end
    )

    local function AddBossIndicator(inst)
        if _G.ThePlayer == nil then
            return
        else
            --print(tostring(_G.ThePlayer))
            AddTrackingIndicator(inst, 2.8)
            --print('Found Boss:',inst.prefab and inst.prefab:upper())
            _G.ThePlayer.components.talker:Say("Found entity: " .. tostring(inst.prefab and inst.prefab:upper()))
        end
    end
    --boss

    AddPrefabPostInit("antlion", AddBossIndicator)
    --AddPrefabPostInit("antlion_spawner",AddBossIndicator)
    AddPrefabPostInit("spat", AddBossIndicator)
    AddPrefabPostInit("warg", AddBossIndicator)
    AddPrefabPostInit("bearger", AddBossIndicator)
    --AddPrefabPostInit("walrus",AddBossIndicator)

    do
        return
    end

    do
        local function GetEquippedItem(self, eslot)
            return self._equipspreview ~= nil and self._equipspreview[eslot] or
                (self._equips[eslot] ~= nil and self._equips[eslot]:value() or nil)
        end
        local back = _G.EQUIPSLOTS.BACK or _G.EQUIPSLOTS.BODY --compatible with "Extra Equip Slots" mod
        local function GetOverflowContainer(self)
            local item = GetEquippedItem(self, back)
            return item ~= nil and item.replica.container or nil
        end
        local function Count(item)
            return item.replica.stackable ~= nil and item.replica.stackable:StackSize() or 1
        end

        --local inv_rep = require "components/inventory_replica"
        local function MyUpdateInventory(inst, result_table)
            local new_inventory = result_table or {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil}
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
        AddPrefabPostInit(
            "inventory_classified",
            function(inst)
                inst.MyUpdateInventory = MyUpdateInventory
            end
        )

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
        AddPrefabPostInit(
            "container_classified",
            function(inst)
                inst.MyUpdateInventoryContainer = MyUpdateInventoryContainer
            end
        )

        local save_local  --local inventory
        local function UpdateRecipes(inst)
            inst.count_gold =
                (save_local.goldnugget or 0) +
                (save_local.spear or save_local.hambat or save_local.cane or save_local.armorwood or
                    save_local.footballhat or
                    save_local.goldenshovel or
                    save_local.goldenaxe or
                    save_local.goldenpickaxe or
                    save_local.heatrock or
                    0) *
                    100
            inst.count_flints = (save_local.flint or 0) + (save_local.rocks or 0) * 0.5 + (save_local.log or 0) * 0.5
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
        AddPlayersPostInitEasy(
            function(inst)
                --print("THEPLAYER == "..tostring(_G.ThePlayer))
                local init_timer
                init_timer =
                    inst:DoPeriodicTask(
                    0.3,
                    function(inst)
                        if not _G.ThePlayer then
                            return
                        end
                        init_timer:Cancel()
                        if inst == _G.ThePlayer then
                            inst.recipes_task = inst:DoPeriodicTask(0.5 + math.random() * 0.1, OnTickFn)
                        end
                    end
                )
            end
        )
    end --[[AddPrefabPostInit("animal_track",function(inst)
	local indicator = MyAddChild(inst,
		"private_circle", --prefab
		false, --,must_track.
		"up", --arrow up anim
		2.5 --scale
	)
	if indicator then
		local direction = inst.Transform:GetRotation() --Направление следа.
		indicator.Transform:SetRotation(direction)
	end
end)]]
    --
    --

    --[[AddPrefabPostInit("flint",function(inst)
	AddTrackingIndicator(inst,1.5,
		function() return(_G.ThePlayer and _G.ThePlayer.count_flints and _G.ThePlayer.count_flints<10) end,
		0, 0.4, 1, 1)
end)


AddPrefabPostInit("goldnugget",function(inst)
	AddTrackingIndicator(inst,1.5,
		function() return(_G.ThePlayer and _G.ThePlayer.count_gold and _G.ThePlayer.count_gold<6) end)--,
		--0, 0.4, 1, 1)
end)]] AddPrefabPostInit(
        "dirtpile",
        function(inst)
            MyAddChild(inst, "private_arrow_down", false, "green") --,scale)
            local circle = MyAddChild(inst, "private_circle") --,must_track,anim,scale)
            if circle then
                circle:SetRadius(4)
            end
            AddTrackingIndicator(inst, 1.5)
        end
    )
    --

    --[[AddPrefabPostInit("cane",function(inst)
	AddTrackingIndicator(inst,1.7)
end)]] AddPrefabPostInit(
        "gears",
        function(inst)
            AddTrackingIndicator(inst, 1.5, nil, 0, 0.4, 1, 1)
        end
    )
end

error(111)

print(ver)