#include "MakeScroll.as";
// Flesh hit

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

	if (this.getHealth() <= gibHealth)
	{
		if (this.hasTag("boss"))
		{
			bool scrolls_spawn = getRules().get_bool("scrolls_spawn");
			if (scrolls_spawn)
			{
				int r = XORRandom(16);
				if (r == 0)
					server_MakePredefinedScroll(this.getPosition() + Vec2f(0,-16.0), "carnage");
				else
				if (r == 1)
					server_MakePredefinedScroll(this.getPosition() + Vec2f(0,-16.0), "midas");				
				else
				if (r == 2)
					server_MakePredefinedScroll(this.getPosition() + Vec2f(0,-16.0), "tame");				
				else
				if (r == 3)
					server_MakePredefinedScroll(this.getPosition() + Vec2f(0,-16.0), "necro");	
				else
				if (r == 4)
					server_MakePredefinedScroll(this.getPosition() + Vec2f(0,-16.0), "stone");
				else
				if (r == 5)
					server_MakePredefinedScroll(this.getPosition() + Vec2f(0,-16.0), "light");
				else
				if (r == 6)
					server_MakePredefinedScroll(this.getPosition() + Vec2f(0,-16.0), "bison");
				else
				if (r == 7)
					server_MakePredefinedScroll(this.getPosition() + Vec2f(0,-16.0), "healing");	
				else
				if (r == 8)
					server_MakePredefinedScroll(this.getPosition() + Vec2f(0,-16.0), "drought");
				else
				if (r == 9)
					server_MakePredefinedScroll(this.getPosition() + Vec2f(0,-16.0), "shark");
				else
				if (r == 10)
					server_MakePredefinedScroll(this.getPosition() + Vec2f(0,-16.0), "horde");
				else
				if (r == 11)
					server_MakePredefinedScroll(this.getPosition() + Vec2f(0,-16.0), "meteor");
				else
				if (r == 12)
					server_MakePredefinedScroll(this.getPosition() + Vec2f(0,-16.0), "chicken");
				else
				if (r == 13)
					server_MakePredefinedScroll(this.getPosition() + Vec2f(0,-16.0), "return");
				else
				if (r == 14)
					server_MakePredefinedScroll(this.getPosition() + Vec2f(0,-16.0), "skeleton");
				else
				if (r == 15)
					server_MakePredefinedScroll(this.getPosition() + Vec2f(0,-16.0), "zombie");
			}
		}
	    server_DropCoins(this.getPosition() + Vec2f(0, -3.0f), this.get_u16("coins on death"));

		this.getSprite().Gib();
		this.server_Die();
	}

	return 0.0f; //done, we've used all the damage
}
