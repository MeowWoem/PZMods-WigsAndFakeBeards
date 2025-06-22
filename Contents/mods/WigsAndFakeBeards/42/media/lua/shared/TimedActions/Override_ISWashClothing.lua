require "TimedActions/ISWashClothing"

function ISWashClothing:complete()
	local item = self.item;
	local water = ISWashClothing.GetRequiredWater(item)

	if instanceof(item, "Clothing") then
		local coveredParts = BloodClothingType.getCoveredParts(item:getBloodClothingType())
		if coveredParts then
			for j=0,coveredParts:size()-1 do
				if self.noSoap == false then
					self:useSoap(item, coveredParts:get(j));
				end
				item:setBlood(coveredParts:get(j), 0);
				item:setDirt(coveredParts:get(j), 0);
			end
		end
		item:setWetness(100);
		item:setDirtyness(0);
	elseif item:getItemAfterCleaning() then
		local color = item:getColor()
		local immuColor = ImmutableColor.new(color)
		local newItem = instanceItem(item:getItemAfterCleaning());
				
		local visual = newItem:getVisual();
		
		if visual then
			visual:setTint(immuColor);
		end
		
		newItem:setColorRed(immuColor:getRedFloat());
		newItem:setColorGreen(immuColor:getGreenFloat());
		newItem:setColorBlue(immuColor:getBlueFloat());
		
		
		newItem:setColor(color)
		newItem:setCustomColor(true);
		
		self.character:getInventory():Remove(item);
		self.character:getInventory():AddItem(newItem);
	else
		self:useSoap(item, nil);
	end

	item:setBloodLevel(0);

	--sync Wetness, Dirtyness, BloodLevel
	syncItemFields(self.character, item);
	syncVisuals(self.character);
	self.character:updateHandEquips();

	if self.character:isPrimaryHandItem(item) then
		self.character:setPrimaryHandItem(item);
	end
	if self.character:isSecondaryHandItem(item) then
		self.character:setSecondaryHandItem(item);
	end

	self.sink:useFluid(water);

	return true;
end