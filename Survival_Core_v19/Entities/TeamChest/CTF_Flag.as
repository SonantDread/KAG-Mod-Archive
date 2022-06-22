// Flag logic

#include "CTF_FlagCommon.as"
#include "CTF_Structs.as"

const string return_prop = "return time";
const u16 return_time = 30*60;
const u16 fast_return_speedup = 3;

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(false);

	this.getCurrentScript().tickFrequency = 5;

	//cannot fall out of map
	this.SetMapEdgeFlags(u8(CBlob::map_collide_up) |
	                     u8(CBlob::map_collide_down) |
	                     u8(CBlob::map_collide_sides));

	this.set_u16(return_prop, 0);

	this.Tag("medium weight"); //slow carrier a little

	Vec2f pos = this.getPosition();

	this.addCommandID("pickup");
	this.addCommandID("capture");
	this.addCommandID("return");

	//we actually have our own way of ignoring damage
	//but this is important for a lot of other scripts
	this.Tag("invincible");

	//special item - prioritise pickup
	this.Tag("special");

	//minimap
	this.SetMinimapOutsideBehaviour(CBlob::minimap_snap);
	this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 9, Vec2f(8, 8));
	
	this.set_u8("race",0);
}

void onTick(CBlob@ this)
{
	bool can_return = !this.isAttached();
	u16 returncount = this.get_u16(return_prop);

	u32 freq = this.getCurrentScript().tickFrequency;

	if (can_return)
	{
		if(!shouldFastReturn(this)){
			if (returncount < return_time)returncount += freq;
		} else {
			returncount = return_time;
		}
	}
	else
	{
		returncount = 0;
	}
	this.set_u16(return_prop, returncount);
	//no sync - should be about the same on client

	if (returncount >= return_time)
	{
		this.Tag("return");
		this.Sync("return", true);
	}
}

//sprite

void onInit(CSprite@ this)
{
	this.SetZ(-10.0f);

	if (this.getBlob().getTeamNum() == 0)
	{
		this.getBlob().SetFacingLeft(true);
	}
}

void onTick(CSprite@ this)
{
	this.SetFrameIndex(this.getBlob().get_u8("race"));
}

bool canBePickedUp(CBlob@ this, CBlob@ by)
{
	return !this.isAttached() && by.hasTag("player") && by.getTeamNum() < 8 &&
	       this.getTeamNum() != by.getTeamNum() &&
	       canPickupFlag(by) &&
	       this.getDistanceTo(by) < 32.0f;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	//ignore all damage except from special hit
	if (customData == 0xfa)
	{
		this.server_SetHealth(-1.0f);
		this.server_Die();
	}
	return 0.0f;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null) return;

	if (this.isAttached()) return;
	if (!blob.hasTag("player") ||  blob.hasTag("ignore_flags")) return; //dont attach to non players

	int team = this.getTeamNum();

	if (blob.getTeamNum() != team)
	{
		if (canPickupFlag(blob))
			blob.server_AttachTo(this, "PICKUP");
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	bool needsmessage = false;
	string message = "";

	if (cmd == this.getCommandID("pickup"))
	{
		this.set_u16(return_prop, 0);
		//Sound::Play("/flag_capture.ogg");

		string name;
		if (!params.saferead_string(name)) return;

		//needsmessage = true;
		message = "picked up by " + name + "!";
	}
	else if (cmd == this.getCommandID("capture"))
	{
		Sound::Play("/flag_score.ogg");

		string name;
		if (!params.saferead_string(name)) return;

		needsmessage = true;
		message = "stolen by " + name + "!";
	}
	else if (cmd == this.getCommandID("return"))
	{
		//Sound::Play("/flag_return.ogg");

		//needsmessage = true;

		if (shouldFastReturn(this))
			message = "returned due to teamwork!";
		else
			message = "returned!";
	}

	if (needsmessage)
	{
		CRules@ rules = getRules();

		int team = this.getTeamNum();

		string myTeamName = (team < rules.getTeamsCount() ? rules.getTeam(team).getName() + "'s" : "");

		client_AddToChat(myTeamName + " chest has been " + message);
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return (blob.getShape().isStatic());
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return (forBlob.getTeamNum() == this.getTeamNum());
}