require "TimedActions/ISTrimBeard";

local old_ISTrimBeard_complete = ISTrimBeard.complete;

function ISTrimBeard:complete()
    local currentBeardStyleData = CorpseHairCuttingUtils.getBeardStyle(self.character:getHumanVisual():getBeardModel());
    local newBeardStyleData = CorpseHairCuttingUtils.getBeardStyle(self.beardStyle);

    local immuColor = self.character:getHumanVisual():getBeardColor();
    local color = Color.new(immuColor:getRedFloat(), immuColor:getGreenFloat(), immuColor:getBlueFloat(), 1);

    local qty = currentBeardStyleData.qtyMax - newBeardStyleData.qtyMax;

    local result = old_ISTrimBeard_complete(self);

    for i = 1, qty do
        local item = instanceItem("Base.HairTuft");

        local visual = item:getVisual();
        if visual then
            visual:setTint(immuColor);
        end

        item:setColorRed(immuColor:getRedFloat());
        item:setColorGreen(immuColor:getGreenFloat());
        item:setColorBlue(immuColor:getBlueFloat());
        item:setColor(color);
        item:setCustomColor(true);

        self.character:getInventory():AddItem(item);
        sendAddItemToContainer(self.character:getInventory(), item);
    end

    return result;
end