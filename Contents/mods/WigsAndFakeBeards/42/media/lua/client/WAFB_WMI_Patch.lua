require "ISUI/ISWorldObjectContextMenu";
require "TimedActions/ISWashClothing";
require "TimedActions/ISInventoryTransferAction";
require "TimedActions/ISBaseTimedAction";
require "TimedActions/ISTimedActionQueue";

if(getActivatedMods():contains("WashFix")) then

WFB = WFB or {};
WFB.debug = false;
local function log(...)
    if not WFB.debug then return; end
    local t = {};
    for i = 1, select("#", ...) do t[#t + 1] = tostring(select(i, ...)); end
    print("[WFB-Wash] " .. table.concat(t, " "));
end

-- ---------------------------------------------------------------------------
-- Items already covered by WMI's own modules - never duplicate these.
-- Extend this set if WMI adds more dirty-cloth types later.
-- ---------------------------------------------------------------------------
local WMI_HANDLED_FULLTYPES = {
    ["Base.BandageDirty"]       = true,
    ["Base.RippedSheetsDirty"]  = true,
    ["Base.DenimStripsDirty"]   = true,
    ["Base.LeatherStripsDirty"] = true,
};

-- ---------------------------------------------------------------------------
-- Build-version compatibility (same trick WMI itself uses)
-- ---------------------------------------------------------------------------
local function WFB_IsB4215Plus()
    if not getGameVersion then return false; end
    local version = tostring(getGameVersion() or "");
    local major, minor = string.match(version, "^(%d+)%.(%d+)");
    major = tonumber(major) or 0;
    minor = tonumber(minor) or 0;
    return (major > 42) or (major == 42 and minor >= 15);
end

local function WFB_NewWashAction(playerObj, sink, soapList, item, bloodAmount, dirtAmount, noSoap, returnContainer, waterOverride)
    if WFB_IsB4215Plus() then
        -- 42.15+: soaps fetched internally by vanilla, no soapList arg.
        return ISWashClothing:new(playerObj, sink, item, bloodAmount, dirtAmount, noSoap, returnContainer, waterOverride);
    end
    return ISWashClothing:new(playerObj, sink, soapList, item, bloodAmount, dirtAmount, noSoap, returnContainer, waterOverride);
end

local function WFB_HasTag(item, tagString, tagEnum)
    if not item then return false; end
    if tagEnum ~= nil then
        local ok, res = pcall(item.hasTag, item, tagEnum);
        if ok then return res; end
    end
    local ok, res = pcall(item.hasTag, item, tagString);
    if ok then return res; end
    return false;
end

-- ---------------------------------------------------------------------------
-- Sandbox: water cost per item washed (tweak the default to taste)
-- ---------------------------------------------------------------------------
local function _getSandboxDouble(name, defaultValue)
    local ok, opts = pcall(getSandboxOptions);
    if not ok or not opts or not opts.getOptionByName then return defaultValue; end
    local opt = opts:getOptionByName(name);
    if not opt or not opt.getValue then return defaultValue; end
    local v = opt:getValue();
    return (type(v) == "number") and v or defaultValue;
end

local function _hairWaterPerItem()
    local v = _getSandboxDouble("WFB.HairWaterPerItem", 4.0);
    if v < 0.01 then v = 0.01; end
    return v;
end

-- ---------------------------------------------------------------------------
-- Soap list (bar soap + bleach/cleaning liquid) - mirrors vanilla rule
-- ---------------------------------------------------------------------------
local function _predicateCleaningLiquid(item)
    if not item or not item.hasComponent then return false; end
    if not item:hasComponent(ComponentType.FluidContainer) then return false; end
    local fc = item:getFluidContainer();
    if not fc then return false; end
    local okBleach = (Fluid and Fluid.Bleach and fc.contains and fc:contains(Fluid.Bleach)) or false;
    local okClean  = (Fluid and Fluid.CleaningLiquid and fc.contains and fc:contains(Fluid.CleaningLiquid)) or false;
    if not (okBleach or okClean) then return false; end
    return fc:getAmount() >= (ZomboidGlobals and ZomboidGlobals.CleanBloodBleachAmount or 1);
end

local function _buildSoapList(playerObj)
    local inv = playerObj:getInventory();
    if inv and inv.getSoapList then
        local ok, soaps = pcall(inv.getSoapList, inv, nil, true);
        if ok and soaps then return soaps; end
    end
    local soapList = {};
    local barList = inv:getItemsFromType("Soap2", true);
    if barList and barList.size then
        for i = 0, barList:size() - 1 do soapList[#soapList + 1] = barList:get(i); end
    end
    local bottleList = inv:getAllEvalRecurse(_predicateCleaningLiquid);
    if bottleList and bottleList.size then
        for i = 0, bottleList:size() - 1 do soapList[#soapList + 1] = bottleList:get(i); end
    end
    return soapList;
end

local function _listSize(list)
    if not list then return 0; end
    if list.size then
        local ok, s = pcall(list.size, list);
        return (ok and s) or 0;
    end
    return #list;
end

-- ---------------------------------------------------------------------------
-- Item collection: anything tagged CanBeWashed that WMI's category-based scan
-- would NOT already pick up (i.e. not Clothing/Weapon/Container), excluding
-- fulltypes already handled by WMI_CleanBandagesContext, and that actually
-- transforms into a clean type via ItemAfterCleaning.
-- ---------------------------------------------------------------------------
local function _isAlreadyHandledByWMI(item)
    local cat = item.getCategory and item:getCategory() or nil;
    if cat == "Clothing" or cat == "Weapon" or cat == "Container" then
        return true;
    end
    local fullType = item.getFullType and item:getFullType() or nil;
    if fullType and WMI_HANDLED_FULLTYPES[fullType] then
        return true;
    end
    return false;
end

local function _collectDirtyHair(playerObj)
    local inv = playerObj:getInventory();
    local out = {};
    local all = inv:getItems();
    for i = 0, all:size() - 1 do
        local item = all:get(i);
        if item and not item:isHidden()
            and WFB_HasTag(item, "CanBeWashed", ItemTag.CAN_BE_WASHED)
            and not _isAlreadyHandledByWMI(item)
            and item.getItemAfterCleaning
        then
            local ok, after = pcall(item.getItemAfterCleaning, item);
            if ok and after and after ~= "" then
                table.insert(out, item);
            end
        end
    end
    return out;
end

local function _computeWashAmounts(item)
    if item.getBloodLevel then
        local ok, v = pcall(item.getBloodLevel, item);
        if ok and v then return v, 0; end
    end
    return 1, 0; -- fallback: nonzero so ISWashClothing always has something to "clean"
end

local function _selectByWater(items, waterRemaining, waterPerItem)
    local selected = {};
    if not items or #items == 0 or not waterRemaining or waterRemaining < 1 then return selected; end
    local used = 0;
    for _, it in ipairs(items) do
        if used + waterPerItem > waterRemaining + 1e-6 then break end
        used = used + waterPerItem;
        table.insert(selected, it);
    end
    return selected;
end

-- ---------------------------------------------------------------------------
-- Wash queue (transfer-safe: pulls the item into main inventory first if it's
-- sitting in a bag, same technique as WMI's own bandage cleaner)
-- ---------------------------------------------------------------------------
local function _queueWashItems(playerObj, sink, soapList, items, closeMenu, noSoap, waterPerItem)
    if not items or #items == 0 then return; end
    if not luautils.walkAdj(playerObj, sink:getSquare(), true) then
        log("walkAdj failed");
        return;
    end

    local playerInv = playerObj:getInventory();

    for _, item in ipairs(items) do
        if item then
            local originalContainer = item:getContainer();
            local bloodAmount, dirtAmount = _computeWashAmounts(item);

            if originalContainer and originalContainer ~= playerInv then
                local xfer = ISInventoryTransferAction:new(playerObj, item, originalContainer, playerInv);
                if xfer.setAllowMissingItems then xfer:setAllowMissingItems(true); end
                xfer:setOnComplete(function(action)
                    local moved = action.item;
                    if not moved then return; end
                    local b, d = _computeWashAmounts(moved);
                    local wash = WFB_NewWashAction(playerObj, sink, soapList, moved, b, d, noSoap, originalContainer, waterPerItem);
                    ISTimedActionQueue.addAfter(action, wash);
                end);
                ISTimedActionQueue.add(xfer);
            else
                ISTimedActionQueue.add(WFB_NewWashAction(playerObj, sink, soapList, item, bloodAmount, dirtAmount, noSoap, nil, waterPerItem));
            end
        end
    end

    if closeMenu and closeMenu.closeAll then closeMenu:closeAll(); end
end

-- ---------------------------------------------------------------------------
-- Menu building
-- ---------------------------------------------------------------------------
local function _buildHairMenu(subMenu, playerObj, sink)
    local waterAmount = (sink and sink.getFluidAmount and sink:getFluidAmount()) or 0;
    if not sink or waterAmount < 1 then return; end

    local items = _collectDirtyHair(playerObj);
    if #items == 0 then return; end

    local WASH  = getText("ContextMenu_Wash") or "Wash";
    local LABEL = getText("ContextMenu_CleanHair") or "Clean Hair";

    local optRoot = subMenu:addOption(LABEL);
    local rootSub = ISContextMenu:getNew(subMenu);
    subMenu:addSubMenu(optRoot, rootSub);

    -- Cosmetic: place it right after "Wash" if present.
    for i, o in ipairs(subMenu.options) do
        if o.name == WASH then
            for j, oo in ipairs(subMenu.options) do
                if oo == optRoot then table.remove(subMenu.options, j); break end
            end
            table.insert(subMenu.options, i + 1, optRoot);
            break
        end
    end

    local soapList = _buildSoapList(playerObj);
    local soapRemaining = (_listSize(soapList) >= 1) and ISWashClothing.GetSoapRemaining(soapList) or 0;
    local waterPerItem = _hairWaterPerItem();
    local selected = _selectByWater(items, waterAmount, waterPerItem);

    local allLabel = getText("ContextMenu_AllWithCount", #selected);
    if not allLabel or allLabel == "" then allLabel = "All (" .. #selected .. ")"; end

    rootSub:addActionsOption(allLabel,
        function(pObj, sinkObj, list, soapListRef, soapRemain)
            local reqSoap = 0;
            for _, it in ipairs(list) do reqSoap = reqSoap + ISWashClothing.GetRequiredSoap(it); end
            local noSoap = reqSoap > soapRemain;
            _queueWashItems(pObj, sinkObj, soapListRef, list, rootSub, noSoap, waterPerItem);
        end,
        sink, selected, soapList, soapRemaining);

    if #items > 1 then
        local oneLabel = getText("ContextMenu_One") or "One";
        rootSub:addActionsOption(oneLabel,
            function(pObj, sinkObj, soapListRef)
                local its = _collectDirtyHair(pObj);
                if #its == 0 then return; end
                _queueWashItems(pObj, sinkObj, soapListRef, { its[1] }, rootSub, false, waterPerItem);
            end,
            sink, soapList);
    end
end

-- ---------------------------------------------------------------------------
-- Water-submenu discovery - self-contained, no dependency on WMI internals
-- ---------------------------------------------------------------------------
local function _getSubMenuFromOption(rootContext, opt)
    if not rootContext or not opt or not opt.subOption then return nil; end
    return rootContext:getSubMenu(opt.subOption);
end

local function _isWaterSource(obj)
    if not obj or type(obj) ~= "userdata" then return false; end
    if obj.getFluidAmount then
        local ok, amt = pcall(function() return obj:getFluidAmount(); end);
        if ok and type(amt) == "number" and amt > 0 then return true; end
    end
    if obj.hasWater then
        local ok, has = pcall(function() return obj:hasWater(); end);
        if ok and has then return true; end
    end
    return false;
end

local function _findWaterObjectInSubMenu(sub)
    for _, ch in ipairs(sub.options or {}) do
        for i = 1, 6 do
            local p = ch["param" .. i];
            if _isWaterSource(p) then return p; end
        end
    end
    return nil;
end

local function _iterWaterSubmenus(context)
    local tDrink  = getText("ContextMenu_Drink")  or "Drink";
    local tFill   = getText("ContextMenu_Fill")   or "Fill";
    local tRefill = getText("ContextMenu_Refill") or "Refill";
    local tWash   = getText("ContextMenu_Wash")   or "Wash";

    local out = {};
    for _, top in ipairs(context.options or {}) do
        local sub = _getSubMenuFromOption(context, top);
        if sub and sub.options then
            local hasDrink, hasFill, hasWash = false, false, false;
            for _, ch in ipairs(sub.options) do
                if ch.name == tDrink then hasDrink = true; end
                if ch.name == tFill or ch.name == tRefill then hasFill = true; end
                if ch.name == tWash then hasWash = true; end
            end
            if hasWash or (hasDrink and hasFill) then
                local waterObj = _findWaterObjectInSubMenu(sub);
                if waterObj then table.insert(out, { sub = sub, water = waterObj }); end
            end
        end
    end
    return out;
end


local function onFill(playerNum, context, worldobjects, test)
    if test then return; end

    local playerObj = getSpecificPlayer(playerNum);
    if not playerObj then return; end

    local entries = _iterWaterSubmenus(context);
    if #entries == 0 then
        log("no water submenus");
        return;
    end

    local LABEL = getText("ContextMenu_CleanHair") or "Clean Hair";

    for _, e in ipairs(entries) do
        local already = false;
        for _, opt in ipairs(e.sub.options or {}) do
            if opt.name == LABEL then already = true; break end
        end
        if not already then
            _buildHairMenu(e.sub, playerObj, e.water);
        end
    end
end

    Events.OnFillWorldObjectContextMenu.Add(onFill);
end