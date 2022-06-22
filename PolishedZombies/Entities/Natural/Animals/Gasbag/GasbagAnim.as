void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	
	if (blob.hasTag("dead"))
	{
		this.PlaySound("/SkeletonBreak1");
	    this.getCurrentScript().runFlags |= Script::remove_after_this;
		return;
	}

	if    (blob.getBrain().getTarget() !is null || blob.hasTag("enraged"))
	{
		if (!this.isAnimation("attack"))
			this.SetAnimation("attack");
	}
	else if(!blob.isOnGround() && !blob.isOnLadder()) 
	{
		if (!this.isAnimation("fly"))
			this.SetAnimation("fly");
	}
	else if (!this.isAnimation("walk"))
			 this.SetAnimation("walk");
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