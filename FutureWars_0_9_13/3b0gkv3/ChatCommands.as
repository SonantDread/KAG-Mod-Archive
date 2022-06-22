// Simple chat processing example.
// If the player sends a command, the server does what the command says.
// You can also modify the chat message before it is sent to clients by modifying text_out

#include "7udhq.as";
#include "3ld485t.as";
#include "gn7bft.as";

#include "2bku9o7.as";

#include "MakeSeed.as";
#include "MakeCrate.as";
#include "MakeScroll.as";

const string[] bot_names =
{
	"Noob",
	"Ultron",
	"Hax0r",
	"Geti",
	"Gatu",
	"Drone",
	"NotARobot",
	"AimAssist"
};

bool onServerProcessChat( CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player )
{
	if (player is null)
		return true;
	
	string name = player.getUsername();
	
	const bool lion = name == "Aphelion" || name == "Perihelion371";
	const bool superadmin = getSecurity().getPlayerSeclev(player).getName() == "Super Admin";
	const bool mod = player.isMod();
	const bool canSpawn = lion;
	
    CBlob@ blob = player.getBlob();
    if    (blob is null)
        return true;
	
	bool chatVisible = true;
	
	Vec2f pos = blob.getAimPos();
	int team = blob.getTeamNum();
	
	if (lion)
	{
        string[]@ args = text_in.split(" ");

	    if (args[0] == "/wep")
		{
		    setItem(blob, ItemType::WEAPON_PRIMARY, args[1]);
		}
		else if (args[0] == "/testing")
		{
			CRules@ rules = getRules();

			if (args.length > 1 && args[1] == "off")
				rules.set_bool("testing", false);
			else
				rules.set_bool("testing", true);

			rules.Sync("testing", true);
		}
		else if (args[0] == "/ai")
		{
			CRules@ rules = getRules();

			if (args.length > 1 && args[1] == "off")
				rules.set_bool("ai", false);
			else
				rules.set_bool("ai", true);

			rules.Sync("ai", true);
		}
		else if (args[0] == "/teleto")
		{
			string playerName = args[1];
			
			for(uint i = 0; i < getPlayerCount(); i++)
			{
				CPlayer@ teletoPlayer = getPlayer(i);
				if      (teletoPlayer !is null && teletoPlayer.getUsername() == playerName)
				{
					CBlob@ teletoBlob = teletoPlayer.getBlob();
					if    (teletoBlob !is null)
					{
						blob.setPosition(teletoBlob.getPosition());
						blob.setVelocity( Vec2f_zero );			  
						blob.getShape().PutOnGround();
					}
				}
			}
		}
	}
	
	if (superadmin)
	{
		if(text_in == "/s" || text_in == "/stone")
		{
			CBlob@ b = server_CreateBlob( "mat_stone", team, pos );

			if (b !is null)
			{
				b.server_SetQuantity(250);
			}
		}
		else if(text_in == "/w" || text_in == "/wood")
		{
			CBlob@ b = server_CreateBlob( "mat_wood", team, pos );

			if (b !is null)
			{
				b.server_SetQuantity(500);
			}
		}
		else if((text_in == "/g" || text_in == "/gold") && lion)
		{
			CBlob@ b = server_CreateBlob( "mat_gold", team, pos );

			if (b !is null)
			{
				b.server_SetQuantity(100);
			}
		}
	}
	
	// MODERATOR COMMANDS
	if (mod)
	{
	    if(text_in == "/mypos")
		{
		    Vec2f pos = blob.getPosition();
			
	        client_AddToChat("Pos X:" + pos.x + ", Pos Y:" + pos.y);
		}
	}
	
	if (text_in == "/stats")
	{
		PlayerProfile@ profile = getProfile(player);

		if (profile !is null)
		{
			int kills  = profile.kills;
			int deaths = profile.deaths;
			f32 ratio = getRatio(kills, deaths);

			cmdSendMessage(player.getUsername(), "-- Kills: " + kills + " Deaths: " + deaths + " K/D: " + ratio + " --", false);
		}

		chatVisible = false;
	}
	
	// TEMP
    if (text_in == "/debug" && lion)
    {
        // print all blobs
        CBlob@[] all;
        getBlobs( @all );
		printf("BLOBS TOTAL: " + all.length);
    }
	
	if (!chatVisible && lion)
	{
	    return false;
	}
    
	// SPAWNING
	if (canSpawn)
	{
		if (text_in == "!spawnwater" && lion)
		{
			getMap().server_setFloodWaterWorldspace(pos, true);
		}
		else if (text_in == "!pine")
		{
			server_MakeSeed( pos, "tree_pine", 300, 1, 8 );
		}
		else if (text_in == "!oak")
		{
			server_MakeSeed( pos, "tree_bushy", 300, 2, 8 );
		}
		else if (text_in == "!redwood")
		{
			server_MakeSeed( pos, "tree_redwood", 300, 7, 8 );
		}
		else if (text_in == "!flowers")
        {
            server_CreateBlob( "Entities/Natural/Flowers/Flowers.cfg", blob.getTeamNum(), blob.getPosition() );
        }
		else if (text_in == "!s" || text_in == "!stone")
		{
			CBlob@ b = server_CreateBlob( "mat_stone", team, pos );

			if (b !is null)
			{
				b.server_SetQuantity(500);
			}
		}
		else if (text_in == "!w" || text_in == "!wood")
		{
			CBlob@ b = server_CreateBlob( "mat_wood", team, pos );

			if (b !is null)
			{
				b.server_SetQuantity(500);
			}
		}
		else if (text_in == "!g" || text_in == "!gold")
		{
			CBlob@ b = server_CreateBlob( "mat_gold", team, pos );

			if (b !is null)
			{
				b.server_SetQuantity(500);
			}
		}
		else if (text_in == "!c" || text_in == "!coal")
		{
			CBlob@ b = server_CreateBlob( "mat_coal", team, pos );

			if (b !is null)
			{
				b.server_SetQuantity(100);
			}
		}
		else if (text_in == "!i" || text_in == "!iron")
		{
			CBlob@ b = server_CreateBlob( "mat_iron", team, pos );

			if (b !is null)
			{
				b.server_SetQuantity(100);
			}
		}
		else if (text_in == "!m" || text_in == "!mythril")
		{
			CBlob@ b = server_CreateBlob( "mat_mythril", team, pos );

			if (b !is null)
			{
				b.server_SetQuantity(100);
			}
		}
		else if (text_in == "!bombs")
		{
			for (int i = 0; i < 3; i++)
			{
				CBlob@ b = server_CreateBlob( "mat_bombs", team, pos );
				
				if (b !is null) 
				{
					b.server_SetQuantity(4);
				}
			}
		}
		else if (text_in == "!arrows")
		{
			for (int i = 0; i < 3; i++)
			{
				CBlob@ b = server_CreateBlob( "mat_arrows", team, pos );

				if (b !is null) {
					b.server_SetQuantity(30);
				}
			}
		}
		else if (text_in == "!bombarrows")
		{
			for (int i = 0; i < 3; i++)
			{
				CBlob@ b = server_CreateBlob( "mat_bombarrows", team, pos );

				if (b !is null) {
					b.server_SetQuantity(2);
				}
			}
		}
		else if (text_in == "!crate")
		{
			server_MakeCrate( "", "", 0, team, Vec2f( pos.x, pos.y - 30.0f ) );
		}
		else if (text_in == "!coins")
		{
			player.server_setCoins(player.getCoins() + 5000);
		}
		else if (text_in.substr(0, 1) == "!")
        {
            string[]@ tokens = text_in.split(" ");
            
            if (tokens.length > 1)
            {
				if (tokens[0] == "!settime" && lion)
			    {
				    float time = parseFloat(tokens[1]);
					getMap().SetDayTime(time);
				}
				else if (tokens[0] == "!bot" && lion)
			    {
        	        CPlayer@ bot = AddBot( tokens[1] );
				}
				else if (tokens[0] == "!team" && lion)
				{
					int team = parseInt(tokens[1]);
					blob.server_setTeamNum(team);
				}
				else if (tokens[0] == "!crate")
				{
					int frame = tokens[1] == "catapult" ? 1 : 0;
					string description = tokens.length > 2 ? tokens[2] : tokens[1];
					server_MakeCrate( tokens[1], description, frame, -1, Vec2f( pos.x, pos.y ) );
				}
			}
			else if (tokens[0] == "!bot")
			{
        	    CPlayer@ bot = AddBot( bot_names[XORRandom(bot_names.length)] );
			}
			
			// try to spawn an actor with this name !actor
			string name = text_in.substr(1, text_in.size());
			
			server_CreateBlob( name, team, pos );
		}
		else 
		{
		    return true;
		}
		return !lion;
	}
    return true;
}

