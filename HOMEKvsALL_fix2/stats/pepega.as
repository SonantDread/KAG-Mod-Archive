#include "ScoreboardCommon.as"; // for match time
#include "StatsCommon.as";
#include "Hitters.as";

// Usernames tracked for current match
string[] current_usernames;

string[] current_usernames_blue;
string[] current_usernames_red;

// Stats of ALL players to have ever played for blue in homek vs all
Stats[] all_stats_blue;

Stats[] all_stats_red;

// all_stats moved to clientside
Stats[] client_stats_blue;
Stats[] client_stats_red;

Vec2f temp;
Vec2f temp2;

u32 selected_int;

bool different_colour = false;

u32[] coords = {200, 250, 300, 380, 450, 520, 590, 660, 730, 800, 870, 940, 1010, 1080, 1150, 1220, 1290};
string[] sortmodes = {"matches_won", "matches_lost", "winrate", "kills", "deaths", "kdr", "k_kills", "k_deaths", "k_kdr", "b_kills", "b_deaths", "b_kdr", "a_kills", "a_deaths", "a_kdr", "coins"};
string[] namesofstuff = {"Won", "Lost", "Winrate", "Kills", "Deaths", "KDR", "KK", "KD", "KKDR", "BK", "BD", "BKDR", "AK", "AD", "AKDR", "Coins"};

string[] hitterstuff = {"fall", "water", "fire", "builder", "spikes", "sword", "shield", "bombarrow", "bomb", "keg", "mine", "arrow", "ballista", "boulder", "stones", "drill", "saw"};

f32 lineheight = 16;
f32 padheight = 6;
f32 stepheight = lineheight + padheight;

// Set rule property for each stat to 0. Requires passing player's username.
void statsPlayerSetup(string stats_username)
{
	if(!isServer()) return;

	CRules@ rules = getRules();
	CPlayer@ p = getPlayerByUsername(stats_username);

	string current_team;

	if(p !is null)
	{
		if (p.getTeamNum() == 0) current_team = "blue";
		else if (p.getTeamNum() == 1) current_team = "red";

		if(!rules.exists(stats_username + "_" + current_team + "_" + "total"))
			rules.set_u32(stats_username + "_" + current_team + "_" + "total", 0);
	}
	else
	{
		printf("Our p is null, stats_username: " + stats_username);

		if(!rules.exists(stats_username + "_blue_total"))
			rules.set_u32(stats_username + "_blue_total", 0);

		if(!rules.exists(stats_username + "_red_total"))
			rules.set_u32(stats_username + "_red_total", 0);

	}

	string[] propArray = { "_kills~blue", "_deaths~blue", "k_kills~blue", "k_deaths~blue", "b_kills~blue", "b_deaths~blue", "a_kills~blue", "a_deaths~blue", "_kills~red", "_deaths~red", "k_kills~red", "k_deaths~red", "b_kills~red", "b_deaths~red", "a_kills~red", "a_deaths~red", "coins~blue", "coins~red"};

	for(int i = 0; i < propArray.length(); ++i)
	{
		rules.set_u32(stats_username + propArray[i], 0);
	}

	for(int i = 0; i < hitterstuff.length(); ++i)
	{
		rules.set_u32(stats_username + "_kill_" + hitterstuff[i] + "~blue", 0);
		rules.set_u32(stats_username + "_kill_" + hitterstuff[i] + "~red", 0);
		rules.set_u32(stats_username + "_death_" + hitterstuff[i] + "~blue", 0);
		rules.set_u32(stats_username + "_death_" + hitterstuff[i] + "~red", 0);
	}

	// Add player to array of players tracked in current match
	if (current_usernames.find(stats_username) == -1)
	{
		current_usernames.push_back(stats_username);
	}	
}

// No idea what is happening here!
void StatsSync(CRules@ this)
{
	all_stats_blue.clear();
	client_stats_blue.clear();

	all_stats_red.clear();
	client_stats_red.clear();

	ConfigFile file;

	string[] all_usernames = {};

	all_usernames.clear();

	CBitStream cockparams;

	this.SendCommand(this.getCommandID("clear stats"), cockparams);

	if(isServer())
	{
	   	if(file.loadFile("../Cache/" + STATS_DIR + "S_all_players")) 
	    { 
	    	if(file.exists("All players"))
	    		file.readIntoArray_string(all_usernames, "All players");
	    }

		for(int h = 0; h < all_usernames.length(); ++h)
		{
			Stats@ currentstat = Stats(all_usernames[h], 0);
			all_stats_blue.push_back(currentstat);

			Stats@ currentstat2 = Stats(all_usernames[h], 1);
			all_stats_red.push_back(currentstat2);
		}
	}

	if(isClient())
	{
		client_stats_blue.clear();
		client_stats_red.clear();
	}

	if(isServer())
	{
		for(int x = 0; x < all_stats_blue.length(); ++x)
		{
			Stats@ current = all_stats_blue[x];

			CBitStream bparams;

			current.serialize(bparams);

			this.SendCommand(this.getCommandID("send stats blue"), bparams);
		}

		for(int x = 0; x < all_stats_red.length(); ++x)
		{
			Stats@ current = all_stats_red[x];

			CBitStream bparams;

			current.serialize(bparams);

			this.SendCommand(this.getCommandID("send stats red"), bparams);
		}
	}
}

void upClassStat(CRules@ this, CBlob@ victim, string player_username, string stat, string team)
{
	if(victim is null) 
	{ 
		printf("Victim null in upClassStat");
		return;
	}

	string victim_name = victim.getName();

	string class_prefix;

	if(victim_name == "knight")
	{
		class_prefix = "k_";
	}

	if(victim_name == "builder")
	{
		class_prefix = "b_";
	}

	if(victim_name == "archer")
	{
		class_prefix = "a_";
	}

	this.add_u32(player_username + class_prefix + stat + "~" + team, 1);
}

CPlayer@ hoveredPlayer;
Vec2f hoveredPos;

float scoreboardMargin = 52.0f;
float scrollOffset = 0.0f;
float scrollSpeed = 4.0f;
float maxMenuWidth = 700;
float screenMidX = getScreenWidth()/2;

bool showlb = false;

void onInit(CRules@ this)
{
	this.addCommandID("send stats blue");
	this.addCommandID("send stats red");
	this.addCommandID("clear stats");

	string[] all_usernames;

	ConfigFile file;

	if(isServer())
	{
	   	if(file.loadFile("../Cache/" + STATS_DIR + "S_all_players")) 
	    { 
	    	file.readIntoArray_string(all_usernames, "All players");
	    }

		if(all_stats_blue.length() == 0)
		{
			for(int h = 0; h < all_usernames.length(); ++h)
			{
				Stats@ currentstat = Stats(all_usernames[h], 0);
				all_stats_blue.push_back(currentstat);
			}
		}

		if(all_stats_red.length() == 0)
		{
			for(int h = 0; h < all_usernames.length(); ++h)
			{
				Stats@ currentstat2 = Stats(all_usernames[h], 1);
				all_stats_red.push_back(currentstat2);
			}
		}
	}
}

