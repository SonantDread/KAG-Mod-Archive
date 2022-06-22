#include "Knocked.as"
#include "EatCommon.as";

void onInit(CBlob@ this)
{
	this.getCurrentScript().removeIfTag = "dead";
}

void onTick(CBlob@ this)
{
	Vec2f vel = this.getVelocity();

    if (this.hasTag("Speed"))
    {
    	if (this.isOnMap() && (Maths::Abs(vel.x) > 1.6f))
    	{
	    	if ((Maths::Abs(vel.x) < 4.0f))
			{
				this.AddForce(Vec2f((vel.x * 3.5f), 0.0f));
		    }
		}
    }
    if (
        getNet().isServer() &&
        this.isKeyJustPressed(key_eat) &&
        !isKnocked(this) &&
        this.getHealth() < this.getInitialHealth()
    ) {
        CBlob @carried = this.getCarriedBlob();
        if (carried !is null && canEat(carried))
        {
            Heal(this, carried);
        }
        else // search in inv
        {
            CInventory@ inv = this.getInventory();
            for (int i = 0; i < inv.getItemsCount(); i++)
            {
                CBlob @blob = inv.getItem(i);
                if (canEat(blob))
                {
                    Heal(this, blob);
                    return;
                }
            }
        }
    }
}