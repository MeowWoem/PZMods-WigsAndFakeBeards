CorpseHairCuttingUtils = {}

CorpseHairCuttingUtils.hairLengths = {
	bald = 0,
	xs = 1,
	s = 2,
	m = 3,
	l = 4,
	xl = 5,
}
local hairLengths = CorpseHairCuttingUtils.hairLengths;

local function HairStyle(canBeCollected, length, qtyMin, qtyMax)
	qtyMin = qtyMin or 0
	qtyMax = qtyMax or 0
	return {
		canBeCollected = canBeCollected,
		qtyMin = qtyMin,
		qtyMax = qtyMax,
		length = length
	}
end

CorpseHairCuttingUtils.hairStyles = {
	Bald = HairStyle(false, hairLengths.bald),
	Picard = HairStyle(true, hairLengths.xs, 1, 1),
	CrewCut = HairStyle(true, hairLengths.xs, 1, 2),
	Fresh = HairStyle(true, hairLengths.xs, 1, 2),
	MohawkShort = HairStyle(true, hairLengths.xs, 1, 2),
	Demi = HairStyle(true, hairLengths.xs, 1, 2),
	
	Baldspot = HairStyle(true, hairLengths.s, 1, 2),
	Recede = HairStyle(true, hairLengths.s, 2, 3),
	Hat = HairStyle(true, hairLengths.s, 2, 3),
	HatCurly = HairStyle(true, hairLengths.s, 2, 3),
	Messy = HairStyle(true, hairLengths.s, 2, 3),
	MessyCurly = HairStyle(true, hairLengths.s, 2, 3),
	Short = HairStyle(true, hairLengths.s, 2, 3),
	ShortCurly = HairStyle(true, hairLengths.s, 2, 3),
	ShortHat = HairStyle(true, hairLengths.s, 2, 3),
	ShortHatCurly = HairStyle(true, hairLengths.s, 2, 3),
	ShortAfroCurly = HairStyle(true, hairLengths.s, 2, 3),
	CentreParting = HairStyle(true, hairLengths.s, 2, 3),
	LeftParting = HairStyle(true, hairLengths.s, 2, 3),
	RightParting = HairStyle(true, hairLengths.s, 2, 3),
	MohawkFlat = HairStyle(true, hairLengths.s, 2, 3),
	FlatTop = HairStyle(true, hairLengths.s, 2, 3),
	GreasedBack = HairStyle(true, hairLengths.s, 2, 3),
	Spike = HairStyle(true, hairLengths.s, 2, 3),
	
	CentrePartingLong = HairStyle(true, hairLengths.m, 2, 4),
	Cornrows = HairStyle(true, hairLengths.m, 2, 4),
	Donny = HairStyle(true, hairLengths.m, 2, 4),
	MohawkFan = HairStyle(true, hairLengths.m, 2, 4),
	MohawkSpike = HairStyle(true, hairLengths.m, 2, 4),
	Braids = HairStyle(true, hairLengths.m, 2, 4),
	Grungey = HairStyle(true, hairLengths.m, 2, 4),
	GrungeyBehindEars = HairStyle(true, hairLengths.m, 2, 4),
	GrungeyParted = HairStyle(true, hairLengths.m, 2, 4),
	Grungey02 = HairStyle(true, hairLengths.m, 2, 4),
	OverEye = HairStyle(true, hairLengths.m, 2, 4),
	OverEyeCurly = HairStyle(true, hairLengths.m, 2, 4),
	OverLeftEye = HairStyle(true, hairLengths.m, 2, 4),
	Bob = HairStyle(true, hairLengths.m, 2, 4),
	BobCurly = HairStyle(true, hairLengths.m, 2, 4),
	Bun = HairStyle(true, hairLengths.m, 2, 4),
	BunCurly = HairStyle(true, hairLengths.m, 2, 4),
	Back = HairStyle(true, hairLengths.m, 2, 4),
	TopCurls = HairStyle(true, hairLengths.m, 2, 4),
	
	Rachel = HairStyle(true, hairLengths.l, 3, 5),
	RachelCurly = HairStyle(true, hairLengths.l, 3, 5),
	PonyTail = HairStyle(true, hairLengths.l, 3, 5),
	PonyTailBraids = HairStyle(true, hairLengths.l, 3, 5),
	LibertySpikes = HairStyle(true, hairLengths.l, 3, 5),
	Buffont = HairStyle(true, hairLengths.l, 3, 5),
	LongBraids = HairStyle(true, hairLengths.l, 3, 5),
	
	Mullet = HairStyle(true, hairLengths.xl, 4, 6),
	MulletCurly = HairStyle(true, hairLengths.xl, 4, 6),
	Metal = HairStyle(true, hairLengths.xl, 4, 6),
	Fabian = HairStyle(true, hairLengths.xl, 4, 6),
	FabianCurly = HairStyle(true, hairLengths.xl, 4, 6),
	FabianBraided = HairStyle(true, hairLengths.xl, 4, 6),
	LongBraids02 = HairStyle(true, hairLengths.xl, 4, 6),
	HatLong = HairStyle(true, hairLengths.xl, 4, 6),
	HatLongBraided = HairStyle(true, hairLengths.xl, 4, 6),
	HatLongCurly = HairStyle(true, hairLengths.xl, 4, 6),
	Long = HairStyle(true, hairLengths.xl, 4, 6),
	Longcurly = HairStyle(true, hairLengths.xl, 4, 6),
	Kate = HairStyle(true, hairLengths.xl, 4, 6),
	KateCurly = HairStyle(true, hairLengths.xl, 4, 6),
	Long2 = HairStyle(true, hairLengths.xl, 4, 6),
	Long2curly = HairStyle(true, hairLengths.xl, 4, 6),
}

