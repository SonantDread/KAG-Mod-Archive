
// Making seeds - pass a blob name and grow time and it will set up and return the seed
// only functions on server - make sure to check for null.

// modify seed.as to make custom seed appearances

#include "ProductionCommon.as"
#include "BF_Nursery.as"

ShopItem@ addShrubItem( CBlob@ this, const string &in seedName,
	const string &in  description, u16 timeToMakeSecs, const u16 quantityLimit, CBitStream@ requirements = null )
{
	
	ShopItem@ item = addProductionItem( this, "Shrub", "$custom_shrub$", "bf_shrubplant", "Shrub", 15, false, 2, requirements );
	return item;
}
ShopItem@ addCarrotItem( CBlob@ this, const string &in seedName,
	const string &in  description, u16 timeToMakeSecs, const u16 quantityLimit, CBitStream@ requirements = null )
{
	
	ShopItem@ item = addProductionItem( this, "Carrot", "$custom_carrot$", "bf_carrotplant", "Carrot", 10, false, 1, requirements );
	return item;
}
ShopItem@ addRocknutItem( CBlob@ this, const string &in seedName,
	const string &in  description, u16 timeToMakeSecs, const u16 quantityLimit, CBitStream@ requirements = null )
{
	
	ShopItem@ item = addProductionItem( this, "Rocknut", "$custom_rocknut$", "bf_rocknutplant", "Rocknut", 15, false, 1, requirements );
	return item;
}
