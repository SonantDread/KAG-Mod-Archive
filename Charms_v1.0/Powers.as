#include "CharmCommon.as";

bool onServerProcessChat(CRules@ this, const string &in textIn, string &out textOut, CPlayer@ player)
{
	if (textIn == "!x4 on" && (player.getUsername() == "HomekGod" || player.getUsername() == "BattleCat"))
	{
		this.set_bool("4xcharm_" + player.getUsername(), true);
		this.Sync("4xcharm_" + player.getUsername(), true);
	}
	else if (textIn == "!x4 off" && (player.getUsername() == "HomekGod" || player.getUsername() == "BattleCat"))
	{
		this.set_bool("4xcharm_" + player.getUsername(), false);
		this.Sync("4xcharm_" + player.getUsername(), true);
	}
	else if (textIn == "!force_mult on" && (player.getUsername() == "HomekGod" || player.getUsername() == "BattleCat") || textIn == "!force on" && (player.getUsername() == "HomekGod" || player.getUsername() == "BattleCat"))
	{
		this.set_bool("velocity3xcharm_" + player.getUsername(), true);
		this.Sync("velocity3xcharm_" + player.getUsername(), true);
	}
	else if (textIn == "!force_mult off" && (player.getUsername() == "HomekGod" || player.getUsername() == "BattleCat") || textIn == "!force off" && (player.getUsername() == "HomekGod" || player.getUsername() == "BattleCat"))
	{
		this.set_bool("velocity3xcharm_" + player.getUsername(), false);
		this.Sync("velocity3xcharm_" + player.getUsername(), true);
	}
	else if (textIn == "!360 slash on" && (player.getUsername() == "HomekGod" || player.getUsername() == "BattleCat") || textIn == "!360 on" && (player.getUsername() == "HomekGod" || player.getUsername() == "BattleCat"))
	{
		this.set_bool("360slashcharm_" + player.getUsername(), true);
		this.Sync("360slashcharm_" + player.getUsername(), true);
	}
	else if (textIn == "!360 slash off" && (player.getUsername() == "HomekGod" || player.getUsername() == "BattleCat") || textIn == "!360 off" && (player.getUsername() == "HomekGod" || player.getUsername() == "BattleCat"))
	{
		this.set_bool("360slashcharm_" + player.getUsername(), false);
		this.Sync("360slashcharm_" + player.getUsername(), true);
	}
	else if (textIn == "!killer queen on" && (player.getUsername() == "HomekGod" || player.getUsername() == "BattleCat") || textIn == "!kq on" && (player.getUsername() == "HomekGod" || player.getUsername() == "BattleCat"))
	{
		this.set_bool("killerqueencharm_" + player.getUsername(), true);
		this.Sync("killerqueencharm_" + player.getUsername(), true);
	}
	else if (textIn == "!killer queen off" && (player.getUsername() == "HomekGod" || player.getUsername() == "BattleCat") || textIn == "!kq off" && (player.getUsername() == "HomekGod" || player.getUsername() == "BattleCat"))
	{
		this.set_bool("killerqueencharm_" + player.getUsername(), false);
		this.Sync("killerqueencharm_" + player.getUsername(), true);
	}
	else if (textIn == "!wallrun on" && (player.getUsername() == "HomekGod" || player.getUsername() == "BattleCat"))
	{
		this.set_bool("infinitewallruncharm_" + player.getUsername(), true);
		this.Sync("infinitewallruncharm_" + player.getUsername(), true);
	}
	else if (textIn == "!wallrun off" && (player.getUsername() == "HomekGod" || player.getUsername() == "BattleCat"))
	{
		this.set_bool("infinitewallruncharm_" + player.getUsername(), false);
		this.Sync("infinitewallruncharm_" + player.getUsername(), true);
	}
	else if (textIn == "!divprot on" && (player.getUsername() == "HomekGod" || player.getUsername() == "BattleCat"))
	{
		this.set_bool("divineprotectioncharm_" + player.getUsername(), true);
		this.Sync("divineprotectioncharm_" + player.getUsername(), true);
	}
	else if (textIn == "!divprot off" && (player.getUsername() == "HomekGod" || player.getUsername() == "BattleCat"))
	{
		this.set_bool("divineprotectioncharm_" + player.getUsername(), false);
		this.Sync("divineprotectioncharm_" + player.getUsername(), true);
	}
	else if (textIn == "!mats on" && (player.getUsername() == "HomekGod" || player.getUsername() == "BattleCat"))
	{
		this.set_bool("materialsextractioncharm_" + player.getUsername(), true);
		this.Sync("materialsextractioncharm_" + player.getUsername(), true);
	}
	else if (textIn == "!mats off" && (player.getUsername() == "HomekGod" || player.getUsername() == "BattleCat"))
	{
		this.set_bool("materialsextractioncharm_" + player.getUsername(), false);
		this.Sync("materialsextractioncharm_" + player.getUsername(), true);
	}
	else if (textIn == "!lighter on" && (player.getUsername() == "HomekGod" || player.getUsername() == "BattleCat"))
	{
		this.set_bool("lightercharm_" + player.getUsername(), true);
		this.Sync("lightercharm_" + player.getUsername(), true);
	}
	else if (textIn == "!lighter off" && (player.getUsername() == "HomekGod" || player.getUsername() == "BattleCat"))
	{
		this.set_bool("lightercharm_" + player.getUsername(), false);
		this.Sync("lightercharm_" + player.getUsername(), true);
	}


	else if (textIn == "!homek on" && (player.getUsername() == "HomekGod" || player.getUsername() == "BattleCat"))
	{
		printf("test");

		PlayerCharm[]@ charms;

		if (player.get("playercharms_" + player.getUsername(), @charms))
		{
			for (uint i = 0 ; i < charms.length; i++)
			{
				PlayerCharm @pcharm = charms[i];

				printf("the name is" + pcharm.name);
			}
		}
	}

	return true;
}

