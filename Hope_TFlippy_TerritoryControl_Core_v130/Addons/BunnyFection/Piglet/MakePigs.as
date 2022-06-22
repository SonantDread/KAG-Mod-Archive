//todo: make it so that blobs can eat multiple types of food
//script by betelgeuse
#define SERVER_ONLY;

#include "FoodQueue.as"

const string food_queue = "food_queue";

void onInit(CBlob@ this)
{
	FoodQueue fq("steak", 30);
	this.set(food_queue, fq);
	this.set_u32("count", 0);
}

void onTick(CBlob@ this)
{
	CBlob@[] blobs;
	this.getMap().getBlobsInRadius(this.getPosition(), 512.0f, blobs);

	int count;

	for (int i = 0; i < blobs.length; i++)
	{
		if (blobs[i] is null) continue;
		if (blobs[i].getName() == "piglet") count++;
	}
	if (this.get_u32("count") < 30)
	{
		FoodQueue@ fq;
		this.get(food_queue, @fq);
		if (fq is null) return;

		fq.onTick(@this);

		if (fq.Ate()) {
			//this.getSprite().PlaySound("Pluck0");
			server_CreateBlob("piglet", this.getTeamNum(), this.getPosition() + Vec2f(0.0f, 5.0f));
		}
	}
	this.set_u32("count", count);
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	FoodQueue@ fq;
	this.get(food_queue, @fq);
	if (fq is null) return;

	fq.onCollision(@this, @blob);
}