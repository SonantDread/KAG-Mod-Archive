// CommonBuilderBlocks.as

//////////////////////////////////////
// Builder menu documentation
//////////////////////////////////////

// To add a new page;

// 1) initialize a new BuildBlock array, 
// example:
// BuildBlock[] my_page;
// blocks.push_back(my_page);

// 2) 
// Add a new string to PAGE_NAME in 
// BuilderInventory.as
// this will be what you see in the caption
// box below the menu

// 3)
// Extend BuilderPageIcons.png with your new
// page icon, do note, frame index is the same
// as array index

// To add new blocks to a page, push_back
// in the desired order to the desired page
// example:
// BuildBlock b(0, "name", "icon", "description");
// blocks[3].push_back(b);

#include "BuildBlock.as";
#include "Requirements.as";

const string blocks_property = "blocks";
const string inventory_offset = "inventory offset";

void addCommonBuilderBlocks(BuildBlock[][]@ blocks)
{

	AddIconToken("$forge$", "Forge.png", Vec2f(16, 24), 0);
	AddIconToken("$counter$", "Counter.png", Vec2f(16, 16), 3);
	AddIconToken("$markettable$", "MarketTable.png", Vec2f(16, 16), 3);
	AddIconToken("$chest$", "Chest.png", Vec2f(16, 16), 1);
	AddIconToken("$constructionyard$", "ConstructionYardIcon.png", Vec2f(16, 16), 0);
	AddIconToken("$ground_block$", "Sprites/World.png", Vec2f(8, 8), CMap::tile_ground);
	
	BuildBlock[] page_0;
	blocks.push_back(page_0);
	{
		BuildBlock b(CMap::tile_castle, "stone_block", "$stone_block$", "Stone Block\nBasic building block");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_castle_back, "back_stone_block", "$back_stone_block$", "Back Stone Wall\nExtra support");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 2);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "stone_door", "$stone_door$", "Stone Door\nPlace next to walls");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 50);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_wood, "wood_block", "$wood_block$", "Wood Block\nCheap block\nwatch out for fire!");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_wood_back, "back_wood_block", "$back_wood_block$", "Back Wood Wall\nCheap extra support");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 2);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "wooden_door", "$wooden_door$", "Wooden Door\nPlace next to walls");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 30);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "trap_block", "$trap_block$", "Trap Block\nOnly enemies can pass");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 25);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "ladder", "$ladder$", "Ladder\nAnyone can climb it");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "wooden_platform", "$wooden_platform$", "Wooden Platform\nOne way platform");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 15);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "spikes", "$spikes$", "Spikes\nPlace on Stone Block\nfor Retracting Trap");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_ground, "ground_block", "$ground_block$", "Dirt");
		AddRequirement(b.reqs, "blob", "mat_sand", "Sand", 10);
		blocks[0].push_back(b);
	}
	/*{ //Moved to log
		BuildBlock b(0, "fireplace", "$fireplace$", "Camp  Fire");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 50);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 50);
		b.buildOnGround = true;
		b.size.Set(16, 16);
		blocks[0].push_back(b);
	}*/
	{
		BuildBlock b(0, "counter", "$counter$", "Cooking Counter");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 50);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 25);
		b.buildOnGround = true;
		b.size.Set(32, 16);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "workbench", "$workbench$", "Workbench");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 120);
		b.buildOnGround = true;
		b.size.Set(32, 16);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "chest_storage", "$chest$", "Chest");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 75);
		b.buildOnGround = true;
		b.size.Set(16, 16);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "markettable", "$markettable$", "Market Stall");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 100);
		b.buildOnGround = true;
		b.size.Set(16, 16);
		blocks[0].push_back(b);
	}
	/*{ //Moved to campfire/log
		BuildBlock b(0, "forge", "$forge$", "Forge");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 100);
		b.buildOnGround = true;
		b.size.Set(16, 24);
		blocks[0].push_back(b);
	}*/
	{
		BuildBlock b(0, "bed", "$bed$", "Bed");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 75);
		b.buildOnGround = true;
		b.size.Set(24, 16);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "construction_yard", "$constructionyard$", "Construction Yard");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 150);
		b.buildOnGround = true;
		b.size.Set(64, 56);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "flag_base", "$icon_flag$", "Team Chest");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 250);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 250);
		AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 100);
		b.buildOnGround = true;
		b.size.Set(24, 24);
		blocks[0].push_back(b);
	}
	
	
	
}