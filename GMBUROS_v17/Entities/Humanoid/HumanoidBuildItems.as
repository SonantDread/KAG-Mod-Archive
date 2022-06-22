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

	BuildBlock[] Blank;
	BuildBlock[] WoodHammer;
	BuildBlock[] StoneHammer;
	BuildBlock[] MetalHammer;

	///////////Line 2: stone
	{
		BuildBlock b(CMap::tile_castle, "stone_block", "$stone_block$", "Stone Block\nBasic building block");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", BuilderCosts::stone_block);
		StoneHammer.push_back(b);
		MetalHammer.push_back(b);
	}
	{
		BuildBlock b(CMap::tile_castle_back, "back_stone_block", "$back_stone_block$", "Back Stone Wall\nExtra support");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", BuilderCosts::back_stone_block);
		StoneHammer.push_back(b);
		MetalHammer.push_back(b);
	}
	{
		AddIconToken("$stone_base$", "StoneBase.png", Vec2f(16, 16), 2);
		BuildBlock b(0, "stone_base", "$stone_base$", "Used to build stone structures.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 100);
		b.buildOnGround = true;
		b.size.Set(24, 24);
		StoneHammer.push_back(b);
		MetalHammer.push_back(b);
	}
	AddIconToken("$gold_brick_icon$", "world.png", Vec2f(8, 8), CMap::tile_gold_brick);
	{
		BuildBlock b(CMap::tile_gold_brick, "gold_brick", "$gold_brick_icon$", "Gold Block\nLavish building block");
		AddRequirement(b.reqs, "blob", "gold_bar", "Gold Bar", 1);
		StoneHammer.push_back(b);
		MetalHammer.push_back(b);
	}
	AddIconToken("$gold_pile_icon$", "world.png", Vec2f(8, 8), CMap::tile_gold_pile);
	{
		BuildBlock b(CMap::tile_gold_pile, "gold_pile", "$gold_pile_icon$", "Gold Pile\nCompact gold storage");
		AddRequirement(b.reqs, "blob", "gold_bar", "Gold Bar", 1);
		StoneHammer.push_back(b);
		MetalHammer.push_back(b);
	}
	
	///////////Line 1: wood
	{
		BuildBlock b(CMap::tile_wood, "wood_block", "$wood_block$", "Wood Block\nCheap block\nwatch out for fire!");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 25);
		WoodHammer.push_back(b);
		StoneHammer.push_back(b);
		MetalHammer.push_back(b);
	}
	{
		BuildBlock b(CMap::tile_wood_back, "back_wood_block", "$back_wood_block$", "Back Wood Wall\nCheap extra support");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		WoodHammer.push_back(b);
		StoneHammer.push_back(b);
		MetalHammer.push_back(b);
	}
	{
		AddIconToken("$wood_base$", "WoodBase.png", Vec2f(16, 16), 2);
		BuildBlock b(0, "wood_base", "$wood_base$", "Used to build basic furniture.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 50);
		b.buildOnGround = true;
		b.size.Set(24, 24);
		WoodHammer.push_back(b);
		StoneHammer.push_back(b);
		MetalHammer.push_back(b);
	}
	{
		BuildBlock b(0, "wooden_platform", "$wooden_platform$", "Wooden Platform\nOne way platform");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", BuilderCosts::wooden_platform);
		WoodHammer.push_back(b);
		StoneHammer.push_back(b);
		MetalHammer.push_back(b);
	}
	AddIconToken("$dirt_icon$", "world.png", Vec2f(8, 8), CMap::tile_ground);
	{
		BuildBlock b(CMap::tile_ground, "ground_block", "$dirt_icon$", "Dirt Block\nA block of soil.\nCan only be placed on dirt background.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", BuilderCosts::wood_block);
		WoodHammer.push_back(b);
		StoneHammer.push_back(b);
		MetalHammer.push_back(b);
	}
	
	blocks.push_back(Blank);
	blocks.push_back(WoodHammer);
	blocks.push_back(StoneHammer);
	blocks.push_back(MetalHammer);
}
