#include "Knocked.as"
#include "EatCommon.as";

void onInit(CBlob@ this)
{
	this.getCurrentScript().removeIfTag = "dead";
}

void onTick(CBlob@ this)
{
	Vec2f vel = this.getVelocity();

    if (this.hasTag("Healing") && getGameTime() % 110 == 0) //3 sec+, slow regen
    {
        if (this.getHealth() < this.getInitialHealth()) {
	        Sound::Play("Heart.ogg", this.getPosition());
	        if (isServer()) {
	            this.server_Heal(0.25f);
	        }
	    }
    }
    if (this.hasTag("Healing2") && getGameTime() % 36 == 0) //little more than a sec
    {
    	if (this.getHealth() < this.getInitialHealth()) {
	        Sound::Play("Heart.ogg", this.getPosition());
	        if (isServer()) {
	            this.server_Heal(0.25f);
	        }
	    }
    }
    if (this.hasTag("Float"))
    {
    	if (vel.y > -1.0f)
		{
			this.AddForce(Vec2f(0, -35.0f));
	    }
    }
    if (this.hasTag("Speed"))
    {
    	if (Maths::Abs(vel.x) < 8.0f)
		{
			this.AddForce(Vec2f((vel.x * 4.0f), 0.0f));
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