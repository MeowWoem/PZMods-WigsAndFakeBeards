local function onClientCommand(module, command, player, args)
    print("SERVER COMMAND")
    if module == "CorpseHair" and command == "UpdateCorpseVisual" then
        local sq = getSquare(args.x, args.y, args.z);
        if sq then
            local staticObjects = sq:getStaticMovingObjects();
            for i = 0, staticObjects:size() - 1 do
                local obj = staticObjects:get(i);
                if instanceof(obj, "IsoDeadBody") and obj:getStaticMovingObjectIndex() == args.index then
                    local visual = obj:getHumanVisual();
                    if visual then
                        visual:setHairModel(args.hairModel or "");
                        if not obj:isFemale() then
                            visual:setBeardModel(args.beardModel or "");
                        end
                        obj:invalidateCorpse();
                    end
                    break;
                end
            end
        end
        -- Renvoyer l'instruction à l'ensemble des joueurs proches/sur le serveur
        sendServerCommand("CorpseHair", "SyncCorpseVisual", args);
    end
end

Events.OnClientCommand.Add(onClientCommand);