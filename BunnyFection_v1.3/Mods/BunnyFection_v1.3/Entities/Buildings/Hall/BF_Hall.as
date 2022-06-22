// BF_Workshop script

#include "Requirements.as"
#include "ShopCommon.as";
#include "CheckSpam.as";
#include "BF_Costs.as";

void onInit( CBlob@ this )
{
    this.set_TileType("background tile", CMap::tile_wood_back);
    this.getSprite().SetZ(-50);
    this.getShape().getConsts().mapCollisions = false;

    // ICONS
    AddIconToken( "$custom_kitchen$", "BF_Kitchen.png", Vec2f(32,16), 0);
	AddIconToken( "$custom_barracks$", "BF_Barracks.png", Vec2f(32,16), 0);
    AddIconToken( "$custom_nursery$", "BF_Nursery.png", Vec2f(32,16), 0);
	AddIconToken( "$custom_furnace$", "BF_Furnace.png", Vec2f(32,16), 0);

    // SHOP
    this.set_Vec2f("shop offset", Vec2f(0, 0));
    this.set_Vec2f("shop menu size", Vec2f(2,4));
    this.set_string("shop description", "Construct");
    this.set_u8("shop icon", 12);

    // WOODSHOP
    {
        ShopItem@ s = addShopItem( this, "Kitchen", "$custom_kitchen$", "bf_kitchen", "Construct a Kitchen for all your cooking needs!");
        AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 70 );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 50 );
    }
	{
        ShopItem@ s = addShopItem( this, "Barracks", "$custom_barracks$", "bf_barracks", "Construct a Barracks to hire some pigs");
        AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 100 );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 70 );
    }
	{
        ShopItem@ s = addShopItem( this, "Nursery", "$custom_nursery$", "bf_nursery", "Construct a Nursery to grow plants");
        AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 100 );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 10 );
    }
	{
        ShopItem@ s = addShopItem( this, "Furnace", "$custom_furnace$", "bf_furnace", "Construct a Furnace");
        AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 100 );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 50 );
    }

}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
    if (cmd == this.getCommandID("shop made item"))
    {
        this.getSprite().PlaySound("/Construct.ogg" ); 
        this.getSprite().getVars().gibbed = true;
        this.server_Die();
    }
}