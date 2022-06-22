// Simple chat processing example.
// If the player sends a command, the server does what the command says.
// You can also modify the chat message before it is sent to clients by modifying text_out

#include "MakeSeed.as";
#include "MakeCrate.as";
#include "MakeScroll.as";
#include "RulesCore.as";
#include "Logging.as";
#include "SpareCode.as";
bool onServerProcessChat( CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player )
{
	RulesCore@ core;
	this.get("core", @core);

	if (player is null)
		return true;


	//commands that don't rely on sv_test

	string[]@ tokens = text_in.split(" ");
	
	if (tokens[0] == "!settickets" && player.isMod()) {
		if (tokens.length > 1)
		{
			s16 numTix = parseInt(tokens[1]);
	    	this.set_s16("redTickets", numTix);
			this.set_s16("blueTickets", numTix);
			this.Sync("redTickets", true);
			this.Sync("blueTickets", true);
		}
    }
    else if (tokens[0] == "!setredtickets" && player.isMod()) {
		if (tokens.length > 1)
		{
			s16 numTix = parseInt(tokens[1]);
	    	this.set_s16("redTickets", numTix);
			this.Sync("redTickets", true);
		}
    }
    else if (tokens[0] == "!setbluetickets" && player.isMod()) {
		if (tokens.length > 1)
		{
			s16 numTix = parseInt(tokens[1]);
			this.set_s16("blueTickets", numTix);
			this.Sync("blueTickets", true);
		}
    }
    else if (tokens[0] == "!settug" && player.isMod()) {
		if (tokens.length > 1)
		{
			s16 TugCap = parseInt(tokens[1]);
			this.set_s16("TugOfTickets", TugCap);
			this.Sync("TugOfTickets", true);
		}
    }
    else if (text_in == "!allspec" && player.isMod())
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
    }
    else if (text_in == "!lockclasses" && player.isMod())
    {
		lockclasses(this);
	}
	else if (tokens[0] == "!sethealth" && player.isMod())
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
	}
	else if (tokens[0] == "!juggernaut" && player.isMod())
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
	}
	else if (tokens[0] == "!class" && player.isMod())
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
	}

	else if (tokens[0] == "!startoffi" && player.isMod() || tokens[0] == "!stopoffi" && player.isMod())
	{
		setOffi(this);
	}
	else if (tokens[0] == "!nidhogg" && player.isMod())
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
	}
    else if (tokens[0] == "!healing" && player.isMod())
    {
		healing(this);
	}

    else if (tokens[0] == "!testing" && player.isMod())
    {
			CBitStream params;
			this.SendCommand(this.getCommandID("show pick menu"), params, player);
		}
    else if (tokens[0] == "!lockteams" && player.isMod())
    {
		lockteams(this);
	}
    else if (tokens[0] == "!randomize" && player.isMod())

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

    }
    else if (tokens[0] == "!balance" && player.isMod())

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

    }
	else if (tokens[0] == "!red" && player.isMod() || tokens[0] == "!blue" && player.isMod() || tokens[0] == "!spec" && player.isMod())
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
	}

	// Sudden death commands
	else if (text_in == "!expand" && player.isMod())
	{
		CBlob@[] flags;
		if (getBlobsByName("flag_base", @flags))
		{
			for (int i = 0; i < flags.length; ++i)
			{
				flags[i].SendCommand(flags[i].getCommandID("expand_zone"));
			}
		}
		return true;
	}
	else if (text_in == "!shrink" && player.isMod())
	{
		CBlob@[] flags;
		if (getBlobsByName("flag_base", @flags))
		{
			for (int i = 0; i < flags.length; ++i)
			{
				flags[i].SendCommand(flags[i].getCommandID("shrink_zone"));
			}
		}
		return true;
	}
	else if (tokens[0] == "!suddendeath" && player.isMod())
	{
		string response = "Sudden death";
		bool suddendeath_change = false;
		if (tokens.length > 1)
		{
			response += " (every " + tokens[1] + " seconds)";
			this.set_u16("suddendeath_zone_interval", parseInt(tokens[1]));
			suddendeath_change = true;
		}
		if (tokens.length > 2)
		{
			response += " (" + tokens[2] + " times)";
			this.set_u8("suddendeath_zone_max_times", parseInt(tokens[2]));
			suddendeath_change = true;
		}

		CBlob@[] flags;
		bool sd_deactivated = false;
		if (getBlobsByName("flag_base", @flags))
		{
			for (int i = 0; i < flags.length; ++i)
			{
				CBlob@ flag = flags[i];

				if (flag.hasTag("sudden_death_zone") && !suddendeath_change)
				{
					sd_deactivated = true;
					flag.SendCommand(flag.getCommandID("stop_sudden_death"));
				}
				else
					flag.SendCommand(flag.getCommandID("start_sudden_death"));
			}
		}

		response += sd_deactivated ? " off" : " on";
		getNet().server_SendMsg(response);

		return true;
	}

	else if (tokens[0] == "!bot" && player.isMod()) // TODO: whoaaa check seclevs
	if (tokens.size() == 1)
	{
	    CPlayer@ bot = AddBot( "Henry" );
	    return true;
	    
	}
	else if (tokens.size() == 2)
	{
     	for (u32 i=0; i < parseInt(tokens[1]); i++)
     	{
		    CPlayer@ bot = AddBot( "Henry" );
		         	
		}
		return true;
	}

    //spawning things
    
	//these all require sv_test - no spawning without it
	//some also require the player to have mod status
	CBlob@ blob = player.getBlob();

    if (blob is null) {
        return true;
    }
	if(sv_test)
	{
		Vec2f pos = blob.getPosition();
		int team = blob.getTeamNum();
		
		if (text_in == "!tree")
		{
			server_MakeSeed( pos, "tree_pine", 600, 1, 16 );
		}
		else if (text_in == "!btree")
		{
			server_MakeSeed( pos, "tree_bushy", 400, 2, 16 );
		}
		else if (text_in == "!stones")
		{
			CBlob@ b = server_CreateBlob( "Entities/Materials/MaterialStone.cfg", team, pos );

			if (b !is null) {
				b.server_SetQuantity(320);
			}
		}
		else if (text_in == "!arrows")
		{
			for (int i = 0; i < 3; i++)
			{
				CBlob@ b = server_CreateBlob( "Entities/Materials/MaterialArrows.cfg", team, pos );

				if (b !is null) {
					b.server_SetQuantity(30);
				}
			}
		}
		else if (text_in == "!bombs")
		{
			//  for (int i = 0; i < 3; i++)
			CBlob@ b = server_CreateBlob( "Entities/Materials/MaterialBombs.cfg", team, pos );

			if (b !is null) {
				b.server_SetQuantity(30);
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
			client_AddToChat( "usage: !crate BLOBNAME [DESCRIPTION]", SColor(255, 255, 0,0));
			server_MakeCrate( "", "", 0, team, Vec2f( pos.x, pos.y - 30.0f ) );
		}
		else if (text_in == "!coins")
		{
			player.server_setCoins( player.getCoins() + 100 );
		}
		else if (text_in.substr(0,1) == "!")
		{
			// check if we have tokens
			string[]@ tokens = text_in.split(" ");

			if (tokens.length > 1)
			{
				if (tokens[0] == "!crate")
				{
					int frame = tokens[1] == "catapult" ? 1 : 0;
					string description = tokens.length > 2 ? tokens[2] : tokens[1];
					server_MakeCrate( tokens[1], description, frame, -1, Vec2f( pos.x, pos.y ) );
				}
				else if (tokens[0] == "!team")
				{
					int team = parseInt(tokens[1]);
					if (tokens.size() <= 2) {
						blob.server_setTeamNum(team);
					}
				}				else if (tokens[0] == "!scroll")
				{
					string s = tokens[1];
					for(uint i = 2; i < tokens.length; i++)
						s += " "+tokens[i];
					server_MakePredefinedScroll( pos, s );
				}

				return true;
			}

			// try to spawn an actor with this name !actor
			string name = text_in.substr(1, text_in.size());

			if (server_CreateBlob( name, team, pos ) is null) {
				client_AddToChat( "blob " + text_in + " not found", SColor(255, 255, 0,0));
			}
		}
	}

    return true;
}

void healing( CRules@ this )
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
CBlob@[] GetPlayers( CRules@ this, string PlayersWanted)
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
CPlayer@[] GetPlayersList( CRules@ this, string[] PlayerNames)
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

void lockclasses( CRules@ this )
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


