#include "Hitters.as"

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-10.0f);
}

void onInit(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	u16 netID = blob.getNetworkID();
	this.animation.frame = (netID % this.animation.getFramesCount());
	this.SetFacingLeft(((netID % 13) % 2) == 0);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return false;
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	f32 dmg = damage/2;

	return dmg;
}

void onDie(CBlob@ this)
{
    if (this.hasTag("despawned")) return;

    this.getSprite().Gib();

    // Drop loot
    array<string> _items =
    {
        "mat_wood",
        "mat_stone",

    	"lantern",
    	"bucket"
    };
    array<float> _chances =
    {
        0.6,
        0.3,

        0.03,
        0.01
    };
    array<u8> _amount =
    {
        (XORRandom(7)+1)*5,
        (XORRandom(6)+1)*5,

        1,
        1
    };

    if (getNet().isServer())
    {
    	for (int i = 0; i < 2; i++)
		{
	        u32 element = RandomWeightedPicker(_chances, XORRandom(1000));
	        CBlob@ b = server_CreateBlob(_items[element],-1,this.getPosition());  
	        b.AddForce(Vec2f((XORRandom(5)-2)/1.3, -3));  
	        if (b.getMaxQuantity() > 1)
	        {
	            b.server_SetQuantity(_amount[element]);
	        }
    	}
    }
}

shared u32 RandomWeightedPicker(array<float> chances, u32 seed = 0)
{
    if (seed == 0) {seed = (getGameTime() * 404 + 1337 - Time_Local());}

    u32 i;
    float sum = 0.0f;

    for (i = 0; i < chances.size(); i++) {sum += chances[i];}

    Random@ rnd = Random(seed);//Random with seed

    float random_number = (rnd.Next() + rnd.NextFloat()) % sum;//Get our random number between 0 and the sum

    float current_pos = 0.0f;//Current pos in the bar

    for (i = 0; i < chances.size(); i++)//For every chance
    {
        if(current_pos + chances[i] > random_number)
        {
            break;//Exit out with i untouched
        }
        else//Random number has not yet reached the chance
        {
            current_pos += chances[i];//Add to current_pos
        }
    }

    return i;//Return the chance that was got
}