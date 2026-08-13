--***********************************************************
--**                         AMENOPHIS                     **
--***********************************************************

require "TimedActions/ISBaseTimedAction";

ISCorpseHairCutting = ISBaseTimedAction:derive("ISCorpseHairCutting");

function ISCorpseHairCutting:isValid()
    if not self.corpse or self.corpse:getStaticMovingObjectIndex() < 0 then
        return false;
    end
    return true;
end

function ISCorpseHairCutting:waitToStart()
    self.character:faceThisObject(self.corpse);
    return self.character:shouldBeTurning();
end

function ISCorpseHairCutting:update()
    self.item:setJobDelta(self:getJobDelta());
    self.character:faceThisObject(self.corpse);
    self.character:setMetabolicTarget(Metabolics.LightWork);
end

function ISCorpseHairCutting:start()
    if(self.isRazor) then
        self.item:setJobType(getText("ContextMenu_ShaveRazorCorpseHair"));
    elseif(self.isShear) then
        self.item:setJobType(getText("ContextMenu_ShaveCorpseHair"));
    else
        self.item:setJobType(getText("ContextMenu_CutCorpseHair"));
    end
    self.item:setJobDelta(0.0);

    if self.isShear then
        if self.item:IsDrainable() then
            self.sound = self.character:playSound("AnimalFoleyShearSheepElectric");
        else
            self.sound = self.character:playSound("AnimalFoleyShearSheepManual");
        end
    elseif self.isRazor then
        self.sound = self.character:playSound("ShaveRazor");
    else
        self.sound = self.character:playSound("HairCutScissors");
    end

    self:setActionAnim("Shear");
    self:setOverrideHandModels(self.item, nil);
end

function ISCorpseHairCutting:stop()
    self:stopSound();
    self.item:setJobDelta(0.0);
    ISBaseTimedAction.stop(self);
end

function ISCorpseHairCutting:perform()
    self:stopSound();
    self.item:setJobDelta(0.0);

    if(isMultiplayer() and isClient()) then
        self:updateCorpseVisual();
    end

    ISBaseTimedAction.perform(self);
    return true;
end

function ISCorpseHairCutting:complete()
    self:completeAction();
    return true;
end

function ISCorpseHairCutting:updateCorpseVisual()
    local visual = self.corpse:getHumanVisual();
    if not visual then return; end
    local hairModel = visual:getHairModel() or "";

    local newHairModel = hairModel;
    local newBeardModel = not self.corpse:isFemale() and (visual:getBeardModel() or "") or "";

    local hairStyleData = CorpseHairCuttingUtils.getHairStyle(hairModel);
    local beardStyleData = CorpseHairCuttingUtils.getBeardStyle("");

    if not self.corpse:isFemale() then
        beardStyleData = CorpseHairCuttingUtils.getBeardStyle(visual:getBeardModel() or "");
    end

    if self.isShear or self.isRazor then
        newHairModel = "";
        if not self.corpse:isFemale() then
            newBeardModel = "";
        end
    else
        if hairStyleData and hairStyleData.length > CorpseHairCuttingUtils.hairLengths.s then
            newHairModel = "Short";
        end
        if not self.corpse:isFemale() and beardStyleData and beardStyleData.length > CorpseHairCuttingUtils.hairLengths.s then
            newBeardModel = "Full";
        end
    end

    local sq = self.corpse:getSquare();
    if sq then
        if isMultiplayer() and isClient() then
            local args = {
                x = sq:getX(),
                y = sq:getY(),
                z = sq:getZ(),
                index = self.corpse:getStaticMovingObjectIndex(),
                hairModel = newHairModel,
                beardModel = newBeardModel
            };
            sendClientCommand("CorpseHair", "UpdateCorpseVisual", args);
            self.corpse:transmitModData();
        else
            visual:setHairModel(newHairModel);
            if not self.corpse:isFemale() then
                visual:setBeardModel(newBeardModel);
            end
            self.corpse:invalidateCorpse();
        end
    end
end

