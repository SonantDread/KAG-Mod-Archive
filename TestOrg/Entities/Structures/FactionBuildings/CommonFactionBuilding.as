#include "Survival_Structs.as";
#include "Hitters.as";

const string raid_tag = "under raid";
const u32[] teamcolours = {0xff0000ff, 0xffff0000, 0xff00ff00, 0xffff00ff, 0xffff6600, 0xff00ffff, 0xff6600ff, 0xff647160};

void onInit(CBlob@ this)
{
	this.Tag("faction_base");
	
	this.addCommandID("faction_captured");
	this.addCommandID("faction_destroyed");
	this.addCommandID("faction_menu");
	this.addCommandID("faction_menu_button");
	this.addCommandID("faction_player_button");
	this.addCommandID("button_join");
	
	this.set_bool("base_demolition", false);
	this.set_bool("base_alarm", false);
	this.set_bool("base_alarm_manual", false);
	
	AddIconToken("$faction_become_leader$", "FactionIcons.png", Vec2f(16, 16), 0);
	AddIconToken("$faction_resign_leader$", "FactionIcons.png", Vec2f(16, 16), 1);
	AddIconToken("$faction_remove$", "FactionIcons.png", Vec2f(16, 16), 2);
	AddIconToken("$faction_lock$", "FactionIcons.png", Vec2f(16, 16), 3);
	AddIconToken("$faction_coin$", "FactionIcons.png", Vec2f(16, 16), 4);
	AddIconToken("$faction_crate$", "FactionIcons.png", Vec2f(16, 16), 5);
	AddIconToken("$faction_bed$", "FactionIcons.png", Vec2f(16, 16), 6);
	AddIconToken("$faction_alarm$", "FactionIcons.png", Vec2f(16, 16), 7);
	
	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSound("Faction_Alarm.ogg");
	sprite.SetEmitSoundPaused(true);
	sprite.SetEmitSoundSpeed(1.0f);
	sprite.SetEmitSoundVolume(2.0f);
	
	this.SetLight(false);
	this.SetLightRadius(256.0f);
	this.SetLightColor(SColor(255, 255, 0, 0));
}

void onTick(CBlob@ this)
{
	SetMinimap(this);   //needed for under raid check
	if (this.get_bool("base_allow_alarm")) SetAlarm(this, this.get_bool("base_alarm_manual") || this.hasTag(raid_tag));
	
	if (getGameTime() % 30 == 0 && this.get_bool("base_demolition"))
	{
		if (getNet().isServer())
		{
			this.server_Hit(this, this.getPosition(), Vec2f(0, 1), this.getInitialHealth() * 0.05f, Hitters::builder, true);
		}
		
		if (getNet().isClient())
		{	
			this.getSprite().PlaySound("/BuildingExplosion", 0.8f, 0.8f);
			
			Vec2f pos = this.getPosition() - Vec2f((this.getWidth() / 2) - 8, (this.getHeight() / 2) - 8);
			
			for (int y = 0; y < this.getHeight(); y += 16)
			{
				for (int x = 0; x < this.getWidth(); x += 16)
				{
					if (XORRandom(100) < 75) 
					{
						// MakeDustParticle(pos + Vec2f(x + (8 - XORRandom(16)), y + (8 - XORRandom(16))), "woodparts.png");
						ParticleAnimated(CFileMatcher("Smoke.png").getFirst(), pos + Vec2f(x + (8 - XORRandom(16)), y + (8 - XORRandom(16))), Vec2f((100 - XORRandom(200)) / 100.0f, 0.5f), 0.0f, 1.5f, 3, 0.0f, true);
					}
				}
			}
		}
	}
}

void SetMinimap(CBlob@ this)
{
	bool raid = this.hasTag(raid_tag);

	if (raid || this.get_bool("base_alarm"))
	{
		this.SetMinimapOutsideBehaviour(CBlob::minimap_snap);
		this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 1, Vec2f(16, 16));
	}
	else
	{
		this.SetMinimapOutsideBehaviour(CBlob::minimap_arrow);
		
		if (this.hasTag("minimap_large")) this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", this.get_u8("minimap_index"), Vec2f(16, 8));
		else if (this.hasTag("minimap_small")) this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", this.get_u8("minimap_index"), Vec2f(8, 8));
	}

	this.SetMinimapRenderAlways(true);
}

