void onInit(CBlob@ this)
{
	//make sure we've set this ahead of time, or complain loudly
	string config_filename = this.get_string("gunangelarm_config");
	if(config_filename == "") {
		error("Missing gun config for blob "+this.getName());
		return;
	}

	ConfigFile cfg = ConfigFile();
	cfg.loadFile(config_filename);

	//otherwise get ready to load the config

	//add the required command
	this.addCommandID("shoot");

	//note: i'm using properties here but
	//		it would be more performant to
	//		use a class - you cant sync()
	//		then though, so i thought this
	//		would be simpler for you!

	//time between shots
	this.set_u16("gun_fire_delay_ticks", cfg.read_u16("gun_fire_delay_ticks", 15));
	this.set_u16("gun_fire_delay_timer", 0);
	//fullauto
	this.set_bool("gun_fullauto", cfg.read_bool("gun_fullauto", false));
	//reloading
	this.set_u16("gun_clip_size", cfg.read_u16("gun_clip_size", 100));
	this.set_u16("gun_reload_ticks", cfg.read_u16("gun_reload_ticks", 60));
	this.set_u16("gun_reload_timer", 0);
	this.set_bool("gun_start_loaded", cfg.read_bool("gun_start_loaded", true));
	if(this.get_bool("gun_start_loaded")) {
		this.set_u16("gun_ammo", this.get_u16("gun_clip_size"));
	} else {
		this.set_u16("gun_ammo", 0);
	}
	//bullet parameters
	this.set_f32("gun_damage", cfg.read_f32("gun_damage", 1.0f));
	this.set_f32("gun_speedmin", cfg.read_f32("gun_speedmin", 12.0f)); // was 25.0f
	this.set_f32("gun_speedmax", cfg.read_f32("gun_speedmax", 13.0f)); // was 25.0f apparently the cfg doesn't work for the speed? - nein, it was because of line 195
	this.set_f32("gun_spread_angle", cfg.read_f32("gun_spread_angle", 5.0f));
	this.set_f32("gun_bullet_life", cfg.read_f32("gun_bullet_life", 1.3f));
	this.set_f32("gun_bullet_gravity", cfg.read_f32("gun_bullet_gravity", 0.8f));

	//effects
	this.set_string("gun_firesound", cfg.read_string("gun_firesound", "M16Fire.ogg"));
	this.set_string("gun_reload_start_sound", cfg.read_string("gun_reload_start_sound", "Construct.ogg"));
	this.set_string("gun_reload_end_sound", cfg.read_string("gun_reload_end_sound", "Construct.ogg"));

	//note: we're not doing any of the attachment point button-stealing stuff
	//		as there is a bug in the engine, so it doesn't work properly on net.
	//		if you want to block behaviours when something is attached
	//		do so in the actor's code probably.
	this.Tag("heavy");
}

void onTick(CBlob@ this)
{
	if (this.isAttached())
	{
		this.getCurrentScript().runFlags &= ~Script::tick_not_sleeping;

		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		CBlob@ holder = point.getOccupied();
		if (holder is null) { return; }

		CShape@ shape = this.getShape();
		CSprite@ sprite = this.getSprite();
		const f32 aimangle = getAimAngle(this,holder);

		// face towards mouse cursor
		sprite.ResetTransform();
		sprite.RotateBy(aimangle, holder.isFacingLeft() ? Vec2f(-8,2) : Vec2f(8,2));
		// reset frame (set by fire event)
		sprite.animation.frame = 0;

		//handle reload
		UpdateReload(this);

		// fire if appropriate
		if (holder.isMyPlayer())
		{
			//print("gun_fire_delay_timer "+this.get_u16(gun_fire_delay_timer));
			//print("key_pressed "+this.get_u16(gun_fire_delay_timer));

			//this timer is only relevant on the client who owns the gun
			//- so we cant check canFire on anyone else's machine, we just trust the client
			ReduceU16CounterProperty(this, "gun_fire_delay_timer");
			if (canFire(this))
			{
				if (//full auto and held
					(holder.isKeyPressed(key_action1) && this.get_bool("gun_fullauto")) ||
					//not full auto and just pulled trigger
					holder.isKeyJustPressed(key_action1))
				{
					Shoot(this, aimangle, holder);
				}
			}
		}
	}
	else
	{
		this.getCurrentScript().runFlags |= Script::tick_not_sleeping;
	}
}

f32 getAimAngle(CBlob@ this, CBlob@ holder)
{
	Vec2f aimvector = holder.getAimPos() - this.getPosition();
	return holder.isFacingLeft() ? -aimvector.Angle()+180.0f : -aimvector.Angle();
}

void Shoot(CBlob@ this, const f32 aimangle, CBlob@ holder)
{
	//bundle up the command
	CBitStream params;
	params.write_Vec2f(this.getPosition());
	params.write_f32(aimangle);
	params.write_netid(holder.getNetworkID());
	this.SendCommand(this.getCommandID("shoot"), params);
	//set the fire delay timer
	this.set_u16("gun_fire_delay_timer", this.get_u16("gun_fire_delay_ticks"));
}


