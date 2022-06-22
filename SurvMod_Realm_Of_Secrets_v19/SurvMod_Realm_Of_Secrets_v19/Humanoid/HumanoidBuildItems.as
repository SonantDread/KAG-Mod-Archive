// CommonBuilderBlocks.as

#include "BuildBlock.as"
#include "Requirements.as"
#include "Costs.as"
#include "EquipmentCommon.as";
#include "CMap.as";

const string blocks_property = "blocks";
const string inventory_offset = "inventory offset";

void addCommonBuilderBlocks(CBlob @this, BuildBlock[][]@ blocks)
{
	InitCosts();

	BuildBlock[] feudal;
	BuildBlock[] medieval;

	///////////Line 1: stone
	{
		BuildBlock b(CMap::tile_castle, "stone_block", "$stone_block$", "Stone Block\nBasic building block");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", BuilderCosts::stone_block);
		medieval.push_back(b);
	}
	{
		BuildBlock b(CMap::tile_castle_back, "back_stone_block", "$back_stone_block$", "Back Stone Wall\nExtra support");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", BuilderCosts::back_stone_block);
		medieval.push_back(b);
	}
	{
		BuildBlock b(0, "stone_door", "$stone_door$", "Stone Door\nPlace next to walls");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", BuilderCosts::stone_door);
		medieval.push_back(b);
	}
	///////////Line 2: wood
	{
		BuildBlock b(CMap::tile_wood, "wood_block", "$wood_block$", "Wood Block\nCheap block\nwatch out for fire!");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", BuilderCosts::wood_block);
		feudal.push_back(b);
		medieval.push_back(b);
	}
	{
		BuildBlock b(CMap::tile_wood_back, "back_wood_block", "$back_wood_block$", "Back Wood Wall\nCheap extra support");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", BuilderCosts::back_wood_block);
		feudal.push_back(b);
		medieval.push_back(b);
	}
	{
		BuildBlock b(0, "wooden_door", "$wooden_door$", "Wooden Door\nPlace next to walls");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", BuilderCosts::wooden_door);
		feudal.push_back(b);
		medieval.push_back(b);
	}
	///////////Line 3: Misc blocks
	AddIconToken("$dirt_icon$", "world.png", Vec2f(8, 8), CMap::tile_ground);
	{
		BuildBlock b(CMap::tile_ground, "ground_block", "$dirt_icon$", "Dirt Block\nA block of soil.\nCan only be placed on dirt background.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", BuilderCosts::wood_block);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", BuilderCosts::stone_block);
		feudal.push_back(b);
		medieval.push_back(b);
	}
	AddIconToken("$gold_brick_icon$", "world.png", Vec2f(8, 8), CMap::tile_gold_brick);
	{
		BuildBlock b(CMap::tile_gold_brick, "gold_brick", "$gold_brick_icon$", "Gold Block\nLavish building block");
		AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 8);
		feudal.push_back(b);
		medieval.push_back(b);
	}
	AddIconToken("$gold_pile_icon$", "world.png", Vec2f(8, 8), CMap::tile_gold_pile);
	{
		BuildBlock b(CMap::tile_gold_pile, "gold_pile", "$gold_pile_icon$", "Gold Pile\nCompact gold storage");
		AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 10);
		feudal.push_back(b);
		medieval.push_back(b);
	}
	///////////Line 4: 3x3 and more wood stuff
	{
		AddIconToken("$feudal_small_icon$", "Feudal_Small.png", Vec2f(16, 16), 2);
		BuildBlock b(0, "feudal_building_small", "$feudal_small_icon$", "Used to build feudal structures.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 50);
		b.buildOnGround = true;
		b.size.Set(24, 24);
		feudal.push_back(b);
	}
	{
		AddIconToken("$medieval_small_icon$", "Medieval_Small.png", Vec2f(16, 16), 2);
		BuildBlock b(0, "medieval_building_small", "$medieval_small_icon$", "Used to build small medieval structures.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 50);
		b.buildOnGround = true;
		b.size.Set(24, 24);
		medieval.push_back(b);
	}
	{
		BuildBlock b(0, "ladder", "$ladder$", "Ladder\nAnyone can climb it");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", BuilderCosts::ladder);
		feudal.push_back(b);
		medieval.push_back(b);
	}
	{
		BuildBlock b(0, "wooden_platform", "$wooden_platform$", "Wooden Platform\nOne way platform");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", BuilderCosts::wooden_platform);
		feudal.push_back(b);
		medieval.push_back(b);
	}
	///////////Line 5: 5x3 and more stone stuff
	{
		BuildBlock b(0, "medieval_building", "$building$", "Used to build medieval structures.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 100);
		b.buildOnGround = true;
		b.size.Set(40, 24);
		medieval.push_back(b);
	}
	{
		BuildBlock b(0, "trap_block", "$trap_block$", "Trap Block\nOnly enemies can pass");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", BuilderCosts::trap_block);
		medieval.push_back(b);
	}
	{
		BuildBlock b(0, "spikes", "$spikes$", "Spikes\nPlace on Stone Block\nfor Retracting Trap");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", BuilderCosts::spikes);
		medieval.push_back(b);
	}
	///////////Line 6: halls
	{
		AddIconToken("$hall_icon$", "HallIcon.png", Vec2f(24, 24), 0);
		BuildBlock b(0, "hall_building", "$hall_icon$", "Used to build large medieval structures.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 150);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 150);
		b.buildOnGround = true;
		b.size.Set(80, 56);
		medieval.push_back(b);
	}
	{
		AddIconToken("$conveyor_icon$", "Conveyor.png", Vec2f(8, 8), 0);
		BuildBlock b(0, "conveyor", "$conveyor_icon$", "Conveyor Belt\nPushes items that land on it.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		medieval.push_back(b);
	}
	{
		AddIconToken("$climber_icon$", "Climber.png", Vec2f(8, 8), 0);
		BuildBlock b(0, "climber", "$climber_icon$", "Climber\nMoves any items it touches upwards.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 5);
		medieval.push_back(b);
	}
	{
		AddIconToken("$dropper_icon$", "Dropper.png", Vec2f(8, 8), 0);
		BuildBlock b(0, "dropper", "$dropper_icon$", "Dropper Belt\nPushes items that land on it, drops items in it's whitelist.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		medieval.push_back(b);
	}
	{
		AddIconToken("$autosaw_icon$", "AutoSaw.png", Vec2f(16, 16), 1);
		BuildBlock b(0, "auto_saw", "$autosaw_icon$", "Auto-Saw\nChops up any trees and logs nearby.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		AddRequirement(b.reqs, "blob", "mat_metal", "Metal", 2);
		medieval.push_back(b);
	}
	
	blocks.push_back(feudal);
	blocks.push_back(medieval);
	
	/*
	{
		BuildBlock b(0, "bulwark_chest_base", "$icon_flag$", "Team Flag");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 500);
		AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 100);
		b.buildOnGround = true;
		b.size.Set(24, 24);
		blocks[0].push_back(b);
	}
	
	AddIconToken("$icon_flag$", "Chest.png", Vec2f(24, 24), 0);*/
}
