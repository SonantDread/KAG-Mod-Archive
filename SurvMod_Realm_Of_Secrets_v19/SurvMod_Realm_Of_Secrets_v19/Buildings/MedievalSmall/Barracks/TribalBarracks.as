// BuilderShop.as

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "ClassSelectMenu.as";
#include "StandardRespawnCommand.as";

void onInit(CBlob@ this)
{
	//this.set_TileType("background tile", CMap::tile_wood_back);
	
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
	InitClasses( this );
	InitRespawnCommand( this );
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	CBitStream params;
	params.write_u16( caller.getNetworkID() );
	if ((this.getPosition() - caller.getPosition()).Length() < 18.0f) {
		BuildRespawnMenuFor( this, caller );
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	{
		onRespawnCommand( this, cmd, params );
	}
}