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
    AddIconToken( "$custom_blockwood$", "BF_BlockWood.png", Vec2f(8,8), 0);
    AddIconToken( "$custom_doorwood$", "BF_DoorWood.png", Vec2f(16,8), 0);
    AddIconToken( "$custom_candle$", "BF_Candle.png", Vec2f(8,8), 4);
   
    AddIconToken( "$custom_turretballista$", "BF_WoodTurretBallista.png", Vec2f(24,16), 9);
   
    AddIconToken( "$custom_platformwood$", "BF_PlatformWood.png", Vec2f(8,8), 0);
	AddIconToken( "$custom_ladderwood$", "BF_LadderWood.png", Vec2f(16,16), 6);

    // SHOP
    this.set_Vec2f("shop offset", Vec2f(0, 0));
    this.set_Vec2f("shop menu size", Vec2f(3,2));
    this.set_string("shop description", "Craft");

    // WOOD
    {   // Wood Block
        ShopItem@ s = addShopItem( this, "Wood Block", "$custom_blockwood$", "bf_blockwood", "Craft a Wood Block.", false );
        AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 1 );
    }
    {   // Wood Door
        ShopItem@ s = addShopItem( this, "Wood Door", "$custom_doorwood$", "bf_doorwood", "Craft a Wood Door.", false );
        AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_WDOOR );
    }
    {   // Candle
        ShopItem@ s = addShopItem( this, "Candle", "$custom_candle$", "bf_candle", "Craft a small candle, illuminates a small area.", false );
        AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_CANDLE );
    }
    {   // Wood Ballista
        ShopItem@ s = addShopItem( this, "Wood Ballista", "$custom_turretballista$", "bf_woodturretballista", "Craft a Wood Ballista that automatically fires at intruders.", false );
        AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_BALLISTA );
        AddRequirement( s.requirements, "blob", "mat_stone", "Stone", COST_STONE_BALLISTA );
    }
    {   // Wood Platform
        ShopItem@ s = addShopItem( this, "Wood Platform", "$custom_platformwood$", "bf_platformwood", "Craft a Wood Platform.", false );
        AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_PLATFORM );
    }
    {   // Wood Ladder
        ShopItem@ s = addShopItem( this, "Wood Ladder", "$custom_ladderwood$", "bf_ladderwood", "Craft a Wood Ladder.", false );
        AddRequirement( s.requirements, "blob", "mat_wood", "Wood", COST_WOOD_LADDER);
    }
	
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
    if (cmd == this.getCommandID("shop made item"))
    {
        this.getSprite().PlaySound("/ConstructShort.ogg" );
    }
}
