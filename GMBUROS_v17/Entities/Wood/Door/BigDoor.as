// Swing Door logic

#include "Hitters.as"
#include "FireCommon.as"
#include "MapFlags.as"
#include "ClanCommon.as"

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(false);
	this.getSprite().getConsts().accurateLighting = true;
	
	this.getSprite().SetZ(-100.0f);

	this.set_s16(burn_duration , 300);
	//transfer fire to underlying tiles
	this.Tag(spread_fire_tag);

	// this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().tickFrequency = 0;


	//block knight sword
	this.Tag("blocks sword");

	this.Tag("door");
	this.Tag("blocks water");
	
	this.Tag("place norotate");
	this.set_Vec2f("place offset",Vec2f(0.0f,-4.0f));
	this.Tag("ignore blocking actors");
	
	
	this.set_u8("destruction",0);
	this.Tag("save");
	//this.getShape().SetStatic(false);
	
	if(this.hasTag("force_placement"))this.getShape().SetStatic(true);
	
	this.addCommandID("metal_lock");
	this.addCommandID("gold_lock");
	
	if(isServer())if(this.hasTag("locked"))this.server_SetHealth(this.getInitialHealth()*2);
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(!this.hasTag("locked")){
		if(caller.getCarriedBlob() !is null){
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			if(caller.getCarriedBlob().getName() == "metal_bar"){
				CButton@ button = caller.CreateGenericButton(2, Vec2f(0,-8), this, this.getCommandID("metal_lock"), "Attach Personal Lock", params);
				if(button !is null)button.enableRadius = 24;
			}
			if(caller.getCarriedBlob().getName() == "gold_bar" && getBlobClan(caller) != 0){
				CButton@ button = caller.CreateGenericButton(2, Vec2f(0,-8), this, this.getCommandID("gold_lock"), "Attach Clan Lock", params);
				if(button !is null)button.enableRadius = 24;
			}
		}
	} else {
		string name = " by "+getClanName(getBlobClan(this));
		if(name == " by Nameless")name = "";
		if(this.get_string("player_locked") != "")name = " by "+this.get_string("player_locked");
		CButton@ button = caller.CreateGenericButton(2, Vec2f(0,0), this, this.getCommandID("metal_lock"), "Locked"+name+"\nDamage enough to unlock");
		if(button !is null)button.SetEnabled(false);
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("metal_lock"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			if(getNet().isServer() && !this.hasTag("locked")){
				CBlob@ hold = caller.getCarriedBlob();
				if(hold !is null)if(caller.getPlayer() !is null){
					hold.server_Die();
					this.set_string("player_locked",caller.getPlayer().getUsername());
					this.Sync("player_locked",true);
					this.Tag("locked");
					this.Sync("locked",true);
					this.server_SetHealth(this.getInitialHealth()*2);
				}
			}
		}
	}
	if (cmd == this.getCommandID("gold_lock"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			if(getNet().isServer() && !this.hasTag("locked")){
				CBlob@ hold = caller.getCarriedBlob();
				if(hold !is null)if(caller.getPlayer() !is null){
					hold.server_Die();
					this.set_u16("ClanID",getBlobClan(caller));
					this.Sync("ClanID",true);
					this.Tag("locked");
					this.Sync("locked",true);
					this.server_SetHealth(this.getInitialHealth()*2);
				}
			}
		}
	}
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	if (!isStatic) return;

	this.getSprite().PlaySound("/build_door.ogg");
}

bool isOpen(CBlob@ this)
{
	return !this.getShape().getConsts().collidable;
}

void setOpen(CBlob@ this, bool open, bool faceLeft = false)
{
	CSprite@ sprite = this.getSprite();
	if (open)
	{
		if(this.getShape().isStatic()){
			sprite.SetZ(-100.0f);
			sprite.SetAnimation("open"+this.get_u8("destruction"));
			sprite.SetFacingLeft(faceLeft);   // swing left or right
			Sound::Play("/DoorOpen.ogg", this.getPosition());
		}
		this.getShape().getConsts().collidable = false;
		this.getCurrentScript().tickFrequency = 3;
	}
	else
	{
		if(this.getShape().isStatic()){
			sprite.SetZ(100.0f);
			sprite.SetAnimation("close"+this.get_u8("destruction"));
			Sound::Play("/DoorClose.ogg", this.getPosition());
		}
		this.getShape().getConsts().collidable = true;
		this.getCurrentScript().tickFrequency = 0;
	}

	//TODO: fix flags sync and hitting
	//SetSolidFlag(this, !open);
}

