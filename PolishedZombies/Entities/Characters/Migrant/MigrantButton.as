#include "MigrantCommon"

void onInit(CBlob@ this)
{
    this.addCommandID("migrant_stop");
    this.addCommandID("migrant_start");

    AddIconToken("$migrant_standground$", "Orders.png", Vec2f(32,32), 2);
    AddIconToken("$migrant_continue$", "Orders.png", Vec2f(32,32), 4);

    this.getCurrentScript().tickFrequency = 31;
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
    u8 strategy = 0;
    if (cmd == this.getCommandID("migrant_stop"))
    {
        strategy = params.read_u8();
        this.set_u8("strategy", strategy);
    }
    else if (cmd == this.getCommandID("migrant_start"))
    {
        strategy = params.read_u8();
        this.set_u8("strategy", strategy);
    }
}