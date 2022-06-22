// Simple chat processing example.
// If the player sends a command, the server does what the command says.
// You can also modify the chat message before it is sent to clients by modifying text_out

#include "Logging.as";
#include "MakeSeed.as";
#include "MakeCrate.as";
#include "MakeScroll.as";
#include "RulesCore.as";

const int TEAM_BLUE = 0;
const int TEAM_RED  = 1;

bool onServerProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	RulesCore@ core;
	this.get("core", @core);

	if (player is null)
		return true;

	if (text_in == "!allspec" && player.isMod())
	{
		CBlob@[] all;
		getBlobs( @all );
		for (u32 i=0; i < all.length; i++)
		{		
			CBlob@ blob1 = all[i];
			if(blob1.getPlayer() != null)
			{
				core.ChangePlayerTeam(blob1.getPlayer(), this.getSpectatorTeamNum());
			}
		}
	}
	else if (text_in == "!lockteams" && player.isMod())
    {
		if (this.get_bool("lockedteams"))
		{
			this.set_bool("lockedteams", false);
			this.Sync("lockedteams", true);
			getNet().server_SendMsg( "swapping teams is enabled!" );
		}
		else
		{
			this.set_bool("lockedteams", true);
			this.Sync("lockedteams", true);
			getNet().server_SendMsg( "swapping teams is disabled!" );
		}
	}
	else if (text_in == "!pause" && player.isMod())
	{
		for (int a = 0; a < getPlayerCount(); a++)
		{ 
			getPlayer(a).freeze = true; 
		}
	}
	else if (text_in == "!unpause" && player.isMod())
	{
		for (int a = 0; a < getPlayerCount(); a++)
		{ 
			getPlayer(a).freeze = false; 
		}
	}
	
	string[]@ tokens = text_in.split(" ");
    	int tlen = tokens.length;

    if (tokens[0]=="!blue" && tlen>=2 && player.isMod()) 
    {
        CBlob@[] all;
        getBlobs( @all );
        string targetIdent = tokens[1];
        CPlayer@ target = GetPlayerByIdent(targetIdent);
        if(target != null)
        {
            ChangePlayerTeam(this, target, TEAM_BLUE);
        }
    }      
    else if (tokens[0]=="!red" && tlen>=2 && player.isMod()) 
    {
        CBlob@[] all;
        getBlobs( @all );
        string targetIdent = tokens[1];
        CPlayer@ target = GetPlayerByIdent(targetIdent);
        if(target != null)
        {
            ChangePlayerTeam(this, target, TEAM_RED);
        } 
    }	
	
	CBlob@ blob = player.getBlob();

	if (blob is null)
	{
		return true;
	}

	//commands that don't rely on sv_test
	
	if (text_in == "!killme")
	{
		blob.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), 100.0f, 0);
	}
	else if (text_in == "!bot" && player.isMod()) // TODO: whoaaa check seclevs
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
	if (sv_test)
	{
		Vec2f pos = blob.getPosition();
		int team = blob.getTeamNum();
		
		if (text_in == "!tree")
		{
			server_MakeSeed(pos, "tree_pine", 600, 1, 16);
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
		else if (text_in == "!seed")
		{
			// crash prevention?
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
				else if (tokens[0] == "!scroll")
				{
					string s = tokens[1];
					for (uint i = 2; i < tokens.length; i++)
						s += " " + tokens[i];
					server_MakePredefinedScroll(pos, s);
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

CPlayer@ GetPlayerByIdent(string ident) 
{
    // Takes an identifier, which is a prefix of the player's character name
    // or username. If there is 1 matching player then they are returned.
    ident = ident.toLower();
    log("GetPlayerByIdent", "ident = " + ident);
    CPlayer@[] matches; // players matching ident

    for (int i=0; i < getPlayerCount(); i++) {
        CPlayer@ p = getPlayer(i);
        if (p is null) continue;

        string username = p.getUsername().toLower();
        string charname = p.getCharacterName().toLower();

        if (username == ident || charname == ident) {
            return p;
        }
        else if (username.find(ident) >= 0 || charname.find(ident) >= 0) {
            matches.push_back(p);
        }
    }
    
    if (matches.length == 1) {
        return matches[0];
    }

    return null;
}

void ChangePlayerTeam(CRules@ this, CPlayer@ player, int teamNum) 
{
    RulesCore@ core;
    this.get("core", @core);
    core.ChangePlayerTeam(player, teamNum);
}