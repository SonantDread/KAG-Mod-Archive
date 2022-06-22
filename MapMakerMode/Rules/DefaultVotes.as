//implements 2 default vote types (kick and next map) and menus for them

#include "VoteCommon.as"
#include "BasePNGLoader.as";

bool g_haveStartedVote = false;
s32 g_lastVoteCounter = 0;
string g_lastUsernameVoted = "";
const float required_minutes = 1; //time you have to wait after joining w/o skip_votewait.

s32 g_lastNextmapCounter = 0;
const float required_minutes_nextmap = 1; //global nextmap vote cooldown

const s32 VoteKickTime = 30; //minutes (30min default)

//kicking related globals and enums
enum kick_reason
{
	kick_reason_griefer = 0,
	kick_reason_hacker,
	kick_reason_teamkiller,
	kick_reason_spammer,
	kick_reason_non_participation,
	kick_reason_count,
};
string[] kick_reason_string = { "Griefer", "Hacker", "Teamkiller", "Chat Spam", "Non-Participation" };

string g_kick_reason = kick_reason_string[kick_reason_griefer]; //default

//next map related globals and enums
enum nextmap_reason
{
	nextmap_reason_ruined = 0,
	nextmap_reason_stalemate,
	nextmap_reason_bugged,
	nextmap_reason_count,
};

//next map related globals and enums
enum loadmap_reason
{
	loadmap_reason_ruined = 0,
	loadmap_reason_stalemate,
	loadmap_reason_bugged,
	loadmap_reason_count,
};

string[] nextmap_reason_string = { "Map Ruined", "Stalemate", "Game Bugged" };
string[] loadmap_reason_string = { "Map Ruined", "Stalemate", "Game Bugged" };

//votekick and vote nextmap

const string votekick_id = "vote: kick";
const string votenextmap_id = "vote: nextmap";
const string voteloadmap_id = "vote: loadmap";

//set up the ids
void onInit(CRules@ this)
{
	this.addCommandID(votekick_id);
	this.addCommandID(votenextmap_id);
	this.addCommandID(voteloadmap_id);
}


void onRestart(CRules@ this)
{
	g_lastNextmapCounter = 60 * getTicksASecond() * required_minutes_nextmap;
}

void onTick(CRules@ this)
{
	if (g_lastVoteCounter < 60 * getTicksASecond()*required_minutes)
	{
		g_lastVoteCounter++;
	}

	if (g_lastNextmapCounter < 60 * getTicksASecond()*required_minutes_nextmap)
	{
		g_lastNextmapCounter++;
	}
}

//VOTE KICK --------------------------------------------------------------------
//votekick functors

class VoteKickFunctor : VoteFunctor
{
	VoteKickFunctor() {} //dont use this
	VoteKickFunctor(CPlayer@ _kickplayer)
	{
		@kickplayer = _kickplayer;
	}

	CPlayer@ kickplayer;

	void Pass(bool outcome)
	{
		if (kickplayer !is null && outcome)
		{
			client_AddToChat(
				getTranslatedString("Votekick passed! {USER} will be kicked out.")
					.replace("{USER}", kickplayer.getUsername()),
				vote_message_colour()
			);

			if (getNet().isServer())
			{
				getSecurity().ban(kickplayer, VoteKickTime, "Voted off"); //30 minutes ban
			}
		}
	}
};

class VoteKickCheckFunctor : VoteCheckFunctor
{
	VoteKickCheckFunctor() {}//dont use this
	VoteKickCheckFunctor(CPlayer@ _kickplayer, string _reason)
	{
		@kickplayer = _kickplayer;
		reason = _reason;
	}

	CPlayer@ kickplayer;
	string reason;

	bool PlayerCanVote(CPlayer@ player)
	{
		if (!getSecurity().checkAccess_Feature(player, "mark_player")) return false;

		if (reason.find(kick_reason_string[kick_reason_griefer]) != -1 || //reason contains "Griefer"
				reason.find(kick_reason_string[kick_reason_teamkiller]) != -1 || //or TKer
				reason.find(kick_reason_string[kick_reason_non_participation]) != -1) //or AFK
		{
			return (player.getTeamNum() == kickplayer.getTeamNum() || //must be same team
					kickplayer.getTeamNum() == getRules().getSpectatorTeamNum() || //or they're spectator
					getSecurity().checkAccess_Feature(player, "mark_any_team"));   //or has mark_any_team
		}

		return true; //spammer, hacker (custom?)
	}
};

