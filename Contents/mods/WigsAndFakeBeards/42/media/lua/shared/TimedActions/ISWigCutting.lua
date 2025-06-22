--***********************************************************
--**                       AMENOPHIS                       **
--***********************************************************

require "TimedActions/ISBaseTimedAction"

ISWigCutting = ISBaseTimedAction:derive("ISWigCutting");

function ISWigCutting:isValid()
    return true;
end

function ISWigCutting:update()
   	self.item:setJobDelta(self:getJobDelta());
    self.character:setMetabolicTarget(Metabolics.LightWork);
end

function ISWigCutting:start()
    self.item:setJobType(getText("ContextMenu_CutWig"));
 	self.item:setJobDelta(0.0);

	if self.scissors then
		self.sound = self.character:playSound("HairCutScissors")
		self:setOverrideHandModels(self.scissors, nil)
	end
	
	self:setActionAnim("RipSheets")


end

function ISWigCutting:stop()
    self:stopSound()
    self.item:setJobDelta(0.0)

    ISBaseTimedAction.stop(self)
end

function ISWigCutting:perform()
    self:stopSound()
    self.item:setJobDelta(0.0)

    ISBaseTimedAction.perform(self)
end

function ISWigCutting:complete()
	local color = Color.new(self.item:getColor())
	local immuColor = ImmutableColor.new(color)
	local playerInv = self.character:getInventory();
	
	playerInv:Remove(self.item)
	sendRemoveItemFromContainer(playerInv, self.item);
	local newItem = instanceItem(self.itemType)
		
	local visual = newItem:getVisual();
	
	if visual then
		visual:setTint(immuColor);
	end
	
	newItem:setColorRed(immuColor:getRedFloat());
	newItem:setColorGreen(immuColor:getGreenFloat());
	newItem:setColorBlue(immuColor:getBlueFloat());
	
	
	newItem:setColor(color)
	newItem:setCustomColor(true);
	playerInv:AddItem(newItem)
	
	for i = 1, self.hairTuftQty do
		local tuft = instanceItem("Base.HairTuft")
		
		local visual = tuft:getVisual();
		
		if visual then
			visual:setTint(immuColor);
		end
		
		tuft:setColorRed(immuColor:getRedFloat());
		tuft:setColorGreen(immuColor:getGreenFloat());
		tuft:setColorBlue(immuColor:getBlueFloat());
		
		
		tuft:setColor(color)
		tuft:setCustomColor(true);
		
		playerInv:AddItem(tuft)
		
		i = i + 1
	end
	
    return true
end

function ISWigCutting:getDuration()
    if self.character:isTimedActionInstant() then
        return 1
    end
		
    return 300
end

function ISWigCutting:stopSound()
    if self.sound and self.character:getEmitter():isPlaying(self.sound) then
        self.character:stopOrTriggerSound(self.sound)
    end
end

function ISWigCutting:new (character, item, itemType, scissors, hairTuftQty)
    local o = ISBaseTimedAction.new(self, character)
    
    o.item = item
    o.character = character
    o.itemType = itemType
    
    o.scissors = scissors
    o.hairTuftQty = hairTuftQty
	
	o.maxTime = o:getDuration()
    return o
end