void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
   if (cmd == this.getCommandID("shoot"))
   {
     Vec2f pos = params.read_Vec2f();
     f32 angle = params.read_f32();
     u16 holder_id = params.read_netid();
     CBlob@ holder = getBlobByNetworkID(holder_id);

     //holder dead on server? do nothing
     if (holder is null) {
       return;
     }

     //take a bullet
     TakeBullet(this);

     //effects before we try to create anything
     {
       CSprite@ sprite = this.getSprite();
       // animate muzzle fire
       sprite.animation.frame = 1 + XORRandom(3);
       // pull back
       sprite.TranslateBy(Vec2f(1.0f, 0.0));
       //play sound
       sprite.PlaySound(this.get_string("gun_firesound"));
     }
     // shell particle
     {
       Vec2f velr = getRandomVelocity(30, 4.3f, 40.0f) * 0.1f;
       velr.x *= (this.isFacingLeft() ? 1.0f : -1.0f);
       ParticlePixel(this.getPosition(), velr,
         SColor(255,255,197,47), true);
     }

     //all the rest is about constructing
     if (!getNet().isServer()) {
       return;
     }
     

	 Random _r(getGameTime() + holder_id);
	f32 speedmin = this.get_f32("gun_speedmin");
     f32 speedmax = this.get_f32("gun_speedmax");
	 for (int i = 0; i < 4; ++i) // tweak for the shotgun effect by Asu
	 {
     
       //decide the random speed
       f32 speed = (_r.NextFloat() * (speedmax - speedmin)) + speedmin;
       Vec2f velocity(speed, 0);
       //apply random spread
       velocity.RotateBy((_r.NextFloat() - 0.5) * this.get_f32("gun_spread_angle"));
	   
       
       //initialise the bullet and set it up properly
       CBlob@ bullet = server_CreateBlobNoInit("angelshell");
       if (bullet !is null)
       {
         float cangle = angle;
         
         Vec2f offset(15,0); // was 15,0

         if (this.isFacingLeft())
         {
           offset.RotateBy(cangle, Vec2f(-12,-2));
           bullet.setPosition(pos - offset);
           cangle += 180.0f;
         }
         else
         {
           offset.RotateBy(cangle, Vec2f(-12,-2));
           bullet.setPosition(pos + offset);
         }

         velocity.RotateBy(cangle);
         bullet.setVelocity(velocity * 1); // was multiplied by 25 in the original

         bullet.IgnoreCollisionWhileOverlapped(holder);
         bullet.SetDamageOwnerPlayer(holder.getPlayer());
         bullet.server_setTeamNum(holder.getTeamNum());
         bullet.set_f32("damage", this.get_f32("gun_damage"));
         bullet.set_f32("gravity", this.get_f32("gun_bullet_gravity"));
         bullet.server_SetTimeToDie(this.get_f32("gun_bullet_life"));

         bullet.Init(); //done - initialise it and send it off
       }
     }
   }
}

//count a timer/counter down to zero
//if it hit zero (this cycle) - return true, otherwise false
bool ReduceU16CounterProperty(CBlob@ this, string name)
{
	bool hit_zero = false;
	u16 counter = this.get_u16(name);
	if (counter > 0)
	{
		counter--;
		if(counter == 0)
		{
			hit_zero = true;
		}
	}
	this.set_u16(name, counter);
	return hit_zero;
}

//reloading handling
//
//	gun_ammo is how many bullets we have
//		it ticks down every time we fire
//		when we hit zero, we "reload"
//	when we reload:
//	gun_reload_timer is usually zero
//		when we reload we set it to gun_reload_ticks
//		and tick it down every frame

void UpdateReload(CBlob@ this)
{
	if(ReduceU16CounterProperty(this, "gun_reload_timer"))
	{
		this.set_u16("gun_ammo", this.get_u16("gun_clip_size"));
		//play reload sound
		{
			CSprite@ sprite = this.getSprite();
			sprite.PlaySound(this.get_string("gun_reload_end_sound"));
		}
	}
}

//can we fire now (do we have bullets/have we cooled down enough)
bool canFire(CBlob@ this)
{
	return this.get_u16("gun_ammo") > 0 && this.get_u16("gun_fire_delay_timer") == 0;
}

//take a bullet (ie, we just fired)
void TakeBullet(CBlob@ this)
{
	if(ReduceU16CounterProperty(this, "gun_ammo"))
	{
		this.server_SetTimeToDie(1);
	}
}


//interaction handling

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	//set so we update "all the time" when picked up
	this.getCurrentScript().runFlags &= ~Script::tick_not_sleeping;
	//and set so that any damage we do now, will be treated as done by whoever's holding us
	this.SetDamageOwnerPlayer(attached.getPlayer());
	//AND reset the fire delay timer so you cant shoot as soon as you pick it up
	//(this also mitigates desync on this clientside timer)
	this.set_u16("gun_fire_delay_timer", this.get_u16("gun_fire_delay_ticks"));
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint @detachedPoint)
{

	CSprite@ sprite = this.getSprite();
	sprite.ResetTransform();
	sprite.animation.frame = 0;
	this.setAngleDegrees(getAimAngle(this,detached));
}
