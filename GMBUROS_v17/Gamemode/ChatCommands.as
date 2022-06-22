// Simple chat processing example.
// If the player sends a command, the server does what the command says.
// You can also modify the chat message before it is sent to clients by modifying text_out

#include "MakeSeed.as";
#include "MakeCrate.as";
#include "MakeScroll.as";
#include "Hitters.as";
#include "EquipmentCommon.as";
#include "BasePNGLoader.as";
#include "SaveBlobs.as";
#include "CMap.as";
#include "TimeCommon.as";
#include "GetPlayerData.as";
#include "ClanCommon.as";

bool onServerProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	if (player is null)
		return true;
	
		
	CBlob@ blob = player.getBlob();

	if (blob is null)
	{
		return true;
	}

	//commands that don't rely on sv_test

	if (text_in == "!bot" && player.isMod()) // TODO: whoaaa check seclevs
	{
		CPlayer@ bot = AddBot("Henry");
		return true;
	}
	else if (text_in == "!debug" && player.isMod())
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

	//spawning things

	//these all require sv_test - no spawning without it
	//some also require the player to have mod status
	if (player.getUsername() == "Pirate-Rob")
	{
		Vec2f pos = blob.getPosition();
		int team = blob.getTeamNum();

		if (text_in == "!fire")
		{
			CBlob@[] blobsInRadius;
			if (getMap().getBlobsInRadius(blob.getPosition(), 32.0f, @blobsInRadius)) 
			{
				for (uint i = 0; i < blobsInRadius.length; i++)
				{
					CBlob@ b = blobsInRadius[i];
					
					if(b !is null && b !is blob){

						blob.server_Hit(b, b.getPosition(), Vec2f(0,0), 1.0f, Hitters::fire, true);
					}
				}
			}
		}
		else 
		if (text_in == "!killme")
		{
			blob.server_Die();
		}
		else 
		if (text_in == "!save")
		{
			SavePlayerData("PlayerData.cfg");
			SaveMap(getMap(),"MainMap.png");
			SaveSpecialBlobs("SavedBlobs.cfg");
			SaveClans("SavedClans.cfg");
		}
		else 
		if (text_in == "!minimap")
		{
			getMap().MakeMiniMap();
			return false;
		} else
		if (text_in == "!tree")
		{
			server_MakeSeed(pos, "tree_pine", 600, 1, 16);
		} else
		if (text_in == "!testmap")
		{
			LoadMap("TestMap.png");
		}
		else if (text_in == "!btree")
		{
			server_MakeSeed(pos, "tree_bushy", 400, 2, 16);
		}
		else if (text_in == "!stones")
		{
			CBlob@ b = server_CreateBlob('mat_stone', -1, pos);
		}
		else if (text_in == "!arrows")
		{
			for (int i = 0; i < 3; i++)
			{
				CBlob@ b = server_CreateBlob('mat_arrows', -1, pos);
			}
		}
		else if (text_in == "!bombs")
		{
			for (int i = 0; i < 3; i++)
			{
				CBlob@ b = server_CreateBlob('mat_bombs', -1, pos);
			}
		}
		else if (text_in == "!spawnwater" && player.isMod())
		{
			getMap().server_setFloodWaterWorldspace(pos, true);
		}
		else if (text_in == "!crate")
		{
			client_AddToChat("usage: !crate BLOBNAME [DESCRIPTION]", SColor(255, 255, 0, 0));
			server_MakeCrate("", "", 0, team, Vec2f(pos.x, pos.y - 30.0f));
		}
		else if (text_in == "!coins")
		{
			player.server_setCoins(player.getCoins() + 100);
		}
		else if (text_in == "!archer")
		{
			equipType(blob, EquipSlot::Main, Equipment::Bow, 0);
			equipType(blob, EquipSlot::Sub, Equipment::Grapple, 0);
			equipType(blob, EquipSlot::Torso, Equipment::Shirt, 0);
		}
		else if (text_in == "!knight")
		{
			equipType(blob, EquipSlot::Main, Equipment::Sword, 0);
			equipType(blob, EquipSlot::Sub, Equipment::Shield, 0);
			equipType(blob, EquipSlot::Torso, Equipment::KnightArmour, 0);
		}
		else if (text_in == "!builder")
		{
			equipType(blob, EquipSlot::Main, Equipment::Hammer, 0);
			equipType(blob, EquipSlot::Sub, Equipment::Pick, 0);
			equipType(blob, EquipSlot::Torso, Equipment::Shirt, 0);
		}
		else if (text_in.substr(0, 1) == "!")
		{
			// check if we have tokens
			string[]@ tokens = text_in.split(" ");

			if (tokens.length > 1)
			{
				if (tokens[0] == "!crate")
				{
					int frame = tokens[1] == "catapult" ? 1 : 0;
					string description = tokens.length > 2 ? tokens[2] : tokens[1];
					server_MakeCrate(tokens[1], description, frame, -1, Vec2f(pos.x, pos.y));
				}
				else if (tokens[0] == "!team")
				{
					int team = parseInt(tokens[1]);
					blob.server_setTeamNum(team);
				}
				else if (tokens[0] == "!class")
				{
					string str = tokens[1];
					CBlob @create = server_CreateBlob(str, team, pos);
					if(create !is null){
						create.server_SetPlayer(player);
						blob.server_Die();
					}
				}
				else if (tokens[0] == "!scroll")
				{
					string s = tokens[1];
					for (uint i = 2; i < tokens.length; i++)
						s += " " + tokens[i];
					server_MakePredefinedScroll(pos, s);
				}
				else if (tokens[0] == "!seed")
				{
					server_MakeSeed(pos, tokens[1]);
				}

				return true;
			}

			// try to spawn an actor with this name !actor
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
