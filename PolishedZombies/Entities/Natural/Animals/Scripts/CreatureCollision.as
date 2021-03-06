bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if(this.getTeamNum() == blob.getTeamNum() && (blob.hasTag("player") || blob.hasTag("migrant") || blob.hasTag("bot")))
		return false;
    // when dead, collide only if its moving and some time has passed after death
	if (this.hasTag("dead"))
	{
        CShape@ oShape = blob.getShape();
		bool slow = (this.getShape().vellen < 1.5f);
        //static && collidable should be doors/platform etc             fast vel + static and !player = other entities for a little bit (land on the top of ballistas).
		return (oShape.isStatic() && oShape.getConsts().collidable) || (!slow && oShape.isStatic() && !blob.hasTag("player"));
	}
	return true;
}