function ISCorpseHairCutting:completeAction()
    local visual = self.corpse:getHumanVisual();
    if not visual then return; end

    local hairModel = visual:getHairModel() or "";
    local immuColor = visual:getHairColor();
    local color = Color.new(immuColor:getRedFloat(), immuColor:getGreenFloat(), immuColor:getBlueFloat(), 1);    
    
    local hairStyleData = CorpseHairCuttingUtils.getHairStyle(hairModel);
    local beardStyleData = CorpseHairCuttingUtils.getBeardStyle("");
    
    local scissorsPenaltyMultiplier = 0;
    
    if hairModel ~= "" and hairModel ~= "Bald" and hairStyleData and hairStyleData.length > CorpseHairCuttingUtils.hairLengths.s then
        scissorsPenaltyMultiplier = scissorsPenaltyMultiplier + 1;
    end
    
    if not self.corpse:isFemale() then
        local beardModel = visual:getBeardModel() or "";
        beardStyleData = CorpseHairCuttingUtils.getBeardStyle(beardModel);
        if beardModel ~= "" and beardStyleData and beardStyleData.length > CorpseHairCuttingUtils.hairLengths.s then
            scissorsPenaltyMultiplier = scissorsPenaltyMultiplier + 1;
        end
    end
    
    local scissorsPenalty = ZombRand(1 * scissorsPenaltyMultiplier, 2 * scissorsPenaltyMultiplier);
    local qtyMin = 0;
    local qtyMax = 0;
    
    if self.isScissors then
        if hairStyleData and hairStyleData.length > CorpseHairCuttingUtils.hairLengths.s then
            qtyMin = qtyMin + hairStyleData.qtyMin;
            qtyMax = qtyMax + hairStyleData.qtyMax;
        end
        
        if beardStyleData and beardStyleData.length > CorpseHairCuttingUtils.hairLengths.s then
            qtyMin = qtyMin + beardStyleData.qtyMin;
            qtyMax = qtyMax + beardStyleData.qtyMax;
        end
    
        qtyMin = qtyMin - scissorsPenalty;
        qtyMax = qtyMax - scissorsPenalty;
        
        qtyMin = PZMath.max(1, qtyMin);
        qtyMax = PZMath.max(1, qtyMax);
    else
        if hairStyleData and hairStyleData.length > 0 then
            qtyMin = qtyMin + hairStyleData.qtyMin;
            qtyMax = qtyMax + hairStyleData.qtyMax;
        end
        
        if beardStyleData and beardStyleData.length > 0 then
            qtyMin = qtyMin + beardStyleData.qtyMin;
            qtyMax = qtyMax + beardStyleData.qtyMax;
        end
    end
        
    local qty = ZombRand(qtyMin, qtyMax);
    local md = self.corpse:getModData();
    
    if md.cuttingHairQtyCollected and md.cuttingHairScissorsPenalty then
        scissorsPenalty = md.cuttingHairScissorsPenalty;
        qty = scissorsPenalty;
    end
    
    md.cuttingHairScissorsPenalty = scissorsPenalty;
    md.cuttingHairQtyCollected = qty;

    local itemsToAdd = ArrayList.new();
    for i = 1, qty do
        local itemName = (ZombRand(1, 4) == 1) and "Base.HairTuft" or "Base.HairTuftDirty";
        local item = instanceItem(itemName);
        
        local itemVisual = item:getVisual();
        if itemVisual then
            itemVisual:setTint(immuColor);
        end
        
        item:setColorRed(immuColor:getRedFloat());
        item:setColorGreen(immuColor:getGreenFloat());
        item:setColorBlue(immuColor:getBlueFloat());
        item:setColor(color);
        item:setCustomColor(true);
        
        self.character:getInventory():AddItem(item);
        itemsToAdd:add(item);
    end

    if itemsToAdd:size() > 0 then
        sendAddItemsToContainer(self.character:getInventory(), itemsToAdd);
    end

    self:updateCorpseVisual();
end

function ISCorpseHairCutting:getDuration()
    if self.character:isTimedActionInstant() then
        return 1;
    end
    
    local duration = 300;
    if self.isShear then
        duration = self.item:IsDrainable() and 120 or 180;
    elseif self.isRazor then
        duration = 240;
    else
        duration = 300;
    end
    
    return duration;
end

function ISCorpseHairCutting:stopSound()
    if self.sound and self.character:getEmitter():isPlaying(self.sound) then
        self.character:stopOrTriggerSound(self.sound);
    end
end

function ISCorpseHairCutting:new(character, corpse, item)
    local o = ISBaseTimedAction.new(self, character);
    o.character = character;
    o.item = item;
    o.corpse = corpse;
    o.isShear = item:hasTag(ItemTag.SHEAR) or (item:getType() == "Shears");
    o.isRazor = item:hasTag(ItemTag.RAZOR) or (item:getType() == "Razor");
    o.isScissors = item:hasTag(ItemTag.SCISSORS) or (item:getType() == "Scissors");
    o.maxTime = o:getDuration();
    return o;
end

local function onServerCommand(module, command, args)
	
    if module == "CorpseHair" and command == "SyncCorpseVisual" then
		
        local sq = getSquare(args.x, args.y, args.z);
        if sq then
            local staticObjects = sq:getStaticMovingObjects();
            for i = 0, staticObjects:size() - 1 do
                local obj = staticObjects:get(i);
                if instanceof(obj, "IsoDeadBody") and obj:getStaticMovingObjectIndex() == args.index then
                    local visual = obj:getHumanVisual();
                    if visual then
                        visual:setHairModel(args.hairModel or "");
                        if not obj:isFemale() then
                            visual:setBeardModel(args.beardModel or "");
                        end
                        obj:invalidateCorpse();
						print("CLIENT COMMAND")
						print(args.hairModel)
						print(args.beardModel)
                    end
                    break;
                end
            end
        end
    end
end

Events.OnServerCommand.Add(onServerCommand);