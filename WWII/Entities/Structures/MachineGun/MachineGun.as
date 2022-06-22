#include "VehicleCommon.as"
#include "RulesCore.as";
#include "Requirements_Tech.as";
#include "ParticleSparks.as";
const Vec2f arm_offset = Vec2f(-6,-5);

void onInit( CBlob@ this )
{
    Vehicle_Setup( this,
                   30.0f, // move speed
                   0.31f,  // turn speed
                   Vec2f(0.0f, 0.0f), // jump out velocity
                   false  // inventory access
                 );
	VehicleInfo@ v;
	if (!this.get( "VehicleInfo", @v )) {
		return;
	}
    Vehicle_SetupWeapon( this, v,
                         3, // fire delay (ticks)
                         1, // fire bullets amount
                         Vec2f(-6.0f, 2.0f), // fire position offset
                         "mat_bullets", // bullet ammo config name
                         "mgbullet", // bullet config name
                         "GunFire", // fire sound
                         "EmptyFire" // empty fire sound
                       );
    v.charge = 0;
    CSprite@ sprite = this.getSprite();
    CSpriteLayer@ arm = sprite.addSpriteLayer( "arm", sprite.getConsts().filename, 16, 16 );
    this.addCommandID("Reload");
	this.set_s32("lastReloadTime", 0);
			bool hasMGBomb = hasTech(this, "MG ammo");
	this.set_bool("MG ammo", hasMGBomb);
	
	
	
	if (arm !is null)
    {
        Animation@ anim = arm.addAnimation( "default", 0, false );
        anim.AddFrame(4);
        anim.AddFrame(5);
        arm.SetOffset( arm_offset );
    }

    CSpriteLayer@ cage = sprite.addSpriteLayer( "cage", sprite.getConsts().filename, 16, 16 );

    if (cage !is null)
    {
        Animation@ anim = cage.addAnimation( "default", 0, false );
        anim.AddFrame(0);
        anim.AddFrame(2);
        anim.AddFrame(3);
        cage.SetOffset( sprite.getOffset() );
        cage.SetRelativeZ(20.0f);
    }

    this.getShape().SetRotationsAllowed( false );
	this.set_string("autograb blob", "mat_bullets");

	sprite.SetZ(-10.0f);

	this.getCurrentScript().runFlags |= Script::tick_hasattached;	
    //this.Tag("medium weight");
	this.Tag("veryheavy weight");
	// auto-load on creation
	if (getNet().isServer())
	{
		CBlob@ ammo = server_CreateBlob( "mat_bullets" );
		if (ammo !is null)	{
			if (!this.server_PutInInventory( ammo ))
				ammo.server_Die();
		}
	}
	
	
}

f32 getAimAngle( CBlob@ this, VehicleInfo@ v )
{
    f32 angle = Vehicle_getWeaponAngle(this, v);
    bool facing_left = this.isFacingLeft();
    AttachmentPoint@ gunner = this.getAttachments().getAttachmentPointByName("GUNNER");
    bool failed = true;

    if (gunner !is null && gunner.getOccupied() !is null)
    {
        gunner.offsetZ = 5.0f;
        Vec2f aim_vec = gunner.getPosition() - gunner.getAimPos();

		if( this.isAttached() )
		{
			if (facing_left) { aim_vec.x = -aim_vec.x; }
			angle = (-(aim_vec).getAngle() + 180.0f);
		}
		else
		{
			if ( (!facing_left && aim_vec.x < 0) ||
					( facing_left && aim_vec.x > 0 ) )
			{
				if (aim_vec.x > 0) { aim_vec.x = -aim_vec.x; }

				angle = (-(aim_vec).getAngle() + 180.0f);
				angle = Maths::Max( -80.0f , Maths::Min( angle , 80.0f ) );
			}
			else
			{
				this.SetFacingLeft(!facing_left);
			}
		}
    }

    return angle;
}

