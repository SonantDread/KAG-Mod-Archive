
const string tagname = "played fanfare";

const int8 maxNumber = 22; //How many different songs?

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	this.set_bool(tagname, false);
}

void onTick(CRules@ this)
{
	if (this.isGameOver() && this.getTeamWon() >= 0 && !this.get_bool(tagname))
	{
		// only play for winners
		CPlayer@ localplayer = getLocalPlayer();
		if (localplayer !is null)
		{
			CBlob@ playerBlob = getLocalPlayerBlob();
			int teamNum = playerBlob !is null ? playerBlob.getTeamNum() : localplayer.getTeamNum() ; // bug fix (cause in singelplayer player team is 255)

			//Sound::Play("win"+XORRandom(maxNumber)+".ogg");
			Sound::Play("win"+(getGameTime()%(maxNumber+1))+".ogg");

		}

		this.set_bool(tagname, true);
		// no sound played on spectator or tie
	}
}
