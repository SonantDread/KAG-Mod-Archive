#include "AnimalConsts.as";

const u8 DEFAULT_PERSONALITY = TAMABLE_BIT | DONT_GO_DOWN_BIT;
const s16 MAD_TIME = 250;

void onInit(CSprite@ this)
{
	this.ReloadSprites(0, 0);
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	if (!blob.hasTag("dead")) {
		f32 x = blob.getVelocity().x;
		f32 y = blob.getVelocity().y;

		if (Maths::Abs(y) > 0.5f) {
			if (y > 0.0f) {
				this.SetAnimation("fall");
			}
			else {
				this.SetAnimation("jump");
			}
		}
		else if (Maths::Abs(x) > 0.3f) {
			this.SetAnimation("walk");
		}
		else {
			this.SetAnimation("idle");
		}
	}
	else {
		this.SetAnimation("dead");
		this.getCurrentScript().runFlags |= Script::remove_after_this;
	}
}

void onInit(CBlob@ this)
{
	string[] tags = {"player", "flesh"};
	this.set("tags to eat", tags);
	this.server_setTeamNum(10); //seperate team
	this.set_f32("bite damage", 0.25f);
	this.set_u8(personality_property, DEFAULT_PERSONALITY);
	this.set_u8("random move freq", 70);
	this.set_f32(target_searchrad_property, 320.0f);
	this.set_f32(terr_rad_property, 85.0f);
	this.set_u8(target_lose_random, 34);
	this.getBrain().server_SetActive(true);
	this.getShape().SetRotationsAllowed(false);
	this.set_f32("gib health", -0.0f);
	this.Tag("flesh");
	this.Tag("ignorespikes");
	this.Tag("dooropener");
	this.set_s16("mad timer", 0);
	this.getShape().SetOffset(Vec2f(0, 6));
	this.getCurrentScript().runFlags |= Script::tick_blob_in_proximity;
	this.getCurrentScript().runProximityTag = "player";
	this.getCurrentScript().runProximityRadius = 300.0f;
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
	if (isServer())
	{
		server_CreateBlob("heart",-1,this.getPosition());
		server_CreateBlob("drill",-1,this.getPosition());
		server_CreateBlob("mat_bomb",-1,this.getPosition());

		server_DropCoins(this.getPosition(), XORRandom(20)+1);

		if (XORRandom(4) == 0) {
			server_CreateBlob("mat_stone",-1,this.getPosition()); }
		if (XORRandom(3) == 0) {
			server_CreateBlob("heartnecklace",-1,this.getPosition()); }
		if (XORRandom(6) == 0) {
			server_CreateBlob("heartlocket",-1,this.getPosition()); }
		if (XORRandom(6) == 0) {
			server_CreateBlob("speednecklace",-1,this.getPosition()); }
		if (XORRandom(7) == 0) {
			server_CreateBlob("cloudnecklaec",-1,this.getPosition()); }

		CBlob@ blob1 = server_CreateBlobNoInit('gunpowder');
		if (blob1 !is null)
		{
			blob1.Tag('custom quantity');
			blob1.Init();
			blob1.server_SetQuantity(8+XORRandom(6));
			blob1.setPosition(this.getPosition());
		}
	}
}

void onTick(CBlob@ this)
{
	f32 x = this.getVelocity().x;
	f32 y = this.getVelocity().y;
	s16 mad = this.get_s16("mad timer");
	this.SetFacingLeft(x < 0);

	if ((mad > 0) && (getGameTime() % 65 == 0))
	{
		mad -= 65;
		if (mad < 0)
		{
			this.set_u8(personality_property, DEFAULT_PERSONALITY);
		}
		this.set_s16("mad timer", mad);
	}

	if ((XORRandom(9) == 0) && (Maths::Abs(x) > 0.9f) && (Maths::Abs(y) > 0.2f) && (getGameTime() % 20 == 0) && (mad > 0)) {
		if(getNet().isServer())
		{
			CBlob@ spawn = server_CreateBlob("mine",-1,this.getPosition());
	        if (spawn !is null) {
				Vec2f vel(x, y);
				spawn.setVelocity(vel * 2.0);
				spawn.server_setTeamNum(10);
			}
		}
	}
	if ((XORRandom(9) == 0) && (Maths::Abs(x) > 1.0f) && (Maths::Abs(y) > 0.3f) && (getGameTime() % 15 == 0) && (mad > 0)) {
		if(getNet().isServer())
		{
			CBlob@ spawn = server_CreateBlob("bomb",-1,this.getPosition());
	        if (spawn !is null) {
				Vec2f vel(x, y);
				spawn.setVelocity(vel * 5.5);
				spawn.server_setTeamNum(10);
			}
		}
	}
}

void MadAt(CBlob@ this, CBlob@ hitterBlob)
{
	const u16 damageOwnerId = (hitterBlob.getDamageOwnerPlayer() !is null && hitterBlob.getDamageOwnerPlayer().getBlob() !is null) ?
	                          hitterBlob.getDamageOwnerPlayer().getBlob().getNetworkID() : 0;
	this.set_s16("mad timer", MAD_TIME);
	this.set_u8(personality_property, DEFAULT_PERSONALITY | AGGRO_BIT);
	this.set_u8(state_property, MODE_TARGET);
	if (hitterBlob.hasTag("player"))
		this.set_netid(target_property, hitterBlob.getNetworkID());
	else if (damageOwnerId > 0)
	{
		this.set_netid(target_property, damageOwnerId);
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	MadAt(this, hitterBlob);
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
			if (vel * direction > 0.25f)
			{
				f32 power = Maths::Max(0.25f, 0.04f * vellen);
				this.server_Hit(blob, point1, vel, power, Hitters::sword, false);
			}
			if (vel * direction > 0.95f) {
				this.getSprite().PlaySound("/Arrgh", 2.4f, 0.75f);
				CMap@ map = this.getMap();
				map.server_DestroyTile(other_pos, 0.4f, this);
			}
		}
		MadAt(this, blob);
	}
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	if (hitBlob !is null && customData == Hitters::sword)
	{
		Vec2f force = velocity * 0.55f;
		force.y -= 60.0f;
		hitBlob.AddForce(force);
	}
}