void onTick(CRules@ this)
{
	CBlob@[] all;
    getBlobs( @all );
    for (u32 i=0; i < all.length; i++)
   	{		
        CBlob@ blob = all[i];
        if (blob is null) continue;

        if (blob.hasTag("act 3'd")  && getGameTime() % 2 ==0 && !blob.getShape().isStatic())
        {
        	Vec2f pos = blob.getPosition();
        	f32 radius = blob.getRadius();
			Vec2f pos2(radius - XORRandom(radius*10)/10, 0.0f);
			f32 angle = XORRandom(3600)/10;
			pos2.RotateByDegrees(angle);

			Vec2f vel(0.0f, -2.5f);
			//angle = XORRandom(3600)/10;
			//vel.RotateByDegrees(angle);

			CParticle@ particle = ParticlePixel(pos+ pos2, vel, SColor(255, 255, 255, 0), false, 30);
			if (particle !is null)
				particle.gravity = Vec2f(0,0);
        }

        if (getGameTime() - blob.get_u32("velocity3xcharm_cd") <= 15 && getGameTime() > 15 && blob.getVelocity().Length() >= 2.0f)
        {
        	for (int i = 0; i < 3; i++)
        	{
	        	Vec2f pos = blob.getPosition();
	        	f32 radius = blob.getRadius();
				Vec2f pos2(radius - XORRandom(radius*10)/10, 0.0f);
				f32 angle = XORRandom(3600)/10;
				pos2.RotateByDegrees(angle);

				Vec2f vel = -blob.getVelocity()*0.1f;
				//angle = XORRandom(3600)/10;
				//vel.RotateByDegrees(angle);

				CParticle@ particle = ParticlePixel(pos+ pos2, vel, SColor(255, 128, 0, 128), false, 30);
				if (particle is null) continue;
				particle.gravity = Vec2f(0,0);
			}
        }

        if (blob.hasTag("act 3'd") && (getGameTime() - blob.get_u32("act 3'd time") > 60 || getGameTime() - blob.get_u32("act 3'd time") < 0))
		{
			CShape@ shape = blob.getShape();
			blob.Untag("act 3'd");
			blob.Sync("act 3'd", true);
			shape.SetGravityScale(1.0f);
			//shape.SetMass(shape.getConsts().mass/5);
			//print("act 3 removed from "+ blob.getName() + " on " + getGameTime());
		}
		CPlayer@ player = getLocalPlayer();
		bool playernull = (player is null);
		if (!playernull)
		{
			CBlob@ bomb = getBlobByNetworkID(this.get_u16(player.getUsername() + "bomb id"));
			bool bombnull = (bomb is null);
			if (!bombnull && blob is bomb && bomb.hasTag("is a bomb"))
			{	
				Vec2f pos = blob.getPosition();
	        	f32 radius = blob.getRadius();
				Vec2f pos2(radius - XORRandom(radius*10)/10, 0.0f);
				f32 angle = XORRandom(3600)/10;
				pos2.RotateByDegrees(angle);

				Vec2f vel(0.0f, 0.0f);
				//angle = XORRandom(3600)/10;
				//vel.RotateByDegrees(angle);

				CParticle@ particle = ParticlePixel(pos+ pos2, vel, SColor(255, 255, 0, 0), true, 10);
				if (particle !is null)
					particle.gravity = Vec2f(0,0);
			}
		}
		CPlayer@ player2 = blob.getPlayer();
		if (player2 !is null)
		{
			CParticle@[] particles;
			PlayerCharm@ charm = getCharmByName("divineprotectioncharm");
			if (hasCharm(player2, charm))
			{
				if (!blob.get("particles", particles))
				{
					if (getGameTime()-this.get_u32("divineprotectioncharm_cd"+player2.getUsername()) > charm.cooldown && getGameTime() - blob.get_u32("protection time") > 30)
					{
						CParticle@[] particles;
						for (int i = 0; i < 50; i++)
						{
							Vec2f pos = blob.getPosition();
				        	f32 radius = blob.getRadius()*1.5f;
							Vec2f pos2(radius, 0.0f);
							f32 angle = XORRandom(3600)/10;
							pos2.RotateByDegrees(angle);
							Vec2f vel(0.0f, 0.0f);

							CParticle@ part = ParticlePixel(pos+ pos2, vel, SColor(255,212,175,55), false, 30*30*30*30);
							if (part is null) continue;
							part.collides = false;
							part.gravity = Vec2f(0,0);
							particles.push_back(part);
						}
						blob.set("particles", particles);
					}
				}
				else
				{
					for (int i = 0; i < particles.length(); i++)
					{
						CParticle@ part = particles[i];
						Vec2f pos = blob.getPosition();
						f32 radius = blob.getRadius()*1.5f;
						Vec2f pos2 = Vec2f(pos.x + radius*Maths::Cos(getGameTime()*0.1f+i*10),pos.y + radius*Maths::Sin(getGameTime()*0.1f+i*10));
						
						bool mapedge = (pos2.x < 0.5f || pos2.x > (getMap().tilemapwidth * getMap().tilesize) - 8.1f || pos2.y > (getMap().tilemapheight * getMap().tilesize)-8.1f);
						if (!mapedge) part.position = pos2;
					}
				}
			}
			else
			if (blob.get("particles", particles))
			{
				for (int i = 0; i < particles.length(); i++)
								{
									particles[i].timeout = 0;
								}
								blob.set("particles", null);
			}
		}
    }    
}

void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData)
{
	if (victim !is null)
	{
		CParticle@[] particles;
		CBlob@ blob = victim.getBlob();
		if (blob is null) return;
		if (blob.get("particles", particles))
		{
			for (int i = 0; i < particles.length(); i++)
			{
				particles[i].timeout = 0;
			}
		}
	}
}