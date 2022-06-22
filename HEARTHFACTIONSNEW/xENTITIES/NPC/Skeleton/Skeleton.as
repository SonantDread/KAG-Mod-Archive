#include "AnimalConsts.as";
const u8 DEFAULT_PERSONALITY = TAMABLE_BIT | DONT_GO_DOWN_BIT;
const s16 MAD_TIME = 340;

void onInit(CSprite@ this)
{
	this.ReloadSprites(0, 0);
}

void onInit(CBlob@ this)
{
	string[] tags = {"player", "flesh"};
	this.set("tags to eat", tags);
	this.server_setTeamNum(11); //seperate team
	this.set_f32("bite damage", 0.05f);
	this.set_u8(personality_property, DEFAULT_PERSONALITY);
	this.set_u8("random move freq", 70);
	this.set_f32(target_searchrad_property, 320.0f);
	this.set_f32(terr_rad_property, 85.0f);
	this.set_u8(target_lose_random, 34);
	this.getBrain().server_SetActive(true);
	this.getShape().SetRotationsAllowed(false);
	this.set_f32("gib health", -0.0f);
	//this.Tag("hasowner");
	this.Tag("dooropener");
	this.set_s16("mad timer", 0);
	this.getShape().SetOffset(Vec2f(0, 6));
	this.getCurrentScript().runFlags |= Script::tick_blob_in_proximity;
	this.getCurrentScript().runProximityTag = "player";
	this.getCurrentScript().runProximityRadius = 750.0f;
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (!blob.hasTag("dead")) {
		f32 x = blob.getVelocity().x;
		f32 y = blob.getVelocity().y;

		if (blob.hasTag("hasowner")) { //tame
			if (Maths::Abs(y) > 0.5f) {
				if (y > 0.0f) {
					this.SetAnimation("fall"); }
				else {
					this.SetAnimation("jump"); }
			}
			else if (Maths::Abs(x) > 0.3f) {
				this.SetAnimation("walk"); }
			else {
				this.SetAnimation("idle"); }
		}
		else { //wild
			if (Maths::Abs(y) > 0.5f) {
				if (y > 0.0f) {
					this.SetAnimation("fall2"); }
				else {
					this.SetAnimation("jump2"); }
			}
			else if (Maths::Abs(x) > 0.3f) {
				this.SetAnimation("walk2"); }
			else {
				this.SetAnimation("idle2"); }
		}
	}
	else {
		this.SetAnimation("dead");
		this.getCurrentScript().runFlags |= Script::remove_after_this; }
}

void onDie(CBlob@ this)
{
	if (isServer()) {
		server_DropCoins(this.getPosition(), XORRandom(3)); }
}

void onTick(CBlob@ this)
{
	f32 x = this.getVelocity().x;
	f32 y = this.getVelocity().y;
	s16 mad = this.get_s16("mad timer");

	if (Maths::Abs(x) > 1.0f) {
		this.SetFacingLeft(x < 0);
	}
	else {
		if (this.isKeyPressed(key_left)) {
			this.SetFacingLeft(true);
		}
		if (this.isKeyPressed(key_right)) {
			this.SetFacingLeft(false);
		}
	}

	if ((mad > 0) && (getGameTime() % 65 == 0)) {
		mad -= 65;
		if (mad < 0) {
			this.set_u8(personality_property, DEFAULT_PERSONALITY);
			this.getSprite().PlaySound("/Cackle2", 2.0f, 0.75f);
		}
		this.set_s16("mad timer", mad);
	}

	const u16 friendId = this.get_netid(friend_property);
	CBlob@ friend = getBlobByNetworkID(friendId);
	if (friend !is null) //follow master
	{
		this.Tag("hasowner");
		CMap@ map = getMap();
		if ((friend.getPosition().y + 2.0f < this.getPosition().y) && this.isOnMap()) {
			this.AddForce(Vec2f(0.0f, -410.0f));
		}
		else
		{
			this.AddForce(Vec2f(0.0f, 90.0f));
		}
	}
	else {
		this.Untag("hasowner");
	}
	Vec2f vel = this.getVelocity();
	CShape@ shape = this.getShape();
	if (shape.vellen > 1.8f) { //slow the fuck down
		this.AddForce(Vec2f(-vel.x * 50.0f, 100.0f));
	}
	CMap@ map = getMap();
	if ((getGameTime() % 15 == 0)) {
		if (this.isOnMap()) {
			this.AddForce(Vec2f(this.getVelocity().x * -3.0f, -900.0f));
		}
		else {
			this.AddForce(Vec2f(this.getVelocity().x * -3.0f, -300.0f));
		}
	}
}

