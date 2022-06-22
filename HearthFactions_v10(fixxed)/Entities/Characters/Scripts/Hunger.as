#include "/Entities/Common/Attacks/Hitters.as"
//Hunger system


void onInit(CBlob@ this)
{
    this.set_s8("hunger", 17);
}

void onTick( CBlob@ this )
{
    s8 hungerTracker;
    if (this.hasTag("invincible"))
    {
        hungerTracker = 17;
        this.set_s8("hunger", hungerTracker);
    }

    if (getGameTime() % 900 == 0) //900 30sec
    {
        if (this.get_s8("hunger") > 0)
        {
              this.sub_s8("hunger", 1);
           }
           else
           {
               if (getNet().isServer())
            {
                Vec2f pos = this.getPosition();
                this.server_Hit(this, pos, Vec2f(0, 0), 0.25f, Hitters::ballista, true); //hunger icon
               }
           }
           //print(this.get_s8("hunger")+" h");
    }
    if (this.get_s8("hunger") > 20)
    {
        this.set_s8("hunger",20);
    }

    if (hungerTracker > this.get_s8("hunger"))
    {
        this.set_s8("hunger", hungerTracker);
     }
    else if (this.get_s8("hunger") > hungerTracker)
    {
      hungerTracker = this.get_s8("hunger");
    }
}