require "recipecode"

Recipe = Recipe or {}
Recipe.OnCreate = Recipe.OnCreate or {}
Recipe.OnTest = Recipe.OnTest or {}

function Recipe.OnTest.SaveColorOfDye(item)
	-- Use ModData to store color to fix a bug that resets the color when the fluid container is empty after crafting is complete
	if item:getFluidContainer() and item:getFluidContainer():getPrimaryFluid() and ISInventoryPaneContextMenu.startWith(item:getFluidContainer():getPrimaryFluid():getFluidTypeString(), "HairDye") and not item:getFluidContainer():isEmpty() then
	   local md = item:getModData()
	   md.HairDyeColor = Color.new(item:getFluidContainer():getColor())
	end
	
	return true
end

function Recipe.OnCreate.InheritColorFromDye(craftRecipeData, character)

	local inputs = craftRecipeData:getAllInputItems();
	
	local dyeItem = nil;

	for j=0,inputs:size() - 1 do
		local testItem = inputs:get(j)
		
		-- Use ModData to store color to fix a bug that resets the color when the fluid container is empty after crafting is complete
		local md = testItem:getModData()
		if ISInventoryPaneContextMenu.startWith(testItem:getType(), "HairDye") and md.HairDyeColor then
           dyeItem = testItem;
		   break
        end
    end
	if not dyeItem then return end
	
	-- Use ModData to store color to fix a bug that resets the color when the fluid container is empty after crafting is complete
	local md = dyeItem:getModData()
	local color = md.HairDyeColor
	md.HairDyeColor = nil
	
	local results = craftRecipeData:getAllCreatedItems();

	for j=0,results:size() - 1 do
		local result = results:get(j)
		result:setColor(color);
		if instanceof(result, "Clothing") or instanceof(result, "InventoryContainer") then
			local visual = result:getVisual();
			if visual then
				local immuColor = ImmutableColor.new(color);
				visual:setTint(immuColor);
			end
		end
    end
end

function Recipe.OnCreate.Undye(craftRecipeData, character)

		
	local results = craftRecipeData:getAllCreatedItems();

	for j=0,results:size() - 1 do
		local result = results:get(j)
		result:setColor(Color.new(1, 1, 1, 1));
		if instanceof(result, "Clothing") or instanceof(result, "InventoryContainer") then
			local visual = result:getVisual();
			if visual then
				local immuColor = ImmutableColor.new(ImmutableColor.new(1, 1, 1, 1));
				visual:setTint(immuColor);
			end
		end
    end
end


function Recipe.OnCreate.InheritColorFromHairTuft(craftRecipeData, character)

	local inputs = craftRecipeData:getAllInputItems();
	
	local tuftsColors = {}
	
	for j=0,inputs:size() - 1 do
		local testItem = inputs:get(j)
		if testItem:getType() == "HairTuft" then
			local col = testItem:getColor()
			table.insert(tuftsColors, {col:getRedFloat(), col:getGreenFloat(), col:getBlueFloat()})
        end
    end
	
	local color = CorpseHairCuttingUtils.averageColor(tuftsColors)
	
	local results = craftRecipeData:getAllCreatedItems();

	for j=0,results:size() - 1 do
		local result = results:get(j)
		result:setColor(color);
		if instanceof(result, "Clothing") or instanceof(result, "InventoryContainer") then
			local visual = result:getVisual();
			if visual then
				local immuColor = ImmutableColor.new(color);
				visual:setTint(immuColor);
			end
		end
    end
end