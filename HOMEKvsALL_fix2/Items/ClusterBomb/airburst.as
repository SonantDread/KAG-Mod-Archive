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

	this.ResetTransform();
	this.RotateBy(-angle - 90, Vec2f_zero);
}

const u16 fuse = 145;


// todo: standardize spark colors and light color on lit fuse
const SColor[] colors = {
SColor(0xFFF3AC5C),         // ARGB(255, 243, 172,  92);
SColor(0xFFF3AC5C),         // weighted
SColor(0xFFDB5743),         // ARGB(255, 219,  87,  67);
SColor(0xFFDB5743),         // weighted
SColor(0xFF7E3041)};        // ARGB(255, 126,  48,  65);

void onInit(CBlob@ this)
{
	// Activatable.as adds the following
	//this.Tag("activatable");
	// this.addCommandID("activate");

	// used by Fabric scripts, Wooden.as, Stone.as
	this.Tag("ignore fall");

	

	// used by Explosion.as
	this.set_f32("explosive_radius", 16.0f); 
	this.set_f32("explosive_damage", 1.0f);  
	this.set_bool("explosive_teamkill", true);

	this.set_f32("map_damage_radius", 16.0f); 
	this.set_f32("map_damage_ratio", 0.8f);
	this.set_bool("map_damage_raycast", false);

	this.set_u8("custom_hitter", Hitters::mine);
	this.set_string("custom_explosion_sound", "KegExplosion.ogg");


	CShape@ shape = this.getShape();
	shape.getVars().waterDragScale = 12.0f;
	shape.getConsts().collideWhenAttached = false;
	this.getShape().SetGravityScale(0.0f);
	this.getCurrentScript().tickIfTag = "exploding";
	this.server_SetTimeToDie(0.2);
}

void onTick(CBlob@ this)
{
	

}


void onDie(CBlob@ this)
{
	Explode(this, this.get_f32("explosive_radius"), this.get_f32("explosive_damage"));
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.getShape().isStatic() && blob.isCollidable();
}


bool canBePickedUp(CBlob@ this, CBlob@ blob)
{
	return false;
}