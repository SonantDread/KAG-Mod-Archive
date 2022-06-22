// generic crate
// can hold items in inventory or unpacks to catapult/ship etc.

#include "Hitters.as"
#include "GenericButtonCommon.as"

//property name
const string required_space = "required space";

//proportion of distance allowed (1.0f == overlapping radius, 2.0f = within 1 extra radius)
const float ally_allowed_distance = 2.0f;

void onInit(CBlob@ this)
{
	this.checkInventoryAccessibleCarefully = true;

	//this.addCommandID("loadexplosives");
	this.addCommandID("blowup");


	/*u8 frame = 0;
	if (this.exists("frame"))
	{
		frame = this.get_u8("frame");

	}*/
}


bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.getShape().isStatic();
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return (this.getTeamNum() == byBlob.getTeamNum() || this.isOverlapping(byBlob));
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	if (!canSeeButtons(this, forBlob))
		return false;

	if (forBlob.getCarriedBlob() !is null
		&& this.getInventory().canPutItem(forBlob.getCarriedBlob())){
		if(!canLoad(forBlob.getCarriedBlob())){
			return false; 
		}
	}
	if (forBlob.getCarriedBlob() !is null
		&& this.getInventory().canPutItem(forBlob.getCarriedBlob())){
		return true; // OK to put an item in whenever
	}

	if (this.getTeamNum() == forBlob.getTeamNum())
	{
		f32 dist = (this.getPosition() - forBlob.getPosition()).Length();
		f32 rad = (this.getRadius() + forBlob.getRadius());

		if (dist < rad * ally_allowed_distance)
		{
			return true; // Allies can access from further away
		}
	}
	else if (this.isOverlapping(forBlob))
	{
		return true; // Enemies can access when touching
	}

	return false;
}


void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!canSeeButtons(this, caller)) return;

	Vec2f buttonpos(0, 0);

	bool putting = caller.getCarriedBlob() !is null && caller.getCarriedBlob() !is this;
	bool canput = putting && this.getInventory().canPutItem(caller.getCarriedBlob());
	// If there's a player inside and we aren't just dropping in an item

	if (caller.getCarriedBlob() is this)
	{
		CBitStream params;
		params.write_u16( caller.getNetworkID() );
		caller.CreateGenericButton( 4, Vec2f(0,0), this, this.getCommandID("blowup"), getTranslatedString("Blow Up"), params );
	}
	else if (this.getTeamNum() != caller.getTeamNum() && !this.isOverlapping(caller))
	{
		// We need a fake crate inventory button to hint to players that they need to get closer
		// And also so they're unable to discern which crates have hidden players
		if (caller.getCarriedBlob() is null || (putting && !canput))
		{
			CButton@ button = caller.CreateGenericButton(13, Vec2f(), this, this.getCommandID("blowup"), getTranslatedString("Blow Up"));
			button.SetEnabled(false); // they shouldn't be able to actually press it tho
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("blowup"))
	{
		if (this.getHealth() <= 0)
		{
			return;
		}
		CBlob @caller = getBlobByNetworkID( params.read_u16() );

		if (caller !is null && this.getInventory() !is null) {
			// lighting objects
			lightAndEmpty(this, caller);

		}
		this.server_SetHealth(-1.0f);
		this.server_Die();
	}
}


void onAddToInventory(CBlob@ this, CBlob@ blob)
{

	this.getSprite().PlaySound("thud.ogg");
	if (blob.getName() == "keg")
	{
		if (blob.hasTag("exploding"))
		{
			this.Tag("heavy weight");
		}
		else
		{
			this.Tag("medium weight");
		}
	}
}


void onRemoveFromInventory(CBlob@ this, CBlob@ blob)
{
	if (blob.getName() == "keg")
	{
		if (blob.hasTag("exploding") && blob.get_s32("explosion_timer") - getGameTime() <= 0)
		{
			this.server_Hit(this, this.getPosition(), Vec2f(), 100.0f, Hitters::explosion, true);
		}

		this.Untag("medium weight");
		this.Untag("heavy weight"); // TODO: what if there can be multiple kegs?
	}
	if (blob.getName() == "mine")
	{
		this.Untag("medium weight");
		this.Untag("heavy weight"); // TODO: what if there can be multiple kegs?
	}
	if (blob.getName() == "bomb" || blob.getName() == "waterbomb")
	{
		if (blob.hasTag("exploding") && blob.get_s32("explosion_timer") - getGameTime() <= 0)
		{
			this.server_Hit(this, this.getPosition(), Vec2f(), 100.0f, Hitters::explosion, true);
		}

		this.Untag("medium weight");
		this.Untag("heavy weight"); // TODO: what if there can be multiple kegs?
	}

}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	f32 dmg = damage;

	if (customData == Hitters::builder)
	{
		dmg *= 4;
	}
	if (customData == Hitters::saw)
	{
		DumpOutItems(this, 0);
	}
	if (isExplosionHitter(customData) || customData == Hitters::keg)
	{
		CBlob@ emptyBlob;
		if (dmg > 50.0f) // inventory explosion
		{
			lightAndExplode(this, emptyBlob);

		}
		else
		{
			if (customData == Hitters::keg)
			{
				lightAndExplode(this, emptyBlob);
			}
		}
	}
	if (this.getHealth() - (dmg / 2.0f) <= 0.0f)
	{
		if (customData == Hitters::burn || customData == Hitters::fire){
			CBlob@ emptyBlob;
			lightAndEmpty(this, emptyBlob);
		}

	}

	return dmg;
}

