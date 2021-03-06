const string chomp_tag = "chomping";

void onInit(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
    this.ReloadSprites(blob.getTeamNum(), 0);
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	
	if (blob.hasTag("dead"))
	{
	    if (!this.isAnimation("dead"))
	    {
			this.SetAnimation("dead");
            this.PlaySound("/ZombieDie");
	    }
		return;
	}

	const bool left = blob.isKeyPressed(key_left);
	const bool right = blob.isKeyPressed(key_right);
	const bool up = blob.isKeyPressed(key_up);
	const bool down = blob.isKeyPressed(key_down);
	const bool inair = (!blob.isOnGround() && !blob.isOnLadder());
	
	if (inair)
	{
		if (!this.isAnimation("jump"))
			 this.SetAnimation("jump");
	}
	else if (blob.hasTag(chomp_tag))
	{
		if (!this.isAnimation("attack"))
			 this.SetAnimation("attack");
	}
	else if ((left || right) ||
             (blob.isOnLadder() && (up || down)))
	{
		if (!this.isAnimation("walk"))
			 this.SetAnimation("walk");
	}
	else
	{
		if (!this.isAnimation("default"))
			 this.SetAnimation("default");
	}
}

void onGib(CSprite@ this)
{
    if (g_kidssafe)
        return;
	
	if (!getNet().isClient())
		return;
	
    CBlob@ blob = this.getBlob();
    Vec2f pos = blob.getPosition();
    Vec2f vel = blob.getVelocity();
	vel.y -= 3.0f;
    f32 hp = Maths::Min(Maths::Abs(blob.getHealth()), 2.0f) + 1.0;
	const u8 team = blob.getTeamNum();
    makeGibParticle("Entities/Creatures/Sprites/UndeadGibs.png", pos, vel + getRandomVelocity(90, hp , 80),       1, 0, Vec2f (8,8), 2.0f, 20, "/BodyGibFall", team);
    makeGibParticle("Entities/Creatures/Sprites/UndeadGibs.png", pos, vel + getRandomVelocity(90, hp - 0.2 , 80), 1, 1, Vec2f (8,8), 2.0f, 20, "/BodyGibFall", team);
    makeGibParticle("Entities/Creatures/Sprites/UndeadGibs.png", pos, vel + getRandomVelocity(90, hp - 0.2 , 80), 1, 2, Vec2f (8,8), 2.0f, 20, "/BodyGibFall", team);
    makeGibParticle("Entities/Creatures/Sprites/UndeadGibs.png", pos, vel + getRandomVelocity(90, hp , 80),       1, 3, Vec2f (8,8), 2.0f, 0, "/BodyGibFall", team);
    makeGibParticle("Entities/Creatures/Sprites/UndeadGibs.png", pos, vel + getRandomVelocity(90, hp + 1 , 80),   1, 4, Vec2f (8,8), 2.0f, 0, "/BodyGibFall", team);
}