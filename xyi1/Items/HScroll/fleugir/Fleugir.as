
#include "GenericButtonCommon.as";

const f32 YEET_FORCE=   2500.0f;//force applied
void onInit(CBlob@ this)
{
	this.Tag("ignore_saw");
    this.addCommandID("activate");

   	this.set_string("power name", "fleugir");

	
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!canSeeButtons(this, caller)) return;
    if (!this.isAttachedTo(caller)) return;

	CBitStream params;
	params.write_u16(caller.getNetworkID());
	caller.CreateGenericButton(11, Vec2f_zero, this, this.getCommandID("activate"), "Activate", params);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	
				
	
    if (cmd == this.getCommandID("activate"))
    {
        this.server_Die();

        CBlob@ caller = getBlobByNetworkID(params.read_u16());
		

				Vec2f aimPos=   caller.getAimPos();
				Vec2f pos=      caller.getPosition();
				Vec2f vel=      caller.getVelocity();
		
        if (caller.getPlayer() !is null)
        {

            Vec2f force=ActualNormalize(aimPos-pos)*YEET_FORCE;
            caller.AddForce(force);
	
            //Sound::Play("MagicWand.ogg");
        }
    }
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	this.server_setTeamNum(attached.getTeamNum());
}


Vec2f ActualNormalize(Vec2f value)
{
    float dis=  Maths::Sqrt(value.x*value.x+value.y*value.y);
    return Vec2f(value.x/dis,value.y/dis);
}