class VoteKickLeaveFunctor : VotePlayerLeaveFunctor
{
	VoteKickLeaveFunctor() {} //dont use this
	VoteKickLeaveFunctor(CPlayer@ _kickplayer)
	{
		@kickplayer = _kickplayer;
	}

	CPlayer@ kickplayer;

	//avoid dangling reference to player
	void PlayerLeft(VoteObject@ vote, CPlayer@ player)
	{
		if (player is kickplayer)
		{
			client_AddToChat(
				getTranslatedString("{USER} left early, acting as if they were kicked.")
					.replace("{USER}", player.getUsername()),
				vote_message_colour()
			);
			if (getNet().isServer())
			{
				getSecurity().ban(player, VoteKickTime, "Ran from vote");
			}

			CancelVote(vote);
		}
	}
};

//setting up a votekick object
VoteObject@ Create_Votekick(CPlayer@ player, CPlayer@ byplayer, string reason)
{
	VoteObject vote;

	@vote.onvotepassed = VoteKickFunctor(player);
	@vote.canvote = VoteKickCheckFunctor(player, reason);
	@vote.playerleave = VoteKickLeaveFunctor(player);

	vote.title = "Kick {USER}?";
	vote.reason = reason;
	vote.byuser = byplayer.getUsername();
	vote.user_to_kick = player.getUsername();
	vote.forcePassFeature = "ban";
	vote.cancel_on_restart = false;

	CalculateVoteThresholds(vote);

	return vote;
}

//VOTE NEXT MAP ----------------------------------------------------------------
//nextmap functors

class VoteNextmapFunctor : VoteFunctor
{
	VoteNextmapFunctor() {} //dont use this
	VoteNextmapFunctor(CPlayer@ player)
	{
		string charname = player.getCharacterName();
		string username = player.getUsername();
		//name differs?
		if (
			charname != username &&
			charname != player.getClantag() + username &&
			charname != player.getClantag() + " " + username
		) {
			playername = charname + " (" + player.getUsername() + ")";
		}
		else
		{
			playername = charname;
		}
	}

	string playername;
	void Pass(bool outcome)
	{
		if (outcome)
		{
			if (getNet().isServer())
			{
				LoadNextMap();
			}
		}
		else
		{
			client_AddToChat(
				getTranslatedString("{USER} needs to take a spoonful of cement! Play on!")
					.replace("{USER}", playername),
				vote_message_colour()
			);
		}
	}
};

class VoteNextmapCheckFunctor : VoteCheckFunctor
{
	VoteNextmapCheckFunctor() {}

	bool PlayerCanVote(CPlayer@ player)
	{
		return getSecurity().checkAccess_Feature(player, "map_vote");
	}
};

//setting up a vote next map object
VoteObject@ Create_VoteNextmap(CPlayer@ byplayer, string reason)
{
	VoteObject vote;

	@vote.onvotepassed = VoteNextmapFunctor(byplayer);
	@vote.canvote = VoteNextmapCheckFunctor();

	vote.title = "Skip to next map?";
	vote.reason = reason;
	vote.byuser = byplayer.getUsername();
	vote.forcePassFeature = "nextmap";
	vote.cancel_on_restart = true;

	CalculateVoteThresholds(vote);

	return vote;
}

//VOTE NEXT MAP ----------------------------------------------------------------
//loadmap functors

class VoteLoadmapFunctor : VoteFunctor
{
	VoteLoadmapFunctor() {} //dont use this
	VoteLoadmapFunctor(CPlayer@ player)
	{
		string charname = player.getCharacterName();
		string username = player.getUsername();
		//name differs?
		if (
			charname != username &&
			charname != player.getClantag() + username &&
			charname != player.getClantag() + " " + username
		) {
			playername = charname + " (" + player.getUsername() + ")";
		}
		else
		{
			playername = charname;
		}
	}

	string playername;
	void Pass(VoteObject@ vote, bool outcome)
	{
		string mapname = vote.mapname;
		if (outcome)
		{
			print("as ddsadsad "+mapname);
			if (getNet().isServer())
			{
				LoadMap(mapname);
			}
		}
		else
		{
			client_AddToChat(
				getTranslatedString("{USER} needs to take a spoonful of cement! Play on!")
					.replace("{USER}", playername),
				vote_message_colour()
			);
		}
	}
};

