require "Items/Distributions"
require "Items/ProceduralDistributions"
require "RandomizedWorldContent/StoryClutter/StoryClutter_Definitions"


local doProceduralDistributions  = function(storage, item, count)
  ProceduralDistributions = ProceduralDistributions or {};
  ProceduralDistributions.list = ProceduralDistributions.list or {};
  ProceduralDistributions.list[storage] = ProceduralDistributions.list[storage] or {};
  ProceduralDistributions.list[storage].items = ProceduralDistributions.list[storage].items or {};
  table.insert(ProceduralDistributions.list[storage].items, item);
  table.insert(ProceduralDistributions.list[storage].items, count);
end




doProceduralDistributions("SalonCounter", "Base.HairTuft", 0.1)
doProceduralDistributions("SalonShelfHaircare", "Base.HairTuft", 0.1)
doProceduralDistributions("CrateSalonSupplies", "Base.HairTuft", 0.1)
doProceduralDistributions("SalonShelfHaircare", "Base.DummyWig", 1)
doProceduralDistributions("SalonCounter", "Base.DummyWig", 1)
doProceduralDistributions("CrateSalonSupplies", "Base.DummyWig", 2)


table.insert(StoryClutter.HairSalonClutter, "Base.HairTuft")

local function postMergeDistributions()
	SuburbsDistributions.aesthetic.bin = SuburbsDistributions.aesthetic.bin or {
		items = {
			"Bag_TrashBag", 20,
			"BandageDirty", 2,
			"Brochure", 1,
			"BrokenGlass", 0.4,
			"Cockroach", 8,
			"DeadMouse", 2,
			"DeadRat", 2,
			"Flier", 1,
			"FountainCup", 4,
			"PaperNapkins2", 4,
			"PlasticCup", 4,
			"Pop2Empty", 8,
			"Pop3Empty", 8,
			"PopBottleEmpty", 1,
			"PopEmpty", 8,
			"Receipt", 10,
			"RippedSheetsDirty", 4,
			"Straw2", 8,
			"WaterBottleEmpty", 1,
		},
		rolls = 4,
		ignoreZombieDensity = true,
		isTrash = true,
	}

	for i = 1, 10 do
		
		table.insert(SuburbsDistributions.aesthetic.bin.items, "Base.HairTuft")
		table.insert(SuburbsDistributions.aesthetic.bin.items, 25)
		i = i + 1
	end

end

Events.OnPostDistributionMerge.Add(postMergeDistributions)