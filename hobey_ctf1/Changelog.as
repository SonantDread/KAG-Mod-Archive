







// TODO(hobey): add MapVotesCommon minimap code to minimap pull request










void onMainMenuCreated(CRules@ this, CContextMenu@ menu) {
    CPlayer@ me = getLocalPlayer();
    if (me is null) return;
    CRules@ rules = getRules();
    
    // CContextMenu@ leadermenu_button = Menu::addContextMenu(menu, "Stats/Leaderboard");
    // Menu::addSeparator(votemenu); //before the back button
    
    // Menu::addContextItem(menu, "Stats/Leaderboard", "export.as", "void open_stats_menu()");
    
    CBitStream params;
    Menu::addContextItemWithParams(menu, "Changelog of the hobey_ctf mod", "Changelog.as", "show_changelog", params);
}

bool changelog_shown;
float changelog_scroll;

void show_changelog (CBitStream@ menu_params) {
    Menu::CloseAllMenus();
    changelog_shown = true;
    changelog_scroll = 0.f;
}

// TODO(hobey): copy paste from indicators.as
string get_font(string file_name, s32 size)
{
    string result = file_name+"_"+size;
    if (!GUI::isFontLoaded(result)) {
        string full_file_name = CFileMatcher(file_name+".ttf").getFirst();
        // TODO(hobey): apparently you cannot load multiple different sizes of a font from the same font file in this api?
        GUI::LoadFont(result, full_file_name, size, true);
    }
    return result;
}

