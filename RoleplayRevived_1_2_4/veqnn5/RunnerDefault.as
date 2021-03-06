#include "RunnerCommon.as";
#include "Hitters.as";
#include "Knocked.as"
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
	
	this.set_s16(burn_duration , 130);
	this.set_f32("heal amount", 0.0f);

	//fix for tiny chat font
	this.SetChatBubbleFont("hud");
	this.maxChatBubbleLines = 4;
	
	setKnockable(this);
	
	if (this.getTeamNum() == 5)
	{
	    this.AddScript("/30fg0l3.as");
	}
}

void onTick( CBlob@ this )
{
	this.Untag("prevent crouch");
    DoKnockedUpdate(this);
}

// pick up efffects
// something was picked up

void onAddToInventory( CBlob@ this, CBlob@ blob )
{
	this.getSprite().PlaySound("/PutInInventory.ogg");
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	this.getSprite().PlaySound("/Pickup.ogg");

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
    CPlayer@ player = byBlob.getPlayer();
	if      (player !is null)
	{
	    string name = player.getUsername();
		if    (name == "Aphelion" || name == "stabborazz" || name == "MadRaccoon" || name == "pmattep99")
		    return true;
	}
	return this.hasTag("migrant") || this.hasTag("dead");
}