class VoteLoadmapCheckFunctor : VoteCheckFunctor
{
	VoteLoadmapCheckFunctor() {}

	bool PlayerCanVote(CPlayer@ player)
	{
		return getSecurity().checkAccess_Feature(player, "map_vote");
	}
};

//setting up a vote next map object
VoteObject@ Create_VoteLoadmap(CPlayer@ byplayer, string reason, string mapname)
{
	VoteObject vote;

	@vote.onvotepassed = VoteLoadmapFunctor(byplayer);
	@vote.canvote = VoteLoadmapCheckFunctor();

	vote.title = "Load map?";
	vote.reason = reason;	
	vote.mapname = mapname;
	vote.byuser = byplayer.getUsername();
	vote.forcePassFeature = "nextmap";
	vote.cancel_on_restart = true;

	CalculateVoteThresholds(vote);

	return vote;
}

//create menus for kick and nextmap

void onMainMenuCreated(CRules@ this, CContextMenu@ menu)
{
	//get our player first - if there isn't one, move on
	CPlayer@ me = getLocalPlayer();
	if (me is null) return;

	CRules@ rules = getRules();

	if (Rules_AlreadyHasVote(rules))
	{
		UI::Clear();
	UI::SetFont("hud");
	CBitStream params;

	CBlob@[] players;
    getBlobsByTag("player", players);
	for (uint i = 0; i < players.length; i++)
    {
    	CBlob@ blob = players[i];
		if(blob.isMyPlayer())
		{
			blob.server_SetActive(true);
			blob.getSprite().server_SetActive(true);
			blob.AddScript("StandardControls.as");
		}
	}

		Menu::addContextItem(menu, getTranslatedString("(Vote already in progress)"), "DefaultVotes.as", "void CloseMenu()");
		Menu::addSeparator(menu);

		return;

	}

	//and advance context menu when clicked
	CContextMenu@ votemenu = Menu::addContextMenu(menu, getTranslatedString("Start a Vote"));
	Menu::addSeparator(menu);

	//vote options menu

	CContextMenu@ kickmenu = Menu::addContextMenu(votemenu, getTranslatedString("Kick"));
	CContextMenu@ mapmenu = Menu::addContextMenu(votemenu, getTranslatedString("Next Map"));
	Menu::addContextItem(votemenu, "Load Map", "DefaultVotes.as", "void Callback_Loadmap()");
	Menu::addSeparator(votemenu); //before the back button

	bool can_skip_wait = getSecurity().checkAccess_Feature(me, "skip_votewait");

	//kick menu
	if (getSecurity().checkAccess_Feature(me, "mark_player"))
	{
		if (g_lastVoteCounter < 60 * getTicksASecond()*required_minutes
				&& (!can_skip_wait || g_haveStartedVote))
		{
			string cantstart_info = getTranslatedString(
				"Voting requires a {REQUIRED_MIN} min wait\n" +
				"after each started vote to\n" +
				"prevent spamming/abuse.\n"
			).replace("{REQUIRED_MIN}", "" + required_minutes);

			Menu::addInfoBox(kickmenu, getTranslatedString("Can't Start Vote"), cantstart_info);
		}
		else
		{
			string votekick_info = getTranslatedString(
				"Vote to kick a player on your team\nout of the game.\n\n" +
				"- use responsibly\n" +
				"- report any abuse of this feature.\n" +
				"\nTo Use:\n\n" +
				"- select a reason from the\n     list (default is griefing).\n" +
				"- select a name from the list.\n" +
				"- everyone votes.\n"
			);
			Menu::addInfoBox(kickmenu, getTranslatedString("Vote Kick"), votekick_info);

			Menu::addSeparator(kickmenu);

			//reasons
			for (uint i = 0 ; i < kick_reason_count; ++i)
			{
				CBitStream params;
				params.write_u8(i);
				Menu::addContextItemWithParams(kickmenu, getTranslatedString(kick_reason_string[i]), "DefaultVotes.as", "Callback_KickReason", params);
			}

			Menu::addSeparator(kickmenu);

			//write all players on our team
			bool added = false;
			for (int i = 0; i < getPlayersCount(); ++i)
			{
				CPlayer@ player = getPlayer(i);

				//if(player is me) continue; //don't display ourself for kicking
				//commented out for max lols

				int player_team = player.getTeamNum();
				if ((player_team == me.getTeamNum() || player_team == this.getSpectatorTeamNum()
						|| getSecurity().checkAccess_Feature(me, "mark_any_team"))
						&& (!getSecurity().checkAccess_Feature(player, "kick_immunity")))
				{
					string descriptor = player.getCharacterName();

					if (player.getUsername() != player.getCharacterName())
						descriptor += " (" + player.getUsername() + ")";

					if(g_lastUsernameVoted == player.getUsername())
					{
						string title = getTranslatedString(
							"Cannot kick {USER}"
						).replace("{USER}", descriptor);
						string info = getTranslatedString(
							"You started a vote for\nthis person last time.\n\nSomeone else must start the vote."
						);
						//no-abuse box
						Menu::addInfoBox(
							kickmenu,
							title,
							info
						);
					}
					else
					{
						string kick = getTranslatedString("Kick {USER}").replace("{USER}", descriptor);
						string kicking = getTranslatedString("Kicking {USER}").replace("{USER}", descriptor);
						string info = getTranslatedString( "Make sure you're voting to kick\nthe person you meant.\n" );

						CContextMenu@ usermenu = Menu::addContextMenu(kickmenu, kick);
						Menu::addInfoBox(usermenu, kicking, info);
						Menu::addSeparator(usermenu);

						CBitStream params;
						params.write_u16(player.getNetworkID());

						Menu::addContextItemWithParams(
							usermenu, getTranslatedString("Yes, I'm sure"),
							"DefaultVotes.as", "Callback_Kick",
							params
						);
						added = true;

						Menu::addSeparator(usermenu);
					}
				}
			}

			if (!added)
			{
				Menu::addContextItem(
					kickmenu, getTranslatedString("(No-one available)"),
					"DefaultVotes.as", "void CloseMenu()"
				);
			}
		}
	}
	else
	{
		Menu::addInfoBox(
			kickmenu,
			getTranslatedString("Can't vote"),
			getTranslatedString(
				"You are now allowed to votekick\n" +
				"players on this server\n"
			)
		);
	}
	Menu::addSeparator(kickmenu);

	//nextmap menu
	//if (getSecurity().checkAccess_Feature(me, "map_vote"))
	{
		if (g_lastNextmapCounter < 60 * getTicksASecond()*required_minutes_nextmap
				&& (!can_skip_wait || g_haveStartedVote))
		{
			string cantstart_info = getTranslatedString(
				"Voting for next map\n" +
				"requires a {NEXTMAP_MINS} min wait\n" +
				"after each started vote\n" +
				"to prevent spamming.\n"
			).replace("{NEXTMAP_MINS}", "" + required_minutes_nextmap);
			Menu::addInfoBox( mapmenu, getTranslatedString("Can't Start Vote"), cantstart_info);
		}
		else
		{
			string nextmap_info = getTranslatedString(
				"Vote to change the map\nto the next in cycle.\n\n" +
				"- report any abuse of this feature.\n" +
				"\nTo Use:\n\n" +
				"- select a reason from the list.\n" +
				"- everyone votes.\n"
			);
			Menu::addInfoBox(mapmenu, getTranslatedString("Vote Next Map"), nextmap_info);

			Menu::addSeparator(mapmenu);
			//reasons
			for (uint i = 0 ; i < nextmap_reason_count; ++i)
			{
				CBitStream params;
				params.write_u8(i);
				Menu::addContextItemWithParams(mapmenu, getTranslatedString(nextmap_reason_string[i]), "DefaultVotes.as", "Callback_NextMap", params);
			}
		}
	}
	//else
	//{
	//	Menu::addInfoBox(
	//		mapmenu,
	//		getTranslatedString("Can't vote"),
	//		getTranslatedString(
	//			"You are not allowed to vote\n" +
	//			"to change the map on this server\n"
	//		)
	//	);
	//}
	Menu::addSeparator(mapmenu);
	
}