void onRender(CRules@ rules)
{
    if (!changelog_shown) return;
    
    CControls@ controls = getControls();
    if ((controls.isKeyPressed(KEY_ESCAPE)) ||
        (controls.isKeyPressed(key_action1)) ||
        (controls.isKeyPressed(key_action2))) {
        // if (controls.mousePressed2) {
        changelog_shown = false;
        return;
    }
    
    float amount = 300.f * getRenderDeltaTime();
    if (controls.isKeyPressed(KEY_KEY_W)) {
        changelog_scroll += amount;
    }
    if (controls.mouseScrollUp) {
        changelog_scroll += amount * 10.f;
    }
    if (controls.mouseScrollDown) {
        changelog_scroll -= amount * 10.f;
    }
    if (controls.isKeyPressed(KEY_KEY_S)) {
        changelog_scroll -= amount;
    }
    
    // if (getGameTime() == controls.getLastKeyPressTime()) {
    
    float screen_size_x = getDriver().getScreenWidth();
    float screen_size_y = getDriver().getScreenHeight();
    float resolution_scale = screen_size_y / 720.f; // NOTE(hobey): scaling relative to 1280x720
    // string font_name              = get_font("GenShinGothic-P-Medium", s32(24.f * resolution_scale));
    string font_name = get_font("AveriaSerif-Regular", s32(11.f * resolution_scale));
    GUI::SetFont(font_name);
    
    // GUI::DrawTextCentered("Loading...", Vec2f(screen_size_x*.5f,screen_size_y*.5f), SColor(255, 230, 30, 30));
    
    Vec2f pos = Vec2f(30, 30 + changelog_scroll) * resolution_scale;
    
    
    // TODO(hobey): map vote buttons are broken
    // TODO(hobey): start of map resupplies fall on the ground sometimes
    // TODO(hobey): nextmap during building time -> building time modifiers inactive on clients
    
    
    
    // TODO(hobey): drilling dirt nerfs, waterbucket nerfs
    // TODO(hobey): drill color
    
    // TODO(hobey): delete darkness; fighting in darkness is not fun
    // TODO(hobey): add day/night cycle
    
    // TODO(hobey): grass/flower/bush seeds (in buildershop?)
    
    // TODO(hobey): knight/archer auto pickup 1 sponge
    
    // TODO(hobey): visualization for getting coins
    // TODO(hobey): post-death stat HUD showing gained coins/fed coins/damage dealt/damage taken/mats created
    
    string [] texts = {
        "During building time:\n"
            "    1.3x Builder Movement speed\n"
            "    1.3x Builder Jump power\n"
            "    No falldamage and no fallstun\n"
            "    Using tunnels doesn't stun you\n"
            "    \n"
            "    Resupply happens everywhere (not just at the tent or at a buildershop) and on all classes\n"
            "    Resupplies give 450 wood + 150 stone every 20 seconds\n"
            "    Building time lasts 150 seconds (was 180 seconds)\n"
            "    You always respawn as builder during building time\n"
            "    \n"
            "    2x Build speed\n"
            "    2x Build range\n"
            "    2x Pickaxe speed\n"
            "    2x Pickaxe range\n"
            "    \n"
            "    2x Drill range\n"
            "    2x Drill speed\n"
            "    2x Drill heat cooling rate\n"
            "    Drills get 100% stone from stone ore (was 3/4 or 4/6)\n"
            "    2x Drill sprite size\n"
            "    \n"
            "    1.8x Knight Movement speed\n"
            "    1.8x Knight Jump power\n"
            "    Stronger knight slash boost (4x slash force, 3x max velocity from slash boost)\n"
            "    2.4x Archer Movement speed\n"
            "    2.4x Archer Jump power\n"
            "    \n"
            "    Trees fall faster\n"
            "    Spikes deal no damage"
            // "    \n"
        // "    \n"
        ,
        "After building time:\n"
            "    Normal movement speed, normal drills etc.\n"
            "    All classes resupply for 120 wood + 30 stone at a any shop or respawn point\n"
            "    Players that join the server spawn as knight (instead of 50/50 knight/archer)"
            // "    \n"
        // "    \n"
        ,
        "Markers:\n"
            "    Hold R ('mark' keybind in settings) and press number keys to ping a location to your teammates\n"
            "    Backspace ('misc' keybind in settings) is a second modifier key for more markers (also try 'mark' + 'misc' + numbers for a third set of markers)\n"
            "\n"
            "    You can hide/mute other players' markers with these chatcommands (mute also applies to chat sounds):\n"
            "    !hide ThatGuy\n"
            "    !hideall\n"
            "    !mute ThatGuy\n"
            "    !muteall\n"
            "    and you can unhide/unmute with !unhide, !unhideall, !unmute, !unmuteall\n"
            "\n"
            "    The old functionality or the 'mark' keybind is removed (the small yellow or grey notch above players that you could toggle with R)"
            ,
        "Coins:\n"
        
            "    You get 5 coins for resupplying (was 0)\n"
            "    You get 6 coins per heart of damage dealt (was 5)\n"
            "    You get 12 coins for kills (was 10)\n"
            "    You no longer lose 50 coins for teamkills"
            "    You get 12 coins for throwing food at teammates (was 10)\n"
            "    You get 7 coins for throwing a heart at teammates (was 5)\n"
            "\n"
            "    You get 3 coins per stone block built (was 4)\n"
            "    You get 5 coins per stone door built (was 4)\n"
            "    You get 0 coins per trapblock (was 4)\n"
            "    You get 0.4 coins per stone backwall built (was 0)\n"
            "    Making a tunnel/storage/quarry (or pressing the backwalls button in a shop) counts as building 15 stone backwalls and gives 6 coins\n"
            "\n"
            "    You get 0.75 coins per ladder built (was 0)\n"
            "    You get 1.25 coins per wooden door built (was 1)\n"
            "\n"
            "    During building time, you only gain 1/5 the coins you would normally (was 1/3 of the coins)\n"
            "\n"
            "    Reduced coin loss on death to 15% (was 20%)\n"
            "    Changed the dropped coins on death to 100% of the lost coins (was random 0%-100% of lost coins)"
            ,
        "Changed mapcycle:\n"
            "    Removed Ferrezinhre_Moonfall\n"
            "    Removed PUNK123_ChasmSpasm\n"
            "    Removed PUNK123_Rally\n"
            "    Removed Skinney_Bluff\n"
            "    Removed Redshadow6_twinlakes\n"
            "    Removed Potatobird_CubeCanyon\n"
            "\n"
            "    Replaced Fellere_FourRivers with bunnie_RiversFour\n"
            "\n"
            "    Modified Snatchmark (NSnatchmark)\n"
            "    Modified 8x_Grounds (NGrounds)\n"
            "    Modified mcrifel_fish (NFish)\n"
            "\n"
            "    Added NCatMap1\n"
            "    Added NFlatPleasure\n"
            "    Added NSasin\n"
            "    Added NRelantris\n"
            "    Added NCourouz\n"
            "    Added NBiurzaRem"
            ,
        "Other changes:\n"
            "    Pressing the heal key can now heal you while you're stunned\n"
            "    Gold ore now drops gold when damaged by bombs\n"
            "    Gold and saplings that fall into the void reappear in the sky (or at the ceiling of the map)\n"
            "    \n"
            "    Changed fall damage and fall stun values\n"
            "    Trampolines can now be pointed in any direction\n"
            "    One pile of stone now holds 150 stone (was 250 stone); one inventory slot now holds 300 stone (was 500)\n"
            "    \n"
            "    Corpses are never the first pickup target if there is a non-corpse item in pickup-range\n"
            "    You can now place stone backwalls into a wooden door without opening the door\n"
            "    Doors become stable if they have a solid block diagonally adjacent to them\n"
            "    Added a 10th option to the \"Construct shop\" menu that lets you fill up the shop with stone backwalls for 30 stone\n"
            "    Removed the regular arrow item\n"
            "    \n"
            "    Modified colors for blocks on minimap (you can now tell dirt, stone ore, rich stone ore and bedrock apart)\n"
            "    Added minimap icons for trees, tunnel and ballista"
            "    More emotes (see emote bindings menu)\n"
            "    \n"
            "    The game checks if it needs to give resupplies every 19 ticks (was 31 ticks)\n"
            "    Tweaked the red resupply indicator in the middle of the screen and added a message explaining resupplying when the timer runs out\n"
            "    Trees drop their sapling immediately when they start falling (instead of when they hit the ground or a wall)\n"
            "    Hearts now decay after 60 seconds (was 40 seconds) and don't decay when held\n"
            "    Crates now autopick hearts\n"
            "    Added sponge to knightshop and archershop\n"
            "    \n"
            "    Map vote now has 4 map options and no \"random map\" option\n"
            "    Map vote now lasts 17 seconds (was 22 seconds)\n" // TODO(hobey): voteLockDuration is now 2 seconds (was 3)
        "    Map vote screen darkening reduced (to 20% opacity, was 80% opacity)\n"
            "    \n"
            "    The match starts even if there is only 1 player on the server\n"
            "    \n"
            "    Added !inv to sv_test commands which gives you a million health"
        
            // NOTE(hobey): builder autopickup fix
        // NOTE(hobey): selected ladder preventing pickup fix
    };
    
    // string full_text = "";
    for (int text_index = 0; text_index < texts.length; text_index++) {
        string text = texts[text_index];
        
        // if (text_index != 0) full_text += "\n\n";
        // full_text += text;
        
        Vec2f text_dimensions; GUI::GetTextDimensions(text, text_dimensions);
        text_dimensions.y *= .75f;
        float margin_size = 8.f * resolution_scale;
        
        // Vec2f middle = Vec2f(screen_size_x*.5f,screen_size_y*.5f);
        Vec2f text_top_left     = pos;
        Vec2f pane_top_left     = text_top_left - Vec2f(margin_size, margin_size);
        Vec2f pane_bottom_right = text_top_left + Vec2f(margin_size, margin_size) + text_dimensions;
        pos.y += text_dimensions.y + 20.f * resolution_scale;
        
        // bool selected = (getGameTime()/30)%2 == 0;
        // SColor text_color = SColor(255, 170, 170, 20);
        // SColor text_color = SColor(255, 230, 230, 30);
        // SColor text_color = SColor(255, 20, 20, 30);
        // SColor text_color = SColor(255, 230, 230, 240);
        SColor text_color = SColor(255, 240, 240, 250);
        
        // GUI::DrawPane(pane_top_left, pane_bottom_right);
        GUI::DrawSunkenPane(pane_top_left, pane_bottom_right);
        // GUI::DrawTextCentered("hello", Vec2f(screen_size_x*.5f,screen_size_y*.5f), SColor(128, 230, 230, 30));
        GUI::DrawText(text, text_top_left, text_color);
        
        // string phrase = "hello";
        // SColor color = SColor(   255,   255,   255,   0);
        // Vec2f text_pos = Vec2f(screen_size_x*.5f,screen_size_y*.5f);
        //
        // GUI::DrawTextCentered(phrase, text_pos, color);
    }
    // CopyToClipboard(full_text);
}
