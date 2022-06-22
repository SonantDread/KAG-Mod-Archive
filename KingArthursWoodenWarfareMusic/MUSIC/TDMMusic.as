// Game Music

#define CLIENT_ONLY

enum GameMusicTags
{
	world_intro,
	world_home,
	world_calm,
	world_battle,
	world_battle_2,
	world_train,
	world_outro,
	world_quick_out,
};

void onInit(CBlob@ this)
{
	CMixer@ mixer = getMixer();
	if (mixer is null)
		return;

	this.set_bool("initialized game", false);
}

void onTick(CBlob@ this)
{
	CMixer@ mixer = getMixer();
	if (mixer is null)
		return;

	if (s_gamemusic && s_musicvolume > 0.0f)
	{
		if (!this.get_bool("initialized game"))
		{
			AddGameMusic(this, mixer);
		}

		GameMusicLogic(this, mixer);
	}
	else
	{
		mixer.FadeOutAll(0.0f, 2.0f);
	}
}

//sound references with tag
void AddGameMusic(CBlob@ this, CMixer@ mixer)
{
	if (mixer is null)
		return;

	this.set_bool("initialized game", true);
	mixer.ResetMixer();
	mixer.AddTrack("Music6.ogg", world_battle);
	mixer.AddTrack("Music7.ogg", world_battle);
	mixer.AddTrack("Music8.ogg", world_battle);
	mixer.AddTrack("Music9.ogg", world_battle);
	mixer.AddTrack("Music12.ogg", world_battle);
	mixer.AddTrack("Music15.ogg", world_battle);
	mixer.AddTrack("Empty.ogg", world_battle);
	mixer.AddTrack("Empty.ogg", world_battle);
	mixer.AddTrack("Empty.ogg", world_battle);

	mixer.AddTrack("Music1.ogg", world_home);
	mixer.AddTrack("Music2.ogg", world_home);
	mixer.AddTrack("Music3.ogg", world_home);
	mixer.AddTrack("Music4.ogg", world_home);
	mixer.AddTrack("Music5.ogg", world_home);
	mixer.AddTrack("Music10.ogg", world_home);
	mixer.AddTrack("Music11.ogg", world_home);
	mixer.AddTrack("Music16.ogg", world_home);

	mixer.AddTrack("Music13.ogg", world_train);
	mixer.AddTrack("Music14.ogg", world_train);
	mixer.AddTrack("Empty.ogg", world_train);

}

uint timer = 0;

void GameMusicLogic(CBlob@ this, CMixer@ mixer)
{
	if (mixer is null)
		return;

	//warmup
	CRules @rules = getRules();

	if (getMap().getMapName() == "KAWWTraining.png")
	{
		if (mixer.getPlayingCount() == 0)
		{
			mixer.FadeInRandom(world_train , 0.0f);
		}
	}
	else
	{
		if (rules.isWarmup())
		{
			if (mixer.getPlayingCount() == 0)
			{
				mixer.FadeInRandom(world_home , 0.0f);
			}
		}
		else if (rules.isMatchRunning()) //battle music
		{
			if (mixer.getPlayingCount() == 0)
			{
				mixer.FadeInRandom(world_battle , 0.0f);
			}
		}
		else
		{
			mixer.FadeOutAll(0.0f, 1.0f);
		}
	}
}