void onPlayerStartedVote()
{
	g_lastVoteCounter = 0;
	g_lastNextmapCounter = 0;
	g_haveStartedVote = true;
}

void Callback_KickReason(CBitStream@ params)
{
	u8 id; if (!params.saferead_u8(id)) return;

	if (id < kick_reason_count)
	{
		g_kick_reason = kick_reason_string[id];
	}
}

void Callback_Kick(CBitStream@ params)
{
	CloseMenu(); //definitely close the menu

	CPlayer@ me = getLocalPlayer();
	if (me is null) return;

	u16 id;
	if (!params.saferead_u16(id)) return;

	CPlayer@ other_player = getPlayerByNetworkId(id);
	if (other_player is null) return;

	if (getSecurity().checkAccess_Feature(other_player, "kick_immunity"))
		return;

	//monitor to prevent abuse
	g_lastUsernameVoted = other_player.getUsername();

	CBitStream params2;

	params2.write_u16(other_player.getNetworkID());
	params2.write_u16(me.getNetworkID());
	params2.write_string(g_kick_reason);

	getRules().SendCommand(getRules().getCommandID(votekick_id), params2);
	onPlayerStartedVote();
}

void Callback_NextMap(CBitStream@ params)
{
	CloseMenu(); //definitely close the menu

	CPlayer@ me = getLocalPlayer();
	if (me is null) return;

	u8 id;
	if (!params.saferead_u8(id)) return;

	string reason = "";
	if (id < nextmap_reason_count)
	{
		reason = nextmap_reason_string[id];
	}

	CBitStream params2;

	params2.write_u16(me.getNetworkID());
	params2.write_string(reason);

	getRules().SendCommand(getRules().getCommandID(votenextmap_id), params2);
	onPlayerStartedVote();
}

