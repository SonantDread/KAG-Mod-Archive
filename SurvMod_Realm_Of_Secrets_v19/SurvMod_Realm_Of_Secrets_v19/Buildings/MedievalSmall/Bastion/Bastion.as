
#include "TeamWipeCheck.as"

void onInit(CBlob@ this)
{
	this.addCommandID("upgrade");
	
	this.setInventoryName("Bastion: "+(this.getHealth()*2)+"HP");
	
	this.Tag("bulwark");
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());

	if(this.getDistanceTo(caller) < 24)caller.CreateGenericButton(12, Vec2f(0,0), this, this.getCommandID("upgrade"), "Pay 100 stone to increase Health by 5.", params);
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("upgrade"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		{
			if(caller.hasBlob("mat_stone", 100)){
				caller.TakeBlob("mat_stone", 100);
				if(isClient()){
					this.getSprite().SetFrame(1);
					this.setInventoryName("Bastion: "+(this.getHealth()*2+5)+"HP");
				}
				if(isServer())this.server_SetHealth(this.getHealth()+2.5f);
			}
		}
	}
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData ){
	
	this.setInventoryName("Bastion: "+((this.getHealth()-damage)*2)+"HP");
	
	return damage;
}

void onDie( CBlob@ this){
	if(isServer()){
		int team = this.getTeamNum();
		this.server_setTeamNum(-1);
		TeamWipeCheck(team);
	}
}

void onInit(CSprite@ this)
{
	CSpriteLayer@ flag = this.addSpriteLayer("flag_layer", "CTF_Flag.png", 32, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (flag !is null)
	{
		flag.SetOffset(Vec2f(19, -18));
		flag.SetRelativeZ(-1.0f);
		Animation@ anim = flag.addAnimation("default", XORRandom(3) + 3, true);
		anim.AddFrame(0);
		anim.AddFrame(2);
		anim.AddFrame(4);
		anim.AddFrame(6);
	}
	
	CSpriteLayer@ pole = this.addSpriteLayer("pole", "CTF_Flag.png", 32, 32, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (pole !is null)
	{
		pole.SetOffset(Vec2f(16, -14));
		pole.SetRelativeZ(-0.5f);
		Animation@ anim = pole.addAnimation("default", XORRandom(3) + 3, true);
		anim.AddFrame(1);
	}
}