//historyblocks.as//

shared class HistoryBlock
{
	TileType tile;
	string name;
	u8 team;
	Vec2f pos;

	HistoryBlock() {} // required for handles to work

	HistoryBlock(TileType _tile, string _name, u8 _team, Vec2f _pos)
	{
		tile = _tile;
		name = _name;
		team = _team;
		pos = _pos;
	}
};

shared class HistoryInfo
{
	HistoryBlock@[][] historyblocks;
	u16 currentHistoryTimeline;

	void setTimeline()
	{			
		currentHistoryTimeline++;
		historyblocks.set_length(currentHistoryTimeline+2);
		historyblocks[currentHistoryTimeline-1].clear();
		historyblocks[currentHistoryTimeline].clear();
		historyblocks[currentHistoryTimeline+1].clear();
	}

	void PushHistory( Vec2f tilepos, u8 maptile, string name, u8 teamnum)
	{
		CBlob@ underblob = getMap().getBlobAtPosition(tilepos);	
		if (name != "" && name != "waterspawner") // is a blob
		{
			HistoryBlock b( maptile, name, teamnum, tilepos);
			historyblocks[currentHistoryTimeline-1].push_back( b );
		}
		else if (underblob !is null && !underblob.hasTag("player") && !underblob.isAttached())
		{
			HistoryBlock b( maptile, underblob.getName(), underblob.getTeamNum(), tilepos);
			historyblocks[currentHistoryTimeline-1].push_back( b );	
		}
		else if (getMap().isInWater(tilepos) || name == "waterspawner")
		{
			HistoryBlock b( maptile, "waterspawner", 0, tilepos);
			historyblocks[currentHistoryTimeline-1].push_back( b );	
		}
		else
		{
			HistoryBlock b( maptile, "", 0, tilepos);
			historyblocks[currentHistoryTimeline-1].push_back( b );	
		}		
	}
}

