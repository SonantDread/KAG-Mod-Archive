// spawn resources

#include "RulesCore.as";
#include "CTF_Structs.as";
#include "CrouchCommon.as";

const u32 materials_wait = 20; //seconds between free mats
const u32 materials_wait_warmup = 40; //seconds between free mats

//property
const string SPAWN_ITEMS_TIMER_BUILDER = "CTF SpawnItems Builder:";
const string SPAWN_ITEMS_TIMER_ARCHER  = "CTF SpawnItems Archer:";

string base_name() { return "tent"; }

bool SetMaterials(CBlob@ blob,  const string &in name, const int quantity, bool drop = false)
{
	CInventory@ inv = blob.getInventory();
	
	//avoid over-stacking arrows
	if (name == "mat_arrows")
	{
		inv.server_RemoveItems(name, quantity);
	}
	
	CBlob@ mat = server_CreateBlobNoInit(name);
	
	if (mat !is null)
	{
		mat.Tag('custom quantity');
		mat.Init();
		
		mat.server_SetQuantity(quantity);
		
		if (drop || not blob.server_PutInInventory(mat))
		{
			mat.setPosition(blob.getPosition());
		}
	}
	
	return true;
}

//when the player is set, give materials if possible
void onSetPlayer(CRules@ this, CBlob@ blob, CPlayer@ player)
{
	if (!getNet().isServer()) return;
	
	if (blob is null) return;
	if (player is null) return;
	
	doGiveSpawnMats(this, player, blob);
}

//when player dies, unset archer flag so he can get arrows if he really sucks :)
//give a guy a break :)
void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData)
{
	if (victim !is null)
	{
		SetCTFTimerArcher(this, victim, 0);
	}
}

string getCTFTimerPropertyNameBuilder(CPlayer@ p)
{
	return SPAWN_ITEMS_TIMER_BUILDER + p.getUsername();
}

s32 getCTFTimerBuilder(CRules@ this, CPlayer@ p)
{
	string property = getCTFTimerPropertyNameBuilder(p);
	if (this.exists(property))
		return this.get_s32(property);
	else
		return 0;
}

void SetCTFTimerBuilder(CRules@ this, CPlayer@ p, s32 time)
{
	string property = getCTFTimerPropertyNameBuilder(p);
	this.set_s32(property, time);
	this.SyncToPlayer(property, p);
}

string getCTFTimerPropertyNameArcher(CPlayer@ p)
{
	return SPAWN_ITEMS_TIMER_ARCHER + p.getUsername();
}

s32 getCTFTimerArcher(CRules@ this, CPlayer@ p)
{
	string property = getCTFTimerPropertyNameArcher(p);
	if (this.exists(property))
		return this.get_s32(property);
	else
		return 0;
}

void SetCTFTimerArcher(CRules@ this, CPlayer@ p, s32 time)
{
	string property = getCTFTimerPropertyNameArcher(p);
	this.set_s32(property, time);
	this.SyncToPlayer(property, p);
}

void GetMatsToReceive(CRules@ this, CPlayer@ p, int &out wood_amount, int &out stone_amount, string modifier="none")
{
	f32 playerCount = CountPlayersInTeam(p.getTeamNum());
	wood_amount = 100;
	stone_amount = 30;
	
	if (modifier=="controlpoint")
	{
			wood_amount = 500;
			stone_amount = 150;

			wood_amount /= (1.05 * playerCount);
			wood_amount *= 0.75f;
			stone_amount /= (1.05 * playerCount);
			stone_amount *= 0.75f;
	}
	else
	{
		if (this.isWarmup()) 
		{
			wood_amount = 1200;
			stone_amount = 500;

			wood_amount /= playerCount;
			stone_amount /= playerCount;
		}
		else
		{
			wood_amount = 500;
			stone_amount = 150;

			wood_amount /= (1.05 * playerCount);
			stone_amount /= (1.05 * playerCount);
		}
	}
}