//actually setting up the votes
void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
	if (Rules_AlreadyHasVote(this))
		return;

	if (cmd == this.getCommandID(votekick_id))
	{
		u16 playerid, byplayerid;
		string reason;

		if (!params.saferead_u16(playerid)) return;
		if (!params.saferead_u16(byplayerid)) return;
		if (!params.saferead_string(reason)) return;

		CPlayer@ player = getPlayerByNetworkId(playerid);
		CPlayer@ byplayer = getPlayerByNetworkId(byplayerid);

		if (player !is null && byplayer !is null)
			Rules_SetVote(this, Create_Votekick(player, byplayer, reason));
	}
	else if (cmd == this.getCommandID(votenextmap_id))
	{
		u16 byplayerid;
		string reason;

		if (!params.saferead_u16(byplayerid)) return;
		if (!params.saferead_string(reason)) return;

		CPlayer@ byplayer = getPlayerByNetworkId(byplayerid);

		if (byplayer !is null)
			Rules_SetVote(this, Create_VoteNextmap(byplayer, reason));

		g_lastNextmapCounter = 0;
	}
	else if (cmd == this.getCommandID(voteloadmap_id))
	{
		u16 byplayerid;
		string reason;
		string mapname;

		if (!params.saferead_u16(byplayerid)) return;
		if (!params.saferead_string(reason)) return;
		if (!params.saferead_string(mapname)) return;


		CPlayer@ byplayer = getPlayerByNetworkId(byplayerid);

		if (byplayer !is null)
			Rules_SetVote(this, Create_VoteLoadmap(byplayer, reason, mapname));

		g_lastNextmapCounter = 0;
	}

}

#include "UI.as"
#include "BasePNGLoader.as";
//skin
#include "MainButtonRender.as"
#include "MainImageRender.as"
#include "MainTextInputRender.as"
#include "MainToggleRender.as"
#include "MainOptionRender.as"
#include "MainSliderRender.as"
//controls
#include "UIButton.as"
#include "UIImage.as"
#include "UITextInput.as"
#include "UIToggle.as"
#include "UIOption.as"
#include "UILabel.as"
#include "UISlider.as"
//map maker
#include "UIGenSlider.as"
#include "UIMapMakerButton.as"
#include "UIMapMakerInfo.as"
#include "UIMapMakerMapPreview.as"

float map_width = 0.2;
float map_height = 0.1;
float SetMapWidth( float value )		{ return map_width = value;}
float SetMapHeight( float value )		{ return map_height	= value;}

string[] MapNames;
string filepath = "";
string[] filepaths;

