// spawn resources

#include "RulesCore.as";
#include "CTF_Structs.as";
#include "fractional_coins.as"

const u32 materials_wait = 20; //seconds between free mats
const u32 materials_wait_warmup = 20; //seconds between free mats

//property
const string SPAWN_ITEMS_TIMER = "CTF SpawnItems:";

string base_name() { return "tent"; }

bool SetMaterials(CBlob@ blob,  const string &in name, const int quantity, bool put_in_inventory = true)
{
    CInventory@ inv = blob.getInventory();
    
    //avoid over-stacking arrows
    if (name == "mat_arrows")
    {
        inv.server_RemoveItems(name, quantity);
    }
    
    CBlob@ mat = server_CreateBlobNoInit(name);
    
    if (mat !is null)
    {
        mat.Tag('custom quantity');
        mat.Init();
        
        mat.server_SetQuantity(quantity);
        
        if (!put_in_inventory || not blob.server_PutInInventory(mat))
        {
            mat.setPosition(blob.getPosition());
        }
    }
    
    return true;
}

bool GiveSpawnResources(CRules@ this, CBlob@ blob, CPlayer@ player, CTFPlayerInfo@ info)
{
    if (this.isWarmup())
    {
        bool is_builder = blob.getName() == "builder";
        SetMaterials(blob, "mat_wood", 450, is_builder);
        SetMaterials(blob, "mat_stone", 150, is_builder);
    }
    else
    {
        if (blob.getName() == "builder") {
            SetMaterials(blob, "mat_wood", 120);
            SetMaterials(blob, "mat_stone", 30);
            
            // SetMaterials(blob, "heart", 1);
        } else {
            // NOTE(hobey): heart first
            // SetMaterials(blob, "heart", 1);
            
            
            SetMaterials(blob, "mat_wood", 120, false);
            SetMaterials(blob, "mat_stone", 30, false);
        }
        // player.server_setCoins(player.getCoins() + 5);
    }
    add_coins_to_player(player, 5);
    
    info.items_collected |= ItemFlag::Builder;
    info.items_collected |= ItemFlag::Knight;
    info.items_collected |= ItemFlag::Archer;
    
    /*
    if (blob.getName() == "builder")
    {
        if (this.isWarmup())
        {
            ret = SetMaterials(blob, "mat_wood", 300) || ret;
            ret = SetMaterials(blob, "mat_stone", 100) || ret;
            
        }
        else
        {
            ret = SetMaterials(blob, "mat_wood", 100) || ret;
            ret = SetMaterials(blob, "mat_stone", 30) || ret;
        }
        
        if (ret)
        {
            info.items_collected |= ItemFlag::Builder;
        }
    }
    else if (blob.getName() == "archer")
    {
        ret = SetMaterials(blob, "mat_arrows", 30) || ret;
        
        if (ret)
        {
            info.items_collected |= ItemFlag::Archer;
        }
    }
    else if (blob.getName() == "knight")
    {
        if (ret)
        {
            info.items_collected |= ItemFlag::Knight;
        }
    }
    */
    
    return true;
}

//when the player is set, give materials if possible
void onSetPlayer(CRules@ this, CBlob@ blob, CPlayer@ player)
{
    if (!getNet().isServer())
        return;
    
    if (blob !is null && player !is null)
    {
        RulesCore@ core;
        this.get("core", @core);
        if (core !is null)
        {
            doGiveSpawnMats(this, player, blob, core);
        }
    }
}

//when player dies, unset archer flag so he can get arrows if he really sucks :)
//give a guy a break :)
void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData)
{
    if (victim !is null)
    {
        RulesCore@ core;
        this.get("core", @core);
        if (core !is null)
        {
            CTFPlayerInfo@ info = cast < CTFPlayerInfo@ > (core.getInfoFromPlayer(victim));
            if (info !is null)
            {
                info.items_collected &= ~ItemFlag::Archer;
            }
        }
    }
}

bool canGetSpawnmats(CRules@ this, CPlayer@ p, RulesCore@ core)
{
    s32 next_items = getCTFTimer(this, p);
    s32 gametime = getGameTime();
    
    CTFPlayerInfo@ info = cast < CTFPlayerInfo@ > (core.getInfoFromPlayer(p));
    
    if (gametime > next_items)		// timer expired
    {
        info.items_collected = 0; //reset available class items
        return true;
    }
    else //trying to get new class items, give a guy a break
    {
        u32 items = info.items_collected;
        u32 flag = 0;
        
        CBlob@ b = p.getBlob();
        string name = b.getName();
        if (name == "builder")
            flag = ItemFlag::Builder;
        else if (name == "knight")
            flag = ItemFlag::Knight;
        else if (name == "archer")
            flag = ItemFlag::Archer;
        
        if (info.items_collected & flag == 0)
        {
            return true;
        }
    }
    
    return false;
    
}

string getCTFTimerPropertyName(CPlayer@ p)
{
    return SPAWN_ITEMS_TIMER + p.getUsername();
}

s32 getCTFTimer(CRules@ this, CPlayer@ p)
{
    string property = getCTFTimerPropertyName(p);
    if (this.exists(property))
        return this.get_s32(property);
    else
        return 0;
}

void SetCTFTimer(CRules@ this, CPlayer@ p, s32 time)
{
    string property = getCTFTimerPropertyName(p);
    this.set_s32(property, time);
    this.SyncToPlayer(property, p);
}

