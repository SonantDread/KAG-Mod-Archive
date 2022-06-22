// AircraftShop.as

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"
#include "TeamIconToken.as"

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	//INIT COSTS
	InitCosts();

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(4, 4));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	int team_num = this.getTeamNum();

	// TODO: Better information + icons like the vehicle shop, also make aircraft not suck
	{
		string dinghy_icon = getTeamIcon("bomber", "BomberIcon.png", team_num, Vec2f(32, 32), 0);
		ShopItem@ s = addShopItem(this, "Balloon", dinghy_icon, "bomber", dinghy_icon + "\n\n\n" + Descriptions::bomber, false, true);
		s.crate_icon = 4;
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::bomber);		   
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::bomber_wood);
	}
	/*{
		string dinghy_icon = getTeamIcon("basecraft", "VehicleIcons.png", team_num, Vec2f(32, 32), 1);
		ShopItem@ s = addShopItem(this, "Special Ballon", dinghy_icon, "basecraft", dinghy_icon + "\n\n\n" + Descriptions::basecraft, false, true);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::basecraft);		   
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::basecraft_wood)
		s.crate_icon = 2;
	}*/
	{
		string dinghy_icon = getTeamIcon("airship", "AirshipIcon.png", team_num, Vec2f(33, 32), 0);
		ShopItem@ s = addShopItem(this, "Airship", dinghy_icon, "airship", dinghy_icon + "\n\n\n" + Descriptions::airship, false, true);
		s.crate_icon = 4;
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::airship);		
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::airship_wood);
		
	}
	{
		string dinghy_icon = getTeamIcon("glider", "GliderIcon.png", team_num, Vec2f(32, 32), 0);
		ShopItem@ s = addShopItem(this, "Glider", dinghy_icon, "glider", dinghy_icon + "\n\n\n" + Descriptions::glider, false, true);
		s.crate_icon = 4;
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::glider);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::glider_wood);
	}
	{
		string longboat_icon = getTeamIcon("zeppelin", "ZeppelinIcon.png", team_num, Vec2f(32, 32), 0);
		ShopItem@ s = addShopItem(this, "Zeppelin", longboat_icon, "zeppelin", longboat_icon + "\n\n\n" + Descriptions::zeppelin, false, true);
		s.crate_icon = 4;
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::zeppelin);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::zeppelin_wood);
	}

}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");
	}
}
