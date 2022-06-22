// Simple chat processing example.
// If the player sends a command, the server does what the command says.
// You can also modify the chat message before it is sent to clients by modifying text_out
// By the way, in case you couldn't tell, "mat" stands for "material(s)"

#include "MakeSeed.as";
#include "MakeCrate.as";
#include "MakeScroll.as";
#include "RulesCore.as";
#include "Logging.as";
#include "SpareCode.as";
#include "FlagZonesCommon.as";

const bool chatCommandCooldown = false; // enable if you want cooldown on your server
const uint chatCommandDelay = 3 * 30; // Cooldown in seconds
const string[] blacklistedItems = {
	"hall",         // grief
	"shark",        // grief spam
	"bison",        // grief spam
	"necromancer",  // annoying/grief
	"greg",         // annoying/grief
	"ctf_flag",     // sound spam
	"flag_base"     // sound spam + bedrock grief
};

void onInit(CRules@ this)
{
	this.addCommandID("SendChatMessage");
}

bool onServerProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	//--------MAKING CUSTOM COMMANDS-------//
	// Making commands is easy - Here's a template:
	//
	// if (text_in == "!YourCommand")
	// {
	//	// what the command actually does here
	// }
	//
	// Switch out the "!YourCommand" with
	// your command's name (i.e., !cool)
	//
	// Then decide what you want to have
	// the command do
	//
	// Here are a few bits of code you can put in there
	// to make your command do something:
	//
	// blob.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), 10.0f, 0);
	// Deals 10 damage to the player that used that command (20 hearts)
	//
	// CBlob@ b = server_CreateBlob('mat_wood', -1, pos);
	// insert your blob/the thing you want to spawn at 'mat_wood'
	//
	// player.server_setCoins(player.getCoins() + 100);
	// Adds 100 coins to the player's coins
	//-----------------END-----------------//

	if (player is null || text_in.substr(0, 1) != "!")
		return true;

	RulesCore@ core;
	this.get("core", @core);

	string[]@ tokens = text_in.split(" ");
	const bool isMod = player.isMod();
	const string gamemode = this.gamemode_name;
	bool wasCommandSuccessful = true; // assume command is successful 
	string errorMessage = ""; // so errors can be printed out of wasCommandSuccessful is false
	SColor errorColor = SColor(255,255,0,0); // ^
	
	// commands that don't rely on sv_test being on (sv_test = 1)

	if (isMod)
	{
		if (tokens[0] == "!bot")
		{
			if (tokens.length > 1)
			{
				for (int i = 0; i < parseInt(tokens[1]); ++i)
				{
					AddBot("Henry");
				}
			}
			else
			{
				AddBot("Henry");
			}
			return true;
		}
		else if (text_in == "!debug")
		{
			CBlob@[] all;
			getBlobs(@all);

			for (u32 i = 0; i < all.length; i++)
			{
				CBlob@ blob = all[i];
				print("[" + blob.getName() + " " + blob.getNetworkID() + "] ");
			}
		}
		else if (text_in == "!endgame")
		{
			this.SetCurrentState(GAME_OVER); //go to map vote
			return true;
		}
		else if (text_in == "!startgame")
		{
			this.SetCurrentState(GAME);
			return true;
		}
		else if (tokens[0] == "!settickets")
		{
			if (tokens.length > 1)
			{
				s16 numTix = parseInt(tokens[1]);
				this.set_s16("redTickets", numTix);
				this.set_s16("blueTickets", numTix);
				this.Sync("redTickets", true);
				this.Sync("blueTickets", true);
			}
			return true;
		}
		else if (tokens[0] == "!setredtickets")
		{
			if (tokens.length > 1)
			{
				s16 numTix = parseInt(tokens[1]);
				this.set_s16("redTickets", numTix);
				this.Sync("redTickets", true);
			}
			return true;
		}
		else if (tokens[0] == "!setbluetickets")
		{
			if (tokens.length > 1)
			{
				s16 numTix = parseInt(tokens[1]);
				this.set_s16("blueTickets", numTix);
				this.Sync("blueTickets", true);
			}
			return true;
		}
		else if (tokens[0] == "!settug")
		{
			if (tokens.length > 1)
			{
				s16 TugCap = parseInt(tokens[1]);
				this.set_s16("TugOfTickets", TugCap);
				this.Sync("TugOfTickets", true);
			}
			return true;
		}
		else if (text_in == "!allspec")
		{
			CBlob@[] all = GetPlayers(this, "all");
			for (u32 i=0; i < all.length; i++)
			{		
				CBlob@ blob1 = all[i];
				if(blob1.getPlayer() != null)
				{
					core.ChangePlayerTeam(blob1.getPlayer(), this.getSpectatorTeamNum());
				}
			}
			return true;
		}
		else if (text_in == "!lockclasses")
		{
			lockclasses(this);
			return true;
		}
		else if (tokens[0] == "!sethealth")
		{
			float health = parseFloat(tokens[tokens.length - 1]);
			if(tokens.length > 2)
			{
				string[] Usernames = tokens;
				Usernames.removeAt(0);
				CPlayer@[] myPlayerList = GetPlayersList(this, Usernames);
				for (u32 i=0; i < myPlayerList.size(); i++)
				{		
					CPlayer@ myplayer = myPlayerList[i];
					if(myplayer !is null)
					{
						if(myplayer.getBlob() !is null){
							myplayer.getBlob().server_SetHealth(health);
						}
					}
				}
			}
			return true;
		}
		else if (tokens[0] == "!juggernaut")
		{
			CBlob@[] tents;
			float health = parseFloat(tokens[tokens.size() - 1]);
			Vec2f teampos;
			getBlobsByName( "tent" ,  @tents );
			for (int a = 0; a < tents.size(); a++)
			{
				CBlob@ blob2 = tents[a];
				if (blob2.getTeamNum() == 1)
				{
					teampos = blob2.getPosition();
				}
			}
			if (tokens.size() >= 2)
			{
				string[] Usernames = tokens;
				Usernames.removeAt(0);
				CPlayer@[] myPlayerList = GetPlayersList(this, Usernames);
				for(int i=0; i < getPlayersCount(); i++)
				{
					CPlayer@ myplayer = getPlayer(i);
					bool onList = false;
					for(int j = 0; j < myPlayerList.size(); j++)
					{
						if(myplayer is myPlayerList[j])
						{
							onList = true;
							break;
						}
					}

					if(onList)
					{
						if(myplayer != null)
						{
							if (myplayer.getTeamNum() == 1)
							{
								CBlob@ ClassBlob = server_CreateBlob("knight", 1, teampos);
								ClassBlob.server_SetHealth(health);
							
								if (ClassBlob.getPosition() != Vec2f(0, 0) && myplayer.getBlob() !is null)
								{
									if (myplayer.getTeamNum() == 1)
									{
										myplayer.getBlob().server_Die();
										ClassBlob.server_SetPlayer(myplayer);
									}
								}
							}
							else
							{
								core.ChangePlayerTeam(myplayer, 1);
							}
						}	
					}
					else
					{
						core.ChangePlayerTeam(myplayer, 0);
					}
				}
			}
			this.set_s16("redTickets", 0);
			this.set_s16("blueTickets", 30);
			this.Sync("redTickets", true);
			this.Sync("blueTickets", true);
			return true;
		}
		else if (tokens[0] == "!class")
		{
			string classes = tokens[(tokens.length -1)];
			if(tokens.length > 2)
			{

				if (tokens[1] == "all" || tokens[1] == "blue" || tokens[1] == "red")
				{
					CBlob@[] Players = GetPlayers(this, tokens[1]);
					for (u32 i=0; i < Players.size(); i++)
					{		
						CBlob@ blob1 = Players[i];
						CPlayer@ myplayer = Players[i].getPlayer();
						if(myplayer !is null)
						{	
							CBlob@ ClassBlob = server_CreateBlob(classes, blob1.getTeamNum(), blob1.getPosition());
							if (ClassBlob !is null) {
								if(blob1 !is null) {
									blob1.server_Die();
									ClassBlob.server_SetPlayer(blob1.getPlayer());
								}
							}
						}
					}
				}
				else 
				{
				string[] Usernames = tokens;
				Usernames.removeAt(0);
				CPlayer@[] myPlayerList = GetPlayersList(this, Usernames);
				for (u32 i=0; i < (myPlayerList.size()); i++)
					{		
						CPlayer@ myplayer = myPlayerList[i];
						if(myplayer !is null)
						{
							if (myplayer.getBlob() !is null)
							{
								CBlob@ ClassBlob = server_CreateBlob(classes, myplayer.getBlob().getTeamNum(), myplayer.getBlob().getPosition());
								if (ClassBlob.getPosition() != Vec2f(0, 0))
								{			
									myplayer.getBlob().server_Die();
									ClassBlob.server_SetPlayer(myplayer);	
								}
							}
						}
					}
				}
			}
			return true;
		}
		else if (tokens[0] == "!gametime" || tokens[0] == "!game")
		{
			if (tokens.length > 1)
			{
				//sets the game time for next map (IN MINUTES)
				int timer = parseInt(tokens[1]);
				this.set_s32("custom_game_time", timer);
				if (timer <= 0)
				{
					getNet().server_SendMsg("Future matches will have no timer");
				}
				else
				{
					getNet().server_SendMsg("Future matches will be " + timer + " minutes long");
				}
			}
			else
			{
				getNet().server_SendMsg("Do !gametime <mins>, use !timer for this match");
			}
			return true;
		}
		else if (tokens[0] == "!warmuptime" || tokens[0] == "!warmup")
		{
			if (tokens.length > 1)
			{
				//sets the warmup time for next map (in seconds)
				int timer = parseInt(tokens[1]);
				if (timer >= 0)
				{
					this.set_s32("custom_warmup_time", timer);
					getNet().server_SendMsg("Future warmups will be " + timer + " seconds long");
				}
			}
			else
			{
				getNet().server_SendMsg("Do !warmuptime <secs>");
			}
			return true;
		}
		else if (tokens[0] == "!timer")
		{
			if (tokens.length > 1)
			{
				int timer = parseInt(tokens[1]);
				if (timer > 0)
				{
					this.set_u32("game_end_time", getGameTime() + timer * 60 * 30);
					this.set_bool("no timer", false);
					this.Sync("no timer", true);
					getNet().server_SendMsg("Timer set to " + timer + " mins for this round");
				}
				else
				{
					this.set_bool("no timer", true);
					this.Sync("no timer", true);
					getNet().server_SendMsg("Timer disabled for this round");
				}
			}
			else
			{
				getNet().server_SendMsg("Do !timer <mins> for this match, !gametime for next");
			}
			return true;
		}
		else if (text_in == "!expand")
		{
			CBlob@[] flags;
			if (getBlobsByName("flag_base", @flags))
			{
				for (int i = 0; i < flags.length; ++i)
				{
					ExpandFlagZone(flags[i]);
				}
			}
			return true;
		}
		else if (tokens[0] == "!shrink")
		{
			u8 shrink_times = 1;
			if (tokens.length > 1)
			{
				shrink_times = parseInt(tokens[1]);
			}
			CBlob@[] flags;
			if (getBlobsByName("flag_base", @flags))
			{
				for (int i = 0; i < flags.length; ++i)
				{
					ShrinkFlagZone(flags[i], shrink_times);
				}
			}
			return true;
		}
		else if (tokens[0] == "!suddendeath")
		{
			string response = "Sudden death";
			bool suddendeath_change = false;
			if (tokens.length > 1)
			{
				response += " - flagzones expand every " + tokens[1] + " seconds";
				this.set_u16("flagzone_cooldown", parseInt(tokens[1]));
				suddendeath_change = true;
			}
			if (tokens.length > 2)
			{
				response += " (" + tokens[2] + " times)";
				this.set_u8("flagzone_max_expands", parseInt(tokens[2]));
				suddendeath_change = true;
			}

			if (suddendeath_change)
			{
				// Re-trigger flagzones if they were already on so they immediately update
				if (isSuddenDeath(this))
					server_StartSuddenDeathFlags();
			}
			else
			{
				response += (this.hasTag("sudden_death_flags")) ? " deactivated" : " activated";
				server_ToggleSuddenDeathFlags();
			}

			getNet().server_SendMsg(response);
			return true;
		}
		else if (tokens[0] == "!overtime")
		{
			if (this.hasTag("overtime_possible"))
			{
				this.Tag("overtime_disabled");
				this.Untag("overtime_possible");
				this.Untag("overtime_active");
				this.Sync("overtime_possible", true);
				this.Sync("overtime_active", true);
				getNet().server_SendMsg("Overtime disabled");
			}
			else
			{
				this.Untag("overtime_disabled");
				this.Tag("overtime_possible");
				this.Sync("overtime_possible", true);
				getNet().server_SendMsg("Overtime enabled");
			}
			return true;
		}
		else if (tokens[0] == "!startoffi" || tokens[0] == "!stopoffi")
		{
			setOffi(this);
			return true;
		}
		else if (tokens[0] == "!nidhogg")
		{
			string classes = tokens[(tokens.size() -1)];
			if(tokens.size() > 2)
			{
				if(!this.get_bool("healing"))
				{
					healing(this);
				}

				if(!this.get_bool("lockclasses"))
				{
					lockclasses(this);
				}
				this.set_s16("redTickets", 0);
				this.set_s16("blueTickets", 0);
				this.Sync("redTickets", true);
				this.Sync("blueTickets", true);
				this.SetCurrentState(GAME);

				if (tokens[1] == "all" || tokens[1] == "blue" || tokens[1] == "red")
				{
					CBlob@[] Players = GetPlayers(this, tokens[1]);
					for (u32 i=0; i < Players.size(); i++)
					{
						CBlob@ blob1 = Players[i];
						if(blob1.getPlayer() !is null)
						{
							CBlob@ ClassBlob = server_CreateBlob((tokens[(tokens.size() - 1)] == "same" ? blob1.getName() : classes), blob1.getTeamNum(), blob1.getPosition());
							ClassBlob.server_SetHealth(0.25);
							if (ClassBlob !is null)
							{
								blob1.server_Die();
								ClassBlob.server_SetPlayer(blob1.getPlayer());
							}
						}
					}
				}
				else
				{
					string[] Usernames = tokens;
					Usernames.removeAt(0);
					CPlayer@[] myPlayerList = GetPlayersList(this, Usernames);
					for (u32 i=0; i < (myPlayerList.size()); i++)
					{
						CPlayer@ myplayer = myPlayerList[i];
						CBlob@ blob1 = myplayer.getBlob();
						if(myplayer !is null)
						{
							CBlob@ ClassBlob = server_CreateBlob((tokens[(tokens.size() - 1)] == "same" ? blob1.getName() : classes), blob1.getTeamNum(), blob1.getPosition());
							ClassBlob.server_SetHealth(0.25);
							if (ClassBlob.getPosition() != Vec2f(0, 0))
							{
								myplayer.getBlob().server_Die();
								ClassBlob.server_SetPlayer(myplayer);
							}
						}
					}
				}
			}
			return true;
		}
		else if (tokens[0] == "!healing")
		{
			healing(this);
			return true;
		}
		else if (tokens[0] == "!testing")
		{
			CBitStream params;
			this.SendCommand(this.getCommandID("show pick menu"), params, player);
			return true;
		}
		else if (tokens[0] == "!lockteams")
		{
			lockteams(this);
			return true;
		}
		else if (tokens[0] == "!randomize")
		{
			if (tokens.size() >= 1)
			{
				int[] orders = playerNumlist( this );
				int team;

				for(int j=(getPlayersCount() - 1); j >= 0; j--)
				{
					orders.removeAt(j);
					orders.insert(XORRandom(getPlayersCount()), j);
				}

				for(int q=0; q < getPlayersCount(); q++)
				{
					team = (q < int(getPlayersCount() / 2) ? 0 : 1);
					CPlayer@ myplayer = getPlayer(orders[q]);
					if(myplayer !is null)
					{
						core.ChangePlayerTeam(myplayer, team);
					}
				}
			}
			return true;
		}
		else if (tokens[0] == "!balance")
		{
			if (tokens.size() > 1)
			{
				string[] playerNames;
				string[] sortedBy = tokens;
				sortedBy.removeAt(0);
				for(int i=0; i < getPlayersCount(); i++)
				{
					CPlayer@ myplayer = getPlayer(i);
					if(myplayer !is null){
						playerNames.push_back(myplayer.getUsername());
					}
				}
				print("[USCaptains] Balance: " + Flatten(playerNames) + "+" + Flatten(sortedBy));
			}
			return true;
		}
		else if (tokens[0] == "!red"|| tokens[0] == "!blue"|| tokens[0] == "!spec")
		{
			if(tokens.size() > 1)
			{
				if (tokens[0] == "!blue" || tokens[0] == "!red")
				{
					CPlayer@[] myPlayerList = GetPlayersList(this, tokens);
					for(int i=0; i < (myPlayerList.size()); i++)
					{
						CPlayer@ myplayer = myPlayerList[i];
						if (myplayer !is null){
							core.ChangePlayerTeam(myplayer, (tokens[0] == "!blue" ? 0 : 1));
						}
					}
				}
				else
				{
					CPlayer@[] myPlayerList = GetPlayersList(this, tokens);
					for(int i=0; i < (myPlayerList.size()); i++)
					{
						CPlayer@ myplayer = myPlayerList[i];
						if (myplayer !is null){
							core.ChangePlayerTeam(myplayer, this.getSpectatorTeamNum());
						}
					}
				}
			}
			return true;
		}
	}

	// spawning things / player blob commands

	// these all require sv_test - no spawning without it
	// some also require the player to have mod status (!spawnwater)

	if (sv_test)
	{
		CBlob@ blob = player.getBlob(); // now, when the code references "blob," it means the player who called the command

		if (blob is null) // cannot do commands while dead
		{
			return true;
		}

		const Vec2f pos = blob.getPosition(); // grab player position (x, y)
		const int team = blob.getTeamNum(); // grab player team number (for i.e. making all flags you spawn be your team's flags)

		if (!isMod && this.hasScript("Sandbox_Rules.as") || chatCommandCooldown) // chat command cooldown timer
		{
			uint lastChatTime = 0;
			if (blob.exists("chat_last_sent"))
			{
				lastChatTime = blob.get_u16("chat_last_sent");
				if (getGameTime() < lastChatTime)
				{
					return true;
				}
			}
		}

		if (text_in == "!tree") // pine tree (seed)
		{
			server_MakeSeed(pos, "tree_pine", 600, 1, 16);
		}
		else if (text_in == "!btree") // bushy tree (seed)
		{
			server_MakeSeed(pos, "tree_bushy", 400, 2, 16);
		}
		else if (text_in == "!allarrows") // 30 normal arrows, 2 water arrows, 2 fire arrows, 1 bomb arrow (full inventory for archer)
		{
			server_CreateBlob('mat_arrows', -1, pos);
			server_CreateBlob('mat_waterarrows', -1, pos);
			server_CreateBlob('mat_firearrows', -1, pos);
			server_CreateBlob('mat_bombarrows', -1, pos);
		}
		else if (text_in == "!arrows") // 3 mats of 30 arrows (90 arrows)
		{
			for (int i = 0; i < 3; i++)
			{
				server_CreateBlob('mat_arrows', -1, pos);
			}
		}
		else if (text_in == "!allbombs") // 2 normal bombs, 1 water bomb
		{
			for (int i = 0; i < 2; i++)
			{
				server_CreateBlob('mat_bombs', -1, pos);
			}
			server_CreateBlob('mat_waterbombs', -1, pos);
		}
		else if (text_in == "!bombs") // 3 (unlit) bomb mats
		{
			for (int i = 0; i < 3; i++)
			{
				server_CreateBlob('mat_bombs', -1, pos);
			}
		}
		else if (text_in == "!spawnwater" && player.isMod())
		{
			getMap().server_setFloodWaterWorldspace(pos, true);
		}
		/*else if (text_in == "!drink") // removes 1 water tile roughly at the player's x, y, coordinates (I notice that it favors the bottom left of the player's sprite)
		{
			getMap().server_setFloodWaterWorldspace(pos, false);
		}*/
		else if (text_in == "!seed")
		{
			// crash prevention?
		}
		else if (text_in == "!crate")
		{
			client_AddToChat("usage: !crate BLOBNAME [DESCRIPTION]", SColor(255, 255, 0, 0)); //e.g., !crate shark Your Little Darling
			server_MakeCrate("", "", 0, team, Vec2f(pos.x, pos.y - 30.0f));
		}
		else if (text_in == "!coins") // adds 100 coins to the player's coins
		{
			player.server_setCoins(player.getCoins() + 100);
		}
		else if (text_in == "!coinoverload") // + 10000 coins
		{
			player.server_setCoins(player.getCoins() + 10000);
		}
		else if (text_in == "!fishyschool") // spawns 12 fishies
		{
			for (int i = 0; i < 12; i++)
			{
				server_CreateBlob('fishy', -1, pos);
			}
		}
		else if (text_in == "!chickenflock") // spawns 12 chickens
		{
			for (int i = 0; i < 12; i++)
			{
				server_CreateBlob('chicken', -1, pos);
			}
		}
		else if (text_in == "!allmats") // 500 wood, 500 stone, 100 gold
		{
			//wood
			CBlob@ wood = server_CreateBlob('mat_wood', -1, pos);
			wood.server_SetQuantity(500); // so I don't have to repeat the server_CreateBlob line again
			//stone
			CBlob@ stone = server_CreateBlob('mat_stone', -1, pos);
			stone.server_SetQuantity(500);
			//gold
			CBlob@ gold = server_CreateBlob('mat_gold', -1, pos);
			gold.server_SetQuantity(100);
		}
		else if (text_in == "!woodstone") // 250 wood, 500 stone
		{
			server_CreateBlob('mat_wood', -1, pos);

			for (int i = 0; i < 2; i++)
			{
				server_CreateBlob('mat_stone', -1, pos);
			}
		}
		else if (text_in == "!stonewood") // 500 wood, 250 stone
		{
			server_CreateBlob('mat_stone', -1, pos);

			for (int i = 0; i < 2; i++)
			{
				server_CreateBlob('mat_wood', -1, pos);
			}
		}
		else if (text_in == "!wood") // 250 wood
		{
			server_CreateBlob('mat_wood', -1, pos);
		}
		else if (text_in == "!stones" || text_in == "!stone") // 250 stone
		{
			server_CreateBlob('mat_stone', -1, pos);
		}
		else if (text_in == "!gold") // 200 gold
		{
			for (int i = 0; i < 4; i++)
			{
				server_CreateBlob('mat_gold', -1, pos);
			}
		}
		// removed/commented out since this can easily be abused...
		/*else if (text_in == "!sharkpit") // spawns 5 sharks, perfect for making shark pits
		{
			for (int i = 0; i < 5; i++)
			{
				CBlob@ b = server_CreateBlob('shark', -1, pos);
			}
		}
		else if (text_in == "!bisonherd") // spawns 5 bisons
		{
			for (int i = 0; i < 5; i++)
			{
				CBlob@ b = server_CreateBlob('bison', -1, pos);
			}
		}*/
		else
		{
			if (tokens.length > 1)
			{
				//(see above for crate parsing example)
				if (tokens[0] == "!crate")
				{
					string item = tokens[1];

					if (!isMod && isBlacklisted(item))
					{
						wasCommandSuccessful = false;
						errorMessage = "blob is currently blacklisted";
					}
					else
					{
						int frame = item == "catapult" ? 1 : 0;
						string description = tokens.length > 2 ? tokens[2] : item;
						server_MakeCrate(item, description, frame, -1, Vec2f(pos.x, pos.y));
					}
				}
				// eg. !team 2
				else if (tokens[0] == "!team")
				{
					// Picks team color from the TeamPalette.png (0 is blue, 1 is red, and so forth - if it runs out of colors, it uses the grey "neutral" color)
					int team = parseInt(tokens[1]);
					blob.server_setTeamNum(team);
					// We should consider if this should change the player team as well, or not.
				}
				else if (tokens[0] == "!scroll")
				{
					string s = tokens[1];
					for (uint i = 2; i < tokens.length; i++)
					{
						s += " " + tokens[i];
					}
					server_MakePredefinedScroll(pos, s);
				}
				else if(tokens[0] == "!coins")
				{
					int money = parseInt(tokens[1]);
					player.server_setCoins(money);
				}
			}
			else
			{
				string name = text_in.substr(1, text_in.size());
				if (!isMod && isBlacklisted(name))
				{
					wasCommandSuccessful = false;
					errorMessage = "blob is currently blacklisted";
				}
				else
				{
					CBlob@ newBlob = server_CreateBlob(name, team, Vec2f(0, -5) + pos); // currently any blob made will come back with a valid pointer

					if (newBlob !is null)
					{
						if (newBlob.getName() != name)  // invalid blobs will have 'broken' names
						{
							wasCommandSuccessful = false;
							errorMessage = "blob " + text_in + " not found";
						}
					}
				}
			}
		}

		if (wasCommandSuccessful)
		{
			blob.set_u16("chat_last_sent", getGameTime() + chatCommandDelay);
		}
	}

	if (errorMessage != "") // send error message to client
	{
		CBitStream params;
		params.write_string(errorMessage);

		// List is reverse so we can read it correctly into SColor when reading
		params.write_u8(errorColor.getBlue());
		params.write_u8(errorColor.getGreen());
		params.write_u8(errorColor.getRed());
		params.write_u8(errorColor.getAlpha());

		this.SendCommand(this.getCommandID("SendChatMessage"), params, player);
	}

	return true;
}

