// generic crate
// can hold items in inventory or unpacks to catapult/ship etc.

#include "CrateCommon.as"
#include "MiniIconsInc.as"
#include "Help.as"
#include "Hitters.as"
#include "GenericButtonCommon.as"
#include "KnockedCommon.as"

//property name
const string required_space = "required space";

//proportion of distance allowed (1.0f == overlapping radius, 2.0f = within 1 extra radius)
const float ally_allowed_distance = 2.0f;

void onInit(CBlob@ this)
{
	this.checkInventoryAccessibleCarefully = true;

	this.addCommandID("getin");
	this.addCommandID("getout");

}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	this.animation.frame = (this.animation.getFramesCount()) * (1.0f - (blob.getHealth() / blob.getInitialHealth()));

}


bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.getShape().isStatic();
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return true;
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return false;
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!canSeeButtons(this, caller)) return;

	Vec2f buttonpos(0, 0);
	CInventory@ inv = this.getInventory();
	bool putting = caller.getCarriedBlob() !is null && caller.getCarriedBlob() !is this;
	bool canput = putting && inv.canPutItem(caller.getCarriedBlob());
	CBlob@ sneaky_player;

	if (this.getTeamNum() == caller.getTeamNum())
	{
		if(inv.getItemsCount() > 0){
			for (int i = 0; i < inv.getItemsCount(); i++)
			{
				CBlob@ playerBlob = inv.getItem(i);
				if (playerBlob is caller)
				{
					@sneaky_player = playerBlob;
				}
			}
		}
		if( sneaky_player is caller || inv.getItemsCount() > 3){
				CBitStream params;
				params.write_u16( caller.getNetworkID() );
				CButton@ button = caller.CreateGenericButton( 6, Vec2f(0,0), this, this.getCommandID("getout"), getTranslatedString("Get out"), params);
		}
		if(inv.getItemsCount() < 4 && caller !is sneaky_player){
			CBitStream params;
			params.write_u16( caller.getNetworkID() );
			caller.CreateGenericButton( 4, Vec2f(0,0), this, this.getCommandID("getin"), getTranslatedString("Get inside"), params );
	
		}
	}

	else if (caller.getCarriedBlob() is this ||  inv.getItemsCount() < 4)
	{
		CBitStream params;
		params.write_u16( caller.getNetworkID() );
		caller.CreateGenericButton( 4, Vec2f(0,0), this, this.getCommandID("getin"), getTranslatedString("Get inside"), params );
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{

	if (cmd == this.getCommandID("getin"))
	{
		if (this.getHealth() <= 0)
		{
			return;
		}
		CBlob @caller = getBlobByNetworkID( params.read_u16() );

		if (caller !is null && this.getInventory() !is null) {
			Vec2f velocity = caller.getVelocity();
			this.server_PutInInventory( caller );
			this.setVelocity(velocity);
		}
	}
	else if (cmd == this.getCommandID("getout"))
	{
		CBlob @caller = getBlobByNetworkID( params.read_u16() );
		CInventory@ inv = this.getInventory();
		if (caller !is null) {
			for (int i = 0; i < inv.getItemsCount(); i++){
				this.server_PutOutInventory(inv.getItem(i));
			}
		}
		this.Tag("crate escaped");

		// Attack self to pop out items
		this.server_Hit(this, this.getPosition(), Vec2f(), 100.0f, Hitters::crush, true);
		this.server_Die();
	}
}




void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu)
{
	CInventory@ inv = this.getInventory();
	for (int i = 0; i < inv.getItemsCount(); i++)
	{
		CBlob@ item = inv.getItem(i);
		if (item.hasTag("player"))
		{
			// Get out of there, can't grab players
			forBlob.ClearGridMenus();
		}
	}
}