void onTick(CRules@ this)
{
	CControls@ controls = getControls();

	if (controls.isKeyJustPressed(KEY_KEY_J) && controls.isKeyPressed(KEY_LSHIFT))
	{
		if(this.get_u32("tabmode") == 2) 
			this.set_u32("tabmode", 0);
		else this.set_u32("tabmode", 2);
	}
	if (controls.isKeyJustPressed(KEY_KEY_L) && controls.isKeyPressed(KEY_LSHIFT))
	{
		if(this.get_u32("tabmode") == 3) 
			this.set_u32("tabmode", 0);
		else this.set_u32("tabmode", 3);
	}


	if(isClient())
	{
		if (getLocalPlayer() is null)
			return;

		if(!this.hasTag("stats on") && getLocalPlayer().getUsername() == "HomekGod" && getGameTime() % 30 == 0 && getGameTime() < 300)
		{
			client_AddToChat("bunni epic noob stats arent on", SColor(255, 180, 24, 94));
		}

		CControls@ controls = getControls();

		if (controls is null) return;

		if (this.get_u32("tabmode") == 2)
		{
			goDown(getLocalPlayer(), 0);
		}

		if (this.get_u32("tabmode") == 3)
		{
			goDown(getLocalPlayer(), 1);
		}

		if (controls.isKeyPressed(KEY_LBUTTON) && (controls.isKeyJustPressed(KEY_LBUTTON)) && (this.get_u32("tabmode") == 2 || this.get_u32("tabmode") == 3))
		{
			Vec2f cursor = controls.getMouseScreenPos();

			bool truetrue = (cursor.y > temp.y - 32 && cursor.y < temp.y + 32);

			/*u32[] coords = {200, 250, 300, 380, 450, 520, 590, 660, 730, 800, 870, 940, 1010, 1080, 1150, 1220, 1290};
			string[] sortmodes = {"matches_won", "matches_lost", "winrate", "kills", "deaths", "kdr", "k_kills", "k_deaths", "k_kdr", "b_kills", "b_deaths", "b_kdr", "a_kills", "a_deaths", "a_kdr"};
			string[] namesofstuff = {"Won", "Lost", "Winrate", "Kills", "Deaths", "KDR", "KK", "KD", "KKDR", "BK", "BD" "BKDR", "AK", "AD", "AKDR"};
*/
			for(int i = 0; i < sortmodes.length(); ++i)
			{
				if(cursor.x > temp.x + coords[i] && cursor.x < temp.x + coords[i + 1] && truetrue)
				{
					if(this.get_string(getLocalPlayer().getUsername() + "sortmode") == sortmodes[i])
					{
						if(different_colour)
						{
							client_stats_blue.sortDesc();
							client_stats_red.sortDesc();
						}
						else
						{
							client_stats_blue.sortAsc();
							client_stats_red.sortAsc();
						}

						Sound::Play("buttonclick.ogg");
						different_colour = !different_colour;
					}
					else
					{
						this.set_string(getLocalPlayer().getUsername() + "sortmode", sortmodes[i]);
						client_stats_blue.sortDesc();
						client_stats_red.sortDesc();
						Sound::Play("buttonclick.ogg");
						different_colour = false;
					}

					selected_int = i;
				}
			}
		}
	}
}

void onRender(CRules@ this)
{
    if(getLocalPlayer() is null) return;

	if(this.get_u32("tabmode") == 2 && getLocalPlayer().isMyPlayer())
	{
		Vec2f topleft(Maths::Max( 100, screenMidX-maxMenuWidth), 150);
		drawScoreboardc(topleft, 0);
	}
	if(this.get_u32("tabmode") == 3 && getLocalPlayer().isMyPlayer())
	{
		Vec2f topleft(Maths::Max( 100, screenMidX-maxMenuWidth), 150);
		drawScoreboardc(topleft, 1);
	}
}

u32 ticks_down = 0;
u32 ticks_up = 0;
u32 go_down = 0;

void goDown(CPlayer@ player, int teamnum)
{
	CControls@ controls = getControls();
	Vec2f mousePos = controls.getMouseScreenPos();
	Vec2f topleft(Maths::Max( 100, screenMidX-maxMenuWidth), 150);
	topleft = topleft - Vec2f(0, go_down);

	u32 actual_count = 0;

	if (teamnum == 0)
	{
		for (u32 i = 0; i < client_stats_blue.length(); i++)
		{
			Stats@ current_stat = client_stats_blue[i];
			string current_player = current_stat.m_username;

			if(current_stat.m_kills == 0 && current_stat.m_deaths == 0 && current_stat.m_matches_won == 0 && current_stat.m_matches_lost == 0)
			continue;

			actual_count++;
		}
	}
	else
	{
		for (u32 i = 0; i < client_stats_red.length(); i++)
		{
			Stats@ current_stat = client_stats_red[i];
			string current_player = current_stat.m_username;

			if(current_stat.m_kills == 0 && current_stat.m_deaths == 0 && current_stat.m_matches_won == 0 && current_stat.m_matches_lost == 0)
			continue;

			actual_count++;
		}
	}

	Vec2f bottomright;
	bottomright = Vec2f(Maths::Min(getScreenWidth() - 100, screenMidX+maxMenuWidth), topleft.y + (actual_count + 5.5) * stepheight);

	if(mousePos.y > getScreenHeight() * 0.9)
	{
		if(bottomright.y > 100)
		{
			ticks_down++;
			ticks_up = 0;

			if(ticks_down > 15)
			{
				go_down += 15;
			}
		}
	}
	else if(mousePos.y < getScreenHeight() * 0.1)
	{
		ticks_up++;
		ticks_down = 0;

		if(ticks_up > 15 && go_down != 0)
		{
			go_down -= 15;
		}
	}
}

