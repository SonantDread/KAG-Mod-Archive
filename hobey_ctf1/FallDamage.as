//fall damage for all characters and fall damaged items
// apply Rules "fall vel modifier" property to change the damage velocity base

#include "Hitters.as";
#include "KnockedCommon.as";
#include "FallDamageCommon.as";

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
    if (!solid || this.isInInventory())
    {
        return;
    }
    
    if (blob !is null && (blob.hasTag("player") || blob.hasTag("no falldamage")))
    {
        return; //no falldamage when stomping
    }
    
    if (getRules().isWarmup()) {
        return;
    }
    
    f32 vely = this.getOldVelocity().y;
    
    if (vely < 0 || Maths::Abs(normal.x) > Maths::Abs(normal.y) * 2) { return; }
    
    // f32 damage = FallDamageAmount(vely);
    f32 damage = 0.f;
    if        (vely < 9.2)  { damage =  0.0f; // NOTE(hobey): no damage no stun
    } else if (vely < 10.)  { damage = -1.0f; // NOTE(hobey): 16+ blocks fall -> stun only
    } else if (vely < 11.1) { damage =   .5f; // NOTE(hobey): 19+ blocks fall -> stun and 0.5 heart damage
    } else if (vely < 12.)  { damage =  1.0f; // NOTE(hobey): 22+ blocks fall -> stun and 1.0 heart damage
    } else if (vely < 12.9) { damage =  1.5f; // NOTE(hobey): 25+ blocks fall -> stun and 1.5 heart damage
    } else if (vely < 13.51){ damage =  2.0f; // NOTE(hobey): 29+ blocks fall -> stun and 2.0 heart damage
    } else if (vely < 14.15){ damage =  2.5f; // NOTE(hobey): 32+ blocks fall -> stun and 2.5 heart damage
    } else if (vely < 14.55){ damage =  3.0f; // NOTE(hobey): 35+ blocks fall -> stun and 3.0 heart damage
    } else if (vely < 15.2) { damage =  3.5f; // NOTE(hobey): 37+ blocks fall -> stun and 3.5 heart damage
    } else {                  damage =  4.0f; // NOTE(hobey): 40+ blocks fall -> stun and 4.0 heart damage
    }
    
    if (damage != 0.0f) //interesting value
    {
        bool doknockdown = true;
        
        if (damage > 0.0f)
        {
            // check if we aren't touching a trampoline
            CBlob@[] overlapping;
            
            if (this.getOverlapping(@overlapping))
            {
                for (uint i = 0; i < overlapping.length; i++)
                {
                    CBlob@ b = overlapping[i];
                    
                    if (b.hasTag("no falldamage"))
                    {
                        return;
                    }
                }
            }
            
            if (damage > 0.1f)
            {
                this.server_Hit(this, point1, normal, damage, Hitters::fall);
            }
            else
            {
                doknockdown = false;
            }
        }
        
        // stun on fall
        const u8 knockdown_time = 12;
        
        if (doknockdown && setKnocked(this, knockdown_time))
        {
            if (damage < this.getHealth()) //not dead
            Sound::Play("/BreakBone", this.getPosition());
            else
            {
                Sound::Play("/FallDeath.ogg", this.getPosition());
            }
        }
    }
}
