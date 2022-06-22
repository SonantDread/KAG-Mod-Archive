
#include "BuildBlock.as"
#include "Requirements.as"
#include "BF_Costs.as";

const string blocks_property = "blocks";
const string inventory_offset = "inventory offset";

void addCommonBuilderBlocks( BuildBlock[]@ blocks )
{
    {   // BF_Workshop
        BuildBlock b( 0, "bf_workshop", "$bf_workshop$", "Workshop" );
        AddRequirement( b.reqs, "blob", "mat_wood", "Wood", COST_WOOD_WORKSHOP );
        b.buildOnGround = true;
        b.size.Set( 16,16 );
        blocks.push_back( b );
    }
	{   // BF_Hall
        BuildBlock b( 0, "bf_hall", "$bf_hall$", "Hall" );
        AddRequirement( b.reqs, "blob", "mat_wood", "Wood", 50 );
        b.buildOnGround = true;
        b.size.Set( 32,16 );
        blocks.push_back( b );
    }
}