void onDie(CBlob@ this)
{
	this.getSprite().Gib();
	Vec2f pos = this.getPosition();
	Vec2f vel = this.getVelocity();
	//custom gibs
	string fname = CFileMatcher("/ExplosiveCrate.png").getFirst();
	for (int i = 0; i < 4; i++)
	{
		CParticle@ temp = makeGibParticle(fname, pos, vel + getRandomVelocity(90, 1 , 120), 9, 2 + i, Vec2f(16, 16), 2.0f, 20, "Sounds/material_drop.ogg", 0);
	}
}


Vec2f crate_getOffsetPos(CBlob@ blob, CMap@ map)
{
	Vec2f halfSize = blob.get_Vec2f(required_space) * 0.5f;

	Vec2f alignedWorldPos = map.getAlignedWorldPos(blob.getPosition() + Vec2f(0, -2)) + (Vec2f(0.5f, 0.0f) * map.tilesize);
	Vec2f offsetPos = alignedWorldPos - Vec2f(halfSize.x , halfSize.y) * map.tilesize;
	return offsetPos;
}


bool DumpOutItems(CBlob@ this, float pop_out_speed = 5.0f, Vec2f init_velocity = Vec2f_zero, bool dump_player = true)
{
	bool dumped_anything = false;
	if (getNet().isClient())
	{
		if (this.getInventory().getItemsCount() > 0)
		{
			this.getSprite().PlaySound("give.ogg");
		}
	}
	if (getNet().isServer())
	{
		Vec2f velocity = (init_velocity == Vec2f_zero) ? this.getOldVelocity() : init_velocity;
		CInventory@ inv = this.getInventory();
		//u8 target_items_left = dump_player ? 0 : 1;
		u8 target_items_left = 0;
		bool skipping_player = false;
		while (inv !is null && (inv.getItemsCount() > target_items_left))
		{
			CBlob@ item;

			@item = inv.getItem(0);
			dumped_anything = true;
			this.server_PutOutInventory(item);
			if (pop_out_speed == 0 || item.getName() == "keg")
			{
				item.setVelocity(velocity);
			}
			else
			{
				float magnitude = (1 - XORRandom(3) * 0.25) * pop_out_speed;
				item.setVelocity(velocity + getRandomVelocity(90, magnitude, 45));
			}
		}
	}
	return dumped_anything;
}


bool canLoad(CBlob@ blob)
{
    const string blobName = blob.getName();
    print(blobName);
    if (blobName == "keg"
        || blobName == "mat_bombs"
        || blobName == "mine"
        || blobName == "minikeg"
        ){
    	return true;
	}

	return false;
}
void lightAndEmpty(CBlob@ this, CBlob@ caller){
	print("light and empty");
	CInventory@ inv = this.getInventory();
	u8 itemcount = inv.getItemsCount();
	for(int i = (itemcount - 1); i >= 0; i--)

	{
		// pop out last items until we can put in player or there's nothing left
		CBlob@ item = inv.getItem(i);
		if (item.getName() == "mat_bombs"){
			if(isServer()){
				item.server_Die();
				@item = server_CreateBlob("bomb", this.getTeamNum(), this.getPosition());
				item.set_s32("bomb_timer", getGameTime() + 90 + XORRandom(30));
				//item.Sync("bomb_timer", true);
			}
		}
		if( item.getName() == "keg" || item.getName() == "minikeg"){
			item.SendCommand(item.getCommandID("activate"));
		}

		this.server_PutOutInventory(item);
		float magnitude = (1 - XORRandom(3) * 0.25) * 5.0f;
		if (caller !is null){
			item.setVelocity(caller.getVelocity() + getRandomVelocity(90, magnitude, 45));
		}
		else{
			item.setVelocity(getRandomVelocity(90, magnitude, 45));
		}
	}
}

void lightAndExplode(CBlob@ this, CBlob@ caller){
	print("light and explode");
	CInventory@ inv = this.getInventory();
	u8 itemcount = inv.getItemsCount();
	/* 
	int explosionFactor;
	if(item.getName() == "mat_bombs"){
	explosionFactor += 2;
	}
	if(item.getName() == "keg"){
	explosionFactor += 16;
	}
	if(item.getName() == "mine"){
	explosionFactor += 8;
	}*/
	for(int i = (itemcount - 1); i >= 0; i--)

	{
		// pop out last items until we can put in player or there's nothing left
		CBlob@ item = inv.getItem(i);
		if (item.getName() == "mat_bombs"){
			if(isServer()){
				item.server_Die();
				@item = server_CreateBlob("bomb", this.getTeamNum(), this.getPosition());
			}
		}
		if(item.getName() == "keg" || item.getName() == "minikeg"){
			item.SendCommand(item.getCommandID("activate"));
		}

		this.server_PutOutInventory(item);
		item.server_SetHealth(-1.0f);
		item.server_Die();

	}
	this.server_Die();

}
