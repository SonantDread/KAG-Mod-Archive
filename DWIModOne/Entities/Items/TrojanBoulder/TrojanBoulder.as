#include "/Entities/Common/Attacks/Hitters.as";
#include "/Entities/Common/Attacks/LimitedAttacks.as";
#include "GenericButtonCommon.as"
#include "KnockedCommon.as"


const int pierce_amount = 8;

const f32 hit_amount_ground = 0.5f;
const f32 hit_amount_air = 1.0f;
const f32 hit_amount_air_fast = 3.0f;
const f32 hit_amount_cata = 10.0f;

void onInit(CBlob @ this)
{
	this.set_u8("launch team", 255);
	this.server_setTeamNum(-1);
	this.Tag("medium weight");
	this.addCommandID("hide in");


	// damage
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().tickFrequency = 3;
}

void onTick(CBlob@ this)
{
	//rock and roll mode

	if (getPlayerInside(this) !is null){
		boulder_standardControls(this, getPlayerInside(this));
	}
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	this.set_u8("launch team", detached.getTeamNum());
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	if (attached.getPlayer() !is null)
	{
		this.SetDamageOwnerPlayer(attached.getPlayer());
	}

	this.set_u8("launch team", attached.getTeamNum());
}

void Slam(CBlob @this, f32 angle, Vec2f vel, f32 vellen)
{
	if (vellen < 0.1f)
		return;

	CMap@ map = this.getMap();
	Vec2f pos = this.getPosition();
	HitInfo@[] hitInfos;
	u8 team = this.get_u8("launch team");

	if (map.getHitInfosFromArc(pos, -angle, 30, vellen, this, true, @hitInfos))
	{
		for (uint i = 0; i < hitInfos.length; i++)
		{
			HitInfo@ hi = hitInfos[i];
			f32 dmg = 2.0f;

			if (team != u8(hi.blob.getTeamNum()))
			{
				this.server_Hit(hi.blob, pos, vel, dmg, Hitters::cata_boulder, true);
				this.setVelocity(vel * 0.9f); //damp

				// die when hit something large
				if (hi.blob.getRadius() > 32.0f)
				{
					this.server_Hit(this, pos, vel, 10, Hitters::cata_boulder, true);
				}
			}
		}
	}


}


bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return false;
	
}
void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!canSeeButtons(this, caller)) return;

	Vec2f buttonpos(0, 0);

	CBlob@ sneaky_player = getPlayerInside(this);
	// If there's a player inside and we aren't just dropping in an item
	if (sneaky_player !is null)
	{
		if (sneaky_player.getTeamNum() == caller.getTeamNum())
		{
			CBitStream params;
			params.write_u16( caller.getNetworkID() );
			CButton@ button = caller.CreateGenericButton( 6, Vec2f(0,0), this, this.getCommandID("hide in"), getTranslatedString("Get out"), params);

			if (sneaky_player !is caller) // it's a teammate, so they have to be close to use button
			{
				button.enableRadius = 20.0f;
			}
		}
		else // make fake buttons for enemy
		{
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			if (caller.getCarriedBlob() is this)
			{
				// Fake get in button
				caller.CreateGenericButton(4, Vec2f(), this, this.getCommandID("hide in"), getTranslatedString("Get inside"), params);
			}
			else
			{
				// Fake inventory button
				CButton@ button = caller.CreateGenericButton(13, Vec2f(), this, this.getCommandID("hide in"), getTranslatedString("Trojan Boulder"), params);
				button.enableRadius = 20.0f;
			}
		}
	}
	else{
		CBitStream params;
		params.write_u16( caller.getNetworkID() );
		CButton@ button = caller.CreateGenericButton( 6, Vec2f(0,0), this, this.getCommandID("hide in"), getTranslatedString("Get in"), params);

	}
	
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("hide in"))
	{
		CBlob @caller = getBlobByNetworkID( params.read_u16() );
		if (this.getInventory().canPutItem(caller))
		{
			this.server_PutInInventory( caller );
		}
		else
		{
			CBlob@ sneaky_player = getPlayerInside(this);
			if (caller !is null && sneaky_player !is null) {
				if (caller.getTeamNum() != sneaky_player.getTeamNum())
				{
					if (isKnockable(caller))
					{
						setKnocked(caller, 30);
					}
				}
			
				this.server_PutOutInventory(sneaky_player);
						// Attack self to pop out items
			}

		}
	}
}

void onRemoveFromInventory(CBlob@ this, CBlob@ blob)
{
	this.server_SetHealth(-1.0f); // TODO: wont gib on client
	this.server_Die();
}
void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (solid && blob !is null)
	{
		Vec2f hitvel = this.getOldVelocity();
		Vec2f hitvec = point1 - this.getPosition();
		f32 coef = hitvec * hitvel;

		if (coef < 0.706f) // check we were flying at it
		{
			return;
		}

		f32 vellen = hitvel.Length();

		//fast enough
		if (vellen < 1.0f)
		{
			return;
		}

		u8 tteam = this.get_u8("launch team");
		CPlayer@ damageowner = this.getDamageOwnerPlayer();

		//not teamkilling (except self)
		if (damageowner is null || damageowner !is blob.getPlayer())
		{
			if (
			    (blob.getName() != this.getName() &&
			     (blob.getTeamNum() == this.getTeamNum() || blob.getTeamNum() == tteam))
			)
			{
				return;
			}
		}

		//not hitting static stuff
		if (blob.getShape() !is null && blob.getShape().isStatic())
		{
			return;
		}

		//hitting less or similar mass
		if (this.getMass() < blob.getMass() - 1.0f)
		{
			return;
		}

		//get the dmg required
		hitvel.Normalize();
		f32 dmg = vellen > 8.0f ? 5.0f : (vellen > 4.0f ? 1.5f : 0.5f);

		//bounce off if not gibbed
		if (dmg < 4.0f)
		{
			this.setVelocity(blob.getOldVelocity() + hitvec * -Maths::Min(dmg * 0.33f, 1.0f));
		}

		//hurt
		this.server_Hit(blob, point1, hitvel, dmg, Hitters::boulder, true);

		return;

	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::sword || customData == Hitters::arrow)
	{
		return damage *= 0.5f;
	}

	return damage;
}

//sprite

void onInit(CSprite@ this)
{
	this.animation.frame = (this.getBlob().getNetworkID() % 4);
	this.getCurrentScript().runFlags |= Script::remove_after_this;
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
void boulder_standardControls(CBlob@ this, CBlob@ insideBlob){

	if (insideBlob is null) return;

	CPlayer@ insidePlayer = insideBlob.getPlayer();
	if (insidePlayer !is null){

		const bool left = insideBlob.isKeyPressed(key_left);
		const bool right = insideBlob.isKeyPressed(key_right);
		const bool up = insideBlob.isKeyPressed(key_up);
		const bool onground = this.isOnGround();
		Vec2f force;		
		f32 moveForce = 35.0f;
		if (left){
			force.x -= 6.0f * moveForce;
		}
		if (right){
			force.x += 6.0f * moveForce;
		}
		if (up && onground){
			print('up');
			force.y -= 30.0f * moveForce;		
		}
		this.AddForce(force);

		
	}
}  