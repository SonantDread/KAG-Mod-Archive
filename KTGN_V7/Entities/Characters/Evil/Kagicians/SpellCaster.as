#include "MagicCommon.as";
void onInit(CBlob@ this)
{
	this.addCommandID("scale");
	this.addCommandID("sendspellstuff");
}
void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
    if (cmd == this.getCommandID("scale"))
    {
		CBlob@ spell = getBlobByNetworkID(params.read_u16());
		u16 charge = spell.get_u16("charge");
		if(spell !is null)
		{
			f32 scale = charge;
			scale += 40;
			scale /= 200.0f;
			scale = Maths::Min(scale, 1.5f);
			spell.getSprite().ScaleBy(Vec2f(scale, scale));
		}
	}
	else if (cmd == this.getCommandID("sendspellstuff"))
    {
		Vec2f aimpos = params.read_Vec2f();
		doSpellStuff(this, aimpos);
	}
}