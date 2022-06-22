// Aphelion \\

#include "DecayCommon.as";
#include "Costs.as"
#include "HallCommon.as"
#include "Requirements.as"
#include "ShopCommon.as"
#include "Knocked.as";

const string pickable_tag = "pickable";

const u16 ATTACK_FREQUENCY = 45;
const f32 ATTACK_DAMAGE = 0.75f;

const int COINS_ON_DEATH = 10;

void onInit(CBlob@ this)
{
	setKnockable( this );
	
	this.set_f32("gib health", -3.0f);
    this.Tag("player");
    this.Tag("flesh");
	this.Tag("migrantbot");
	this.Tag("migrant");
	this.getCurrentScript().tickFrequency = 150; // opt

	this.getShape().SetRotationsAllowed(false);

	this.getBrain().server_SetActive(true);

	this.set_f32("gib health", -3.0f);
    this.Tag("flesh");
	
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
	
	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(6, 6));
	this.set_string("shop description", "DRUG");
	this.set_u8("shop icon", 25);
	
		// CLASS
	this.set_Vec2f("class offset", Vec2f(-6, 0));
	
	{
		ShopItem@ s = addShopItem(this, "Tea", "$tea$", "tea", "Remove drug effect.", true);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystal Shard",1);
	}
	{
		ShopItem@ s = addShopItem(this, "Beer", "$beer$", "beer", "Drink boi, drink..", true);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystal Shard",12);
	}
	{
		ShopItem@ s = addShopItem(this, "Babby Drug", "$babby$", "babby", "Become an stranger and give this candy for the kid.", true);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystal Shard",12);
	}
	{
		ShopItem@ s = addShopItem(this, "Bobomax Drug", "$bobomax$", "bobomax", "You will lose your mind.", true);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystal Shard",10);
	}
	{
		ShopItem@ s = addShopItem(this, "Bobongo Drug", "$bobongo$", "bobongo", "Transform your friends as an slave.", true);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystal Shard",2);
	}
	{
		ShopItem@ s = addShopItem(this, "Boof Drug", "$boof$", "boof", "Try, you will see.", true);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystal Shard",3);
	}
	{
		ShopItem@ s = addShopItem(this, "Crak Drug", "$crak$", "crak", "Did you see him ? He mine all the map with only one pickaxe.", true);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystal Shard",5);
	}	
	{
		ShopItem@ s = addShopItem(this, "Mountain Dew", "$dew$", "dew", "MLG @##?§ DORI#?§T0S J@CK!€ ch@N §N00P D0GG§ DOG!", true);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystal Shard",3);
	}
	{
		ShopItem@ s = addShopItem(this, "Domino Pizza", "$domino$", "domino", "To see life in pink.", true);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystal Shard",12);
	}
	{
		ShopItem@ s = addShopItem(this, "Fiks Drug", "$fiks$", "fiks", "Get heal, better than food (or not).", true);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystal Shard",6);
	}
	{
		ShopItem@ s = addShopItem(this, "Foof Drug", "$foof$", "foof", "Train your hand for give max recoil.", true);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystal Shard",8);
	}
	{
		ShopItem@ s = addShopItem(this, "Fumes Pack", "$fumes$", "fumes", "You asked how get Wing ? With this one you can get it !", true);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystal Shard",3);
	}	
	{
		ShopItem@ s = addShopItem(this, "Covid-19", "$fusk$", "fusk", "Infect people, but don't forget you can be infected you too.");
		AddRequirement(s.requirements, "blob", "whitepage", "Crystal Shard",15);
	}
	{
		ShopItem@ s = addShopItem(this, "Syringe of Gooby ", "$gooby$", "gooby", "Only for people you hate ! (First time they get healed so they will thanks you, but the second phase they will suffer.", true);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystal Shard",15);
	}	
	{
		ShopItem@ s = addShopItem(this, "Valentine Love", "$love$", "love", "Give it to your love.", true);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystal Shard",20);
	}		
	{
		ShopItem@ s = addShopItem(this, "Syringe of Paxilon", "$paxilon$", "paxilon", "Its will be better in lab with steel wall, barricaded door, turret and tesla.", true);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystal Shard",18);
	}		
	/*{
		ShopItem@ s = addShopItem(this, "Poot", "$poot$", "poot", "What you want buy it ? Ask Henry before.");
		AddRequirement(s.requirements, "blob", "whitepage", "Crystal Shard",25);
	}*/	
	{
		ShopItem@ s = addShopItem(this, "Propesko", "$propesko$", "propesko", "This one make you regret. Caution when you move.", true);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystal Shard",9);
	}
	{
		ShopItem@ s = addShopItem(this, "Radpill", "$radpill$", "radpill", "Actually not work but i like get Crystal boi.", true);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystal Shard",1);
	}	
	{
		ShopItem@ s = addShopItem(this, "Syringe of Rippio", "$rippio$", "rippio", "Make him crazy.", true);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystal Shard",19);
	}
	{
		ShopItem@ s = addShopItem(this, "Schisk", "$schisk$", "schisk", "Be an real traumatised soldier.", true);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystal Shard",4);
	}	
	{
		ShopItem@ s = addShopItem(this, "Syringe of Stim", "$stim$", "stim", "Inject ! Run ! Have fun !", true);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystal Shard",2);
	}	
	{
		ShopItem@ s = addShopItem(this, "Vodka", "$vodka$", "vodka", "Na zdorovié !", true);
		AddRequirement(s.requirements, "blob", "whitepage", "Crystal Shard",2);
	}	
	
}


void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");
	}
}


void onTick(CBlob@ this)
{

	if(this.hasTag("idle"))
	{
		this.Untag(pickable_tag);
		this.Sync(pickable_tag, true);
		
		return;
	}
	
	if(!getNet().isServer()) return; //---------------------SERVER ONLY
	
	CBlob@ owner = getOwner(this);
	
	if(owner is null || //no owner
		//or not overlapping owner (or glued somewhere)
		(!this.getShape().isStatic() && !this.isOverlapping(owner)) )
	{
		//SelfDamage( this );
		
		this.Tag(pickable_tag);
		this.Sync(pickable_tag, true);
	}
	else
	{
		this.Untag(pickable_tag);
		this.Sync(pickable_tag, true);
	}
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob )
{
	return (this.getTeamNum() == byBlob.getTeamNum() && !this.getShape().isStatic() && this.hasTag(pickable_tag));
}