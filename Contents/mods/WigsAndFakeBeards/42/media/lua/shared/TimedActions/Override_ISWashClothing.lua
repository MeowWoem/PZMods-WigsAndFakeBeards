require "TimedActions/ISWashClothing"

function ISWashClothing:complete()
	local item = self.item;
	local water = ISWashClothing.GetRequiredWater(item)
	local isRemoved = false;

	if instanceof(item, "Clothing") or instanceof(item, "InventoryContainer") then
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
		if instanceof(item, "Clothing") then
			item:setWetness(100);
			item:setDirtiness(0);
		end
	elseif item:getItemAfterCleaning() then
		isRemoved = true;
		local newItemType = item:getItemAfterCleaning();
		
		local color = item:getColor()
		local immuColor = ImmutableColor.new(color)
		
		self.character:getInventory():Remove(item);
		sendRemoveItemFromContainer(self.character:getInventory(), item);
		
		local newItem = self.character:getInventory():AddItem(newItemType);
		
		local visual = newItem:getVisual();
		if visual then
			visual:setTint(immuColor);
		end
		
		newItem:setColorRed(immuColor:getRedFloat());
		newItem:setColorGreen(immuColor:getGreenFloat());
		newItem:setColorBlue(immuColor:getBlueFloat());
		newItem:setColor(color);
		newItem:setCustomColor(true);
		
		newItem:setFavorite(item:isFavorite());
		sendAddItemToContainer(self.character:getInventory(), newItem);
	else
		self:useSoap(item, nil);
	end

	item:setBloodLevel(0);
	
	if not isRemoved then
		syncItemFields(self.character, item);
	end
	
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