void onRemoveFromInventory(CBlob@ this, CBlob@ blob)
{
	if (blob.hasTag("player"))
	{
		if (this.hasTag("crate exploded"))
		{
			this.getSprite().PlaySound(getTranslatedString("MigrantSayNo") + ".ogg", 1.0f, blob.getSexNum() == 0 ? 1.0f : 1.5f);
			Vec2f velocity = this.getVelocity();
			if (velocity.x > 0) // Blow them right
			{
				velocity = Vec2f(0.75, -1);
			}
			else if (velocity.x < 0) // Blow them left
			{
				velocity = Vec2f(-0.75, -1);
			}
			else // Go straight up
			{
				velocity = Vec2f(0, -1);
			}
			blob.setVelocity(velocity * 8);
			if (isKnockable(blob))
			{
				setKnocked(blob, 30);
			}
		}
		else if (this.hasTag("crate escaped"))
		{
			Vec2f velocity = this.getOldVelocity();
			if (-5 < velocity.y && velocity.y < 5)
			{
				velocity.y = -5; // Leap out of crate
			}
			Vec2f pos = this.getPosition();
			pos.y -= 5;
			blob.setPosition(pos);
			blob.setVelocity(velocity);

			blob.getSprite().PlaySound(getTranslatedString("MigrantSayHello") + ".ogg", 1.0f, blob.getSexNum() == 0 ? 1.0f : 1.25f);
		}
		else
		{
			blob.setVelocity(this.getOldVelocity());
			if (isKnockable(blob))
			{
				setKnocked(blob, 2);
			}
		}
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
		DumpOutPlayers(this, 0);
	}
	if (isExplosionHitter(customData) || customData == Hitters::keg)
	{
		CInventory@ inv = this.getInventory();

		if (dmg > 50.0f) // inventory explosion
		{
			this.Tag("crate exploded");
			DumpOutPlayers(this, 10);
			// Nearly kill the player
			CInventory@ inv = this.getInventory();
			if (inv.getItemsCount() > 0){

				for (int i = 0; i < inv.getItemsCount(); i++)
				{
					CBlob@ playerBlob = inv.getItem(i);
					hitterBlob.server_Hit(playerBlob, this.getPosition(), Vec2f(),
									  playerBlob.getInitialHealth() * 2 - 0.25f, Hitters::explosion, true);
				}
			}
		}
		else
		{
			if (customData == Hitters::keg)
			{
				dmg = Maths::Max(dmg, this.getInitialHealth() * 2); // Keg always kills crate
			}
			if (inv.getItemsCount() > 0)
			{
				bool should_teamkill = (this.getTeamNum() != hitterBlob.getTeamNum()
										|| customData == Hitters::keg);
				for (int i = 0; i < inv.getItemsCount(); i++){
					hitterBlob.server_Hit(inv.getItem(i), this.getPosition(), Vec2f_zero,
									  dmg / 2, customData, should_teamkill);
				}
			}
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
	string fname = CFileMatcher("/TeamCrate.png").getFirst();
	for (int i = 0; i < 4; i++)
	{
		CParticle@ temp = makeGibParticle(fname, pos, vel + getRandomVelocity(90, 1 , 120), 9, 2 + i, Vec2f(16, 16), 2.0f, 20, "Sounds/material_drop.ogg", 0);
	}
}



CBlob@ getPlayerInside(CBlob@ this)
{
	CInventory@ inv = this.getInventory();
	for (int i = 0; i < inv.getItemsCount(); i++)
	{
		CBlob@ item = inv.getItem(i);
		if (item.hasTag("player"))
			return item;
	}
	return null;
}

bool DumpOutPlayers(CBlob@ this, float pop_out_speed = 5.0f, Vec2f init_velocity = Vec2f_zero)
{

	if (getNet().isServer())
	{
		Vec2f velocity = (init_velocity == Vec2f_zero) ? this.getOldVelocity() : init_velocity;
		CInventory@ inv = this.getInventory();
		u8 target_items_left = 0;
		while (inv !is null && (inv.getItemsCount() > target_items_left))
		{
			CBlob@ item;
			@item = inv.getItem(0);

			float magnitude = (1 - XORRandom(3) * 0.25) * pop_out_speed;
			item.setVelocity(velocity + getRandomVelocity(90, magnitude, 45));


			this.server_PutOutInventory(item);
	
		}
	}
	return true;
}

// SPRITE

// render unpacking time


