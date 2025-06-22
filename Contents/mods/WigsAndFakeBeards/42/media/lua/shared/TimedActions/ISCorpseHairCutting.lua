--***********************************************************
--**                       AMENOPHIS                       **
--***********************************************************

require "TimedActions/ISBaseTimedAction"

ISCorpseHairCutting = ISBaseTimedAction:derive("ISCorpseHairCutting");

function ISCorpseHairCutting:isValid()
    return true;
end

function ISCorpseHairCutting:update()
   	self.item:setJobDelta(self:getJobDelta());
    self.character:setMetabolicTarget(Metabolics.LightWork);
end

function ISCorpseHairCutting:start()
    self.item:setJobType(getText("ContextMenu_CutCorpseHair"));
 	self.item:setJobDelta(0.0);

	if self.isShear  then
		if self.item:IsDrainable()  then
			self.sound = self.character:playSound("AnimalFoleyShearSheepElectric")
		else
			self.sound = self.character:playSound("AnimalFoleyShearSheepManual")
		end
	elseif self.isRazor  then
		self.sound = self.character:playSound("ShaveRazor")
	else
		self.sound = self.character:playSound("HairCutScissors")
	end

    self:setActionAnim("Shear")
    self:setOverrideHandModels(self.item, nil)


end

function ISCorpseHairCutting:stop()
    self:stopSound()
    self.item:setJobDelta(0.0)

    ISBaseTimedAction.stop(self)
end

function ISCorpseHairCutting:perform()
    self:stopSound()
    self.item:setJobDelta(0.0)

    ISBaseTimedAction.perform(self)
end

function ISCorpseHairCutting:complete()
	local hairModel = self.corpse:getHumanVisual():getHairModel()
	local immuColor = self.corpse:getHumanVisual():getHairColor()
	local color = Color.new(immuColor:getRedFloat(), immuColor:getGreenFloat(), immuColor:getBlueFloat(), 1)	
	
	local hairStyleData = CorpseHairCuttingUtils.getHairStyle(hairModel);
	local beardStyleData = CorpseHairCuttingUtils.getBeardStyle("");
	
	local scissorsPenaltyMultiplier = 0;
	
	if hairModel ~= "" and hairModel ~= "Bald" and hairStyleData.length > CorpseHairCuttingUtils.hairLengths.s then
		scissorsPenaltyMultiplier = scissorsPenaltyMultiplier + 1
	end
	
	if not self.corpse:isFemale() then
		local beardModel = self.corpse:getHumanVisual():getBeardModel()
		beardStyleData = CorpseHairCuttingUtils.getBeardStyle(beardModel)
		if beardModel ~= "" and beardStyleData.length > CorpseHairCuttingUtils.hairLengths.s then
			scissorsPenaltyMultiplier = scissorsPenaltyMultiplier + 1
		end
	end
	
	local scissorsPenalty = ZombRand(1 * scissorsPenaltyMultiplier, 2 * scissorsPenaltyMultiplier)
	local qtyMin = 0
	local qtyMax = 0
	
	
	if self.isScissors then
		if hairStyleData.length > CorpseHairCuttingUtils.hairLengths.s then
			qtyMin = qtyMin + hairStyleData.qtyMin
			qtyMax = qtyMax + hairStyleData.qtyMax
		end
		
		if beardStyleData.length > CorpseHairCuttingUtils.hairLengths.s then
			qtyMin = qtyMin + beardStyleData.qtyMin
			qtyMax = qtyMax + beardStyleData.qtyMax
		end
	
		qtyMin = qtyMin - scissorsPenalty
		qtyMax = qtyMax - scissorsPenalty
		
		qtyMin = PZMath.max(1, qtyMin)
		qtyMax = PZMath.max(1, qtyMax)
	else
		
		if hairStyleData.length > 0 then
			qtyMin = qtyMin + hairStyleData.qtyMin
			qtyMax = qtyMax + hairStyleData.qtyMax
		end
		
		if beardStyleData.length > 0 then
			qtyMin = qtyMin + beardStyleData.qtyMin
			qtyMax = qtyMax + beardStyleData.qtyMax
		end
	end
		
	local qty = ZombRand(qtyMin, qtyMax);
	
	local md = self.corpse:getModData();
	
	if md.cuttingHairQtyCollected and md.cuttingHairScissorsPenalty then
		scissorsPenalty = md.cuttingHairScissorsPenalty
		qty = scissorsPenalty
	end
	
	md.cuttingHairScissorsPenalty = scissorsPenalty;
	md.cuttingHairQtyCollected = qty;
	
	for i = 1, qty do
	
		local itemName = "Base.HairTuftDirty"
		
		if(ZombRand(1, 4) == 1) then
			itemName = "Base.HairTuft"
		end
	
		local item = instanceItem(itemName)
		
		local visual = item:getVisual();
		
		if visual then
			visual:setTint(immuColor);
		end
		
		item:setColorRed(immuColor:getRedFloat());
		item:setColorGreen(immuColor:getGreenFloat());
		item:setColorBlue(immuColor:getBlueFloat());
		
		
		item:setColor(color)
		item:setCustomColor(true);
		
		self.character:getInventory():AddItem(item)
		
		i = i + 1
	end
	
	
	if self.isShear or self.isRazor then
		self.corpse:getHumanVisual():setHairModel("")
		if not self.corpse:isFemale() then
			self.corpse:getHumanVisual():setBeardModel("")
		end
	else
		if hairStyleData.length > CorpseHairCuttingUtils.hairLengths.s then
			self.corpse:getHumanVisual():setHairModel("Short")
		end
		if not self.corpse:isFemale() and beardStyleData.length > CorpseHairCuttingUtils.hairLengths.s then
			self.corpse:getHumanVisual():setBeardModel("Full")
		end
	end
	
    
	self.corpse:invalidateCorpse()
    return true
end



function ISCorpseHairCutting:getDuration()
    if self.character:isTimedActionInstant() then
        return 1
    end
	
	local duration = 300
	
	if self.isShear  then
		if self.item:IsDrainable()  then
			duration = 120
		else
			duration = 180
		end
	elseif self.isRazor  then
		duration = 240
	else
		duration = 300
	end
	
    return duration
end

function ISCorpseHairCutting:stopSound()
    if self.sound and self.character:getEmitter():isPlaying(self.sound) then
        self.character:stopOrTriggerSound(self.sound)
    end
end

function ISCorpseHairCutting:new (character, corpse, item)
    local o = ISBaseTimedAction.new(self, character)
    
    o.character = character
    o.item = item
    
    o.corpse = corpse
    o.isShear = item:hasTag("Shear")
    o.isRazor = item:hasTag("Razor")
    o.isScissors = item:hasTag("Scissors")
	o.maxTime = o:getDuration()
    return o
end


