//needed for crouch logic
#include "CrouchCommon.as";
#include "EquipmentCommon.as"

// character was placed in crate
void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	this.doTickScripts = true; // run scripts while in crate
	this.getMovement().server_SetActive(true);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	CShape@ shape = this.getShape();
	CShape@ oShape = blob.getShape();
	if (shape is null || oShape is null)
	{
		error("error: missing shape in runner doesCollideWithBlob");
		return false;
	}

	bool colliding_block = (oShape.isStatic() && oShape.getConsts().collidable);

	if(blob.isAttachedToPoint("BED") || blob.isAttachedToPoint("SEAT"))return false;

	// when dead, collide only if its moving and some time has passed after death
	if (this.getHealth() <= 0.0f)
	{
		bool slow = (this.getShape().vellen < 1.5f);
		//static && collidable should be doors/platform etc             fast vel + static and !player = other entities for a little bit (land on the top of ballistas).
		return colliding_block || (!slow && oShape.isStatic() && !blob.hasTag("player"));
	}
	else // collide only if not a player or other team member, or crouching
	{
		if(blob.hasTag("player"))
		{
			//knight shield up logic

			//we're a platform if they aren't pressing down
			/*
			bool thisplatform = this.hasTag("shieldplatform") &&
								!blob.isKeyPressed(key_down);

			if (thisplatform)
			{
				Vec2f pos = this.getPosition();
				Vec2f bpos = blob.getPosition();

				const f32 size = 9.0f;

				if (bpos.y < pos.y - size && thisplatform)
				{
					return true;
				}

			}*/
			
			if((blob.hasTag("alive") || blob.hasTag("animated")) && (this.hasTag("alive") || this.hasTag("animated"))){
				EquipmentInfo@ equip;
				if(this.get("equipInfo", @equip)){
					if(equip.MainHand == Equipment::Shield || equip.SubHand == Equipment::Shield)return true;
				}
				
				if(blob.get("equipInfo", @equip)){
					if(equip.MainHand == Equipment::Shield || equip.SubHand == Equipment::Shield)return true;
				}
			}

			return false;
		}

		//don't collide if crouching (but doesn't apply to blocks)
		if (!shape.isStatic() && !colliding_block && isCrouching(this))
		{
			return false;
		}

	}

	return true;
}