float drawScoreboardc(Vec2f topleft, int team)
{
	ConfigFile file;

	CRules@ rules = getRules();

	topleft = topleft - Vec2f(0, go_down);

	Vec2f bottomright;

	u32 actual_count = 0;

	if (team == 0)
	{
		for (u32 i = 0; i < client_stats_blue.length(); i++)
		{
			Stats@ current_stat = client_stats_blue[i];
			string current_player = current_stat.m_username;

			if(current_stat.m_kills == 0 && current_stat.m_deaths == 0 && current_stat.m_matches_won == 0 && current_stat.m_matches_lost == 0)
			continue;

			actual_count++;
		}
	}
	else
	{
		for (u32 i = 0; i < client_stats_red.length(); i++)
		{
			Stats@ current_stat = client_stats_red[i];
			string current_player = current_stat.m_username;

			if(current_stat.m_kills == 0 && current_stat.m_deaths == 0 && current_stat.m_matches_won == 0 && current_stat.m_matches_lost == 0)
			continue;

			actual_count++;
		}
	}

	if(team == 0) bottomright = Vec2f(Maths::Min(getScreenWidth() - 100, screenMidX+maxMenuWidth), topleft.y + (actual_count + 5.5) * stepheight);
	else bottomright = Vec2f(Maths::Min(getScreenWidth() - 100, screenMidX+maxMenuWidth), topleft.y + (actual_count + 5.5) * stepheight);

	SColor color;
	if (team == 0) color = SColor(255, 25, 94, 157);
	else color = SColor(255, 192, 36, 36);
	GUI::DrawPane(topleft, bottomright, color);

	//offset border
	topleft.x += stepheight;
	bottomright.x -= stepheight;
	topleft.y += stepheight;

	GUI::SetFont("menu");

	if(team == 0)
	GUI::DrawText("Global Homek Vs All Scoreboard (Blue) |-----| Total players: " + actual_count + " |-----| Updates after match end |-----| BK = Builder Kills, AD = Archer Deaths, KKDR = Knight KDR etc. |-----|", Vec2f(topleft.x, topleft.y), SColor(0xffffffff));

	else
	GUI::DrawText("Global Homek Vs All Scoreboard (Homek) |-----| Total players: " + actual_count + " |-----| Updates after match end |-----| BK = Builder Kills, AD = Archer Deaths, KKDR = Knight KDR etc. |-----|", Vec2f(topleft.x, topleft.y), SColor(0xffffffff));

	topleft.y += stepheight * 2;

	temp = topleft;

	GUI::DrawText(getTranslatedString("Player"), Vec2f(topleft.x + 40, topleft.y), SColor(0xffffffff));

	string tex = "UpDown.png";

	//GUI::DrawIcon(tex, frame, framesize, topleft, 0.5f, p.getTeamNum());

	//draw player table header
	for(int i = 0; i < namesofstuff.length(); ++i)
	{
		SColor cock_colour;

		if(selected_int == i) 
		{
			cock_colour = 0xffffEE44;
			if(!different_colour)
			{
				GUI::DrawIcon(tex, 0, Vec2f(8, 8), Vec2f(topleft.x + coords[i], topleft.y - 16), 1.0f);
			}
			else 
			{ 
				GUI::DrawIcon(tex, 1, Vec2f(8, 8), Vec2f(topleft.x + coords[i], topleft.y - 16), 1.0f);
			}
		}
		else cock_colour = 0xffffffff;

		GUI::DrawText(namesofstuff[i], Vec2f(topleft.x + coords[i], topleft.y),	cock_colour);
	}

	topleft.y += stepheight * 0.5f;

	CControls@ controls = getControls();
	Vec2f mousePos = controls.getMouseScreenPos();

	int real_count = 0;
	//draw players
	if(team == 0)
	{
		for (u32 i = 0; i < client_stats_blue.length(); i++)
		{
			Stats@ current_stat = client_stats_blue[i];
			string current_player = current_stat.m_username;

			if(current_stat.m_kills == 0 && current_stat.m_deaths == 0 && current_stat.m_matches_won == 0 && current_stat.m_matches_lost == 0)
			continue;

			real_count += 1;

			topleft.y += stepheight;
			bottomright.y = topleft.y + lineheight;

			bool playerHover = mousePos.y > topleft.y && mousePos.y < topleft.y + 15;

			Vec2f lineoffset = Vec2f(0, -2);

			u32 underlinecolor = 0xff404040;
			u32 playercolour = 0xff808080;

			CPlayer@ local = getLocalPlayer();

			if (local !is null)
			{
				if(local.getUsername() == current_player)
				{
					playercolour = 0xffffEE44;
				}
			}
			if (playerHover)
			{
				playercolour = 0xffcccccc;
				hoveredPos = topleft;
				hoveredPos.x = bottomright.x - 150;
			}

			GUI::DrawLine2D(Vec2f(topleft.x, bottomright.y + 1) + lineoffset, Vec2f(bottomright.x, bottomright.y + 1) + lineoffset, SColor(underlinecolor));
			GUI::DrawLine2D(Vec2f(topleft.x, bottomright.y) + lineoffset, bottomright + lineoffset, SColor(playercolour));

			//how much room to leave for names and clantags
			float name_buffer = 56.0f;

			//render the player + stats
			SColor namecolour = SColor(0xffffffff);

			if(local.getUsername() == current_player)
			{
				namecolour = SColor(0xffffEE44);
			}

			GUI::DrawText(real_count + ".", Vec2f(topleft.x, topleft.y), namecolour);

			GUI::DrawText("" + current_player, Vec2f(topleft.x + 40, topleft.y), namecolour);

			GUI::DrawText("" + current_stat.m_matches_won, Vec2f(topleft.x + 200, topleft.y), SColor(0xffffffff));
			GUI::DrawText("" + current_stat.m_matches_lost, Vec2f(topleft.x + 250, topleft.y), SColor(0xffffffff));
			GUI::DrawText("" + formatFloat(current_stat.m_winrate, "", 0, 2), Vec2f(topleft.x + 300, topleft.y), SColor(0xffffffff));

			GUI::DrawText("" + current_stat.m_kills, Vec2f(topleft.x + 380, topleft.y), SColor(0xffffffff));
			GUI::DrawText("" + current_stat.m_deaths, Vec2f(topleft.x + 450, topleft.y), SColor(0xffffffff));
			GUI::DrawText("" + formatFloat(current_stat.m_kdr, "", 0, 2), Vec2f(topleft.x + 520, topleft.y), SColor(0xffffffff));

			GUI::DrawText("" + current_stat.m_k_kills, Vec2f(topleft.x + 590, topleft.y), SColor(0xffffffff));
			GUI::DrawText("" + current_stat.m_k_deaths, Vec2f(topleft.x + 660, topleft.y), SColor(0xffffffff));
			GUI::DrawText("" + formatFloat(current_stat.m_k_kdr, "", 0, 2), Vec2f(topleft.x + 730, topleft.y), SColor(0xffffffff));

			GUI::DrawText("" + current_stat.m_b_kills, Vec2f(topleft.x + 800, topleft.y), SColor(0xffffffff));
			GUI::DrawText("" + current_stat.m_b_deaths, Vec2f(topleft.x + 870, topleft.y), SColor(0xffffffff));
			GUI::DrawText("" + formatFloat(current_stat.m_b_kdr, "", 0, 2), Vec2f(topleft.x + 940, topleft.y), SColor(0xffffffff));

			GUI::DrawText("" + current_stat.m_a_kills, Vec2f(topleft.x + 1010, topleft.y), SColor(0xffffffff));
			GUI::DrawText("" + current_stat.m_a_deaths, Vec2f(topleft.x + 1080, topleft.y), SColor(0xffffffff));
			GUI::DrawText("" + formatFloat(current_stat.m_a_kdr, "", 0, 2), Vec2f(topleft.x + 1150, topleft.y), SColor(0xffffffff));

			GUI::DrawText("" + current_stat.m_coins, Vec2f(topleft.x + 1220, topleft.y), SColor(0xffffffff));

		}
	}
	else
	{
		for (u32 i = 0; i < client_stats_red.length(); i++)
		{
			Stats@ current_stat = client_stats_red[i];
			string current_player = current_stat.m_username;

			if(current_stat.m_kills == 0 && current_stat.m_deaths == 0 && current_stat.m_matches_won == 0 && current_stat.m_matches_lost == 0)
			continue;

			real_count += 1;

			topleft.y += stepheight;
			bottomright.y = topleft.y + lineheight;

			bool playerHover = mousePos.y > topleft.y && mousePos.y < topleft.y + 15;

			Vec2f lineoffset = Vec2f(0, -2);

			u32 underlinecolor = 0xff404040;
			u32 playercolour = 0xff808080;

			CPlayer@ local = getLocalPlayer();

			if (local !is null)
			{
				if(local.getUsername() == current_player)
				{
					playercolour = 0xffffEE44;
				}
			}
			if (playerHover)
			{
				playercolour = 0xffcccccc;
				hoveredPos = topleft;
				hoveredPos.x = bottomright.x - 150;
			}

			GUI::DrawLine2D(Vec2f(topleft.x, bottomright.y + 1) + lineoffset, Vec2f(bottomright.x, bottomright.y + 1) + lineoffset, SColor(underlinecolor));
			GUI::DrawLine2D(Vec2f(topleft.x, bottomright.y) + lineoffset, bottomright + lineoffset, SColor(playercolour));

			//how much room to leave for names and clantags
			float name_buffer = 56.0f;

			//render the player + stats
			SColor namecolour = SColor(0xffffffff);

			if(local.getUsername() == current_player)
			{
				namecolour = SColor(0xffffEE44);
			}

			GUI::DrawText(real_count + ".", Vec2f(topleft.x, topleft.y), namecolour);

			GUI::DrawText("" + current_player, Vec2f(topleft.x + 40, topleft.y), namecolour);

			GUI::DrawText("" + current_stat.m_matches_won, Vec2f(topleft.x + 200, topleft.y), SColor(0xffffffff));
			GUI::DrawText("" + current_stat.m_matches_lost, Vec2f(topleft.x + 250, topleft.y), SColor(0xffffffff));
			GUI::DrawText("" + formatFloat(current_stat.m_winrate, "", 0, 2), Vec2f(topleft.x + 300, topleft.y), SColor(0xffffffff));

			GUI::DrawText("" + current_stat.m_kills, Vec2f(topleft.x + 380, topleft.y), SColor(0xffffffff));
			GUI::DrawText("" + current_stat.m_deaths, Vec2f(topleft.x + 450, topleft.y), SColor(0xffffffff));
			GUI::DrawText("" + formatFloat(current_stat.m_kdr, "", 0, 2), Vec2f(topleft.x + 520, topleft.y), SColor(0xffffffff));

			GUI::DrawText("" + current_stat.m_k_kills, Vec2f(topleft.x + 590, topleft.y), SColor(0xffffffff));
			GUI::DrawText("" + current_stat.m_k_deaths, Vec2f(topleft.x + 660, topleft.y), SColor(0xffffffff));
			GUI::DrawText("" + formatFloat(current_stat.m_k_kdr, "", 0, 2), Vec2f(topleft.x + 730, topleft.y), SColor(0xffffffff));

			GUI::DrawText("" + current_stat.m_b_kills, Vec2f(topleft.x + 800, topleft.y), SColor(0xffffffff));
			GUI::DrawText("" + current_stat.m_b_deaths, Vec2f(topleft.x + 870, topleft.y), SColor(0xffffffff));
			GUI::DrawText("" + formatFloat(current_stat.m_b_kdr, "", 0, 2), Vec2f(topleft.x + 940, topleft.y), SColor(0xffffffff));

			GUI::DrawText("" + current_stat.m_a_kills, Vec2f(topleft.x + 1010, topleft.y), SColor(0xffffffff));
			GUI::DrawText("" + current_stat.m_a_deaths, Vec2f(topleft.x + 1080, topleft.y), SColor(0xffffffff));
			GUI::DrawText("" + formatFloat(current_stat.m_a_kdr, "", 0, 2), Vec2f(topleft.x + 1150, topleft.y), SColor(0xffffffff));

			GUI::DrawText("" + current_stat.m_coins, Vec2f(topleft.x + 1220, topleft.y), SColor(0xffffffff));

		}
	}

	return topleft.y;

}

