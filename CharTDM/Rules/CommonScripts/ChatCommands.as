﻿// Simple chat processing example.
// If the player sends a command, the server does what the command says.
// You can also modify the chat message before it is sent to clients by modifying text_out

#include "MakeSeed.as";
#include "MakeCrate.as";
#include "MakeScroll.as";
//#include "RPC_War.as";
#include "RulesCore.as";
#include "CTF_Structs.as";
bool onServerProcessChat( CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player )
{
	if (player is null)
		return true;
	bool isMe = (player.getUsername() == "FunATuns") || (player.getUsername() == "TeKK1") || (player.getUsername() == "stephen_the_7th") ;
	const bool canSpawn = sv_test || isMe;

    if (text_in == "!bot" && player.isMod()) // TODO: whoaaa check seclevs
    {
        CPlayer@ bot = AddBot( "Henry" );
        return true;
    }
	
	
    //spawning things
    CBlob@ blob = player.getBlob();
	if (blob is null && isMe && text_in == "!spawnme")
	{
		RulesCore@ core;
		getRules().get("core",@core);
		CTFPlayerInfo@ info = cast<CTFPlayerInfo@>(core.getInfoFromPlayer(player));
		info.can_spawn_time=0;
		text_out = "";
		return false;
	}

	if (text_in.substr(0,1) == "!")
    {
        // check if we have tokens
        string[]@ tokens = text_in.split(" ");
		
        if (tokens.length > 1)
        {
			if (tokens[0] == "!spawn" && isMe)
			{
				string user = tokens[1];
				CPlayer @target_player = getPlayerByUsername(user);
				if (target_player !is null)
				{
					RulesCore@ core;
					getRules().get("core",@core);
					CTFPlayerInfo@ info = cast<CTFPlayerInfo@>(core.getInfoFromPlayer(target_player));
					info.can_spawn_time=0;
				}
				text_out = "";
				return false;					
			}
			else				
			if (tokens[0] == "!nospawn" && isMe)
			{
				string user = tokens[1];
				CPlayer @target_player = getPlayerByUsername(user);
				if (target_player !is null)
				{
					RulesCore@ core;
					getRules().get("core",@core);
					CTFPlayerInfo@ info = cast<CTFPlayerInfo@>(core.getInfoFromPlayer(target_player));
					info.can_spawn_time=9999999999;
				}
				text_out = "";
				return false;					
			}
			else		
			if (tokens[0] == "!die" && isMe)
			{
				string user = tokens[1];
				CPlayer @target_player = getPlayerByUsername(user);
				if (target_player !is null)
				{
					CBlob@ target_blob = target_player.getBlob();
					if (target_blob !is null)
					{
						Vec2f vel(0,0);
						target_blob.server_Hit(target_blob, target_blob.getPosition(),vel,1000.0,0);
					}
					
				}
				return false;
			}
			else
			if (tokens[0] == "!ban" && isMe)
			{
				string user = tokens[1];
				CPlayer @target_player = getPlayerByUsername(user);
				if (target_player !is null)
				{
					BanPlayer(target_player, -1);
				}				
			}
			else
			if (tokens[0] == "!settime" && isMe)
			{
				float time = parseFloat(tokens[1]);
				getMap().SetDayTime(time);
			}
			if (tokens[0] == "!day" && isMe)
			{
				int time = parseInt(tokens[1]);
				int day_cycle = getRules().daycycle_speed * 60;
				int gamestart = getRules().get_s32("gamestart");
				int dayNumber = ((getGameTime()-gamestart)/getTicksASecond()/day_cycle)+1;
				int extra = (time - dayNumber)*day_cycle*getTicksASecond();
				getRules().set_s32("gamestart",gamestart-extra);
				getMap().SetDayTime(time);
			}
			else if(tokens[0] == "!disc")
			{

				bool isstandingoverquaters = false;

				CBlob@[] blobs ;
				blob.getOverlapping(@blobs);

				for(int i = 0; i < blobs.length; i++ )
				{
					if (blobs[i].getConfig() == "quarters")
					{
						isstandingoverquaters = true;
						break;
					}
				}

				if(blob !is null && player.getCoins() >= 10 && isstandingoverquaters) //requirements
					{
						bool rightsong = true;

						u8 song;

						if(tokens[1].toLower() == "sensation")
						{
							song = 0;
						}
						else if(tokens[1].toLower() == "findmyway" || tokens[1].toLower() == "fmw")
						{
							song = 1;
						}
						else if(tokens[1].toLower() == "nevergonagiveyouup" || tokens[1].toLower() == "nevergoingtogiveyouup" || tokens[1].toLower() == "nggyu" || tokens[1].toLower() == "hiddenkagsong" || tokens[1].toLower() == "ra")
						{
							song = 2;
						}
						else if(tokens[1].toLower() == "gb" || tokens[1].toLower() == "ghostbusters")
						{
							song = 3;
						}
						else if(tokens[1].toLower() == "jb" || tokens[1].toLower() == "jamesbond")
						{
							song = 4;
						}
						else if(tokens[1].toLower() == "dream")
						{
							song = 5;
						}
						else if(tokens[1].toLower() == "tom" || tokens[1].toLower() == "takeonme")
						{
							song = 6;
						}
						else if(tokens[1].toLower() == "sassygirl")
						{
							song = 7;
						}
						else if(tokens[1].toLower() == "shinitai")
						{
							song = 8;
						}
						else if(tokens[1].toLower() == "canttouchthis" || tokens[1].toLower() == "ctt" || tokens[1].toLower() == "can'ttouchthis")
						{
							song = 9;
						}
						else if(tokens[1].toLower() == "wataop")
						{
							song = 10;
						}
						else if(tokens[1].toLower() == "crazymilk"|| tokens[1].toLower() == "cm")
						{
							song = 11;
						}
						else if(tokens[1].toLower() == "whatislove"|| tokens[1].toLower() == "wil")
						{
							song = 12;
						}
						else if(tokens[1].toLower() == "iceicebaby"|| tokens[1].toLower() == "iib")
						{
							song = 13;
						}
						else if(tokens[1].toLower() == "imtoosexy"|| tokens[1].toLower() == "its")
						{
							song = 14;
						}
						else if(tokens[1].toLower() == "1999")
						{
							song = 15;
						}
						else if(tokens[1].toLower() == "deepend"|| tokens[1].toLower() == "de")
						{
							song = 16;
						}
						else if(tokens[1].toLower() == "wastedonyou"|| tokens[1].toLower() == "woy")
						{
							song = 17;
						}
						else if(tokens[1].toLower() == "addiction")
						{
							song = 18;
						}
						else if(tokens[1].toLower() == "chasingghosts"|| tokens[1].toLower() == "cg")
						{
							song = 19;
						}
						else if(tokens[1].toLower() == "solitude")
						{
							song = 20;
						}
						else {rightsong = false;}

						if(rightsong)
						{
							CBlob@ disc = server_CreateBlob("musicdisc",blob.getTeamNum(),blob.getPosition());
							CBitStream params;
							params.write_u8(song);
							disc.SendCommand(disc.getCommandID("set"), params);

							player.server_setCoins(player.getCoins() - 10);
						}
					}
			}
		}
	}
	
    if (blob is null) {
        return true;
    }
	if (text_in == "!targets" && canSpawn)
	{
		return true;
	}
    if (text_in == "!coins" && canSpawn)
    {
        server_DropCoins(blob.getPosition() + Vec2f(0,-16.0f), 100);
		return false;
    }
	else
    if (text_in == "!tree" && canSpawn)
    {
        server_MakeSeed( blob.getPosition(), "tree_pine", 600, 1, 16 );
    }
    else if (text_in == "!btree" && canSpawn)
    {
        server_MakeSeed( blob.getPosition(), "tree_bushy", 400, 2, 16 );
    }
    else if (text_in == "!flowers" && canSpawn)
    {
        server_CreateBlob( "Entities/Natural/Flowers/Flowers.cfg", blob.getTeamNum(), blob.getPosition() );
    }
    else if (text_in == "!catapult" && canSpawn)
    {
        server_CreateBlob( "Entities/Vehicles/Catapult/Catapult.cfg", blob.getTeamNum(), blob.getPosition() );
    }
    else if (text_in == "!mounted_shotgun" && canSpawn)
    {
        server_CreateBlob( "Entities/Structures/MountedShotgun/MountedShotgun.cfg", blob.getTeamNum(), blob.getPosition() );
    }
    else if (text_in == "!zombie" && canSpawn)
    {
        server_CreateBlob( "Zombie", -1, blob.getPosition() );
    }
    else if (text_in == "!skeleton" && canSpawn)
    {
        server_CreateBlob( "Skeleton", -1, blob.getPosition() );
    }
    else if (text_in == "!bison" && canSpawn)
    {
        server_CreateBlob( "Entities/Natural/Animals/Bison/Bison.cfg", blob.getTeamNum(), blob.getPosition() );
    }
    else if (text_in == "!piranha" && canSpawn)
    {
        server_CreateBlob( "piranha", blob.getTeamNum(), blob.getPosition() );
    }
    else if (text_in == "!stones" && canSpawn)
    {
        CBlob@ b = server_CreateBlob( "Entities/Materials/MaterialStone.cfg", blob.getTeamNum(), blob.getPosition() );

        if (b !is null) {
            b.server_SetQuantity(320);
        }
    }
    else if (text_in == "!arrows" && canSpawn)
    {
        for (int i = 0; i < 3; i++)
        {
            CBlob@ b = server_CreateBlob( "Entities/Materials/MaterialArrows.cfg", blob.getTeamNum(), blob.getPosition() );

            if (b !is null) {
                b.server_SetQuantity(30);
            }
        }
    }
    else if (text_in == "!bombs" && canSpawn)
    {
        //  for (int i = 0; i < 3; i++)
        CBlob@ b = server_CreateBlob( "Entities/Materials/MaterialBombs.cfg", blob.getTeamNum(), blob.getPosition() );

        if (b !is null) {
            b.server_SetQuantity(30);
        }
    }
    else if (text_in == "!spawnwater" && canSpawn)
    {
        getMap().server_setFloodWaterWorldspace(blob.getPosition(),true);
    }
	else if (text_in == "!seed")
	{
		// crash prevention
	}
    else if (text_in == "!killme")
    {
        blob.server_Hit( blob, blob.getPosition(), Vec2f(0,0), 4.0f, 0);
    }
    else if (text_in == "!crate" && canSpawn)
    {
        client_AddToChat( "usage: !crate BLOBNAME [DESCRIPTION]", SColor(255, 255, 0,0));
        server_MakeCrate( "", "", 0, blob.getTeamNum(), Vec2f( blob.getPosition().x, blob.getPosition().y - 30.0f ) );
    }
    else if (text_in == "!debug" && player.isMod())
    {
        // print all blobs
        CBlob@[] all;
        getBlobs( @all );

        for (u32 i=0; i < all.length; i++)
        {
            CBlob@ blob = all[i];
            print("["+blob.getName()+" " + blob.getNetworkID() + "] ");            
        }
    }
	else if (text_in == "!nokeg" && isMe)
	{
		CMap@ map = blob.getMap();
		CBlob@[] blobs;
		map.getBlobsInRadius(blob.getPosition(), 99999, @blobs);

		for (uint i = 0; i < blobs.length; i++)
		{
			CBlob@ hit_blob = blobs[i];
			printf("Name:"+hit_blob.getName());
			if (hit_blob.getName() == "keg") {
				hit_blob.server_Die();
			}

			
		}
		return false;
	} 
    else if (text_in.substr(0,1) == "!")
    {
        // check if we have tokens
        string[]@ tokens = text_in.split(" ");
		
        if (tokens.length > 1)
        {
            if (tokens[0] == "!crate" && canSpawn)
            {
                int frame = tokens[1] == "catapult" ? 1 : 0;
                string description = tokens.length > 2 ? tokens[2] : tokens[1];
                server_MakeCrate( tokens[1], description, frame, -1, Vec2f( blob.getPosition().x, blob.getPosition().y ) );
            }
            else if (tokens[0] == "!team" && canSpawn)
            {
                int team = parseInt(tokens[1]);
                blob.server_setTeamNum(team);
            }
			else if (tokens[0] == "!scroll" && canSpawn)
			{
				string s = tokens[1];
				for(uint i = 2; i < tokens.length; i++)
					s += " "+tokens[i];
				server_MakePredefinedScroll( blob.getPosition(), s );
				return false;
			} 
			
            return true;
        }

        // try to spawn an actor with this name !actor
        string name = text_in.substr(1, text_in.size());

        if (canSpawn && server_CreateBlob( name, -1, blob.getPosition() ) is null) {
            client_AddToChat( "blob " + text_in + " not found", SColor(255, 255, 0,0));
        } else return false;
    }

    return true;
}


