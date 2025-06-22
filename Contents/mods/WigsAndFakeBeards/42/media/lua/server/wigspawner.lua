local function assignRandomHairColor(item, allowNonNaturalColor)

	local useNonNaturalColorChance = ZombRand(1, 11)
	
	local color = nil
	
	
	if useNonNaturalColorChance == 3 and allowNonNaturalColor then
	
		color = Color.new(ZombRandFloat(0.086, 1), ZombRandFloat(0.086, 1), ZombRandFloat(0.086, 1))	
	
	else
		local colorChoice = ZombRand(#CorpseHairCuttingUtils.commonHairColor) + 1
		local colorRGB = CorpseHairCuttingUtils.commonHairColor[colorChoice]
		
		color = Color.new(colorRGB[1], colorRGB[2], colorRGB[3])	
	end

	
	local immuColor = ImmutableColor.new(color)

	
	local visual = item:getVisual()
	
	if visual then
		visual:setTint(immuColor)
	end
	
	item:setColorRed(immuColor:getRedFloat())
	item:setColorGreen(immuColor:getGreenFloat())
	item:setColorBlue(immuColor:getBlueFloat())
	
	
	item:setColor(color)
	item:setCustomColor(true)

end

local function createItemWithRandomHairColor(itemType, allowNonNaturalColor)
	local item = instanceItem(itemType)
	assignRandomHairColor(item, allowNonNaturalColor)
	return item
end

local function OnFillContainer(roomType, containerType, container)
	
	if not container or not instanceof(container, "ItemContainer") then return false end
	
	local items = container:FindAll("Base.DummyWig")
	
	for i=0,items:size()-1 do
		local item = items:get(i)
		local choice = ZombRand(#CorpseHairCuttingUtils.wigStyleIndexed) + 1
		local result = createItemWithRandomHairColor(CorpseHairCuttingUtils.wigStyleIndexed[choice].itemType, true)
		container:AddItem(result)
		container:Remove(item)
	end
	
	items = container:FindAll("Base.HairTuft")
	for i=0,items:size()-1 do
		assignRandomHairColor(items:get(i), true)
	end
	
end

Events.OnFillContainer.Add(OnFillContainer)