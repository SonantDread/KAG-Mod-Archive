// BF_Workbench script

#include "Requirements.as"
#include "ShopCommon.as";
#include "CheckSpam.as";
#include "BF_Costs.as";
#include "Hitters.as";
void onInit( CBlob@ this )
{
    this.set_TileType("background tile", CMap::tile_wood_back);
    this.getSprite().SetZ(-50);
    this.getShape().getConsts().mapCollisions = false;

    // ICONS
    AddIconToken( "$custom_blockwood$", "BF_BlockWood.png", Vec2f(8,8), 0);
  

    // SHOP
    this.set_Vec2f("shop offset", Vec2f(0, 0));
    this.set_Vec2f("shop menu size", Vec2f(1,1));
    this.set_string("shop description", "Craft");

    // WOOD
    {   // Wood Block
        ShopItem@ s = addShopItem( this, "Wood", "$custom_blockwood$", "mat_wood", "Cut a Shrub", false );
        AddRequirement( s.requirements, "blob", "bf_shrubplant", "Shrubs", 1 );
    }
    
	
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
    if (cmd == this.getCommandID("shop made item"))
    {
        this.getSprite().PlaySound("/ConstructShort.ogg" );
    }
}

