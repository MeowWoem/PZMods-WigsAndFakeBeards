require "TimedActions/ISWashClothing";

local old_ISWashClothing_complete = ISWashClothing.complete;

function ISWashClothing:complete()
    local item = self.item;
    local hasReplacement = item:getItemAfterCleaning() ~= nil;
    local color, immuColor;

    if hasReplacement then
        color = item:getColor();
        immuColor = ImmutableColor.new(color);
    end

    local result = old_ISWashClothing_complete(self);

    if hasReplacement then
        local items = self.character:getInventory():getItems();
        local newItem = items:get(items:size() - 1);

        local visual = newItem:getVisual();
        if visual then
            visual:setTint(immuColor);
        end

        newItem:setColorRed(immuColor:getRedFloat());
        newItem:setColorGreen(immuColor:getGreenFloat());
        newItem:setColorBlue(immuColor:getBlueFloat());
        newItem:setColor(color);
        newItem:setCustomColor(true);

		newItem:synchWithVisual();
		if(isMultiplayer() and isServer()) then
        	sendServerCommand("CorpseHair", "SyncHairTuftColor", {
                r = immuColor:getRedFloat(),
                g = immuColor:getGreenFloat(),
                b = immuColor:getBlueFloat(),
                index = items:size() - 1,
                playerNum = self.character:getPlayerNum(),
            });
		end
    end

    return result;
end

local function onServerCommand(module, command, args)
	
    if module == "CorpseHair" and command == "SyncHairTuftColor" then
		
        local color = Color.new(args.r, args.g, args.b);
        local immuColor = ImmutableColor.new(args.r, args.g, args.b);
        local items = getSpecificPlayer(args.playerNum):getInventory():getItems();
		local newItem = items:get(args.index);
		if(not newItem) then return; end

        local visual = newItem:getVisual();
        if visual then
            visual:setTint(immuColor);
        end

        newItem:setColorRed(immuColor:getRedFloat());
        newItem:setColorGreen(immuColor:getGreenFloat());
        newItem:setColorBlue(immuColor:getBlueFloat());
        newItem:setColor(color);
        newItem:setCustomColor(true);
		newItem:synchWithVisual();
		newItem:syncItemFields();
    end
end

Events.OnServerCommand.Add(onServerCommand);