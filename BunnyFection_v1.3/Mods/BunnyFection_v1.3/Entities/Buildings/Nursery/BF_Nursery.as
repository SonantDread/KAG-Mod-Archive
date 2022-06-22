// BF_Workbench script
#include "ProductionCommon.as";
#include "MakePlants.as";
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
    
    AddIconToken( "$custom_carrot$", "BF_Carrot.png", Vec2f(8,16), 3);  
	AddIconToken( "$custom_rocknut$", "BF_Rocknut.png", Vec2f(8,16), 3);  
    AddIconToken( "$custom_shrub$", "BF_Shrub.png", Vec2f(16,24), 4);

    // WOOD
    {   // Wood Block      
       addShrubItem( this, "tree_pine", "Pine tree seed", 8, 3 );
    }
	{   // Wood Block      
       addCarrotItem( this, "tree_pine", "Pine tree seed", 8, 3 );
    }
	{   // Wood Block      
       addRocknutItem( this, "tree_pine", "Pine tree seed", 8, 3 );
    }
    this.Tag("inventory access");
	
    this.set_string("blob tag", "bf_plant");
	
	this.inventoryButtonPos = Vec2f(0.0f, 0.0f);


}
void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
    if (cmd == this.getCommandID("shop made item"))
    {
        this.getSprite().PlaySound("/ConstructShort.ogg" );
    }
}

