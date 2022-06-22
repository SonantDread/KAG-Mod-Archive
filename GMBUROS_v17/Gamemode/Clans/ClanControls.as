
#include "GetPlayerData.as"
#include "ClanCommon.as"

void onInit(CBlob@ this)
{
	this.addCommandID("clan_kick");
	this.addCommandID("clan_invite");
	this.addCommandID("clan_join");
	this.addCommandID("clan_decline");
	this.addCommandID("clan_level_up");
}

void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu)
{
	if(this.getPlayer() !is getLocalPlayer())return;
	if(this.getPlayer() is null)return;
	Vec2f pos = Vec2f(getDriver().getScreenWidth()-24*5-2,0);
	
	
	int clanID = getBlobClan(this);
	int Level = 0;
	string name = "Clanless";
	if(clanID != 0){
		name = getClanName(clanID);
		Level = getClanLevel(clanID);
	}
	
	CGridMenu@ header = CreateGridMenu(pos, this, Vec2f(3, 1), "");
	if (header !is null){
		header.SetCaptionEnabled(false);
		
		CGridButton@ clan = header.AddTextButton(name, Vec2f(3,1));
		if(clan !is null){
			if(clanID == 0)clan.hoverText = "To start a clan; If you have 5 gold bars in your inventory, type:\n\n    !clan NameOfClan\n\nIf the server reloads or restarts while your clan has less than 3 members, it will automatically disband.";
		}
	}
	
	int height = Level;
	if(height < 1)height = 1;
	Vec2f banner_pos = Vec2f(getDriver().getScreenWidth()-24*1,height*24+2);
	CGridMenu@ banner = CreateGridMenu(banner_pos, this, Vec2f(1, height), "");
	if (banner !is null){
		banner.SetCaptionEnabled(false);
		CBitStream params;
		CGridButton@ but = banner.AddButton("ClanBanner.png", Level, Vec2f(24,24*height), "", this.getCommandID("colour_swap"), Vec2f(1,height),params);
		if(but !is null){
			but.clickable = false;
			but.deleteAfterClick = false;
			but.SetHoverText("Current clan level: "+Level+"\n\n"+"Current max members: "+(Level*2+1)+"  ");
		}
	}
	
	
	if(clanID == 0){ //If we're not in a clan, search for invitations
	
		int[] ClanOffers;
		CBlob@[] invites;	 
		getBlobsByName("clan_invitation",invites);
		for (uint i = 0; i < invites.length; i++){
			CBlob@ b = invites[i];
			if(b !is null){
				if(b.get_string("username") == this.getPlayer().getUsername()){
					if(getBlobClan(b) == 0){
						ClanOffers.push_back(b.get_u16("clan_id"));
					}
				}
			}
		}
	
		if(ClanOffers.length > 0){
			int l = ClanOffers.length;
			CGridMenu@ invites = CreateGridMenu(pos+Vec2f(24,2+24*l+48), this, Vec2f(4, l), "Clan Invites");
			if (invites !is null){
				for(int i = 0;i < ClanOffers.length;i++){
					invites.AddTextButton(getClanName(ClanOffers[i]), Vec2f(2,1));
					CBitStream params;
					params.write_u16(ClanOffers[i]);
					invites.AddButton("ClanIcons.png", 2, "Join "+getClanName(ClanOffers[i]), this.getCommandID("clan_join"),params);
					invites.AddButton("ClanIcons.png", 0, "Decline Invite", this.getCommandID("clan_decline"),params);
				}
			}
		}
	
	} else { //We're in a clan!
	
		if(Level < 3){
			CGridMenu@ levelUp = CreateGridMenu(Vec2f(getDriver().getScreenWidth()-24*1,height*48+32+2), this, Vec2f(1, 1), "");
			if (levelUp !is null){
				levelUp.SetCaptionEnabled(false);
				
				CGridButton@ levelUpButton = levelUp.AddButton("ClanIcons.png", 3, "Level Up", this.getCommandID("clan_level_up"));
				if(levelUpButton !is null){
					if(Level <= 1)levelUpButton.hoverText = "Level up cost: 100 Gold Bars and a Weak Gem";
					if(Level == 2)levelUpButton.hoverText = "Level up cost: 200 Gold Bars and a Green Gem";
				}
			}
		}
	
		string[] Members = getClanMembers(clanID);
		int l = Members.length;
		bool amLeader = false;
		
		CGridMenu@ members = CreateGridMenu(pos+Vec2f(0,2+24*l+48), this, Vec2f(3, l), "Members");
		if (members !is null){
			for(int i = 0;i < Members.length;i++){
				if(getClanLeader(clanID) == Members[i]){
					
					
					CGridButton@ member = members.AddTextButton("Leader:\n"+Members[i], Vec2f(2,1));
					if(member !is null){
						if(getPlayerByUsername(Members[i]) is null){
							member.SetEnabled(false);
						} else {
							member.SetSelected(3);
						}
					}
					CBitStream params;
					params.write_string(Members[i]);
					if(getPlayerByUsername(Members[i]) is getLocalPlayer()){
						amLeader = true;
						CGridButton@ but = members.AddButton("ClanIcons.png", 1, "Leave Clan", this.getCommandID("clan_kick"),params);
					} else {
						CGridButton@ but = members.AddButton("ClanIcons.png", 1, "MUTINY", this.getCommandID("clan_kick"),params);
						if(but !is null)but.SetEnabled(false);
					}
				}
			}
			
			for(int i = 0;i < Members.length;i++){
				if(getClanLeader(clanID) != Members[i]){
					CGridButton@ member = members.AddTextButton(Members[i], Vec2f(2,1));
					if(member !is null){
						if(getPlayerByUsername(Members[i]) is null){
							member.SetEnabled(false);
						} else {
							if(getPlayerByUsername(Members[i]) is getLocalPlayer())member.SetSelected(2);
							else member.SetSelected(1);
						}
					}
					CBitStream params;
					params.write_string(Members[i]);
					if(getPlayerByUsername(Members[i]) is getLocalPlayer()){
						members.AddButton("ClanIcons.png", 1, "Leave Clan", this.getCommandID("clan_kick"),params);
					} else {
						CGridButton@ but = members.AddButton("ClanIcons.png", 1, "Kick "+Members[i], this.getCommandID("clan_kick"),params);
						if(but !is null){
							if(!amLeader)but.SetEnabled(false);
						}
					}
					
				}
			}
		}
		
		if(amLeader){
			string[] NearbyClanless;
			CBlob@[] humanoids;	 
			getBlobsByName("humanoid",humanoids);
			for (uint i = 0; i < humanoids.length; i++){
				CBlob@ b = humanoids[i];
				if(b !is null){
					if(b.getDistanceTo(this) < 320.0f){
						if(getBlobClan(b) == 0){
							if(b.getPlayer() !is null)NearbyClanless.push_back(b.getPlayer().getUsername());
						}
					}
				}
			}
			
			if(NearbyClanless.length > 0){
				int nc = NearbyClanless.length;
				CGridMenu@ sendInvites = CreateGridMenu(pos+Vec2f(0,2+24*nc+48*l+96), this, Vec2f(3, nc), "Nearby Clanless");
				if (sendInvites !is null){
					for(int i = 0;i < NearbyClanless.length;i++){
						sendInvites.AddTextButton(NearbyClanless[i], Vec2f(2,1));
						CBitStream params;
						params.write_string(NearbyClanless[i]);
						sendInvites.AddButton("ClanIcons.png", 2, "Invite "+NearbyClanless[i], this.getCommandID("clan_invite"),params);
					}
				}
			} else {
				CGridMenu@ sendInvites = CreateGridMenu(pos+Vec2f(0,2+24+48*l+96), this, Vec2f(3, 1), "Nearby Clanless");
				if (sendInvites !is null){
					sendInvites.AddTextButton("No one nearby\nto invite.", Vec2f(3,1));
				}
			}
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("clan_kick"))
	{
		string name = params.read_string();
		int clanID = getBlobClan(this);
		if(clanID != 0){
			
			
			string[]@ Members = getClanMembers(clanID);
			for(int i = 0;i < Members.length;i++){
				if(Members[i] == name){
					Members.removeAt(i);
					break;
				}
			}
			CBlob @clan = getClan(clanID);
			if(clan !is null){
				clan.Tag("force_update_listing");
				if(this.getPlayer() !is null && this.getPlayer().getUsername() == name){
					client_AddToChat(name+" has left "+clan.get_string("name")+"!", SColor(255,96,64,200));
				} else {
					client_AddToChat(name+" has been kicked from "+clan.get_string("name")+"!", SColor(255,200,64,96));
				}
			}
		}
	}
	
	if (cmd == this.getCommandID("clan_invite"))
	{
		string name = params.read_string();
		int clanID = getBlobClan(this);
		if(clanID != 0){
			if(isServer()){
				bool found = false;
				
				CBlob@[] invites;	 
				getBlobsByName("clan_invitation",invites);
				for (uint i = 0; i < invites.length; i++){
					CBlob@ b = invites[i];
					if(b !is null){
						if(b.get_string("username") == name){
							if(clanID == b.get_u16("clan_id")){
								found = true;
							}
						}
					}
				}
				
				if(!found){
					CBlob @invite = server_CreateBlob("clan_invitation",-1,Vec2f(0,0));
					if(invite !is null){
						invite.set_string("username",name);
						invite.set_u16("clan_id",clanID);
					}
				}
			}
		}
	}
	
	if (cmd == this.getCommandID("clan_decline"))
	{
		int clanID = params.read_u16();
		if(clanID != 0){
			if(isServer()){
				CBlob@[] invites;	 
				getBlobsByName("clan_invitation",invites);
				for (uint i = 0; i < invites.length; i++){
					CBlob@ b = invites[i];
					if(b !is null && this.getPlayer() !is null){
						if(b.get_string("username") == this.getPlayer().getUsername()){
							if(clanID == b.get_u16("clan_id")){
								b.server_Die();
							}
						}
					}
				}
			}
		}
	}
	
	if (cmd == this.getCommandID("clan_join"))
	{
		int clanID = params.read_u16();
		if(clanID != 0)
		if(getBlobClan(this) == 0)
		if(this.getPlayer() !is null){
			if(isServer()){
				CBlob@[] invites;	 
				getBlobsByName("clan_invitation",invites);
				for (uint i = 0; i < invites.length; i++){
					CBlob@ b = invites[i];
					if(b !is null){
						if(b.get_string("username") == this.getPlayer().getUsername()){
							if(clanID == b.get_u16("clan_id")){
								b.server_Die();
							}
						}
					}
				}
			}
			addClanMember(clanID, this.getPlayer().getUsername());
		}
	}
	
	if (cmd == this.getCommandID("clan_level_up"))
	{
		int clanID = getBlobClan(this);
		if(clanID != 0){
			if(isServer()){
				CBlob @clan = getClan(clanID);
				if(clan !is null){
					int level = clan.get_u8("Level");
					
					if(level <= 1){
						if(this.hasBlob("gold_bar",100) && this.hasBlob("weak_gem",1)){
							this.TakeBlob("gold_bar",100);
							this.TakeBlob("weak_gem",1);
							clan.set_u8("Level",2);
						}
					}
					if(level == 2){
						if(this.hasBlob("gold_bar",200) && this.hasBlob("gem",1)){
							this.TakeBlob("gold_bar",200);
							this.TakeBlob("gem",1);
							clan.set_u8("Level",3);
						}
					}
					
					clan.Sync("Level",true);
				}
			}
		}
	}
}