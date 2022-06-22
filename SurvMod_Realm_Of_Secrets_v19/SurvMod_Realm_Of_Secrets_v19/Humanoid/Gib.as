// Flesh hit

#include "LimbsCommon.as"

f32 getGibHealth(CBlob@ this)
{
	if (this.exists("gib health"))
	{
		return this.get_f32("gib health");
	}

	return 0.0f;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	this.Damage(damage, hitterBlob);
	// Gib if health below gibHealth
	f32 gibHealth = getGibHealth(this);

	//printf("ON HIT " + damage + " he " + this.getHealth() + " g " + gibHealth );
	// blob server_Die()() and then gib


	//printf("gibHealth " + gibHealth + " health " + this.getHealth() );
	if (this.getHealth() <= gibHealth)
	{
		if(!this.hasTag("gibbed")){
			if(this.get_u8("tors_type") == BodyType::Golem){
			for(int i = 0;i < 10;i++)makeGibParticle("GenericGibs", this.getPosition(), getRandomVelocity(270, 1.0f, 90.0f) + Vec2f(0.0f, -1.0f),2, 4 + XORRandom(4), Vec2f(8, 8), 2.0f, 0, "", 0);
			}
			if(this.get_u8("tors_type") == BodyType::Wood){
				for(int i = 0;i < 10;i++)makeGibParticle("/GenericGibs", this.getPosition(), getRandomVelocity(270, 1.0f, 90.0f) + Vec2f(0.0f, -1.0f),1, 4 + XORRandom(4), Vec2f(8, 8), 2.0f, 0, "", 0);
			}
			if(isLivingFlesh(this.get_u8("tors_type"))){
				for(int i = 0;i < 10;i++)makeGibParticle("/GenericGibs", this.getPosition(), getRandomVelocity(270, 1.0f, 90.0f) + Vec2f(0.0f, -1.0f),4, 4 + XORRandom(4), Vec2f(8, 8), 2.0f, 0, "", 0);
			}
			if(this.get_u8("tors_type") == BodyType::Zombie){
				for(int i = 0;i < 10;i++)makeGibParticle("/GenericGibs", this.getPosition(), getRandomVelocity(270, 1.0f, 90.0f) + Vec2f(0.0f, -1.0f),6, 4 + XORRandom(4), Vec2f(8, 8), 2.0f, 0, "", 0);
			}
			
			this.Tag("gibbed");
		}
		
		this.getSprite().Gib();
		this.server_Die();
	}

	return 0.0f; //done, we've used all the damage
}

void onDie(CBlob@ this)
{
	if (!this.hasTag("switch class") && !this.hasTag("gibbed"))
	{
		if(this.get_u8("tors_type") == BodyType::Golem){
		for(int i = 0;i < 10;i++)makeGibParticle("GenericGibs", this.getPosition(), getRandomVelocity(270, 1.0f, 90.0f) + Vec2f(0.0f, -1.0f),2, 4 + XORRandom(4), Vec2f(8, 8), 2.0f, 0, "", 0);
		}
		if(this.get_u8("tors_type") == BodyType::Wood){
			for(int i = 0;i < 10;i++)makeGibParticle("/GenericGibs", this.getPosition(), getRandomVelocity(270, 1.0f, 90.0f) + Vec2f(0.0f, -1.0f),1, 4 + XORRandom(4), Vec2f(8, 8), 2.0f, 0, "", 0);
		}
		if(isLivingFlesh(this.get_u8("tors_type"))){
			for(int i = 0;i < 10;i++)makeGibParticle("/GenericGibs", this.getPosition(), getRandomVelocity(270, 1.0f, 90.0f) + Vec2f(0.0f, -1.0f),4, 4 + XORRandom(4), Vec2f(8, 8), 2.0f, 0, "", 0);
		}
		if(this.get_u8("tors_type") == BodyType::Zombie){
			for(int i = 0;i < 10;i++)makeGibParticle("/GenericGibs", this.getPosition(), getRandomVelocity(270, 1.0f, 90.0f) + Vec2f(0.0f, -1.0f),6, 4 + XORRandom(4), Vec2f(8, 8), 2.0f, 0, "", 0);
		}
		
		this.Tag("gibbed");
	}
}