bool hasTech(CBlob@ this, const string &in name)
{
	CBitStream reqs, missing;
	//AddRequirement(reqs, "tech", "drop bomb ammo", "Drop Bomb Ammo");
	AddRequirement(reqs, "tech", "MG ammo", "MG Ammo");
	//AddRequirement(reqs, "tech", "Bazooka ammo", "Bazooka Ammo");
	int thisteam = this.getTeamNum();

	CPlayer@ player;
	for (int i = 0; i < getPlayersCount(); i++)
	{
		@player = getPlayer(i);
		if (player.getTeamNum() == thisteam && player.getBlob() !is null)
			break;
	}

	if (player !is null && player.getBlob() !is null)
	{
		return hasRequirements_Tech(player.getBlob().getInventory(), reqs, missing);
	}
	return false;
}

void onTick( CBlob@ this )
{
	if (this.hasAttached() || this.getTickSinceCreated() < 30) //driver, seat or gunner, or just created
	{
		VehicleInfo@ v;
		if (!this.get( "VehicleInfo", @v )) {
			return;
		}

		//set the arm angle based on GUNNER mouse aim, see above ^^^^
		f32 angle = getAimAngle( this, v );
		Vehicle_SetWeaponAngle( this, angle, v );
		CSprite@ sprite = this.getSprite();
		CSpriteLayer@ arm = sprite.getSpriteLayer( "arm" );

		if (arm !is null)
		{
			bool facing_left = sprite.isFacingLeft();
			f32 rotation = angle * (facing_left? -1: 1);

			if (v.loaded_ammo > 0) {
				arm.animation.frame = 1;
			}
			else {
				arm.animation.frame = 0;
			}

			arm.ResetTransform( );
			arm.SetFacingLeft(facing_left);
			arm.SetRelativeZ( 1.0f );
			arm.SetOffset( arm_offset );
			arm.RotateBy( rotation, Vec2f(facing_left?-4.0f:4.0f,0.0f) );
		}


		Vehicle_StandardControls( this, v );
	}
	//const int team = this.getTeamNum();
	 //!
	s32 currentTime = getGameTime();
	s32 lastReloadTime = this.get_s32("lastReloadTime");
	//const int CountMax = 3 * getTicksASecond();
	//const u8 CoutMax = 10;
		CInventory@ inv = this.getInventory();
	   if (inv.getItemsCount() == 0 && !this.hasTag("tryReload"))
					{
					this.Tag("tryReload");
					this.Tag("ResetCurrentTime");
					this.getSprite().PlaySound("/ReloadGun2.ogg");	
					
					}
	
	if(this.hasTag("ResetCurrentTime"))
	{
		this.set_s32("lastReloadTime", currentTime);
		//this.set_u32(currentTime, 0);
		//currentTime -=currentTime;
		//print("ResetCurrentTime:" + currentTime);
		this.Untag("ResetCurrentTime");
	
	}
	
	
			if(this.hasTag("tryReload"))
	{
		int TimeToReload;
			if(this.get_bool("MG ammo") == false)
			{
			TimeToReload = 300;
			}
			else{
			TimeToReload = 150;
			}

			s32 lastReloadTime = this.get_s32("lastReloadTime");
			//print("tryReload Gametime:" + currentTime);
				//if(currentTime - (lastReloadTime + RELOAD_FREQUENCY * getTicksASecond()) > 0)
			if(currentTime > lastReloadTime + TimeToReload)
			{
				//print("Timer currentTime:" + currentTime);
				//print("LastR+RF+TicksAS:" + lastReloadTime * getTicksASecond());
				this.Untag("tryReload");
				//this.set_u32(currentTime, 0);
				CBlob@ ammo = server_CreateBlob( "mat_bullets" );
 
					if (ammo !is null) 
					{
 
						if (!this.server_PutInInventory( ammo )) 
						{
   
						ammo.server_Die();
     
						}
												
					
					}
					
					
			}
				
					
					
   
				
						
 


 
			//s32 timer = this.get_s32("explosion_timer") - gametime;
			//SColor lightColor = SColor(255, 255, Maths::Min(255, uint(gametime * 0.7)), 0);
		
	}

}

