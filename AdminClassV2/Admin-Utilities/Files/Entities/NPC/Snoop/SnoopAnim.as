const string chomp_tag = "chomping";

void onInit(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
    this.ReloadSprites(blob.getTeamNum(),0); 
	this.ScaleBy(Vec2f(0.3,0.19f));
}

/*void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	
	if (blob.hasTag("dead"))
	{
		if (!this.isAnimation("dead"))
			this.PlaySound("/TraderScream");

		this.SetAnimation("dead");

		if (blob.isOnGround())
		{
			this.SetFrameIndex(0);
		}
		else
		{
			this.SetFrameIndex(1);
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
}*/
void onTick( CSprite@ this )
{
    // store some vars for ease and speed
    CBlob@ blob = this.getBlob(); 
    if(blob.getShape().isStatic()) //check frozen
    {
		this.SetAnimation("default");
		return;
	}

	if (blob.hasTag("dead")) //check dead
	{
		Vec2f vel = blob.getVelocity();
		this.SetAnimation("dead");

		if (vel.y < -1.0f) {
			this.SetFrameIndex( 0 );
		}
		else {
			this.SetFrameIndex( 1 );
		}
		return;
	}	      						   
    
	// get facing
   	const bool inair = (!blob.isOnGround() && !blob.isOnLadder());
	const bool left = blob.isKeyPressed(key_left);
	const bool right = blob.isKeyPressed(key_right);
	const bool up = blob.isKeyPressed(key_up);
	const bool down = blob.isKeyPressed(key_down);

	if (inair)
	{
		this.SetAnimation("fall");
		Vec2f vel = blob.getVelocity();
		f32 vy = vel.y;
		this.animation.timer = 0;

		if (vy < -1.5 || up) {
			this.animation.frame = 0;
		}
		else {
			this.animation.frame = 1;
		}
	}
	else if (left || right ||
			 (blob.isOnLadder() && (up || down) ) )
	{
		this.SetAnimation("run");
	}
	else
	{
		this.SetAnimation("default");
	}
    
    //set the attack/dead heads when needed
    if (blob.isKeyPressed(key_action2) || blob.isInFlames())
    {
        blob.Tag("attack head");
    }
    else //default head
    {
        blob.Untag("attack head");
        blob.Untag("dead head");
    }
}
