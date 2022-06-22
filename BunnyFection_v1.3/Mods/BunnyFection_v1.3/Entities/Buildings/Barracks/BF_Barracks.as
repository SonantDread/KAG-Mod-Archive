// BF_Workbench script

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
    AddIconToken( "$custom_pigwar$", "Pigwar.png", Vec2f(16,8), 3);
    AddIconToken( "$custom_fishy$", "Fishy.png", Vec2f(16,16), 8);  
    // SHOP
    this.set_Vec2f("shop offset", Vec2f(0, 0));
    this.set_Vec2f("shop menu size", Vec2f(3,2));
    this.set_string("shop description", "Craft");

    // WOOD
    {   // Wood Block
        ShopItem@ s = addShopItem( this, "Pig Guard", "$custom_pigwar$", "pigwaregg", "Hire a piglet to fight for you!", false );
        AddRequirement( s.requirements, "blob", "bf_carrot", "Carrot", 2 );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 50 );
    }
    
    
	
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
    if (cmd == this.getCommandID("shop made item"))
    {
        this.getSprite().PlaySound("/ConstructShort.ogg" );
    }
}
