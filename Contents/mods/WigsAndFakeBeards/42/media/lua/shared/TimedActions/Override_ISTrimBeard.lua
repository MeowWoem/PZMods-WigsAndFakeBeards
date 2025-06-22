require "TimedActions/ISTrimBeard"

function ISTrimBeard:complete()

	local currentBeardStyleData = CorpseHairCuttingUtils.getBeardStyle(self.character:getHumanVisual():getBeardModel())
	local newBeardStyleData = CorpseHairCuttingUtils.getBeardStyle(self.beardStyle)
	
	local immuColor = self.character:getHumanVisual():getHairColor()
	local color = Color.new(immuColor:getRedFloat(), immuColor:getGreenFloat(), immuColor:getBlueFloat(), 1)

	local qty = currentBeardStyleData.qtyMax - newBeardStyleData.qtyMax
	
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

	self.character:getHumanVisual():setBeardModel(self.beardStyle);

	if self.beardStyle == "" then
		self.character:getHumanVisual():setBeardColor(self.character:getHumanVisual():getNaturalBeardColor())
	end
	sendHumanVisual(self.character)

	if not isServer() then
		self.character:resetModel();
		self.character:resetBeardGrowingTime();
		triggerEvent("OnClothingUpdated", self.character)
	end

	return true
end