void onHealthChange( CBlob@ this, f32 oldHealth )
{

	f32 hp = this.getHealth();
	f32 max_hp = this.getInitialHealth();
	int damframe = hp < max_hp * 0.4f ? 2 : hp < max_hp * 0.9f ? 1 : 0;
	CSprite@ sprite = this.getSprite();
	sprite.animation.frame = damframe;
	CSpriteLayer@ cage = sprite.getSpriteLayer( "cage" );  
	if (cage !is null)	{
		cage.animation.frame = damframe;
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller)
{
	CBitStream params;
		params.write_u16(caller.getNetworkID());
		CInventory@ inv = this.getInventory();
		//CBlob@ item = inv.getItem();
		//const string itemname = item.getName();
		//const string Ammoz = "mat_bullets";
		
  //  if (!Vehicle_AddFlipButton( this, caller))
   // {
       // Vehicle_AddLoadAmmoButton( this, caller );
	   //if (!Ammoz == itemname)
	 //  if (inv.getItemsCount() == 0 && !this.hasTag("tryReload"))
					//{
	  // CButton@ button = caller.CreateGenericButton("$mat_bullets$",  Vec2f(0, 0), this, this.getCommandID("Reload"), "Reload", params);
					//}
   // }
	//string InvItem = this.getInventoryName("");
	//int InvQuantity = this.getQuantity();
	//CBlob@ carryBlob = this.getCarriedBlob();
	//if (InvItem != "mat_bullets")
	//if(!carryBlob.getName() == "mat_bullets")
    //{
	
	//rules.SetGlobalMessage(this.getQuantity() + this.getInventoryName(""));
	//}
}


bool Vehicle_canFire( CBlob@ this, VehicleInfo@ v, bool isActionPressed, bool wasActionPressed, u8 &out chargeValue ) {return false;}

void Vehicle_onFire( CBlob@ this, VehicleInfo@ v, CBlob@ bullet, const u8 _unused )
{
    if (bullet !is null)
    {
		//this.Tag("Fire");
		u16 charge = 900;
        f32 angle = Vehicle_getWeaponAngle( this, v );
        angle = angle * (this.isFacingLeft() ? -1:1);
        angle += ((XORRandom(512) - 256) / 64.0f) * 0;
        
        Vec2f vel = Vec2f(charge/16.0f * (this.isFacingLeft() ? -1 : 1), 0.0f).RotateBy(angle)*0.7;
        bullet.setVelocity( vel );
        Vec2f offset = arm_offset;
        offset.RotateBy(angle);
        bullet.setPosition(this.getPosition() + offset*1.1f );
		// set much higher drag than archer arrow
		bullet.getShape().setDrag( bullet.getShape().getDrag() * 2.0f );
		sparks(this.getPosition(), this.getAngleDegrees(), 0.1f);
		//bullet.server_SetTimeToDie( -1 ); // override lock
		//bullet.server_SetTimeToDie( 0.69f );
		bullet.Tag("projectile");
	
    }
	//else{
	//this.Untag("Fire");
	//}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("fire blob"))
	{	  		
		CBlob@ blob = getBlobByNetworkID( params.read_netid() );
		const u8 charge = params.read_u8();
		VehicleInfo@ v;
		if (!this.get( "VehicleInfo", @v )) {
			return;
		}
		Vehicle_onFire( this, v, blob, charge );
	}
	//if (cmd == this.getCommandID("Reload"))
	//{
	//this.Tag("tryReload");
	//this.Tag("ResetCurrentTime");
	//this.getSprite().PlaySound("/ReloadGun2.ogg");	
			
		
	//}
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
    return Vehicle_doesCollideWithBlob_ground( this, blob );
}


void onCollision( CBlob@ this, CBlob@ blob, bool solid )
{
	if (blob !is null) {
		TryToAttachVehicle( this, blob );
	}
}
void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v))
	{
		return;
	}
	Vehicle_onAttach(this, v, attached, attachedPoint);
}