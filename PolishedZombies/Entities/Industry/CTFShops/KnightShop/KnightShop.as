// Knight Workshop

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "GenericButtonCommon.as";

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.addCommandID("put_migrant");

	AddIconToken("$put_migrant$", "Entities/Characters/Migrant/MigrantIcon.png", Vec2f(18, 18), 0);
	AddIconToken("$change_class$", "/GUI/InteractionIcons.png", Vec2f(32, 32), 12);

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(5, 1));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	// CLASS
	this.set_string("required class", "knight");

	{
		ShopItem@ s = addShopItem(this, "Bomb", "$bomb$", "mat_bombs", Descriptions::bomb, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 25);
	}
	{
		ShopItem@ s = addShopItem(this, "Water Bomb", "$waterbomb$", "mat_waterbombs", Descriptions::waterbomb, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 30);
	}
	{
		ShopItem@ s = addShopItem(this, "Molotov", "$mat_molotov$", "mat_molotov", "Let them burn!!!", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 40);
	}
	{
		ShopItem@ s = addShopItem(this, "Mine", "$mine$", "mine", Descriptions::mine, false);
		AddRequirement(s.requirements, "coin", "", "Coins", 60);
	}
	{
		ShopItem@ s = addShopItem(this, "Keg", "$keg$", "keg", Descriptions::keg, false);
		AddRequirement(s.requirements, "coin", "", "Coins", 125);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!canSeeButtons(this, caller)) return;

	this.set_Vec2f("class offset", Vec2f(-5, 0));

	if (caller.getConfig() == this.get_string("required class"))
	{
		this.set_Vec2f("shop offset", Vec2f_zero);
	}
	else
	{
		this.set_Vec2f("shop offset", Vec2f(5, 0));
	}

	CBlob@ carried = caller.getCarriedBlob();
	CBitStream params;
	if (carried !is null && carried.hasTag("migrant"))
	{
		this.set_Vec2f("class offset", Vec2f(-5, 2));
		if (caller.getConfig() == this.get_string("required class"))
		{
			this.set_Vec2f("shop offset", Vec2f(0, 2));
		}
		else
		{
			this.set_Vec2f("shop offset", Vec2f(5, 2));
		}

		params.write_u16(carried.getNetworkID());
		caller.CreateGenericButton("$put_migrant$", Vec2f(0, -6), this, this.getCommandID("put_migrant"), "Train Knight", params);
	}

	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");
	}
	else if (cmd == this.getCommandID("put_migrant"))
	{
		u16 caller_id;
		if (!params.saferead_netid(caller_id))
			return;

		CBlob@ caller = getBlobByNetworkID(caller_id);
		if (caller !is null)
		{
			if (getNet().isServer())
			{
				caller.server_DetachFromAll();
				caller.server_Die();

				CBlob@ blob = server_CreateBlob("knightbot", this.getTeamNum(), this.getPosition());
			}
			
			this.getSprite().PlaySound("/ChaChing.ogg");
		}
	}
}

void onHealthChange(CBlob@ this, f32 oldHealth)
{
	CSprite@ sprite = this.getSprite();
	if (sprite !is null)
	{
		Animation@ destruction = sprite.getAnimation("destruction");
		if (destruction !is null)
		{
			f32 frame = Maths::Floor((this.getInitialHealth() - this.getHealth()) / (this.getInitialHealth() / sprite.animation.getFramesCount()));
			sprite.animation.frame = frame;
		}
	}
}