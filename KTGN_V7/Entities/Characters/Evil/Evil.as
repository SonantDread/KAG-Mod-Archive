#include "Knocked.as";
void onInit(CBlob@ this)
{
	this.Tag("evil");
	/*int num = getPlayerCount();
	num = Maths::Floor(num / 10.0f);
	for(int i = 0; i < num; i++)
	{
		CBlob@ b = server_CreateBlob("sentinel", this.getTeamNum(), this.getPosition());
		b.set_u16("owner", this.getNetworkID());
	}*/
}
f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	if(!this.hasTag("splorb") && this.getHealth() <= this.getInitialHealth() / 2 )
	{
		print("splorble");
		CBlob@[] nearblobs;
		getMap().getBlobsInRadius(this.getPosition(), 50, @nearblobs);
		for(int i = 0; i < nearblobs.length; i++)
		{
			CBlob@ nearblob = nearblobs[i];
			if(nearblob !is null && nearblob.getTeamNum() != this.getTeamNum() && nearblob.hasTag("player"))
			{
				Vec2f vel = nearblob.getPosition() - this.getPosition();
				vel.Normalize();
				vel *= 40; //FUS ROH DAH
				nearblob.setVelocity(vel);
				SetKnocked( nearblob, 180 );
			}
			this.getSprite().PlaySound("/EvilLaughShort1.ogg");
		}
		this.Tag("splorb");
	}
	return damage;
}