void Callback_Loadmap()
{
	CloseMenu(); //definitely close the menu
	MapNames.clear();
	filepaths.clear();

	ConfigFile cfg = ConfigFile();	
	if (cfg.loadFile("MapDirectories.cfg"))
	{
		cfg.readIntoArray_string( filepaths, "filepaths" );
		for (uint i = 0; i < filepaths.length; i++)
		{
			filepath = filepaths[i];
			CFileMatcher@ files = CFileMatcher(filepath+".png");
			while (files.iterating())
			{		
				const string filename = files.getCurrent();

				if (filename != "Maps/randomgrid_castle.png" && filename != "Maps/randomgrid_castle_2.png" &&
					filename != "Maps/randomgrid_cave.png"   && filename != "Maps/randomgrid_cave_2.png" &&
					filename != "Maps/tutorial_archer.png"   && filename != "Maps/tutorial_builder.png" &&
					filename != "Maps/tutorial_knight.png"   && filename != "Maps/MapPalette.png")
				{
					MapNames.push_back(filename);	
				}					
			}
		}
	}	

	CBlob@[] players;
    getBlobsByTag("player", players);
    for (uint i = 0; i < players.length; i++)
    {
    	CBlob@ blob = players[i];
		if(blob.isMyPlayer())
		{
			blob.server_SetActive(false);
			blob.RemoveScript("StandardControls.as");
		}
	}

	ShowLoadMap();
}

void ShowLoadMap()
{
	UI::Group@ group;
	UI::Control@ control;
	UI::Clear();
	
	UI::Control@ c;

	UI::AddGroup("Load Map list", Vec2f(0.02,0.025), Vec2f(0.4,0.935));
		UI::Grid( 1, 20, 0.01 );
		for (int i = 0; i < 20; ++i)
		{
			UI::AddSeparator();
		}
		UI::Background();

	UI::AddGroup("Load Map scroll", Vec2f(0.4,0.025), Vec2f(0.43,0.985));	
		UI::Grid( 1, 1, 0.0 );
		UI::VerticalScrollbar::Add(ScrollMapList, 1, 1.1);
		UI::Background();

	UI::AddGroup("Load Map map preview", Vec2f(0.435,0.05), Vec2f(0.99,0.70));
		UI::Grid( 1, 1, 0.136 );
		UI::AddSeparator();


	UI::AddGroup("Load Map info", Vec2f(0.435,0.025), Vec2f(0.99,0.985));
		UI::Grid( 1, 1, 0.05 );
		UI::Background();

	UI::AddGroup("Load Map Search Bar", Vec2f(0.02,0.935), Vec2f(0.4,0.99));
		UI::Grid( 1, 1, 0.0 );
		@c = UI::TextInput::Add("", null, search, "", 0, "Search..");
		 c.proxy.align.Set(0.02f, 0.5f);
		 c.vars.set("caption centered", false);
		 c.input = UpdateSearch;

	UI::AddGroup("Load Map Search Clear Button", Vec2f(0.374,0.935), Vec2f(0.401,0.99));
		UI::Grid( 1, 1, 0.3 );
		UI::Button::Add("X", ClearLoadMapSearch, "");
		 //UI::Button::AddIcon("MakerPlacementMenu.png", Vec2f(24, 8), 62 );

	//UI::AddGroup("loadbutton", Vec2f(0.6,0.8), Vec2f(0.8,0.9));
	//	UI::Grid( 1, 1 );
	//	UI::Button::Add("Load", SelectLoad, "loadmap");

		//Refresh(null,null);

		ApplyFilters();
		SortMapList();

	@UI::getData().activeGroup = group;
}

void ClearLoadMapSearch(UI::Group@ group, UI::Control@ control)
{	
	search = "";
	UI::Data@ data = UI::getData();
	UI::Control@ textbar = UI::getGroup(data, "Load Map Search Bar").controls[0][0];
	textbar.caption = "";
	ApplyFilters();
	SortMapList();
}

string search;
void UpdateSearch( UI::Control@ control, const s32 key, bool &out ok, bool &out cancel )
{
	UI::TextInput::Input( control, key, ok, cancel );
	CRules@ rules = getRules();
	if (key != 0) 
	{
		rules.set_u32("search update time", getGameTime());
	} 
	else 
	{
		uint gameTime = getGameTime();
		uint updateTime = rules.get_u32("search update time");
		if (updateTime == 0) {
			rules.set_u32("search update time", gameTime);
			updateTime = gameTime;
		}

		if (gameTime == updateTime + 10) {
			search = control.caption;
			ApplyFilters();
			SortMapList();
		}
	}
}

