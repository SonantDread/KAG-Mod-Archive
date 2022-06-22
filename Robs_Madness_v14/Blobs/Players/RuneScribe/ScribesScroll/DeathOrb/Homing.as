void onTick(CBlob@ this)
{
	CBlob @closest = null;
	int Distance = 320;
	
	CBlob@[] blobsInRadius;	   
	if (this.getMap().getBlobsInRadius(this.getPosition(), 320.0f, @blobsInRadius)) 
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			if(b.hasTag("flesh") && !b.hasTag("dead"))
			{
				if(b.getDistanceTo(this) < Distance){
					Distance = b.getDistanceTo(this);
					@closest = b;
				}
				
			}
		}
	}
	
	if(closest !is null){
		Vec2f Vel = closest.getPosition()-this.getPosition();
		Vel.Normalize();
		this.AddForce(Vel*0.3);
	}
}