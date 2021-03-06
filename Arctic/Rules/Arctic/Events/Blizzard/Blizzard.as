//int timetodie = 0;
//int special = 0;

void onInit(CBlob@ this)
{
	this.getShape().SetStatic(true);
	//this.getCurrentScript().tickFrequency = 1;
	
	this.getShape().SetRotationsAllowed(true);
	
	getMap().CreateSkyGradient("skygradient_blizzard.png");
	
	if (getNet().isServer())
	{
		this.server_SetTimeToDie(60);
	}
	int timetodie = this.getTimeToDie()*30;
	this.set_s32("timetodie", timetodie);
	this.Sync("timetodie", false);
	//special = 0;
	//offsety = 0;
}

const int spritesize = 256;
f32 speed = 5.0f;
f32 offsety = 0;
f32 modifier_raw = 1;
f32 modifier = 1;

void onInit(CSprite@ this)
{
	//this.getConsts().accurateLighting = false;
	
	if (getNet().isClient())
	{
		Vec2f size = Vec2f(6, 5);
		
		for (int y = 0; y < size.y; y++)
		{
			for (int x = 0; x < size.x; x++)
			{
				CSpriteLayer@ l = this.addSpriteLayer("l_x" + x + "y" + y, "Blizzard.png", spritesize, spritesize, this.getBlob().getTeamNum(), 0);
				l.SetOffset(Vec2f(x * spritesize, y * spritesize) - (Vec2f(size.x * spritesize, size.y * spritesize) / 2));
				l.SetLighting(false);
				l.SetRelativeZ(-600);
			}
		}
		
		this.SetEmitSound("blizzard_loop2.ogg");
		this.SetEmitSoundPaused(false);
	}
}

void onTick(CBlob@ this)
{
	//if (getNet().isServer())
	//{
	//	if(timetodie-this.getTickSinceCreated() > this.getTickSinceCreated())
	//		special = this.getTickSinceCreated();
	//	else
	//		special = (timetodie-this.getTickSinceCreated());
		
	//	this.set_s32("special", special);
	//}
	if (getNet().isClient())
	{
		CBlob@ blob = getLocalPlayerBlob();
		CSprite@ sprite = this.getSprite();
		Vec2f bpos = this.getPosition();
		if (blob !is null) bpos = blob.getPosition();

		//Vec2f pos = Vec2f(int(bpos.x / spritesize) * spritesize, int(bpos.y / spritesize) * spritesize);
		Vec2f pos = Vec2f((int(bpos.x / spritesize) * spritesize)+(spritesize/2), (int(bpos.y / spritesize) * spritesize)+(spritesize/2));
		this.setPosition(pos);

		Vec2f size = Vec2f(6, 5);
		f32 sine = Maths::Sin(getGameTime() * 0.0025f);
		speed = 6.0f + sine * 4.0f;

		this.getSprite().SetEmitSoundSpeed(0.6f + sine * 0.4f);

		Vec2f hit;
		if (getMap().rayCastSolidNoBlobs(Vec2f(bpos.x, 0), bpos, hit))
		{
			f32 depth = Maths::Abs(bpos.y - hit.y) / 8.0f;
			modifier_raw = 1.0f - Maths::Clamp(depth / 8.0f, 0.25, 1);
		}
		else
		{
			modifier_raw = 1;
		}
			
		modifier = Lerp(modifier, modifier_raw, 0.06f);
		//print("modifier: "+modifier);
		this.set_f32("modifier", modifier);
		//this.Sync("modifier", false);
		Vec2f fixpos = pos-bpos;
		f32 fix = fixpos.getLength();
		this.getSprite().SetEmitSoundVolume(modifier);
			
		this.getShape().SetAngleDegrees(30 + sine * 30.0f);

		offsety = offsety+speed;
		if(offsety >= spritesize)
			offsety = offsety-spritesize;

		for (int y = 0; y < size.y; y++)
		{
			for (int x = 0; x < size.x; x++)
			{
				CSpriteLayer@ l = sprite.getSpriteLayer("l_x" + x + "y" + y);
				l.SetOffset(Vec2f(x * spritesize, y * spritesize) - (Vec2f(size.x * spritesize, size.y * spritesize) / 2) + Vec2f(0,offsety));
			}
		}
	}
}

f32 Lerp(f32 v0, f32 v1, f32 t) 
{
	return v0 + t * (v1 - v0);
}

void onDie(CBlob@ this)
{
	getMap().CreateSkyGradient("skygradient.png");
}