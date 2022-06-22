// Genreic building

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"
#include "GenericButtonCommon.as"
#include "fractional_coins.as"

//are builders the only ones that can finish construction?
const bool builder_only = false;

void onInit(CBlob@ this)
{
    AddIconToken("$stonequarry$", "../Mods/Entities/Industry/CTFShops/Quarry/Quarry.png", Vec2f(40, 24), 4);
    AddIconToken("$put_stone_backwalls$", "Sprites/world.png", Vec2f(8, 8), 64);
    this.set_TileType("background tile", CMap::tile_wood_back);
    //this.getSprite().getConsts().accurateLighting = true;
    
    this.getSprite().SetZ(-50); //background
    this.getShape().getConsts().mapCollisions = false;
    
    //INIT COSTS
    InitCosts();
    
    // SHOP
    this.set_Vec2f("shop offset", Vec2f(0, 0));
    this.set_Vec2f("shop menu size", Vec2f(4, 5));
    this.set_string("shop description", "Construct");
    this.set_u8("shop icon", 12);
    this.Tag(SHOP_AUTOCLOSE);
    
    {
        ShopItem@ s = addShopItem(this, "Builder Shop", "$buildershop$", "buildershop", Descriptions::buildershop);
        AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::buildershop_wood);
    }
    {
        ShopItem@ s = addShopItem(this, "Quarters", "$quarters$", "quarters", Descriptions::quarters);
        AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::quarters_wood);
    }
    {
        ShopItem@ s = addShopItem(this, "Knight Shop", "$knightshop$", "knightshop", Descriptions::knightshop);
        AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::knightshop_wood);
    }
    {
        ShopItem@ s = addShopItem(this, "Archer Shop", "$archershop$", "archershop", Descriptions::archershop);
        AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::archershop_wood);
    }
    {
        ShopItem@ s = addShopItem(this, "Boat Shop", "$boatshop$", "boatshop", Descriptions::boatshop);
        AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::boatshop_wood);
        AddRequirement(s.requirements, "blob", "mat_gold", "Gold", CTFCosts::boatshop_gold);
    }
    {
        ShopItem@ s = addShopItem(this, "Vehicle Shop", "$vehicleshop$", "vehicleshop", Descriptions::vehicleshop);
        AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::vehicleshop_wood);
        AddRequirement(s.requirements, "blob", "mat_gold", "Gold", CTFCosts::vehicleshop_gold);
    }
    {
        ShopItem@ s = addShopItem(this, "Storage Cache", "$storage$", "storage", Descriptions::storagecache);
        AddRequirement(s.requirements, "blob", "mat_stone", "Stone", CTFCosts::storage_stone);
        AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::storage_wood);
    }
    {
        ShopItem@ s = addShopItem(this, "Transport Tunnel", "$tunnel$", "tunnel", Descriptions::tunnel);
        AddRequirement(s.requirements, "blob", "mat_stone", "Stone", CTFCosts::tunnel_stone);
        AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::tunnel_wood);
        AddRequirement(s.requirements, "blob", "mat_gold", "Gold", CTFCosts::tunnel_gold);
    }
    
    {
        ShopItem@ s = addShopItem(this, "Stone Quarry", "$stonequarry$", "quarry", Descriptions::quarry);
        AddRequirement(s.requirements, "blob", "mat_stone", "Stone", CTFCosts::quarry_stone);
        AddRequirement(s.requirements, "blob", "mat_gold", "Gold", CTFCosts::quarry_gold);
        AddRequirement(s.requirements, "no more", "quarry", "Stone Quarry", CTFCosts::quarry_count);
    }
    
    {
        ShopItem@ s = addShopItem(this, "Put stone backwalls", "$put_stone_backwalls$", "building", "Put stone backwalls in the 5x3 area of the shop.");
        AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 30); //28
    }
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
    if (!canSeeButtons(this, caller)) return;
    
    if (this.isOverlapping(caller))
        this.set_bool("shop available", !builder_only || caller.getName() == "builder");
    else
        this.set_bool("shop available", false);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
    bool isServer = getNet().isServer();
    if (cmd == this.getCommandID("shop made item"))
    {
        CBlob@ caller = getBlobByNetworkID(params.read_netid());
        CBlob@ item = getBlobByNetworkID(params.read_netid());
        
        if (item !is null && caller !is null)
        {
            this.Tag("shop disabled"); //no double-builds
            
            Vec2f pos = this.getPosition();
            this.getSprite().PlaySound("/Construct.ogg");
            this.getSprite().getVars().gibbed = true;
            this.server_Die();
            caller.ClearMenus();
            
            if ((item.getName() == "quarry") ||
                (item.getName() == "storage") ||
                (item.getName() == "tunnel")) {
                CPlayer@ p = caller.getPlayer();
                if (p !is null) {
                    add_coins_to_player(p, 6); // NOTE(hobey): 15 stonebackwalls -> 15*0.4 coins
                }
            }
            
            if (item.getName() == "building") {
                CMap@ map = getMap();
                
                map.server_SetTile(pos + Vec2f( 2, 1) * 8, CMap::tile_castle_back);
                map.server_SetTile(pos + Vec2f( 1, 1) * 8, CMap::tile_castle_back);
                map.server_SetTile(pos + Vec2f( 0, 1) * 8, CMap::tile_castle_back);
                map.server_SetTile(pos + Vec2f(-1, 1) * 8, CMap::tile_castle_back);
                map.server_SetTile(pos + Vec2f(-2, 1) * 8, CMap::tile_castle_back);
                
                map.server_SetTile(pos + Vec2f( 2, 0) * 8, CMap::tile_castle_back);
                map.server_SetTile(pos + Vec2f( 1, 0) * 8, CMap::tile_castle_back);
                map.server_SetTile(pos + Vec2f( 0, 0) * 8, CMap::tile_castle_back);
                map.server_SetTile(pos + Vec2f(-1, 0) * 8, CMap::tile_castle_back);
                map.server_SetTile(pos + Vec2f(-2, 0) * 8, CMap::tile_castle_back);
                
                map.server_SetTile(pos + Vec2f( 2,-1) * 8, CMap::tile_castle_back);
                map.server_SetTile(pos + Vec2f( 1,-1) * 8, CMap::tile_castle_back);
                map.server_SetTile(pos + Vec2f( 0,-1) * 8, CMap::tile_castle_back);
                map.server_SetTile(pos + Vec2f(-1,-1) * 8, CMap::tile_castle_back);
                map.server_SetTile(pos + Vec2f(-2,-1) * 8, CMap::tile_castle_back);
                
                CPlayer@ p = caller.getPlayer();
                if (p !is null) {
                    add_coins_to_player(p, 6); // NOTE(hobey): 15 stonebackwalls -> 15*0.4 coins
                }
                
                CBitStream newParams;
                newParams.write_netid(caller.getNetworkID());
                item.SendCommand(item.getCommandID("shop menu"), newParams);
            }
            
            // open factory upgrade menu immediately
            if (item.getName() == "factory")
            {
                CBitStream factoryParams;
                factoryParams.write_netid(caller.getNetworkID());
                item.SendCommand(item.getCommandID("upgrade factory menu"), factoryParams);
            }
        }
    }
}