bool onClientProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	if (text_in == "!debug" && !getNet().isServer())
	{
		// print all blobs
		CBlob@[] all;
		getBlobs(@all);

		for (u32 i = 0; i < all.length; i++)
		{
			CBlob@ blob = all[i];
			print("[" + blob.getName() + " " + blob.getNetworkID() + "] ");

			if (blob.getShape() !is null)
			{
				CBlob@[] overlapping;
				if (blob.getOverlapping(@overlapping))
				{
					for (uint i = 0; i < overlapping.length; i++)
					{
						CBlob@ overlap = overlapping[i];
						print("       " + overlap.getName() + " " + overlap.isLadder());
					}
				}
			}
		}
	}

	return true;
}

void onCommand(CRules@ this, u8 cmd, CBitStream @para)
{
	if (cmd == this.getCommandID("SendChatMessage"))
	{
		string errorMessage = para.read_string();
		SColor col = SColor(para.read_u8(), para.read_u8(), para.read_u8(), para.read_u8());
		client_AddToChat(errorMessage, col);
	}
}

bool isBlacklisted(string name)
{
	return blacklistedItems.find(name) != -1;
}

void healing(CRules@ this)
{
	if (this.get_bool("healing"))
	{
		this.set_bool("healing", false);
		this.Sync("healing", true);
		getNet().server_SendMsg( "healing is enabled!" );
	}
	else
	{
		this.set_bool("healing", true);
		this.Sync("healing", true);
		getNet().server_SendMsg( "healing is disabled!" );
	}
}

