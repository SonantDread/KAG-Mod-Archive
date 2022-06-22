// Tunnel.as

#include "TunnelCommon.as"

const float DECAY_DISTANCE = 200.0;

void onInit(CBlob@ this)
{
    bool decay = true;
    this.set_TileType("background tile", CMap::tile_castle_back);
    CBlob@[] tents;
    getBlobsByName("tent",  @tents );
    for (int i = 0; i < tents.size(); i++)
    {
        if (this.getTeamNum() == tents[i].getTeamNum()){

            if (this.getDistanceTo(tents[i]) < DECAY_DISTANCE){
                decay = false;
            }
        }
    }
    this.set_bool("decay", decay);

}
void onInit(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	CSpriteLayer@ planks = this.addSpriteLayer("planks", this.getFilename() , 24, 24, blob.getTeamNum(), blob.getSkinNum());
	if (planks !is null)
	{
		Animation@ anim = planks.addAnimation("default", 3, true);
		anim.AddFrame(5);
		planks.SetOffset(Vec2f(0, 0));
		planks.SetRelativeZ(10);
	}

	this.getCurrentScript().tickFrequency = 45; // opt
}

void onTick(CSprite@ this)
{
	CSpriteLayer@ planks = this.getSpriteLayer("planks");
	if (planks is null) return;

	CBlob@[] list;
	if (getTunnels(this.getBlob(), list))
	{
		planks.SetVisible(false);
	}
	else
	{
		planks.SetVisible(true);
	}
}

void onTick(CBlob@ this){
	if (this.get_bool("decay")){
		if (getGameTime() % 30 == 0)
  		{
			this.server_Hit(this, this.getPosition(), Vec2f(0, 0), 0.1, 0);
  		}
  	}
}
void onHealthChange(CBlob@ this, f32 oldHealth)
{
	CSprite@ sprite = this.getSprite();
	if (sprite !is null)
	{
		Animation@ destruction = sprite.getAnimation("destruction");
		if (destruction !is null)
		{
			f32 frame = Maths::Floor((this.getInitialHealth() - this.getHealth()) / (this.getInitialHealth() / sprite.animation.getFramesCount()));
			sprite.animation.frame = frame;
		}
	}
}
