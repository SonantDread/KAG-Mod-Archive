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
#include "TeamIconToken.as"
#include "CustomBlocks.as"

const string blocks_property = "blocks";
const string inventory_offset = "inventory offset";

void addCommonBuilderBlocks(BuildBlock[][]@ blocks, int team_num = 0, const string&in gamemode_override = "")
{
AddIconToken("$steel_block$", "World.png", Vec2f(8, 8), CMap::tile_steel);
AddIconToken("$gold_block$", "World.png", Vec2f(8, 8), CMap::tile_castle_gold);
AddIconToken("$gold_brick$", "World.png", Vec2f(8, 8), CMap::tile_birk_godl);
AddIconToken("$mossy_wood$", "World.png", Vec2f(8, 8), CMap::tile_mossy_wood);
AddIconToken("$bedrock$", "World.png", Vec2f(8, 8), CMap::tile_bedrock);
	InitCosts();
	CRules@ rules = getRules();

	string gamemode = rules.gamemode_name;
	if (gamemode_override != "")
	{
		gamemode = gamemode_override;

	}

	const bool CTF = gamemode == "CTF";
	const bool SCTF = gamemode == "SmallCTF";
	const bool TTH = gamemode == "TTH";
	const bool SBX = gamemode == "Sandbox";

	BuildBlock[] page_0;
	blocks.push_back(page_0);
	{
		BuildBlock b(CMap::tile_castle, "stone_block", "$stone_block$", "Stone Block\nBasic building block");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone",  0);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_castle_back, "back_stone_block", "$back_stone_block$", "Back Stone Wall\nExtra support");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone",  0);
		blocks[0].push_back(b);
	}
	{
		AddIconToken("$stone_moss_block$", "Sprites/World.png", Vec2f(8, 8), CMap::tile_castle_moss);
		BuildBlock b( CMap::tile_castle_moss, "stone_moss_block", "$stone_moss_block$", "Mossy Stone Block" );
		AddRequirement( b.reqs, "blob", "mat_stone", "Stone", 0 );
		blocks[0].push_back( b );
	}
	{
		AddIconToken("$back_stone_moss_block$", "Sprites/World.png", Vec2f(8, 8), CMap::tile_castle_back_moss);
		BuildBlock b( CMap::tile_castle_back_moss, "back_stone_moss_block", "$back_stone_moss_block$", "Mossy Back Stone Wall" );
		AddRequirement( b.reqs, "blob", "mat_stone", "Stone", 0 );
		blocks[0].push_back( b );
	}
	{
		BuildBlock b(CMap::tile_castle_gold, "gold_block", "$gold_block$", "Gold Block\nBasic building block made with gold");
		AddRequirement(b.reqs, "blob", "mat_gold", "Gold",  0);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_birk_godl, "gold_brick", "$gold_brick$", "Gold Brick\nOld basic building block made with gold");
		AddRequirement(b.reqs, "blob", "mat_gold", "Gold",  0);
		blocks[0].push_back(b);
	}
	{
		AddIconToken("$dark_castle_block$", "Sprites/World.png", Vec2f(8, 8), CMap::tile_dark_castle_block);
		BuildBlock b( CMap::tile_dark_castle_block, "dark_castle_block", "$dark_castle_block$", "Dark Castle Block" );
		AddRequirement( b.reqs, "blob", "mat_stone", "Stone", 0 );
		blocks[0].push_back( b );
	}
	{
		BuildBlock b(CMap::tile_bedrock, "bedrock", "$bedrock$", "Bedrock\nHeavy block");
		AddRequirement(b.reqs, "blob", "mat_bedrock", "Bedrock",  100);
		blocks[0].push_back(b);
	}
{
		BuildBlock b(CMap::tile_steel, "steel_block", "$steel_block$", "Steel Block\nBasic building block made with steel");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone",  0);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_birk_godl, "gold_brick", "$gold_brick$", "Gold Brick\nOld basic building block made with gold");
		AddRequirement(b.reqs, "blob", "mat_gold", "Gold",  0);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "stone_door", getTeamIcon("stone_door", "1x1StoneDoor.png", team_num, Vec2f(16, 8)), "Stone Door\nPlace next to walls");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone",  0);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "gold_door", getTeamIcon("gold_door", "GoldDoorIcon.png", team_num, Vec2f(16, 16)), "Gold Door\nPlace next to walls");
		AddRequirement(b.reqs, "blob", "mat_gold", "Gold",  0);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "steel_door", getTeamIcon("steel_door", "1x1SteelDoor.png", team_num, Vec2f(16, 16)), "Steel Door\nUnbreakable by an normal builder");
		AddRequirement(b.reqs, "blob", "mat_steel", "Steel",  10);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_wood, "wood_block", "$wood_block$", "Wood Block\nCheap block\nwatch out for fire!");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 0);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_wood_back, "back_wood_block", "$back_wood_block$", "Back Wood Wall\nCheap extra support");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 0);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "wooden_door", getTeamIcon("wooden_door", "1x1WoodDoor.png", team_num, Vec2f(16, 8)), "Wooden Door\nPlace next to walls");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood",  0);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "trap_block", getTeamIcon("trap_block", "TrapBlock.png", team_num), "Trap Block\nOnly enemies can pass");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone",  0);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "fire_trap_block", "$fire_trap_block$", "Fire Trap");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 20);
		AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 5);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "bridge", getTeamIcon("bridge", "Bridge.png", team_num), "Trap Bridge\nOnly your team can stand on it");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood",  0);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "ladder", "$ladder$", "Ladder\nAnyone can climb it");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood",  0);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "triangle", "$triangle$", "StoneTriangle\nFor your vehicles and stairs");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "wtriangle", "$wtriangle$", "WoodTriangle\nFor your vehicles and stairs");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 0);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "wooden_platform", "$wooden_platform$", "Wooden Platform\nOne way platform");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood",  0);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "spikes", "$spikes$", "Spikes\nPlace on Stone Block\nfor Retracting Trap");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone",  20);
		blocks[0].push_back(b);
	}
	/*{
		BuildBlock b(0, "woodenspikes", "$woodenspikes$", "Wooden Spikes\nPlace on Wood Block\nfor Retracting Trap");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 0);
		blocks[0].push_back(b);
	}*/
	{
		BuildBlock b(0, "mushroom_block", "$mushroom_block$", "Bouncy mushroom");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone",  50);
		//AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 0);
		blocks[0].push_back(b);
	}
	/*{
		BuildBlock b(0, "stalagmite", "$stalagmite$", "Stalagmite");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone",  50);
		blocks[0].push_back(b);
	}*/
	{
		BuildBlock b(0, "torch", "$torch$", "Torch\nLight the caves.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 0);
		blocks[0].push_back(b);
	}

	if (CTF || SCTF)
	{
		BuildBlock b(0, "building", "$building$", "Workshop\nStand in an open space\nand tap this button.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", CTFCosts::workshop_wood);
		b.buildOnGround = true;
		b.size.Set(40, 24);
		blocks[0].insertAt(9, b);
	}
	else if (TTH)
	{
		{
			BuildBlock b(0, "factory", "$building$", "Factory\nAn item-producing factory\nRequires migrant");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", WARCosts::factory_wood);
			b.buildOnGround = true;
			b.size.Set(40, 24);
			blocks[0].insertAt(9, b);
		}
		{
			BuildBlock b(0, "workbench", "$workbench$", "Workbench\nCreate trampolines, saws, and more");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", WARCosts::workbench_wood);
			b.buildOnGround = true;
			b.size.Set(32, 16);
			blocks[0].push_back(b);
		}
	}
	else if (SBX)
	{
			
		BuildBlock[] page_1;
		blocks.push_back(page_1);
		
		{
			BuildBlock b(0, "building", "$building$", "Workshop\nStand in an open space\nand tap this button.");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 50);
			b.buildOnGround = true;
			b.size.Set(40, 24);
			blocks[1].push_back(b);
		}
		{
			BuildBlock b(0, "largebuilding", "$largebuilding$", "Large Building");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 300);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 250);
			b.buildOnGround = true;
			b.size.Set(80, 48);
			blocks[1].push_back(b);
		}
			{
			BuildBlock b(0, "factory", "$building$", "Factory\nAn item-producing factory\nRequires migrant");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", WARCosts::factory_wood);
			b.buildOnGround = true;
			b.size.Set(40, 24);
			blocks[1].push_back(b);
		}
		{
			BuildBlock b(0, "techmain", "$techmain$", "Technologie Main");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 300);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 250);
			b.buildOnGround = true;
			b.size.Set(40, 24);
			blocks[1].push_back(b);
		}
			{
			BuildBlock b(0, "workbench", "$workbench$", "Workbench\nCreate trampolines, saws, and more");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", WARCosts::workbench_wood);
			b.buildOnGround = true;
			b.size.Set(32, 16);
			blocks[1].push_back(b);
		}
		{
			BuildBlock b(0, "fireplace", "$fireplace$", "Fire Place");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 25);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 50);
			b.buildOnGround = true;
			b.size.Set(16, 16);
			blocks[1].push_back(b);
		}
		{
			BuildBlock b(0, "bed", "$bed$", "Bed");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 50);
			b.buildOnGround = true;
			b.size.Set(16, 16);
			blocks[1].push_back(b);
		}
		{
			BuildBlock b(0, "warboat_door", "$warboat_door$", "Wooden Door");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 75);
			blocks[1].push_back(b);
		}
		{
			BuildBlock b(0, "seat", "$seat$", "Wooden Chair");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 25);
			blocks[1].push_back(b);
		}
		/*{
			BuildBlock b(0, "tdm_spawn", "$tdm_spawn$", "Ruins");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 150);
			b.buildOnGround = true;
			b.size.Set(16, 16);
			blocks[1].push_back(b);
		}*/
		{
			BuildBlock b(0, "dummy", "$dummy$", "Dummy");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 25);
			b.buildOnGround = true;
			b.size.Set(16, 16);
			blocks[1].push_back(b);
		}
		{
			BuildBlock b(0, "chest", "$chest$", "Chest");
			AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 100);
			b.buildOnGround = true;
			b.size.Set(16, 16);
			blocks[1].push_back(b);
		}
		/*{
			BuildBlock b(0, "war_base", "$war_base$", "War Base");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 200);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 150);
			AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 50);
			b.buildOnGround = true;
			b.size.Set(16, 16);
			blocks[1].push_back(b);
		}*/
		{
			BuildBlock b(0, "tradingpost", "$tradingpost$", "Trading Post");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 150);
			b.buildOnGround = true;
			b.size.Set(32, 32);
			blocks[1].push_back(b);
		}
		{
			BuildBlock b(0, "gunzerkershop", "$gunzerkershop$", "Gunzerker Shop");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 150);
			AddRequirement(b.reqs, "blob", "whitepage", "Crystal Shard", 2);
			AddRequirement(b.reqs, "coins", "", "Coins", 150);
			b.buildOnGround = true;
			b.size.Set(32, 32);
			blocks[1].push_back(b);
		}
		{
			BuildBlock b(0, "tent", "$tent$", "Tent");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 100);
			AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 50);
			b.buildOnGround = true;
			b.size.Set(40, 40);
			blocks[1].push_back(b);
		}
		{
			BuildBlock b(0, "primitiveforge", "$primitiveforge$", "Primitive Forge\nBurn your wood for get advanced stuff.");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 500);
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 50);
			b.buildOnGround = true;
			b.size.Set(40, 24);
			blocks[1].push_back(b);
		}
		{
			BuildBlock b(0, "table", "$table$", "Table\nTake a seat and drink something.");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 0);
			blocks[1].push_back(b);
		}
		

		BuildBlock[] page_2;
		blocks.push_back(page_2);
		
		{
			BuildBlock b(0, "wire", "$wire$", "Wire");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 0);
			blocks[2].push_back(b);
		}
		{
			BuildBlock b(0, "elbow", "$elbow$", "Elbow");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 0);
			blocks[2].push_back(b);
		}
		{
			BuildBlock b(0, "tee", "$tee$", "Tee");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 0);
			blocks[2].push_back(b);
		}
		{
			BuildBlock b(0, "junction", "$junction$", "Junction");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			blocks[2].push_back(b);
		}
		{
			BuildBlock b(0, "diode", "$diode$", "Diode");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			blocks[2].push_back(b);
		}
		{
			BuildBlock b(0, "resistor", "$resistor$", "Resistor");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			blocks[2].push_back(b);
		}
		{
			BuildBlock b(0, "inverter", "$inverter$", "Inverter");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			blocks[2].push_back(b);
		}
		{
			BuildBlock b(0, "oscillator", "$oscillator$", "Oscillator");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			blocks[2].push_back(b);
		}	
		{
			BuildBlock b(0, "transistor", "$transistor$", "Transistor");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 0);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			blocks[2].push_back(b);
		}
		{
			BuildBlock b(0, "toggle", "$toggle$", "Toggle");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			blocks[2].push_back(b);
		}
		{
			BuildBlock b(0, "randomizer", "$randomizer$", "Randomizer");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			blocks[2].push_back(b);
		}
		{
			BuildBlock b(0, "lever", "$lever$", "Lever");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 0);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			blocks[2].push_back(b);
		}
		{
			BuildBlock b(0, "push_button", "$pushbutton$", "Button");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			blocks[2].push_back(b);
		}
		{
			BuildBlock b(0, "coin_slot", "$coin_slot$", "Coin Slot");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			blocks[2].push_back(b);
		}
		{
			BuildBlock b(0, "pressure_plate", "$pressureplate$", "Pressure Plate");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 0);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			blocks[2].push_back(b);
		}
		{
			BuildBlock b(0, "sensor", "$sensor$", "Motion Sensor");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			blocks[2].push_back(b);
		}

		BuildBlock[] page_3;
		blocks.push_back(page_3);
		{
			BuildBlock b(0, "lamp", "$lamp$", "Lamp");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 0);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 0);
			blocks[2].push_back(b);
		}
		{
			BuildBlock b(0, "Multi_Lamp", "$Multi_Lamp$", "Multi Lamp 2.0");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 0);
			blocks[2].push_back(b);
		}
		{
			BuildBlock b(0, "emitter", "$emitter$", "Emitter");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 0);
			blocks[2].push_back(b);
		}
		{
			BuildBlock b(0, "receiver", "$receiver$", "Receiver");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 0);
			blocks[2].push_back(b);
		}
		{
			BuildBlock b(0, "magazine", "$magazine$", "Magazine");
			AddRequirement(b.reqs, "blob", "mat_stone", "Wood", 0);
			AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 0);
			blocks[2].push_back(b);
		}
		{
			BuildBlock b(0, "bolter", "$bolter$", "Bolter");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 0);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 0);
			blocks[2].push_back(b);
		}
		{
			BuildBlock b(0, "dispenser", "$dispenser$", "Dispenser");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 0);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 0);
			blocks[2].push_back(b);
		}
		{
			BuildBlock b(0, "obstructor", "$obstructor$", "Obstructor");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 0);
			blocks[2].push_back(b);
		}
		{
			BuildBlock b(0, "spiker", "$spiker$", "Spiker");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 0);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 0);
			blocks[2].push_back(b);
		}
		{
			BuildBlock b(0, "flamer", "$flamer$", "Flamer");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 0);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 0);
			blocks[2].push_back(b);
		}
		{
			BuildBlock b(0, "booster", "$booster$", "Bouncer");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 0);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 0);
			blocks[2].push_back(b);
		}
		/*{
			BuildBlock b(0, "conveyor", "$conveyor$", "Conveyor");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 0);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 0);
			blocks[2].push_back(b);
		}
		{
			BuildBlock b(0, "conveyortriangle", "$conveyortriangle$", "Conveyor Triangle");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 0);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 0);
			blocks[2].push_back(b);
		}*/
		{
			BuildBlock b(0, "electricsponge", "$electricsponge$", "Electric Sponge");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 0);
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 0);
			blocks[2].push_back(b);
		}
				{
			BuildBlock b(0, "grave1", "$grave1$", "Grave");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 25);
			blocks[3].push_back(b);
		}
		{
			BuildBlock b(0, "grave2", "$grave2$", "Grave");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 25);
			blocks[3].push_back(b);
		}
		{
			BuildBlock b(0, "grave3", "$grave3$", "Grave");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 25);
			blocks[3].push_back(b);
		}
		{
			BuildBlock b(0, "grave4", "$grave4$", "Grave");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 25);
			blocks[3].push_back(b);
		}
		{
			BuildBlock b(0, "grave5", "$grave5$", "Grave");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 25);
			blocks[3].push_back(b);
		}
		{
			BuildBlock b(0, "casket1", "$casket1$", "Casket");
			AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 50);
			blocks[3].push_back(b);
		}
		{
			BuildBlock b(0, "casket2", "$casket2$", "Casket");
			AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 50);
			blocks[3].push_back(b);
		}
	}
}

ConfigFile@ openBlockBindingsConfig()
{
	ConfigFile cfg = ConfigFile();
	if (!cfg.loadFile("../Cache/BlockBindings.cfg"))
	{
		// write EmoteBinding.cfg to Cache
		cfg.saveFile("BlockBindings.cfg");

	}

	return cfg;
}

u8 read_block(ConfigFile@ cfg, string name, u8 default_value)
{
	u8 read_val = cfg.read_u8(name, default_value);
	return read_val;
}