void onTick(CBlob@ this)
{
	
	const uint count = this.getTouchingCount();
	for (uint step = 0; step < count; ++step)
	{
		CBlob@ blob = this.getTouchingByIndex(step);
		if (blob is null) continue;
			
		if (canUnlock(this,blob) && !isOpen(this))
		{
			Vec2f pos = this.getPosition();
			Vec2f other_pos = blob.getPosition();
			Vec2f direction = Vec2f(1, 0);
			direction.RotateBy(this.getAngleDegrees());
			setOpen(this, true, ((pos - other_pos) * direction) < 0.0f);
		}
	}
	// close it
	if (isOpen(this) && canClose(this))
	{
		setOpen(this, false);
	}
	

	if(isServer()){
		if(getGameTime() % 300 == 0){
			if(this.hasTag("locked")){
				if(this.getHealth()<this.getInitialHealth()*2)this.server_SetHealth(this.getHealth() + 1);
			} else {
				if(this.getHealth()<this.getInitialHealth())this.server_SetHealth(this.getHealth() + 1);
			}
			if(this.hasTag("locked")){
				if(this.exists("player_locked")){
					this.Sync("player_locked",true);
				}
				if(this.exists("ClanID")){
					this.Sync("ClanID",true);
				}
			}
		}
	}
	
	if(this.getHealth()<=this.getInitialHealth())
	if(this.hasTag("locked")){
		this.Untag("locked");
		if(isClient())this.getSprite().PlaySound("destroy_ladder.ogg",1.0f);
		if(isServer()){
			if(this.get_string("player_locked") != ""){
				server_CreateBlob("metal_drop",-1,this.getPosition());
			}
			if(getBlobClan(this) > 0){
				server_CreateBlob("gold_drop",-1,this.getPosition());
			}
			this.Sync("locked",true);
		}
		this.set_string("player_locked","");
		this.set_u16("ClanID",0);
	}
}


bool canClose(CBlob@ this)
{
	const uint count = this.getTouchingCount();
	uint collided = 0;
	for (uint step = 0; step < count; ++step)
	{
		CBlob@ blob = this.getTouchingByIndex(step);
		if (blob.isCollidable())
		{
			collided++;
		}
	}
	return collided == 0;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null)
	if (blob.isCollidable())
	{
		this.getCurrentScript().tickFrequency = 3;
	}
}

void onEndCollision(CBlob@ this, CBlob@ blob)
{
	if (blob !is null)
	if (blob.isCollidable())
	{
		if (canClose(this))
		{
			if (isOpen(this))
			{
				setOpen(this, false);
			}
			this.getCurrentScript().tickFrequency = 0;
		}
	}
}


bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return !this.getShape().isStatic();
}

// this is such a pain - can't edit animations at the moment, so have to just carefully add destruction frames to the close animation >_>
f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	CSprite @sprite = this.getSprite();

	if (sprite !is null)
	{
		u8 frame = 0;

		if (this.getHealth() < this.getInitialHealth())
		{
			f32 ratio = (this.getHealth() - damage * getRules().attackdamage_modifier) / this.getInitialHealth();


			if (ratio <= 0.25f)
			{
				frame = 3;
			} else
			if (ratio <= 0.5f)
			{
				frame = 2;
			} else
			if (ratio <= 0.75f)
			{
				frame = 1;
			}
		}
	
		this.set_u8("destruction",frame);
	}

	return damage;
}

void onDie(CBlob @this){
	if(isServer()){
		if(this.hasTag("locked")){
			if(this.exists("player_locked")){
				server_CreateBlob("metal_drop",-1,this.getPosition());
			}
			if(this.exists("ClanID")){
				server_CreateBlob("gold_drop",-1,this.getPosition());
			}
		}
	}
}


bool doesCollideWithBlob(CBlob@ this, CBlob@ blob){
	if (isOpen(this))return false;
	
	return true;
}

bool canUnlock(CBlob@ this, CBlob@ blob){
	
	if(this.hasTag("locked")){
		
		if(this.get_string("player_locked") != ""){
			if(blob.getPlayer() !is null)if(blob.getPlayer().getUsername() == this.get_string("player_locked"))return true;
		} else {
			if(getBlobClan(this) != 0)
			if(getBlobClan(blob) == getBlobClan(this))return true;
		}
		return false;
	}
	
	return blob.getName() == "humanoid";
}