// Tunnel.as

#include "TunnelCommon.as"

const bool CASUAL_MODE = false;
const float DECAY_DISTANCE = 200.0;
const int DECAY_FREQUENCY = 30;
const float DECAY_DAMAGE = 0.1;

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);
	bool decay = true;
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

	ScriptData@ script = this.getCurrentScript();
	script.tickIfTag = "decay";
	script.tickFrequency = DECAY_FREQUENCY;

	if (decay)
	{
		this.Tag("decay");
	}
}

void onTick(CBlob@ this)
{
	this.server_Hit(this, this.getPosition(), Vec2f(0, 0), DECAY_DAMAGE, 0);
}

// destroy tunnel after enemly uses it
void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	//only casuals want this
	if (!CASUAL_MODE) return;

	if (cmd == this.getCommandID("travel"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller !is null && caller.getTeamNum() != this.getTeamNum())
		{
			this.server_Die();
		}
	}
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