//takes into account and sets the limiting timer
//prevents dying over and over, and allows getting more mats throughout the game
void doGiveSpawnMats(CRules@ this, CPlayer@ p, CBlob@ b, string modifier="none")
{
	s32 gametime = getGameTime();
	string name = b.getName();
	bool droppingMats = p.hasTag("dropping_mats");

	if (name == "builder" || droppingMats || this.isWarmup()) 
	{
		if (gametime > getCTFTimerBuilder(this, p)) 
		{
			int playerCount = CountPlayersInTeam(p.getTeamNum());
			int wood_amount = 100;
			int stone_amount = 30;
			
			if (modifier=="controlpoint")
				GetMatsToReceive(this, p, wood_amount, stone_amount, "controlpoint");
			else
				GetMatsToReceive(this, p, wood_amount, stone_amount);
			
			bool did_give_wood = SetMaterials(b, "mat_wood", wood_amount, droppingMats);
			bool did_give_stone = SetMaterials(b, "mat_stone", stone_amount, droppingMats);

			if (!this.isWarmup())
			{
				this.set_u32(p.getUsername() + "matdrops", this.get_u32(p.getUsername() + "matdrops") + 1);

				if (this.hasTag("track_stats"))
				{
					tcpr("MatDrop " + p.getUsername() + " " + getGameTime());
				}
				p.setAssists(p.getAssists() + 1);
			}
			
			if (did_give_wood || did_give_stone)
			{
				SetCTFTimerBuilder(this, p, gametime + (this.isWarmup() ? materials_wait_warmup : materials_wait)*getTicksASecond());
			}
		}
	} 
	else if (name == "archer") 
	{
		if (gametime > getCTFTimerArcher(this, p)) 
		{
			if (SetMaterials(b, "mat_arrows", 30)) 
			{
				SetCTFTimerArcher(this, p, gametime + (this.isWarmup() ? materials_wait_warmup : materials_wait)*getTicksASecond());
			}
		}
	}
	p.Untag("dropping_mats");
}

// normal hooks

