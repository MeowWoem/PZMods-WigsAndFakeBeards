--***********************************************************
--**                       AMENOPHIS                       **
--***********************************************************

local ContextMenu = {}

local function predicateShear(item)
    return not item:isBroken() and item:hasTag("Shear")
end

local function predicateScissors(item)
    return not item:isBroken() and item:hasTag("Scissors")
end

local function predicateRazor(item)
    return not item:isBroken() and item:hasTag("Razor")
end

function ContextMenu.onCutHair(playerObj, corpse, item)
	local pos = corpse:getGrabHeadPosition(Vector2f.new())
	ISTimedActionQueue.add(ISPathFindAction:pathToLocationF(playerObj, pos:x(), pos:y(), corpse:getZ()))
	--if luautils.walkAdj(playerObj, corpse:getSquare(), false) then
		ISTimedActionQueue.add(ISCorpseHairCutting:new(playerObj, corpse, item));
	--end	
	
end

function ContextMenu.onCutWigOrFakeBeard(playerObj, item, itemType, scissors, hairTuftQty)
	ISTimedActionQueue.add(ISWigCutting:new(playerObj, item, itemType, scissors, hairTuftQty));
end


function ContextMenu.onDebugHairStyle(player, corpse, style)
	print("_____________")
	print(style);
	print("_____________")
	
	local md = corpse:getModData()
	md.cuttingHairQtyCollected = nil
	md.cuttingHairScissorsPenalty = nil
	corpse:getHumanVisual():setHairModel(style)
	corpse:invalidateCorpse()
	
end