bool onClientProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	CBlob@ blob = player.getBlob();

	if (player is getLocalPlayer() && (text_in == "/help" || text_in == "!help"))
	{
		this.set_u32("help_time", getGameTime());
	}

	const bool lion = player.getUsername() == "Aphelion" || player.getUsername() == "Perihelion371";
	if        (lion)
	{
		string[]@ args = text_in.split(" ");
		
	    if (text_in == "/medic")
		{
		    Sound::Play("Mercenary_NeedHeal.ogg", player.getBlob().getPosition());
		    return false;
		}

		if (args[0] == "/testing")
		{
			if (args.length > 1 && args[1] == "off")
				sendMessage("TESTING: Disabled");
			else
				sendMessage("TESTING: Enabled -- All items unlocked");
		}
		else if(args[0] == "/teleto")
		{
			string playerName = args[1];
			
			for(uint i = 0; i < getPlayerCount(); i++)
			{
				CPlayer@ teletoPlayer = getPlayer(i);
				if      (teletoPlayer !is null && teletoPlayer.getUsername() == playerName)
				{
					CBlob@ teletoBlob = teletoPlayer.getBlob();
					if    (teletoBlob !is null)
					{
						player.getBlob().setPosition(teletoBlob.getPosition());
						player.getBlob().setVelocity( Vec2f_zero );			  
						player.getBlob().getShape().PutOnGround();
					}
				}
			}
		}
	}
    return true;
}