float ScrollMapList( float newValue )
{
	UI::Data@ data = UI::getData();
	UI::Control@ scroll = UI::getGroup(data, "Load Map scroll").controls[0][0];
	float oldValue;
	scroll.vars.get( "value", oldValue );

	bool refresh = newValue == -1;
	if(refresh) newValue = 0;
	int offset = Maths::Round(Maths::Max(searchlist.length-20, 0) * newValue);
	if(offset == Maths::Round((searchlist.length-20) * oldValue) && !refresh) return newValue;

	UI::Group@ list = UI::getGroup(data, "Load Map list");

	int sunkenIndex = -1, selectedIndex = -1;
	UI::Control@ prev;
	if(getRules().get("radio set map selection", @prev) && prev !is null){
		prev.vars.get( "i", sunkenIndex );
	}
	if (list.activeControl !is null) {
		list.activeControl.vars.get( "i", selectedIndex );
	}

	UI::Group@ active = data.activeGroup;
	@data.activeGroup = list;
// print("ClearGroup: "+list.name);
	UI::ClearGroup(list);
	for (int i = 0; i < 20; ++i)
		if(i < searchlist.length)	
			UI::LoadMapButton::Add(searchlist[offset + i], offset + i);
		else
			UI::AddSeparator();

	sunkenIndex -= offset;
	selectedIndex -= offset;
	if (sunkenIndex >= 0 && sunkenIndex < 20) {
		UI::Control@ sunken = list.controls[0][sunkenIndex];
		getRules().set("radio set map selection", @sunken);
		sunken.vars.set( "sunken", true );
	}
	if (selectedIndex >= 0 && selectedIndex < 20) {
		UI::SetSelection(selectedIndex);
	}

	@data.activeGroup = active;

	return newValue;
}

void Refresh( UI::Group@ group, UI::Control@ control )
{
	searchlist.clear();

	UI::Data@ data = UI::getData();
	UI::Control@ scroll = UI::getGroup(data, "Load Map scroll").controls[0][0];
	scroll.vars.set( "value", ScrollMapList(-1) );
	getRules().set("radio set map selection", null);

	UI::Group@ active = data.activeGroup;
	UI::Group@ info = UI::getGroup(data, "Load Map info");
	@data.activeGroup = info;
	UI::ClearGroup(info);
	UI::MapInfo::Add("");
	UI::Group@ map = UI::getGroup(data, "Load Map map preview");
	@data.activeGroup = map;
	UI::ClearGroup(map);
	UI::AddSeparator();
	@data.activeGroup = active;
}

void SortMapList()
{
	searchlist.sortAsc();
	UI::Group@ group = UI::getGroup(UI::getData(), "Load Map scroll");
	if (group is null) return;
	UI::Control@ scroll = group.controls[0][0];
	scroll.vars.set( "increment", searchlist.length > 20 ? 1.0/(searchlist.length-20) : 2 );
	scroll.vars.set( "value", ScrollMapList(-1) );
}

string[] searchlist;
void ApplyFilters()
{
	searchlist.clear();
	for (int i = 0; i < MapNames.length; i++)
	{
		if (search == "" || MapNames[i].toLower().find(search) != -1) 
		{
			searchlist.push_back(MapNames[i]);
		}
	}
}

void SelectLoad( UI::Group@ group, UI::Control@ control )
{	
	UI::Clear();
	//LoadMap(rules.get_string("filepath"));

	CloseMenu(); //definitely close the menu

	CPlayer@ me = getLocalPlayer();
	if (me is null) return;	

	CBitStream params2;

	params2.write_u16(me.getNetworkID());
	params2.write_string("reason");
	params2.write_string(getRules().get_string("filepath"));

	getRules().SendCommand(getRules().getCommandID(voteloadmap_id), params2);
	onPlayerStartedVote();
}

void OnCloseMenu(CRules@ this)
{
	UI::Clear();
}

void CloseMenu()
{
	Menu::CloseAllMenus();
}