#include "AnimalConsts.as";
#include "BrainCommon.as";

const u8 DEFAULT_PERSONALITY = AGGRO_BIT;
const string punch_tag = "punching";

//sprite

void onInit(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	
    this.ReloadSprites(blob.getTeamNum(),0);
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (this.isAnimation("bite") && !this.isAnimationEnded()) return;
    if (blob.getHealth() > 0.0)
    {
		f32 x = blob.getVelocity().x;
		
		// if( blob.get_s32("climb") > 1 ) 
		// {
			// if (!this.isAnimation("climb")) {
				// this.SetAnimation("climb");
			// }
		// }
	}
	else 
	{
		if (!this.isAnimation("dead"))
		{
			this.SetAnimation("dead");
		}
	}
}

f32 getGibHealth( CBlob@ this )
{
    if (this.exists("gib health")) {
        return this.get_f32("gib health");
    }

    return 0.0f;
}

void onRender(CSprite@ this)
{

}

//blob
void onInit(CBrain@ this)
{
	this.getCurrentScript().runFlags = Script::tick_not_attached;
}
void onInit(CBlob@ this)
{
	
	//for EatOthers
	string[] tags = {"player"};
	this.set("tags to eat", tags);
	
	this.set_f32("bite damage", 1.0f);
	this.set_u16("bite freq", 60);
	this.set_u16("bite charge", 20);
	//brain
	this.set_u8(personality_property, DEFAULT_PERSONALITY);
	this.set_u8("random move freq",6);
	this.set_f32(target_searchrad_property, 160.0f);
	this.set_f32(terr_rad_property, 185.0f);
	this.set_u8(target_lose_random,34);
	
	this.set_u32("lastSoundPlayedTime", 0);
	
	this.getBrain().server_SetActive( true );
	
	//for shape
	this.getShape().SetRotationsAllowed(false);
	
	this.set_f32("gib health", 0.0f);
	this.Tag("flesh");
	this.Tag("lifeless");
	
	this.getCurrentScript().runFlags = Script::tick_not_attached;
}

bool canBePickedUp(CBlob@ this, CBlob@ blob)
{
	return false;
}