function ContextMenu.addOnCutHairCorpseOption(player, context, worldObjects, test)

	local playerObj = getSpecificPlayer(player)
	local playerInv = playerObj:getInventory();
	local pickedCorpse = IsoObjectPicker.Instance:PickCorpse(getMouseX(), getMouseY())
	
	if not pickedCorpse then return false end
	
	if isDebugEnabled() then
		local debugOption = context:addOption("Debug Hair", worldObjects, nil);
		
		local debugMenu = ISContextMenu:getNew(context)
		context:addSubMenu(debugOption, debugMenu)
		
		local debugHairStylesOption = debugMenu:addOption("Styles", worldObjects, nil);
		local debugHairStylesMenu = ISContextMenu:getNew(context)
		context:addSubMenu(debugHairStylesOption, debugHairStylesMenu)
		
		debugHairStylesMenu:addGetUpOption("None", playerObj, ContextMenu.onDebugHairStyle, pickedCorpse, "")
		
		local hairStyles = getAllHairStyles(pickedCorpse:isFemale())
		for i=1,hairStyles:size() do
			debugHairStylesMenu:addGetUpOption(hairStyles:get(i - 1), playerObj, ContextMenu.onDebugHairStyle, pickedCorpse, hairStyles:get(i - 1))
		end
		
		
	end
	
	if pickedCorpse:isAnimal() then
		-- TODO: Add option to get fur tuft
	else
			
		local shear = playerInv:getFirstEvalRecurse(predicateShear)
		local scissors = playerInv:getFirstEvalRecurse(predicateScissors)
		local razor = playerInv:getFirstEvalRecurse(predicateRazor)
		
		if not shear and not scissors and not razor then return false end
		
		local getHairOption = context:addOption(getText("ContextMenu_CollectHair"), worldObjects, nil);
		
		local cutHairMenu = ISContextMenu:getNew(context)
		context:addSubMenu(getHairOption, cutHairMenu)
		
		local shaveHairOption = cutHairMenu:addGetUpOption(getText("ContextMenu_ShaveCorpseHair"), playerObj, ContextMenu.onCutHair, pickedCorpse, shear);
		local shaveRazorHairOption = cutHairMenu:addGetUpOption(getText("ContextMenu_ShaveRazorCorpseHair"), playerObj, ContextMenu.onCutHair, pickedCorpse, razor);
		local cutHairOption = cutHairMenu:addGetUpOption(getText("ContextMenu_CutCorpseHair"), playerObj, ContextMenu.onCutHair, pickedCorpse, scissors);
		
		local tooltipScissorsDesc = getText("ContextMenu_HairCutThisWillCut")
		local tooltipDesc = getText("ContextMenu_HairCutThisWillCut")
		
		local beardStyleData = CorpseHairCuttingUtils.getBeardStyle("")
		local hairStyleData = CorpseHairCuttingUtils.getHairStyle(pickedCorpse:getHumanVisual():getHairModel());
		
		if not pickedCorpse:isFemale() then
			beardStyleData = CorpseHairCuttingUtils.getBeardStyle(pickedCorpse:getHumanVisual():getBeardModel())
		end
		
		if hairStyleData.length > CorpseHairCuttingUtils.hairLengths.s then
			tooltipScissorsDesc = tooltipScissorsDesc .. " \n<INDENT:8><RGB:1,1,1>- " .. getText("ContextMenu_HairCutHair")
		else
			tooltipScissorsDesc = tooltipScissorsDesc .. " \n<INDENT:8><RGB:1,0,0>- " .. getText("ContextMenu_HairCutHair") .. " (".. getText("ContextMenu_TooShort") .. ")"
		end
		
		if beardStyleData.length > CorpseHairCuttingUtils.hairLengths.s then
			tooltipScissorsDesc = tooltipScissorsDesc .. " \n<INDENT:8><RGB:1,1,1>- " .. getText("ContextMenu_HairCutBeard")
		elseif beardStyleData.length > 0 then
			tooltipScissorsDesc = tooltipScissorsDesc .. " \n<INDENT:8><RGB:1,0,0>- " .. getText("ContextMenu_HairCutBeard") .. " (".. getText("ContextMenu_TooShort") .. ")"
		else
			tooltipScissorsDesc = tooltipScissorsDesc .. " \n<INDENT:8><RGB:1,0,0>- " .. getText("ContextMenu_HairCutBeard") .. " (".. getText("ContextMenu_IsBeardless") .. ")"
		end
		
		if hairStyleData.length > 0 then
			tooltipDesc = tooltipDesc .. " \n<INDENT:8><RGB:1,1,1>- " .. getText("ContextMenu_HairCutHair")
		else
			tooltipDesc = tooltipDesc .. " \n<INDENT:8><RGB:1,0,0>- " .. getText("ContextMenu_HairCutHair") .. " (".. getText("ContextMenu_IsBald") .. ")"
		end
		
		if beardStyleData.length > 0 then
			tooltipDesc = tooltipDesc .. " \n<INDENT:8><RGB:1,1,1>- " .. getText("ContextMenu_HairCutBeard")
		else
			tooltipDesc = tooltipDesc .. " \n<INDENT:8><RGB:1,0,0>- " .. getText("ContextMenu_HairCutBeard") .. " (".. getText("ContextMenu_IsBeardless") .. ")"
		end
		
		local scissorsTooltip = ISWorldObjectContextMenu.addToolTip()
		scissorsTooltip.description = tooltipScissorsDesc .. " <BR><INDENT:0><RGB:1,0.7,0>" .. getText("ContextMenu_HairCutWithScissorsTooltip")
		scissorsTooltip.maxLineWidth = 512
		cutHairOption.toolTip = scissorsTooltip
		
		local shaveTooltip = ISWorldObjectContextMenu.addToolTip()
		shaveTooltip.description = tooltipDesc
		shaveTooltip.maxLineWidth = 512
		
		shaveHairOption.toolTip = shaveTooltip
		shaveRazorHairOption.toolTip = shaveTooltip
		
		if not shear then
			shaveHairOption.notAvailable = true;
			
			local notShearTooltip = ISWorldObjectContextMenu.addToolTip()
            notShearTooltip.description = "<RGB:1,0,0> " .. getText("ContextMenu_HairShearRequired")
			
			shaveHairOption.toolTip = notShearTooltip
		end
		if not scissors then
			cutHairOption.notAvailable = true;
			
			local notScissorsTooltip = ISWorldObjectContextMenu.addToolTip()
            notScissorsTooltip.description = "<RGB:1,0,0> " .. getText("ContextMenu_HairScissorsRequired")
			
			cutHairOption.toolTip = notScissorsTooltip
		end
		if not razor then
			shaveRazorHairOption.notAvailable = true;
			
			local notRazorTooltip = ISWorldObjectContextMenu.addToolTip()
            notRazorTooltip.description = "<RGB:1,0,0> " .. getText("ContextMenu_HairRazorRequired")
			
			shaveRazorHairOption.toolTip = notRazorTooltip
		end
		
		
		if hairStyleData.canBeCollected == false and beardStyleData.canBeCollected == false then
			shaveHairOption.notAvailable = true
			cutHairOption.notAvailable = true
			shaveRazorHairOption.notAvailable = true
			
			local cantBeCollectedTooltip = ISWorldObjectContextMenu.addToolTip()
            cantBeCollectedTooltip.description = "<RGB:1,0,0> " .. getText("ContextMenu_HairCantBeCollected")
			
			shaveHairOption.toolTip = cantBeCollectedTooltip
			cutHairOption.toolTip = cantBeCollectedTooltip
			shaveRazorHairOption.toolTip = cantBeCollectedTooltip
			
		elseif hairStyleData.length <= CorpseHairCuttingUtils.hairLengths.s and beardStyleData.length <= CorpseHairCuttingUtils.hairLengths.s then
			cutHairOption.notAvailable = true;
			
			local tooshortTooltip = ISWorldObjectContextMenu.addToolTip()
            tooshortTooltip.description = "<RGB:1,0,0> " .. getText("ContextMenu_HairTooShort")
			
			cutHairOption.toolTip = tooshortTooltip
		end
		
	end
	
end