void MadAt(CBlob@ this, CBlob@ hitterBlob)
{
	const u16 damageOwnerId = (hitterBlob.getDamageOwnerPlayer() !is null && hitterBlob.getDamageOwnerPlayer().getBlob() !is null) ?
	                          hitterBlob.getDamageOwnerPlayer().getBlob().getNetworkID() : 0;
	const u16 friendId = this.get_netid(friend_property);
	if (friendId == hitterBlob.getNetworkID() || friendId == damageOwnerId) //unfriend?
	{
		//this.set_netid(friend_property, 0);
	}
	else
	{
		hitterBlob.Tag("skeletons_hate_him");
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
	const u16 friendId = this.get_netid(friend_property);
	CBlob@ friend = getBlobByNetworkID(friendId);

	if ((blob.hasTag("player") && friend is null) && !blob.hasTag("skeletons_hate_him")) { //found a master
		this.getSprite().PlaySound("/Cackle", 2.8f, 0.75f);
		blob.Untag("skeletons_hate_him");
		CPlayer@ owner = blob.getDamageOwnerPlayer();
		if (owner !is null) {
			CBlob@ ownerblob = owner.getBlob();
			if (ownerblob !is null) {
				this.set_u8(state_property, MODE_FRIENDLY);
				this.set_netid(friend_property, ownerblob.getNetworkID());
			}
		}
	}

	if ((friend is null || (blob.getTeamNum() != friend.getTeamNum())) && blob.getName() != this.getName())
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
			if (vel * direction > 0.6f) {
				this.server_Hit(blob, point1, vel, 0.25f, Hitters::flying, false);
				this.getSprite().PlaySound("/Swoosh", 2.4f, 0.75f);
				CMap@ map = this.getMap();
				map.server_DestroyTile(other_pos, 0.5f, this);
			}
			else if (vel * direction > 0.02f) {
				this.server_Hit(blob, point1, vel, 0.02f, Hitters::flying, false);
			}
		}
		MadAt(this, blob);
	}

	if (blob.getName() == "heart") {
		CPlayer@ owner = blob.getDamageOwnerPlayer();
		if (owner !is null) {
			CBlob@ ownerblob = owner.getBlob();
			if (ownerblob !is null) {
				if ((this.getHealth() != this.getInitialHealth()) || ownerblob.hasTag("skeletons_hate_him"))
				{
					this.getSprite().PlaySound("/Cackle2", 2.2f, 0.75f);
					this.server_SetHealth(this.getInitialHealth());
					blob.server_Die();
					ownerblob.Untag("skeletons_hate_him"); // skeletons will forgive you for your deeds
				}
			}
		}
	}
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	if (hitBlob !is null && customData == Hitters::flying) {
		Vec2f force = velocity * 0.55f;
		if (hitBlob.hasTag("flesh")) {
			force.y -= 60.0f;
			if (hitBlob.getHealth() <= 0.125f) {
				hitBlob.server_Die();
				if(isServer()) {
		        	server_CreateBlob("skeleton",-1,hitBlob.getPosition());
	   		 	}
	   		 	this.getSprite().PlaySound("/Cackle", 2.2f, 0.75f);
			}
		}
		hitBlob.AddForce(force);
	}
}