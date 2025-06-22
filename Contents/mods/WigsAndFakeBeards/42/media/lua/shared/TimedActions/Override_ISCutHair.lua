require "TimedActions/ISCutHair"

function ISCutHair:complete()
	local newHairStyle = getHairStylesInstance():FindMaleStyle(self.hairStyle)
	if self.character:isFemale() then
		newHairStyle = getHairStylesInstance():FindFemaleStyle(self.hairStyle)
	end

	if newHairStyle:getName():contains("Bald") then
		self.character:getHumanVisual():setHairColor(self.character:getHumanVisual():getNaturalHairColor())
	end

	-- if we're attaching our hair we need to set the non attached model, or if we untie, we reset our model
	if newHairStyle:isAttachedHair() and not self.character:getHumanVisual():getNonAttachedHair() then
		self.character:getHumanVisual():setNonAttachedHair(self.character:getHumanVisual():getHairModel());
	end
	if self.character:getHumanVisual():getNonAttachedHair() and not newHairStyle:isAttachedHair() then
		self.character:getHumanVisual():setNonAttachedHair(nil);
	end
	
	local currentHairStyleData = CorpseHairCuttingUtils.getHairStyle(self.character:getHumanVisual():getHairModel())
	local newHairStyleData = CorpseHairCuttingUtils.getHairStyle(self.hairStyle)
	
	local qty = currentHairStyleData.qtyMax - newHairStyleData.qtyMax
	
	
	local immuColor = self.character:getHumanVisual():getHairColor()
	local color = Color.new(immuColor:getRedFloat(), immuColor:getGreenFloat(), immuColor:getBlueFloat(), 1)	
	
	for i = 1, qty do
	
		local item = instanceItem("Base.HairTuft")
		
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
	
	self.character:getHumanVisual():setHairModel(self.hairStyle);
	self.character:resetModel();
	self.character:resetHairGrowingTime();

	-- reduce hairgel for mohawk
	if (newHairStyle:getName():contains("Mohawk") or newHairStyle:getName():contains("Spike") or newHairStyle:getName():contains("GreasedBack")) and newHairStyle:getName() ~= "MohawkFlat" then
		local hairgel = self.character:getInventory():getItemFromType("Hairgel", true, true) or self.character:getInventory():getItemFromType("Hairspray2", true, true) or self.character:getInventory():getFirstTagRecurse("DoHairdo");
		if hairgel then
			hairgel:UseAndSync();
		end
	end
	-- reduce hairspray for buffant
	if newHairStyle:getName():contains("Buffont") then
		local hairspray = self.character:getInventory():getItemFromType("Hairspray2", true, true)
		if hairspray then
			hairspray:UseAndSync();
		end
	end
	-- reduce hairgel for greased
	if newHairStyle:getName():contains("Greased") then
		local hairgel = self.character:getInventory():getItemFromType("Hairgel", true, true) or self.character:getInventory():getFirstTagRecurse("SlickHair")
		if hairgel then
			hairgel:UseAndSync();
		end
	end
	sendHumanVisual(self.character)
	return true
end