CorpseHairCuttingUtils.hairStyles[""] = CorpseHairCuttingUtils.hairStyles.Bald
CorpseHairCuttingUtils.hairStyles["default"] = CorpseHairCuttingUtils.hairStyles.Donny


CorpseHairCuttingUtils.beardStyles = {
	None = HairStyle(false, hairLengths.bald),
	Moustache = HairStyle(true, hairLengths.xs, 1, 1),
	Goatee = HairStyle(true, hairLengths.xs, 1, 1),
	Chin = HairStyle(true, hairLengths.xs, 1, 1),
	PointyChin = HairStyle(true, hairLengths.xs, 1, 1),
	
	Chops = HairStyle(true, hairLengths.s, 1, 2),
	BeardOnly = HairStyle(true, hairLengths.s, 1, 2),
	Full = HairStyle(true, hairLengths.s, 1, 2),
	
	Long = HairStyle(true, hairLengths.m, 2, 3),
	LongScruffy = HairStyle(true, hairLengths.m, 2, 3),
}

CorpseHairCuttingUtils.beardStyles[""] = CorpseHairCuttingUtils.beardStyles.None
CorpseHairCuttingUtils.beardStyles["default"] = CorpseHairCuttingUtils.beardStyles.Chops



CorpseHairCuttingUtils.wigStyle = {
	Wig_MaleHairPicardTINT = CorpseHairCuttingUtils.hairStyles.Picard,
	Wig_MaleHairCrewCutTINT = CorpseHairCuttingUtils.hairStyles.CrewCut,
	Wig_FemaleHairFreshTINT = CorpseHairCuttingUtils.hairStyles.Fresh,
	Wig_FemaleHairMohawkShortTINT = CorpseHairCuttingUtils.hairStyles.MohawkShort,
	Wig_FemaleHairDemiTINT = CorpseHairCuttingUtils.hairStyles.Demi,
	Wig_MaleHairBaldspotTINT = CorpseHairCuttingUtils.hairStyles.Baldspot,
	Wig_MaleHairRecedeTINT = CorpseHairCuttingUtils.hairStyles.Recede,
	Wig_FemaleHairHatTINT = CorpseHairCuttingUtils.hairStyles.Hat,
	Wig_FemaleHairHatCurlyTINT = CorpseHairCuttingUtils.hairStyles.HatCurly,
	Wig_MaleHairMessyTINT = CorpseHairCuttingUtils.hairStyles.Messy,
	Wig_MaleHairMessyCurlyTINT = CorpseHairCuttingUtils.hairStyles.MessyCurly,
	Wig_MaleHairShortTINT = CorpseHairCuttingUtils.hairStyles.Short,
	Wig_FemaleHairShortCurlyTINT = CorpseHairCuttingUtils.hairStyles.ShortCurly,
	Wig_MaleHairShortHatTINT = CorpseHairCuttingUtils.hairStyles.ShortHat,
	Wig_MaleHairShortHatCurlyTINT = CorpseHairCuttingUtils.hairStyles.ShortHatCurly,
	Wig_FemaleHairShortCurlyTINT = CorpseHairCuttingUtils.hairStyles.ShortAfroCurly,
	Wig_FemaleHairPartingCentreTINT = CorpseHairCuttingUtils.hairStyles.CentreParting,
	Wig_FemaleHairPartingLeftTINT = CorpseHairCuttingUtils.hairStyles.LeftParting,
	Wig_FemaleHairPartingRightTINT = CorpseHairCuttingUtils.hairStyles.RightParting,
	Wig_FemaleHairMohawkFlatTINT = CorpseHairCuttingUtils.hairStyles.MohawkFlat,
	Wig_FemaleHairFlatTopTINT = CorpseHairCuttingUtils.hairStyles.FlatTop,
	Wig_FemaleHairGreasedBackTINT = CorpseHairCuttingUtils.hairStyles.GreasedBack,
	Wig_FemaleHairSpikeTINT = CorpseHairCuttingUtils.hairStyles.Spike,
	Wig_FemaleHairPartingCentreLongTINT = CorpseHairCuttingUtils.hairStyles.CentrePartingLong,
	Wig_FemaleHairCornrowsTINT = CorpseHairCuttingUtils.hairStyles.Cornrows,
	Wig_MaleHairDonnyTINT = CorpseHairCuttingUtils.hairStyles.Donny,
	Wig_FemaleHairMohawkFanTINT = CorpseHairCuttingUtils.hairStyles.MohawkFan,
	Wig_FemaleHairMohawkSpikeTINT = CorpseHairCuttingUtils.hairStyles.MohawkSpike,
	Wig_FemaleHairBraided01TINT = CorpseHairCuttingUtils.hairStyles.Braids,
	Wig_FemaleHairGrungeyTINT = CorpseHairCuttingUtils.hairStyles.Grungey,
	Wig_FemaleHairGrungeyBehindEarTINT = CorpseHairCuttingUtils.hairStyles.GrungeyBehindEars,
	Wig_FemaleHairGrungeyPartingTINT = CorpseHairCuttingUtils.hairStyles.GrungeyParted,
	Wig_FemaleHairGrungey02TINT = CorpseHairCuttingUtils.hairStyles.Grungey02,
	Wig_FemaleHairOverEyeTINT = CorpseHairCuttingUtils.hairStyles.OverEye,
	Wig_FemaleHairOverEyeCurlyTINT = CorpseHairCuttingUtils.hairStyles.OverEyeCurly,
	Wig_FemaleHairOverEyeLeftTINT = CorpseHairCuttingUtils.hairStyles.OverLeftEye,
	Wig_FemaleHairBobTINT = CorpseHairCuttingUtils.hairStyles.Bob,
	Wig_FemaleHairBobCurlyTINT = CorpseHairCuttingUtils.hairStyles.BobCurly,
	Wig_FemaleHairBunTINT = CorpseHairCuttingUtils.hairStyles.Bun,
	Wig_FemaleHairBunCurlyTINT = CorpseHairCuttingUtils.hairStyles.BunCurly,
	Wig_FemaleHairBackTINT = CorpseHairCuttingUtils.hairStyles.Back,
	Wig_FemaleHairTopMopTINT = CorpseHairCuttingUtils.hairStyles.TopCurls,
	Wig_FemaleHairRachelTINT = CorpseHairCuttingUtils.hairStyles.Rachel,
	Wig_FemaleHairRachelCurlyTINT = CorpseHairCuttingUtils.hairStyles.RachelCurly,
	Wig_FemaleHairPonyTailTINT = CorpseHairCuttingUtils.hairStyles.PonyTail,
	Wig_FemaleHairPonyTailBraidedTINT = CorpseHairCuttingUtils.hairStyles.PonyTailBraids,
	Wig_FemaleHairLibertySpikesTINT = CorpseHairCuttingUtils.hairStyles.LibertySpikes,
	Wig_MaleHairBuffontTINT = CorpseHairCuttingUtils.hairStyles.Buffont,
	Wig_FemaleHairLongBraidTINT = CorpseHairCuttingUtils.hairStyles.LongBraids,
	Wig_MaleHairMulletTINT = CorpseHairCuttingUtils.hairStyles.Mullet,
	Wig_MaleHairMulletCurlyTINT = CorpseHairCuttingUtils.hairStyles.MulletCurly,
	Wig_MaleHairMetalTINT = CorpseHairCuttingUtils.hairStyles.Metal,
	Wig_MaleHairFabianTINT = CorpseHairCuttingUtils.hairStyles.Fabian,
	Wig_MaleHairFabianCurlyTINT = CorpseHairCuttingUtils.hairStyles.FabianCurly,
	Wig_MaleHairFabianBraidedTINT = CorpseHairCuttingUtils.hairStyles.FabianBraided,
	Wig_FemaleHairLongBraid02TINT = CorpseHairCuttingUtils.hairStyles.LongBraids02,
	Wig_FemaleHairHatLongTINT = CorpseHairCuttingUtils.hairStyles.HatLong,
	Wig_FemaleHairHatLongBraidedTINT = CorpseHairCuttingUtils.hairStyles.HatLongBraided,
	Wig_FemaleHairHatLongCurlyTINT = CorpseHairCuttingUtils.hairStyles.HatLongCurly,
	Wig_FemaleHairLongTINT = CorpseHairCuttingUtils.hairStyles.Long,
	Wig_FemaleHairLongCurlyTINT = CorpseHairCuttingUtils.hairStyles.Longcurly,
	Wig_FemaleHairKateTINT = CorpseHairCuttingUtils.hairStyles.Kate,
	Wig_FemaleHairKateCurlyTINT = CorpseHairCuttingUtils.hairStyles.KateCurly,
	Wig_FemaleHairLong2TINT = CorpseHairCuttingUtils.hairStyles.Long2,
	Wig_FemaleHairLong2CurlyTINT = CorpseHairCuttingUtils.hairStyles.Long2curly,
	
	FakeBeard_BeardOnlyTINT = CorpseHairCuttingUtils.beardStyles.BeardOnly,
	FakeBeard_MoustacheTINT = CorpseHairCuttingUtils.beardStyles.Moustache,
	FakeBeard_GoateeTINT = CorpseHairCuttingUtils.beardStyles.Goatee,
	FakeBeard_ChinTINT = CorpseHairCuttingUtils.beardStyles.Chin,
	FakeBeard_PointyChinTINT = CorpseHairCuttingUtils.beardStyles.PointyChin,
	FakeBeard_ChopsTINT = CorpseHairCuttingUtils.beardStyles.Chops,
	FakeBeard_FullTINT = CorpseHairCuttingUtils.beardStyles.Full,
	FakeBeard_LongTINT = CorpseHairCuttingUtils.beardStyles.Long,
	FakeBeard_LongScruffyTINT = CorpseHairCuttingUtils.beardStyles.LongScruffy,
	
}

