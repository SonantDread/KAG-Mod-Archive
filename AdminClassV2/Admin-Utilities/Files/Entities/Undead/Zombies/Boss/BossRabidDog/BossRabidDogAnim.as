// Aphelion \\

const string chomp_tag = "chomping";

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	
	if (blob.hasTag("dead"))
	{
	    if(!this.isAnimation("dead"))
	    {
			this.SetAnimation("dead");
            this.PlaySound("/dog_die1");
	    }
		return;
	}
	const bool left = blob.isKeyPressed(key_left);
	const bool right = blob.isKeyPressed(key_right);
	const bool up = blob.isKeyPressed(key_up);
	const bool down = blob.isKeyPressed(key_down);
	const bool inair = (!blob.isOnGround() && !blob.isOnLadder());
	
	if(inair) 
	{
		if (!this.isAnimation("jump"))
			 this.SetAnimation("jump");
	}
	else if(blob.hasTag(chomp_tag))
	{
		if (!this.isAnimation("bite"))
		{
			int zGrowl = XORRandom(7);
			if (zGrowl<=2)
			this.PlaySound( "/dog_attack3", 0.25f );
			if (zGrowl>=3 && zGrowl<=5)
			this.PlaySound( "/dog_attack2", 0.25f );
			if (zGrowl==6)
			this.PlaySound( "/dog_attack1", 0.25f );
			this.SetAnimation("bite");				 
			return;
		}
	}
	
	else if ((left || right) || (blob.isOnLadder() && (up || down)))
	{
		if (!this.isAnimation("walk"))
			 this.SetAnimation("walk");
	}
	else
	{
		if (!this.isAnimation("default")) 
		{
			int zGrowl = XORRandom(7);
			if (zGrowl==0)
			this.PlaySound( "/dog_growl1" );
			if (zGrowl==1)
			this.PlaySound( "/dog_growl2" );
			if (zGrowl==2)
			this.PlaySound( "/dog_growl3" );
			this.SetAnimation("default");
			return;	
		}
	}
}

void onGib(CSprite@ this)
{
    if (g_kidssafe)
        return;
	
    CBlob@ blob = this.getBlob();
    Vec2f pos = blob.getPosition();
    Vec2f vel = blob.getVelocity();
	vel.y -= 3.0f;
    f32 hp = Maths::Min(Maths::Abs(blob.getHealth()), 2.0f) + 1.0;
	const u8 team = blob.getTeamNum();
    CParticle@ Body     = makeGibParticle( "Entities\Undead\Zombies\Boss\BossRabidDog\BossRabidDogGibs.png", pos, vel + getRandomVelocity( 90, hp , 80 ),       0, 0, Vec2f (8,8), 2.0f, 20, "/BodyGibFall", team );
    CParticle@ Arm1     = makeGibParticle( "Entities\Undead\Zombies\Boss\BossRabidDog\BossRabidDogGibs.png", pos, vel + getRandomVelocity( 90, hp - 0.2 , 80 ), 0, 1, Vec2f (8,8), 2.0f, 20, "/BodyGibFall", team );
    CParticle@ Arm2     = makeGibParticle( "Entities\Undead\Zombies\Boss\BossRabidDog\BossRabidDogGibs.png", pos, vel + getRandomVelocity( 90, hp - 0.2 , 80 ), 0, 2, Vec2f (8,8), 2.0f, 20, "/BodyGibFall", team );
    CParticle@ Shield   = makeGibParticle( "Entities\Undead\Zombies\Boss\BossRabidDog\BossRabidDogGibs.png", pos, vel + getRandomVelocity( 90, hp , 80 ),       0, 3, Vec2f (8,8), 2.0f, 0, "/BodyGibFall", team );
    CParticle@ Sword    = makeGibParticle( "Entities\Undead\Zombies\Boss\BossRabidDog\BossRabidDogGibs.png", pos, vel + getRandomVelocity( 90, hp + 1 , 80 ),   0, 4, Vec2f (8,8), 2.0f, 0, "/BodyGibFall", team );
}