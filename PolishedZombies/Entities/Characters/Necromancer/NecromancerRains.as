#include "NecromancerCommon.as";

void SummonBlob(string name, Vec2f pos, int team)
{
    if (getNet().isServer())
        server_CreateBlob(name, team, pos);
}

namespace NecroRainTypes
{
    enum type{
        finished = 0,
        zombieRain,
        meteorRain,
        meteoriteStrike,
        skeletonRain
    }
}

class NecroRain
{
    u8 type;
    u8 level;
    Vec2f position;
    int team;

    uint time;
    uint objectsAmount;

    NecroRain(CBlob@ blob, u8 i_type, u8 i_level, Vec2f pos)
    {
        type = i_type;
        level = i_level;
        position = pos;
        team = blob.getTeamNum();

        if (type == NecroRainTypes::zombieRain)
        {
            if (level == NecroParams::extra_ready)
                SummonBlob("zknight", position, team);
            objectsAmount = 5;
            if (level == NecroParams::extra_ready)
                objectsAmount += XORRandom(15);
            else if (level == NecroParams::cast_3)
                objectsAmount += XORRandom(10);
            else if (level == NecroParams::cast_2)
                objectsAmount += XORRandom(6);
            else if (level == NecroParams::cast_1)
                objectsAmount += XORRandom(3);
            time = 1 + XORRandom(6);
        }
        else if (type == NecroRainTypes::meteorRain)
        {
            objectsAmount = 2;
            if (level == NecroParams::extra_ready)
                objectsAmount += XORRandom(5);
            else if (level == NecroParams::cast_3)
                objectsAmount += XORRandom(3);
            else if (level == NecroParams::cast_2)
                objectsAmount += XORRandom(2);
            else if (level == NecroParams::cast_1)
                objectsAmount += XORRandom(2);
            time = 1 + XORRandom(6);
        }
        else if (type == NecroRainTypes::meteoriteStrike)
        {
            objectsAmount = 2;
            time = 1;
        }
        else if (type == NecroRainTypes::skeletonRain)
        {
            objectsAmount = 5;
            if (level == NecroParams::extra_ready)
                objectsAmount += XORRandom(15);
            else if (level == NecroParams::cast_3)
                objectsAmount += XORRandom(10);
            else if (level == NecroParams::cast_2)
                objectsAmount += XORRandom(6);
            else if (level == NecroParams::cast_1)
                objectsAmount += XORRandom(3);
            time = 1;
        }
    }

    void Manage()
    {
        time -= 1;
        if (time <= 0)
        {
            if (type == NecroRainTypes::zombieRain)
            {
                string[] possibleZombies = {"skeleton", "zombie", "ankou", "zchicken", "catto"};
                if (level >= NecroParams::cast_3)
                {
                    possibleZombies.insertLast("zknight");
                }
                SummonBlob(possibleZombies[XORRandom(possibleZombies.length)], position + Vec2f(XORRandom(80) - 40, XORRandom(80) - 40), team);

                time = 1 + XORRandom(6);
            }
            else if (type == NecroRainTypes::meteorRain)
            {
                SummonBlob("meteor", Vec2f(position.x + 100.0f - XORRandom(200.0f), 20.0f), team);

                time = 1 + XORRandom(6);
            }
            else if (type == NecroRainTypes::meteoriteStrike)
            {
                SummonBlob("meteorite", Vec2f(position.x, 10.0f), team);

                time = 1;
            }
            else if (type == NecroRainTypes::skeletonRain)
            {
                SummonBlob("skeleton", position + Vec2f(XORRandom(80) - 40, XORRandom(80) - 40), team);
                time = 1;
            }
            objectsAmount -= 1;
            if (objectsAmount <= 0)
            {
                type = NecroRainTypes::finished;
            }
        }
    }

    bool CheckFinished()
    {
        return (type == NecroRainTypes::finished);
    }
}

void onInit(CBlob@ this)
{
    this.addCommandID("rain");

    NecroRain[] rains;
    this.set("necromancerRains", rains);

    this.getCurrentScript().tickFrequency = getTicksASecond()/2;
    this.getCurrentScript().removeIfTag = "dead";
}

void onTick(CBlob@ this)
{
    if (!getNet().isServer())
        return;

    NecroRain[]@ rains;
    if (!this.get("necromancerRains", @rains)){
        return;
    }

    if (rains.length == 0)
        return;
    for (int i=rains.length-1; i>=0; i--)
    {
        if (rains[i].CheckFinished())
        {
            rains.removeAt(i);
        }
    }
    for (uint i=0; i<rains.length; i++)
        rains[i].Manage();
}

void addRain(CBlob@ this, string type, u8 level, Vec2f pos)
{
    NecroRain[]@ rains;
    if (!this.get("necromancerRains", @rains)){
        return;
    }
    if (!getNet().isServer())
        return;
    if (type == "zombie_rain")
        rains.insertLast(NecroRain(this, NecroRainTypes::zombieRain, level, pos));
    else if (type == "meteor_rain")
        rains.insertLast(NecroRain(this, NecroRainTypes::meteorRain, level, pos));
    else if(type == "meteorite_strike")
        rains.insertLast(NecroRain(this, NecroRainTypes::meteoriteStrike, level, pos));
    else if (type == "skeleton_rain")
        rains.insertLast(NecroRain(this, NecroRainTypes::skeletonRain, level, pos));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
    if (cmd == this.getCommandID("rain"))
    {
        string type = params.read_string();
        u8 charge_state = params.read_u8();
        Vec2f aimpos = params.read_Vec2f();
        addRain(this, type, charge_state, aimpos);
    }
}