void Reset(CRules@ this)
{
	//restart everyone's timers
	for (uint i = 0; i < getPlayersCount(); ++i) {
		SetCTFTimerBuilder(this, getPlayer(i), 0);
		SetCTFTimerArcher(this, getPlayer(i), 0);
	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	s32 next_add = getGameTime() + (this.isWarmup() ? materials_wait_warmup : materials_wait)*getTicksASecond();

	if (next_add < getCTFTimerArcher(this, player) || next_add < getCTFTimerBuilder(this, player))
	{
		SetCTFTimerBuilder(this, player, getGameTime());
		SetCTFTimerArcher(this, player, getGameTime());
	}
}

void onRestart(CRules@ this)
{
	Reset(this);
}

void onInit(CRules@ this)
{
	Reset(this);
}

void onTick(CRules@ this)
{
	if (!getNet().isServer())
		return;
	
	s32 gametime = getGameTime();
	
	if ((gametime % 15) != 5)
		return;
	
	if (this.isWarmup()) 
	{
		// during building time, give everyone resupplies no matter where they are
		for (int i = 0; i < getPlayerCount(); i++) 
		{
			CPlayer@ player = getPlayer(i);
			CBlob@ blob = player.getBlob();
			if (blob !is null) 
			{
				doGiveSpawnMats(this, player, blob);
			}
		}
	} 
	else 
	{
		CBlob@[] spots;
		getBlobsByName(base_name(),   @spots);
		getBlobsByName("ballista",	@spots);
		getBlobsByName("outpost",	@spots);
		getBlobsByName("warboat",	 @spots);
		getBlobsByName("buildershop", @spots);
		getBlobsByName("archershop",  @spots);
		// getBlobsByName("knightshop",  @spots);
		for (uint step = 0; step < spots.length; ++step) 
		{
			CBlob@ spot = spots[step];
			if (spot is null) continue;

			CBlob@[] overlapping;
			if (!spot.getOverlapping(overlapping)) continue;

			string name = spot.getName();
			bool isShop = (name.find("shop") != -1);

			for (uint o_step = 0; o_step < overlapping.length; ++o_step) 
			{
				CBlob@ overlapped = overlapping[o_step];
				if (overlapped is null) continue;
				
				if (!overlapped.hasTag("player")) continue;
				CPlayer@ p = overlapped.getPlayer();
				if (p is null) continue;
				
				if (isShop && name.find(overlapped.getName()) == -1) continue; // NOTE(hobey): builder doesn't get wood+stone at archershop, archer doesn't get arrows at buildershop
					
				doGiveSpawnMats(this, p, overlapped);
			}
		}

	}
}

// render gui for the player
void onRender(CRules@ this)
{
	if (g_videorecording || this.isGameOver())
		return;
	
	CPlayer@ p = getLocalPlayer();
	if (p is null || !p.isMyPlayer()) return;
	
	CBlob@ b = p.getBlob();
	if (b is null) return;
	
	string name = b.getName();
	
	string propname = getCTFTimerPropertyNameBuilder(p);
	if (this.exists(propname)) 
	{
		s32 next_items = this.get_s32(propname);
		
		GUI::SetFont("menu");
		
		u32 secs = ((next_items - 1 - getGameTime()) / getTicksASecond()) + 1;
		string units = ((secs != 1) ? " seconds" : " second");
		
		string need_to_switch_string = "";
		if (name != "builder") need_to_switch_string = getTranslatedString("and switch to builder ");
		
		SColor color = SColor(200, 135, 185, 45);
		int wood_amount = 100;
		int stone_amount = 30;

		int cp_wood_amount = 100;
		int cp_stone_amount = 30;
		
		GetMatsToReceive(this, getLocalPlayer(), wood_amount, stone_amount);
		GetMatsToReceive(this, getLocalPlayer(), cp_wood_amount, cp_stone_amount, "controlpoint");

		string text = getTranslatedString("Go to a builder shop or a respawn point {SWITCH} to get a resupply of {WOOD} wood and {STONE} stone.\nAt control point: {CP_WOOD} wood and {CP_STONE} stone.")
			.replace("{SWITCH}", need_to_switch_string)
			.replace("{WOOD}", "" + wood_amount)
			.replace("{STONE}", "" + stone_amount)
			.replace("{CP_WOOD}", "" + cp_wood_amount)
			.replace("{CP_STONE}", "" + cp_stone_amount);

		Vec2f offset = Vec2f(20, 64);
		float x = getScreenWidth() / 3 + offset.x;
		float y = getScreenHeight() - offset.y;
		
		if (next_items > getGameTime())
		{
			// color = SColor(255, 255, 55, 55);
			color = SColor(255, 255, 55, 55);
			
			text = getTranslatedString("Next resupply of {WOOD} wood and {STONE} stone in {SEC}{TIMESUFFIX}.\nAt control point: {CP_WOOD} wood and {CP_STONE} stone.")
				.replace("{SEC}", "" + secs)
				.replace("{TIMESUFFIX}", getTranslatedString(units))
				.replace("{WOOD}", "" + wood_amount)
				.replace("{STONE}", "" + stone_amount)
				.replace("{CP_WOOD}", "" + cp_wood_amount)
				.replace("{CP_STONE}", "" + cp_stone_amount);

			x = getScreenWidth() / 2;
			y = getScreenHeight() / 3 - 70.0f;
		}
		
		GUI::DrawTextCentered(text, Vec2f(x, y), color);
	}
	
	// TODO(hobey): maybe only draw the cooldown/helptext for archer if low on arrows?
	propname = getCTFTimerPropertyNameArcher(p);
	if (name == "archer" && this.exists(propname))
	{
		s32 next_items = this.get_s32(propname);
		
		GUI::SetFont("menu");
		
		u32 secs = ((next_items - 1 - getGameTime()) / getTicksASecond()) + 1;
		string units = ((secs != 1) ? " seconds" : " second");
		
		SColor color = SColor(200, 135, 185, 45);
		int wood_amount = 100;
		int stone_amount = 30;
		if (this.isWarmup())
		{
			wood_amount = 300;
			stone_amount = 100;
		}
		string text = getTranslatedString("Go to an archer shop or a respawn point to get a resupply of 30 arrows.");

		Vec2f offset = Vec2f(20, 96);
		float x = getScreenWidth() / 3 + offset.x;
		float y = getScreenHeight() - offset.y;
		
		if (next_items > getGameTime())
		{
			// color = SColor(255, 255, 55, 55);
			color = SColor(255, 255, 55, 55);
			
			text = getTranslatedString("Next resupply of 30 arrows in {SEC}{TIMESUFFIX}.")
				.replace("{SEC}", "" + secs)
				.replace("{TIMESUFFIX}", getTranslatedString(units));

			x = getScreenWidth() / 2;
			y = getScreenHeight() / 3 - 16.0f;
		}
		
		GUI::DrawTextCentered(text, Vec2f(x, y), color);
	}
}

int CountPlayersInTeam(int teamNum) {
    int count = 0;

    for (int i=0; i < getPlayerCount(); i++) {
        CPlayer@ p = getPlayer(i);
        if (p is null) continue;

        if (p.getTeamNum() == teamNum)
            count++;
    }

    return count;
}