bool onClientProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	if(isClient())
	{
		if(text_in.findFirst("!sort") != -1)
		{
			string[]@ split = text_in.split(" ");
			if(split.size() > 1)
			{
				this.set_string(player.getUsername() + "sortmode", split[1]);
			}

			client_stats_blue.sortDesc();
			client_stats_red.sortDesc();
		}
	}

	return true;
}

bool onServerProcessChat( CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player )
{

	if (player is null)
		return true;

    if (text_in == "!statson" && player.isMod())
	{
		printf("stats on! ");

		this.Tag("stats on");

		this.set_u32("bluekills", 0);
		this.set_u32("bluedeaths", 0);
		this.set_u32("redkills", 0);
		this.set_u32("reddeaths", 0);

		for(int i = 0; i < hitterstuff.length(); ++i)
		{
			this.set_u32("bluekill_" + hitterstuff[i], 0);
			this.set_u32("redkill_" + hitterstuff[i], 0);
			this.set_u32("bluedeath_" + hitterstuff[i], 0);
			this.set_u32("reddeath_" + hitterstuff[i], 0);
		}

		for (int i=0; i < getPlayerCount(); i++) 
		{
			CPlayer@ p = getPlayer(i);
			if (p is null) continue;
			
			string player_name = p.getUsername();

			statsPlayerSetup(player_name);

			if (p.getTeamNum() != 0 && p.getTeamNum() != 1) continue;

			string current_team;

			if (p.getTeamNum() == 0) current_team = "blue";
			else if (p.getTeamNum() == 1) current_team = "red";

			this.set_u32(player_name + "_" + current_team + "_" + "start", getGameTime());
			printf(player_name + "_" + current_team + "_" + "start");
		}
	}
		
	// too problematic for now
	else if (text_in == "!statsoff" && player.getUsername() == "HomekGod")
	{
		this.Untag("stats on");
	}

	else if (text_in == "!timeplayed" && player.getUsername() == "HomekGod")
	{
		for(int i = 0; i < current_usernames.length(); ++i)
	    {
	    	string player_name = current_usernames[i];
	    	// lets fucking goo
	    	printf("!!! Username: " + player_name + "\nTP total blue: " + this.get_u32(player_name + "_blue_" + "total") + "\nTP end blue: " + this.get_u32(player_name + "_blue_" + "end") + "\nTP start blue: " + this.get_u32(player_name + "_blue_" + "start") + "\nTP total red: " + this.get_u32(player_name + "_red_" + "total") + "\nTP end red: " + this.get_u32(player_name + "_red_" + "end") + "\nTP start red: " + this.get_u32(player_name + "_red_" + "start"));
		}
	}
	
	// debug

	if(text_in == "!givearrayd" && player.isMod())
	{ 
		for(int x = 0; x < current_usernames.length(); ++x)
		{
			printf("x: " + x + ": " + current_usernames[x] + ", kills: " + this.get_u32(current_usernames[x] + "_kills") + ", deaths: " + this.get_u32(current_usernames[x] + "_deaths"));
		}
	}

	if(text_in == "!statsync" && player.isMod())
	{ 
		StatsSync(this);
	}

	return true;
}

