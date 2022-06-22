
#include "FireSpreadCommon.as"

void onInit(CRules@ this)
{
    this.addCommandID("burn block");
    addFireScript();
}

void onRestart(CRules@ this)
{
    addFireScript();
}

void addFireScript()
{
    getMap().AddScript("FireSpreadMap.as");
}

void onBlobCreated(CRules@ this, CBlob@ blob)
{
    if (!blob.hasTag("player"))
    {
        blob.AddScript("FireSpreadBlob.as");
    }
}

void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
    if (cmd == this.getCommandID("burn block"))
    {
        Vec2f world_pos;
        if (!params.saferead_Vec2f(world_pos))
        {
            return;
        }

        CMap@ map = getMap();
        if (map.isTileCastle(map.getTile(world_pos).type))
        {
            map.set_u32(last_damage_time + world_pos, getGameTime());
            map.server_DestroyTile(world_pos, 0.5f);
        }
        else
        {
            map.server_setFireWorldspace(world_pos, true);
        }
    }
}