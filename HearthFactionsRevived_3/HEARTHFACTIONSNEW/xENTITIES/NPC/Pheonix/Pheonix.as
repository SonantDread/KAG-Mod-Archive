#include "AnimalConsts.as";

const u8 DEFAULT_PERSONALITY = TAMABLE_BIT | DONT_GO_DOWN_BIT;
const s16 MAD_TIME = 900;

void onInit(CSprite@ this)
{
	this.ReloadSprites(0, 0);
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	f32 xv = blob.getVelocity().x;
	f32 yv = blob.getVelocity().y;
	CMap@ map = blob.getMap();

	if (!blob.isOnMap()) {
		if (Maths::Abs(yv) > 4.0f)
		{
			if ((yv > 6.0f) && blob.get_s16("diving") == 1)
			{
				this.SetAnimation("dive2");
			}
			else if ((yv > 3.0f && blob.get_s16("diving") == 1))
			{
				this.SetAnimation("dive");
			}
			else if (yv > 0.0f)
			{
				this.SetAnimation("flyfall");
			}
			else
			{
				this.SetAnimation("flyjump");
			}
		}
		else
		{
			this.SetAnimation("fly");
		}
	}
	else {
		if (Maths::Abs(yv) > 2.0f)
		{
			if (yv > 0.0f)
			{
				this.SetAnimation("fall");
			}
			else
			{
				this.SetAnimation("jump");
			}
		}
		else if (Maths::Abs(xv) > 1.5f)
		{
			this.SetAnimation("walk");
		}
		else
		{
			this.SetAnimation("idle");
		}
	}
}

void onInit(CBlob@ this)
{
	string[] tags = {"player", "flesh"};
	this.set("tags to eat", tags);
	this.server_setTeamNum(10); //seperate team
	this.set_f32("bite damage", 0.2);
	this.set_u8(personality_property, DEFAULT_PERSONALITY);
	this.set_u8("random move freq", 30);
	this.set_f32(target_searchrad_property, 3000.0f);
	this.set_f32(terr_rad_property, 30.0f);
	this.set_u8(target_lose_random, 200);
	this.getBrain().server_SetActive(false);
	this.getShape().SetRotationsAllowed(false);
	this.set_f32("gib health", -0.0f);
	this.Tag("flesh");
	this.Tag("ignorespikes");
	this.Tag("ignorekegs");
	this.Tag("dooropener");
	this.set_s16("mad timer", 0);
	this.set_s16("direction", 1); //0 left, 1 right
	this.set_s16("diving", 0);
	this.set_s16("setold", 0);
	this.getShape().SetOffset(Vec2f(0, 6));
	this.getCurrentScript().runFlags |= Script::tick_blob_in_proximity;
	this.getCurrentScript().runProximityTag = "player";
	this.getCurrentScript().runProximityRadius = 8000.0f;
	this.getCurrentScript().runFlags |= Script::tick_not_attached;

	AttachmentPoint@[] aps;
	if (this.getAttachmentPoints(@aps))
	{
		for (uint i = 0; i < aps.length; i++)
		{
			AttachmentPoint@ ap = aps[i];
			ap.offsetZ = 10.0f;
		}
	}
}

void onDie(CBlob@ this)
{
	if (isServer()) {
		server_CreateBlob("sunshard",-1,this.getPosition());
		server_DropCoins(this.getPosition(), (100 - XORRandom(20))); }
}