void onRestart(CRules@ this)
{
	this.Untag("stats on");

	string[] all_usernames;

	ConfigFile file;

	if(isServer())
	{
	   	if(file.loadFile("../Cache/" + STATS_DIR + "S_all_players")) 
	    { 
	    	file.readIntoArray_string(all_usernames, "All players");
	    }

		if(all_stats_blue.length() == 0)
		{
			for(int h = 0; h < all_usernames.length(); ++h)
			{
				ConfigFile file2;
				if(!file2.loadFile("../Cache/" + STATS_DIR + all_usernames[h] + "~blue")) continue; 

				Stats@ currentstat = Stats(all_usernames[h], 0);
				all_stats_blue.push_back(currentstat);
			}
		}
		if(all_stats_red.length() == 0)
		{
			for(int h = 0; h < all_usernames.length(); ++h)
			{
				ConfigFile file2;
				if(!file2.loadFile("../Cache/" + STATS_DIR + all_usernames[h] + "~red")) continue; 

				Stats@ currentstat = Stats(all_usernames[h], 1);
				all_stats_red.push_back(currentstat);
			}
		}
	}
	if(isServer())
	{
		for(int i = 0; i < current_usernames.length(); ++i)
		{
			ConfigFile file;

			string current_username = current_usernames[i];

			if(file.loadFile("../Cache/" + STATS_DIR + current_username + "~blue")) 
	    	{ 
	    		printf("Updating file: " + current_username + "~blue");
				file.add_u32("kills", file.read_u32("kills") + this.get_u32(current_username + "_kills~blue")); 
				file.add_u32("deaths", file.read_u32("deaths") + this.get_u32(current_username + "_deaths~blue")); 
				file.add_u32("k_kills", file.read_u32("k_kills") + this.get_u32(current_username + "k_kills~blue")); 
				file.add_u32("k_deaths", file.read_u32("k_deaths") + this.get_u32(current_username + "k_deaths~blue")); 
				file.add_u32("b_kills", file.read_u32("b_kills") + this.get_u32(current_username + "b_kills~blue")); 
				file.add_u32("b_deaths", file.read_u32("b_deaths") + this.get_u32(current_username + "b_deaths~blue")); 
				file.add_u32("a_kills", file.read_u32("a_kills") + this.get_u32(current_username + "a_kills~blue")); 
				file.add_u32("a_deaths", file.read_u32("a_deaths") + this.get_u32(current_username + "a_deaths~blue")); 
				file.add_u32("coins", file.read_u32("coins") + this.get_u32(current_username + "coins~blue")); 

				for(int i = 0; i < hitterstuff.length(); ++i)
				{
					file.add_u32("kill_" + hitterstuff[i], file.read_u32("kill_" + hitterstuff[i]) + this.get_u32(current_username + "_kill_" + hitterstuff[i] + "~blue"));
					file.add_u32("death_" + hitterstuff[i], file.read_u32("death_" + hitterstuff[i]) + this.get_u32(current_username + "_death_" + hitterstuff[i] + "~blue"));
				}

				file.saveFile(STATS_DIR + current_username + "~blue");
	  		}

	  		ConfigFile file2;

			if(file2.loadFile("../Cache/" + STATS_DIR + current_username + "~red")) 
	    	{ 
	    		printf("Updating file: " + current_username + "~red");
				file2.add_u32("kills", file2.read_u32("kills") + this.get_u32(current_username + "_kills~red")); 
				file2.add_u32("deaths", file2.read_u32("deaths") + this.get_u32(current_username + "_deaths~red")); 
				file2.add_u32("k_kills", file2.read_u32("k_kills") + this.get_u32(current_username + "k_kills~red")); 
				file2.add_u32("k_deaths", file2.read_u32("k_deaths") + this.get_u32(current_username + "k_deaths~red")); 
				file2.add_u32("b_kills", file2.read_u32("b_kills") + this.get_u32(current_username + "b_kills~red")); 
				file2.add_u32("b_deaths", file2.read_u32("b_deaths") + this.get_u32(current_username + "b_deaths~red")); 
				file2.add_u32("a_kills", file2.read_u32("a_kills") + this.get_u32(current_username + "a_kills~red")); 
				file2.add_u32("a_deaths", file2.read_u32("a_deaths") + this.get_u32(current_username + "a_deaths~red")); 
				file2.add_u32("coins", file2.read_u32("coins") + this.get_u32(current_username + "coins~red")); 

				for(int i = 0; i < hitterstuff.length(); ++i)
				{
					file2.add_u32("kill_" + hitterstuff[i], file2.read_u32("kill_" + hitterstuff[i]) + this.get_u32(current_username + "_kill_" + hitterstuff[i] + "~red"));
					file2.add_u32("death_" + hitterstuff[i], file2.read_u32("death_" + hitterstuff[i]) + this.get_u32(current_username + "_death_" + hitterstuff[i] + "~red"));
				}

				file2.saveFile(STATS_DIR + current_username + "~red");
	  		}
		}

		ConfigFile file;

		u32 match_count;

	    if(file.loadFile("../Cache/" + STATS_DIR + "count")) 
	    { 
	        match_count = file.read_u32("matches");

	        printf("Match count in onRestart is currently: " + match_count);

	        ConfigFile file2;

	        if(file2.loadFile("../Cache/" + STATS_DIR + "match" + match_count))
	        {
		        for(int i = 0; i < current_usernames.length(); ++i)
				{
					string current_username = current_usernames[i];

					file2.add_u32(current_username + "_kills~blue", this.get_u32(current_username + "_kills~blue")); 
					file2.add_u32(current_username + "_deaths~blue", this.get_u32(current_username + "_deaths~blue")); 
					file2.add_u32(current_username + "_k_kills~blue", this.get_u32(current_username + "k_kills~blue")); 
					file2.add_u32(current_username + "_k_deaths~blue", this.get_u32(current_username + "k_deaths~blue")); 
					file2.add_u32(current_username + "_b_kills~blue", this.get_u32(current_username + "b_kills~blue")); 
					file2.add_u32(current_username + "_b_deaths~blue", this.get_u32(current_username + "b_deaths~blue")); 
					file2.add_u32(current_username + "_a_kills~blue", this.get_u32(current_username + "a_kills~blue")); 
					file2.add_u32(current_username + "_a_deaths~blue", this.get_u32(current_username + "a_deaths~blue")); 
					file2.add_u32(current_username + "_coins~blue", this.get_u32(current_username + "coins~blue"));

					file2.add_u32(current_username + "_kills~red", this.get_u32(current_username + "_kills~red")); 
					file2.add_u32(current_username + "_deaths~red", this.get_u32(current_username + "_deaths~red")); 
					file2.add_u32(current_username + "_k_kills~red", this.get_u32(current_username + "k_kills~red")); 
					file2.add_u32(current_username + "_k_deaths~red", this.get_u32(current_username + "k_deaths~red")); 
					file2.add_u32(current_username + "_b_kills~red", this.get_u32(current_username + "b_kills~red")); 
					file2.add_u32(current_username + "_b_deaths~red", this.get_u32(current_username + "b_deaths~red")); 
					file2.add_u32(current_username + "_a_kills~red", this.get_u32(current_username + "a_kills~red")); 
					file2.add_u32(current_username + "_a_deaths~red", this.get_u32(current_username + "a_deaths~red"));  
					file2.add_u32(current_username + "_coins~red", this.get_u32(current_username + "coins~red"));

					for(int i = 0; i < hitterstuff.length(); ++i)
					{
						file2.add_u32(current_username + "_kill_" + hitterstuff[i] + "~blue", this.get_u32(current_username + "_kill_" + hitterstuff[i] + "~blue"));
						file2.add_u32(current_username + "_death_" + hitterstuff[i] + "~blue", this.get_u32(current_username + "_death_" + hitterstuff[i] + "~blue"));
						file2.add_u32(current_username + "_kill_" + hitterstuff[i] + "~red", this.get_u32(current_username + "_kill_" + hitterstuff[i] + "~red"));
						file2.add_u32(current_username + "_death_" + hitterstuff[i] + "~red", this.get_u32(current_username + "_death_" + hitterstuff[i] + "~red"));
					}

					file2.add_u32(current_username + "timeplayed", this.get_u32(current_username  + "_blue_total") + this.get_u32(current_username + "_red_total"));
					file2.add_u32(current_username + "timeplayedblue", this.get_u32(current_username  + "_blue_total"));
					file2.add_u32(current_username + "timeplayedred", this.get_u32(current_username  + "_red_total"));

					file2.saveFile(STATS_DIR + "match" + match_count);
					printf("Created match file: " + match_count);
				}
			}
	    }
	}

	if(isServer())
		StatsSync(this);

	for (int i=0; i < current_usernames.length(); i++) 
	{
		string player_name = current_usernames[i];

		// time for deciding which team player counts as 
		this.set_u32(player_name + "_" + "red" + "_" + "start", 0);
		this.set_u32(player_name + "_" + "red" + "_" + "end", 0);
		this.set_u32(player_name + "_" + "blue" + "_" + "start", 0);
		this.set_u32(player_name + "_" + "blue" + "_" + "end", 0);

		// kills and deaths
		statsPlayerSetup(player_name);

		this.set_u32("bluedeaths", 0);
		this.set_u32("reddeaths", 0);
		this.set_u32("bluekills", 0);
		this.set_u32("redkills", 0);

		for(int i = 0; i < hitterstuff.length(); ++i)
		{
			this.set_u32("bluekill_" + hitterstuff[i], 0);
			this.set_u32("redkill_" + hitterstuff[i], 0);
			this.set_u32("bluedeath_" + hitterstuff[i], 0);
			this.set_u32("reddeath_" + hitterstuff[i], 0);
		}

	}

	for (int i=0; i < all_usernames.length(); i++)
	{
		string player_name = all_usernames[i];
		this.set_u32(player_name + "_" + "red" + "_" + "start", 0);
		this.set_u32(player_name + "_" + "red" + "_" + "end", 0);
		this.set_u32(player_name + "_" + "red" + "_" + "total", 0);
		this.set_u32(player_name + "_" + "blue" + "_" + "start", 0);
		this.set_u32(player_name + "_" + "blue" + "_" + "end", 0);
		this.set_u32(player_name + "_" + "blue" + "_" + "total", 0);
	}

	current_usernames.clear(); 
	current_usernames_blue.clear();
	current_usernames_red.clear();
}

