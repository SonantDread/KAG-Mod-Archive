#include "SuperKnightCommon.as";
#include "SuperArcherCommon.as";
#include "FighterVarsCommon.as"

//set facing direction to aiming direction

void onInit(CMovement@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
	this.getCurrentScript().tickFrequency = 3;
}

void onTick(CMovement@ this)
{
	CBlob@ blob = this.getBlob();

	SSKFighterVars@ fighterVars;
	if (!blob.get("fighterVars", @fighterVars))
	{
		return;
	}

	// face direction of attack
	if (fighterVars.inMoveAnimation)
	{
		blob.SetFacingLeft(fighterVars.isAttackingLeft);
		return;
	}

	u16 hitstunTime = fighterVars.hitstunTime;
	u16 tumbleTime = fighterVars.tumbleTime;
	u16 dazeTime = fighterVars.dazeTime;
	bool disableItemActions = fighterVars.disableItemActions;

	// stop the logic if hitstunned
	if (hitstunTime > 0 || tumbleTime > 0 || dazeTime > 0 || disableItemActions)
	{
		return;
	}

	bool isFacingLeft = blob.isFacingLeft();

	bool doFaceLeft = false;

	const bool left		= blob.isKeyPressed(key_left);
	const bool right	= blob.isKeyPressed(key_right);	
	const bool isAimingLeft = (blob.getAimPos().x <= blob.getPosition().x);

	if (blob.isOnGround())
	{
		if (!left && !right)
			doFaceLeft = isAimingLeft;
		else if (left && !right)
			doFaceLeft = true;
		else if (right && !left)
			doFaceLeft = false;
	}
	else
	{
		doFaceLeft = isFacingLeft;
	}

	// face attack direction
	SuperKnightInfo@ superKnight;
	if (blob.get("superKnightInfo", @superKnight))
	{
		 if (superKnight.state != SuperKnightStates::normal)
		 	doFaceLeft = (blob.getAimPos().x <= blob.getPosition().x);
	}

	SuperArcherInfo@ superArcher;
	if (blob.get("superArcherInfo", @superArcher))
	{
		 if (superArcher.charge_state != 0)
		 	doFaceLeft = (blob.getAimPos().x <= blob.getPosition().x);
	}

	// face for all attachments
	if (blob.hasAttached())
	{
		AttachmentPoint@[] aps;
		if (blob.getAttachmentPoints(@aps))
		{
			for (uint i = 0; i < aps.length; i++)
			{
				AttachmentPoint@ ap = aps[i];
				CBlob@ heldBlob = ap.getOccupied();
				if (ap.socket && heldBlob !is null)
				{
					// override player facing if holding aimable item
					if (ap.getOccupied().hasTag("aimable"))
					{
						doFaceLeft = isAimingLeft;
					}

					heldBlob.SetFacingLeft(doFaceLeft);
				}
			}
		}
	}	

	blob.SetFacingLeft(doFaceLeft);
}