CorpseHairCuttingUtils.wigStyleIndexed = {}


CorpseHairCuttingUtils.commonHairColor = {
    {0.831, 0.671, 0.271},
    {0.663, 0.522, 0.318},
    {0.624, 0.424, 0.169},
    {0.612, 0.510, 0.337},
    {0.596, 0.439, 0.298},
    {0.573, 0.475, 0.349},
    {0.435, 0.341, 0.235},
    {0.337, 0.263, 0.176},
    {0.345, 0.208, 0.133},
    {0.220, 0.161, 0.106},
    {0.204, 0.192, 0.188},
    {0.106, 0.090, 0.086},
    {0.486, 0.471, 0.439},
    {0.651, 0.620, 0.502},
    {0.737, 0.694, 0.616},
    {0.651, 0.643, 0.624},
    {0.745, 0.522, 0.404},
    {0.651, 0.365, 0.247},
    {0.584, 0.251, 0.251},
    {0.525, 0.259, 0.188},
}

for k, v in pairs(CorpseHairCuttingUtils.wigStyle) do
	v.itemType = "Base." .. k
	table.insert(CorpseHairCuttingUtils.wigStyleIndexed, v)
end

CorpseHairCuttingUtils.getHairStyle = function(style)
	if CorpseHairCuttingUtils.hairStyles[style] then
		return CorpseHairCuttingUtils.hairStyles[style]
	else
		return CorpseHairCuttingUtils.hairStyles.default
	end
end

CorpseHairCuttingUtils.getBeardStyle = function(style)
	if CorpseHairCuttingUtils.beardStyles[style] then
		return CorpseHairCuttingUtils.beardStyles[style]
	else
		return CorpseHairCuttingUtils.beardStyles.default
	end
end

CorpseHairCuttingUtils.averageColor = function(colors)
    local count = #colors
    if count == 0 then return {0, 0, 0} end

    local totalR, totalG, totalB = 0, 0, 0

    for _, color in ipairs(colors) do
        totalR = totalR + color[1]
        totalG = totalG + color[2]
        totalB = totalB + color[3]
    end

    return Color.new(totalR / count, totalG / count, totalB / count)
end