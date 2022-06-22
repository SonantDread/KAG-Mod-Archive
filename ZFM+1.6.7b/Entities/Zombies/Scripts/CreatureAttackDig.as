// Aphelion \\

#include "Hitters.as";

void onInit(CBlob@ this)
{
	if (!this.exists("attack frequency"))
		 this.set_u8("attack frequency", 30);
	
	if (!this.exists("attack distance"))
	     this.set_f32("attack distance", 2.5f);
	     
	if (!this.exists("attack damage"))
		 this.set_f32("attack damage", 1.0f);
		
	if (!this.exists("dig radius"))
		 this.set_f32("dig radius", 1.0f);
		 
	if (!this.exists("dig damage"))
		 this.set_f32("dig damage", 0.25f);	 
	
	if (!this.exists("attack hitter"))
		 this.set_u8("attack hitter", Hitters::bite);
	
	if (!this.exists("attack sound"))
		 this.set_string("attack sound", "ZombieBite");
	
	this.getCurrentScript().removeIfTag	= "dead";
}

void onTick( CBlob@ this )
{
	CBlob@ target = this.getBrain().getTarget();
	if    (target !is null)
	{
		if (getGameTime() >= this.get_u32("next_attack"))
		{
			CMap@ map = this.getMap();
            Vec2f pos = this.getPosition();

            const f32 radius = this.getRadius();
            const f32 attack_distance = radius + this.get_f32("attack distance");

			Vec2f vec = this.getAimPos() - pos;
			f32 angle = vec.Angle();
            
		    HitInfo@[] hitInfos;

		    if (map.getHitInfosFromArc(this.getPosition(), -angle, 90.0f, radius + attack_distance, this, @hitInfos))
		    {
			    for(uint i = 0; i < hitInfos.length; i++)
			    {
				    HitInfo@ hi = hitInfos[i];
				    
				    CBlob@ b = hi.blob;

				    if (b !is null && b is target)
				    {
					    HitTarget(this, b);
					    break;
				    }
			    }
		    }
		}
	}
}

void HitTarget( CBlob@ this, CBlob@ target )
{
	Vec2f hitvel = Vec2f( this.isFacingLeft() ? -1.0 : 1.0, 0.0f );
	
	this.server_Hit( target, target.getPosition(), hitvel, this.get_f32("attack damage"), this.get_u8("attack hitter"), true);
	this.set_u32("next_attack", getGameTime() + this.get_u8("attack frequency"));
	this.set_u32("last_hit_time", getGameTime());
	
	//unelegant (hacky maybe) solution to make zombies dig, they'll destroy non-natural tiles around them
	if (!getNet().isServer()) {
        return;
    }

    Vec2f pos = this.getPosition();
    CMap@ map = this.getMap();
    float step = map.tilesize;
    float radius = step * this.get_f32("dig radius"); //radius of destruction

    for (float x = pos.x - radius; x < pos.x + radius; x += step)
    {
        for (float y = pos.y - radius; y < pos.y + radius; y += step)
        {
            Vec2f tpos = Vec2f(x, y);
            TileType tile = map.getTile(tpos).type; 
			
			//we don't want to destroy natural tiles
            if (map.isTileBedrock(tile) || map.isTileStone(tile) || map.isTileThickStone(tile) || map.isTileGold(tile) || map.isTileGrass(tile) || map.isTileSand(tile) || map.isTileGroundStuff(tile)) 
			{
                continue;
            }
			
			//how strong will the damage on tiles be
            map.server_DestroyTile(tpos, this.get_f32("dig damage"), this); 
        }
    }
}

void onHitBlob( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData )
{		 
	if (damage > 0.0f)
	{
		this.getSprite().PlayRandomSound(this.get_string("attack sound"));
	}
}