void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
	if(isClient())
	{
		if (cmd == this.getCommandID("send stats blue"))
		{
			Stats@ current = Stats(params);
			client_stats_blue.push_back(current);
		}

		if (cmd == this.getCommandID("send stats red"))
		{
			Stats@ current = Stats(params);
			client_stats_red.push_back(current);
		}
	}

	if(cmd == this.getCommandID("clear stats"))
	{
		all_stats_blue.clear();
		all_stats_red.clear();
		client_stats_blue.clear();
		client_stats_red.clear();
	}
}

// make username.cfg file with kills and deaths
void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	//if(player is null) return;
	if(player is null) ("lets see if player is null");

	if(isServer())
		StatsSync(this);

    string username = player.getUsername();
    
    ConfigFile file;
    
    if(!file.loadFile("../Cache/" + STATS_DIR + username + "~blue" + ".cfg")) 
    { 
    	file.add_u32("kills", 0); 
    	file.add_u32("deaths", 0);
    	file.add_u32("matches_won", 0);
    	file.add_u32("matches_lost", 0);

    	file.add_u32("k_kills", 0);
    	file.add_u32("k_deaths", 0);

    	file.add_u32("b_kills", 0);
    	file.add_u32("b_deaths", 0);

    	file.add_u32("a_kills", 0);
    	file.add_u32("a_deaths", 0);

		file.add_u32("time played", 0); 
		file.add_u32("coins", 0);

		for(int i = 0; i < hitterstuff.length(); ++i)
		{
			file.add_u32("kill_" + hitterstuff[i], 0);
			file.add_u32("death_" + hitterstuff[i], 0);
		}

        print("Didn't find file onNewPlayerJoin: "+username);
        
        if(!file.saveFile(STATS_DIR + username + "~blue"))
	    {
	        print("Cant save file " + username + "~blue");
	    }
	    else
	    {
	    	print("We did it! " + username + "~blue");
	    }
    }

    ConfigFile file2;

    if(!file2.loadFile("../Cache/" + STATS_DIR + username + "~red" + ".cfg")) 
    { 
    	file2.add_u32("kills", 0); 
    	file2.add_u32("deaths", 0);
    	file2.add_u32("matches_won", 0);
    	file2.add_u32("matches_lost", 0);

    	file2.add_u32("k_kills", 0);
    	file2.add_u32("k_deaths", 0);

    	file2.add_u32("b_kills", 0);
    	file2.add_u32("b_deaths", 0);

    	file2.add_u32("a_kills", 0);
    	file2.add_u32("a_deaths", 0);

		file2.add_u32("time played", 0); 
		file2.add_u32("coins", 0);

		for(int i = 0; i < hitterstuff.length(); ++i)
		{
			file2.add_u32("kill_" + hitterstuff[i], 0);
			file2.add_u32("death_" + hitterstuff[i], 0);
		}

        print("Didn't find file onNewPlayerJoin: "+username);
        
        if(!file2.saveFile(STATS_DIR + username + "~red"))
	    {
	        print("Cant save file " + username + "~red");
	    }
	    else
	    {
	    	print("Saved file " + username + "~red");
	    }
    }

    ConfigFile file3;

    if(!file3.loadFile("../Cache/" + STATS_DIR + "S_all_players")) 
    { 
    	string[] players;
    	players.push_back(username);
    	file3.addArray_string("All players", players);

    	file3.saveFile(STATS_DIR + "S_all_players");
    }
    else
    {
    	string[] players;
    	file3.readIntoArray_string(players, "All players");

    	if (players.find(username) == -1)
    	{
    		players.push_back(username);
    	}

    	file3.addArray_string("All players", players);

    	file3.saveFile(STATS_DIR + "S_all_players");
    }

    if (!this.hasTag("stats on") || player is null || this is null) return;

	string player_name = player.getUsername();

	if (current_usernames.find(player_name) == -1)
	{
		statsPlayerSetup(player_name);
	}	

	string current_team;
	string previous_team;

	u8 newteam = player.getTeamNum();

	if(newteam == 0)
		current_team = "blue";
	else if(newteam == 1)
		current_team = "red";

	// Player joined new team: start counting time
	if(newteam == 0 || newteam == 1)
	{
		this.set_u32(player_name + "_" + current_team + "_" + "start", getGameTime());
	}
}

