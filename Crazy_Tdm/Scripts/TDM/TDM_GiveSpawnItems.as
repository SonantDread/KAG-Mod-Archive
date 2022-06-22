// spawn resources
// added mats for new classes

// spawn resources
// added mats for new classes

#include "RulesCore.as";
#include "CTF_Structs.as";

const u32 materials_wait = 10; //seconds between free mats
const u32 materials_wait_warmup = 1; //seconds between free mats

//property
const string SPAWN_ITEMS_TIMER = "CTF SpawnItems:";

string base_name() { return "tdm_spawn"; }

/* I don't change structs
namespace tdm_spawn
{

	const u32 Builder = 0x01; = Rockthrower = Warcrafter = Chopper
	const u32 Archer = 0x02; = Crossbowman
	const u32 Knight = 0x04;
	const u32 Medic = 0x08;
	const u32 Spearman = 0x10;
	const u32 Assassin = 0x20;
	const u32 Musketman = 0x40; = Gunner
	const u32 Butcher = 0x80;
	const u32 Demolitionist = 0x100;
	const u32 Weaponthrower = 0x200;
	const u32 Firelancer = 0x400;
	const u32 Warhammer = 0x800;
	const u32 Duelist = 0x1000;

}*/

bool SetMaterials(CBlob@ blob,  const string &in name, const int quantity)
{
	CInventory@ inv = blob.getInventory();

	//avoid over-stacking arrows
	/*
	if (name == "mat_arrows")
	{
		inv.server_RemoveItems(name, quantity);
	}
	*/

	CBlob@ mat = server_CreateBlobNoInit(name);

	if (mat !is null)
	{
		mat.Tag('custom quantity');
		mat.Init();

		mat.server_SetQuantity(quantity);

		if (not blob.server_PutInInventory(mat))
		{
			mat.setPosition(blob.getPosition());
		}
	}

	return true;
}

bool GiveSpawnResources(CRules@ this, CBlob@ blob, CPlayer@ player, CTFPlayerInfo@ info)
{
	bool ret = false;

	if (blob.getName() == "builder" || blob.getName() == "rockthrower" || blob.getName() == "warcrafter" || blob.getName() == "chopper")
	{
		if (this.isWarmup())
		{
			ret = SetMaterials(blob, "mat_wood", 300) || ret;
			ret = SetMaterials(blob, "mat_stone", 100) || ret;

		}
		else
		{
			ret = SetMaterials(blob, "mat_wood", 100) || ret;
			ret = SetMaterials(blob, "mat_stone", 30) || ret;
		}

		if (ret)
		{
			info.items_collected |= ItemFlag::Builder;
		}
	}
	else if (blob.getName() == "archer" || blob.getName() == "crossbowman")
	{
		ret = SetMaterials(blob, "mat_arrows", 30) || ret;

		if (ret)
		{
			info.items_collected |= ItemFlag::Archer;
		}
	}
	else if (blob.getName() == "knight")
	{
		ret = SetMaterials(blob, "mat_bombs", 1) || ret;

		if (ret)
		{
			info.items_collected |= ItemFlag::Knight;
		}
	}
	else if (blob.getName() == "medic")
	{
		ret = SetMaterials(blob, "mat_medkits", 10) || ret;

		if (ret)
		{
			info.items_collected |= 0x08;
		}
	}
	else if (blob.getName() == "spearman")
	{
		ret = SetMaterials(blob, "mat_spears", 10) || ret;
		if (ret)
		{
			info.items_collected |= 0x10;
		}
	}
	else if (blob.getName() == "assassin")
	{
		if (ret)
		{
			info.items_collected |= 0x20;
		}
	}
	else if (blob.getName() == "musketman" || blob.getName() == "gunner")
	{
		ret = SetMaterials(blob, "mat_bullets", 15) || ret;
		if (ret)
		{
			info.items_collected |= 0x40;
		}
	}
	else if (blob.getName() == "butcher")
	{
		if (ret)
		{
			info.items_collected |= 0x80;
		}
	}
	else if (blob.getName() == "demolitionist")
	{
		if (ret)
		{
			info.items_collected |= 0x100;
		}
	}
	else if (blob.getName() == "weaponthrower")
	{
		ret = SetMaterials(blob, "mat_boomerangs", 15) || ret;
		if (ret)
		{
			info.items_collected |= 0x200;
		}
	}
	else if (blob.getName() == "firelancer")
	{
		ret = SetMaterials(blob, "mat_firelances", 5) || ret;
		if (ret)
		{
			info.items_collected |= 0x400;
		}
	}
	else if (blob.getName() == "warhammer")
	{
		if (ret)
		{
			info.items_collected |= 0x800;
		}
	}
	else if (blob.getName() == "duelist")
	{
		if (ret)
		{
			info.items_collected |= 0x1000;
		}
	}

	return ret;
}