void lockclasses(CRules@ this)
{
	if (this.get_bool("lockclasses"))
	{
		this.set_bool("lockclasses", false);
		this.Sync("lockclasses", true);
		getNet().server_SendMsg( "Swapping classes is enabled!" );
	}
	else
	{
		this.set_bool("lockclasses", true);
		this.Sync("lockclasses", true);
		getNet().server_SendMsg( "Swapping classes is disabled!" );
	}
}

CBlob@[] GetPlayers(CRules@ this, string PlayersWanted)
{
	CBlob@[] all;
	CBlob@[] Team;
	getBlobs(@all);
	if (PlayersWanted == "all"){
		return all;
	}
	else if (PlayersWanted == "red" || PlayersWanted == "blue"){
		for (u32 i=0; i < all.size(); i++)
		{	
		int TeamNum = (PlayersWanted == "blue" ? 0 : 1);
			CBlob@ blob1 = all[i];
			CPlayer@ myplayer = blob1.getPlayer();
			if(blob1.getPlayer() != null)
			{	
				if(myplayer.getTeamNum() == TeamNum)
				{
					Team.push_back(blob1);
				}
			}
		}
	}
	return Team;
}

CPlayer@[] GetPlayersList(CRules@ this, string[] PlayerNames)
{
	CPlayer@[] Players;
	PlayerNames.removeAt(0);
	for(int i=0; i < (PlayerNames.size()); i++)
	{
		CPlayer@ myplayer = GetPlayerByIdent(PlayerNames[i]);
		if(myplayer !is null){
			Players.push_back(myplayer);
		}
	}
	return Players;
}
