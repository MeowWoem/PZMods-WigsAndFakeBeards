require "TimedActions/ISCutHair";

local old_ISCutHair_complete = ISCutHair.complete;

function ISCutHair:complete()
    local newHairStyle = getHairStylesInstance():FindMaleStyle(self.hairStyle);
    if self.character:isFemale() then
        newHairStyle = getHairStylesInstance():FindFemaleStyle(self.hairStyle);
    end

    local currentHairStyleData = CorpseHairCuttingUtils.getHairStyle(self.character:getHumanVisual():getHairModel());
    local newHairStyleData = CorpseHairCuttingUtils.getHairStyle(self.hairStyle);

    local qty = currentHairStyleData.qtyMax - newHairStyleData.qtyMax;

    local immuColor = self.character:getHumanVisual():getHairColor();
    local color = Color.new(immuColor:getRedFloat(), immuColor:getGreenFloat(), immuColor:getBlueFloat(), 1);

    local result = old_ISCutHair_complete(self);

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