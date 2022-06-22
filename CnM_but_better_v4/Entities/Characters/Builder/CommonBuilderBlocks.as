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

#include "BuildBlock.as"
#include "Requirements.as"
#include "Costs.as"
#include "CustomBlocks.as"

const string blocks_property = "blocks";
const string inventory_offset = "inventory offset";

void addCommonBuilderBlocks(BuildBlock[][]@ blocks, const string&in gamemode_override = "")
{
	InitCosts();

	BuildBlock[] page_0;
	blocks.push_back(page_0);
	{
		BuildBlock b(CMap::tile_goldbrick, "gold_brick", "$gold_brick$", "Gold Brick\nCareful! Cats can break it.");
		AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 20);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_ladder_n, "ladder", "$ladder_tile$", "Ladder\nAnyone can climb it");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 5);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_wood_back, "back_wood_block", "$back_wood_block$", "Back Wood Wall\nCheap extra support");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 15);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "spikes", "$spikes$", "Spikes\nPlace on Stone Block\nfor Retracting Trap");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 40);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_fake_dirt, "", "$fake_dirt$", "Fake dirt\nYou can go trough it. Cats too.");
		AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 20);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_fake_castle, "", "$fake_castle$", "Fake castle wall\nYou can go trough it. Cats too.");
		AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 15);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_fake_wood, "", "$fake_wood$", "Fake wood wall\nYou can go trough it. Cats too.");
		AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 15);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_fake_goldbrick, "", "$fake_gold_brick$", "Fake gold brick\nYou can go trough it. Cats too.");
		AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 20);
		blocks[0].push_back(b);
	}
}
