
class GramophoneRecord
{
	string name;
	string filename;

	GramophoneRecord(string name, string filename)
	{
		this.name = name;
		this.filename = filename;
	}
};

const GramophoneRecord@[] records =
{
	GramophoneRecord("Mountain King", "Disc_MountainKing.ogg"),
	GramophoneRecord("No Hushing", "Disc_NoHushing.ogg"),
	GramophoneRecord("Sacred War", "Disc_SacredWar.ogg"),
	GramophoneRecord("Maple Leaf", "Disc_MapleLeaf.ogg"),
	GramophoneRecord("Drunken Sailor", "Disc_DrunkenSailor.ogg"),
	GramophoneRecord("Suite Punta del Este", "Disc_SuitePuntaDelEste.ogg"),
	GramophoneRecord("Odd Couple", "Disc_OddCouple.ogg"),
	GramophoneRecord("Bandit Radio", "Disc_Bandit.ogg"),
	GramophoneRecord("Tea for Two", "Disc_TeaForTwo.ogg"),
	GramophoneRecord("Keep on Running", "Disc_KeepOnRunning.ogg"),
	GramophoneRecord("Big Iron", "Disc_BigIron.ogg"),
	GramophoneRecord("Fortunate Son", "Disc_FortunateSon.ogg"),
};