//when the player is set, give materials if possible
void onSetPlayer(CRules@ this, CBlob@ blob, CPlayer@ player)
{
	if (!getNet().isServer())
		return;

	if (blob !is null && player !is null)
	{
		RulesCore@ core;
		this.get("core", @core);
		if (core !is null)
		{
			doGiveSpawnMats(this, player, blob, core);
		}
	}
}

//when player dies, unset archer flag so he can get arrows if he really sucks :)
//give a guy a break :)
void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData)
{
	if (victim !is null)
	{
		RulesCore@ core;
		this.get("core", @core);
		if (core !is null)
		{
			CTFPlayerInfo@ info = cast < CTFPlayerInfo@ > (core.getInfoFromPlayer(victim));
			if (info !is null)
			{
				info.items_collected &= ~ItemFlag::Archer;
				info.items_collected &= ~0x08;
				info.items_collected &= ~0x10;
				info.items_collected &= ~0x40;
				info.items_collected &= ~0x200;
				info.items_collected &= ~0x400;
			}
		}
	}
}

bool canGetSpawnmats(CRules@ this, CPlayer@ p, RulesCore@ core)
{
	s32 next_items = getCTFTimer(this, p);
	s32 gametime = getGameTime();

	CTFPlayerInfo@ info = cast < CTFPlayerInfo@ > (core.getInfoFromPlayer(p));

	if (gametime > next_items)		// timer expired
	{
		info.items_collected = 0; //reset available class items
		return true;
	}
	else //trying to get new class items, give a guy a break
	{
		u32 items = info.items_collected;
		u32 flag = 0;

		CBlob@ b = p.getBlob();
		string name = b.getName();
		if (name == "builder" || name == "rockthrower" || name == "warcrafter" || name == "chopper")
			flag = ItemFlag::Builder;
		else if (name == "knight")
			flag = ItemFlag::Knight;
		else if (name == "archer" || name == "crossbowman")
			flag = ItemFlag::Archer;
		else if (name == "medic")
			flag = 0x08;
		else if (name == "spearman")
			flag = 0x10;
		else if (name == "assassin")
			flag = 0x20;
		else if (name == "musketman" || name == "gunner")
			flag = 0x40;
		else if (name == "butcher")
			flag = 0x80;
		else if (name == "demolitionist")
			flag = 0x100;
		else if (name == "weaponthrower")
			flag = 0x200;
		else if (name == "firelancer")
			flag = 0x400;
		else if (name == "warhammer")
			flag = 0x800;
		else if (name == "duelist")
			flag = 0x1000;

		if (info.items_collected & flag == 0)
		{
			return true;
		}
	}

	return false;

}

string getCTFTimerPropertyName(CPlayer@ p)
{
	return SPAWN_ITEMS_TIMER + p.getUsername();
}

s32 getCTFTimer(CRules@ this, CPlayer@ p)
{
	string property = getCTFTimerPropertyName(p);
	if (this.exists(property))
		return this.get_s32(property);
	else
		return 0;
}

void SetCTFTimer(CRules@ this, CPlayer@ p, s32 time)
{
	string property = getCTFTimerPropertyName(p);
	this.set_s32(property, time);
	this.SyncToPlayer(property, p);
}

