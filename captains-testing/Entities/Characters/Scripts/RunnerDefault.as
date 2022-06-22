#include "RunnerCommon.as";
#include "Hitters.as";
#include "KnockedCommon.as"
#include "FireCommon.as"
#include "Help.as"

void onInit(CBlob@ this)
{
	this.getCurrentScript().removeIfTag = "dead";
	this.Tag("medium weight");

	//default player minimap dot - not for migrants
	if (this.getName() != "migrant")
	{
		this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 8, Vec2f(8, 8));
	}

	array<u16> burned_by(burn_array_size);
	this.set(player_burn_array, burned_by);
	this.set_u8(burn_array_i, 0);

	this.set_s16(burn_duration , 6 * 28); // 1.5 hearts, this does 1/4 heart every 28 ticks
	this.set_f32("heal amount", 0.0f);

	//fix for tiny chat font
	this.SetChatBubbleFont("hud");
	this.maxChatBubbleLines = 4;

	InitKnockable(this);
}

void onTick(CBlob@ this)
{
	this.Untag("prevent crouch");
	DoKnockedUpdate(this);
}

// pick up efffects
// something was picked up

void onAddToInventory(CBlob@ this, CBlob@ blob)
{
	this.getSprite().PlaySound("/PutInInventory.ogg");
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	this.getSprite().PlaySound("/Pickup.ogg");

	this.ClearButtons();

	if (getNet().isClient())
	{
		RemoveHelps(this, "help throw");

		if (!attached.hasTag("activated"))
			SetHelp(this, "help throw", "", getTranslatedString("${ATTACHED}$Throw    $KEY_C$").replace("{ATTACHED}", getTranslatedString(attached.getName())), "", 2);
	}

	// check if we picked a player - don't just take him out of the box
	/*if (attached.hasTag("player"))
	this.server_DetachFrom( attached ); CRASHES*/
}

// set the Z back
void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	this.getSprite().SetZ(0.0f);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return this.hasTag("migrant") || this.hasTag("dead");
}
