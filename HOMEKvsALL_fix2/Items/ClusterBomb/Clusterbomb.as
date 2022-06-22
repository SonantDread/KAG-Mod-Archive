// Clusterbomb
#include "Hitters.as";
#include "BombCommon.as";
#include "Explosion.as";

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if(blob.isOnGround() || blob.getShape().isStatic() || blob.isAttached()) return;

	Vec2f velocity = blob.getVelocity();
	velocity.Normalize();

	f32 angle = velocity.Angle();
}

const u16 fuse = 100;


void onInit(CBlob@ this)
{
	// Activatable.as adds the following
	//this.Tag("activatable");
	// this.addCommandID("activate");

	// used by Fabric scripts, Wooden.as, Stone.as
	this.Tag("ignore fall");

	

	// used by Explosion.as
	this.set_f32("explosive_radius", 12.0f); 
	this.set_f32("explosive_damage", 1.5f);  
	this.set_bool("explosive_teamkill", true);

	this.set_f32("map_damage_radius", 16.0f); 
	this.set_f32("map_damage_ratio", 0.8f);
	this.set_bool("map_damage_raycast", false);

	this.set_u8("custom_hitter", Hitters::mine);
	this.set_string("custom_explosion_sound", "KegExplosion.ogg");

	this.SetLightRadius(32.0f);
	this.SetLightColor(SColor(0xFFFFF0AB));
	this.SetLight(false);

	CShape@ shape = this.getShape();
	shape.getVars().waterDragScale = 12.0f;
	shape.getConsts().collideWhenAttached = false;

	this.getCurrentScript().tickIfTag = "exploding";
	
}

void onTick(CBlob@ this)
{
	const u32 timer = this.get_u32("timer");
	const u32 time = getGameTime();
	const s16 remaining = timer - time;


	if(remaining > 0) return;

	Explode(this, this.get_f32("explosive_radius"), this.get_f32("explosive_damage"));
	
	server_CreateBlob("airburst", -1, this.getPosition() + Vec2f(0, -32));
	server_CreateBlob("airburst", -1, this.getPosition() + Vec2f(0, 32));
	server_CreateBlob("airburst", -1, this.getPosition() + Vec2f(-32, 0));
	server_CreateBlob("airburst", -1, this.getPosition() + Vec2f(32, 0));
	
	server_CreateBlob("airburst", -1, this.getPosition() + Vec2f(16, -32));
	server_CreateBlob("airburst", -1, this.getPosition() + Vec2f(16, 32));
	server_CreateBlob("airburst", -1, this.getPosition() + Vec2f(-32, 16));
	server_CreateBlob("airburst", -1, this.getPosition() + Vec2f(32, 16));
	
	server_CreateBlob("airburst", -1, this.getPosition() + Vec2f(-32, -64));
	server_CreateBlob("airburst", -1, this.getPosition() + Vec2f(-64, -32));
	
	server_CreateBlob("airburst", -1, this.getPosition() + Vec2f(32, 64));
	server_CreateBlob("airburst", -1, this.getPosition() + Vec2f(64, 32));
	
	server_CreateBlob("airburst", -1, this.getPosition() + Vec2f(32, -64));
	server_CreateBlob("airburst", -1, this.getPosition() + Vec2f(-64, 32));
	
	server_CreateBlob("airburst", -1, this.getPosition() + Vec2f(-32, 64));
	server_CreateBlob("airburst", -1, this.getPosition() + Vec2f(64, -32));
	

	if(getNet().isServer())
	{
		this.server_Die();
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if(!solid || this.isAttached()) return;

}


void onThisAddToInventory( CBlob@ this, CBlob@ inventoryBlob )
{
	this.doTickScripts = true;
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(cmd != this.getCommandID("activate")) return;

	this.set_u32("timer", getGameTime() + fuse);

	this.Tag("exploding");


	CSprite@ sprite = this.getSprite();
	if(sprite is null) return;

	sprite.SetAnimation("lit");
	sprite.SetEmitSoundPaused(false);
	sprite.PlaySound("SpikesOut.ogg");
	
}

void onDie(CBlob@ this)
{
	this.getSprite().Gib();
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.getShape().isStatic() && blob.isCollidable();
}


bool canBePickedUp(CBlob@ this, CBlob@ blob)
{
	return true;
}