
const string tagname = "played fanfare";

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
	if (this.isGameOver() && !this.get_bool(tagname))
	{
		if(this.getTeamWon() >= 0)
		{
			// only play for winners
			CPlayer@ localplayer = getLocalPlayer();
			if (localplayer !is null)
			{
				CBlob@ playerBlob = getLocalPlayerBlob();
				int teamNum = playerBlob !is null ? playerBlob.getTeamNum() : localplayer.getTeamNum() ; // bug fix (cause in singelplayer player team is 255)
				if (teamNum == this.getTeamWon())
				{
					Sound::Play("/FanfareWin.ogg");
				}
				else
				{
					Sound::Play("/FanfareLose.ogg");
				}
			}

			this.set_bool(tagname, true);
			// no sound played on spectator or tie
		}
		else if (this.exists("winning_player"))
		{
			// only play for winners
			CPlayer@ localplayer = getLocalPlayer();
			if (localplayer !is null)
			{
				if (localplayer.getUsername() == this.get_string("winning_player"))
				{
					Sound::Play("/FanfareWin.ogg");
				}
				else
				{
					Sound::Play("/FanfareLose.ogg");
				}
			}

			this.set_bool(tagname, true);
			// no sound played on spectator or tie
		}
	}
}
