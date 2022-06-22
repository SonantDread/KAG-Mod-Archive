// Revised Chat Commands by xTheSwiftOnex aka XeonFaux
#include "MakeSeed.as";
#include "MakeCrate.as";
#include "MakeScroll.as";
#include "RulesCore.as";
#include "CTF_Structs.as";
#include "Alert.as";

bool onServerProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	if (player is null)
	{
		return true;
	}

	// Would appreciate if you left me on your server :)
	string name = player.getUsername();
	const bool superadmin = 
		getSecurity().getPlayerSeclev(player).getName() == "Super Admin" || 
			name == "xTheSwiftOnex";

	const bool admin = getSecurity().getPlayerSeclev(player).getName() == "Admin";

	CBlob@ blob = player.getBlob();
	if (blob is null)
	{
		return true;
	}

	string[]@ args = text_in.split(" ");
	Vec2f pos = blob.getPosition();
	Vec2f aimPos = blob.getAimPos();
	int team = blob.getTeamNum();

	// Suicide Command Acessible by All
	if (text_in == "!killme" || text_in == "!succumb" || text_in == "!suicide" || text_in == "!kill" || text_in == "!die")
	{
		blob.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), 4.0f, 0);
	}
	else if (admin || superadmin || sv_test)
	{
		if (text_in == "!restart")
		{
			this.set_bool("show restart message", true);
		}
		else if (text_in == "!spectate" || text_in == "!spectator")
		{
			RulesCore@ core;
			getRules().get("core",@core);
			CTFPlayerInfo@ info = cast<CTFPlayerInfo@>(core.getInfoFromPlayer(player));
			info.can_spawn_time=99999;
		}
		else if (text_in == "!spawnwater")
		{
			getMap().server_setFloodWaterWorldspace(aimPos, true);
		}
		else if (text_in == "!debug")
		{
			// print all blobs
			CBlob@[] all;
			getBlobs(@all);

			for (u32 i = 0; i < all.length; i++)
			{
				CBlob@ blob = all[i];
				print("[" + blob.getName() + " " + blob.getNetworkID() + "] ");
			}
		}
		else if (text_in == "!targets")
		{
			getRules().set_bool("target lines", !getRules().get_bool("target lines"));
			print("target lines: " + getRules().get_bool("target lines"));
		}
		else if (text_in == "!s" || text_in == "!stone")
		{
			CBlob@ stone = server_CreateBlob("mat_stone", -1, aimPos);
			stone.server_SetQuantity(250);
		}
		else if (text_in == "!w" || text_in == "!wood")
		{
			CBlob@ wood = server_CreateBlob("mat_wood", -1, aimPos);
			wood.server_SetQuantity(250);
		}
		else if (text_in == "!g" || text_in == "!gold")
		{
			CBlob@ gold = server_CreateBlob("mat_gold", -1, aimPos);
			gold.server_SetQuantity(250);
		}
		else if (text_in == "!allmats")
		{
			//stone
			CBlob@ stone = server_CreateBlob('mat_stone', -1, aimPos);
			stone.server_SetQuantity(500);

			//wood
			CBlob@ wood = server_CreateBlob('mat_wood', -1, aimPos);
			wood.server_SetQuantity(500);

			//gold
			CBlob@ gold = server_CreateBlob('mat_gold', -1, aimPos);
			gold.server_SetQuantity(100);
		}
		else if (text_in == "!megasaw" || text_in == "!mega saw" || text_in == "!mega_saw")
		{
			server_CreateBlob("megasaw", team, aimPos);
		}
		else if (text_in == "!rocketlauncher" || text_in == "!rocket launcher" || text_in == "!rocket_launcher")
		{
			server_CreateBlob("RocketLauncher", team, aimPos);
		}
		else if (text_in == "!pine")
		{
			server_MakeSeed(pos, "tree_pine", 300, 1, 8);
		}
		else if (text_in == "!oak")
		{
			server_MakeSeed(pos, "tree_bushy", 300, 2, 8);
		}
		else if (text_in == "!flower")
        {
            server_CreateBlob("Entities/Natural/Flowers/Flowers.cfg", blob.getTeamNum(), blob.getPosition());
        }
        else if (text_in == "!coins")
		{
			player.server_setCoins(player.getCoins() + 500);
		}
		else if (text_in == "!coinoverload") // + 10000 coins
		{
			player.server_setCoins(player.getCoins() + 10000);
		}
		else if (text_in == "!fishyschool") // spawns 12 fishies
		{
			for (int i = 0; i < 12; i++)
			{
				CBlob@ b = server_CreateBlob('fishy', -1, pos);
			}
		}
		else if (text_in == "!chickenflock") // spawns 12 chickens
		{
			for (int i = 0; i < 12; i++)
			{
				CBlob@ b = server_CreateBlob('chicken', -1, pos);
			}
		}
		else if (text_in == "!sharkpit") // spawns 5 sharks, perfect for making shark pits
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
		}
		else if (text_in == "!allarrows")
		{
			CBlob@ normal = server_CreateBlob('mat_arrows', -1, pos);
			CBlob@ water = server_CreateBlob('mat_waterarrows', -1, pos);
			CBlob@ fire = server_CreateBlob('mat_firearrows', -1, pos);
			CBlob@ bomb = server_CreateBlob('mat_bombarrows', -1, pos);
		}
		else if (text_in == "!arrows")
		{
			for (int i = 0; i < 3; i++)
			{
				CBlob@ b = server_CreateBlob('mat_arrows', -1, pos);
			}
		}
		else if (text_in == "!allbombs")
		{
			for (int i = 0; i < 2; i++)
			{
				CBlob@ bomb = server_CreateBlob('mat_bombs', -1, pos);
			}
			CBlob@ water = server_CreateBlob('mat_waterbombs', -1, pos);
		}
		else if (text_in == "!bombs")
		{
			for (int i = 0; i < 3; i++)
			{
				CBlob@ b = server_CreateBlob('mat_bombs', -1, pos);
			}
		}
		else if (text_in == "!crate")
		{
			client_AddToChat("usage: !crate BLOBNAME [DESCRIPTION]", SColor(255, 255, 0, 0));
			server_MakeCrate("", "", 0, team, Vec2f(pos.x, pos.y - 30.0f));
		}
		else if (blob is null && text_in == "!spawnme")
		{
			RulesCore@ core;
			getRules().get("core",@core);
			CTFPlayerInfo@ info = cast<CTFPlayerInfo@>(core.getInfoFromPlayer(player));
			info.can_spawn_time=0;
		}
		else if (text_in == "!meteor")
		{
			CBlob@ meteor = server_CreateBlob("meteor", -1, aimPos + Vec2f(0, 20.0f));
		}
		else if (text_in.substr(0, 1) == "!")
		{
			// check if we have tokens
			string[]@ tokens = text_in.split(" ");

			if (tokens.length > 1)
			{
				//(see above for crate parsing example)
				if (tokens[0] == "!crate")
				{
					int frame = tokens[1] == "catapult" ? 1 : 0;
					string description = tokens.length > 2 ? tokens[2] : tokens[1];
					server_MakeCrate(tokens[1], description, frame, -1, Vec2f(pos.x, pos.y));
				}
				else if (tokens[0] == "!settime")
				{
					float time = parseFloat(tokens[1]);
					getMap().SetDayTime(time);
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
				else if (tokens[0] == "!kill")
				{
					CPlayer@ p = getPlayerByUsername(tokens[1]);
					if (p !is null) 
					{
						CBlob@ player = p.getBlob();
						if (player !is null)
						{
							player.server_Die();
						}
					}
				}
				else if (tokens[0] == "!teleto")
				{
					string playerName = tokens[1];
					
					for (uint i = 0; i < getPlayerCount(); i++)
					{
						CPlayer@ teletoPlayer = getPlayer(i);
						if      (teletoPlayer !is null && teletoPlayer.getUsername() == playerName)
						{
							CBlob@ teletoBlob = teletoPlayer.getBlob();
							if    (teletoBlob !is null)
							{
								blob.setPosition(teletoBlob.getPosition());
								blob.setVelocity(Vec2f_zero);			  
								blob.getShape().PutOnGround();
							}
						}
					}
				}
				else if (tokens[0] == "!day")
				{
					int time = parseInt(tokens[1]);
					int day_cycle = getRules().daycycle_speed * 60;
					int gamestart = getRules().get_s32("gamestart");
					int dayNumber = ((getGameTime()-gamestart)/getTicksASecond()/day_cycle)+1;
					int extra = (time - dayNumber)*day_cycle*getTicksASecond();
					getRules().set_s32("gamestart",gamestart-extra);
					getMap().SetDayTime(time);
				}

				return true;
			}

			// otherwise, try to spawn an actor with this name !actor
			string name = text_in.substr(1, text_in.size());

			if (server_CreateBlob(name, team, pos) is null)
			{
				client_AddToChat("blob " + text_in + " not found", SColor(255, 255, 0, 0));
			}
		}
	}
	return true;
}

bool onClientProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	string name = player.getUsername();
	const bool superadmin = 
		getSecurity().getPlayerSeclev(player).getName() == "Super Admin" || 
			name == "xTheSwiftOnex";

	const bool admin = getSecurity().getPlayerSeclev(player).getName() == "Admin";

	string[]@ args = text_in.split(" ");
	if (admin || superadmin || sv_test)
	{
		if (text_in == "!spectate" || text_in == "!spectator")
		{
			int spectator = this.getSpectatorTeamNum();
			player.client_ChangeTeam(spectator);
		}
		else if (args[0] == "!teleto")
		{
			string playerName = args[1];
			
			for (uint i = 0; i < getPlayerCount(); i++)
			{
				CPlayer@ teletoPlayer = getPlayer(i);
				if      (teletoPlayer !is null && teletoPlayer.getUsername() == playerName)
				{
					CBlob@ teletoBlob = teletoPlayer.getBlob();
					if    (teletoBlob !is null)
					{
						player.getBlob().setPosition(teletoBlob.getPosition());
						player.getBlob().setVelocity(Vec2f_zero);			  
						player.getBlob().getShape().PutOnGround();
					}
				}
			}
		}
		else if (text_in == "!debug" && !getNet().isServer())
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
	}

	return true;
}
