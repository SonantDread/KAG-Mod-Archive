// Builder logic

#include "Hitters.as";
#include "Knocked.as";
#include "BuilderCommon.as";
#include "ThrowCommon.as";
#include "RunnerCommon.as";
#include "Help.as";
#include "Requirements.as"
#include "BuilderHittable.as";
#include "PlacementCommon.as";
#include "ParticleSparks.as";
#include "MaterialCommon.as";
#include "EquipmentCommon.as";
#include "LimbsCommon.as";

void onInit(CBlob@ this)
{
	this.set_u8("hammer_swing",0);
}

void onTick(CBlob@ this)
{
	if(this.isInInventory())
		return;

	const bool ismyplayer = this.isMyPlayer();

	if(ismyplayer && getHUD().hasMenus())
	{
		return;
	}
	
	if(ismyplayer && this.isKeyPressed(key_action1) && !this.isKeyPressed(key_inventory)) //Don't let the builder place blocks if he/she is selecting which one to place
	{
		BlockCursor @bc;
		this.get("blockCursor", @bc);

		HitData@ hitdata;
		this.get("hitdata", @hitdata);
		hitdata.blobID = 0;
		hitdata.tilepos = bc.buildable ? bc.tileAimPos : Vec2f(-8, -8);
	}

	// get rid of the built item
	if(this.isKeyJustPressed(key_inventory) || this.isKeyJustPressed(key_pickup) || !((isLimbUsable(this,this.get_u8("marm_type")) && this.get_u16("marm_equip") == Equipment::Hammer) || (isLimbUsable(this,this.get_u8("sarm_type")) && this.get_u16("sarm_equip") == Equipment::Hammer)))
	{
		this.set_u8("buildblob", 255);
		this.set_TileType("buildtile", 0);

		CBlob@ blob = this.getCarriedBlob();
		if(blob !is null && blob.hasTag("temp blob"))
		{
			blob.Untag("temp blob");
			blob.server_Die();
		}
	}
	
	if((this.get_u16("marm_equip") == Equipment::Hammer && this.isKeyPressed(key_action1) && isLimbUsable(this,this.get_u8("marm_type"))) || (this.get_u16("sarm_equip") == Equipment::Hammer && this.isKeyPressed(key_action2) && isLimbUsable(this,this.get_u8("sarm_equip")))){
		if(this.get_u8("hammer_swing") < 10)this.add_u8("hammer_swing",1);
		else this.set_u8("hammer_swing",0);
	} else {
		this.set_u8("hammer_swing",0);
	}
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	// ignore collision for built blob
	BuildBlock[][]@ blocks;
	if(!this.get("blocks", @blocks))
	{
		return;
	}
	
	
	const u8 PAGE = this.get_u8("build page");
	
	for(u8 i = 0; i < blocks[PAGE].length; i++)
	{
		BuildBlock@ block = blocks[PAGE][i];
		if(block !is null && block.name == detached.getName())
		{
			this.IgnoreCollisionWhileOverlapped(null);
			detached.IgnoreCollisionWhileOverlapped(null);
		}
	}

	// BUILD BLOB
	// take requirements from blob that is built and play sound
	// put out another one of the same
	if(detached.hasTag("temp blob"))
	{
		if(!detached.hasTag("temp blob placed"))
		{
			detached.server_Die();
			return;
		}

		uint i = this.get_u8("buildblob");
		if(i >= 0 && i < blocks[PAGE].length)
		{
			BuildBlock@ b = blocks[PAGE][i];
			if(b.name == detached.getName())
			{
				this.set_u8("buildblob", 255);
				this.set_TileType("buildtile", 0);

				CInventory@ inv = this.getInventory();

				CBitStream missing;
				if(hasRequirements(inv, b.reqs, missing, not b.buildOnGround))
				{
					server_TakeRequirements(inv, b.reqs);
				}
				// take out another one if in inventory
				server_BuildBlob(this, blocks[PAGE], i);
			}
		}
	}
	else if(detached.getName() == "seed")
	{
		if (not detached.hasTag('temp blob placed')) return;

		CBlob@ anotherBlob = this.getInventory().getItem(detached.getName());
		if(anotherBlob !is null)
		{
			this.server_Pickup(anotherBlob);
		}
	}
}

void onAddToInventory(CBlob@ this, CBlob@ blob)
{
	// destroy built blob if somehow they got into inventory
	if(blob.hasTag("temp blob"))
	{
		blob.server_Die();
		blob.Untag("temp blob");
	}

	if(this.isMyPlayer() && blob.hasTag("material"))
	{
		SetHelp(this, "help inventory", "builder", "$Help_Block1$$Swap$$Help_Block2$           $KEY_HOLD$$KEY_F$", "", 3);
	}
}