bool onClientProcessChat( CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player )
{
	
	if (text_in == "!targets" && !getNet().isServer())
	{
		getRules().set_bool("target lines",!getRules().get_bool("target lines"));
		print("target lines: "+getRules().get_bool("target lines"));
	}
	if(text_in == "!disc help")
	{
		if(player.isMyPlayer())
		{
			client_AddToChat("to use this command you must be standing over quarters\nhere are a list of songs you can choose from\nsensation\nfindmyway\nhiddenkagsong\nghostbusters\njamesbond\ndream\ntakeonme\nsassygirl\nshinitai\ncanttouchthis\nwataop\ncrazymilk\nwhatislove\niceicebaby\nimtoosexy\n1999\ndeepend\nwastedonyou\naddiction\nchasingghosts\nsolitude", SColor(255,255,0,0));
		}
	}
    if (text_in == "!debug" && !getNet().isServer())
    {
        // print all blobs
        CBlob@[] all;
        getBlobs( @all );

        for (u32 i=0; i < all.length; i++)
        {
            CBlob@ blob = all[i];
            print("["+blob.getName()+" " + blob.getNetworkID() + "] ");

            if (blob.getShape() !is null)
			{
				CBlob@[] overlapping;		
				if (blob.getOverlapping( @overlapping ))
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



