// Princess brain

#include "BrainCommon.as"
#include "Hitters.as";
#include "HittersTC.as";
#include "Explosion.as";
#include "FireParticle.as"
#include "FireCommon.as";
#include "RunnerCommon.as";

void onInit( CBrain@ this )
{
	if (getNet().isServer())
	{
		InitBrain( this );
		this.server_SetActive( true ); // always running
	}
}

void onInit(CBlob@ this)
{
	this.Tag("npc");
	this.Tag("flesh");
	this.Tag("dangerous");
	
	this.SetLight(true);
	this.SetLightRadius(16.0f);
	this.SetLightColor(SColor(255, 25, 255, 100));
	
	this.server_setTeamNum(230);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return this.hasTag("dead");
}

void onTick(CBlob@ this)
{
	RunnerMoveVars@ moveVars;
	if (this.get("moveVars", @moveVars))
	{
		moveVars.walkFactor *= 0.40f;
		moveVars.jumpFactor *= 0.75f;
	}

	if (this.getHealth() < 1.0 && !this.hasTag("dead"))
	{
		this.Tag("dead");
		this.getSprite().PlaySound("MithrilMan_Scream_0.ogg", 1.0f, 1.0f);
		
		Explode(this, 32.0f, 4.0f);
			
			for (int i = 0; i < 6; i++)
			{
				CBlob@ blob = server_CreateBlob("mat_mithril", this.getTeamNum(), this.getPosition());
				
				if (blob !is null)
				{
					blob.server_SetQuantity(5 + XORRandom(10));
					blob.setVelocity(Vec2f(4 - XORRandom(2), -2 - XORRandom(4)));
				}
			}
		
		if (getNet().isServer() && this.getPlayer() !is null) this.server_SetPlayer(null);
		this.getCurrentScript().runFlags |= Script::remove_after_this;
	}

	if (getNet().isClient())
	{
		if (getGameTime() > this.get_u32("next sound") && XORRandom(100) < 5)
		{
			this.getSprite().PlaySound("MithrilMan_Scream_" + XORRandom(4) + ".ogg", 0.7f, 1.0f);
			this.set_u32("next sound", getGameTime() + 210);
		}
	}
	
	if (getNet().isServer())
	{
		if (XORRandom(100) == 0)
		{
			CBlob@ blob = server_CreateBlob("mat_mithril", this.getTeamNum(), this.getPosition());
			blob.server_SetQuantity(5 + XORRandom(10));
			
			this.server_Hit(this, this.getPosition(), Vec2f(), 0.25f, Hitters::stab, true);
		}
	}
	
	if (XORRandom(10) == 0) 
	{
		// if (getNet().isClient())
		// {
			// // I know it's unrealistic, but people kept complaining about 'random' damage. Hopefully this'll give them the idea. :v
			// // ...Let's say that KAG players have a built-in Geiger counter.
			// // -- TFlippy
			
			// this.getSprite().PlaySound("geiger" + XORRandom(3) + ".ogg", 0.7f, 1.0f);
		// }
	
		if (getNet().isServer())
		{
			CBlob@[] blobsInRadius;
			if (this.getMap().getBlobsInRadius(this.getPosition(), 64, @blobsInRadius))
			{
				for (int i = 0; i < blobsInRadius.length; i++)
				{
					CBlob@ blob = blobsInRadius[i];
					if (!blob.hasTag("flesh") || blob.hasTag("dead")) continue;
					
					f32 distMod = Maths::Max(0, (1.00f - ((this.getPosition() - blob.getPosition()).Length() / 64)));
					if (XORRandom(100) < 100.0f * distMod) 
					{
						this.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), 0.125f, HittersTC::radiation, true);
						
						if (blob.hasTag("human") && !blob.hasTag("transformed") && blob.getHealth() <= 0.125f && XORRandom(3) == 0)
						{
							CBlob@ man = server_CreateBlob("mithrilman", blob.getTeamNum(), blob.getPosition());
							if (blob.getPlayer() !is null) man.server_SetPlayer(blob.getPlayer());
							blob.Tag("transformed");
							blob.server_Die();
						}
					}
				}
			}
		}
	}
}

void onTick(CBrain@ this)
{
	if (!getNet().isServer()) return;

	CBlob @blob = this.getBlob();
	
	if (blob.getPlayer() !is null) return;
	
	SearchTarget(this, false, true);
	CBlob @target = this.getTarget();
	
	this.getCurrentScript().tickFrequency = 30;
	if (target !is null)
	{
		this.getCurrentScript().tickFrequency = 1;

		const f32 distance = (target.getPosition() - blob.getPosition()).getLength();
		f32 visibleDistance;
		const bool visibleTarget = isVisible( blob, target, visibleDistance);
		
		if (target.hasTag("dead") || distance > 200.0f) 
		{
			CPlayer@ targetPlayer = target.getPlayer();
			
			this.SetTarget(null);
			return;
		}
		else if (target.isOnGround())
		{
			DefaultChaseBlob(blob, target);
		}
		
		LoseTarget(this, target);
	}
	else
	{
		if (XORRandom(100) < 50) RandomTurn(blob);		
	}

	FloatInWater(blob); 
} 

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	switch (customData)
	{
		case HittersTC::radiation:
			return 0;
			break;
		
		// Kill it with fire
		case Hitters::fire:
		case Hitters::burn:
			damage *= 4.00f;
			break;			
	}

	if (getNet().isClient())
	{
		if (getGameTime() > this.get_u32("next sound") - 25)
		{
			this.getSprite().PlaySound("MithrilMan_Scream_" + (1 + XORRandom(2)) + ".ogg", 1, 0.8f);
			this.set_u32("next sound", getGameTime() + 100);
		}
	}
	
	if (getNet().isServer())
	{
		CBrain@ brain = this.getBrain();
		
		if (brain !is null && hitterBlob !is null)
		{
			if (hitterBlob.getTeamNum() != this.getTeamNum()) brain.SetTarget(hitterBlob);
		}
	}
		
	return damage;
}