void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ killer, u8 customdata)
{
	if(this.hasTag("stats on") && this.getCurrentState() == GAME)
	{
		if (victim !is null)
		{
			string hitter_string;

			switch (customdata)
			{
				case Hitters::fall:     		hitter_string = "_fall"; break;

				case Hitters::drown:     		hitter_string = "_water"; break;

				case Hitters::fire:
				case Hitters::burn:     		hitter_string = "_fire"; break;

				case Hitters::stomp:    		hitter_string = "_stomp"; break;

				case Hitters::builder:  		hitter_string = "_builder"; break;

				case Hitters::spikes:  			hitter_string = "_spikes"; break;

				case Hitters::sword:    		hitter_string = "_sword"; break;

				case Hitters::shield:   		hitter_string = "_shield"; break;

				case Hitters::bomb_arrow:		hitter_string = "_bombarrow"; break;

				case Hitters::bomb:
				case Hitters::explosion:     	hitter_string = "_bomb"; break;

				case Hitters::keg:     			hitter_string = "_keg"; break;

				case Hitters::mine:             hitter_string = "_mine"; break;
				case Hitters::mine_special:     hitter_string = "_mine"; break;

				case Hitters::arrow:    		hitter_string = "_arrow"; break;

				case Hitters::ballista: 		hitter_string = "_ballista"; break;

				case Hitters::boulder:			hitter_string = "_boulder"; break;
				case Hitters::cata_stones:		hitter_string = "_stones"; break;
				case Hitters::cata_boulder:  	hitter_string = "_boulder"; break;

				case Hitters::drill:			hitter_string = "_drill"; break;
				case Hitters::saw:				hitter_string = "_saw"; break;

				default: 						hitter_string = "_fall";
			}

			string username = victim.getUsername();

			if (killer !is null && killer.getTeamNum() != victim.getTeamNum())
			{
				string username2 = killer.getUsername();

				int killerteam = killer.getTeamNum();
				int victimteam = victim.getTeamNum();

				string killteam = (killer.getTeamNum() == 0 ? "blue" : "red");
				string victteam = (victim.getTeamNum() == 0 ? "blue" : "red");

				if(victim.getBlob() !is null)
				{
					CBlob@ victim_blob = victim.getBlob();

					upClassStat(this, victim_blob, username, "deaths", victteam);

					this.add_u32(username + "_death" + hitter_string + "~" + victteam, 1);
				}

				if(killer.getBlob() !is null)
				{
					CBlob@ killer_blob = killer.getBlob();

					upClassStat(this, killer_blob, username2, "kills", killteam);

					this.add_u32(username2 + "_kill" + hitter_string + "~" + killteam, 1);
				}

				this.add_u32(username2 + "_kills" + "~" + killteam, 1);
				this.add_u32(username + "_deaths" + "~" + victteam, 1);

				if(killerteam == 0)
				{
					this.add_u32("bluekills", 1);
					this.add_u32("bluekill_" + hitter_string, 1);
				}
				else if(killerteam == 1)
				{
					this.add_u32("redkills", 1);
					this.add_u32("redkill_" + hitter_string, 1);
				}

				if(victimteam == 0)
				{
					this.add_u32("bluedeaths", 1);
					this.add_u32("bluedeath_" + hitter_string, 1);
				}
				else if(victimteam == 1)
				{
					this.add_u32("reddeaths", 1);
					this.add_u32("reddeath_" + hitter_string, 1);
				}
			}

			else if (killer is null)
			{
				int victimteam = victim.getTeamNum();

				string victteam = (victim.getTeamNum() == 0 ? "blue" : "red");

				if(victim.getBlob() !is null)
				{
					CBlob@ victim_blob = victim.getBlob();

					upClassStat(this, victim_blob, username, "deaths", victteam);

					this.add_u32(username + "_death" + hitter_string + "~" + victteam, 1);
				}

				this.add_u32(username + "_deaths" + "~" + victteam, 1);
				if(victimteam == 0)
					this.add_u32("bluedeaths", 1);
				else if(victimteam == 1)
					this.add_u32("reddeaths", 1);
			}
		}
	}
}

