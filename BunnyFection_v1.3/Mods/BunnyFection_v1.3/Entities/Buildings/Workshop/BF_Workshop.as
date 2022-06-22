// BF_Workshop script

#include "Requirements.as";
#include "ShopCommon.as";
#include "CheckSpam.as";
#include "BF_Costs.as";

void onInit( CBlob@ this )
{
    this.set_TileType("background tile", CMap::tile_wood_back);
    this.getSprite().SetZ(-50);
    this.getShape().getConsts().mapCollisions = false;

    // ICONS
    AddIconToken( "$custom_workbench$", "BF_WorkshopIcons.png", Vec2f(16,16), 0);
	AddIconToken( "$custom_saw$", "BF_Saw.png", Vec2f(16,16), 0);
    AddIconToken( "$custom_forge$", "BF_WorkshopIcons.png", Vec2f(16,16), 1);
    AddIconToken( "$custom_anvil$", "BF_WorkshopIcons.png", Vec2f(16,16), 2);
    AddIconToken( "$custom_laboratory$", "BF_WorkshopIcons.png", Vec2f(16,16), 3);
    AddIconToken( "$custom_storage$", "BF_WorkshopIcons.png", Vec2f(16,16), 4);
	AddIconToken( "$custom_roast$", "BF_Roast.png", Vec2f(16,16), 0);

    // SHOP
    this.set_Vec2f("shop offset", Vec2f(0, 0));
    this.set_Vec2f("shop menu size", Vec2f(3,3));
    this.set_string("shop description", "Construct");
    this.set_u8("shop icon", 12);

    // WOODSHOP
    {
        ShopItem@ s = addShopItem( this, "Workbench", "$custom_workbench$", "bf_workbench", "Construct a Woodshop for crafting basic Wood blocks.");
        AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 60 );
    }
    {
        ShopItem@ s = addShopItem( this, "Saw", "$custom_saw$", "bf_saw", "Construct a Saw to Turn Shrubs into Wood.");
        AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 60 );
		AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 20 );
    }
    // MASON
    {
        ShopItem@ s = addShopItem( this, "Mason", "$custom_anvil$", "bf_mason", "Construct a Mason for crafting basic Stone blocks.");
        AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 100 );
        AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 20 );
    }
    // LABORATORY
    {
        ShopItem@ s = addShopItem( this, "Laboratory", "$custom_laboratory$", "bf_laboratory", "Construct a Laboratory for crafting potions." );
        AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 100 );
        AddRequirement( s.requirements, "blob", "mat_stone", "Stone", 50 );
    }
    // STORAGE
    {
        ShopItem@ s = addShopItem( this, "Storage", "$custom_storage$", "bf_storage", "Construct a Storage cache." );
        AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 60 );
    }
	{
        ShopItem@ s = addShopItem( this, "Roast", "$custom_roast$", "bf_roast", "Construct a Fire pit" );
        AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 20 );
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