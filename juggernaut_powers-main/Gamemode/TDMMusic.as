// Game Music

#include "ModPath.as";

void onCommand(CBlob@ this,u8 cmd,CBitStream @stream)
{
	if(cmd==this.getCommandID("requestMusic")){
		if(!getNet().isServer()){
			return;
		}
		CPlayer@ player=getPlayerByNetworkId(stream.read_u16());
		if(player !is null){
			CBitStream stream;
			stream.write_s32(this.get_s32("currentTrack"));
			this.server_SendCommandToPlayer(this.getCommandID("setMusic"),stream,player);
		}
	}else if(cmd==this.getCommandID("setMusic")){
		s32 musicId=				stream.read_s32();
		this.set_s32("currentTrack",musicId);
		print("got musicId "+musicId);
	}
}

void onInit(CBlob@ this)
{
	this.addCommandID("setMusic");
	this.addCommandID("requestMusic");
	this.Tag("musicPlayer");
	if(getNet().isServer()) {
		this.set_s32("currentTrack",XORRandom(13));
		CBitStream stream;
		stream.write_s32(this.get_s32("currentTrack"));
		this.SendCommand(this.getCommandID("setMusic"),stream);
		return;
	}else{
		this.set_s32("currentTrack",-1);
		CPlayer@ player=getLocalPlayer();
		if(player !is null){
			CBitStream stream;
			stream.write_u16(player.getNetworkID());
			this.SendCommand(this.getCommandID("requestMusic"),stream);
		}
	}
	this.set_u32("nextMusicRequest",0);
	
	CMixer@ mixer=getMixer();
	if(mixer is null){
		return;
	}
	this.set_bool("initialized game",false);
}
void onTick(CBlob@ this)
{
	CMixer@ mixer=getMixer();
	if(mixer is null){
		return;
	}

	if(s_gamemusic && s_musicvolume > 0.0f)
	{
		if(!this.get_bool("initialized game"))
		{
			AddGameMusic(this,mixer);
		}
		GameMusicLogic(this,mixer);
	}else{
		mixer.FadeOutAll(0.0f, 2.0f);
	}
}

//sound references with tag
void AddGameMusic(CBlob@ this,CMixer@ mixer)
{
	if(mixer is null){
		return;
	}

	this.set_bool("initialized game",true);
	mixer.ResetMixer();
	//mixer.AddTrack(MUSIC_PATH+"/AimShootKill.ogg",			0);		
	//mixer.AddTrack(MUSIC_PATH+"/DonnaToTheRescue.ogg",		3);
	
	//Doom
	mixer.AddTrack(MUSIC_PATH+"/DooM/BetweenLevels.ogg",			0);
	mixer.AddTrack(MUSIC_PATH+"/DooM/ByeByeAmericanPie.ogg",		1);
	mixer.AddTrack(MUSIC_PATH+"/DooM/HellKeep.ogg",					2);
	mixer.AddTrack(MUSIC_PATH+"/DooM/HidingTheSecrets.ogg",			3);
	mixer.AddTrack(MUSIC_PATH+"/DooM/ImpSong.ogg",					4);
	mixer.AddTrack(MUSIC_PATH+"/DooM/IntermissionFromDOOM.ogg",		5);
	mixer.AddTrack(MUSIC_PATH+"/DooM/InTheDark.ogg",				6);
	mixer.AddTrack(MUSIC_PATH+"/DooM/IntoTheBeastsBelly.ogg",		7);
	mixer.AddTrack(MUSIC_PATH+"/DooM/KitchenAceAndTakingNames.ogg",	8);
	mixer.AddTrack(MUSIC_PATH+"/DooM/LetsKillAtWill.ogg",			9);
	mixer.AddTrack(MUSIC_PATH+"/DooM/OnTheHunt.ogg",				10);
	mixer.AddTrack(MUSIC_PATH+"/DooM/Sadistic.ogg",					11);
	mixer.AddTrack(MUSIC_PATH+"/DooM/SmellsLikeBurningCorpse.ogg",	12);
}

void GameMusicLogic(CBlob@ this,CMixer@ mixer)
{
	if(mixer is null){
		return;
	}
	//warmup
	s32 currentTrack=this.get_s32("currentTrack");
	if(currentTrack>=0){
		if(mixer.getPlayingCount()==0) {
			mixer.FadeInRandom(currentTrack,0.0f);
		}
	}else{
		mixer.FadeOutAll(0.0f,1.0f);
		
		if(getGameTime()>=this.get_u32("nextMusicRequest")){
			CPlayer@ player=	getLocalPlayer();
			if(player !is null){
				CBitStream stream;
				stream.write_u16(player.getNetworkID());
				this.SendCommand(this.getCommandID("requestMusic"),stream);
				this.set_u32("nextMusicRequest",getGameTime()+30);
			}
		}
	}
}