//takes into account and sets the limiting timer
//prevents dying over and over, and allows getting more mats throughout the game
void doGiveSpawnMats(CRules@ this, CPlayer@ p, CBlob@ b, RulesCore@ core)
{
    if (canGetSpawnmats(this, p, core))
    {
        s32 gametime = getGameTime();
        
        // print("resupply: "+b.getTickSinceCreated()+", "+b.getNetworkID()+","+p.getUsername()+","+getGameTime());
        if (gametime < 30) return; // NOTE(hobey): because auto balance
        
        CTFPlayerInfo@ info = cast < CTFPlayerInfo@ > (core.getInfoFromPlayer(p));
        
        bool gotmats = GiveSpawnResources(this, b, p, info);
        if (gotmats)
        {
            SetCTFTimer(this, p, gametime + (this.isWarmup() ? materials_wait_warmup : materials_wait)*getTicksASecond());
        }
    }
}

// normal hooks

void Reset(CRules@ this)
{
    //restart everyone's timers
    for (uint i = 0; i < getPlayersCount(); ++i)
        SetCTFTimer(this, getPlayer(i), 0);
}

void onRestart(CRules@ this)
{
    Reset(this);
}

void onInit(CRules@ this)
{
    Reset(this);
}

void onTick(CRules@ this)
{
    if (!getNet().isServer())
        return;
    
    s32 gametime = getGameTime();
    
    if ((gametime % 19) != 5)
        return;
    
    
    RulesCore@ core;
    this.get("core", @core);
    if (core !is null)
    {
        if (this.isWarmup()) {
            // NOTE(hobey): during building time, give everyone resupplies no matter where they are
            for (int i = 0; i < getPlayerCount(); i++) {
                CPlayer@ player = getPlayer(i);
                CBlob@ blob = player.getBlob();
                if (blob !is null) {
                    doGiveSpawnMats(this, player, blob, core);
                }
            }
        } else {
            CBlob@[] spots;
            
            // TODO(hobey): at this point we maybe should iterate through all player blobs instead of the shops/respawnpoints
            
            // NOTE(hobey): respawn points
            getBlobsByName(base_name(), @spots);
            getBlobsByName("ballista", @spots);
            getBlobsByName("warboat", @spots);
            
            // NOTE(hobey): shops
            getBlobsByName("buildershop", @spots);
            getBlobsByName("quarters", @spots);
            getBlobsByName("knightshop", @spots);
            getBlobsByName("archershop", @spots);
            
            getBlobsByName("boatshop", @spots);
            getBlobsByName("vehicleshop", @spots);
            getBlobsByName("storage", @spots);
            getBlobsByName("tunnel", @spots);
            getBlobsByName("quarry", @spots);
            
            for (uint step = 0; step < spots.length; ++step)
            {
                CBlob@ spot = spots[step];
                CBlob@[] overlapping;
                if (spot !is null && spot.getOverlapping(overlapping))
                {
                    string name = spot.getName();
                    bool isShop = (name.find("shop") != -1);
                    for (uint o_step = 0; o_step < overlapping.length; ++o_step)
                    {
                        CBlob@ overlapped = overlapping[o_step];
                        if (overlapped !is null && overlapped.hasTag("player"))
                        {
                            // if (!isShop || name.find(overlapped.getName()) != -1)
                            // {
                            CPlayer@ p = overlapped.getPlayer();
                            if (p !is null)
                            {
                                doGiveSpawnMats(this, p, overlapped, core);
                            }
                            // }
                        }
                    }
                }
                
            }
        }
    }
}

// render gui for the player
void onRender(CRules@ this)
{
    if (g_videorecording)
        return;
    
    CPlayer@ p = getLocalPlayer();
    if (p is null || !p.isMyPlayer()) { return; }
    
    string propname = getCTFTimerPropertyName(p);
    CBlob@ b = p.getBlob();
    if (b !is null && this.exists(propname))
    {
        s32 next_items = this.get_s32(propname);
        // if (next_items > getGameTime())
        {
            
            GUI::SetFont("menu");
            
            SColor color = SColor(200, 135, 185, 45);
            string text = getTranslatedString("Go to a shop or a respawn point\n to get 120 wood and 30 stone");
            if (next_items > getGameTime() - 19) {
                color = SColor(120, 255, 55, 55);
                
                u32 secs = ((next_items - 1 - getGameTime()) / getTicksASecond()) + 1;
                string units = ((secs != 1) ? " seconds" : " second");
                
                // string action = (b.getName() == "builder" ? "Go Build" : "Go Fight");
                // if (this.isWarmup()) { action = "Prepare for Battle"; }
                text = getTranslatedString("Next resupply in {SEC}{TIMESUFFIX}").replace("{SEC}", "" + secs)
                    .replace("{TIMESUFFIX}", getTranslatedString(units));
                // .replace("{ACTION}", getTranslatedString(action));
                
            }
            // Vec2f pos = Vec2f(getScreenWidth() / 2, getScreenHeight() / 3 - 70.0f + Maths::Sin(getGameTime() / 3.0f) * 5.0f);
            // Vec2f pos = Vec2f(getScreenWidth() / 2, getScreenHeight() / 3 - 70.0f + Maths::Sin(getGameTime() / 8.0f) * 2.0f);
            
            if (!this.isWarmup() || (next_items > getGameTime() - 19)) {
                
                Vec2f pos = Vec2f(getScreenWidth() / 2, getScreenHeight() / 3 - 70.0f);
                GUI::DrawTextCentered(text, pos, color);
            }
        }
    }
}