void onChangeTeam(CBlob@ this, const int oldTeam)
{
	CBlob@[] forts;
	getBlobsByTag("faction_base", @forts);

	int newTeam = this.getTeamNum();
	int totalFortCount = forts.length;
	int oldTeamForts = 0;
	int newTeamForts = 0;
	
	CRules@ rules = getRules();
	
	SetNearbyBlobsToTeam(this, oldTeam, newTeam);
	
	for(uint i = 0; i < totalFortCount; i++)
	{
		int fortTeamNum = forts[i].getTeamNum();
	
		if (fortTeamNum == newTeam)
		{
			newTeamForts++;
		}
		else if (fortTeamNum == oldTeam)
		{
			oldTeamForts++;
		}
	}
	
	if (oldTeamForts <= 0)
	{
		if (getNet().isServer())
		{
			CBitStream bt;
			bt.write_s32(newTeam);
			bt.write_s32(oldTeam);
			bt.write_bool(oldTeamForts == 0);

			this.SendCommand(this.getCommandID("faction_captured"), bt);
						
			// for(u8 i = 0; i < getPlayerCount(); i++)
			// {
				// CPlayer@ p = getPlayer(i);
				// if(p !is null && p.getTeamNum() == oldTeam)
				// {
					// p.server_setTeamNum(XORRandom(100)+100);
					// CBlob@ b = p.getBlob();
					// if(b !is null)
					// {
						// b.server_Die();
					// }
				// }
			// }
		}
	}
}

void SetNearbyBlobsToTeam(CBlob@ this, const int oldTeam, const int newTeam)
{
	CBlob@[] teamBlobs;
	this.getMap().getBlobsInRadius(this.getPosition(), 128.0f, @teamBlobs);

	for (uint i = 0; i < teamBlobs.length; i++)
	{
		CBlob@ b = teamBlobs[i];
		if(b.getName() != this.getName() && b.hasTag("change team on fort capture") && (b.getTeamNum() == oldTeam || b.getTeamNum() > 7))
		{
			b.server_setTeamNum(newTeam);
		}
	}
}