void onStateChange( CRules@ this, const u8 oldState )
{
	if (!this.hasTag("stats on")) return;

	if (this.isGameOver() && this.getTeamWon() >= 0)
	{
		string mapName = getFilenameWithoutExtension(getFilenameWithoutPath(getMap().getMapName()));
		string winningTeam = (this.getTeamWon() == 0) ? "Blue" : "Red";

		// up total match count by 1
		ConfigFile file;

		// If there's no count.cfg
	    if(!file.loadFile("../Cache/" + STATS_DIR + "count")) 
	    { 
	    	file.add_u32("matches", 1); 
	        file.saveFile(STATS_DIR + "count");
	    }
	    // If there's count.cfg already
	    else
	    {
	    	file.add_u32("matches", file.read_u32("matches") + 1); 
			file.saveFile(STATS_DIR + "count");
	    }

	    int match_count = file.read_u32("matches");

	    string[] blue_players;
	    string[] red_players;

	    for(int i = 0; i < current_usernames.length(); ++i)
	    {
	    	string username = current_usernames[i];

	    	CPlayer@ p = getPlayerByUsername(username);

	    	string current_team;
	    	if(p !is null) 
	    	{
				if (p.getTeamNum() == 0) current_team = "blue";
				else if (p.getTeamNum() == 1) current_team = "red";

				this.set_u32(username + "_" + current_team + "_" + "end", getGameTime());

		    	u32 previous_time = this.get_u32(username + "_" + current_team + "_" + "end") - this.get_u32(username + "_" + current_team  + "_" + "start");
				this.add_u32(username + "_" + current_team + "_" + "total", previous_time);
			}

			// play for at least 10% of match time or at least 10 minutes
			if(this.get_u32(username + "_blue_total") + this.get_u32(username + "_red_total") > getGameTime() / 10 || this.get_u32(username + "_blue_total") + this.get_u32(username + "_red_total") > 60 * 30 * 10)
			{
				//ConfigFile file3;
		    	//if(file3.loadFile("../Cache/" + STATS_DIR + username)) 
		    	//{
		    		// Blue player
		    		//if (this.get_u32(username + "_blue_total") > this.get_u32(username + "_red_total"))
		    		if (this.get_u32(username + "_blue_total") > 0)
		    		{
		    			blue_players.push_back(username);

		    			ConfigFile file4;
						if(file4.loadFile("../Cache/" + STATS_DIR + username + "~blue")) 
						{
			    			if (this.get_u32(username + "_blue_total") > this.get_u32(username + "_red_total"))
				    		{
				    			if(this.getTeamWon() == 0)
					    		{
					    			file4.add_u32("matches_won", file4.read_u32("matches_won") + 1); 
					    		}
					    		else
					    		{
					    			file4.add_u32("matches_lost", file4.read_u32("matches_lost") + 1); 
					    		}
					    	}

				    		if(this.exists(username + "_blue_total"))
					    	{
					    		file4.add_u32("time played", file4.read_u32("time played") + this.get_u32(username + "_blue_total"));
					    	}

				    		file4.saveFile(STATS_DIR + username + "~blue");
				    	}
		    		}
		    		// Red player
		    		//else
		    		if (this.get_u32(username + "_red_total") > 0)
		    		{
		    			red_players.push_back(username);

		    			ConfigFile file7;
						if(file7.loadFile("../Cache/" + STATS_DIR + username + "~red")) 
						{
				    		if (this.get_u32(username + "_blue_total") <= this.get_u32(username + "_red_total"))
				    		{
				    			if(this.getTeamWon() == 1)
					    		{
					    			file7.add_u32("matches_won", file7.read_u32("matches_won") + 1); 
					    		}
					    		else
					    		{
					    			file7.add_u32("matches_lost", file7.read_u32("matches_lost") + 1); 
					    		}
				    		}

				    		if(this.exists(username + "_red_total"))
				    		{
				    			file7.add_u32("time played", file7.read_u32("time played") + this.get_u32(username + "_red_total"));
				    		}

				    		file7.saveFile(STATS_DIR + username + "~red");
				    	}
		    		}
		    	//}
	    	}	
	    }

	    ConfigFile file2;
	    if(!file2.loadFile("../Cache/" + STATS_DIR + "match" + match_count)) 
	    { 
	    	file2.add_u32("Match number", match_count); 
	    	file2.add_string("Map", mapName);
	    	file2.add_u32("Match time", getGameTime());
	    	file2.add_string("Winning team", winningTeam);
	    	file2.addArray_string("Blue team", blue_players);
	    	file2.addArray_string("Red team", red_players);

	    	file2.add_u32("Blue kills", this.get_u32("bluekills"));
	    	file2.add_u32("Blue deaths", this.get_u32("bluedeaths"));
	    	int totalkd;
	    	if (this.get_u32("bluedeaths") == 0) totalkd = this.get_u32("bluekills");
	    	else totalkd = this.get_u32("bluekills") / this.get_u32("bluedeaths");
	    	file2.add_f32("Blue K/D", totalkd);

	    	file2.add_u32("Red kills", this.get_u32("redkills"));
			file2.add_u32("Red deaths", this.get_u32("reddeaths"));
	    	int totalkd2;
	    	if (this.get_u32("reddeaths") == 0) totalkd2 = this.get_u32("redkills");
	    	else totalkd2 = this.get_u32("redkills") / this.get_u32("reddeaths");
	    	file2.add_f32("Red K/D", totalkd2);

	    	for(int i = 0; i < hitterstuff.length(); ++i)
			{
				file2.add_u32("bluekill_" + hitterstuff[i], this.get_u32("bluekill_" + hitterstuff[i]));
				file2.add_u32("redkill_" + hitterstuff[i], this.get_u32("redkill_" + hitterstuff[i]));
				file2.add_u32("bluedeath_" + hitterstuff[i], this.get_u32("bluedeath_" + hitterstuff[i]));
				file2.add_u32("reddeath_" + hitterstuff[i], this.get_u32("reddeath_" + hitterstuff[i]));
			}

	        file2.saveFile(STATS_DIR + "match" + match_count);
	    }
	    else
	    {
	    	printf("There's already a match with that number!");
	    }

	    if (this.hasTag("stats on")) this.Untag("stats on");
	}
}

void onPlayerChangedTeam( CRules@ this, CPlayer@ player, u8 old_team, u8 newteam )
{
	printf("Test");
	if (!this.hasTag("stats on") || player is null || this is null) return;

	string player_name = player.getUsername();

	if (current_usernames.find(player_name) == -1)
	{
		statsPlayerSetup(player_name);
	}	

	string current_team;
	string previous_team;

	if(newteam == 0)
		current_team = "blue";
	else if(newteam == 1)
		current_team = "red";

	if(old_team == 0)
		previous_team = "blue";
	else if(old_team == 1)
		previous_team = "red";

	// Player joined new team: start counting time
	if(newteam == 0 || newteam == 1)
	{
		this.set_u32(player_name + "_" + current_team + "_" + "start", getGameTime());
	}

	// Player left old team: stop counting time
	if(old_team == 0 || old_team == 1)
	{
		this.set_u32(player_name + "_" + previous_team + "_" + "end", getGameTime());
		u32 previous_time = this.get_u32(player_name + "_" + previous_team + "_" + "end") - this.get_u32(player_name + "_" + previous_team + "_" + "start");
		this.add_u32(player_name + "_" + previous_team + "_" + "total", previous_time);
	}
}

void onPlayerLeave( CRules@ this, CPlayer@ player )
{
	if(!this.hasTag("stats on") || player is null) return;

	if (player.getTeamNum() != 0 && player.getTeamNum() != 1) return;

	string player_name = player.getUsername();

	string current_team;
	if (player.getTeamNum() == 0) current_team = "blue";
	else if (player.getTeamNum() == 1) current_team = "red";

	// Player is no longer playing for a team - stop counting time
	this.set_u32(player_name + "_" + current_team + "_" + "end", getGameTime());
	u32 previous_time = this.get_u32(player_name + "_" + current_team + "_" + "end") - this.get_u32(player_name + "_" + current_team  + "_" + "start");
	this.add_u32(player_name + "_" + current_team + "_" + "total", previous_time);

}