void onTick(CBlob@ this)
{
	f32 x = this.getVelocity().x;

	if (this.get_u32("lastSoundPlayedTime") + 200 < getGameTime() && XORRandom(100) < 10 )
	{		
		this.getSprite().PlaySound("scyther-screech0" + (XORRandom(3) + 1), 1.00f, 1.00f);
		this.set_u32("lastSoundPlayedTime", getGameTime());
	}
	
	if (this.getHealth()<=0.0 && (this.getTickSinceCreated() - this.get_u16("death ticks")) > 300)
	{
		this.server_SetHealth(0.5);
		this.getShape().setFriction( 0.3f );
		this.getShape().setElasticity( 0.1f );		
	}
	if (this.getHealth()<=0.0) return;
	
	CBlob@ b = getBlobByNetworkID(this.get_netid(target_property));
	
	if(this.isInWater()){
		if(b is null)this.AddForce(Vec2f(0,-8));
		else {
			if(b.getPosition().y <= this.getPosition().y)this.AddForce(Vec2f(0,-8));
		}
	}
	
	u16 lastbite = this.get_u16("lastbite");
	u16 bitefreq = this.get_u16("bite freq");
	
	if (lastbite <= bitefreq-this.get_u16("bite charge"))this.set_u16("lastbite",this.get_u16("lastbite")+1);
	
	if (b !is null){
		if (this.getDistanceTo(b) < 128.0f)JustGo(this,b);
	}
	
	if (getNet().isServer() && b !is null && this.getDistanceTo(b) < 16.0f)
	{
		if (bitefreq<0) bitefreq=20;

		if (lastbite > bitefreq-this.get_u16("bite charge"))this.set_u16("lastbite",this.get_u16("lastbite")+1);
		
		float aimangle=0;
		if(this.get_u8(state_property) == MODE_TARGET )
		{
			Vec2f vel;
			if(b !is null)
			{
				vel = b.getPosition()-this.getPosition();
			}
			else vel = Vec2f(1,0);
			
			{
				vel.Normalize();
				if (b !is null)
				{
					if (b.getTeamNum() != this.getTeamNum())
					{
						if (lastbite > bitefreq){
							f32 power = this.get_f32("bite damage");
							this.server_Hit(b,b.getPosition(),vel,power,Hitters::bite, true);
							this.set_u16("lastbite",0);
							if(this.hasTag(punch_tag)){
								this.Untag(punch_tag);
								this.Sync(punch_tag,true);
							}
						} else if (lastbite > bitefreq-this.get_u16("bite charge")){
							if(!this.hasTag(punch_tag)){
								this.Tag(punch_tag);
								this.Sync(punch_tag,true);
							}
						}
					}
				}
			}		
		} else {
			if(this.hasTag(punch_tag)){
				this.Untag(punch_tag);
				this.Sync(punch_tag,true);
			}
		}
	}	
	
	if (Maths::Abs(x) > 1.0f)
	{
		this.SetFacingLeft( x < 0 );
	}
	else
	{
		if (this.isKeyPressed(key_left)) {
			this.SetFacingLeft( true );
		}
		if (this.isKeyPressed(key_right)) {
			this.SetFacingLeft( false );
		}
	}
	
	// footsteps

	if (this.isOnGround() && (this.isKeyPressed(key_left) || this.isKeyPressed(key_right)) )
	{
		if (XORRandom(20)==0)
		{
			Vec2f tp = this.getPosition() + (Vec2f( XORRandom(16)-8, XORRandom(16)-8 )/8.0)*(this.getRadius() + 4.0f);
			TileType tile = this.getMap().getTile( tp ).type;
			if ( this.getMap().isTileWood( tile ) ) {		
			this.getMap().server_DestroyTile(tp, 0.1);
			}
		}	
		if (this.isKeyPressed(key_right))
		{
			TileType tile = this.getMap().getTile( this.getPosition() + Vec2f( this.getRadius() + 4.0f, 0.0f )).type;
			if (this.getMap().isTileCastle( tile )) {		
			//this.getMap().server_DestroyTile(this.getPosition() + Vec2f( this.getRadius() + 4.0f, 0.0f ), 0.1);
			}
		}
		if ((this.getNetworkID() + getGameTime()) % 9 == 0)
		{
			f32 volume = Maths::Min( 0.1f + Maths::Abs(this.getVelocity().x)*0.1f, 1.0f );
			TileType tile = this.getMap().getTile( this.getPosition() + Vec2f( 0.0f, this.getRadius() + 4.0f )).type;
		}
	}
	
}

void MadAt( CBlob@ this, CBlob@ hitterBlob )
{
	const u16 damageOwnerId = (hitterBlob.getDamageOwnerPlayer() !is null && hitterBlob.getDamageOwnerPlayer().getBlob() !is null) ? 
		hitterBlob.getDamageOwnerPlayer().getBlob().getNetworkID() : 0;
	this.set_u8(state_property, MODE_TARGET);
	if (hitterBlob.hasTag("player"))
		this.set_netid(target_property, hitterBlob.getNetworkID() );
	else
	if (damageOwnerId > 0) {
		this.set_netid(target_property, damageOwnerId );
	}
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{	
	if (this.getHealth()>0 && this.getHealth() <= damage)
	{
		if (getNet().isServer()){
			this.set_u16("death ticks",this.getTickSinceCreated());
			this.Sync("death ticks",true);
		}
	}
    this.Damage( damage, hitterBlob );

    f32 gibHealth = getGibHealth( this );

    if (this.getHealth() <= gibHealth)
    {
        this.getSprite().Gib();
		if (hitterBlob.hasTag("player"))
		{
			CPlayer@ player = hitterBlob.getPlayer();
		} else
		if(hitterBlob.getDamageOwnerPlayer() !is null)
		{
			CPlayer@ player = hitterBlob.getDamageOwnerPlayer();
		}
		
        this.server_Die();
    }
	MadAt( this, hitterBlob );
    return 0.0f; //done, we've used all the damage	
}															

#include "Hitters.as";

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	if (blob.hasTag("dead"))
		return false;
	return true;
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1 )
{
	if (this.getHealth() <= 0.0) return; // dead
	if (blob is null)
		return;

	if (blob.getTeamNum() != this.getTeamNum() && blob.hasTag("flesh") && !blob.hasTag("dead"))
	{
		MadAt( this, blob );
	}
}