void onTick(CBlob@ this)
{
	f32 xv = this.getVelocity().x;
	f32 yv = this.getVelocity().y;
	f32 x = this.getPosition().x;
	f32 y = this.getPosition().y;
	f32 oldx = 0.0f;
	CMap@ map = this.getMap();
	f32 mapWidth = (map.tilemapwidth * map.tilesize);	
	f32 mapHeight = (map.tilemapheight * map.tilesize);

	if (Maths::Abs(xv) > 1.0f) {
		this.SetFacingLeft(xv < 0); }
	else {
		if (this.isKeyPressed(key_left)) {
			this.SetFacingLeft(true); }
		if (this.isKeyPressed(key_right)) {
			this.SetFacingLeft(false); }
	}

	if (getGameTime() % 100 == 0) {
		CBlob@ spawn = server_CreateBlob("fireorb",-1,this.getPosition());
        if (spawn !is null) {
			Vec2f vel(xv, yv);
			spawn.setVelocity(vel * 4.0);
			spawn.server_setTeamNum(10);
		}
	}

	if (getGameTime() % 173 == 0) {
		CBlob@ spawn = server_CreateBlob("keg",-1,this.getPosition());
        if (spawn !is null) {
			Vec2f vel(xv, yv);
			spawn.setVelocity(vel * 4.0);
			spawn.server_setTeamNum(10);
			spawn.SendCommand(spawn.getCommandID("activate"));
		}
	}

	if ((getGameTime() % 15 == 0) && ((Maths::Abs(xv) + Maths::Abs(yv)) > 1.0f)) {
		if (map is null)   return;
	    map.server_setFireWorldspace(Vec2f(this.getPosition().x + ((XORRandom(5)) * 8) + xv*8, this.getPosition().y + ((XORRandom(5)) * 8) + yv*8), true);
	}

	if (y > (mapHeight * 0.2f))
	{
		if ((getGameTime() % 45 == 0) || (this.get_s16("diving") == 1))
		{
			if ((this.isOnMap()) || (y > (mapHeight * 0.39f)))
			{
				this.set_s16("diving", 0);
			}
			else 
			{
				this.set_s16("diving", 1);
				this.AddForce(Vec2f(0.0f, -150.0f));
			}
		}
		else if (this.get_s16("diving") == 0) {
			this.AddForce(Vec2f(this.getVelocity().x * 20.0f, -2250.0f));
		}
	}

	if ((getGameTime() % 2.5 == 0) && this.get_s16("diving") == 1) {
		CBlob@ spawn = server_CreateBlob("keg",-1,this.getPosition());
        if (spawn !is null) {
			Vec2f vel(xv, yv);
			spawn.setVelocity(vel * 4.0);
			spawn.server_setTeamNum(10);
			spawn.SendCommand(spawn.getCommandID("activate"));
		}
	}

	//unstuck
	if ((getGameTime() % 300 == 0) && (this.isOnMap()) && (Maths::Abs(xv) + Maths::Abs(yv)) < 0.5f) {
		CBlob@ spawn = server_CreateBlob("keg",-1,this.getPosition());
        if (spawn !is null) {
			Vec2f vel(xv+XORRandom(20)-10, yv+XORRandom(20)-10);
			spawn.setVelocity(vel * 8.0);
			spawn.SendCommand(spawn.getCommandID("activate"));
		}
	}


	if (this.get_s16("direction") == 1) {
		if (x < (mapWidth * 0.99f)) {
			this.AddForce(Vec2f(85.0f, 0.0f));
		}
		else{
			this.set_s16("direction", 0);
		}
	}
	if (this.get_s16("direction") == 0) {
		if (x > (mapWidth * 0.01f)) {
			this.AddForce(Vec2f(-85.0f, 0.0f));
		}
		else{
			this.set_s16("direction", 1);
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	return damage;
}

#include "Hitters.as";

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if (blob.hasTag("dead"))
		return false;
	return true;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (blob is null)
		return;
	if (blob.getName() != this.getName() && blob.hasTag("flesh"))
	{
		const f32 vellen = this.getShape().vellen;
		if (vellen > 0.1f)
		{
			Vec2f pos = this.getPosition();
			Vec2f vel = this.getVelocity();
			Vec2f other_pos = blob.getPosition();
			Vec2f direction = other_pos - pos;
			direction.Normalize();
			vel.Normalize();
			if (vel * direction > 0.02f)
			{
				f32 power = Maths::Max(0.02f, 1.0f * vellen);
				this.server_Hit(blob, point1, vel, power, Hitters::fire, false);
			}
		}
	}
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	if (hitBlob !is null && customData == Hitters::fire)
	{
		Vec2f force = velocity * 0.55f;
		if (hitBlob.hasTag("flesh")) {
			force.y -= 400.0f;
		}
		hitBlob.AddForce(force);
	}
}