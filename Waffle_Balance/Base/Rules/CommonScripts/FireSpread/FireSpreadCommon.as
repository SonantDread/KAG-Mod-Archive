
const string last_damage_time = "Last Damage Time ";

void FireSpread(Vec2f world_pos)
{
    CMap@ map = getMap();
    Random@ random = Random(getGameTime());
    for (u8 i = 0; i < 2; i++)
    {
        sendBurnCommand(map, world_pos + Vec2f(1 - random.NextRanged(3), 1 - random.NextRanged(3)) * map.tilesize);
    }
}

void sendBurnCommand(CMap@ map, Vec2f world_pos)
{
    CRules@ rules = getRules();
    CBitStream params;
    params.write_Vec2f(world_pos);
    rules.SendCommand(rules.getCommandID("burn block"), params);
}