function ContextMenu.addCutWigsOption(player, context, items)
	local item = nil
	for i,v in ipairs(items) do
        if not instanceof(v, "InventoryItem") then
			item = v.items[1]
        else
			item = v
        end
	end
	
	
	if item ~= nil then
		if ISInventoryPaneContextMenu.startWith(item:getType(), "FakeBeard") or ISInventoryPaneContextMenu.startWith(item:getType(), "Wig") then
			local playerObj = getSpecificPlayer(player)
			local playerInv = playerObj:getInventory();
			local scissors = playerInv:getFirstEvalRecurse(predicateScissors)
		
			local currentCut = CorpseHairCuttingUtils.wigStyle[item:getType()]
			
			if ISInventoryPaneContextMenu.startWith(item:getType(), "FakeBeard") then
				local possibleCut = {}
				for k, v in pairs(CorpseHairCuttingUtils.beardStyles) do
					if v.length <= currentCut.length then
						if k ~= "" and k ~= "None" and k ~= "default" and v.itemType ~= currentCut.itemType then
							table.insert(possibleCut, {name = k, itemType = v.itemType})
						end
					end
				end
				
				if #possibleCut > 0 then
					local parentOption = context:addOption(getText("ContextMenu_CutFakeBeard"), nil, nil);
					local styleMenu = ISContextMenu:getNew(context)
					context:addSubMenu(parentOption, styleMenu)
					
					for _, v in ipairs(possibleCut) do
						local newBeard = CorpseHairCuttingUtils.beardStyles[v.name]
						local cutItem = nil
						local hairTuftQty = 0
						local label = getText("ContextMenu_HairStyling")
						if currentCut.length ~= newBeard.length then
							cutItem = scissors
							hairTuftQty = currentCut.qtyMax - newBeard.qtyMax
							label = getText("ContextMenu_HairCut")
						end
						
						local option = styleMenu:addGetUpOption(label .. " : " .. v.name, playerObj, ContextMenu.onCutWigOrFakeBeard, item, v.itemType, cutItem, hairTuftQty)
						if not scissors and currentCut.length ~= newBeard.length then
							option.notAvailable = true
			
							local notScissorsTooltip = ISWorldObjectContextMenu.addToolTip()
							notScissorsTooltip.description = "<RGB:1,0,0> " .. getText("ContextMenu_HairScissorsRequired")
							
							option.toolTip = notScissorsTooltip
						elseif scissors and currentCut.length ~= newBeard.length and hairTuftQty > 0 then
							local youWillGetTooltip = ISWorldObjectContextMenu.addToolTip()
							youWillGetTooltip.description = getText("ContextMenu_HairYouWillGet", hairTuftQty, getText("ContextMenu_HairTuft"))
							
							option.toolTip = youWillGetTooltip
						end
					end
				end
			elseif ISInventoryPaneContextMenu.startWith(item:getType(), "Wig") then
				local possibleCut = {}
				for k, v in pairs(CorpseHairCuttingUtils.hairStyles) do
					--print("____")
					--print(tostring(currentCut))
					--print("____")
					if v.length <= currentCut.length then
						if k ~= "" and k ~= "Bald" and k ~= "default" and v.itemType ~= currentCut.itemType then
							table.insert(possibleCut, {name = k, itemType = v.itemType})
						end
					end
				end
				
				if #possibleCut > 0 then
					local parentOption = context:addOption(getText("ContextMenu_CutWig"), nil, nil);
					local styleMenu = ISContextMenu:getNew(context)
					context:addSubMenu(parentOption, styleMenu)
					
					for _, v in ipairs(possibleCut) do
						local newHair = CorpseHairCuttingUtils.hairStyles[v.name]
						local cutItem = nil
						local hairTuftQty = 0
						local label = getText("ContextMenu_HairStyling")
						if currentCut.length ~= newHair.length then
							cutItem = scissors
							hairTuftQty = currentCut.qtyMax - newHair.qtyMax
							label = getText("ContextMenu_HairCut")
						end
						local option = styleMenu:addGetUpOption(label .. " : " .. v.name, playerObj, ContextMenu.onCutWigOrFakeBeard, item, v.itemType, cutItem, hairTuftQty)
						if not scissors and currentCut.length ~= newHair.length then
							option.notAvailable = true
			
							local notScissorsTooltip = ISWorldObjectContextMenu.addToolTip()
							notScissorsTooltip.description = "<RGB:1,0,0> " .. getText("ContextMenu_HairScissorsRequired")
							
							option.toolTip = notScissorsTooltip
						elseif scissors and currentCut.length ~= newHair.length and hairTuftQty > 0 then
							local youWillGetTooltip = ISWorldObjectContextMenu.addToolTip()
							youWillGetTooltip.description = getText("ContextMenu_HairYouWillGet", hairTuftQty, getText("ItemName_Base.HairTuft"))
							
							option.toolTip = youWillGetTooltip
						end
					end
				end
				
			end
		end
	end
end


Events.OnFillWorldObjectContextMenu.Add(ContextMenu.addOnCutHairCorpseOption)
Events.OnFillInventoryObjectContextMenu.Add(ContextMenu.addCutWigsOption)

return ContextMenu

