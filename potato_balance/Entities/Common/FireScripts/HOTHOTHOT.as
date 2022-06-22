//Get stuck running forward/backward based on facing direction
//make sure this goes before the actual mover code in execution order

#include "FireCommon.as";

void onInit(CMovement@ this)
{
	this.getCurrentScript().tickIfTag = burning_tag;
	this.getCurrentScript().removeIfTag = "dead";
}

void onTick(CMovement@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob.getHealth() > 0.0f)
	{
		if (blob.hasTag(burning_tag)) //double check
		{
			// MovementVars@ vars = this.getVars();

			if (!blob.hasTag("fire_hothothot"))
			{
				// Just started running - set direction based on facing
				blob.Tag("fire_hothothot");
				SetFireRunDirection(blob, blob.isFacingLeft());
			}

			// Switch direction if key just pressed
			if (blob.isKeyJustPressed(key_left))
			{
				SetFireRunDirection(blob, true);
			}
			else if (blob.isKeyJustPressed(key_right))
			{
				SetFireRunDirection(blob, false);
			}

			// Now go the way we're facing
			if (blob.hasTag("fire_go_left"))
			{
				blob.setKeyPressed(key_right, false);
				blob.setKeyPressed(key_left, true);
			}
			else if (blob.hasTag("fire_go_right"))
			{
				blob.setKeyPressed(key_left, false);
				blob.setKeyPressed(key_right, true);
			}

			if (XORRandom(200) == 0)
			{
				blob.getSprite().PlaySound("/MigrantScream");
			}

			if (blob.get_s16(burn_timer) == 0)
			{
				blob.Untag("fire_hothothot");
			}
		}
	}
}

void SetFireRunDirection(CBlob@ blob, bool left)
{
	if (left)
	{
		blob.Tag("fire_go_left");
		blob.Untag("fire_go_right");
	}
	else
	{
		blob.Tag("fire_go_right");
		blob.Untag("fire_go_left");
	}
}
