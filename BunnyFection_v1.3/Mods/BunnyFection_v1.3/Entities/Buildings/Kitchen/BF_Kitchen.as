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
    AddIconToken( "$custom_carrot$", "BF_CarrotCooked.png", Vec2f(8,16), 6);
    AddIconToken( "$custom_fishy$", "Fishy.png", Vec2f(16,16), 8);  
	AddIconToken( "$custom_piggy$", "BF_PigCooked.png", Vec2f(16,16), 8); 
    // SHOP
    this.set_Vec2f("shop offset", Vec2f(0, 0));
    this.set_Vec2f("shop menu size", Vec2f(2,2));
    this.set_string("shop description", "Craft");

    // WOOD
    {   // Wood Block
        ShopItem@ s = addShopItem( this, "Cooked Carrot", "$custom_carrot$", "bf_carrotcooked", "Cook a Carrot!", false );
        AddRequirement( s.requirements, "blob", "bf_carrot", "Carrot", 1 );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 5 );
    }
    {   // Wood Door
        ShopItem@ s = addShopItem( this, "Cooked fish", "$custom_fishy$", "bf_fishycooked", "Cook a Fish!", false );
        AddRequirement( s.requirements, "blob", "fishy", "Fish", 1 );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 5 );
    }
	{   // Wood Door
        ShopItem@ s = addShopItem( this, "Cooked Pig", "$custom_piggy$", "pigcooked", "Roast a Pig!", false );
        AddRequirement( s.requirements, "blob", "bf_piglet", "Pig", 1 );
		AddRequirement( s.requirements, "blob", "mat_wood", "Wood", 5 );
    }
    
    
	
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
    if (cmd == this.getCommandID("shop made item"))
    {
        this.getSprite().PlaySound("/ConstructShort.ogg" );
    }
}