//takes into account and sets the limiting timer
//prevents dying over and over, and allows getting more mats throughout the game
void doGiveSpawnMats(CRules@ this, CPlayer@ p, CBlob@ b, RulesCore@ core)
{
	if (canGetSpawnmats(this, p, core))
	{
		s32 gametime = getGameTime();

		CTFPlayerInfo@ info = cast < CTFPlayerInfo@ > (core.getInfoFromPlayer(p));

		bool gotmats = GiveSpawnResources(this, b, p, info);
		if (gotmats)
		{
			SetCTFTimer(this, p, gametime + (this.isWarmup() ? materials_wait_warmup : materials_wait)*getTicksASecond());
		}
	}
}

// normal hooks

void Reset(CRules@ this)
{
	//restart everyone's timers
	for (uint i = 0; i < getPlayersCount(); ++i)
		SetCTFTimer(this, getPlayer(i), 0);
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


	RulesCore@ core;
	this.get("core", @core);
	if (core !is null)
	{

		CBlob@[] spots;
		getBlobsByName(base_name(), @spots);
		getBlobsByName("buildershop", @spots);
		getBlobsByName("knightshop", @spots);
		getBlobsByName("archershop", @spots);
		for (uint step = 0; step < spots.length; ++step)
		{
			CBlob@ spot = spots[step];
			CBlob@[] overlapping;
			if (spot !is null && spot.getOverlapping(overlapping))
			{
				string name = spot.getName();
				bool isShop = (name.find("shop") != -1);
				for (uint o_step = 0; o_step < overlapping.length; ++o_step)
				{
					CBlob@ overlapped = overlapping[o_step];
					if (overlapped !is null && overlapped.hasTag("player"))
					{
						if (!isShop || // name.find(overlapped.getName()) != -1) it's no longer works
							(name == "buildershop" && (overlapped.getName() == "builder" || overlapped.getName() == "rockthrower" || overlapped.getName() == "medic" || overlapped.getName() == "warcrafter" || overlapped.getName() == "butcher" || overlapped.getName() == "demolitionist")) ||
							(name == "knightshop" && (overlapped.getName() == "knight" || overlapped.getName() == "spearman" || overlapped.getName() == "assassin" || overlapped.getName() == "chopper" || overlapped.getName() == "warhammer" || overlapped.getName() == "duelist")) ||
							(name == "archershop" && (overlapped.getName() == "archer" || overlapped.getName() == "crossbowman" || overlapped.getName() == "musketman" || overlapped.getName() == "weaponthrower" || overlapped.getName() == "firelancer" || overlapped.getName() == "gunner")))						{
							CPlayer@ p = overlapped.getPlayer();
							if (p !is null)
							{
								doGiveSpawnMats(this, p, overlapped, core);
							}
						}
					}
				}
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
	if (p is null || !p.isMyPlayer()) { return; }

	string propname = getCTFTimerPropertyName(p);
	CBlob@ b = p.getBlob();
	if (b !is null && this.exists(propname))
	{
		s32 next_items = this.get_s32(propname);
		if (next_items > getGameTime())
		{
			string action = (b.getName() == "builder" ? "Go Build" : "Go Fight");
			if (this.isWarmup())
			{
				action = "Prepare for Battle";
			}

			u32 secs = ((next_items - 1 - getGameTime()) / getTicksASecond()) + 1;
			string units = ((secs != 1) ? " seconds" : " second");
			GUI::SetFont("menu");
			GUI::DrawTextCentered(getTranslatedString("Next resupply in {SEC}{TIMESUFFIX}, {ACTION}!")
							.replace("{SEC}", "" + secs)
							.replace("{TIMESUFFIX}", getTranslatedString(units))
							.replace("{ACTION}", getTranslatedString(action)),
			              Vec2f(getScreenWidth() / 2, getScreenHeight() / 3 - 70.0f + Maths::Sin(getGameTime() / 3.0f) * 5.0f),
			              SColor(255, 255, 55, 55));
		}
	}
}
