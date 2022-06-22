#include "MakeMat.as";

void onInit(CSprite@ this)
{
	// Building
	this.SetZ(-50);

	this.RemoveSpriteLayer("gear");
	CSpriteLayer@ gear = this.addSpriteLayer("gear", "Extractor.png" , 16, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	if (gear !is null)
	{
		Animation@ anim = gear.addAnimation("default", 0, false);
		anim.AddFrame(2);
		gear.SetOffset(Vec2f(0.0f, -3.0f));
		gear.SetAnimation("default");
		gear.SetRelativeZ(-60);
	}
}

void onTick(CSprite@ this)
{
	if(this.getSpriteLayer("gear") !is null){
		this.getSpriteLayer("gear").RotateBy(3, Vec2f(0.5f,-0.5f));
	}
}

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);
	this.getShape().getConsts().mapCollisions = false;
	this.getCurrentScript().tickFrequency = 10;

	this.set_bool("reversed", false);
	this.addCommandID("reverse");

	this.Tag("ignore extractor");
	this.Tag("builder always hit");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBitStream params;

	if (this !is null)
	{
		CButton@ button = caller.CreateGenericButton(17, Vec2f(0, 3.0f), this, this.getCommandID("reverse"), "Reverse logic filter \nAlready reversed: " + this.get_bool("reversed"), params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("reverse"))
	{
		if (this !is null)
		{
			if (!this.get_bool("reversed"))
				this.set_bool("reversed", true);
			else
				this.set_bool("reversed", false);
			printf("" + this.get_bool("reversed"));
		}
	}
}

void onTick(CBlob@ this)
{
	if (isServer())
	{
		CBlob@[] blobs;
		// if (this.getMap().getBlobsInRadius(this.getPosition(), 32.0f, @blobs))
		if (getMap().getBlobsInBox(this.getPosition() + Vec2f(-32, -32), this.getPosition() + Vec2f(32, 32), @blobs))
		{
			for (uint i = 0; i < blobs.length; i++)
			{
				CBlob@ b = blobs[i];
				if(b.getInventory() !is null && b.hasTag("player") && b.getTeamNum() == this.getTeamNum())
				{
					int count = b.getInventory().getItemsCount();

					for (int i = 0; i < count; i++)
					{
						if (!this.get_bool("reversed"))
						{
							CBlob@ item = b.getInventory().getItem(i);
							if (item !is null && this.hasBlob(item.getName(), 0)
							|| this.hasBlob(item.getName(), 1)
							|| this.hasBlob(item.getName(), 2)
							|| this.hasBlob(item.getName(), 3)
							|| this.hasBlob(item.getName(), 4)
							|| this.hasBlob(item.getName(), 5)
							|| this.hasBlob(item.getName(), 6)
							|| this.hasBlob(item.getName(), 7)
							|| this.hasBlob(item.getName(), 8)
							|| this.hasBlob(item.getName(), 9)
							|| this.hasBlob(item.getName(), 10)
							|| this.hasBlob(item.getName(), 11)
							|| this.hasBlob(item.getName(), 12)
							|| this.hasBlob(item.getName(), 13)
							|| this.hasBlob(item.getName(), 14)
							|| this.hasBlob(item.getName(), 15)
							|| this.hasBlob(item.getName(), 16))
							{
								b.server_PutOutInventory(item);
								item.setPosition(this.getPosition());

								return;
							}
						}
						else if (this.get_bool("reversed"))
						{
							CBlob@ item = b.getInventory().getItem(i);
							if (item !is null && !this.hasBlob(item.getName(), 0)
							|| !this.hasBlob(item.getName(), 1)
							|| !this.hasBlob(item.getName(), 2)
							|| !this.hasBlob(item.getName(), 3)
							|| !this.hasBlob(item.getName(), 4)
							|| !this.hasBlob(item.getName(), 5)
							|| !this.hasBlob(item.getName(), 6)
							|| !this.hasBlob(item.getName(), 7)
							|| !this.hasBlob(item.getName(), 8)
							|| !this.hasBlob(item.getName(), 9)
							|| !this.hasBlob(item.getName(), 10)
							|| !this.hasBlob(item.getName(), 11)
							|| !this.hasBlob(item.getName(), 12)
							|| !this.hasBlob(item.getName(), 13)
							|| !this.hasBlob(item.getName(), 14)
							|| !this.hasBlob(item.getName(), 15)
							|| !this.hasBlob(item.getName(), 16))
							{
								b.server_PutOutInventory(item);
								item.setPosition(this.getPosition());

								return;
							}
						}
					}
					
					// if (b.getInventory().getItemsCount() > 0)
					// {
						// // return !(this.hasBlob(blob.getName(), 0) || this.hasBlob(blob.getName(), 1));
					
						// CBlob@ item = b.getInventory().getItem(0);

						// b.server_PutOutInventory(item);
						// item.setPosition(this.getPosition());
					// }
				}
			}
		}
	}
}


void onAddToInventory( CBlob@ this, CBlob@ blob )
{
	if(blob.getName() != "gyromat") return;

	this.getCurrentScript().tickFrequency = 10 / (this.exists("gyromat_acceleration") ? this.get_f32("gyromat_acceleration") : 1);
}

void onRemoveFromInventory(CBlob@ this, CBlob@ blob)
{
	if(blob.getName() != "gyromat") return;
	
	this.getCurrentScript().tickFrequency = 10 / (this.exists("gyromat_acceleration") ? this.get_f32("gyromat_acceleration") : 1);
}