void onDie(CBlob@ this)
{
	if (this.hasTag("upgrading")) return;

	CBlob@[] forts;
	getBlobsByTag("faction_base", @forts);

	CRules@ rules = getRules();
	int teamForts = 0; // Current fort is being faction_destroyed
	u8 team = this.getTeamNum();
	
	for(uint i = 0; i < forts.length; i++)
	{
		if (forts[i].getTeamNum() == team) teamForts++;
	}
	
	if (teamForts <= 0)
	{
		if (getNet().isServer())
		{
			CBitStream bt;
			bt.write_s32(team);
		
			this.SendCommand(this.getCommandID("faction_destroyed"), bt);
			
			// for(u8 i = 0; i < getPlayerCount(); i++)
			// {
				// CPlayer@ p = getPlayer(i);
				// if(p !is null && p.getTeamNum() == team)
				// {
					// p.server_setTeamNum(XORRandom(100)+100);
					// CBlob@ b = p.getBlob();
					// if(b !is null)
					// {
						// b.server_Die();
					// }
				// }
			// }
		}
	}
	else
	{
		// print("is gud");
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (this.isOverlapping(caller))
	{
		if (caller.getTeamNum() >= 100 && caller.getTeamNum() < 200 && this.getTeamNum() < 100 && caller.getConfig() != "slave")
		{
			TeamData@ team_data;
			GetTeamData(this.getTeamNum(), @team_data);
			
			if (team_data !is null)
			{
				// bool deserter = caller.getPlayer() !is null && caller.getPlayer().get_u32("teamkick_time") > getGameTime();
				bool recruitment_enabled = team_data.recruitment_enabled;
				bool upkeep_gud = team_data.upkeep + UPKEEP_COST_PLAYER < team_data.upkeep_cap;
			
				string msg = "";
				if (!recruitment_enabled || !upkeep_gud) msg = "\n\nCannot join!\n" + (!recruitment_enabled ? "This faction is not accepting any new members.\n" : "") + (!upkeep_gud ? "Faction's upkeep is too high.\n" : "");
				
				CBitStream params;
				params.write_u16(caller.getNetworkID());
				CButton@ button = caller.CreateGenericButton(11, Vec2f(0, 0), this, this.getCommandID("button_join"), "Join the Faction" + msg, params);
				button.SetEnabled(recruitment_enabled && upkeep_gud);
			}
		}
		
		if (caller.getTeamNum() == this.getTeamNum() && this.getTeamNum() < 100)
		{
			CBitStream params_menu;
			params_menu.write_u16(caller.getNetworkID());
			// CButton@ button_menu = caller.CreateGenericButton(11, Vec2f(14, 5), this, this.getCommandID("faction_menu"), "Faction Management", params_menu);
			CButton@ button_menu = caller.CreateGenericButton(11, Vec2f(1, -8), this, this.getCommandID("faction_menu"), "Faction Management", params_menu);
		}
	}
}

void SetAlarm(CBlob@ this, bool inState)
{
	if (inState == this.get_bool("base_alarm")) return;

	this.set_bool("base_alarm", inState);
	if (getNet().isServer()) this.Sync("base_alarm", true);

	this.SetLight(inState);
							
	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSoundPaused(!inState);
	sprite.RewindEmitSound();
	sprite.PlaySound("LeverToggle.ogg");
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ inParams)
{		
	if (cmd == this.getCommandID("faction_menu"))
	{
		CBlob@ caller = getBlobByNetworkID(inParams.read_u16());
		if (caller !is null)
		{
			CPlayer@ myPly = caller.getPlayer();
			if (myPly !is null && caller.isMyPlayer())
			{
				TeamData@ team_data;
				GetTeamData(this.getTeamNum(), @team_data);
			
				const bool isLeader = team_data.leader_name == myPly.getUsername();
				const bool recruitment_enabled = team_data.recruitment_enabled;
				const bool tax_enabled = team_data.tax_enabled;
				const bool storage_enabled = team_data.storage_enabled;
				const bool lockdown_enabled = team_data.lockdown_enabled;
				const bool base_demolition = this.get_bool("base_demolition");
				const bool base_alarm = this.get_bool("base_alarm");
			
				{
					CGridMenu@ menu = CreateGridMenu(getDriver().getScreenCenterPos() + Vec2f(0.0f, 0.0f), this, Vec2f(3, 3), "Faction Policies");
					if (menu !is null)
					{
						{
							CBitStream params;
							params.write_u16(caller.getNetworkID());
							
							if (team_data.leader_name == myPly.getUsername())
							{
								params.write_u8(0);
								params.write_u8(0);
							
								CGridButton@ butt = menu.AddButton("$faction_resign_leader$", "Renounce Leadership", this.getCommandID("faction_menu_button"), Vec2f(3, 1), params);
								butt.hoverText = "Renounce yourself as the leader of this faction, leaving a spot for someone more experienced.";
								butt.SetEnabled(isLeader);
							}
							else
							{
								params.write_u8(0);
								params.write_u8(1);
							
								CGridButton@ butt = menu.AddButton("$faction_become_leader$", "Claim Leadership", this.getCommandID("faction_menu_button"), Vec2f(3, 1), params);
								butt.hoverText = "Claim leadership of this faction, giving yourself access to various management tools.";
								butt.SetEnabled(team_data.leader_name == "");
							}
						}
						
						{
							CBitStream params;
							params.write_u16(caller.getNetworkID());
							params.write_u8(1);
							params.write_u8(recruitment_enabled ? 0 : 1);
							
							CGridButton@ butt = menu.AddButton("$faction_bed$", (recruitment_enabled ? "Disable" : "Enable") + " Recruitment", this.getCommandID("faction_menu_button"), Vec2f(1, 1), params);
							butt.hoverText = (recruitment_enabled ? "Disallows" : "Allows") + " new people joining your faction.";
							butt.SetEnabled(isLeader);
						}
						
						{
							CBitStream params;
							params.write_u16(caller.getNetworkID());
							params.write_u8(2);
							params.write_u8(tax_enabled ? 0 : 1);
							
							CGridButton@ butt = menu.AddButton("$faction_coin$", (tax_enabled ? "Disable" : "Enable") + " 50% Murder Tax", this.getCommandID("faction_menu_button"), Vec2f(1, 1), params);
							butt.hoverText = (tax_enabled ? "Disallows" : "Allows") + " the leader to claim 50% of your teammates' coins obtained by killing enemies.";
							butt.SetEnabled(isLeader);
						}
						
						// {
							// CBitStream params;
							// params.write_u16(caller.getNetworkID());
							// params.write_u8(3);
							// params.write_u8(storage_enabled ? 0 : 1);
							
							// CGridButton@ butt = menu.AddButton("$faction_crate$", (storage_enabled ? "Disable" : "Enable") + " Remote Storage", this.getCommandID("faction_menu_button"), Vec2f(1, 1), params);
							// butt.hoverText = (storage_enabled ? "Disables" : "Allows") + " remote storage.";
							// butt.SetEnabled(isLeader);
						// }
						
						{
							CBitStream params;
							params.write_u16(caller.getNetworkID());
							params.write_u8(4);
							params.write_u8(lockdown_enabled ? 0 : 1);
							
							CGridButton@ butt = menu.AddButton("$faction_lock$", (lockdown_enabled ? "Disable" : "Enable") + " Lockdown", this.getCommandID("faction_menu_button"), Vec2f(1, 1), params);
							butt.hoverText = (lockdown_enabled ? "Allows" : "Disallows") + " neutrals to pass through your doors.";
							butt.SetEnabled(isLeader);
						}
						
						{
							CBitStream params;
							params.write_u16(caller.getNetworkID());
							params.write_u8(5);
							params.write_u8(base_demolition ? 0 : 1);
							
							CGridButton@ butt = menu.AddButton("$faction_remove$", (base_demolition ? "Cancel" : "Commence") + " demolition of this building", this.getCommandID("faction_menu_button"), Vec2f(1, 1), params);
							butt.hoverText = (base_demolition ? "Cancels" : "Commences") + " demolition of this building, destroying it over course of several seconds.";
							butt.SetEnabled(isLeader);
						}
						
						{
							CBitStream params;
							params.write_u16(caller.getNetworkID());
							params.write_u8(6);
							params.write_u8(base_alarm ? 0 : 1);
							
							CGridButton@ butt = menu.AddButton("$faction_alarm$", (base_alarm ? "Turn off" : "Turn on") + " the emergency mode.", this.getCommandID("faction_menu_button"), Vec2f(1, 1), params);
							butt.hoverText = (base_alarm ? "Turns off" : "Turn on") + " the emergency mode, which alerts your team members and sets off the alarm.";
							butt.SetEnabled(isLeader && this.get_bool("base_allow_alarm"));
						}
						
					}
				}
				
				{
					CPlayer@[] players;
					for (int i = 0; i < getPlayerCount(); i++)
					{
						CPlayer@ p = getPlayer(i);
						if (p.getTeamNum() == this.getTeamNum()) players.push_back(p);
					}
				
					// print("" + players.length);
					int yOffset = ((players.length - 1) * 24) - 48;
					// print("" + yOffset);
				
					CGridMenu@ menu = CreateGridMenu(getDriver().getScreenCenterPos() + Vec2f(192.00f + 16.00f, yOffset), this, Vec2f(5, players.length), "Faction Member Management");
					if (menu !is null)
					{
						{
							for (int i = 0; i < players.length; i++)
							{
								CPlayer@ ply = players[i];
							
								{
									CBitStream params;
									menu.AddTextButton(ply.getUsername(), 0, Vec2f(4, 1), params);
								}
								
								{
									CBitStream params;
									params.write_u8(0);
									params.write_u16(myPly.getNetworkID());
									params.write_u16(ply.getNetworkID());
							
									CGridButton@ butt = menu.AddButton("$faction_remove$", "Kick " + ply.getUsername(), this.getCommandID("faction_player_button"), Vec2f(1, 1), params);
									butt.hoverText = "Remove " + ply.getUsername() + " from your faction.";
									butt.SetEnabled(isLeader || ply.getUsername() == myPly.getUsername());
								}
							}
						}
					}
				}
			}
		}
	}
	else if (cmd == this.getCommandID("faction_menu_button"))
	{
		CBlob@ caller = getBlobByNetworkID(inParams.read_u16());
		const u8 type = inParams.read_u8();
		const u8 data = inParams.read_u8();
	
		if (caller !is null)
		{
			CPlayer@ ply = caller.getPlayer();
		
			if (ply !is null)
			{
				TeamData@ team_data;
				GetTeamData(this.getTeamNum(), @team_data);
			
				// Fuck this bug already, I'm fixing this for like 5th time
				if (team_data is null) return;
				if (ply.getTeamNum() > 6) return;
			
				bool isLeader = ply.getUsername() == team_data.leader_name;
			
				string teamName = getRules().getTeam(ply.getTeamNum()).getName();
				SColor teamColor = getRules().getTeam(ply.getTeamNum()).color;
			
				switch (type)
				{
					case 0:						
						if (data == 0 && isLeader)
						{
							client_AddToChat(ply.getUsername() + " has resigned as the leader of the " + teamName + "!", teamColor);
							team_data.leader_name = "";
						}
						else if (data == 1 && team_data.leader_name == "")
						{
							team_data.leader_name = ply.getUsername();
							client_AddToChat(ply.getUsername() + " has become the leader of " + teamName + "!", teamColor);
						}
						break;
						
					case 1:
						if (isLeader) team_data.recruitment_enabled = data > 0;
						break;
						
					case 2:
						if (isLeader) team_data.tax_enabled = data > 0;
						break;
						
					case 3:
						if (isLeader) team_data.storage_enabled = data > 0;
						break;
						
					case 4:
						if (isLeader) team_data.lockdown_enabled = data > 0;
						break;
						
					case 5:
						if (isLeader)
						{	
							this.set_bool("base_demolition", data > 0);

							if (getNet().isServer()) this.Sync("base_demolition", true);
							if (getNet().isClient())
							{
								client_AddToChat(ply.getUsername() + " has " + (data == 1 ? "commenced" : "cancelled") + " demolition of " + teamName + "'s " + this.getInventoryName() + "!", teamColor);
								
								// if (ply !is null && this.getTeamNum() == ply.getTeamNum() && data > 0) 
								// {
									// client_AddToChat(ply.getUsername() + " has " + (data == 1 ? "commenced" : "cancelled") + " demolition of " + teamName + "'s " + this.getInventoryName() + "!", teamColor);
								// }
							}
						}
						break;
						
					case 6:
						if (isLeader)
						{	
							this.set_bool("base_alarm_manual", data > 0);
							if (getNet().isServer()) this.Sync("base_alarm_manual", true);
						
							if (getNet().isClient())
							{
								SetAlarm(this, data > 0);
								
								// client_AddToChat(ply.getUsername() + " has set off the alarm at one of your bases and requires your assistance!", teamColor);
								
								// CPlayer@ ply = getLocalPlayer();
								if (ply !is null && this.getTeamNum() == ply.getTeamNum() && data > 0) 
								{
									client_AddToChat(ply.getUsername() + " has set off the alarm at one of your bases and requires your assistance!", teamColor);
								}
							}
						}
						break;
				}
			}
		}
	}
	else if (cmd == this.getCommandID("faction_player_button"))
	{
		const u8 type = inParams.read_u8();
		const u16 caller_netid = inParams.read_u16();
		const u16 player_netid = inParams.read_u16();
		
		CPlayer@ caller = getPlayerByNetworkId(caller_netid);
		CPlayer@ ply = getPlayerByNetworkId(player_netid);
	
		CRules@ rules = getRules();
		
		// print("" + player_netid);
	
		
	
		if (rules !is null && ply !is null && getRules() !is null && ply.getTeamNum() < 7)
		{
			CTeam@ team = rules.getTeam(ply.getTeamNum());
			
			if (team is null) return;
		
			TeamData@ team_data;
			GetTeamData(this.getTeamNum(), @team_data);
		
			bool isLeader = caller.getUsername() == team_data.leader_name;

			
			
			SColor teamColor = ply.getTeamNum() < 7 ? team.color : SColor(255, 128, 128, 128);
			
			
			// SColor teamColor = ply.getTeamNum() < getRules().getTeamsNum() ? getRules().getTeam(ply.getTeamNum()).color : SColor(255, 128, 128, 128);
		
			switch (type)
			{
				case 0:
					if (isLeader)
					{
						if (getNet().isServer())
						{
							ply.server_setTeamNum(100 + XORRandom(100));
							if (ply.getBlob() !is null) ply.getBlob().server_Die();
						}
						
						if (getNet().isClient())
						{
							string teamName = rules.getTeam(caller.getTeamNum()).getName();
						
							client_AddToChat(ply.getUsername() + " has been kicked out of the " + teamName + " by " + caller.getUsername() + "!", teamColor);
						}
					}
					break;
			}
		}
	}
	else if (cmd == this.getCommandID("button_join"))
	{
		u16 id;
		if (!inParams.saferead_u16(id)) return;

		CBlob@ blob = getBlobByNetworkID(id);
		
		u8 myTeam = this.getTeamNum();
	
		if (myTeam < 7 && blob !is null && this.isOverlapping(blob) && blob.hasTag("player") && !blob.hasTag("ignore_flags"))
		{
			CPlayer@ p = blob.getPlayer();
			if (p !is null)
			{
				TeamData@ team_data;
				GetTeamData(myTeam, @team_data);
			
				if (p.getTeamNum() >= 100 && team_data !is null)
				{
					// bool deserter = p.get_u32("teamkick_time") > getGameTime();
					bool upkeep_gud = team_data.upkeep + UPKEEP_COST_PLAYER <= team_data.upkeep_cap;
					bool recruitment_enabled = team_data.recruitment_enabled;
					
					if (upkeep_gud && recruitment_enabled)
					{
						this.getSprite().PlaySound("party_join.ogg");
						
						if (getNet().isServer())
						{	
							p.server_setTeamNum(myTeam);
							CBlob@ newPlayer = server_CreateBlob("builder", myTeam, blob.getPosition());
							newPlayer.server_SetPlayer(p);
							
							blob.server_Die();
						}
					}
				}
			}
		}
	}
	

	if (getNet().isClient())
	{
		if (cmd == this.getCommandID("faction_captured"))
		{
			CRules@ rules = getRules();
		
			int newTeam = inParams.read_s32();
			int oldTeam = inParams.read_s32();
			bool defeat = inParams.read_bool();
			
			if (rules is null) return;
			
			// if (!(oldTeam < getRules().getTeamsNum())) return;
			
			if (oldTeam < 7 && newTeam < 7)
			{
				string oldTeamName = rules.getTeam(oldTeam).getName();
				string newTeamName = rules.getTeam(newTeam).getName();
				
				if (defeat)
				{
					client_AddToChat(oldTeamName + " has been defeated by the " + newTeamName + "!", SColor(0xff444444));
					
					CPlayer@ ply = getLocalPlayer();
					int myTeam = ply.getTeamNum();
					
					if (oldTeam == myTeam)
					{
						Sound::Play("FanfareLose.ogg");
					}
					else
					{
						Sound::Play("flag_score.ogg");
					}
				}
				else
				{
					client_AddToChat(oldTeamName + "'s Fortress been faction_captured by the " + newTeamName + "!", SColor(0xff444444));
				}
			}
		}
		else if (cmd == this.getCommandID("faction_destroyed"))
		{
			CRules@ rules = getRules();
		
			int team = inParams.read_s32();
			if (!(team < rules.getTeamsNum())) return;
			
			string teamName = rules.getTeam(team).getName();
		
			client_AddToChat(teamName + " has been defeated!", SColor(0xff444444));
			
			CPlayer@ ply = getLocalPlayer();
			int myTeam = ply.getTeamNum();
			
			if (team == myTeam)
			{
				Sound::Play("FanfareLose.ogg");
			}
			else
			{
				Sound::Play("flag_score.ogg");
			}
		}
	}
}
