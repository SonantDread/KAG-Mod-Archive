#include "Hitters.as";
#include "GenericButtonCommon.as";

const u32 VANISH_BODY_SECS = 45;
const f32 CARRIED_BLOB_VEL_SCALE = 1.0;
const f32 MEDIUM_CARRIED_BLOB_VEL_SCALE = 0.8;
const f32 HEAVY_CARRIED_BLOB_VEL_SCALE = 0.6;

void onInit(CBlob@ this)
{
	this.set_f32("hit dmg modifier", 0.0f);
	this.set_f32("hit dmg modifier", 0.0f);
	this.getCurrentScript().tickFrequency = 0; // make it not run ticks until dead
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
    if(this.hasTag("migrant") && hitterBlob.hasTag("zombie"))
    {
        if (getGameTime() - this.get_u32("last_scream_time") > 60 && XORRandom(2) == 0)
        {
            this.getSprite().PlaySound("/MigrantScream", 1.0f, 1.5f);
            this.set_u32("last_scream_time", getGameTime());
        }
    }

    // make dead state
    // make sure this script is at the end of onHit scripts for it gets the final health
    if (this.getHealth() <= 0.0f && !this.hasTag("dead"))
    {
        if(this.hasTag("migrant"))
        {
            this.Untag("migrant");
        }
        
        this.Tag("dead");
        this.Untag("survivor");
        this.set_u32("death time", getGameTime());
        
		this.UnsetMinimapVars(); //remove minimap icon

        // we want the corpse to stay but player to respawn so we force a die event in rules

		if (getNet().isServer())
		{
			if (this.getPlayer() !is null)
			{
				getRules().server_PlayerDie(this.getPlayer());
	            this.server_SetPlayer(null);
			}
			else {
				getRules().server_BlobDie(this);
			}
		}

        // add pickup attachment so we can pickup body
        CAttachment@ a = this.getAttachments();

        if (a !is null)
        {
            AttachmentPoint@ ap = a.AddAttachmentPoint("PICKUP", false);
        }

        // sound
        if (this.getSprite() !is null) //moved here to prevent other logic potentially not getting run
        {
            f32 gibHealth = this.get_f32("gib health");

            if (this !is hitterBlob || customData == Hitters::fall)
            {
                if (this.isInWater())
                {
                    if (this.getHealth() > gibHealth) {
                        this.getSprite().PlaySound("Gurgle");
                    }
                }
                else
                {
                    if (this.getHealth() > gibHealth/2.0f) {
                        this.getSprite().PlaySound("WilhelmShort.ogg", this.getSexNum() == 0 ? 1.0f : 1.5f);
                    }
                    else if (this.getHealth() > gibHealth) {
                        this.getSprite().PlaySound("Wilhelm.ogg", 1.0f, this.getSexNum() == 0 ? 1.0f : 1.5f);
                    }
                }
            }

            // turn off bow sound (emit sound)
            this.getSprite().SetEmitSoundPaused(true);
        }

		this.getCurrentScript().tickFrequency = 30;

        this.set_f32("hit dmg modifier", 0.5f);

		// new physics vars so bodies don't slide
		this.getShape().setFriction(0.75f);
		this.getShape().setElasticity(0.2f);

        // disable tags
        this.Untag("shielding");
		this.Untag("player");
        this.getShape().getVars().isladder = false;
		this.getShape().getVars().onladder = false;
		this.getShape().checkCollisionsAgain = true;
        this.getShape().SetGravityScale(1.0f);
        //set velocity to blob in hand
        CBlob@ carried = this.getCarriedBlob();
        if (carried !is null)
        {
            Vec2f current_vel = this.getVelocity() * CARRIED_BLOB_VEL_SCALE;
            if (carried.hasTag("medium weight"))
                current_vel = current_vel * MEDIUM_CARRIED_BLOB_VEL_SCALE;
            else if (carried.hasTag("heavy weight"))
                current_vel = current_vel * HEAVY_CARRIED_BLOB_VEL_SCALE;
            //the item is detatched from the player before setting the velocity
            //otherwise it wont go anywhere
            this.server_DetachFrom(carried);
            carried.setVelocity(current_vel);
        }
        // fall out of attachments/seats // drop all held things
        this.server_DetachAll();

		StuffFallsOut(this);
    }
	else
		this.set_u32("death time", getGameTime());

    return damage;
}


// erase all items before vanishing

void onTick(CBlob@ this)
{
    if (!getNet().isServer())
        return;

	if (this.get_u32("death time") + VANISH_BODY_SECS*getTicksASecond() < getGameTime())
	{
		// destroy what was in inv

		CInventory@ inv = this.getInventory();
		if (inv !is null)
		{
			for (int i = 0; i < inv.getItemsCount(); i++)
			{
				CBlob @blob = inv.getItem(i);	
				blob.server_Die();
			}
		}

		// create zombie at corpse
		server_CreateBlob("zombie", -1, this.getPosition());

		// vanish ourselves

		this.server_Die();
	}
}
				   
// reset vanish counter on pickup

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{  
	this.set_u32("death time", getGameTime());
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return (this.hasTag("dead") && this.getInventory().getItemsCount() > 0 && canSeeButtons(this, forBlob));
}

void StuffFallsOut(CBlob@ this)
{
	if (!getNet().isServer())
		return;

	int counter = 0;
	CInventory@ inv = this.getInventory();
	while(inv !is null && inv.getItemsCount() > 0)
	{
		CBlob @blob = inv.getItem(0);	
		this.server_PutOutInventory(blob);
		blob.setVelocity(getRandomVelocity(90, 4.0f, 40));
		counter++;
		if (counter == 2) // optimization - just 2 stuff falls out
		{
			return;
		}
	}
}
