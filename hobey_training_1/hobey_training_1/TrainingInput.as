
#include "RulesCore.as";

namespace Training {
    
    // NOTE(hobey): :TrainingMode
    enum Training_Mode {
        uninitiialized = 0,
        
        crouch_shieldslide,
        crouch_jab_shieldslide,
        overhead_slash_shieldslide,
        
        crouching_into_someones_shield,
        crouching_into_someones_shield_from_above,
        
        jab_direction_inside_shield,
        slash_direction_inside_shield,
        
        turnaround_slash_while_crouching_into_enemy_shield,
        
        instajab,
        instaslash_slashspammer,
        instaslash_fast_slashspammer,
        
        easy_slash_stomp,
        slash_stomp,
        hard_slash_stomp,
        
        shield_bash_and_jab,
        shield_bash_and_jab_against_wall,
        shield_bash_and_slash_against_wall,
        
        late_slashing_and_jabbing,
        
        foo,
    };
};

class Tick_Input {
    bool action1;
    bool action2;
    bool action3;
    
    bool left;
    bool right;
    bool up;
    bool down;
    
    bool facing_left;
    // Vec2f aim_angle
    Vec2f aim_pos;
}

class Recording {
    int first_tick;
    u16 blob_id;
    string s;
}

void onInit (CBlob@ blob) {
}

bool is_a_frog (string username) { return username.substr(0, 4) == "Frog"; } // NOTE(hobey): handles Frog~2 etc.
bool is_a_tiger (string username) { return username.substr(0, 5) == "Tiger"; }

void onTick (CBlob@ blob) {
    if (blob.getTickSinceCreated() == 1) {
        CPlayer@ p = blob.getPlayer();
        if (p !is null) {
            if (isServer()) {
                if (p.isBot()) {
                    if (is_a_frog(p.getUsername())) p.server_setHeadNum(842);
                    if (is_a_tiger(p.getUsername())) p.server_setHeadNum(839);
                }
            }
            
            blob.setSkinNum(p.getSkin());
            blob.setHeadNum(p.getHead());
            blob.setSexNum(p.getSex());
        }
    }
    
    CPlayer@ p = getLocalPlayer();
    if (blob.getPlayer() !is null && blob.getPlayer() is p) {
        Tick_Input input;
        
        input.action1 = blob.isKeyPressed(key_action1);
        input.action2 = blob.isKeyPressed(key_action2);
        input.action3 = blob.isKeyPressed(key_action3);
        
        input.left    = blob.isKeyPressed(key_left);
        input.right   = blob.isKeyPressed(key_right);
        input.up      = blob.isKeyPressed(key_up);
        input.down    = blob.isKeyPressed(key_down);
        
        input.facing_left  = blob.isFacingLeft();
        input.aim_pos      = blob.getAimPos();
        
        getRules().set("training_input", @input);
        int tick = blob.getTickSinceCreated();
        // print("if (tick == "+tick+") {}");
        u16 id = blob.getNetworkID();
        
        
        if (p !is null) {
            if (p.getControls().isKeyJustPressed(KEY_KEY_G)) {
                Recording r;
                r.first_tick = tick;
                r.blob_id = id;
                r.s = "";
                
                r.s += "if (tick == 0) { blob.setPosition(Vec2f("+blob.getPosition().x+","+blob.getPosition().y+")); blob.setVelocity(Vec2f_zero); input.aim_pos = blob.getPosition(); }\n";
                
                getRules().set("recording", @r);
                
                if (p.getControls().isKeyPressed(KEY_LSHIFT)) {
                    CPlayer@ bot = AddBot("Frog");
                }
                // CPlayer@ bot2 = AddBot("Tiger");
            }
            if (p.getControls().isKeyJustPressed(KEY_KEY_H)) {
                Recording@ r; getRules().get("recording", @r);
                
                if ((r !is null) && (id == r.blob_id)) {
                    r.s += "if (tick >= "+int(tick-r.first_tick)+") { if (isServer() && bot !is null) KickPlayer(bot); }\n";
                    
                    // print(r.s);
                    CopyToClipboard(r.s);
                    getRules().set("recording", null);
                }
            }
            if (p.getControls().isKeyJustPressed(KEY_KEY_R)) {
                //AddBot("Guy", 0, 0);
                CPlayer@ bot = AddBot("Frog");
                if (!p.getControls().isKeyPressed(KEY_LSHIFT)) {
                    CPlayer@ bot2 = AddBot("Tiger");
                }
                // bot.client_ChangeTeam(0);
            }
        }
        
        // getPlayer(1).client_ChangeTeam(0);
        // while (getPlayerCount() > 1) getNet().DisconnectPlayer(getPlayer(1));
        {
            Recording@ r; getRules().get("recording", @r);
            if ((r !is null) && (id == r.blob_id)) {
                Vec2f aim_pos_relative = input.aim_pos - blob.getPosition();
                
                r.s += "if (tick == "+int(tick-r.first_tick)+") { ";
                r.s += "input.aim_pos += Vec2f("+aim_pos_relative.x+","+aim_pos_relative.y+");";
                if (input.action1) r.s += "input.action1 = true; ";
                if (input.action2) r.s += "input.action2 = true; ";
                if (input.action3) r.s += "input.action3 = true; ";
                if (input.left)    r.s += "input.left = true; ";
                if (input.right)   r.s += "input.right = true; ";
                if (input.up)      r.s += "input.up = true; ";
                if (input.down)    r.s += "input.down = true; ";
                if (input.facing_left) r.s += "input.facing_left = true; ";
                r.s += "}\n";
            }
        }
        
        
    } else if (!blob.hasTag("dead")) {
        
    }
}

void onRender (CRules@ rules) {
    Tick_Input@ input; rules.get("shown_input", @input);
    if (input is null) return;
    
    // if (input.action1) GUI::DrawIconByName("$LMB$", Vec2f(100, 100), 1.f);
    
    Vec2f pos = Vec2f(800, 350);
    u8 alpha_off =  80;
    u8 alpha_on  = 255;
    
    GUI::DrawIcon("GUI/Keys.png", 0, Vec2f(16, 16), pos + Vec2f(  0,   0), 1.f, SColor(input.left    ?alpha_on:alpha_off,255,255,255));
    GUI::DrawIcon("GUI/Keys.png", 2, Vec2f(16, 16), pos + Vec2f( 60,   0), 1.f, SColor(input.right   ?alpha_on:alpha_off,255,255,255));
    GUI::DrawIcon("GUI/Keys.png", 6, Vec2f(16, 16), pos + Vec2f( 30, -30), 1.f, SColor(input.up      ?alpha_on:alpha_off,255,255,255));
    GUI::DrawIcon("GUI/Keys.png", 1, Vec2f(16, 16), pos + Vec2f( 30,   0), 1.f, SColor(input.down    ?alpha_on:alpha_off,255,255,255));
    
    GUI::DrawIcon("GUI/Keys.png", 8, Vec2f(24, 16), pos + Vec2f(  0,  30), 1.f, SColor(input.action3 ?alpha_on:alpha_off,255,255,255));
    
    GUI::DrawIcon("GUI/Keys.png", 8, Vec2f(16, 16), pos + Vec2f(120,   0), 1.f, SColor(input.action1 ?alpha_on:alpha_off,255,255,255));
    GUI::DrawIcon("GUI/Keys.png", 9, Vec2f(16, 16), pos + Vec2f(150,   0), 1.f, SColor(input.action2 ?alpha_on:alpha_off,255,255,255));
    
}
void onTick (CRules@ rules) {
    rules.set("shown_input", null);
    
    Vec2f respawnPos;
    
    {
        // NOTE(hobey): figure out respawn pos
        
        CMap@ map = getMap();
        Vec2f[] respawnPositions;
        if (!map.getMarkers("blue main spawn", respawnPositions))
        {
            warn("Blue spawn marker not found on map");
            respawnPos = Vec2f(150.0f, map.getLandYAtX(150.0f / map.tilesize) * map.tilesize - 32.0f);
            respawnPos.y -= 16.0f;
        }
        else
        {
            // for (uint i = 0; i < respawnPositions.length; i++)
            int i = 0;
            {
                respawnPos = respawnPositions[i];
                respawnPos.y -= 16.0f;
            }
        }
    }
    
    for (int i = 0; i < getPlayerCount(); i += 1) {
        CPlayer@ p = getPlayer(i);
        if (p !is null && (p.getBlob() is null || p.getBlob().hasTag("dead"))) {
            CBlob @newBlob = server_CreateBlob("knight", 0, respawnPos);
            newBlob.server_SetPlayer(p);
            p.server_setTeamNum(0);
        }
    }
    
}

// Knight brain
void onInit(CBrain@ brain) {
}

void onTick(CBrain@ brain) {
    // if (!isServer()) return;
    
    CBlob@ blob = brain.getBlob();
    CPlayer@ p = getLocalPlayer();
    CPlayer@ bot = blob.getPlayer();
    if (!bot.isBot()) return;
    
    // if (bot !is null && bot is p) {
    // } else if (!blob.hasTag("dead")) {
    // blob.setKeyPressed(key_right, true);
    // blob.setKeyPressed(key_up, true);
    // }
    
    // getCamera().setTarget(blob);
    
    // Tick_Input@ input; getRules().get("training_input", @input);
    Tick_Input input;
    
    input.action1 = false;
    input.action2 = false;
    input.action3 = false;
    input.left  = false;
    input.right = false;
    input.up    = false;
    input.down  = false;
    input.facing_left  = false;
    input.aim_pos = blob.getPosition();
    
    // if (isServer()) if (ticks > 60) blob.server_Die();
    
    // blob.server_Die();
    /*
    if (bot is null) {
    CPlayer@ other_bot = getPlayer(1);
    if (other_bot !is null) {
    blob.server_setTeamNum(0);
    bool setPlayer_success = blob.server_SetPlayer(other_bot);
    }
    }
    */
    
    int tick = blob.getTickSinceCreated();
    /*
    if (tick == 0) {
    if (bot !is null) {
    RulesCore@ core;
    getRules().get("core", @core);
    if (core !is null) {
    core.ChangePlayerTeam(bot, 3);
    }
    }
    }
    */
    
    int selected_training = getRules().get_s32("selected_training");
    
    bool frog = is_a_frog(bot.getUsername());
    bool tiger = is_a_tiger(bot.getUsername());
    if (tick == 0) {
        if (bot !is null) {
            if (frog) bot.server_setTeamNum(2);
            if (tiger) bot.server_setTeamNum(4);
            blob.server_setTeamNum(bot.getTeamNum());
        }
    }
    
    // NOTE(hobey): :TrainingMode
    if (false) { // NOTE(hobey): slash wall climb
        if (frog) {
            if (tick == 0) {input.aim_pos.x += -0.666855; input.aim_pos.y += -79.6674; input.facing_left = true; }
            if (tick == 1) {input.aim_pos.x += -0.666855; input.aim_pos.y += -79.6674; input.facing_left = true; }
            if (tick == 2) {input.aim_pos.x += -0.666855; input.aim_pos.y += -79.6674; input.facing_left = true; }
            if (tick == 3) {input.aim_pos.x += -0.666855; input.aim_pos.y += -79.6674; input.facing_left = true; }
            if (tick == 4) {input.aim_pos.x += -0.666855; input.aim_pos.y += -79.6674; input.action1 = true; input.facing_left = true; }
            if (tick == 5) {input.aim_pos.x += -0.666855; input.aim_pos.y += -79.6674; input.action1 = true; input.facing_left = true; }
            if (tick == 6) {input.aim_pos.x += -0.666855; input.aim_pos.y += -79.6674; input.action1 = true; input.facing_left = true; }
            if (tick == 7) {input.aim_pos.x += -0.666855; input.aim_pos.y += -79.6674; input.action1 = true; input.facing_left = true; }
            if (tick == 8) {input.aim_pos.x += -0.666855; input.aim_pos.y += -79.6674; input.action1 = true; input.facing_left = true; }
            if (tick == 9) {input.aim_pos.x += -0.666855; input.aim_pos.y += -79.6674; input.action1 = true; input.facing_left = true; }
            if (tick == 10) {input.aim_pos.x += -0.666855; input.aim_pos.y += -79.6674; input.action1 = true; input.facing_left = true; }
            if (tick == 11) {input.aim_pos.x += -0.666855; input.aim_pos.y += -79.6674; input.action1 = true; input.facing_left = true; }
            if (tick == 12) {input.aim_pos.x += -0.666855; input.aim_pos.y += -79.6674; input.action1 = true; input.facing_left = true; }
            if (tick == 13) {input.aim_pos.x += -0.666855; input.aim_pos.y += -79.6674; input.action1 = true; input.facing_left = true; }
            if (tick == 14) {input.aim_pos.x += -0.666855; input.aim_pos.y += -79.6674; input.action1 = true; input.facing_left = true; }
            if (tick == 15) {input.aim_pos.x += -0.666855; input.aim_pos.y += -79.6674; input.action1 = true; input.facing_left = true; }
            if (tick == 16) {input.aim_pos.x += -0.666855; input.aim_pos.y += -79.6674; input.action1 = true; input.facing_left = true; }
            if (tick == 17) {input.aim_pos.x += -0.666855; input.aim_pos.y += -79.6674; input.action1 = true; input.facing_left = true; }
            if (tick == 18) {input.aim_pos.x += -0.666855; input.aim_pos.y += -79.6674; input.action1 = true; input.up = true; input.facing_left = true; }
            if (tick == 19) {input.aim_pos.x += 0.999802; input.aim_pos.y += -90.9294; input.action1 = true; input.up = true; input.facing_left = true; }
            if (tick == 20) {input.aim_pos.x += 0.999802; input.aim_pos.y += -119.505; input.action1 = true; input.up = true; }
            if (tick == 21) {input.aim_pos.x += 4.66649; input.aim_pos.y += -154.185; input.up = true; }
            if (tick == 22) {input.aim_pos.x += 10.3331; input.aim_pos.y += -173.418; input.up = true; }
            if (tick == 23) {input.aim_pos.x += 9.33316; input.aim_pos.y += -171.881; input.up = true; }
            if (tick == 24) {input.aim_pos.x += 6.6665; input.aim_pos.y += -169.995; input.up = true; }
            if (tick == 25) {input.aim_pos.x += 3.66647; input.aim_pos.y += -164.527; input.up = true; }
            if (tick == 26) {input.aim_pos.x += 1.99982; input.aim_pos.y += -159.441; input.up = true; }
            if (tick == 27) {input.aim_pos.x += 1.6665; input.aim_pos.y += -157.502; input.up = true; }
            if (tick == 28) {input.aim_pos.x += 1.6665; input.aim_pos.y += -156.375; input.up = true; }
            if (tick == 29) {input.aim_pos.x += 1.6665; input.aim_pos.y += -154.848; input.up = true; }
            if (tick == 30) {input.aim_pos.x += 0.999802; input.aim_pos.y += -152.689; input.up = true; }
            if (tick == 31) {input.aim_pos.x += 0.333145; input.aim_pos.y += -149.191; input.up = true; }
            if (tick == 32) {input.aim_pos.x += -0.000183105; input.aim_pos.y += -145.422; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 33) {input.aim_pos.x += -0.333511; input.aim_pos.y += -139.873; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 34) {input.aim_pos.x += -1.00018; input.aim_pos.y += -136.295; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 35) {input.aim_pos.x += -1.33351; input.aim_pos.y += -134.789; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 36) {input.aim_pos.x += -2.00018; input.aim_pos.y += -134.704; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 37) {input.aim_pos.x += -2.66684; input.aim_pos.y += -134.66; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 38) {input.aim_pos.x += -4.66685; input.aim_pos.y += -132.319; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 39) {input.aim_pos.x += -7.00018; input.aim_pos.y += -130.432; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 40) {input.aim_pos.x += -9.66685; input.aim_pos.y += -129.612; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 41) {input.aim_pos.x += -11.6668; input.aim_pos.y += -129.33; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 42) {input.aim_pos.x += -12.3335; input.aim_pos.y += -130.051; input.right = true; input.up = true; input.facing_left = true; }
            if (tick == 43) {input.aim_pos.x += -16.5802; input.aim_pos.y += -129.874; input.right = true; input.up = true; input.facing_left = true; }
            if (tick == 44) {input.aim_pos.x += -20.1597; input.aim_pos.y += -129.164; input.left = true; input.right = true; input.up = true; input.facing_left = true; }
            if (tick == 45) {input.aim_pos.x += -22.6171; input.aim_pos.y += -129.017; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 46) {input.aim_pos.x += -24.4135; input.aim_pos.y += -128.962; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 47) {input.aim_pos.x += -25.0566; input.aim_pos.y += -128.733; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 48) {input.aim_pos.x += -25.2725; input.aim_pos.y += -128.783; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 49) {input.aim_pos.x += -24.9315; input.aim_pos.y += -128.455; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 50) {input.aim_pos.x += -23.9854; input.aim_pos.y += -128.572; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 51) {input.aim_pos.x += -22.8075; input.aim_pos.y += -128.812; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 52) {input.aim_pos.x += -20.927; input.aim_pos.y += -129.476; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 53) {input.aim_pos.x += -19.1267; input.aim_pos.y += -129.875; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 54) {input.aim_pos.x += -17.2443; input.aim_pos.y += -130.529; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 55) {input.aim_pos.x += -14.983; input.aim_pos.y += -131.036; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 56) {input.aim_pos.x += -12.9663; input.aim_pos.y += -131.189; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 57) {input.aim_pos.x += -11.3829; input.aim_pos.y += -131.38; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 58) {input.aim_pos.x += -9.8332; input.aim_pos.y += -132.199; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 59) {input.aim_pos.x += -8.81881; input.aim_pos.y += -132.625; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 60) {input.aim_pos.x += -7.84757; input.aim_pos.y += -133.071; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 61) {input.aim_pos.x += -7.40464; input.aim_pos.y += -133.835; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 62) {input.aim_pos.x += -6.63026; input.aim_pos.y += -134.263; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 63) {input.aim_pos.x += -7.09876; input.aim_pos.y += -134.155; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 64) {input.aim_pos.x += -8.29127; input.aim_pos.y += -133.206; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 65) {input.aim_pos.x += -8.70932; input.aim_pos.y += -132.373; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 66) {input.aim_pos.x += -8.72003; input.aim_pos.y += -131.36; input.action2 = true; input.facing_left = true; }
            if (tick == 67) {input.aim_pos.x += -9.06558; input.aim_pos.y += -130.611; input.facing_left = true; }
            if (tick == 68) {input.aim_pos.x += -9.59479; input.aim_pos.y += -130.434; input.facing_left = true; }
            if (tick == 69) {input.aim_pos.x += -10.3093; input.aim_pos.y += -130.808; input.facing_left = true; }
            if (tick == 70) {input.aim_pos.x += -11.0044; input.aim_pos.y += -131.589; input.facing_left = true; }
            if (tick == 71) {input.aim_pos.x += -11.5539; input.aim_pos.y += -132.682; input.facing_left = true; }
            if (tick == 72) {input.aim_pos.x += -12.2017; input.aim_pos.y += -134.067; input.facing_left = true; }
            if (tick == 73) {input.aim_pos.x += -12.922; input.aim_pos.y += -133.567; input.facing_left = true; }
            if (tick == 74) {input.aim_pos.x += -13.5962; input.aim_pos.y += -132.961; input.facing_left = true; }
            if (tick == 75) {input.aim_pos.x += -14.1895; input.aim_pos.y += -132.431; input.facing_left = true; }
            if (tick == 76) {input.aim_pos.x += -14.8137; input.aim_pos.y += -132.262; input.facing_left = true; }
            if (tick == 77) {input.aim_pos.x += -15.302; input.aim_pos.y += -132.14; input.facing_left = true; }
            if (tick == 78) {input.aim_pos.x += -15.7488; input.aim_pos.y += -132.034; input.facing_left = true; }
            if (tick == 79) {input.aim_pos.x += -16.1106; input.aim_pos.y += -131.952; input.facing_left = true; }
            if (tick == 80) {input.aim_pos.x += -16.3779; input.aim_pos.y += -131.559; input.facing_left = true; }
            if (tick == 81) {input.aim_pos.x += -16.6206; input.aim_pos.y += -131.175; input.facing_left = true; }
            if (tick == 82) {input.aim_pos.x += -16.8173; input.aim_pos.y += -131.136; input.facing_left = true; }
            if (tick == 83) {input.aim_pos.x += -16.9624; input.aim_pos.y += -131.107; input.facing_left = true; }
            if (tick == 84) {input.aim_pos.x += -17.0947; input.aim_pos.y += -131.083; input.facing_left = true; }
            if (tick == 85) {input.aim_pos.x += -17.2016; input.aim_pos.y += -131.064; input.facing_left = true; }
            if (tick >= 86) { if (isServer() && bot !is null) KickPlayer(bot); }
        } else if (tiger) {
            if (isServer() && bot !is null) KickPlayer(bot);
        }
    } else if (false) { // NOTE(hobey): slash wall climb
        if (frog) {
            if (tick == 0) {input.aim_pos.x += -9.99736; input.aim_pos.y += -67.5157; input.facing_left = true; }
            if (tick == 1) {input.aim_pos.x += -9.99796; input.aim_pos.y += -67.4746; input.facing_left = true; }
            if (tick == 2) {input.aim_pos.x += -9.99845; input.aim_pos.y += -67.4404; input.facing_left = true; }
            if (tick == 3) {input.aim_pos.x += -9.99876; input.aim_pos.y += -67.4194; input.facing_left = true; }
            if (tick == 4) {input.aim_pos.x += -9.999; input.aim_pos.y += -67.4026; input.facing_left = true; }
            if (tick == 5) {input.aim_pos.x += -9.99914; input.aim_pos.y += -67.3921; input.facing_left = true; }
            if (tick == 6) {input.aim_pos.x += -9.9993; input.aim_pos.y += -67.3818; input.facing_left = true; }
            if (tick == 7) {input.aim_pos.x += -9.66607; input.aim_pos.y += -67.3741; input.action1 = true; input.facing_left = true; }
            if (tick == 8) {input.aim_pos.x += -8.99949; input.aim_pos.y += -67.3676; input.action1 = true; input.facing_left = true; }
            if (tick == 9) {input.aim_pos.x += -8.9996; input.aim_pos.y += -67.6946; input.action1 = true; input.facing_left = true; }
            if (tick == 10) {input.aim_pos.x += -8.99964; input.aim_pos.y += -67.6901; input.action1 = true; input.facing_left = true; }
            if (tick == 11) {input.aim_pos.x += -8.66636; input.aim_pos.y += -67.6858; input.action1 = true; input.facing_left = true; }
            if (tick == 12) {input.aim_pos.x += -8.66642; input.aim_pos.y += -67.6823; input.action1 = true; input.facing_left = true; }
            if (tick == 13) {input.aim_pos.x += -8.66648; input.aim_pos.y += -67.6787; input.action1 = true; input.facing_left = true; }
            if (tick == 14) {input.aim_pos.x += -8.66653; input.aim_pos.y += -67.676; input.action1 = true; input.facing_left = true; }
            if (tick == 15) {input.aim_pos.x += -8.66653; input.aim_pos.y += -67.6737; input.action1 = true; input.facing_left = true; }
            if (tick == 16) {input.aim_pos.x += -8.66653; input.aim_pos.y += -67.6729; input.action1 = true; input.facing_left = true; }
            if (tick == 17) {input.aim_pos.x += -8.66653; input.aim_pos.y += -67.6718; input.action1 = true; input.facing_left = true; }
            if (tick == 18) {input.aim_pos.x += -8.66653; input.aim_pos.y += -67.6709; input.action1 = true; input.facing_left = true; }
            if (tick == 19) {input.aim_pos.x += -8.66653; input.aim_pos.y += -67.67; input.action1 = true; input.facing_left = true; }
            if (tick == 20) {input.aim_pos.x += -8.66653; input.aim_pos.y += -67.6693; input.action1 = true; input.facing_left = true; }
            if (tick == 21) {input.aim_pos.x += -8.66653; input.aim_pos.y += -67.669; input.action1 = true; input.facing_left = true; }
            if (tick == 22) {input.aim_pos.x += -8.66653; input.aim_pos.y += -67.6686; input.action1 = true; input.facing_left = true; }
            if (tick == 23) {input.aim_pos.x += -7.99986; input.aim_pos.y += -71.6682; input.action1 = true; input.up = true; input.facing_left = true; }
            if (tick == 24) {input.aim_pos.x += -5.99987; input.aim_pos.y += -93.93; input.action1 = true; input.up = true; input.facing_left = true; }
            if (tick == 25) {input.aim_pos.x += -2.66653; input.aim_pos.y += -124.508; input.up = true; input.facing_left = true; }
            if (tick == 26) {input.aim_pos.x += 1.66681; input.aim_pos.y += -156.212; input.up = true; input.facing_left = true; }
            if (tick == 27) {input.aim_pos.x += 2.66679; input.aim_pos.y += -166.463; input.up = true; }
            if (tick == 28) {input.aim_pos.x += 2.66679; input.aim_pos.y += -166.126; input.up = true; }
            if (tick == 29) {input.aim_pos.x += 2.66679; input.aim_pos.y += -163.492; input.up = true; }
            if (tick == 30) {input.aim_pos.x += 1.66681; input.aim_pos.y += -159.771; input.up = true; }
            if (tick == 31) {input.aim_pos.x += 1.33348; input.aim_pos.y += -157.493; input.up = true; }
            if (tick == 32) {input.aim_pos.x += 0.333458; input.aim_pos.y += -154.958; input.up = true; }
            if (tick == 33) {input.aim_pos.x += 0.0001297; input.aim_pos.y += -154.333; input.up = true; }
            if (tick == 34) {input.aim_pos.x += -0.99987; input.aim_pos.y += -151.374; input.up = true; }
            if (tick == 35) {input.aim_pos.x += -2.33321; input.aim_pos.y += -148.749; input.up = true; }
            if (tick == 36) {input.aim_pos.x += -3.99987; input.aim_pos.y += -144.703; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 37) {input.aim_pos.x += -5.66654; input.aim_pos.y += -139.843; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 38) {input.aim_pos.x += -6.99988; input.aim_pos.y += -136.119; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 39) {input.aim_pos.x += -8.33321; input.aim_pos.y += -132.031; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 40) {input.aim_pos.x += -9.66654; input.aim_pos.y += -128.73; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 41) {input.aim_pos.x += -10.6666; input.aim_pos.y += -127.057; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 42) {input.aim_pos.x += -11.6665; input.aim_pos.y += -127.379; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 43) {input.aim_pos.x += -11.6665; input.aim_pos.y += -129.069; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 44) {input.aim_pos.x += -12.6665; input.aim_pos.y += -127.862; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 45) {input.aim_pos.x += -14.3332; input.aim_pos.y += -126.711; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 46) {input.aim_pos.x += -17.6665; input.aim_pos.y += -124.742; input.right = true; input.up = true; input.facing_left = true; }
            if (tick == 47) {input.aim_pos.x += -23.2466; input.aim_pos.y += -123.784; input.right = true; input.up = true; input.facing_left = true; }
            if (tick == 48) {input.aim_pos.x += -27.3802; input.aim_pos.y += -123.771; input.right = true; input.up = true; input.facing_left = true; }
            if (tick == 49) {input.aim_pos.x += -30.472; input.aim_pos.y += -122.963; input.left = true; input.right = true; input.up = true; input.facing_left = true; }
            if (tick == 50) {input.aim_pos.x += -32.3051; input.aim_pos.y += -122.836; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 51) {input.aim_pos.x += -33.7298; input.aim_pos.y += -122.646; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 52) {input.aim_pos.x += -35.2642; input.aim_pos.y += -121.93; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 53) {input.aim_pos.x += -34.1689; input.aim_pos.y += -122.79; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 54) {input.aim_pos.x += -33.6217; input.aim_pos.y += -123.28; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 55) {input.aim_pos.x += -31.6944; input.aim_pos.y += -124.576; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 56) {input.aim_pos.x += -29.3328; input.aim_pos.y += -125.899; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 57) {input.aim_pos.x += -27.344; input.aim_pos.y += -126.357; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 58) {input.aim_pos.x += -25.0664; input.aim_pos.y += -126.997; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 59) {input.aim_pos.x += -22.8116; input.aim_pos.y += -127.533; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 60) {input.aim_pos.x += -20.8627; input.aim_pos.y += -128.085; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 61) {input.aim_pos.x += -18.9398; input.aim_pos.y += -128.135; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 62) {input.aim_pos.x += -17.0364; input.aim_pos.y += -128.419; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 63) {input.aim_pos.x += -15.6978; input.aim_pos.y += -128.808; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 64) {input.aim_pos.x += -14.4928; input.aim_pos.y += -128.668; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 65) {input.aim_pos.x += -13.4176; input.aim_pos.y += -128.881; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 66) {input.aim_pos.x += -12.8192; input.aim_pos.y += -129.215; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 67) {input.aim_pos.x += -12.4665; input.aim_pos.y += -129.905; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 68) {input.aim_pos.x += -12.9042; input.aim_pos.y += -130.081; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 69) {input.aim_pos.x += -13.8582; input.aim_pos.y += -130.041; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 70) {input.aim_pos.x += -15.7849; input.aim_pos.y += -129.015; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 71) {input.aim_pos.x += -17.2371; input.aim_pos.y += -127.72; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 72) {input.aim_pos.x += -17.868; input.aim_pos.y += -125.943; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 73) {input.aim_pos.x += -17.6738; input.aim_pos.y += -124.394; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 74) {input.aim_pos.x += -17.3837; input.aim_pos.y += -122.463; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 75) {input.aim_pos.x += -16.4094; input.aim_pos.y += -121.227; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 76) {input.aim_pos.x += -14.8314; input.aim_pos.y += -119.696; input.action2 = true; input.facing_left = true; }
            if (tick == 77) {input.aim_pos.x += -14.4269; input.aim_pos.y += -119.858; input.facing_left = true; }
            if (tick == 78) {input.aim_pos.x += -14.0933; input.aim_pos.y += -119.966; input.facing_left = true; }
            if (tick == 79) {input.aim_pos.x += -13.7653; input.aim_pos.y += -119.172; input.facing_left = true; }
            if (tick == 80) {input.aim_pos.x += -13.8098; input.aim_pos.y += -119.127; input.facing_left = true; }
            if (tick == 81) {input.aim_pos.x += -14.4634; input.aim_pos.y += -119.305; input.facing_left = true; }
            if (tick == 82) {input.aim_pos.x += -14.8374; input.aim_pos.y += -119.312; input.facing_left = true; }
            if (tick == 83) {input.aim_pos.x += -15.398; input.aim_pos.y += -119.395; input.facing_left = true; }
            if (tick == 84) {input.aim_pos.x += -15.7148; input.aim_pos.y += -119.898; input.right = true; input.facing_left = true; }
            if (tick == 85) {input.aim_pos.x += -17.0864; input.aim_pos.y += -120.945; input.right = true; input.facing_left = true; }
            if (tick == 86) {input.aim_pos.x += -18.6191; input.aim_pos.y += -122.817; input.right = true; input.facing_left = true; }
            if (tick == 87) {input.aim_pos.x += -19.6388; input.aim_pos.y += -121.178; input.right = true; input.facing_left = true; }
            if (tick == 88) {input.aim_pos.x += -20.3062; input.aim_pos.y += -120.139; input.right = true; input.facing_left = true; }
            if (tick == 89) {input.aim_pos.x += -21.6097; input.aim_pos.y += -118.63; input.right = true; input.facing_left = true; }
            if (tick == 90) {input.aim_pos.x += -22.7927; input.aim_pos.y += -117.435; input.facing_left = true; }
            if (tick == 91) {input.aim_pos.x += -23.4029; input.aim_pos.y += -116.936; input.facing_left = true; }
            if (tick == 92) {input.aim_pos.x += -23.6904; input.aim_pos.y += -116.231; input.facing_left = true; }
            if (tick == 93) {input.aim_pos.x += -24.1127; input.aim_pos.y += -115.301; input.facing_left = true; }
            if (tick == 94) {input.aim_pos.x += -24.4187; input.aim_pos.y += -114.836; input.facing_left = true; }
            if (tick == 95) {input.aim_pos.x += -24.7924; input.aim_pos.y += -114.011; input.facing_left = true; }
            if (tick == 96) {input.aim_pos.x += -24.8313; input.aim_pos.y += -113.217; input.facing_left = true; }
            if (tick == 97) {input.aim_pos.x += -24.8664; input.aim_pos.y += -112.768; input.facing_left = true; }
            if (tick == 98) {input.aim_pos.x += -25.1581; input.aim_pos.y += -112.023; input.facing_left = true; }
            if (tick == 99) {input.aim_pos.x += -25.5135; input.aim_pos.y += -111.632; input.facing_left = true; }
            if (tick == 100) {input.aim_pos.x += -26.2056; input.aim_pos.y += -110.249; input.facing_left = true; }
            if (tick == 101) {input.aim_pos.x += -26.1486; input.aim_pos.y += -109.898; input.facing_left = true; }
            if (tick == 102) {input.aim_pos.x += -26.1789; input.aim_pos.y += -109.517; input.facing_left = true; }
            if (tick == 103) {input.aim_pos.x += -26.1946; input.aim_pos.y += -109.165; input.facing_left = true; }
            if (tick == 104) {input.aim_pos.x += -26.1356; input.aim_pos.y += -109.158; input.facing_left = true; }
            if (tick == 105) {input.aim_pos.x += -26.1693; input.aim_pos.y += -109.125; input.facing_left = true; }
            if (tick == 106) {input.aim_pos.x += -26.1904; input.aim_pos.y += -109.109; input.facing_left = true; }
            if (tick == 107) {input.aim_pos.x += -26.1317; input.aim_pos.y += -109.108; input.facing_left = true; }
            if (tick == 108) {input.aim_pos.x += -26.4969; input.aim_pos.y += -109.088; input.facing_left = true; }
            if (tick == 109) {input.aim_pos.x += -26.4383; input.aim_pos.y += -109.091; input.facing_left = true; }
            if (tick == 110) {input.aim_pos.x += -26.4747; input.aim_pos.y += -109.075; input.facing_left = true; }
            if (tick == 111) {input.aim_pos.x += -26.5; input.aim_pos.y += -109.065; input.facing_left = true; }
            if (tick == 112) {input.aim_pos.x += -26.5265; input.aim_pos.y += -109.055; input.facing_left = true; }
            if (tick == 113) {input.aim_pos.x += -26.4744; input.aim_pos.y += -109.059; input.facing_left = true; }
            if (tick == 114) {input.aim_pos.x += -26.5055; input.aim_pos.y += -109.049; input.facing_left = true; }
            if (tick >= 115) { if (isServer() && bot !is null) KickPlayer(bot); }
        } else if (tiger) {
            if (isServer() && bot !is null) KickPlayer(bot);
        }
    } else if (false) { // NOTE(hobey): slash_wall climb
        if (frog) {
            if (tick == 0) {input.aim_pos.x += -8.12884; input.aim_pos.y += -130.411; input.facing_left = true; }
            if (tick == 1) {input.aim_pos.x += -7.82903; input.aim_pos.y += -126.512; input.facing_left = true; }
            if (tick == 2) {input.aim_pos.x += -7.86027; input.aim_pos.y += -122.881; input.facing_left = true; }
            if (tick == 3) {input.aim_pos.x += -7.55247; input.aim_pos.y += -119.916; input.action1 = true; input.facing_left = true; }
            if (tick == 4) {input.aim_pos.x += -7.23999; input.aim_pos.y += -117.494; input.action1 = true; input.facing_left = true; }
            if (tick == 5) {input.aim_pos.x += -7.25871; input.aim_pos.y += -115.321; input.action1 = true; input.facing_left = true; }
            if (tick == 6) {input.aim_pos.x += -7.27231; input.aim_pos.y += -113.41; input.action1 = true; input.facing_left = true; }
            if (tick == 7) {input.aim_pos.x += -7.28342; input.aim_pos.y += -112.12; input.action1 = true; input.facing_left = true; }
            if (tick == 8) {input.aim_pos.x += -7.2925; input.aim_pos.y += -111.067; input.action1 = true; input.facing_left = true; }
            if (tick == 9) {input.aim_pos.x += -6.96659; input.aim_pos.y += -110.208; input.action1 = true; input.facing_left = true; }
            if (tick == 10) {input.aim_pos.x += -6.97264; input.aim_pos.y += -109.505; input.action1 = true; input.facing_left = true; }
            if (tick == 11) {input.aim_pos.x += -6.97759; input.aim_pos.y += -108.597; input.action1 = true; input.facing_left = true; }
            if (tick == 12) {input.aim_pos.x += -6.98202; input.aim_pos.y += -108.083; input.action1 = true; input.facing_left = true; }
            if (tick == 13) {input.aim_pos.x += -6.98557; input.aim_pos.y += -107.673; input.action1 = true; input.facing_left = true; }
            if (tick == 14) {input.aim_pos.x += -6.98814; input.aim_pos.y += -107.373; input.action1 = true; input.facing_left = true; }
            if (tick == 15) {input.aim_pos.x += -6.99026; input.aim_pos.y += -107.127; input.action1 = true; input.facing_left = true; }
            if (tick == 16) {input.aim_pos.x += -6.32534; input.aim_pos.y += -109.925; input.action1 = true; input.up = true; input.facing_left = true; }
            if (tick == 17) {input.aim_pos.x += -5.99343; input.aim_pos.y += -124.355; input.action1 = true; input.up = true; input.facing_left = true; }
            if (tick == 18) {input.aim_pos.x += -3.99471; input.aim_pos.y += -146.464; input.up = true; input.facing_left = true; }
            if (tick == 19) {input.aim_pos.x += -0.662239; input.aim_pos.y += -160.7; input.up = true; input.facing_left = true; }
            if (tick == 20) {input.aim_pos.x += 0.00370789; input.aim_pos.y += -161.88; input.up = true; input.facing_left = true; }
            if (tick == 21) {input.aim_pos.x += 0.00296783; input.aim_pos.y += -159.257; input.up = true; input.facing_left = true; }
            if (tick == 22) {input.aim_pos.x += -0.330841; input.aim_pos.y += -155.263; input.up = true; input.facing_left = true; }
            if (tick == 23) {input.aim_pos.x += -1.66462; input.aim_pos.y += -146.042; input.up = true; input.facing_left = true; }
            if (tick == 24) {input.aim_pos.x += -2.33167; input.aim_pos.y += -140.546; input.up = true; input.facing_left = true; }
            if (tick == 25) {input.aim_pos.x += -2.99862; input.aim_pos.y += -137.269; input.up = true; input.facing_left = true; }
            if (tick == 26) {input.aim_pos.x += -3.33222; input.aim_pos.y += -136.462; input.up = true; input.facing_left = true; }
            if (tick == 27) {input.aim_pos.x += -3.99906; input.aim_pos.y += -134.525; input.up = true; input.facing_left = true; }
            if (tick == 28) {input.aim_pos.x += -4.33257; input.aim_pos.y += -133.796; input.up = true; input.facing_left = true; }
            if (tick == 29) {input.aim_pos.x += -4.99938; input.aim_pos.y += -134.417; input.up = true; input.facing_left = true; }
            if (tick == 30) {input.aim_pos.x += -5.33283; input.aim_pos.y += -134.277; input.up = true; input.facing_left = true; }
            if (tick == 31) {input.aim_pos.x += -5.99958; input.aim_pos.y += -135.497; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 32) {input.aim_pos.x += -6.33297; input.aim_pos.y += -132.942; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 33) {input.aim_pos.x += -6.66637; input.aim_pos.y += -131.667; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 34) {input.aim_pos.x += -6.99979; input.aim_pos.y += -129.534; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 35) {input.aim_pos.x += -7.99982; input.aim_pos.y += -128.414; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 36) {input.aim_pos.x += -8.6665; input.aim_pos.y += -127.953; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 37) {input.aim_pos.x += -9.33315; input.aim_pos.y += -128.366; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 38) {input.aim_pos.x += -9.99983; input.aim_pos.y += -129.193; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 39) {input.aim_pos.x += -10.6665; input.aim_pos.y += -128.087; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 40) {input.aim_pos.x += -12.3332; input.aim_pos.y += -127.268; input.left = true; input.right = true; input.up = true; input.facing_left = true; }
            if (tick == 41) {input.aim_pos.x += -15.6665; input.aim_pos.y += -127.099; input.right = true; input.up = true; input.facing_left = true; }
            if (tick == 42) {input.aim_pos.x += -22.9132; input.aim_pos.y += -127.188; input.left = true; input.right = true; input.up = true; input.facing_left = true; }
            if (tick == 43) {input.aim_pos.x += -28.4855; input.aim_pos.y += -127.306; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 44) {input.aim_pos.x += -32.0997; input.aim_pos.y += -127.675; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 45) {input.aim_pos.x += -33.3195; input.aim_pos.y += -127.96; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 46) {input.aim_pos.x += -33.6611; input.aim_pos.y += -128.465; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 47) {input.aim_pos.x += -32.9526; input.aim_pos.y += -128.251; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 48) {input.aim_pos.x += -32.0056; input.aim_pos.y += -128.598; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 49) {input.aim_pos.x += -30.6487; input.aim_pos.y += -128.909; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 50) {input.aim_pos.x += -28.7739; input.aim_pos.y += -129.46; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 51) {input.aim_pos.x += -26.764; input.aim_pos.y += -129.907; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 52) {input.aim_pos.x += -24.6352; input.aim_pos.y += -130.268; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 53) {input.aim_pos.x += -22.4214; input.aim_pos.y += -130.562; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 54) {input.aim_pos.x += -20.1281; input.aim_pos.y += -130.795; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 55) {input.aim_pos.x += -18.2256; input.aim_pos.y += -131.653; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 56) {input.aim_pos.x += -16.6897; input.aim_pos.y += -132.141; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 57) {input.aim_pos.x += -15.5895; input.aim_pos.y += -132.651; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 58) {input.aim_pos.x += -16.2563; input.aim_pos.y += -133.058; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 59) {input.aim_pos.x += -17.6758; input.aim_pos.y += -133.023; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 60) {input.aim_pos.x += -18.7564; input.aim_pos.y += -132.376; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 61) {input.aim_pos.x += -19.3641; input.aim_pos.y += -131.38; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 62) {input.aim_pos.x += -19.513; input.aim_pos.y += -130.219; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 63) {input.aim_pos.x += -19.1498; input.aim_pos.y += -128.629; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 64) {input.aim_pos.x += -18.1991; input.aim_pos.y += -126.797; input.action2 = true; input.facing_left = true; }
            if (tick == 65) {input.aim_pos.x += -17.6904; input.aim_pos.y += -125.835; input.action2 = true; input.facing_left = true; }
            if (tick == 66) {input.aim_pos.x += -17.4052; input.aim_pos.y += -125.809; input.facing_left = true; }
            if (tick == 67) {input.aim_pos.x += -17.178; input.aim_pos.y += -126.15; input.facing_left = true; }
            if (tick == 68) {input.aim_pos.x += -17.2003; input.aim_pos.y += -126.247; input.facing_left = true; }
            if (tick == 69) {input.aim_pos.x += -17.5271; input.aim_pos.y += -126.794; input.facing_left = true; }
            if (tick == 70) {input.aim_pos.x += -17.831; input.aim_pos.y += -127.831; input.facing_left = true; }
            if (tick == 71) {input.aim_pos.x += -18.2139; input.aim_pos.y += -128.769; input.facing_left = true; }
            if (tick == 72) {input.aim_pos.x += -18.7563; input.aim_pos.y += -129.594; input.facing_left = true; }
            if (tick == 73) {input.aim_pos.x += -19.4277; input.aim_pos.y += -131.2; input.facing_left = true; }
            if (tick == 74) {input.aim_pos.x += -20.785; input.aim_pos.y += -130.566; input.facing_left = true; }
            if (tick == 75) {input.aim_pos.x += -21.7631; input.aim_pos.y += -129.572; input.facing_left = true; }
            if (tick == 76) {input.aim_pos.x += -22.7856; input.aim_pos.y += -129.168; input.facing_left = true; }
            if (tick == 77) {input.aim_pos.x += -23.3626; input.aim_pos.y += -128.17; input.facing_left = true; }
            if (tick == 78) {input.aim_pos.x += -24.1702; input.aim_pos.y += -127.232; input.facing_left = true; }
            if (tick == 79) {input.aim_pos.x += -24.8931; input.aim_pos.y += -126.342; input.facing_left = true; }
            if (tick == 80) {input.aim_pos.x += -25.2128; input.aim_pos.y += -126.159; input.facing_left = true; }
            if (tick == 81) {input.aim_pos.x += -25.7822; input.aim_pos.y += -125.358; input.facing_left = true; }
            if (tick == 82) {input.aim_pos.x += -26.0242; input.aim_pos.y += -125.22; input.facing_left = true; }
            if (tick == 83) {input.aim_pos.x += -26.1997; input.aim_pos.y += -125.12; input.facing_left = true; }
            if (tick == 84) {input.aim_pos.x += -26.3577; input.aim_pos.y += -125.03; input.facing_left = true; }
            if (tick == 85) {input.aim_pos.x += -26.4725; input.aim_pos.y += -124.965; input.facing_left = true; }
            if (tick == 86) {input.aim_pos.x += -26.5669; input.aim_pos.y += -124.911; input.facing_left = true; }
            if (tick >= 87) { if (isServer() && bot !is null) KickPlayer(bot); }
        } else if (tiger) {
            if (isServer() && bot !is null) KickPlayer(bot);
        }
    } else if (false) { // NOTE(hobey): slash_wallclimb
        if (frog) {
            if (tick == 0) {input.aim_pos.x += -0.999886; input.aim_pos.y += -121.83; input.facing_left = true; }
            if (tick == 1) {input.aim_pos.x += -0.999886; input.aim_pos.y += -120.133; input.facing_left = true; }
            if (tick == 2) {input.aim_pos.x += -0.999886; input.aim_pos.y += -118.478; input.facing_left = true; }
            if (tick == 3) {input.aim_pos.x += -0.999886; input.aim_pos.y += -116.62; input.facing_left = true; }
            if (tick == 4) {input.aim_pos.x += -0.999886; input.aim_pos.y += -115.822; input.facing_left = true; }
            if (tick == 5) {input.aim_pos.x += -0.999886; input.aim_pos.y += -114.878; input.facing_left = true; }
            if (tick == 6) {input.aim_pos.x += -0.999886; input.aim_pos.y += -114.205; input.facing_left = true; }
            if (tick == 7) {input.aim_pos.x += -0.999886; input.aim_pos.y += -113.549; input.facing_left = true; }
            if (tick == 8) {input.aim_pos.x += -0.999886; input.aim_pos.y += -113.015; input.facing_left = true; }
            if (tick == 9) {input.aim_pos.x += -0.999886; input.aim_pos.y += -112.429; input.facing_left = true; }
            if (tick == 10) {input.aim_pos.x += -0.999886; input.aim_pos.y += -112.074; input.action1 = true; input.facing_left = true; }
            if (tick == 11) {input.aim_pos.x += -0.999886; input.aim_pos.y += -111.791; input.action1 = true; input.facing_left = true; }
            if (tick == 12) {input.aim_pos.x += -0.999886; input.aim_pos.y += -111.617; input.action1 = true; input.facing_left = true; }
            if (tick == 13) {input.aim_pos.x += -0.999886; input.aim_pos.y += -111.469; input.action1 = true; input.facing_left = true; }
            if (tick == 14) {input.aim_pos.x += -0.999886; input.aim_pos.y += -111.323; input.action1 = true; input.facing_left = true; }
            if (tick == 15) {input.aim_pos.x += -0.999886; input.aim_pos.y += -111.163; input.action1 = true; input.facing_left = true; }
            if (tick == 16) {input.aim_pos.x += -0.999886; input.aim_pos.y += -111.055; input.action1 = true; input.facing_left = true; }
            if (tick == 17) {input.aim_pos.x += -0.999886; input.aim_pos.y += -110.971; input.action1 = true; input.facing_left = true; }
            if (tick == 18) {input.aim_pos.x += -0.999886; input.aim_pos.y += -110.906; input.action1 = true; input.facing_left = true; }
            if (tick == 19) {input.aim_pos.x += -0.999886; input.aim_pos.y += -110.876; input.action1 = true; input.facing_left = true; }
            if (tick == 20) {input.aim_pos.x += -0.999886; input.aim_pos.y += -110.845; input.action1 = true; input.facing_left = true; }
            if (tick == 21) {input.aim_pos.x += -0.999886; input.aim_pos.y += -110.809; input.action1 = true; input.facing_left = true; }
            if (tick == 22) {input.aim_pos.x += -0.999886; input.aim_pos.y += -110.782; input.action1 = true; input.facing_left = true; }
            if (tick == 23) {input.aim_pos.x += -0.999886; input.aim_pos.y += -110.762; input.action1 = true; input.up = true; input.facing_left = true; }
            if (tick == 24) {input.aim_pos.x += -0.999886; input.aim_pos.y += -110.674; input.action1 = true; input.up = true; input.facing_left = true; }
            if (tick == 25) {input.aim_pos.x += -0.333214; input.aim_pos.y += -114.903; input.action1 = true; input.up = true; input.facing_left = true; }
            if (tick == 26) {input.aim_pos.x += 0.333443; input.aim_pos.y += -129.271; input.action1 = true; input.up = true; input.facing_left = true; }
            if (tick == 27) {input.aim_pos.x += 0.333443; input.aim_pos.y += -147.568; input.up = true; }
            if (tick == 28) {input.aim_pos.x += -0.333214; input.aim_pos.y += -155.444; input.up = true; }
            if (tick == 29) {input.aim_pos.x += -0.666557; input.aim_pos.y += -156.223; input.up = true; }
            if (tick == 30) {input.aim_pos.x += -0.666557; input.aim_pos.y += -154.517; input.up = true; input.facing_left = true; }
            if (tick == 31) {input.aim_pos.x += -1.33321; input.aim_pos.y += -150.904; input.up = true; input.facing_left = true; }
            if (tick == 32) {input.aim_pos.x += -1.33321; input.aim_pos.y += -146.565; input.up = true; input.facing_left = true; }
            if (tick == 33) {input.aim_pos.x += -1.33321; input.aim_pos.y += -144.233; input.up = true; input.facing_left = true; }
            if (tick == 34) {input.aim_pos.x += -1.66654; input.aim_pos.y += -142.131; input.up = true; input.facing_left = true; }
            if (tick == 35) {input.aim_pos.x += -1.66654; input.aim_pos.y += -141.073; input.up = true; input.facing_left = true; }
            if (tick == 36) {input.aim_pos.x += -1.66654; input.aim_pos.y += -140.027; input.up = true; input.facing_left = true; }
            if (tick == 37) {input.aim_pos.x += -1.66654; input.aim_pos.y += -138.934; input.up = true; input.facing_left = true; }
            if (tick == 38) {input.aim_pos.x += -1.66654; input.aim_pos.y += -138.142; input.up = true; input.facing_left = true; }
            if (tick == 39) {input.aim_pos.x += -1.66654; input.aim_pos.y += -138.063; input.up = true; input.facing_left = true; }
            if (tick == 40) {input.aim_pos.x += -1.99989; input.aim_pos.y += -138.774; input.up = true; input.facing_left = true; }
            if (tick == 41) {input.aim_pos.x += -1.99989; input.aim_pos.y += -139.044; input.up = true; input.facing_left = true; }
            if (tick == 42) {input.aim_pos.x += -1.99989; input.aim_pos.y += -139.9; input.facing_left = true; }
            if (tick == 43) {input.aim_pos.x += -1.99989; input.aim_pos.y += -140.974; input.facing_left = true; }
            if (tick == 44) {input.aim_pos.x += -1.99989; input.aim_pos.y += -141.626; input.facing_left = true; }
            if (tick == 45) {input.aim_pos.x += -1.99989; input.aim_pos.y += -141.052; input.facing_left = true; }
            if (tick == 46) {input.aim_pos.x += -1.66654; input.aim_pos.y += -139.709; input.facing_left = true; }
            if (tick == 47) {input.aim_pos.x += 0.333443; input.aim_pos.y += -137.613; input.right = true; input.facing_left = true; }
            if (tick == 48) {input.aim_pos.x += 2.94258; input.aim_pos.y += -133.129; input.right = true; }
            if (tick == 49) {input.aim_pos.x += 3.75086; input.aim_pos.y += -133.689; input.right = true; }
            if (tick == 50) {input.aim_pos.x += 9.82819; input.aim_pos.y += -127.048; input.right = true; }
            if (tick == 51) {input.aim_pos.x += 12.8347; input.aim_pos.y += -125.204; input.right = true; }
            if (tick == 52) {input.aim_pos.x += 16.7433; input.aim_pos.y += -117.924; input.right = true; }
            if (tick == 53) {input.aim_pos.x += 17.4161; input.aim_pos.y += -111.54; }
            if (tick == 54) {input.aim_pos.x += 21.248; input.aim_pos.y += -104.758; }
            if (tick == 55) {input.aim_pos.x += 23.0495; input.aim_pos.y += -100.747; }
            if (tick == 56) {input.aim_pos.x += 23.9881; input.aim_pos.y += -98.3512; }
            if (tick == 57) {input.aim_pos.x += 25.3805; input.aim_pos.y += -96.5384; }
            if (tick == 58) {input.aim_pos.x += 26.111; input.aim_pos.y += -95.312; }
            if (tick == 59) {input.aim_pos.x += 26.8199; input.aim_pos.y += -94.5703; }
            if (tick == 60) {input.aim_pos.x += 27.822; input.aim_pos.y += -93.6216; }
            if (tick == 61) {input.aim_pos.x += 28.4868; input.aim_pos.y += -92.9989; }
            if (tick == 62) {input.aim_pos.x += 28.8365; input.aim_pos.y += -92.6704; }
            if (tick == 63) {input.aim_pos.x += 29.2591; input.aim_pos.y += -92.2782; }
            if (tick == 64) {input.aim_pos.x += 29.4509; input.aim_pos.y += -92.0992; }
            if (tick == 65) {input.aim_pos.x += 29.678; input.aim_pos.y += -91.8898; }
            if (tick == 66) {input.aim_pos.x += 29.7889; input.aim_pos.y += -91.787; }
            if (tick == 67) {input.aim_pos.x += 29.9347; input.aim_pos.y += -91.6538; }
            if (tick >= 68) { if (isServer() && bot !is null) KickPlayer(bot); }
        } else if (tiger) {
            if (isServer() && bot !is null) KickPlayer(bot);
        }
    }  else if (false) { // NOTE(hobey): double slash wallclimb
        if (frog) {
            if (tick == 0) {input.aim_pos.x += -9.24888; input.aim_pos.y += -106.099; input.facing_left = true; }
            if (tick == 1) {input.aim_pos.x += -9.26411; input.aim_pos.y += -104.094; input.facing_left = true; }
            if (tick == 2) {input.aim_pos.x += -9.27781; input.aim_pos.y += -102.293; input.facing_left = true; }
            if (tick == 3) {input.aim_pos.x += -9.28678; input.aim_pos.y += -101.112; input.facing_left = true; }
            if (tick == 4) {input.aim_pos.x += -8.62934; input.aim_pos.y += -99.9025; input.action1 = true; input.facing_left = true; }
            if (tick == 5) {input.aim_pos.x += -6.63604; input.aim_pos.y += -99.022; input.action1 = true; input.facing_left = true; }
            if (tick == 6) {input.aim_pos.x += -6.64207; input.aim_pos.y += -98.2302; input.action1 = true; input.facing_left = true; }
            if (tick == 7) {input.aim_pos.x += -6.64646; input.aim_pos.y += -97.6538; input.action1 = true; input.facing_left = true; }
            if (tick == 8) {input.aim_pos.x += -6.65041; input.aim_pos.y += -97.1342; input.action1 = true; input.facing_left = true; }
            if (tick == 9) {input.aim_pos.x += -6.6533; input.aim_pos.y += -96.7542; input.action1 = true; input.facing_left = true; }
            if (tick == 10) {input.aim_pos.x += -6.65568; input.aim_pos.y += -96.4414; input.action1 = true; input.facing_left = true; }
            if (tick == 11) {input.aim_pos.x += -6.65763; input.aim_pos.y += -96.1852; input.action1 = true; input.facing_left = true; }
            if (tick == 12) {input.aim_pos.x += -6.65939; input.aim_pos.y += -95.9539; input.action1 = true; input.facing_left = true; }
            if (tick == 13) {input.aim_pos.x += -6.66067; input.aim_pos.y += -95.785; input.action1 = true; input.facing_left = true; }
            if (tick == 14) {input.aim_pos.x += -6.66184; input.aim_pos.y += -95.6322; input.action1 = true; input.facing_left = true; }
            if (tick == 15) {input.aim_pos.x += -6.6627; input.aim_pos.y += -95.5207; input.action1 = true; input.facing_left = true; }
            if (tick == 16) {input.aim_pos.x += -6.66338; input.aim_pos.y += -95.4289; input.action1 = true; input.facing_left = true; }
            if (tick == 17) {input.aim_pos.x += -6.66396; input.aim_pos.y += -95.3531; input.action1 = true; input.facing_left = true; }
            if (tick == 18) {input.aim_pos.x += -6.66444; input.aim_pos.y += -95.2904; input.action1 = true; input.facing_left = true; }
            if (tick == 19) {input.aim_pos.x += -6.66483; input.aim_pos.y += -95.2388; input.action1 = true; input.facing_left = true; }
            if (tick == 20) {input.aim_pos.x += -6.66512; input.aim_pos.y += -95.2004; input.action1 = true; input.facing_left = true; }
            if (tick == 21) {input.aim_pos.x += -6.6654; input.aim_pos.y += -95.1644; input.action1 = true; input.facing_left = true; }
            if (tick == 22) {input.aim_pos.x += -6.66563; input.aim_pos.y += -95.1348; input.action1 = true; input.facing_left = true; }
            if (tick == 23) {input.aim_pos.x += -6.66582; input.aim_pos.y += -95.1105; input.action1 = true; input.facing_left = true; }
            if (tick == 24) {input.aim_pos.x += -6.66598; input.aim_pos.y += -95.0887; input.action1 = true; input.facing_left = true; }
            if (tick == 25) {input.aim_pos.x += -6.66611; input.aim_pos.y += -95.0728; input.action1 = true; input.facing_left = true; }
            if (tick == 26) {input.aim_pos.x += -6.66619; input.aim_pos.y += -95.0598; input.action1 = true; input.facing_left = true; }
            if (tick == 27) {input.aim_pos.x += -6.66627; input.aim_pos.y += -95.0491; input.action1 = true; input.facing_left = true; }
            if (tick == 28) {input.aim_pos.x += -6.66633; input.aim_pos.y += -95.0403; input.action1 = true; input.facing_left = true; }
            if (tick == 29) {input.aim_pos.x += -6.66639; input.aim_pos.y += -95.0345; input.action1 = true; input.facing_left = true; }
            if (tick == 30) {input.aim_pos.x += -6.66645; input.aim_pos.y += -95.0282; input.action1 = true; input.facing_left = true; }
            if (tick == 31) {input.aim_pos.x += -6.6665; input.aim_pos.y += -95.0225; input.action1 = true; input.facing_left = true; }
            if (tick == 32) {input.aim_pos.x += -6.6665; input.aim_pos.y += -95.0185; input.action1 = true; input.facing_left = true; }
            if (tick == 33) {input.aim_pos.x += -6.6665; input.aim_pos.y += -95.0148; input.action1 = true; input.facing_left = true; }
            if (tick == 34) {input.aim_pos.x += -6.6665; input.aim_pos.y += -95.0121; input.action1 = true; input.facing_left = true; }
            if (tick == 35) {input.aim_pos.x += -6.6665; input.aim_pos.y += -95.0099; input.action1 = true; input.facing_left = true; }
            if (tick == 36) {input.aim_pos.x += -6.6665; input.aim_pos.y += -95.008; input.action1 = true; input.facing_left = true; }
            if (tick == 37) {input.aim_pos.x += -6.6665; input.aim_pos.y += -95.0067; input.action1 = true; input.facing_left = true; }
            if (tick == 38) {input.aim_pos.x += -6.6665; input.aim_pos.y += -95.0054; input.action1 = true; input.facing_left = true; }
            if (tick == 39) {input.aim_pos.x += -6.6665; input.aim_pos.y += -95.0045; input.action1 = true; input.facing_left = true; }
            if (tick == 40) {input.aim_pos.x += -6.6665; input.aim_pos.y += -95.3369; input.action1 = true; input.up = true; input.facing_left = true; }
            if (tick == 41) {input.aim_pos.x += -5.99984; input.aim_pos.y += -101.932; input.action1 = true; input.up = true; input.facing_left = true; }
            if (tick == 42) {input.aim_pos.x += -4.99983; input.aim_pos.y += -114.847; input.up = true; input.facing_left = true; }
            if (tick == 43) {input.aim_pos.x += -3.33317; input.aim_pos.y += -128.188; input.up = true; input.facing_left = true; }
            if (tick == 44) {input.aim_pos.x += -2.6665; input.aim_pos.y += -136.191; input.up = true; input.facing_left = true; }
            if (tick == 45) {input.aim_pos.x += -2.33317; input.aim_pos.y += -134.541; input.up = true; input.facing_left = true; }
            if (tick == 46) {input.aim_pos.x += -2.33317; input.aim_pos.y += -132.102; input.up = true; input.facing_left = true; }
            if (tick == 47) {input.aim_pos.x += -2.33317; input.aim_pos.y += -127.246; input.up = true; input.facing_left = true; }
            if (tick == 48) {input.aim_pos.x += -2.99982; input.aim_pos.y += -122.894; input.up = true; input.facing_left = true; }
            if (tick == 49) {input.aim_pos.x += -3.6665; input.aim_pos.y += -120.353; input.up = true; input.facing_left = true; }
            if (tick == 50) {input.aim_pos.x += -3.99982; input.aim_pos.y += -118.921; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 51) {input.aim_pos.x += -4.33315; input.aim_pos.y += -116.808; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 52) {input.aim_pos.x += -4.33315; input.aim_pos.y += -116.178; input.action1 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 53) {input.aim_pos.x += -4.33315; input.aim_pos.y += -115.769; input.action1 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 54) {input.aim_pos.x += -4.33315; input.aim_pos.y += -115.588; input.action1 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 55) {input.aim_pos.x += -4.6665; input.aim_pos.y += -116.648; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 56) {input.aim_pos.x += -4.99983; input.aim_pos.y += -118.677; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 57) {input.aim_pos.x += -5.33316; input.aim_pos.y += -120.658; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 58) {input.aim_pos.x += -5.66651; input.aim_pos.y += -121.006; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 59) {input.aim_pos.x += -5.66651; input.aim_pos.y += -121.215; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 60) {input.aim_pos.x += -5.66651; input.aim_pos.y += -122.186; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 61) {input.aim_pos.x += -6.6665; input.aim_pos.y += -122.893; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 62) {input.aim_pos.x += -6.99984; input.aim_pos.y += -123.924; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 63) {input.aim_pos.x += -8.6665; input.aim_pos.y += -123.344; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 64) {input.aim_pos.x += -9.99983; input.aim_pos.y += -123.254; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 65) {input.aim_pos.x += -11.3332; input.aim_pos.y += -123.77; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 66) {input.aim_pos.x += -11.6665; input.aim_pos.y += -125.496; input.right = true; input.up = true; input.facing_left = true; }
            if (tick == 67) {input.aim_pos.x += -15.9059; input.aim_pos.y += -124.395; input.right = true; input.up = true; input.facing_left = true; }
            if (tick == 68) {input.aim_pos.x += -19.694; input.aim_pos.y += -123.199; input.left = true; input.right = true; input.up = true; input.facing_left = true; }
            if (tick == 69) {input.aim_pos.x += -22.256; input.aim_pos.y += -122.373; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 70) {input.aim_pos.x += -23.5485; input.aim_pos.y += -122.148; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 71) {input.aim_pos.x += -24.1339; input.aim_pos.y += -122.133; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 72) {input.aim_pos.x += -23.7815; input.aim_pos.y += -122.652; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 73) {input.aim_pos.x += -23.0532; input.aim_pos.y += -123.005; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 74) {input.aim_pos.x += -21.6389; input.aim_pos.y += -123.539; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 75) {input.aim_pos.x += -20.028; input.aim_pos.y += -123.302; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 76) {input.aim_pos.x += -18.5324; input.aim_pos.y += -123.452; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 77) {input.aim_pos.x += -16.5426; input.aim_pos.y += -122.969; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 78) {input.aim_pos.x += -14.7536; input.aim_pos.y += -122.854; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 79) {input.aim_pos.x += -12.5322; input.aim_pos.y += -122.766; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 80) {input.aim_pos.x += -10.2241; input.aim_pos.y += -122.698; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 81) {input.aim_pos.x += -7.8559; input.aim_pos.y += -122.313; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 82) {input.aim_pos.x += -5.8231; input.aim_pos.y += -122.546; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 83) {input.aim_pos.x += -4.26626; input.aim_pos.y += -123.191; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 84) {input.aim_pos.x += -3.03638; input.aim_pos.y += -123.844; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 85) {input.aim_pos.x += -2.06034; input.aim_pos.y += -124.505; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 86) {input.aim_pos.x += -3.16232; input.aim_pos.y += -124.745; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 87) {input.aim_pos.x += -4.85448; input.aim_pos.y += -124.473; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 88) {input.aim_pos.x += -6.03816; input.aim_pos.y += -123.823; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 89) {input.aim_pos.x += -6.90128; input.aim_pos.y += -122.247; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 90) {input.aim_pos.x += -6.85699; input.aim_pos.y += -120.538; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 91) {input.aim_pos.x += -6.44713; input.aim_pos.y += -118.481; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 92) {input.aim_pos.x += -5.40877; input.aim_pos.y += -115.88; input.action2 = true; input.facing_left = true; }
            if (tick == 93) {input.aim_pos.x += -4.79534; input.aim_pos.y += -113.741; input.facing_left = true; }
            if (tick == 94) {input.aim_pos.x += -4.44218; input.aim_pos.y += -111.892; input.facing_left = true; }
            if (tick == 95) {input.aim_pos.x += -4.4236; input.aim_pos.y += -112.228; input.facing_left = true; }
            if (tick == 96) {input.aim_pos.x += -4.79774; input.aim_pos.y += -113.108; input.facing_left = true; }
            if (tick == 97) {input.aim_pos.x += -5.14812; input.aim_pos.y += -114.176; input.facing_left = true; }
            if (tick == 98) {input.aim_pos.x += -5.62337; input.aim_pos.y += -114.87; input.facing_left = true; }
            if (tick == 99) {input.aim_pos.x += -6.15778; input.aim_pos.y += -115.798; input.facing_left = true; }
            if (tick == 100) {input.aim_pos.x += -6.7239; input.aim_pos.y += -116.916; input.facing_left = true; }
            if (tick == 101) {input.aim_pos.x += -7.40945; input.aim_pos.y += -117.536; input.facing_left = true; }
            if (tick == 102) {input.aim_pos.x += -7.94633; input.aim_pos.y += -118.602; input.facing_left = true; }
            if (tick == 103) {input.aim_pos.x += -8.47133; input.aim_pos.y += -119.232; input.facing_left = true; }
            if (tick == 104) {input.aim_pos.x += -9.22099; input.aim_pos.y += -118.603; input.facing_left = true; }
            if (tick == 105) {input.aim_pos.x += -9.95187; input.aim_pos.y += -117.897; input.facing_left = true; }
            if (tick == 106) {input.aim_pos.x += -10.4706; input.aim_pos.y += -117.336; input.facing_left = true; }
            if (tick == 107) {input.aim_pos.x += -11.025; input.aim_pos.y += -116.813; input.facing_left = true; }
            if (tick == 108) {input.aim_pos.x += -11.3466; input.aim_pos.y += -116.448; input.facing_left = true; }
            if (tick == 109) {input.aim_pos.x += -11.6934; input.aim_pos.y += -116.131; input.facing_left = true; }
            if (tick == 110) {input.aim_pos.x += -11.9875; input.aim_pos.y += -115.868; input.facing_left = true; }
            if (tick >= 111) { if (isServer() && bot !is null) KickPlayer(bot); }
        } else if (tiger) {
            if (isServer() && bot !is null) KickPlayer(bot);
        }
    } else if (false) { // NOTE(hobey): double slash wallclimb
        if (frog) {
            if (tick == 0) { blob.setPosition(Vec2f(71.6997,71.6997)); blob.setVelocity(Vec2f_zero); input.aim_pos = blob.getPosition(); }
            if (tick == 0) {input.aim_pos.x += 2.97072; input.aim_pos.y += -110.311; }
            if (tick == 1) {input.aim_pos.x += 2.49831; input.aim_pos.y += -107.068; }
            if (tick == 2) {input.aim_pos.x += 1.4311; input.aim_pos.y += -105.873; }
            if (tick == 3) {input.aim_pos.x += 0.343369; input.aim_pos.y += -103.547; }
            if (tick == 4) {input.aim_pos.x += -0.397774; input.aim_pos.y += -101.26; input.facing_left = true; }
            if (tick == 5) {input.aim_pos.x += -1.09576; input.aim_pos.y += -100.596; input.facing_left = true; }
            if (tick == 6) {input.aim_pos.x += -1.14414; input.aim_pos.y += -99.0288; input.action1 = true; input.facing_left = true; }
            if (tick == 7) {input.aim_pos.x += -1.16998; input.aim_pos.y += -97.9908; input.action1 = true; input.facing_left = true; }
            if (tick == 8) {input.aim_pos.x += -1.1957; input.aim_pos.y += -97.6261; input.action1 = true; input.facing_left = true; }
            if (tick == 9) {input.aim_pos.x += -1.2198; input.aim_pos.y += -97.0148; input.action1 = true; input.facing_left = true; }
            if (tick == 10) {input.aim_pos.x += -1.23791; input.aim_pos.y += -96.722; input.action1 = true; input.facing_left = true; }
            if (tick == 11) {input.aim_pos.x += -1.25161; input.aim_pos.y += -96.3283; input.action1 = true; input.facing_left = true; }
            if (tick == 12) {input.aim_pos.x += -1.27053; input.aim_pos.y += -96.3254; input.action1 = true; input.facing_left = true; }
            if (tick == 13) {input.aim_pos.x += -0.945015; input.aim_pos.y += -95.9116; input.action1 = true; input.facing_left = true; }
            if (tick == 14) {input.aim_pos.x += -0.954033; input.aim_pos.y += -95.7672; input.action1 = true; input.facing_left = true; }
            if (tick == 15) {input.aim_pos.x += -0.96331; input.aim_pos.y += -95.2767; input.action1 = true; input.facing_left = true; }
            if (tick == 16) {input.aim_pos.x += -0.969933; input.aim_pos.y += -94.9254; input.action1 = true; input.facing_left = true; }
            if (tick == 17) {input.aim_pos.x += -0.975899; input.aim_pos.y += -94.6094; input.action1 = true; input.facing_left = true; }
            if (tick == 18) {input.aim_pos.x += -0.981071; input.aim_pos.y += -94.3356; input.action1 = true; input.facing_left = true; }
            if (tick == 19) {input.aim_pos.x += -0.984093; input.aim_pos.y += -94.1758; input.action1 = true; input.facing_left = true; }
            if (tick == 20) {input.aim_pos.x += -0.987709; input.aim_pos.y += -93.9837; input.action1 = true; input.facing_left = true; }
            if (tick == 21) {input.aim_pos.x += -0.989845; input.aim_pos.y += -93.8706; input.action1 = true; input.facing_left = true; }
            if (tick == 22) {input.aim_pos.x += -0.99128; input.aim_pos.y += -93.7944; input.action1 = true; input.facing_left = true; }
            if (tick == 23) {input.aim_pos.x += -0.992683; input.aim_pos.y += -93.7197; input.action1 = true; input.facing_left = true; }
            if (tick == 24) {input.aim_pos.x += -0.994377; input.aim_pos.y += -93.6304; input.action1 = true; input.facing_left = true; }
            if (tick == 25) {input.aim_pos.x += -0.995552; input.aim_pos.y += -93.5682; input.action1 = true; input.facing_left = true; }
            if (tick == 26) {input.aim_pos.x += -0.996086; input.aim_pos.y += -93.5394; input.action1 = true; input.facing_left = true; }
            if (tick == 27) {input.aim_pos.x += -0.996574; input.aim_pos.y += -93.5137; input.action1 = true; input.facing_left = true; }
            if (tick == 28) {input.aim_pos.x += -0.997322; input.aim_pos.y += -93.4744; input.action1 = true; input.facing_left = true; }
            if (tick == 29) {input.aim_pos.x += -0.997932; input.aim_pos.y += -93.442; input.action1 = true; input.facing_left = true; }
            if (tick == 30) {input.aim_pos.x += -0.998253; input.aim_pos.y += -93.4248; input.action1 = true; input.facing_left = true; }
            if (tick == 31) {input.aim_pos.x += -0.998619; input.aim_pos.y += -93.4054; input.action1 = true; input.facing_left = true; }
            if (tick == 32) {input.aim_pos.x += -0.998909; input.aim_pos.y += -93.3904; input.action1 = true; input.facing_left = true; }
            if (tick == 33) {input.aim_pos.x += -0.999123; input.aim_pos.y += -93.3797; input.action1 = true; input.facing_left = true; }
            if (tick == 34) {input.aim_pos.x += -0.999229; input.aim_pos.y += -93.3732; input.action1 = true; input.facing_left = true; }
            if (tick == 35) {input.aim_pos.x += -0.999413; input.aim_pos.y += -93.3643; input.action1 = true; input.facing_left = true; }
            if (tick == 36) {input.aim_pos.x += -0.999489; input.aim_pos.y += -93.36; input.action1 = true; input.facing_left = true; }
            if (tick == 37) {input.aim_pos.x += -0.99955; input.aim_pos.y += -93.3558; input.action1 = true; input.facing_left = true; }
            if (tick == 38) {input.aim_pos.x += -0.999626; input.aim_pos.y += -93.3518; input.action1 = true; input.facing_left = true; }
            if (tick == 39) {input.aim_pos.x += -0.999687; input.aim_pos.y += -93.3488; input.action1 = true; input.facing_left = true; }
            if (tick == 40) {input.aim_pos.x += -0.999748; input.aim_pos.y += -93.013; input.action1 = true; input.facing_left = true; }
            if (tick == 41) {input.aim_pos.x += -0.999794; input.aim_pos.y += -93.0111; input.action1 = true; input.facing_left = true; }
            if (tick == 42) {input.aim_pos.x += -0.99984; input.aim_pos.y += -93.0087; input.action1 = true; input.up = true; input.facing_left = true; }
            if (tick == 43) {input.aim_pos.x += -0.99984; input.aim_pos.y += -96.6026; input.action1 = true; input.up = true; input.facing_left = true; }
            if (tick == 44) {input.aim_pos.x += 0.000167847; input.aim_pos.y += -107.498; input.action1 = true; input.up = true; input.facing_left = true; }
            if (tick == 45) {input.aim_pos.x += 0.666817; input.aim_pos.y += -119.856; input.up = true; input.facing_left = true; }
            if (tick == 46) {input.aim_pos.x += 1.00014; input.aim_pos.y += -125.127; input.up = true; }
            if (tick == 47) {input.aim_pos.x += 1.00014; input.aim_pos.y += -123.607; input.up = true; }
            if (tick == 48) {input.aim_pos.x += 1.00014; input.aim_pos.y += -121.515; input.up = true; }
            if (tick == 49) {input.aim_pos.x += 1.00014; input.aim_pos.y += -118.296; input.up = true; }
            if (tick == 50) {input.aim_pos.x += 1.00014; input.aim_pos.y += -115.534; input.up = true; }
            if (tick == 51) {input.aim_pos.x += 1.00014; input.aim_pos.y += -112.087; input.up = true; }
            if (tick == 52) {input.aim_pos.x += 1.00014; input.aim_pos.y += -109.397; input.up = true; }
            if (tick == 53) {input.aim_pos.x += 1.00014; input.aim_pos.y += -107.039; input.up = true; }
            if (tick == 54) {input.aim_pos.x += 1.00014; input.aim_pos.y += -104.617; input.left = true; input.up = true; }
            if (tick == 55) {input.aim_pos.x += 1.00014; input.aim_pos.y += -104.213; input.left = true; input.up = true; }
            if (tick == 56) {input.aim_pos.x += 1.00014; input.aim_pos.y += -103.691; input.left = true; input.up = true; }
            if (tick == 57) {input.aim_pos.x += 1.00014; input.aim_pos.y += -104.016; input.action1 = true; input.left = true; input.up = true; }
            if (tick == 58) {input.aim_pos.x += 1.00014; input.aim_pos.y += -105.415; input.action1 = true; input.left = true; input.up = true; }
            if (tick == 59) {input.aim_pos.x += 0.666817; input.aim_pos.y += -107.543; input.action1 = true; input.left = true; input.up = true; }
            if (tick == 60) {input.aim_pos.x += 0.333488; input.aim_pos.y += -108.465; input.left = true; input.up = true; }
            if (tick == 61) {input.aim_pos.x += 0.000160217; input.aim_pos.y += -107.342; input.left = true; input.up = true; }
            if (tick == 62) {input.aim_pos.x += -0.99984; input.aim_pos.y += -105.676; input.left = true; input.up = true; }
            if (tick == 63) {input.aim_pos.x += -4.66651; input.aim_pos.y += -103.096; input.left = true; input.up = true; }
            if (tick == 64) {input.aim_pos.x += -5.99984; input.aim_pos.y += -103.083; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 65) {input.aim_pos.x += -6.6665; input.aim_pos.y += -103.53; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 66) {input.aim_pos.x += -7.6665; input.aim_pos.y += -105.705; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 67) {input.aim_pos.x += -7.99983; input.aim_pos.y += -107.488; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 68) {input.aim_pos.x += -8.33318; input.aim_pos.y += -109.601; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 69) {input.aim_pos.x += -8.66651; input.aim_pos.y += -111.79; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 70) {input.aim_pos.x += -8.99984; input.aim_pos.y += -113.457; input.right = true; input.up = true; input.facing_left = true; }
            if (tick == 71) {input.aim_pos.x += -12.9059; input.aim_pos.y += -112.185; input.left = true; input.right = true; input.up = true; input.facing_left = true; }
            if (tick == 72) {input.aim_pos.x += -16.8227; input.aim_pos.y += -110.629; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 73) {input.aim_pos.x += -18.9664; input.aim_pos.y += -110.12; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 74) {input.aim_pos.x += -20.1017; input.aim_pos.y += -109.336; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 75) {input.aim_pos.x += -20.5963; input.aim_pos.y += -109.409; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 76) {input.aim_pos.x += -21.1163; input.aim_pos.y += -108.604; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 77) {input.aim_pos.x += -20.9834; input.aim_pos.y += -107.889; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 78) {input.aim_pos.x += -20.2584; input.aim_pos.y += -107.32; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 79) {input.aim_pos.x += -18.3467; input.aim_pos.y += -107.328; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 80) {input.aim_pos.x += -16.5332; input.aim_pos.y += -107.75; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 81) {input.aim_pos.x += -14.4905; input.aim_pos.y += -108.241; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 82) {input.aim_pos.x += -12.2103; input.aim_pos.y += -108.918; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 83) {input.aim_pos.x += -10.2023; input.aim_pos.y += -109.168; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 84) {input.aim_pos.x += -7.75851; input.aim_pos.y += -109.895; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 85) {input.aim_pos.x += -5.71073; input.aim_pos.y += -110.288; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 86) {input.aim_pos.x += -4.40327; input.aim_pos.y += -111.292; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 87) {input.aim_pos.x += -3.27762; input.aim_pos.y += -112.106; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 88) {input.aim_pos.x += -4.11285; input.aim_pos.y += -112.466; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 89) {input.aim_pos.x += -5.27733; input.aim_pos.y += -112.813; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 90) {input.aim_pos.x += -6.25816; input.aim_pos.y += -112.649; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 91) {input.aim_pos.x += -7.40549; input.aim_pos.y += -111.912; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 92) {input.aim_pos.x += -8.07611; input.aim_pos.y += -110.93; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 93) {input.aim_pos.x += -8.02963; input.aim_pos.y += -109.44; input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 94) {input.aim_pos.x += -7.54977; input.aim_pos.y += -108.259; input.action2 = true; input.facing_left = true; }
            if (tick == 95) {input.aim_pos.x += -7.42421; input.aim_pos.y += -106.923; input.action2 = true; input.facing_left = true; }
            if (tick == 96) {input.aim_pos.x += -6.93632; input.aim_pos.y += -105.919; input.action2 = true; input.facing_left = true; }
            if (tick == 97) {input.aim_pos.x += -6.92411; input.aim_pos.y += -105.842; input.action2 = true; input.facing_left = true; }
            if (tick == 98) {input.aim_pos.x += -7.06437; input.aim_pos.y += -105.214; input.action2 = true; input.facing_left = true; }
            if (tick == 99) {input.aim_pos.x += -6.87268; input.aim_pos.y += -104.468; input.facing_left = true; }
            if (tick == 100) {input.aim_pos.x += -7.10786; input.aim_pos.y += -104.799; input.facing_left = true; }
            if (tick == 101) {input.aim_pos.x += -6.44162; input.aim_pos.y += -104.46; input.facing_left = true; }
            if (tick == 102) {input.aim_pos.x += -6.62577; input.aim_pos.y += -105.745; input.facing_left = true; }
            if (tick == 103) {input.aim_pos.x += -6.67122; input.aim_pos.y += -107.268; input.facing_left = true; }
            if (tick == 104) {input.aim_pos.x += -7.17817; input.aim_pos.y += -109.146; input.facing_left = true; }
            if (tick == 105) {input.aim_pos.x += -7.848; input.aim_pos.y += -108.898; input.facing_left = true; }
            if (tick == 106) {input.aim_pos.x += -8.44042; input.aim_pos.y += -108.504; input.facing_left = true; }
            if (tick == 107) {input.aim_pos.x += -8.8585; input.aim_pos.y += -108.267; input.facing_left = true; }
            if (tick == 108) {input.aim_pos.x += -9.18467; input.aim_pos.y += -108.108; input.facing_left = true; }
            if (tick == 109) {input.aim_pos.x += -9.62568; input.aim_pos.y += -107.922; input.facing_left = true; }
            if (tick == 110) {input.aim_pos.x += -9.99743; input.aim_pos.y += -107.772; input.facing_left = true; }
            if (tick == 111) {input.aim_pos.x += -10.1775; input.aim_pos.y += -107.697; input.facing_left = true; }
            if (tick == 112) {input.aim_pos.x += -10.3749; input.aim_pos.y += -107.621; input.facing_left = true; }
            if (tick == 113) {input.aim_pos.x += -10.571; input.aim_pos.y += -107.551; input.facing_left = true; }
            if (tick == 114) {input.aim_pos.x += -10.7366; input.aim_pos.y += -107.495; input.facing_left = true; }
            if (tick == 115) {input.aim_pos.x += -10.8636; input.aim_pos.y += -107.453; input.facing_left = true; }
            if (tick == 116) {input.aim_pos.x += -10.9618; input.aim_pos.y += -107.422; input.facing_left = true; }
            if (tick == 117) {input.aim_pos.x += -10.9971; input.aim_pos.y += -107.41; input.facing_left = true; }
            if (tick == 118) {input.aim_pos.x += -11.0481; input.aim_pos.y += -107.395; input.facing_left = true; }
            if (tick == 119) {input.aim_pos.x += -11.0921; input.aim_pos.y += -107.382; input.facing_left = true; }
            if (tick == 120) {input.aim_pos.x += -11.1419; input.aim_pos.y += -107.37; input.facing_left = true; }
            if (tick == 121) {input.aim_pos.x += -11.1838; input.aim_pos.y += -107.36; input.facing_left = true; }
            if (tick == 122) {input.aim_pos.x += -11.204; input.aim_pos.y += -107.356; input.facing_left = true; }
            if (tick == 123) {input.aim_pos.x += -11.2242; input.aim_pos.y += -107.353; input.facing_left = true; }
            if (tick == 124) {input.aim_pos.x += -11.2485; input.aim_pos.y += -107.348; input.facing_left = true; }
            if (tick == 125) {input.aim_pos.x += -11.2571; input.aim_pos.y += -107.347; input.facing_left = true; }
            if (tick == 126) {input.aim_pos.x += -11.2693; input.aim_pos.y += -107.344; input.facing_left = true; }
            if (tick == 127) {input.aim_pos.x += -11.2797; input.aim_pos.y += -107.342; input.facing_left = true; }
            if (tick == 128) {input.aim_pos.x += -11.2875; input.aim_pos.y += -107.341; input.facing_left = true; }
            if (tick == 129) {input.aim_pos.x += -11.2951; input.aim_pos.y += -107.339; input.facing_left = true; }
            if (tick == 130) {input.aim_pos.x += -11.3008; input.aim_pos.y += -107.338; input.facing_left = true; }
            if (tick >= 131) { if (isServer() && bot !is null) KickPlayer(bot); }
        } else if (tiger) {
            if (isServer() && bot !is null) KickPlayer(bot);
        }
    } else if (selected_training == Training::crouch_shieldslide) {
        if (frog) {
            if (tick == 0) { blob.setPosition(Vec2f(195.712,128.712)); blob.setVelocity(Vec2f_zero); input.aim_pos = blob.getPosition(); }
            if (tick == 0) {input.aim_pos.x += 35.6745; input.aim_pos.y += 29.6646; }
            if (tick == 1) {input.aim_pos.x += 35.6731; input.aim_pos.y += 29.6649; }
            if (tick == 2) {input.aim_pos.x += 35.6718; input.aim_pos.y += 29.6653; }
            if (tick == 3) {input.aim_pos.x += 35.6709; input.aim_pos.y += 29.6655; }
            if (tick == 4) {input.aim_pos.x += 35.6702; input.aim_pos.y += 29.6657; }
            if (tick == 5) {input.aim_pos.x += 35.6695; input.aim_pos.y += 29.6659; }
            if (tick == 6) {input.aim_pos.x += 35.669; input.aim_pos.y += 29.6661; }
            if (tick == 7) {input.aim_pos.x += 35.6686; input.aim_pos.y += 29.6662; }
            if (tick == 8) {input.aim_pos.x += 35.6682; input.aim_pos.y += 29.6663; }
            if (tick == 9) {input.aim_pos.x += 35.6679; input.aim_pos.y += 29.6664; input.right = true; }
            if (tick == 10) {input.aim_pos.x += 34.5429; input.aim_pos.y += 29.9997; input.right = true; }
            if (tick == 11) {input.aim_pos.x += 33.3232; input.aim_pos.y += 29.9998; input.right = true; }
            if (tick == 12) {input.aim_pos.x += 31.7674; input.aim_pos.y += 29.9998; input.right = true; }
            if (tick == 13) {input.aim_pos.x += 29.596; input.aim_pos.y += 31.3332; input.right = true; }
            if (tick == 14) {input.aim_pos.x += 26.481; input.aim_pos.y += 34.6665; input.right = true; }
            if (tick == 15) {input.aim_pos.x += 23.5849; input.aim_pos.y += 36.6665; input.right = true; }
            if (tick == 16) {input.aim_pos.x += 21.1367; input.aim_pos.y += 38.6665; input.right = true; }
            if (tick == 17) {input.aim_pos.x += 19.5103; input.aim_pos.y += 41.3332; input.right = true; }
            if (tick == 18) {input.aim_pos.x += 17.6549; input.aim_pos.y += 45.5653; input.action2 = true; input.right = true; }
            if (tick == 19) {input.aim_pos.x += 16.4507; input.aim_pos.y += 46.7294; input.action2 = true; input.right = true; }
            if (tick == 20) {input.aim_pos.x += 16.4027; input.aim_pos.y += 48.9069; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 21) {input.aim_pos.x += 16.5919; input.aim_pos.y += 50.4963; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 22) {input.aim_pos.x += 16.4456; input.aim_pos.y += 49.5673; input.action2 = true; input.right = true; }
            if (tick == 23) {input.aim_pos.x += 16.5108; input.aim_pos.y += 48.1752; input.action2 = true; input.right = true; }
            if (tick == 24) {input.aim_pos.x += 16.5928; input.aim_pos.y += 49.0711; input.action2 = true; input.right = true; }
            if (tick == 25) {input.aim_pos.x += 16.5726; input.aim_pos.y += 49.962; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 26) {input.aim_pos.x += 15.7793; input.aim_pos.y += 49.7296; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 27) {input.aim_pos.x += 15.0269; input.aim_pos.y += 47.9543; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 28) {input.aim_pos.x += 14.7061; input.aim_pos.y += 46.2488; input.action2 = true; input.right = true; }
            if (tick == 29) {input.aim_pos.x += 14.6136; input.aim_pos.y += 45.2619; input.action2 = true; input.right = true; }
            if (tick == 30) {input.aim_pos.x += 13.8168; input.aim_pos.y += 44.3385; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 31) {input.aim_pos.x += 13.7171; input.aim_pos.y += 43.3543; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 32) {input.aim_pos.x += 14.1112; input.aim_pos.y += 41.3902; input.action2 = true; input.right = true; }
            if (tick == 33) {input.aim_pos.x += 14.6532; input.aim_pos.y += 38.4072; input.action2 = true; input.right = true; }
            if (tick == 34) {input.aim_pos.x += 15.0431; input.aim_pos.y += 36.9701; input.action2 = true; input.right = true; }
            if (tick == 35) {input.aim_pos.x += 15.2252; input.aim_pos.y += 37.3049; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 36) {input.aim_pos.x += 14.6782; input.aim_pos.y += 37.5998; input.action2 = true; input.right = true; }
            if (tick == 37) {input.aim_pos.x += 14.2282; input.aim_pos.y += 37.3532; input.action2 = true; input.right = true; }
            if (tick == 38) {input.aim_pos.x += 13.7634; input.aim_pos.y += 37.1825; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 39) {input.aim_pos.x += 13.5121; input.aim_pos.y += 36.9973; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 40) {input.aim_pos.x += 12.3401; input.aim_pos.y += 37.4168; input.action2 = true; input.right = true; }
            if (tick == 41) {input.aim_pos.x += 11.6221; input.aim_pos.y += 37.3611; input.action2 = true; input.right = true; }
            if (tick == 42) {input.aim_pos.x += 10.5945; input.aim_pos.y += 36.8265; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 43) {input.aim_pos.x += 10.2458; input.aim_pos.y += 36.638; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 44) {input.aim_pos.x += 10.0624; input.aim_pos.y += 36.8099; input.action2 = true; input.right = true; }
            if (tick == 45) {input.aim_pos.x += 9.27985; input.aim_pos.y += 36.9482; input.action2 = true; input.right = true; }
            if (tick == 46) {input.aim_pos.x += 8.37683; input.aim_pos.y += 37.0469; input.action2 = true; input.right = true; }
            if (tick == 47) {input.aim_pos.x += 8.14523; input.aim_pos.y += 37.1258; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 48) {input.aim_pos.x += 7.44702; input.aim_pos.y += 37.4608; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 49) {input.aim_pos.x += 7.19025; input.aim_pos.y += 38.0621; input.action2 = true; input.right = true; }
            if (tick == 50) {input.aim_pos.x += 7.17761; input.aim_pos.y += 38.1564; input.action2 = true; input.right = true; }
            if (tick == 51) {input.aim_pos.x += 7.60907; input.aim_pos.y += 37.747; input.action2 = true; input.right = true; }
            if (tick == 52) {input.aim_pos.x += 8.38959; input.aim_pos.y += 36.9275; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 53) {input.aim_pos.x += 9.15381; input.aim_pos.y += 36.9344; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 54) {input.aim_pos.x += 8.90182; input.aim_pos.y += 36.9986; input.action2 = true; input.right = true; }
            if (tick == 55) {input.aim_pos.x += 8.1246; input.aim_pos.y += 37.0574; input.action2 = true; input.right = true; }
            if (tick == 56) {input.aim_pos.x += 8.22958; input.aim_pos.y += 37.1135; input.action2 = true; input.right = true; }
            if (tick == 57) {input.aim_pos.x += 8.48691; input.aim_pos.y += 37.1578; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 58) {input.aim_pos.x += 8.48755; input.aim_pos.y += 37.4879; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 59) {input.aim_pos.x += 8.69971; input.aim_pos.y += 38.0862; input.action2 = true; input.right = true; }
            if (tick == 60) {input.aim_pos.x += 9.06833; input.aim_pos.y += 38.1705; input.action2 = true; input.right = true; }
            if (tick == 61) {input.aim_pos.x += 9.81668; input.aim_pos.y += 37.7486; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 62) {input.aim_pos.x += 9.81958; input.aim_pos.y += 36.9512; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 63) {input.aim_pos.x += 10.5787; input.aim_pos.y += 36.2188; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 64) {input.aim_pos.x += 10.9916; input.aim_pos.y += 36.3466; input.action2 = true; input.right = true; }
            if (tick == 65) {input.aim_pos.x += 11.7515; input.aim_pos.y += 36.5262; input.action2 = true; input.right = true; }
            if (tick == 66) {input.aim_pos.x += 11.4395; input.aim_pos.y += 36.6599; input.action2 = true; input.right = true; }
            if (tick == 67) {input.aim_pos.x += 10.8908; input.aim_pos.y += 36.7546; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 68) {input.aim_pos.x += 10.5735; input.aim_pos.y += 37.0996; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 69) {input.aim_pos.x += 10.4963; input.aim_pos.y += 37.7077; input.action2 = true; input.right = true; }
            if (tick == 70) {input.aim_pos.x += 10.6419; input.aim_pos.y += 37.8009; input.action2 = true; input.right = true; }
            if (tick == 71) {input.aim_pos.x += 11.2866; input.aim_pos.y += 37.3877; input.action2 = true; input.right = true; }
            if (tick == 72) {input.aim_pos.x += 11.5587; input.aim_pos.y += 36.5805; input.action2 = true; input.right = true; }
            if (tick == 73) {input.aim_pos.x += 12.2498; input.aim_pos.y += 36.5971; input.action2 = true; input.right = true; }
            if (tick == 74) {input.aim_pos.x += 12.6252; input.aim_pos.y += 36.6783; input.action2 = true; input.right = true; }
            if (tick == 75) {input.aim_pos.x += 11.7761; input.aim_pos.y += 36.7395; input.action2 = true; }
            if (tick == 76) {input.aim_pos.x += 11.684; input.aim_pos.y += 36.7927; }
            if (tick == 77) {input.aim_pos.x += 11.5247; input.aim_pos.y += 36.4964; }
            if (tick == 78) {input.aim_pos.x += 12.2622; input.aim_pos.y += 36.1959; }
            if (tick == 79) {input.aim_pos.x += 14.7351; input.aim_pos.y += 36.2261; }
            if (tick == 80) {input.aim_pos.x += 17.3204; input.aim_pos.y += 36.2482; }
            if (tick == 81) {input.aim_pos.x += 19.7202; input.aim_pos.y += 36.2647; }
            if (tick == 82) {input.aim_pos.x += 22.0281; input.aim_pos.y += 36.278; }
            if (tick == 83) {input.aim_pos.x += 24.4857; input.aim_pos.y += 36.2902; }
            if (tick == 84) {input.aim_pos.x += 26.5739; input.aim_pos.y += 36.2997; }
            if (tick == 85) {input.aim_pos.x += 28.3031; input.aim_pos.y += 36.307; }
            if (tick == 86) {input.aim_pos.x += 29.626; input.aim_pos.y += 36.3125; }
            if (tick == 87) {input.aim_pos.x += 30.7129; input.aim_pos.y += 36.3167; }
            if (tick == 88) {input.aim_pos.x += 31.6034; input.aim_pos.y += 36.3202; }
            if (tick == 89) {input.aim_pos.x += 32.3862; input.aim_pos.y += 35.9897; }
            if (tick == 90) {input.aim_pos.x += 32.9305; input.aim_pos.y += 35.9917; }
            if (tick == 91) {input.aim_pos.x += 33.2785; input.aim_pos.y += 35.993; }
            if (tick == 92) {input.aim_pos.x += 33.725; input.aim_pos.y += 35.9945; }
            if (tick == 93) {input.aim_pos.x += 34.1106; input.aim_pos.y += 35.9957; }
            if (tick == 94) {input.aim_pos.x += 34.3962; input.aim_pos.y += 35.9966; }
            if (tick == 95) {input.aim_pos.x += 34.6456; input.aim_pos.y += 35.9973; }
            if (tick >= 96) { if (isServer() && bot !is null) KickPlayer(bot); }
        } else if (tiger) {
            if (tick == 0) { blob.setPosition(Vec2f(281.983,136.3)); blob.setVelocity(Vec2f_zero); input.aim_pos = blob.getPosition(); }
            if (tick == 0) {input.aim_pos.x += -57.6434; input.aim_pos.y += -8.66702; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 1) {input.aim_pos.x += -57.6483; input.aim_pos.y += -8.66702; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 2) {input.aim_pos.x += -57.6509; input.aim_pos.y += -8.66702; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 3) {input.aim_pos.x += -57.6542; input.aim_pos.y += -8.66702; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 4) {input.aim_pos.x += -57.6568; input.aim_pos.y += -8.66702; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 5) {input.aim_pos.x += -57.6584; input.aim_pos.y += -8.66702; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 6) {input.aim_pos.x += -57.6594; input.aim_pos.y += -8.66702; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 7) {input.aim_pos.x += -57.6608; input.aim_pos.y += -8.66701; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 8) {input.aim_pos.x += -57.6621; input.aim_pos.y += -8.66701; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 9) {input.aim_pos.x += -57.663; input.aim_pos.y += -8.66701; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 10) {input.aim_pos.x += -57.6635; input.aim_pos.y += -8.66701; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 11) {input.aim_pos.x += -57.664; input.aim_pos.y += -8.66701; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 12) {input.aim_pos.x += -57.6646; input.aim_pos.y += -8.66701; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 13) {input.aim_pos.x += -57.665; input.aim_pos.y += -8.66701; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 14) {input.aim_pos.x += -57.6652; input.aim_pos.y += -8.66701; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 15) {input.aim_pos.x += -57.6655; input.aim_pos.y += -8.66701; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 16) {input.aim_pos.x += -57.6659; input.aim_pos.y += -8.66701; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 17) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66701; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 18) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66701; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 19) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66701; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 20) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66701; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 21) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66701; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 22) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66701; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 23) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66701; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 24) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66701; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 25) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66701; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 26) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66701; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 27) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66701; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 28) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66701; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 29) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66701; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 30) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66701; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 31) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66701; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 32) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66701; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 33) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66701; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 34) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 35) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 36) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 37) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 38) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 39) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 40) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 41) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 42) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 43) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 44) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 45) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 46) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 47) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 48) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 49) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 50) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 51) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 52) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 53) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 54) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 55) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 56) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 57) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 58) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 59) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 60) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 61) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 62) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 63) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 64) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 65) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 66) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 67) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 68) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 69) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 70) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 71) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 72) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 73) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 74) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 75) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 76) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 77) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 78) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.facing_left = true; }
            if (tick == 79) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.facing_left = true; }
            if (tick == 80) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.facing_left = true; }
            if (tick == 81) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.action2 = true; input.facing_left = true; }
            if (tick == 82) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.facing_left = true; }
            if (tick == 83) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.facing_left = true; }
            if (tick == 84) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.facing_left = true; }
            if (tick == 85) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.facing_left = true; }
            if (tick == 86) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.facing_left = true; }
            if (tick == 87) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.facing_left = true; }
            if (tick == 88) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.facing_left = true; }
            if (tick == 89) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.facing_left = true; }
            if (tick == 90) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.facing_left = true; }
            if (tick == 91) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.facing_left = true; }
            if (tick == 92) {input.aim_pos.x += -57.666; input.aim_pos.y += -8.66698; input.facing_left = true; }
            if (tick >= 93) { if (isServer() && bot !is null) KickPlayer(bot); }
        }
    } else if (false) { // NOTE(hobey): double slash + jab thing
        if (frog) {
            if (tick == 0) { blob.setPosition(Vec2f(267.546,136.3)); blob.setVelocity(Vec2f_zero); input.aim_pos = blob.getPosition(); }
            if (tick == 0) { input.aim_pos.x += 47.6671; input.aim_pos.y += -7.33357; }
            if (tick == 1) { input.aim_pos.x += 47.6671; input.aim_pos.y += -7.33357; }
            if (tick == 2) { input.aim_pos.x += 47.6671; input.aim_pos.y += -7.33357; }
            if (tick == 3) { input.aim_pos.x += 47.6671; input.aim_pos.y += -7.33357; }
            if (tick == 4) { input.aim_pos.x += 47.6671; input.aim_pos.y += -7.33357; }
            if (tick == 5) { input.aim_pos.x += 47.6671; input.aim_pos.y += -7.33357; }
            if (tick == 6) { input.aim_pos.x += 47.6671; input.aim_pos.y += -7.33357; input.action1 = true; }
            if (tick == 7) { input.aim_pos.x += 47.6671; input.aim_pos.y += -7.33357; input.action1 = true; }
            if (tick == 8) { input.aim_pos.x += 47.6671; input.aim_pos.y += -7.33357; input.action1 = true; }
            if (tick == 9) { input.aim_pos.x += 47.6671; input.aim_pos.y += -7.33357; input.action1 = true; }
            if (tick == 10) { input.aim_pos.x += 47.6671; input.aim_pos.y += -7.33357; input.action1 = true; }
            if (tick == 11) { input.aim_pos.x += 47.6671; input.aim_pos.y += -7.33357; input.action1 = true; }
            if (tick == 12) { input.aim_pos.x += 47.6671; input.aim_pos.y += -7.33357; input.action1 = true; }
            if (tick == 13) { input.aim_pos.x += 47.6671; input.aim_pos.y += -7.33357; input.action1 = true; }
            if (tick == 14) { input.aim_pos.x += 47.6671; input.aim_pos.y += -7.33357; input.action1 = true; }
            if (tick == 15) { input.aim_pos.x += 47.6671; input.aim_pos.y += -7.33357; input.action1 = true; }
            if (tick == 16) { input.aim_pos.x += 47.6671; input.aim_pos.y += -7.33357; input.action1 = true; }
            if (tick == 17) { input.aim_pos.x += 47.6671; input.aim_pos.y += -7.33357; input.action1 = true; }
            if (tick == 18) { input.aim_pos.x += 47.6671; input.aim_pos.y += -7.33357; input.action1 = true; }
            if (tick == 19) { input.aim_pos.x += 47.6671; input.aim_pos.y += -7.33357; input.action1 = true; input.right = true; }
            if (tick == 20) { input.aim_pos.x += 47.2578; input.aim_pos.y += -7.33357; input.action1 = true; input.right = true; }
            if (tick == 21) { input.aim_pos.x += 46.4967; input.aim_pos.y += -7.33357; input.action1 = true; input.right = true; }
            if (tick == 22) { input.aim_pos.x += 45.4879; input.aim_pos.y += -7.33357; input.action1 = true; input.right = true; }
            if (tick == 23) { input.aim_pos.x += 45.619; input.aim_pos.y += -8.00024; input.action1 = true; input.right = true; }
            if (tick == 24) { input.aim_pos.x += 44.8615; input.aim_pos.y += -8.00024; input.action1 = true; input.right = true; }
            if (tick == 25) { input.aim_pos.x += 43.4269; input.aim_pos.y += -8.00024; input.action1 = true; input.right = true; }
            if (tick == 26) { input.aim_pos.x += 41.9746; input.aim_pos.y += -8.00024; input.action1 = true; input.right = true; }
            if (tick == 27) { input.aim_pos.x += 40.519; input.aim_pos.y += -8.00024; input.action1 = true; input.right = true; }
            if (tick == 28) { input.aim_pos.x += 40.2377; input.aim_pos.y += -8.00024; input.action1 = true; input.right = true; }
            if (tick == 29) { input.aim_pos.x += 39.9331; input.aim_pos.y += -8.00024; input.action1 = true; input.right = true; }
            if (tick == 30) { input.aim_pos.x += 39.8631; input.aim_pos.y += -8.00024; input.action1 = true; input.right = true; }
            if (tick == 31) { input.aim_pos.x += 39.4077; input.aim_pos.y += -8.00024; input.action1 = true; input.right = true; }
            if (tick == 32) { input.aim_pos.x += 39.3648; input.aim_pos.y += -8.00024; input.action1 = true; input.right = true; }
            if (tick == 33) { input.aim_pos.x += 38.9326; input.aim_pos.y += -8.00024; input.action1 = true; input.right = true; }
            if (tick == 34) { input.aim_pos.x += 38.9072; input.aim_pos.y += -8.00024; input.action1 = true; input.right = true; }
            if (tick == 35) { input.aim_pos.x += 38.2062; input.aim_pos.y += -8.00024; input.action1 = true; input.right = true; }
            if (tick == 36) { input.aim_pos.x += 37.3718; input.aim_pos.y += -8.00024; input.action1 = true; input.right = true; }
            if (tick == 37) { input.aim_pos.x += 36.286; input.aim_pos.y += -8.00024; input.action1 = true; input.right = true; }
            if (tick == 38) { input.aim_pos.x += 35.8331; input.aim_pos.y += -8.00024; input.action1 = true; input.right = true; }
            if (tick == 39) { input.aim_pos.x += 35.4695; input.aim_pos.y += -8.00024; input.action1 = true; input.right = true; }
            if (tick == 40) { input.aim_pos.x += 35.8733; input.aim_pos.y += -7.66692; input.action1 = true; input.right = true; }
            if (tick == 41) { input.aim_pos.x += 36.3284; input.aim_pos.y += -7.66692; input.action1 = true; input.right = true; }
            if (tick == 42) { input.aim_pos.x += 36.0847; input.aim_pos.y += -7.66692; input.action1 = true; input.right = true; }
            if (tick == 43) { input.aim_pos.x += 36.7927; input.aim_pos.y += -8.00024; input.action1 = true; input.right = true; input.up = true; }
            if (tick == 44) { input.aim_pos.x += 38.6933; input.aim_pos.y += -8.26224; input.right = true; input.up = true; }
            if (tick == 45) { input.aim_pos.x += 38.6974; input.aim_pos.y += -6.8548; input.right = true; }
            if (tick == 46) { input.aim_pos.x += 38.5996; input.aim_pos.y += -5.79471; input.right = true; }
            if (tick == 47) { input.aim_pos.x += 37.0776; input.aim_pos.y += -4.90802; input.right = true; }
            if (tick == 48) { input.aim_pos.x += 36.4975; input.aim_pos.y += -4.56664; input.right = true; }
            if (tick == 49) { input.aim_pos.x += 35.0613; input.aim_pos.y += -4.47424; input.action1 = true; input.right = true; }
            if (tick == 50) { input.aim_pos.x += 33.9941; input.aim_pos.y += -4.89192; input.action1 = true; input.right = true; }
            if (tick == 51) { input.aim_pos.x += 33.2248; input.aim_pos.y += -5.73184; input.action1 = true; input.right = true; }
            if (tick == 52) { input.aim_pos.x += 32.0546; input.aim_pos.y += -5.46621; input.action1 = true; input.right = true; }
            if (tick == 53) { input.aim_pos.x += 32.7807; input.aim_pos.y += -4.80311; input.action1 = true; input.right = true; }
            if (tick == 54) { input.aim_pos.x += 33.5401; input.aim_pos.y += -3.90706; input.action1 = true; input.right = true; }
            if (tick == 55) { input.aim_pos.x += 32.811; input.aim_pos.y += -5.77538; input.action1 = true; input.right = true; }
            if (tick == 56) { input.aim_pos.x += 32.2885; input.aim_pos.y += -6.92145; input.action1 = true; input.right = true; }
            if (tick == 57) { input.aim_pos.x += 31.7522; input.aim_pos.y += -9.68746; input.right = true; input.up = true; }
            if (tick == 58) { input.aim_pos.x += 31.9428; input.aim_pos.y += -15.6492; input.right = true; input.up = true; }
            if (tick == 59) { input.aim_pos.x += 32.7355; input.aim_pos.y += -16.2967; input.action1 = true; input.right = true; input.up = true; }
            if (tick == 60) { input.aim_pos.x += 32.4273; input.aim_pos.y += -14.7655; input.action1 = true; input.right = true; }
            if (tick == 61) { input.aim_pos.x += 31.9438; input.aim_pos.y += -8.81621; input.action1 = true; input.right = true; }
            if (tick == 62) { input.aim_pos.x += 33.5296; input.aim_pos.y += -4.09541; input.action1 = true; input.right = true; }
            if (tick == 63) { input.aim_pos.x += 34.7421; input.aim_pos.y += -4.54619; input.action1 = true; input.right = true; }
            if (tick == 64) { input.aim_pos.x += 34.7226; input.aim_pos.y += -7.37737; input.right = true; }
            if (tick == 65) { input.aim_pos.x += 35.5184; input.aim_pos.y += -8.52843; input.action1 = true; input.right = true; }
            if (tick == 66) { input.aim_pos.x += 35.5715; input.aim_pos.y += -8.24457; input.action1 = true; input.right = true; }
            if (tick == 67) { input.aim_pos.x += 36.1432; input.aim_pos.y += -7.86411; input.action1 = true; input.right = true; }
            if (tick == 68) { input.aim_pos.x += 36.0605; input.aim_pos.y += -7.5598; input.action1 = true; input.right = true; }
            if (tick == 69) { input.aim_pos.x += 36.7423; input.aim_pos.y += -7.25435; input.action1 = true; input.right = true; }
            if (tick == 70) { input.aim_pos.x += 37.2815; input.aim_pos.y += -7.04333; input.action1 = true; }
            if (tick == 71) { input.aim_pos.x += 37.8677; input.aim_pos.y += -6.91777; input.action1 = true; }
            if (tick == 72) { input.aim_pos.x += 38.7054; input.aim_pos.y += -6.79378; }
            if (tick == 73) { input.aim_pos.x += 40.554; input.aim_pos.y += -6.69621; }
            if (tick == 74) { input.aim_pos.x += 42.5042; input.aim_pos.y += -6.6084; }
            if (tick == 75) { input.aim_pos.x += 44.1999; input.aim_pos.y += -6.53877; }
            if (tick == 76) { input.aim_pos.x += 44.966; input.aim_pos.y += -6.50713; }
            if (tick == 77) { input.aim_pos.x += 45.6492; input.aim_pos.y += -6.47995; }
            if (tick == 78) { input.aim_pos.x += 46.3319; input.aim_pos.y += -6.45404; }
            if (tick == 79) { input.aim_pos.x += 46.4478; input.aim_pos.y += -6.437; }
            if (tick == 80) { input.aim_pos.x += 47.1378; input.aim_pos.y += -6.41284; }
            if (tick == 81) { input.aim_pos.x += 47.4992; input.aim_pos.y += -6.40001; }
            if (tick == 82) { input.aim_pos.x += 47.8547; input.aim_pos.y += -6.38789; }
            if (tick == 83) { input.aim_pos.x += 48.2769; input.aim_pos.y += -6.37416; }
            if (tick == 84) { input.aim_pos.x += 48.4761; input.aim_pos.y += -6.36757; }
            if (tick == 85) { input.aim_pos.x += 48.7311; input.aim_pos.y += -6.35959; }
            if (tick == 86) { input.aim_pos.x += 48.8485; input.aim_pos.y += -6.35582; }
            if (tick == 87) { input.aim_pos.x += 48.9686; input.aim_pos.y += -6.35213; }
            if (tick == 88) { input.aim_pos.x += 49.0856; input.aim_pos.y += -6.34868; }
            if (tick == 89) { input.aim_pos.x += 49.1946; input.aim_pos.y += -6.34554; }
            if (tick == 90) { input.aim_pos.x += 49.2651; input.aim_pos.y += -6.34369; }
            if (tick == 91) { input.aim_pos.x += 49.3341; input.aim_pos.y += -6.34189; }
            if (tick == 92) { input.aim_pos.x += 49.3979; input.aim_pos.y += -6.34023; }
            if (tick == 93) { input.aim_pos.x += 49.4388; input.aim_pos.y += -6.33916; }
            if (tick == 94) { input.aim_pos.x += 49.4785; input.aim_pos.y += -6.33812; }
            if (tick == 95) { input.aim_pos.x += 49.5077; input.aim_pos.y += -6.33734; }
            if (tick == 96) { input.aim_pos.x += 49.5387; input.aim_pos.y += -6.33653; }
            if (tick == 97) { input.aim_pos.x += 49.5586; input.aim_pos.y += -6.33601; }
            if (tick == 98) { input.aim_pos.x += 49.5756; input.aim_pos.y += -6.33557; }
            if (tick == 99) { input.aim_pos.x += 49.5985; input.aim_pos.y += -6.33496; }
            if (tick == 100) { input.aim_pos.x += 49.6151; input.aim_pos.y += -6.33453; }
            if (tick == 101) { input.aim_pos.x += 49.6247; input.aim_pos.y += -6.33427; }
            if (tick == 102) { input.aim_pos.x += 49.631; input.aim_pos.y += -6.33412; }
            if (tick == 103) { input.aim_pos.x += 49.6364; input.aim_pos.y += -6.334; }
            if (tick == 104) { input.aim_pos.x += 49.6438; input.aim_pos.y += -6.33382; }
            if (tick == 105) { input.aim_pos.x += 49.648; input.aim_pos.y += -6.33368; }
            if (tick == 106) { input.aim_pos.x += 49.6504; input.aim_pos.y += -6.33359; }
            if (tick == 107) { input.aim_pos.x += 49.6534; input.aim_pos.y += -6.33351; }
            if (tick == 108) { input.aim_pos.x += 49.656; input.aim_pos.y += -6.33347; }
            if (tick == 109) { input.aim_pos.x += 49.6573; input.aim_pos.y += -6.33345; }
            if (tick == 110) { input.aim_pos.x += 49.6594; input.aim_pos.y += -6.33344; }
            if (tick == 111) { input.aim_pos.x += 49.661; input.aim_pos.y += -6.33342; }
            if (tick == 112) { input.aim_pos.x += 49.6619; input.aim_pos.y += -6.33342; }
            if (tick == 113) { input.aim_pos.x += 49.6627; input.aim_pos.y += -6.33342; }
            if (tick == 114) { input.aim_pos.x += 49.6634; input.aim_pos.y += -6.33342; }
            if (tick == 115) { input.aim_pos.x += 49.6642; input.aim_pos.y += -6.33342; }
            if (tick == 116) { input.aim_pos.x += 49.6648; input.aim_pos.y += -6.33342; }
            if (tick == 117) { input.aim_pos.x += 49.665; input.aim_pos.y += -6.33342; }
            if (tick == 118) { input.aim_pos.x += 49.6652; input.aim_pos.y += -6.33342; }
            if (tick == 119) { input.aim_pos.x += 49.6654; input.aim_pos.y += -6.33342; }
            if (tick == 120) { input.aim_pos.x += 49.6656; input.aim_pos.y += -6.33342; }
            if (tick == 121) { input.aim_pos.x += 49.6658; input.aim_pos.y += -6.33342; }
            if (tick == 122) { input.aim_pos.x += 49.666; input.aim_pos.y += -6.3334; }
            if (tick == 123) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 124) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 125) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 126) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 127) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 128) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 129) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 130) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 131) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 132) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 133) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 134) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 135) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 136) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 137) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 138) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 139) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 140) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 141) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 142) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 143) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 144) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 145) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 146) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 147) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 148) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 149) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 150) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 151) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 152) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 153) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 154) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 155) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 156) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 157) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 158) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 159) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 160) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 161) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 162) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 163) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 164) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 165) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 166) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 167) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 168) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 169) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 170) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 171) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 172) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 173) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 174) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 175) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 176) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 177) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 178) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 179) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 180) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 181) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 182) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 183) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 184) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 185) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 186) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 187) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick == 188) { input.aim_pos.x += 49.6661; input.aim_pos.y += -6.3334; }
            if (tick >= 189) { if (isServer() && bot !is null) KickPlayer(bot); }
        } else if (tiger) {
            if (tick == 0) { blob.setPosition(Vec2f(368.313,136.3)); blob.setVelocity(Vec2f_zero); input.aim_pos = blob.getPosition(); }
            if (tick == 0) { input.aim_pos.x += -37.9994; input.aim_pos.y += -17.3336; input.facing_left = true; }
            if (tick == 1) { input.aim_pos.x += -37.9994; input.aim_pos.y += -17.3336; input.facing_left = true; }
            if (tick == 2) { input.aim_pos.x += -37.9994; input.aim_pos.y += -17.3336; input.facing_left = true; }
            if (tick == 3) { input.aim_pos.x += -37.9994; input.aim_pos.y += -17.3336; input.facing_left = true; }
            if (tick == 4) { input.aim_pos.x += -37.9994; input.aim_pos.y += -17.3336; input.facing_left = true; }
            if (tick == 5) { input.aim_pos.x += -37.9994; input.aim_pos.y += -17.3336; input.facing_left = true; }
            if (tick == 6) { input.aim_pos.x += -37.9994; input.aim_pos.y += -17.3336; input.facing_left = true; }
            if (tick == 7) { input.aim_pos.x += -37.9994; input.aim_pos.y += -17.3336; input.facing_left = true; }
            if (tick == 8) { input.aim_pos.x += -37.9994; input.aim_pos.y += -17.3336; input.facing_left = true; }
            if (tick == 9) { input.aim_pos.x += -37.9994; input.aim_pos.y += -17.0003; input.facing_left = true; }
            if (tick == 10) { input.aim_pos.x += -37.666; input.aim_pos.y += -16.0003; input.facing_left = true; }
            if (tick == 11) { input.aim_pos.x += -37.666; input.aim_pos.y += -15.3336; input.facing_left = true; }
            if (tick == 12) { input.aim_pos.x += -37.3327; input.aim_pos.y += -15.0003; input.facing_left = true; }
            if (tick == 13) { input.aim_pos.x += -37.3327; input.aim_pos.y += -15.0003; input.facing_left = true; }
            if (tick == 14) { input.aim_pos.x += -37.3327; input.aim_pos.y += -15.0003; input.facing_left = true; }
            if (tick == 15) { input.aim_pos.x += -37.3327; input.aim_pos.y += -15.0003; input.facing_left = true; }
            if (tick == 16) { input.aim_pos.x += -37.3327; input.aim_pos.y += -15.0003; input.facing_left = true; }
            if (tick == 17) { input.aim_pos.x += -37.3327; input.aim_pos.y += -15.0003; input.facing_left = true; }
            if (tick == 18) { input.aim_pos.x += -37.3327; input.aim_pos.y += -15.0003; input.facing_left = true; }
            if (tick == 19) { input.aim_pos.x += -37.3327; input.aim_pos.y += -15.0003; input.facing_left = true; }
            if (tick == 20) { input.aim_pos.x += -37.3327; input.aim_pos.y += -15.0003; input.facing_left = true; }
            if (tick == 21) { input.aim_pos.x += -37.3327; input.aim_pos.y += -15.0003; input.facing_left = true; }
            if (tick == 22) { input.aim_pos.x += -37.3327; input.aim_pos.y += -15.0003; input.facing_left = true; }
            if (tick == 23) { input.aim_pos.x += -37.3327; input.aim_pos.y += -15.0003; input.facing_left = true; }
            if (tick == 24) { input.aim_pos.x += -37.3327; input.aim_pos.y += -15.0003; input.facing_left = true; }
            if (tick == 25) { input.aim_pos.x += -37.3327; input.aim_pos.y += -15.0003; input.facing_left = true; }
            if (tick == 26) { input.aim_pos.x += -37.3327; input.aim_pos.y += -14.667; input.facing_left = true; }
            if (tick == 27) { input.aim_pos.x += -37.3327; input.aim_pos.y += -14.667; input.facing_left = true; }
            if (tick == 28) { input.aim_pos.x += -37.3327; input.aim_pos.y += -14.667; input.facing_left = true; }
            if (tick == 29) { input.aim_pos.x += -37.3327; input.aim_pos.y += -14.667; input.facing_left = true; }
            if (tick == 30) { input.aim_pos.x += -37.3327; input.aim_pos.y += -14.667; input.facing_left = true; }
            if (tick == 31) { input.aim_pos.x += -37.3327; input.aim_pos.y += -14.667; input.facing_left = true; }
            if (tick == 32) { input.aim_pos.x += -37.3327; input.aim_pos.y += -14.667; input.facing_left = true; }
            if (tick == 33) { input.aim_pos.x += -37.3327; input.aim_pos.y += -14.667; input.facing_left = true; }
            if (tick == 34) { input.aim_pos.x += -37.3327; input.aim_pos.y += -14.667; input.facing_left = true; }
            if (tick == 35) { input.aim_pos.x += -37.3327; input.aim_pos.y += -14.667; input.facing_left = true; }
            if (tick == 36) { input.aim_pos.x += -37.3327; input.aim_pos.y += -14.667; input.facing_left = true; }
            if (tick == 37) { input.aim_pos.x += -37.3327; input.aim_pos.y += -14.667; input.facing_left = true; }
            if (tick == 38) { input.aim_pos.x += -37.3327; input.aim_pos.y += -15.0003; input.facing_left = true; }
            if (tick == 39) { input.aim_pos.x += -36.9994; input.aim_pos.y += -15.3336; input.facing_left = true; }
            if (tick == 40) { input.aim_pos.x += -36.9994; input.aim_pos.y += -16.0003; input.facing_left = true; }
            if (tick == 41) { input.aim_pos.x += -36.9994; input.aim_pos.y += -16.3336; input.facing_left = true; }
            if (tick == 42) { input.aim_pos.x += -36.9994; input.aim_pos.y += -16.3336; input.facing_left = true; }
            if (tick == 43) { input.aim_pos.x += -36.9994; input.aim_pos.y += -16.3336; input.facing_left = true; }
            if (tick == 44) { input.aim_pos.x += -36.9994; input.aim_pos.y += -16.667; input.facing_left = true; }
            if (tick == 45) { input.aim_pos.x += -36.3328; input.aim_pos.y += -17.3336; input.right = true; input.facing_left = true; }
            if (tick == 46) { input.aim_pos.x += -35.3598; input.aim_pos.y += -19.6669; input.right = true; input.facing_left = true; }
            if (tick == 47) { input.aim_pos.x += -35.3712; input.aim_pos.y += -22.6669; input.right = true; input.facing_left = true; }
            if (tick == 48) { input.aim_pos.x += -36.3779; input.aim_pos.y += -23.3336; input.action2 = true; input.right = true; input.facing_left = true; }
            if (tick == 49) { input.aim_pos.x += -37.6122; input.aim_pos.y += -23.3336; input.action2 = true; input.right = true; input.facing_left = true; }
            if (tick == 50) { input.aim_pos.x += -38.9009; input.aim_pos.y += -23.3336; input.action2 = true; input.right = true; input.facing_left = true; }
            if (tick == 51) { input.aim_pos.x += -39.9561; input.aim_pos.y += -23.3336; input.action2 = true; input.right = true; input.facing_left = true; }
            if (tick == 52) { input.aim_pos.x += -41.1306; input.aim_pos.y += -23.6669; input.action2 = true; input.right = true; input.facing_left = true; }
            if (tick == 53) { input.aim_pos.x += -42.1298; input.aim_pos.y += -23.6669; input.action2 = true; input.right = true; input.facing_left = true; }
            if (tick == 54) { input.aim_pos.x += -42.4781; input.aim_pos.y += -23.6669; input.action2 = true; input.right = true; input.facing_left = true; }
            if (tick == 55) { input.aim_pos.x += -43.2859; input.aim_pos.y += -23.6669; input.action2 = true; input.right = true; input.facing_left = true; }
            if (tick == 56) { input.aim_pos.x += -44.0571; input.aim_pos.y += -24.0003; input.action2 = true; input.right = true; input.facing_left = true; }
            if (tick == 57) { input.aim_pos.x += -45.0853; input.aim_pos.y += -24.6669; input.action2 = true; input.right = true; input.facing_left = true; }
            if (tick == 58) { input.aim_pos.x += -45.7268; input.aim_pos.y += -24.6669; input.action2 = true; input.right = true; input.facing_left = true; }
            if (tick == 59) { input.aim_pos.x += -46.1417; input.aim_pos.y += -24.6669; input.action2 = true; input.facing_left = true; }
            if (tick == 60) { input.aim_pos.x += -46.0316; input.aim_pos.y += -24.6669; input.action2 = true; input.facing_left = true; }
            if (tick == 61) { input.aim_pos.x += -46.8741; input.aim_pos.y += -24.6669; input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 62) { input.aim_pos.x += -12.7297; input.aim_pos.y += 0; input.facing_left = true; }
            if (tick == 63) { input.aim_pos.x += -11.6233; input.aim_pos.y += 0; input.facing_left = true; }
            if (tick == 64) { input.aim_pos.x += -10.953; input.aim_pos.y += 0; input.facing_left = true; }
            if (tick == 65) { input.aim_pos.x += -10.5469; input.aim_pos.y += 0; input.facing_left = true; }
            if (tick == 66) { input.aim_pos.x += -10.3009; input.aim_pos.y += 0; input.facing_left = true; }
            if (tick == 67) { input.aim_pos.x += -10.1519; input.aim_pos.y += 0; input.facing_left = true; }
            if (tick == 68) { input.aim_pos.x += -10.0616; input.aim_pos.y += 0; input.facing_left = true; }
            if (tick == 69) { input.aim_pos.x += -10.0069; input.aim_pos.y += 0; input.facing_left = true; }
            if (tick == 70) { input.aim_pos.x += -43.9122; input.aim_pos.y += -21.6669; input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 71) { input.aim_pos.x += -45.7151; input.aim_pos.y += -19.9981; input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 72) { input.aim_pos.x += -46.2649; input.aim_pos.y += -19.664; input.action1 = true; input.left = true; input.facing_left = true; }
            if (tick == 73) { input.aim_pos.x += -47.8823; input.aim_pos.y += -20.6642; input.left = true; input.facing_left = true; }
            if (tick == 74) { input.aim_pos.x += -58.8077; input.aim_pos.y += -19.9978; input.left = true; input.facing_left = true; }
            if (tick == 75) { input.aim_pos.x += -58.2376; input.aim_pos.y += -19.998; input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 76) { input.aim_pos.x += -56.7488; input.aim_pos.y += -20.3317; input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 77) { input.aim_pos.x += -55.9263; input.aim_pos.y += -20.9987; input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 78) { input.aim_pos.x += -54.8897; input.aim_pos.y += -20.999; input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 79) { input.aim_pos.x += -52.6983; input.aim_pos.y += -19.3324; input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 80) { input.aim_pos.x += -50.6616; input.aim_pos.y += -18.3325; input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 81) { input.aim_pos.x += -49.114; input.aim_pos.y += -18.3326; input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 82) { input.aim_pos.x += -48.6614; input.aim_pos.y += -18.3541; input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 83) { input.aim_pos.x += -48.4402; input.aim_pos.y += -18.3576; input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 84) { input.aim_pos.x += -48.3185; input.aim_pos.y += -18.3516; input.action2 = true; input.facing_left = true; }
            if (tick == 85) { input.aim_pos.x += -48.7043; input.aim_pos.y += -18.3429; input.action2 = true; input.facing_left = true; }
            if (tick == 86) { input.aim_pos.x += -49.481; input.aim_pos.y += -18.3365; input.action2 = true; input.facing_left = true; }
            if (tick == 87) { input.aim_pos.x += -49.5932; input.aim_pos.y += -18.3328; input.action2 = true; input.facing_left = true; }
            if (tick == 88) { input.aim_pos.x += -50.291; input.aim_pos.y += -18.3304; input.action2 = true; input.facing_left = true; }
            if (tick == 89) { input.aim_pos.x += -50.9895; input.aim_pos.y += -18.3289; input.action2 = true; input.facing_left = true; }
            if (tick == 90) { input.aim_pos.x += -51.3603; input.aim_pos.y += -18.328; input.action2 = true; input.facing_left = true; }
            if (tick == 91) { input.aim_pos.x += -51.6799; input.aim_pos.y += -18.3276; input.action2 = true; input.facing_left = true; }
            if (tick == 92) { input.aim_pos.x += -52.034; input.aim_pos.y += -18.3277; input.action2 = true; input.facing_left = true; }
            if (tick == 93) { input.aim_pos.x += -52.3283; input.aim_pos.y += -18.3281; input.action2 = true; input.facing_left = true; }
            if (tick == 94) { input.aim_pos.x += -52.4504; input.aim_pos.y += -18.328; input.action2 = true; input.facing_left = true; }
            if (tick == 95) { input.aim_pos.x += -52.5931; input.aim_pos.y += -18.3284; input.action2 = true; input.facing_left = true; }
            if (tick == 96) { input.aim_pos.x += -52.7633; input.aim_pos.y += -18.3291; input.action2 = true; input.facing_left = true; }
            if (tick == 97) { input.aim_pos.x += -52.8536; input.aim_pos.y += -18.3294; input.action2 = true; input.facing_left = true; }
            if (tick == 98) { input.aim_pos.x += -52.9309; input.aim_pos.y += -18.3297; input.action2 = true; input.facing_left = true; }
            if (tick == 99) { input.aim_pos.x += -53.0029; input.aim_pos.y += -18.3301; input.action2 = true; input.facing_left = true; }
            if (tick == 100) { input.aim_pos.x += -53.0568; input.aim_pos.y += -18.3305; input.action2 = true; input.facing_left = true; }
            if (tick == 101) { input.aim_pos.x += -53.1021; input.aim_pos.y += -18.3308; input.action2 = true; input.facing_left = true; }
            if (tick == 102) { input.aim_pos.x += -53.1443; input.aim_pos.y += -18.3312; input.action2 = true; input.facing_left = true; }
            if (tick == 103) { input.aim_pos.x += -53.1684; input.aim_pos.y += -18.3314; input.action2 = true; input.facing_left = true; }
            if (tick == 104) { input.aim_pos.x += -53.1933; input.aim_pos.y += -18.3317; input.action2 = true; input.facing_left = true; }
            if (tick == 105) { input.aim_pos.x += -53.2147; input.aim_pos.y += -18.3319; input.action2 = true; input.facing_left = true; }
            if (tick == 106) { input.aim_pos.x += -53.2355; input.aim_pos.y += -18.3322; input.action2 = true; input.facing_left = true; }
            if (tick == 107) { input.aim_pos.x += -53.2507; input.aim_pos.y += -18.3324; input.action2 = true; input.facing_left = true; }
            if (tick == 108) { input.aim_pos.x += -53.2652; input.aim_pos.y += -18.3325; input.action2 = true; input.facing_left = true; }
            if (tick == 109) { input.aim_pos.x += -53.2786; input.aim_pos.y += -18.3326; input.action2 = true; input.facing_left = true; }
            if (tick == 110) { input.aim_pos.x += -53.2893; input.aim_pos.y += -18.3328; input.action2 = true; input.facing_left = true; }
            if (tick == 111) { input.aim_pos.x += -53.2994; input.aim_pos.y += -18.3329; input.action2 = true; input.facing_left = true; }
            if (tick == 112) { input.aim_pos.x += -53.3039; input.aim_pos.y += -18.333; input.action2 = true; input.facing_left = true; }
            if (tick == 113) { input.aim_pos.x += -53.3112; input.aim_pos.y += -18.333; input.action2 = true; input.facing_left = true; }
            if (tick == 114) { input.aim_pos.x += -53.3161; input.aim_pos.y += -18.333; input.action2 = true; input.facing_left = true; }
            if (tick == 115) { input.aim_pos.x += -53.3202; input.aim_pos.y += -18.333; input.action2 = true; input.facing_left = true; }
            if (tick == 116) { input.aim_pos.x += -53.3223; input.aim_pos.y += -18.333; input.action2 = true; input.facing_left = true; }
            if (tick == 117) { input.aim_pos.x += -53.3241; input.aim_pos.y += -18.333; input.action2 = true; input.facing_left = true; }
            if (tick == 118) { input.aim_pos.x += -53.3253; input.aim_pos.y += -18.333; input.action2 = true; input.facing_left = true; }
            if (tick == 119) { input.aim_pos.x += -53.3268; input.aim_pos.y += -18.333; input.action2 = true; input.facing_left = true; }
            if (tick == 120) { input.aim_pos.x += -53.3278; input.aim_pos.y += -18.333; input.action2 = true; input.facing_left = true; }
            if (tick == 121) { input.aim_pos.x += -53.3289; input.aim_pos.y += -18.333; input.action2 = true; input.facing_left = true; }
            if (tick == 122) { input.aim_pos.x += -53.3298; input.aim_pos.y += -18.333; input.action2 = true; input.facing_left = true; }
            if (tick == 123) { input.aim_pos.x += -53.3304; input.aim_pos.y += -18.333; input.action2 = true; input.facing_left = true; }
            if (tick == 124) { input.aim_pos.x += -53.3308; input.aim_pos.y += -18.333; input.action2 = true; input.facing_left = true; }
            if (tick == 125) { input.aim_pos.x += -53.3312; input.aim_pos.y += -18.333; input.action2 = true; input.facing_left = true; }
            if (tick == 126) { input.aim_pos.x += -53.3317; input.aim_pos.y += -18.333; input.action2 = true; input.facing_left = true; }
            if (tick == 127) { input.aim_pos.x += -53.3319; input.aim_pos.y += -18.333; input.action2 = true; input.facing_left = true; }
            if (tick == 128) { input.aim_pos.x += -53.3323; input.aim_pos.y += -18.3329; input.facing_left = true; }
            if (tick == 129) { input.aim_pos.x += -53.3325; input.aim_pos.y += -18.3329; input.facing_left = true; }
            if (tick == 130) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.3329; input.facing_left = true; }
            if (tick == 131) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.333; input.facing_left = true; }
            if (tick == 132) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.333; input.facing_left = true; }
            if (tick == 133) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.333; input.facing_left = true; }
            if (tick == 134) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.333; input.facing_left = true; }
            if (tick == 135) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.6663; input.facing_left = true; }
            if (tick == 136) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.6663; input.facing_left = true; }
            if (tick == 137) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.6663; input.facing_left = true; }
            if (tick == 138) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9996; input.facing_left = true; }
            if (tick == 139) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 140) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9996; input.facing_left = true; }
            if (tick == 141) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 142) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 143) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 144) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 145) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 146) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 147) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 148) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 149) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 150) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 151) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 152) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 153) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 154) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 155) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 156) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 157) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 158) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 159) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 160) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 161) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 162) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 163) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 164) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 165) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 166) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 167) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 168) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 169) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 170) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 171) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 172) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 173) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 174) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 175) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 176) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 177) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 178) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 179) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 180) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 181) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 182) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 183) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 184) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 185) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 186) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 187) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 188) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 189) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 190) { input.aim_pos.x += -53.3327; input.aim_pos.y += -18.9997; input.facing_left = true; }
            if (tick == 191) { input.aim_pos.x += -53.3328; input.aim_pos.y += -19.333; input.facing_left = true; }
            if (tick == 192) { input.aim_pos.x += -53.3328; input.aim_pos.y += -19.333; input.facing_left = true; }
            if (tick == 193) { input.aim_pos.x += -53.3328; input.aim_pos.y += -19.3331; input.facing_left = true; }
            if (tick == 194) { input.aim_pos.x += -53.3328; input.aim_pos.y += -19.3331; input.facing_left = true; }
            if (tick == 195) { input.aim_pos.x += -53.3328; input.aim_pos.y += -19.3331; input.facing_left = true; }
            if (tick == 196) { input.aim_pos.x += -53.3328; input.aim_pos.y += -19.3331; input.facing_left = true; }
            if (tick == 197) { input.aim_pos.x += -53.3328; input.aim_pos.y += -19.3331; input.facing_left = true; }
            if (tick == 198) { input.aim_pos.x += -53.3328; input.aim_pos.y += -19.3331; input.facing_left = true; }
            if (tick == 199) { input.aim_pos.x += -53.3328; input.aim_pos.y += -19.3331; input.facing_left = true; }
            if (tick == 200) { input.aim_pos.x += -53.3328; input.aim_pos.y += -19.3331; input.facing_left = true; }
            if (tick >= 201) { if (isServer() && bot !is null) KickPlayer(bot); }
            
        }
    } else if (selected_training == Training::crouch_jab_shieldslide) {
        if (frog) {
            if (tick == 0) { blob.setPosition(Vec2f(195.712,128.712)); blob.setVelocity(Vec2f_zero); input.aim_pos = blob.getPosition(); }
            if (tick == 0) {input.aim_pos.x += 35.6745; input.aim_pos.y += 29.6646; }
            if (tick == 1) {input.aim_pos.x += 35.6731; input.aim_pos.y += 29.6649; }
            if (tick == 2) {input.aim_pos.x += 35.6718; input.aim_pos.y += 29.6653; }
            if (tick == 3) {input.aim_pos.x += 35.6709; input.aim_pos.y += 29.6655; }
            if (tick == 4) {input.aim_pos.x += 35.6702; input.aim_pos.y += 29.6657; }
            if (tick == 5) {input.aim_pos.x += 35.6695; input.aim_pos.y += 29.6659; }
            if (tick == 6) {input.aim_pos.x += 35.669; input.aim_pos.y += 29.6661; }
            if (tick == 7) {input.aim_pos.x += 35.6686; input.aim_pos.y += 29.6662; }
            if (tick == 8) {input.aim_pos.x += 35.6682; input.aim_pos.y += 29.6663; }
            if (tick == 9) {input.aim_pos.x += 35.6679; input.aim_pos.y += 29.6664; input.right = true; }
            if (tick == 10) {input.aim_pos.x += 34.5429; input.aim_pos.y += 29.9997; input.right = true; }
            if (tick == 11) {input.aim_pos.x += 33.3232; input.aim_pos.y += 29.9998; input.right = true; }
            if (tick == 12) {input.aim_pos.x += 31.7674; input.aim_pos.y += 29.9998; input.right = true; }
            if (tick == 13) {input.aim_pos.x += 29.596; input.aim_pos.y += 31.3332; input.right = true; }
            if (tick == 14) {input.aim_pos.x += 26.481; input.aim_pos.y += 34.6665; input.right = true; }
            if (tick == 15) {input.aim_pos.x += 23.5849; input.aim_pos.y += 36.6665; input.right = true; }
            if (tick == 16) {input.aim_pos.x += 21.1367; input.aim_pos.y += 38.6665; input.right = true; }
            if (tick == 17) {input.aim_pos.x += 19.5103; input.aim_pos.y += 41.3332; input.right = true; }
            if (tick == 18) {input.aim_pos.x += 17.6549; input.aim_pos.y += 45.5653; input.action2 = true; input.right = true; }
            if (tick == 19) {input.aim_pos.x += 16.4507; input.aim_pos.y += 46.7294; input.action2 = true; input.right = true; }
            if (tick == 20) {input.aim_pos.x += 16.4027; input.aim_pos.y += 48.9069; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 21) {input.aim_pos.x += 16.5919; input.aim_pos.y += 50.4963; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 22) {input.aim_pos.x += 16.4456; input.aim_pos.y += 49.5673; input.action2 = true; input.right = true; }
            if (tick == 23) {input.aim_pos.x += 16.5108; input.aim_pos.y += 48.1752; input.action2 = true; input.right = true; }
            if (tick == 24) {input.aim_pos.x += 16.5928; input.aim_pos.y += 49.0711; input.action2 = true; input.right = true; }
            if (tick == 25) {input.aim_pos.x += 16.5726; input.aim_pos.y += 49.962; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 26) {input.aim_pos.x += 15.7793; input.aim_pos.y += 49.7296; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 27) {input.aim_pos.x += 15.0269; input.aim_pos.y += 47.9543; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 28) {input.aim_pos.x += 14.7061; input.aim_pos.y += 46.2488; input.action2 = true; input.right = true; }
            if (tick == 29) {input.aim_pos.x += 14.6136; input.aim_pos.y += 45.2619; input.action2 = true; input.right = true; }
            if (tick == 30) {input.aim_pos.x += 13.8168; input.aim_pos.y += 44.3385; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 31) {input.aim_pos.x += 13.7171; input.aim_pos.y += 43.3543; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 32) {input.aim_pos.x += 14.1112; input.aim_pos.y += 41.3902; input.action2 = true; input.right = true; }
            if (tick == 33) {input.aim_pos.x += 14.6532; input.aim_pos.y += 38.4072; input.action2 = true; input.right = true; }
            if (tick == 34) {input.aim_pos.x += 15.0431; input.aim_pos.y += 36.9701; input.action2 = true; input.right = true; }
            if (tick == 35) {input.aim_pos.x += 15.2252; input.aim_pos.y += 37.3049; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 36) {input.aim_pos.x += 14.6782; input.aim_pos.y += 37.5998; input.action2 = true; input.right = true; }
            if (tick == 37) {input.aim_pos.x += 14.2282; input.aim_pos.y += 37.3532; input.action2 = true; input.right = true; }
            if (tick == 38) {input.aim_pos.x += 13.7634; input.aim_pos.y += 37.1825; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 39) {input.aim_pos.x += 13.5121; input.aim_pos.y += 36.9973; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 40) {input.aim_pos.x += 12.3401; input.aim_pos.y += 37.4168; input.action2 = true; input.right = true; }
            if (tick == 41) {input.aim_pos.x += 11.6221; input.aim_pos.y += 37.3611; input.action2 = true; input.right = true; }
            if (tick == 42) {input.aim_pos.x += 10.5945; input.aim_pos.y += 36.8265; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 43) {input.aim_pos.x += 10.2458; input.aim_pos.y += 36.638; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 44) {input.aim_pos.x += 10.0624; input.aim_pos.y += 36.8099; input.action2 = true; input.right = true; }
            if (tick == 45) {input.aim_pos.x += 9.27985; input.aim_pos.y += 36.9482; input.action2 = true; input.right = true; }
            if (tick == 46) {input.aim_pos.x += 8.37683; input.aim_pos.y += 37.0469; input.action2 = true; input.right = true; }
            if (tick == 47) {input.aim_pos.x += 8.14523; input.aim_pos.y += 37.1258; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 48) {input.aim_pos.x += 7.44702; input.aim_pos.y += 37.4608; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 49) {input.aim_pos.x += 7.19025; input.aim_pos.y += 38.0621; input.action2 = true; input.right = true; }
            if (tick == 50) {input.aim_pos.x += 7.17761; input.aim_pos.y += 38.1564; input.action2 = true; input.right = true; }
            if (tick == 51) {input.aim_pos.x += 7.60907; input.aim_pos.y += 37.747; input.action2 = true; input.right = true; }
            if (tick == 52) {input.aim_pos.x += 8.38959; input.aim_pos.y += 36.9275; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 53) {input.aim_pos.x += 9.15381; input.aim_pos.y += 36.9344; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 54) {input.aim_pos.x += 8.90182; input.aim_pos.y += 36.9986; input.action2 = true; input.right = true; }
            if (tick == 55) {input.aim_pos.x += 8.1246; input.aim_pos.y += 37.0574; input.action2 = true; input.right = true; }
            if (tick == 56) {input.aim_pos.x += 8.22958; input.aim_pos.y += 37.1135; input.action2 = true; input.right = true; }
            if (tick == 57) {input.aim_pos.x += 8.48691; input.aim_pos.y += 37.1578; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 58) {input.aim_pos.x += 8.48755; input.aim_pos.y += 37.4879; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 59) {input.aim_pos.x += 8.69971; input.aim_pos.y += 38.0862; input.action2 = true; input.right = true; }
            if (tick == 60) {input.aim_pos.x += 9.06833; input.aim_pos.y += 38.1705; input.action2 = true; input.right = true; }
            if (tick == 61) {input.aim_pos.x += 9.81668; input.aim_pos.y += 37.7486; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 62) {input.aim_pos.x += 9.81958; input.aim_pos.y += 36.9512; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 63) {input.aim_pos.x += 10.5787; input.aim_pos.y += 36.2188; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 64) {input.aim_pos.x += 10.9916; input.aim_pos.y += 36.3466; input.action2 = true; input.right = true; }
            if (tick == 65) {input.aim_pos.x += 11.7515; input.aim_pos.y += 36.5262; input.action2 = true; input.right = true; }
            if (tick == 66) {input.aim_pos.x += 11.4395; input.aim_pos.y += 36.6599; input.action2 = true; input.right = true; }
            if (tick == 67) {input.aim_pos.x += 10.8908; input.aim_pos.y += 36.7546; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 68) {input.aim_pos.x += 10.5735; input.aim_pos.y += 37.0996; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 69) {input.aim_pos.x += 10.4963; input.aim_pos.y += 37.7077; input.action2 = true; input.right = true; }
            if (tick == 70) {input.aim_pos.x += 10.6419; input.aim_pos.y += 37.8009; input.action2 = true; input.right = true; }
            if (tick == 71) {input.aim_pos.x += 11.2866; input.aim_pos.y += 37.3877; input.action2 = true; input.right = true; }
            if (tick == 72) {input.aim_pos.x += 11.5587; input.aim_pos.y += 36.5805; input.action2 = true; input.right = true; }
            if (tick == 73) {input.aim_pos.x += 12.2498; input.aim_pos.y += 36.5971; input.action2 = true; input.right = true; }
            if (tick == 74) {input.aim_pos.x += 12.6252; input.aim_pos.y += 36.6783; input.action2 = true; input.right = true; }
            if (tick == 75) {input.aim_pos.x += 11.7761; input.aim_pos.y += 36.7395; input.action2 = true; }
            if (tick == 76) {input.aim_pos.x += 11.684; input.aim_pos.y += 36.7927; }
            if (tick == 77) {input.aim_pos.x += 11.5247; input.aim_pos.y += 36.4964; }
            if (tick == 78) {input.aim_pos.x += 12.2622; input.aim_pos.y += 36.1959; }
            if (tick == 79) {input.aim_pos.x += 14.7351; input.aim_pos.y += 36.2261; }
            if (tick == 80) {input.aim_pos.x += 17.3204; input.aim_pos.y += 36.2482; }
            if (tick == 81) {input.aim_pos.x += 19.7202; input.aim_pos.y += 36.2647; }
            if (tick == 82) {input.aim_pos.x += 22.0281; input.aim_pos.y += 36.278; }
            if (tick == 83) {input.aim_pos.x += 24.4857; input.aim_pos.y += 36.2902; }
            if (tick == 84) {input.aim_pos.x += 26.5739; input.aim_pos.y += 36.2997; }
            if (tick == 85) {input.aim_pos.x += 28.3031; input.aim_pos.y += 36.307; }
            if (tick == 86) {input.aim_pos.x += 29.626; input.aim_pos.y += 36.3125; }
            if (tick == 87) {input.aim_pos.x += 30.7129; input.aim_pos.y += 36.3167; }
            if (tick == 88) {input.aim_pos.x += 31.6034; input.aim_pos.y += 36.3202; }
            if (tick == 89) {input.aim_pos.x += 32.3862; input.aim_pos.y += 35.9897; }
            if (tick == 90) {input.aim_pos.x += 32.9305; input.aim_pos.y += 35.9917; }
            if (tick == 91) {input.aim_pos.x += 33.2785; input.aim_pos.y += 35.993; }
            if (tick == 92) {input.aim_pos.x += 33.725; input.aim_pos.y += 35.9945; }
            if (tick == 93) {input.aim_pos.x += 34.1106; input.aim_pos.y += 35.9957; }
            if (tick == 94) {input.aim_pos.x += 34.3962; input.aim_pos.y += 35.9966; }
            if (tick == 95) {input.aim_pos.x += 34.6456; input.aim_pos.y += 35.9973; }
            if (tick >= 96) { if (isServer() && bot !is null) KickPlayer(bot); }
        }
        if (tiger) {
            if (tick == 0) { blob.setPosition(Vec2f(286.82,136.3)); blob.setVelocity(Vec2f_zero); input.aim_pos = blob.getPosition(); }
            if (tick == 0) { input.aim_pos.x += -43.3342; input.aim_pos.y += -5.00027; input.facing_left = true; }
            if (tick == 1) { input.aim_pos.x += -43.3342; input.aim_pos.y += -5.00027; input.facing_left = true; }
            if (tick == 2) { input.aim_pos.x += -43.3342; input.aim_pos.y += -5.00027; input.facing_left = true; }
            if (tick == 3) { input.aim_pos.x += -43.3342; input.aim_pos.y += -5.00027; input.facing_left = true; }
            if (tick == 4) { input.aim_pos.x += -43.3342; input.aim_pos.y += -5.00027; input.facing_left = true; }
            if (tick == 5) { input.aim_pos.x += -43.3342; input.aim_pos.y += -5.00027; input.facing_left = true; }
            if (tick == 6) { input.aim_pos.x += -43.3342; input.aim_pos.y += -5.00027; input.facing_left = true; }
            if (tick == 7) { input.aim_pos.x += -43.3342; input.aim_pos.y += -5.00027; input.facing_left = true; }
            if (tick == 8) { input.aim_pos.x += -43.3342; input.aim_pos.y += -5.00027; input.facing_left = true; }
            if (tick == 9) { input.aim_pos.x += -43.3342; input.aim_pos.y += -5.00027; input.facing_left = true; }
            if (tick == 10) { input.aim_pos.x += -43.3342; input.aim_pos.y += -5.00027; input.facing_left = true; }
            if (tick == 11) { input.aim_pos.x += -43.3342; input.aim_pos.y += -5.00027; input.facing_left = true; }
            if (tick == 12) { input.aim_pos.x += -43.3342; input.aim_pos.y += -5.00027; input.facing_left = true; }
            if (tick == 13) { input.aim_pos.x += -43.3342; input.aim_pos.y += -5.00027; input.facing_left = true; }
            if (tick == 14) { input.aim_pos.x += -43.3342; input.aim_pos.y += -5.00027; input.facing_left = true; }
            if (tick == 15) { input.aim_pos.x += -43.3342; input.aim_pos.y += -5.00027; input.facing_left = true; }
            if (tick == 16) { input.aim_pos.x += -43.3342; input.aim_pos.y += -5.00027; input.facing_left = true; }
            if (tick == 17) { input.aim_pos.x += -43.3342; input.aim_pos.y += -5.00027; input.facing_left = true; }
            if (tick == 18) { input.aim_pos.x += -43.3342; input.aim_pos.y += -5.00027; input.facing_left = true; }
            if (tick == 19) { input.aim_pos.x += -43.3342; input.aim_pos.y += -5.00027; input.facing_left = true; }
            if (tick == 20) { input.aim_pos.x += -43.3342; input.aim_pos.y += -5.00027; input.facing_left = true; }
            if (tick == 21) { input.aim_pos.x += -43.3342; input.aim_pos.y += -5.00027; input.facing_left = true; }
            if (tick == 22) { input.aim_pos.x += -43.3342; input.aim_pos.y += -5.00027; input.facing_left = true; }
            if (tick == 23) { input.aim_pos.x += -43.3342; input.aim_pos.y += -5.00027; input.facing_left = true; }
            if (tick == 24) { input.aim_pos.x += -43.3342; input.aim_pos.y += -5.00027; input.down = true; input.facing_left = true; }
            if (tick == 25) { input.aim_pos.x += -43.3342; input.aim_pos.y += -5.00027; input.down = true; input.facing_left = true; }
            if (tick == 26) { input.aim_pos.x += -43.3342; input.aim_pos.y += -5.00027; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 27) { input.aim_pos.x += -43.3342; input.aim_pos.y += -5.00027; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 28) { input.aim_pos.x += -43.3342; input.aim_pos.y += -5.00027; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 29) { input.aim_pos.x += -43.3342; input.aim_pos.y += -5.00027; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 30) { input.aim_pos.x += -43.3342; input.aim_pos.y += -5.00027; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 31) { input.aim_pos.x += -43.3342; input.aim_pos.y += -5.00027; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 32) { input.aim_pos.x += -43.3342; input.aim_pos.y += -5.00027; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 33) { input.aim_pos.x += -43.3342; input.aim_pos.y += -5.00027; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 34) { input.aim_pos.x += -43.3342; input.aim_pos.y += -5.00027; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 35) { input.aim_pos.x += -43.3342; input.aim_pos.y += -5.00027; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 36) { input.aim_pos.x += -40.6675; input.aim_pos.y += -5.33362; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 37) { input.aim_pos.x += -19.6675; input.aim_pos.y += -7.3336; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 38) { input.aim_pos.x += 19.3325; input.aim_pos.y += -11.0003; input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 39) { input.aim_pos.x += 69.9992; input.aim_pos.y += -12.6669; input.action2 = true; input.down = true; }
            if (tick == 40) { input.aim_pos.x += 147.666; input.aim_pos.y += -17.0003; input.action1 = true; input.down = true; }
            if (tick == 41) { input.aim_pos.x += 203.332; input.aim_pos.y += -27.6669; }
            if (tick == 42) { input.aim_pos.x += 221.666; input.aim_pos.y += -37.0003; }
            if (tick == 43) { input.aim_pos.x += 222.999; input.aim_pos.y += -38.6669; }
            if (tick == 44) { input.aim_pos.x += 222.999; input.aim_pos.y += -38.6669; }
            if (tick == 45) { input.aim_pos.x += 220.666; input.aim_pos.y += -37.6669; input.action2 = true; }
            if (tick == 46) { input.aim_pos.x += 220.666; input.aim_pos.y += -37.3336; input.action2 = true; }
            if (tick == 47) { input.aim_pos.x += 219.999; input.aim_pos.y += -36.6669; input.action2 = true; }
            if (tick == 48) { input.aim_pos.x += 219.666; input.aim_pos.y += -36.3336; input.action2 = true; }
            if (tick == 49) { input.aim_pos.x += 218.999; input.aim_pos.y += -35.6669; input.action2 = true; }
            if (tick == 50) { input.aim_pos.x += 217.666; input.aim_pos.y += -34.3336; input.action2 = true; }
            if (tick == 51) { input.aim_pos.x += 214.999; input.aim_pos.y += -33.0003; input.action2 = true; }
            if (tick == 52) { input.aim_pos.x += 211.999; input.aim_pos.y += -31.3336; input.action2 = true; }
            if (tick == 53) { input.aim_pos.x += 208.999; input.aim_pos.y += -30.0003; input.action2 = true; }
            if (tick == 54) { input.aim_pos.x += 206.999; input.aim_pos.y += -29.3336; input.action2 = true; }
            if (tick == 55) { input.aim_pos.x += 202.333; input.aim_pos.y += -27.6669; input.action2 = true; }
            if (tick == 56) { input.aim_pos.x += 193.332; input.aim_pos.y += -26.3336; input.action2 = true; }
            if (tick == 57) { input.aim_pos.x += 181.666; input.aim_pos.y += -23.6669; input.action2 = true; }
            if (tick == 58) { input.aim_pos.x += 166.666; input.aim_pos.y += -20.6669; input.action2 = true; }
            if (tick == 59) { input.aim_pos.x += 147.999; input.aim_pos.y += -18.0003; input.action2 = true; }
            if (tick == 60) { input.aim_pos.x += 128.332; input.aim_pos.y += -16.3336; input.action2 = true; }
            if (tick == 61) { input.aim_pos.x += 111.999; input.aim_pos.y += -15.6669; input.action2 = true; }
            if (tick == 62) { input.aim_pos.x += 100.999; input.aim_pos.y += -15.3336; }
            if (tick == 63) { input.aim_pos.x += 84.9992; input.aim_pos.y += -13.6669; }
            if (tick == 64) { input.aim_pos.x += 71.6659; input.aim_pos.y += -12.3336; }
            if (tick == 65) { input.aim_pos.x += 68.6658; input.aim_pos.y += -11.3336; }
            if (tick == 66) { input.aim_pos.x += 68.3325; input.aim_pos.y += -11.3336; }
            if (tick == 67) { input.aim_pos.x += 64.3326; input.aim_pos.y += -10.0003; }
            if (tick == 68) { input.aim_pos.x += 54.3326; input.aim_pos.y += -7.66695; }
            if (tick == 69) { input.aim_pos.x += 48.3325; input.aim_pos.y += -7.00027; }
            if (tick == 70) { input.aim_pos.x += 31.9992; input.aim_pos.y += -5.00027; }
            if (tick == 71) { input.aim_pos.x += 17.3326; input.aim_pos.y += -4.00027; }
            if (tick == 72) { input.aim_pos.x += 13.9992; input.aim_pos.y += -3.66695; }
            if (tick == 73) { input.aim_pos.x += 11.6659; input.aim_pos.y += -3.00027; }
            if (tick == 74) { input.aim_pos.x += 9.66586; input.aim_pos.y += -2.66693; }
            if (tick == 75) { input.aim_pos.x += 9.66586; input.aim_pos.y += -2.66693; }
            if (tick == 76) { input.aim_pos.x += 9.66586; input.aim_pos.y += -2.66693; }
            if (tick == 77) { input.aim_pos.x += 9.66586; input.aim_pos.y += -2.66693; }
            if (tick == 78) { input.aim_pos.x += 9.66586; input.aim_pos.y += -2.66693; }
            if (tick == 79) { input.aim_pos.x += 9.66586; input.aim_pos.y += -2.66693; }
            if (tick == 80) { input.aim_pos.x += 9.66586; input.aim_pos.y += -2.66693; }
            if (tick == 81) { input.aim_pos.x += 9.66586; input.aim_pos.y += -2.66693; }
            if (tick == 82) { input.aim_pos.x += 9.66586; input.aim_pos.y += -2.66693; }
            if (tick == 83) { input.aim_pos.x += 9.66586; input.aim_pos.y += -2.66693; }
            if (tick == 84) { input.aim_pos.x += 9.66586; input.aim_pos.y += -2.66693; }
            if (tick == 85) { input.aim_pos.x += 9.66586; input.aim_pos.y += -2.66693; }
            if (tick == 86) { input.aim_pos.x += 9.66586; input.aim_pos.y += -2.66693; }
            if (tick == 87) { input.aim_pos.x += 9.66586; input.aim_pos.y += -2.66693; }
            if (tick == 88) { input.aim_pos.x += 9.66586; input.aim_pos.y += -2.66693; }
            if (tick == 89) { input.aim_pos.x += 9.66586; input.aim_pos.y += -2.66693; }
            if (tick == 90) { input.aim_pos.x += 9.66586; input.aim_pos.y += -2.66693; }
            if (tick == 91) { input.aim_pos.x += 9.66586; input.aim_pos.y += -2.66693; }
            if (tick == 92) { input.aim_pos.x += 9.66586; input.aim_pos.y += -2.66693; }
            if (tick == 93) { input.aim_pos.x += 9.66586; input.aim_pos.y += -2.66693; }
            if (tick == 94) { input.aim_pos.x += 9.66586; input.aim_pos.y += -2.66693; }
            if (tick == 95) { input.aim_pos.x += 9.66586; input.aim_pos.y += -2.66693; }
            if (tick == 96) { input.aim_pos.x += 9.66586; input.aim_pos.y += -2.66693; }
            if (tick == 97) { input.aim_pos.x += 9.66586; input.aim_pos.y += -2.66693; }
            if (tick == 98) { input.aim_pos.x += 9.66586; input.aim_pos.y += -2.66693; }
            if (tick == 99) { input.aim_pos.x += 9.66586; input.aim_pos.y += -2.66693; }
            if (tick == 100) { input.aim_pos.x += 9.66586; input.aim_pos.y += -2.66693; }
            if (tick == 101) { input.aim_pos.x += 9.66586; input.aim_pos.y += -2.66693; }
            if (tick == 102) { input.aim_pos.x += 9.66586; input.aim_pos.y += -2.66693; }
            if (tick == 103) { input.aim_pos.x += 9.66586; input.aim_pos.y += -2.66693; }
            if (tick == 104) { input.aim_pos.x += 9.66586; input.aim_pos.y += -2.66693; }
            if (tick == 105) { input.aim_pos.x += 9.66586; input.aim_pos.y += -2.66693; }
            if (tick == 106) { input.aim_pos.x += 9.66586; input.aim_pos.y += -2.66693; }
            if (tick == 107) { input.aim_pos.x += 9.66586; input.aim_pos.y += -2.66693; }
            if (tick == 108) { input.aim_pos.x += 9.66586; input.aim_pos.y += -2.66693; }
            if (tick == 109) { input.aim_pos.x += 9.66586; input.aim_pos.y += -2.66693; }
            if (tick == 110) { input.aim_pos.x += 9.66586; input.aim_pos.y += -2.66693; }
            if (tick >= 111) { if (isServer() && bot !is null) KickPlayer(bot); }
        }
    } else if (selected_training == Training::overhead_slash_shieldslide) {
        if (frog) {
            if (tick == 0) { blob.setPosition(Vec2f(195.712,128.712)); blob.setVelocity(Vec2f_zero); input.aim_pos = blob.getPosition(); }
            if (tick == 0) {input.aim_pos.x += 35.6745; input.aim_pos.y += 29.6646; }
            if (tick == 1) {input.aim_pos.x += 35.6731; input.aim_pos.y += 29.6649; }
            if (tick == 2) {input.aim_pos.x += 35.6718; input.aim_pos.y += 29.6653; }
            if (tick == 3) {input.aim_pos.x += 35.6709; input.aim_pos.y += 29.6655; }
            if (tick == 4) {input.aim_pos.x += 35.6702; input.aim_pos.y += 29.6657; }
            if (tick == 5) {input.aim_pos.x += 35.6695; input.aim_pos.y += 29.6659; }
            if (tick == 6) {input.aim_pos.x += 35.669; input.aim_pos.y += 29.6661; }
            if (tick == 7) {input.aim_pos.x += 35.6686; input.aim_pos.y += 29.6662; }
            if (tick == 8) {input.aim_pos.x += 35.6682; input.aim_pos.y += 29.6663; }
            if (tick == 9) {input.aim_pos.x += 35.6679; input.aim_pos.y += 29.6664; input.right = true; }
            if (tick == 10) {input.aim_pos.x += 34.5429; input.aim_pos.y += 29.9997; input.right = true; }
            if (tick == 11) {input.aim_pos.x += 33.3232; input.aim_pos.y += 29.9998; input.right = true; }
            if (tick == 12) {input.aim_pos.x += 31.7674; input.aim_pos.y += 29.9998; input.right = true; }
            if (tick == 13) {input.aim_pos.x += 29.596; input.aim_pos.y += 31.3332; input.right = true; }
            if (tick == 14) {input.aim_pos.x += 26.481; input.aim_pos.y += 34.6665; input.right = true; }
            if (tick == 15) {input.aim_pos.x += 23.5849; input.aim_pos.y += 36.6665; input.right = true; }
            if (tick == 16) {input.aim_pos.x += 21.1367; input.aim_pos.y += 38.6665; input.right = true; }
            if (tick == 17) {input.aim_pos.x += 19.5103; input.aim_pos.y += 41.3332; input.right = true; }
            if (tick == 18) {input.aim_pos.x += 17.6549; input.aim_pos.y += 45.5653; input.action2 = true; input.right = true; }
            if (tick == 19) {input.aim_pos.x += 16.4507; input.aim_pos.y += 46.7294; input.action2 = true; input.right = true; }
            if (tick == 20) {input.aim_pos.x += 16.4027; input.aim_pos.y += 48.9069; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 21) {input.aim_pos.x += 16.5919; input.aim_pos.y += 50.4963; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 22) {input.aim_pos.x += 16.4456; input.aim_pos.y += 49.5673; input.action2 = true; input.right = true; }
            if (tick == 23) {input.aim_pos.x += 16.5108; input.aim_pos.y += 48.1752; input.action2 = true; input.right = true; }
            if (tick == 24) {input.aim_pos.x += 16.5928; input.aim_pos.y += 49.0711; input.action2 = true; input.right = true; }
            if (tick == 25) {input.aim_pos.x += 16.5726; input.aim_pos.y += 49.962; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 26) {input.aim_pos.x += 15.7793; input.aim_pos.y += 49.7296; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 27) {input.aim_pos.x += 15.0269; input.aim_pos.y += 47.9543; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 28) {input.aim_pos.x += 14.7061; input.aim_pos.y += 46.2488; input.action2 = true; input.right = true; }
            if (tick == 29) {input.aim_pos.x += 14.6136; input.aim_pos.y += 45.2619; input.action2 = true; input.right = true; }
            if (tick == 30) {input.aim_pos.x += 13.8168; input.aim_pos.y += 44.3385; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 31) {input.aim_pos.x += 13.7171; input.aim_pos.y += 43.3543; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 32) {input.aim_pos.x += 14.1112; input.aim_pos.y += 41.3902; input.action2 = true; input.right = true; }
            if (tick == 33) {input.aim_pos.x += 14.6532; input.aim_pos.y += 38.4072; input.action2 = true; input.right = true; }
            if (tick == 34) {input.aim_pos.x += 15.0431; input.aim_pos.y += 36.9701; input.action2 = true; input.right = true; }
            if (tick == 35) {input.aim_pos.x += 15.2252; input.aim_pos.y += 37.3049; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 36) {input.aim_pos.x += 14.6782; input.aim_pos.y += 37.5998; input.action2 = true; input.right = true; }
            if (tick == 37) {input.aim_pos.x += 14.2282; input.aim_pos.y += 37.3532; input.action2 = true; input.right = true; }
            if (tick == 38) {input.aim_pos.x += 13.7634; input.aim_pos.y += 37.1825; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 39) {input.aim_pos.x += 13.5121; input.aim_pos.y += 36.9973; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 40) {input.aim_pos.x += 12.3401; input.aim_pos.y += 37.4168; input.action2 = true; input.right = true; }
            if (tick == 41) {input.aim_pos.x += 11.6221; input.aim_pos.y += 37.3611; input.action2 = true; input.right = true; }
            if (tick == 42) {input.aim_pos.x += 10.5945; input.aim_pos.y += 36.8265; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 43) {input.aim_pos.x += 10.2458; input.aim_pos.y += 36.638; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 44) {input.aim_pos.x += 10.0624; input.aim_pos.y += 36.8099; input.action2 = true; input.right = true; }
            if (tick == 45) {input.aim_pos.x += 9.27985; input.aim_pos.y += 36.9482; input.action2 = true; input.right = true; }
            if (tick == 46) {input.aim_pos.x += 8.37683; input.aim_pos.y += 37.0469; input.action2 = true; input.right = true; }
            if (tick == 47) {input.aim_pos.x += 8.14523; input.aim_pos.y += 37.1258; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 48) {input.aim_pos.x += 7.44702; input.aim_pos.y += 37.4608; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 49) {input.aim_pos.x += 7.19025; input.aim_pos.y += 38.0621; input.action2 = true; input.right = true; }
            if (tick == 50) {input.aim_pos.x += 7.17761; input.aim_pos.y += 38.1564; input.action2 = true; input.right = true; }
            if (tick == 51) {input.aim_pos.x += 7.60907; input.aim_pos.y += 37.747; input.action2 = true; input.right = true; }
            if (tick == 52) {input.aim_pos.x += 8.38959; input.aim_pos.y += 36.9275; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 53) {input.aim_pos.x += 9.15381; input.aim_pos.y += 36.9344; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 54) {input.aim_pos.x += 8.90182; input.aim_pos.y += 36.9986; input.action2 = true; input.right = true; }
            if (tick == 55) {input.aim_pos.x += 8.1246; input.aim_pos.y += 37.0574; input.action2 = true; input.right = true; }
            if (tick == 56) {input.aim_pos.x += 8.22958; input.aim_pos.y += 37.1135; input.action2 = true; input.right = true; }
            if (tick == 57) {input.aim_pos.x += 8.48691; input.aim_pos.y += 37.1578; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 58) {input.aim_pos.x += 8.48755; input.aim_pos.y += 37.4879; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 59) {input.aim_pos.x += 8.69971; input.aim_pos.y += 38.0862; input.action2 = true; input.right = true; }
            if (tick == 60) {input.aim_pos.x += 9.06833; input.aim_pos.y += 38.1705; input.action2 = true; input.right = true; }
            if (tick == 61) {input.aim_pos.x += 9.81668; input.aim_pos.y += 37.7486; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 62) {input.aim_pos.x += 9.81958; input.aim_pos.y += 36.9512; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 63) {input.aim_pos.x += 10.5787; input.aim_pos.y += 36.2188; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 64) {input.aim_pos.x += 10.9916; input.aim_pos.y += 36.3466; input.action2 = true; input.right = true; }
            if (tick == 65) {input.aim_pos.x += 11.7515; input.aim_pos.y += 36.5262; input.action2 = true; input.right = true; }
            if (tick == 66) {input.aim_pos.x += 11.4395; input.aim_pos.y += 36.6599; input.action2 = true; input.right = true; }
            if (tick == 67) {input.aim_pos.x += 10.8908; input.aim_pos.y += 36.7546; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 68) {input.aim_pos.x += 10.5735; input.aim_pos.y += 37.0996; input.action2 = true; input.right = true; input.up = true; }
            if (tick == 69) {input.aim_pos.x += 10.4963; input.aim_pos.y += 37.7077; input.action2 = true; input.right = true; }
            if (tick == 70) {input.aim_pos.x += 10.6419; input.aim_pos.y += 37.8009; input.action2 = true; input.right = true; }
            if (tick == 71) {input.aim_pos.x += 11.2866; input.aim_pos.y += 37.3877; input.action2 = true; input.right = true; }
            if (tick == 72) {input.aim_pos.x += 11.5587; input.aim_pos.y += 36.5805; input.action2 = true; input.right = true; }
            if (tick == 73) {input.aim_pos.x += 12.2498; input.aim_pos.y += 36.5971; input.action2 = true; input.right = true; }
            if (tick == 74) {input.aim_pos.x += 12.6252; input.aim_pos.y += 36.6783; input.action2 = true; input.right = true; }
            if (tick == 75) {input.aim_pos.x += 11.7761; input.aim_pos.y += 36.7395; input.action2 = true; }
            if (tick == 76) {input.aim_pos.x += 11.684; input.aim_pos.y += 36.7927; }
            if (tick == 77) {input.aim_pos.x += 11.5247; input.aim_pos.y += 36.4964; }
            if (tick == 78) {input.aim_pos.x += 12.2622; input.aim_pos.y += 36.1959; }
            if (tick == 79) {input.aim_pos.x += 14.7351; input.aim_pos.y += 36.2261; }
            if (tick == 80) {input.aim_pos.x += 17.3204; input.aim_pos.y += 36.2482; }
            if (tick == 81) {input.aim_pos.x += 19.7202; input.aim_pos.y += 36.2647; }
            if (tick == 82) {input.aim_pos.x += 22.0281; input.aim_pos.y += 36.278; }
            if (tick == 83) {input.aim_pos.x += 24.4857; input.aim_pos.y += 36.2902; }
            if (tick == 84) {input.aim_pos.x += 26.5739; input.aim_pos.y += 36.2997; }
            if (tick == 85) {input.aim_pos.x += 28.3031; input.aim_pos.y += 36.307; }
            if (tick == 86) {input.aim_pos.x += 29.626; input.aim_pos.y += 36.3125; }
            if (tick == 87) {input.aim_pos.x += 30.7129; input.aim_pos.y += 36.3167; }
            if (tick == 88) {input.aim_pos.x += 31.6034; input.aim_pos.y += 36.3202; }
            if (tick == 89) {input.aim_pos.x += 32.3862; input.aim_pos.y += 35.9897; }
            if (tick == 90) {input.aim_pos.x += 32.9305; input.aim_pos.y += 35.9917; }
            if (tick == 91) {input.aim_pos.x += 33.2785; input.aim_pos.y += 35.993; }
            if (tick == 92) {input.aim_pos.x += 33.725; input.aim_pos.y += 35.9945; }
            if (tick == 93) {input.aim_pos.x += 34.1106; input.aim_pos.y += 35.9957; }
            if (tick == 94) {input.aim_pos.x += 34.3962; input.aim_pos.y += 35.9966; }
            if (tick == 95) {input.aim_pos.x += 34.6456; input.aim_pos.y += 35.9973; }
            if (tick >= 96) { if (isServer() && bot !is null) KickPlayer(bot); }
        } else if (tiger) {
            if (tick == 0) { blob.setPosition(Vec2f(293.141,136.3)); blob.setVelocity(Vec2f_zero); input.aim_pos = blob.getPosition(); }
            if (tick == 0) { input.aim_pos.x += -69.7403; input.aim_pos.y += -17.3336; input.facing_left = true; }
            if (tick == 1) { input.aim_pos.x += -70.1385; input.aim_pos.y += -17.3336; input.facing_left = true; }
            if (tick == 2) { input.aim_pos.x += -70.1759; input.aim_pos.y += -17.3336; input.facing_left = true; }
            if (tick == 3) { input.aim_pos.x += -70.4137; input.aim_pos.y += -17.3336; input.facing_left = true; }
            if (tick == 4) { input.aim_pos.x += -70.6132; input.aim_pos.y += -17.3336; input.facing_left = true; }
            if (tick == 5) { input.aim_pos.x += -70.8044; input.aim_pos.y += -17.3336; input.facing_left = true; }
            if (tick == 6) { input.aim_pos.x += -70.9436; input.aim_pos.y += -17.3336; input.facing_left = true; }
            if (tick == 7) { input.aim_pos.x += -71.0755; input.aim_pos.y += -17.3336; input.facing_left = true; }
            if (tick == 8) { input.aim_pos.x += -71.1717; input.aim_pos.y += -17.3336; input.facing_left = true; }
            if (tick == 9) { input.aim_pos.x += -71.2719; input.aim_pos.y += -17.3336; input.action1 = true; input.facing_left = true; }
            if (tick == 10) { input.aim_pos.x += -71.3357; input.aim_pos.y += -17.3336; input.action1 = true; input.facing_left = true; }
            if (tick == 11) { input.aim_pos.x += -71.4153; input.aim_pos.y += -17.3336; input.action1 = true; input.facing_left = true; }
            if (tick == 12) { input.aim_pos.x += -71.1363; input.aim_pos.y += -17.0003; input.action1 = true; input.facing_left = true; }
            if (tick == 13) { input.aim_pos.x += -69.8484; input.aim_pos.y += -14.667; input.action1 = true; input.facing_left = true; }
            if (tick == 14) { input.aim_pos.x += -69.5492; input.aim_pos.y += -13.0003; input.action1 = true; input.facing_left = true; }
            if (tick == 15) { input.aim_pos.x += -69.2418; input.aim_pos.y += -11.3336; input.action1 = true; input.facing_left = true; }
            if (tick == 16) { input.aim_pos.x += -69.2553; input.aim_pos.y += -10.3336; input.action1 = true; input.facing_left = true; }
            if (tick == 17) { input.aim_pos.x += -68.9321; input.aim_pos.y += -9.33363; input.action1 = true; input.facing_left = true; }
            if (tick == 18) { input.aim_pos.x += -68.9425; input.aim_pos.y += -8.33363; input.action1 = true; input.facing_left = true; }
            if (tick == 19) { input.aim_pos.x += -68.9515; input.aim_pos.y += -8.00029; input.action1 = true; input.facing_left = true; }
            if (tick == 20) { input.aim_pos.x += -68.961; input.aim_pos.y += -7.33362; input.action1 = true; input.facing_left = true; }
            if (tick == 21) { input.aim_pos.x += -68.9679; input.aim_pos.y += -7.00029; input.action1 = true; input.facing_left = true; }
            if (tick == 22) { input.aim_pos.x += -68.9735; input.aim_pos.y += -7.00029; input.action1 = true; input.facing_left = true; }
            if (tick == 23) { input.aim_pos.x += -68.9782; input.aim_pos.y += -6.66695; input.action1 = true; input.facing_left = true; }
            if (tick == 24) { input.aim_pos.x += -68.9811; input.aim_pos.y += -6.66695; input.action1 = true; input.facing_left = true; }
            if (tick == 25) { input.aim_pos.x += -68.6505; input.aim_pos.y += -6.00029; input.action1 = true; input.left = true; input.facing_left = true; }
            if (tick == 26) { input.aim_pos.x += -68.2438; input.aim_pos.y += -5.00029; input.action1 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 27) { input.aim_pos.x += -66.4548; input.aim_pos.y += -1.59561; input.action1 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 28) { input.aim_pos.x += -62.7969; input.aim_pos.y += 6.79045; input.action1 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 29) { input.aim_pos.x += -57.2155; input.aim_pos.y += 16.3472; input.action1 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 30) { input.aim_pos.x += -48.5268; input.aim_pos.y += 23.2556; input.left = true; input.facing_left = true; }
            if (tick == 31) { input.aim_pos.x += -29.5718; input.aim_pos.y += 29.4534; input.left = true; input.facing_left = true; }
            if (tick == 32) { input.aim_pos.x += -16.8358; input.aim_pos.y += 31.7059; input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 33) { input.aim_pos.x += -6.05884; input.aim_pos.y += 37.7215; input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 34) { input.aim_pos.x += 3.43002; input.aim_pos.y += 46.1339; input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 35) { input.aim_pos.x += 5.91959; input.aim_pos.y += 47.1498; input.action2 = true; input.left = true; }
            if (tick == 36) { input.aim_pos.x += 20.9987; input.aim_pos.y += 50.7577; input.action2 = true; input.left = true; }
            if (tick == 37) { input.aim_pos.x += 25.5608; input.aim_pos.y += 51.0953; input.action2 = true; input.left = true; }
            if (tick == 38) { input.aim_pos.x += 31.0843; input.aim_pos.y += 50.3242; input.action2 = true; }
            if (tick == 39) { input.aim_pos.x += 40.1686; input.aim_pos.y += 49.1553; input.action2 = true; }
            if (tick == 40) { input.aim_pos.x += 41.6168; input.aim_pos.y += 48.3099; input.action2 = true; }
            if (tick == 41) { input.aim_pos.x += 41.4341; input.aim_pos.y += 46.9818; input.action2 = true; }
            if (tick == 42) { input.aim_pos.x += 40.1275; input.aim_pos.y += 45.0467; }
            if (tick == 43) { input.aim_pos.x += 39.1028; input.aim_pos.y += 42.4418; }
            if (tick == 44) { input.aim_pos.x += 36.2814; input.aim_pos.y += 37.0535; }
            if (tick == 45) { input.aim_pos.x += 34.9861; input.aim_pos.y += 33.929; }
            if (tick == 46) { input.aim_pos.x += 32.5739; input.aim_pos.y += 30.6004; }
            if (tick == 47) { input.aim_pos.x += 30.966; input.aim_pos.y += 27.5596; input.action1 = true; }
            if (tick == 48) { input.aim_pos.x += 31.4734; input.aim_pos.y += 22.311; input.action1 = true; }
            if (tick == 49) { input.aim_pos.x += 32.2839; input.aim_pos.y += 13.437; }
            if (tick == 50) { input.aim_pos.x += 32.3669; input.aim_pos.y += 9.9205; }
            if (tick == 51) { input.aim_pos.x += 32.3457; input.aim_pos.y += 8.85321; }
            if (tick == 52) { input.aim_pos.x += 32.0369; input.aim_pos.y += 7.52498; }
            if (tick == 53) { input.aim_pos.x += 32.3652; input.aim_pos.y += 3.50183; }
            if (tick == 54) { input.aim_pos.x += 32.9218; input.aim_pos.y += -3.24164; }
            if (tick == 55) { input.aim_pos.x += 33.8006; input.aim_pos.y += -8.74267; }
            if (tick == 56) { input.aim_pos.x += 33.6978; input.aim_pos.y += -8.61391; }
            if (tick == 57) { input.aim_pos.x += 33.6839; input.aim_pos.y += -8.10391; }
            if (tick == 58) { input.aim_pos.x += 33.2845; input.aim_pos.y += -7.5184; }
            if (tick == 59) { input.aim_pos.x += 32.8171; input.aim_pos.y += -6.83411; }
            if (tick == 60) { input.aim_pos.x += 32.4707; input.aim_pos.y += -6.32715; }
            if (tick == 61) { input.aim_pos.x += 32.8781; input.aim_pos.y += -5.94795; }
            if (tick == 62) { input.aim_pos.x += 33.0158; input.aim_pos.y += -5.99509; }
            if (tick == 63) { input.aim_pos.x += 32.8669; input.aim_pos.y += -5.77751; }
            if (tick == 64) { input.aim_pos.x += 32.8141; input.aim_pos.y += -5.70013; }
            if (tick == 65) { input.aim_pos.x += 32.7463; input.aim_pos.y += -5.60114; }
            if (tick == 66) { input.aim_pos.x += 32.7025; input.aim_pos.y += -5.53716; }
            if (tick == 67) { input.aim_pos.x += 32.6218; input.aim_pos.y += -5.41959; }
            if (tick == 68) { input.aim_pos.x += 33.2413; input.aim_pos.y += -5.35085; }
            if (tick == 69) { input.aim_pos.x += 35.2105; input.aim_pos.y += -4.97267; }
            if (tick == 70) { input.aim_pos.x += 37.1788; input.aim_pos.y += -4.25986; }
            if (tick == 71) { input.aim_pos.x += 38.1327; input.aim_pos.y += -4.19293; }
            if (tick == 72) { input.aim_pos.x += 38.4373; input.aim_pos.y += -3.81778; }
            if (tick == 73) { input.aim_pos.x += 38.4135; input.aim_pos.y += -3.78313; }
            if (tick == 74) { input.aim_pos.x += 38.3982; input.aim_pos.y += -3.76085; }
            if (tick == 75) { input.aim_pos.x += 38.3891; input.aim_pos.y += -3.74767; }
            if (tick == 76) { input.aim_pos.x += 38.3773; input.aim_pos.y += -3.73056; }
            if (tick == 77) { input.aim_pos.x += 38.3728; input.aim_pos.y += -3.72403; }
            if (tick == 78) { input.aim_pos.x += 38.3678; input.aim_pos.y += -3.71667; }
            if (tick == 79) { input.aim_pos.x += 38.3601; input.aim_pos.y += -3.70558; }
            if (tick == 80) { input.aim_pos.x += 38.3572; input.aim_pos.y += -3.70134; }
            if (tick == 81) { input.aim_pos.x += 38.3541; input.aim_pos.y += -3.69673; }
            if (tick == 82) { input.aim_pos.x += 38.3501; input.aim_pos.y += -3.69092; }
            if (tick == 83) { input.aim_pos.x += 38.3469; input.aim_pos.y += -3.68625; }
            if (tick == 84) { input.aim_pos.x += 38.3445; input.aim_pos.y += -3.68286; }
            if (tick == 85) { input.aim_pos.x += 38.3419; input.aim_pos.y += -3.67915; }
            if (tick == 86) { input.aim_pos.x += 38.3403; input.aim_pos.y += -3.67679; }
            if (tick == 87) { input.aim_pos.x += 38.3396; input.aim_pos.y += -3.67564; }
            if (tick == 88) { input.aim_pos.x += 38.3385; input.aim_pos.y += -3.67407; }
            if (tick == 89) { input.aim_pos.x += 38.3376; input.aim_pos.y += -3.6729; }
            if (tick == 90) { input.aim_pos.x += 38.3366; input.aim_pos.y += -3.67134; }
            if (tick == 91) { input.aim_pos.x += 38.3361; input.aim_pos.y += -3.67062; }
            if (tick == 92) { input.aim_pos.x += 38.3357; input.aim_pos.y += -3.67001; }
            if (tick == 93) { input.aim_pos.x += 38.3354; input.aim_pos.y += -3.66962; }
            if (tick == 94) { input.aim_pos.x += 38.3349; input.aim_pos.y += -3.66895; }
            if (tick == 95) { input.aim_pos.x += 38.3347; input.aim_pos.y += -3.66858; }
            if (tick == 96) { input.aim_pos.x += 38.3345; input.aim_pos.y += -3.6683; }
            if (tick == 97) { input.aim_pos.x += 38.3343; input.aim_pos.y += -3.66803; }
            if (tick == 98) { input.aim_pos.x += 38.3341; input.aim_pos.y += -3.66782; }
            if (tick == 99) { input.aim_pos.x += 38.334; input.aim_pos.y += -3.66753; }
            if (tick == 100) { input.aim_pos.x += 38.3338; input.aim_pos.y += -3.66734; }
            if (tick == 101) { input.aim_pos.x += 38.3337; input.aim_pos.y += -3.66725; }
            if (tick == 102) { input.aim_pos.x += 38.3336; input.aim_pos.y += -3.66711; }
            if (tick == 103) { input.aim_pos.x += 38.3336; input.aim_pos.y += -3.66696; }
            if (tick == 104) { input.aim_pos.x += 38.3336; input.aim_pos.y += -3.6669; }
            if (tick == 105) { input.aim_pos.x += 38.3336; input.aim_pos.y += -3.66689; }
            if (tick == 106) { input.aim_pos.x += 38.3336; input.aim_pos.y += -3.66687; }
            if (tick == 107) { input.aim_pos.x += 38.3336; input.aim_pos.y += -3.66685; }
            if (tick == 108) { input.aim_pos.x += 38.3336; input.aim_pos.y += -3.66685; }
            if (tick == 109) { input.aim_pos.x += 38.3336; input.aim_pos.y += -3.66685; }
            if (tick == 110) { input.aim_pos.x += 38.3336; input.aim_pos.y += -3.66685; }
            if (tick == 111) { input.aim_pos.x += 38.3336; input.aim_pos.y += -3.66685; }
            if (tick == 112) { input.aim_pos.x += 38.3336; input.aim_pos.y += -3.66685; }
            if (tick == 113) { input.aim_pos.x += 38.3336; input.aim_pos.y += -3.66685; }
            if (tick >= 114) { if (isServer() && bot !is null) KickPlayer(bot); }
        }
    } else if (selected_training == Training::crouching_into_someones_shield) {
        if (frog) {
            if (tick == 0) { blob.setPosition(Vec2f(276.354,136.3)); blob.setVelocity(Vec2f_zero); input.aim_pos = blob.getPosition(); }
            if (tick == 0) { input.aim_pos.x += 20.3341; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 1) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 2) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 3) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 4) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 5) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 6) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 7) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 8) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 9) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 10) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 11) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 12) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 13) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 14) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 15) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 16) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 17) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 18) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 19) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 20) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 21) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 22) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 23) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 24) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 25) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 26) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 27) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 28) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 29) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 30) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 31) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 32) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 33) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 34) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 35) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 36) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 37) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 38) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 39) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 40) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 41) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 42) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 43) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 44) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 45) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 46) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 47) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 48) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 49) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 50) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 51) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick >= 52) { if (isServer() && bot !is null) KickPlayer(bot); }
        } else if (tiger) {
            if (tick == 0) { blob.setPosition(Vec2f(300.685,136.3)); blob.setVelocity(Vec2f_zero); input.aim_pos = blob.getPosition(); }
            if (tick == 0) { input.aim_pos += Vec2f(-19.5759,-4.00011);input.facing_left = true; }
            if (tick == 1) { input.aim_pos += Vec2f(-19.5193,-4.00011);input.facing_left = true; }
            if (tick == 2) { input.aim_pos += Vec2f(-19.5068,-4.00011);input.facing_left = true; }
            if (tick == 3) { input.aim_pos += Vec2f(-19.4774,-4.00011);input.facing_left = true; }
            if (tick == 4) { input.aim_pos += Vec2f(-19.4528,-4.00011);input.facing_left = true; }
            if (tick == 5) { input.aim_pos += Vec2f(-19.4346,-4.00011);input.facing_left = true; }
            if (tick == 6) { input.aim_pos += Vec2f(-19.4191,-4.00011);input.facing_left = true; }
            if (tick == 7) { input.aim_pos += Vec2f(-19.404,-4.00011);input.facing_left = true; }
            if (tick == 8) { input.aim_pos += Vec2f(-19.3889,-4.00011);input.facing_left = true; }
            if (tick == 9) { input.aim_pos += Vec2f(-19.3793,-4.00011);input.facing_left = true; }
            if (tick == 10) { input.aim_pos += Vec2f(-19.3721,-4.00011);input.down = true; input.facing_left = true; }
            if (tick == 11) { input.aim_pos += Vec2f(-19.3653,-4.00011);input.down = true; input.facing_left = true; }
            if (tick == 12) { input.aim_pos += Vec2f(-19.3578,-4.00011);input.down = true; input.facing_left = true; }
            if (tick == 13) { input.aim_pos += Vec2f(-19.3523,-4.00011);input.down = true; input.facing_left = true; }
            if (tick == 14) { input.aim_pos += Vec2f(-19.3492,-4.00011);input.left = true; input.down = true; input.facing_left = true; }
            if (tick == 15) { input.aim_pos += Vec2f(-18.8883,-4.00011);input.left = true; input.down = true; input.facing_left = true; }
            if (tick == 16) { input.aim_pos += Vec2f(-18.0063,-4.00011);input.left = true; input.down = true; input.facing_left = true; }
            if (tick == 17) { input.aim_pos += Vec2f(-16.763,-4.00011);input.down = true; input.facing_left = true; }
            if (tick == 18) { input.aim_pos += Vec2f(-16.2685,-4.00011);input.down = true; input.facing_left = true; }
            if (tick == 19) { input.aim_pos += Vec2f(-16.3599,-4.00011);input.left = true; input.down = true; input.facing_left = true; }
            if (tick == 20) { input.aim_pos += Vec2f(-16.1121,-4.00011);input.left = true; input.down = true; input.facing_left = true; }
            if (tick == 21) { input.aim_pos += Vec2f(-15.0974,-4.00011);input.left = true; input.down = true; input.facing_left = true; }
            if (tick == 22) { input.aim_pos += Vec2f(-14.0632,-4.00011);input.down = true; input.facing_left = true; }
            if (tick == 23) { input.aim_pos += Vec2f(-14.0629,-4.00011);input.down = true; input.facing_left = true; }
            if (tick == 24) { input.aim_pos += Vec2f(-14.5139,-4.00011);input.down = true; input.facing_left = true; }
            if (tick == 25) { input.aim_pos += Vec2f(-15.1672,-4.00011);input.left = true; input.down = true; input.facing_left = true; }
            if (tick == 26) { input.aim_pos += Vec2f(-15.2906,-4.00011);input.down = true; input.facing_left = true; }
            if (tick == 27) { input.aim_pos += Vec2f(-15.1718,-4.00011);input.down = true; input.facing_left = true; }
            if (tick == 28) { input.aim_pos += Vec2f(-15.541,-4.00011);input.down = true; input.facing_left = true; }
            if (tick == 29) { input.aim_pos += Vec2f(-16.1206,-4.00011);input.left = true; input.down = true; input.facing_left = true; }
            if (tick == 30) { input.aim_pos += Vec2f(-16.0378,-4.00011);input.left = true; input.down = true; input.facing_left = true; }
            if (tick == 31) { input.aim_pos += Vec2f(-15.4823,-4.00011);input.left = true; input.down = true; input.facing_left = true; }
            if (tick == 32) { input.aim_pos += Vec2f(-14.5193,-4.00011);input.left = true; input.down = true; input.facing_left = true; }
            if (tick == 33) { input.aim_pos += Vec2f(-13.1569,-4.00011);input.left = true; input.down = true; input.facing_left = true; }
            if (tick == 34) { input.aim_pos += Vec2f(-8.34985,-4.00011);input.left = true; input.down = true; input.facing_left = true; }
            if (tick == 35) { input.aim_pos += Vec2f(3.34595,-4.00011);input.down = true; input.facing_left = true; }
            if (tick == 36) { input.aim_pos += Vec2f(35.4691,-3.33344);}
            if (tick == 37) { input.aim_pos += Vec2f(62.834,-2.33344);}
            if (tick == 38) { input.aim_pos += Vec2f(73.8733,-1.66678);}
            if (tick == 39) { input.aim_pos += Vec2f(74.8368,-1.66678);}
            if (tick == 40) { input.aim_pos += Vec2f(74.0341,-1.66678);}
            if (tick == 41) { input.aim_pos += Vec2f(72.7201,-1.66678);}
            if (tick == 42) { input.aim_pos += Vec2f(72.0602,-1.66678);}
            if (tick == 43) { input.aim_pos += Vec2f(71.3937,-1.66678);}
            if (tick == 44) { input.aim_pos += Vec2f(70.6038,-1.66678);}
            if (tick == 45) { input.aim_pos += Vec2f(69.9744,-1.66678);}
            if (tick == 46) { input.aim_pos += Vec2f(69.5702,-1.66678);}
            if (tick == 47) { input.aim_pos += Vec2f(69.3555,-1.66678);}
            if (tick == 48) { input.aim_pos += Vec2f(69.0543,-1.66678);}
            if (tick == 49) { input.aim_pos += Vec2f(68.9104,-1.66678);}
            if (tick == 50) { input.aim_pos += Vec2f(68.7833,-1.66678);}
            if (tick == 51) { input.aim_pos += Vec2f(68.6712,-1.66678);}
            if (tick == 52) { input.aim_pos += Vec2f(68.5163,-1.66678);}
            if (tick == 53) { input.aim_pos += Vec2f(68.4,-1.66678);}
            if (tick == 54) { input.aim_pos += Vec2f(68.3118,-1.66678);}
            if (tick == 55) { input.aim_pos += Vec2f(68.2401,-1.66678);}
            if (tick == 56) { input.aim_pos += Vec2f(68.2083,-1.66678);}
            if (tick == 57) { input.aim_pos += Vec2f(68.1765,-1.66678);}
            if (tick == 58) { input.aim_pos += Vec2f(68.1405,-1.66678);}
            if (tick == 59) { input.aim_pos += Vec2f(68.1101,-1.66678);}
            if (tick == 60) { input.aim_pos += Vec2f(68.0851,-1.66678);}
            if (tick == 61) { input.aim_pos += Vec2f(68.0687,-1.66678);}
            if (tick == 62) { input.aim_pos += Vec2f(68.0545,-1.66678);}
            if (tick == 63) { input.aim_pos += Vec2f(68.0475,-1.66678);}
            if (tick == 64) { input.aim_pos += Vec2f(68.0376,-1.66678);}
            if (tick == 65) { input.aim_pos += Vec2f(68.0304,-1.66678);}
            if (tick == 66) { input.aim_pos += Vec2f(68.0242,-1.66678);}
            if (tick >= 67) { if (isServer() && bot !is null) KickPlayer(bot); }
        }
    } else if (selected_training == Training::crouching_into_someones_shield_from_above) {
        if (frog) {
            if (tick == 0) { blob.setPosition(Vec2f(276.354,136.3)); blob.setVelocity(Vec2f_zero); input.aim_pos = blob.getPosition(); }
            if (tick == 0) { input.aim_pos.x += 20.3341; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 1) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 2) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 3) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 4) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 5) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 6) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 7) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 8) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 9) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 10) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 11) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 12) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 13) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 14) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 15) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 16) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 17) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 18) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 19) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 20) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 21) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 22) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 23) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 24) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 25) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 26) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 27) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 28) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 29) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 30) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 31) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 32) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 33) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 34) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 35) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 36) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 37) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 38) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 39) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 40) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 41) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 42) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 43) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 44) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 45) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 46) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 47) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 48) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 49) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 50) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick == 51) { input.aim_pos.x += 20.0008; input.aim_pos.y += -3.33372; input.action2 = true; }
            if (tick >= 52) { if (isServer() && bot !is null) KickPlayer(bot); }
        } else if (tiger) {
            if (tick == 0) { blob.setPosition(Vec2f(299.478,136.3)); blob.setVelocity(Vec2f_zero); input.aim_pos = blob.getPosition(); }
            if (tick == 0) { input.aim_pos += Vec2f(63.3254,-20.0004);}
            if (tick == 1) { input.aim_pos += Vec2f(63.3269,-20.0004);}
            if (tick == 2) { input.aim_pos += Vec2f(63.3272,-20.0004);}
            if (tick == 3) { input.aim_pos += Vec2f(63.3284,-20.0004);}
            if (tick == 4) { input.aim_pos += Vec2f(63.3293,-20.0004);}
            if (tick == 5) { input.aim_pos += Vec2f(63.33,-20.0004);}
            if (tick == 6) { input.aim_pos += Vec2f(63.3307,-20.0004);input.up = true; }
            if (tick == 7) { input.aim_pos += Vec2f(63.3311,-18.9693);input.up = true; }
            if (tick == 8) { input.aim_pos += Vec2f(63.3315,-16.9854);input.up = true; }
            if (tick == 9) { input.aim_pos += Vec2f(63.3318,-14.2466);input.up = true; }
            if (tick == 10) { input.aim_pos += Vec2f(62.9989,-12.3717);input.left = true; input.up = true; }
            if (tick == 11) { input.aim_pos += Vec2f(63.39,-10.6507);input.left = true; input.up = true; }
            if (tick == 12) { input.aim_pos += Vec2f(64.1394,-9.46221);input.left = true; input.up = true; }
            if (tick == 13) { input.aim_pos += Vec2f(65.176,-8.77534);input.left = true; input.up = true; }
            if (tick == 14) { input.aim_pos += Vec2f(66.45,-8.47989);input.left = true; input.up = true; }
            if (tick == 15) { input.aim_pos += Vec2f(67.9579,-8.4498);input.left = true; input.up = true; }
            if (tick == 16) { input.aim_pos += Vec2f(69.6167,-8.82268);input.left = true; }
            if (tick == 17) { input.aim_pos += Vec2f(70.8325,-9.8836);input.left = true; }
            if (tick == 18) { input.aim_pos += Vec2f(71.5968,-11.2882);input.left = true; }
            if (tick == 19) { input.aim_pos += Vec2f(72.3479,-12.7804);input.left = true; }
            if (tick == 20) { input.aim_pos += Vec2f(73.0399,-14.373);}
            if (tick == 21) { input.aim_pos += Vec2f(72.6081,-16.839);}
            if (tick == 22) { input.aim_pos += Vec2f(71.9823,-18.7402);}
            if (tick == 23) { input.aim_pos += Vec2f(69.0561,-22.1427);}
            if (tick == 24) { input.aim_pos += Vec2f(61.1437,-28.37);}
            if (tick == 25) { input.aim_pos += Vec2f(51.3275,-38.6406);}
            if (tick == 26) { input.aim_pos += Vec2f(41.4219,-52.0414);}
            if (tick == 27) { input.aim_pos += Vec2f(32.446,-63.6015);}
            if (tick == 28) { input.aim_pos += Vec2f(24.8433,-72.9944);}
            if (tick == 29) { input.aim_pos += Vec2f(18.787,-78.9222);}
            if (tick == 30) { input.aim_pos += Vec2f(15.8445,-82.0222);}
            if (tick == 31) { input.aim_pos += Vec2f(13.3112,-84.6773);input.down = true; }
            if (tick == 32) { input.aim_pos += Vec2f(11.1877,-86.1353);input.action2 = true; input.down = true; }
            if (tick == 33) { input.aim_pos += Vec2f(10.2912,-85.7415);input.action2 = true; input.down = true; }
            if (tick == 34) { input.aim_pos += Vec2f(10.0046,-86.3785);input.action2 = true; input.down = true; }
            if (tick == 35) { input.aim_pos += Vec2f(9.52048,-86.68);input.down = true; }
            if (tick == 36) { input.aim_pos += Vec2f(8.86401,-87.411);input.down = true; }
            if (tick == 37) { input.aim_pos += Vec2f(8.69254,-88.5957);input.down = true; }
            if (tick == 38) { input.aim_pos += Vec2f(8.46848,-89.9452);input.down = true; }
            if (tick == 39) { input.aim_pos += Vec2f(7.91452,-91.4171);input.down = true; }
            if (tick == 40) { input.aim_pos += Vec2f(7.74017,-93.406);input.down = true; }
            if (tick == 41) { input.aim_pos += Vec2f(7.60092,-95.2047);input.down = true; }
            if (tick == 42) { input.aim_pos += Vec2f(7.49338,-94.4502);input.down = true; }
            if (tick == 43) { input.aim_pos += Vec2f(7.39618,-92.7245);input.down = true; }
            if (tick == 44) { input.aim_pos += Vec2f(7.31851,-91.2704);input.down = true; }
            if (tick == 45) { input.aim_pos += Vec2f(7.25656,-90.1117);input.down = true; }
            if (tick == 46) { input.aim_pos += Vec2f(7.20697,-89.1855);}
            if (tick == 47) { input.aim_pos += Vec2f(7.1673,-88.1105);}
            if (tick == 48) { input.aim_pos += Vec2f(7.13528,-86.5131);}
            if (tick == 49) { input.aim_pos += Vec2f(7.11145,-85.7359);}
            if (tick == 50) { input.aim_pos += Vec2f(7.75699,-83.3432);}
            if (tick == 51) { input.aim_pos += Vec2f(9.0744,-78.3805);}
            if (tick == 52) { input.aim_pos += Vec2f(10.728,-74.4703);}
            if (tick == 53) { input.aim_pos += Vec2f(12.7172,-71.269);}
            if (tick == 54) { input.aim_pos += Vec2f(21.0409,-62.7571);}
            if (tick == 55) { input.aim_pos += Vec2f(29.0343,-54.6339);}
            if (tick == 56) { input.aim_pos += Vec2f(37.0292,-46.8728);}
            if (tick == 57) { input.aim_pos += Vec2f(53.0243,-30.7823);}
            if (tick == 58) { input.aim_pos += Vec2f(61.0195,-23.0273);}
            if (tick == 59) { input.aim_pos += Vec2f(64.3491,-18.9568);}
            if (tick == 60) { input.aim_pos += Vec2f(64.6796,-18.5713);}
            if (tick == 61) { input.aim_pos += Vec2f(64.6779,-18.5393);}
            if (tick == 62) { input.aim_pos += Vec2f(64.6758,-18.5011);}
            if (tick == 63) { input.aim_pos += Vec2f(64.6741,-18.4702);}
            if (tick == 64) { input.aim_pos += Vec2f(64.6726,-18.4431);}
            if (tick == 65) { input.aim_pos += Vec2f(64.6714,-18.42);}
            if (tick == 66) { input.aim_pos += Vec2f(64.6706,-18.4045);}
            if (tick == 67) { input.aim_pos += Vec2f(64.6698,-18.3907);}
            if (tick == 68) { input.aim_pos += Vec2f(64.6692,-18.38);}
            if (tick == 69) { input.aim_pos += Vec2f(64.6688,-18.3708);}
            if (tick == 70) { input.aim_pos += Vec2f(64.6685,-18.3635);}
            if (tick == 71) { input.aim_pos += Vec2f(64.6681,-18.3577);}
            if (tick == 72) { input.aim_pos += Vec2f(64.6678,-18.3533);}
            if (tick == 73) { input.aim_pos += Vec2f(64.6675,-18.3495);}
            if (tick == 74) { input.aim_pos += Vec2f(64.6675,-18.3464);}
            if (tick == 75) { input.aim_pos += Vec2f(64.6675,-18.3438);}
            if (tick == 76) { input.aim_pos += Vec2f(64.6675,-18.3418);}
            if (tick == 77) { input.aim_pos += Vec2f(64.6675,-18.3402);}
            if (tick == 78) { input.aim_pos += Vec2f(64.6675,-18.3389);}
            if (tick == 79) { input.aim_pos += Vec2f(64.6675,-18.3379);}
            if (tick == 80) { input.aim_pos += Vec2f(64.6675,-18.6703);}
            if (tick == 81) { input.aim_pos += Vec2f(64.6675,-18.6697);}
            if (tick >= 82) { if (isServer() && bot !is null) KickPlayer(bot); }
        }
    } else if (selected_training == Training::jab_direction_inside_shield) {
        if (frog) {
            if (tick == 0) { blob.setPosition(Vec2f(265.421,136.3)); blob.setVelocity(Vec2f_zero); input.aim_pos = blob.getPosition(); }
            if (tick == 0) { input.aim_pos += Vec2f(51.3325,3.99959);}
            if (tick == 1) { input.aim_pos += Vec2f(51.3325,3.99959);}
            if (tick == 2) { input.aim_pos += Vec2f(51.3325,3.99959);}
            if (tick == 3) { input.aim_pos += Vec2f(51.3325,3.99959);}
            if (tick == 4) { input.aim_pos += Vec2f(51.3325,3.99959);}
            if (tick == 5) { input.aim_pos += Vec2f(51.3325,3.99959);}
            if (tick == 6) { input.aim_pos += Vec2f(51.3325,3.99959);}
            if (tick == 7) { input.aim_pos += Vec2f(51.3325,3.99959);}
            if (tick == 8) { input.aim_pos += Vec2f(51.3325,3.99959);}
            if (tick == 9) { input.aim_pos += Vec2f(51.3325,3.99959);}
            if (tick == 10) { input.aim_pos += Vec2f(51.3325,3.99959);}
            if (tick == 11) { input.aim_pos += Vec2f(51.3325,3.99959);}
            if (tick == 12) { input.aim_pos += Vec2f(51.3325,3.99959);}
            if (tick == 13) { input.aim_pos += Vec2f(51.3325,3.99959);}
            if (tick == 14) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 15) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 16) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 17) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 18) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 19) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 20) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 21) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 22) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 23) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 24) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 25) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 26) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 27) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 28) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 29) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 30) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 31) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 32) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 33) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 34) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 35) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 36) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 37) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 38) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 39) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 40) { input.aim_pos += Vec2f(51.3325,3.99959);}
            if (tick == 41) { input.aim_pos += Vec2f(51.3325,1.33292);}
            if (tick == 42) { input.aim_pos += Vec2f(51.3325,-3.6671);}
            if (tick == 43) { input.aim_pos += Vec2f(51.3325,-5.00043);}
            if (tick == 44) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 45) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 46) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 47) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 48) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 49) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 50) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 51) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 52) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 53) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 54) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 55) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 56) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 57) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 58) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 59) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 60) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 61) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 62) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 63) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 64) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 65) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 66) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 67) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 68) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 69) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 70) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 71) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 72) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 73) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 74) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 75) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 76) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 77) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 78) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 79) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 80) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 81) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 82) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 83) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 84) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 85) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 86) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 87) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 88) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 89) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 90) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 91) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 92) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 93) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 94) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 95) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 96) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 97) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 98) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 99) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 100) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 101) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 102) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 103) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 104) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 105) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 106) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 107) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 108) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 109) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 110) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 111) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 112) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 113) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 114) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 115) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 116) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 117) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 118) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 119) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 120) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 121) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 122) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 123) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 124) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 125) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 126) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 127) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 128) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 129) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 130) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 131) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 132) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 133) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 134) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 135) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 136) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 137) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 138) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 139) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 140) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 141) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 142) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 143) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 144) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 145) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 146) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 147) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 148) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 149) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 150) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 151) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 152) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 153) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 154) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 155) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 156) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 157) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 158) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 159) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 160) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 161) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 162) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 163) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 164) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 165) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 166) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 167) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 168) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 169) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 170) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 171) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 172) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 173) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 174) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 175) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 176) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 177) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 178) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 179) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 180) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 181) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 182) { input.aim_pos += Vec2f(51.3325,-5.6671);}
            if (tick == 183) { input.aim_pos += Vec2f(51.3325,-5.6671);}
            if (tick == 184) { input.aim_pos += Vec2f(51.3325,-5.6671);}
            if (tick == 185) { input.aim_pos += Vec2f(51.3325,-5.6671);}
            if (tick == 186) { input.aim_pos += Vec2f(51.3325,-5.6671);}
            if (tick >= 187) { if (isServer() && bot !is null) KickPlayer(bot); }
        } else if (tiger) {
            if (tick == 0) { blob.setPosition(Vec2f(285.39,136.3)); blob.setVelocity(Vec2f_zero); input.aim_pos = blob.getPosition(); }
            if (tick == 0) { input.aim_pos += Vec2f(-25.9991,-10.667);input.facing_left = true; }
            if (tick == 1) { input.aim_pos += Vec2f(-25.9991,-10.667);input.facing_left = true; }
            if (tick == 2) { input.aim_pos += Vec2f(-25.9992,-10.667);input.facing_left = true; }
            if (tick == 3) { input.aim_pos += Vec2f(-25.9992,-10.667);input.facing_left = true; }
            if (tick == 4) { input.aim_pos += Vec2f(-25.9992,-10.667);input.facing_left = true; }
            if (tick == 5) { input.aim_pos += Vec2f(-25.9992,-10.667);input.facing_left = true; }
            if (tick == 6) { input.aim_pos += Vec2f(-25.9992,-10.667);input.facing_left = true; }
            if (tick == 7) { input.aim_pos += Vec2f(-25.9992,-10.667);input.facing_left = true; }
            if (tick == 8) { input.aim_pos += Vec2f(-25.9992,-10.667);input.facing_left = true; }
            if (tick == 9) { input.aim_pos += Vec2f(-25.9992,-10.667);input.facing_left = true; }
            if (tick == 10) { input.aim_pos += Vec2f(-25.9992,-10.667);input.facing_left = true; }
            if (tick == 11) { input.aim_pos += Vec2f(-25.9992,-10.667);input.facing_left = true; }
            if (tick == 12) { input.aim_pos += Vec2f(-25.9992,-10.667);input.facing_left = true; }
            if (tick == 13) { input.aim_pos += Vec2f(-25.9992,-10.667);input.facing_left = true; }
            if (tick == 14) { input.aim_pos += Vec2f(-25.9992,-10.667);input.facing_left = true; }
            if (tick == 15) { input.aim_pos += Vec2f(-25.9992,-10.667);input.facing_left = true; }
            if (tick == 16) { input.aim_pos += Vec2f(-25.9992,-10.667);input.facing_left = true; }
            if (tick == 17) { input.aim_pos += Vec2f(-25.9992,-10.667);input.facing_left = true; }
            if (tick == 18) { input.aim_pos += Vec2f(-25.9992,-10.667);input.facing_left = true; }
            if (tick == 19) { input.aim_pos += Vec2f(-25.9992,-10.667);input.facing_left = true; }
            if (tick == 20) { input.aim_pos += Vec2f(-25.9992,-10.667);input.facing_left = true; }
            if (tick == 21) { input.aim_pos += Vec2f(-25.9992,-10.667);input.facing_left = true; }
            if (tick == 22) { input.aim_pos += Vec2f(-25.9992,-10.667);input.facing_left = true; }
            if (tick == 23) { input.aim_pos += Vec2f(-25.9992,-10.667);input.facing_left = true; }
            if (tick == 24) { input.aim_pos += Vec2f(-25.9992,-10.667);input.facing_left = true; }
            if (tick == 25) { input.aim_pos += Vec2f(-25.9992,-10.667);input.facing_left = true; }
            if (tick == 26) { input.aim_pos += Vec2f(-25.9992,-10.667);input.facing_left = true; }
            if (tick == 27) { input.aim_pos += Vec2f(-25.9992,-10.667);input.facing_left = true; }
            if (tick == 28) { input.aim_pos += Vec2f(-25.9992,-10.667);input.facing_left = true; }
            if (tick == 29) { input.aim_pos += Vec2f(-25.9992,-10.667);input.facing_left = true; }
            if (tick == 30) { input.aim_pos += Vec2f(-26.3325,-10.667);input.facing_left = true; }
            if (tick == 31) { input.aim_pos += Vec2f(-26.6658,-10.667);input.left = true; input.facing_left = true; }
            if (tick == 32) { input.aim_pos += Vec2f(-26.541,-10.667);input.left = true; input.facing_left = true; }
            if (tick == 33) { input.aim_pos += Vec2f(-26.332,-10.667);input.left = true; input.facing_left = true; }
            if (tick == 34) { input.aim_pos += Vec2f(-25.4461,-10.667);input.left = true; input.facing_left = true; }
            if (tick == 35) { input.aim_pos += Vec2f(-24.9502,-10.667);input.left = true; input.facing_left = true; }
            if (tick == 36) { input.aim_pos += Vec2f(-23.2295,-10.667);input.left = true; input.facing_left = true; }
            if (tick == 37) { input.aim_pos += Vec2f(-21.2659,-10.667);input.left = true; input.facing_left = true; }
            if (tick == 38) { input.aim_pos += Vec2f(-19.7841,-10.667);input.left = true; input.facing_left = true; }
            if (tick == 39) { input.aim_pos += Vec2f(-17.8615,-10.667);input.facing_left = true; }
            if (tick == 40) { input.aim_pos += Vec2f(-18.0871,-10.667);input.facing_left = true; }
            if (tick == 41) { input.aim_pos += Vec2f(-19.6185,-10.667);input.facing_left = true; }
            if (tick == 42) { input.aim_pos += Vec2f(-20.8751,-10.667);input.facing_left = true; }
            if (tick == 43) { input.aim_pos += Vec2f(-22.1528,-10.667);input.facing_left = true; }
            if (tick == 44) { input.aim_pos += Vec2f(-23.2397,-10.667);input.facing_left = true; }
            if (tick == 45) { input.aim_pos += Vec2f(-24.4816,-10.667);input.facing_left = true; }
            if (tick == 46) { input.aim_pos += Vec2f(-25.0994,-10.667);input.facing_left = true; }
            if (tick == 47) { input.aim_pos += Vec2f(-25.7956,-10.667);input.facing_left = true; }
            if (tick == 48) { input.aim_pos += Vec2f(-26.2816,-10.667);input.facing_left = true; }
            if (tick == 49) { input.aim_pos += Vec2f(-26.8873,-10.667);input.facing_left = true; }
            if (tick == 50) { input.aim_pos += Vec2f(-27.4016,-10.667);input.facing_left = true; }
            if (tick == 51) { input.aim_pos += Vec2f(-27.7755,-10.667);input.facing_left = true; }
            if (tick == 52) { input.aim_pos += Vec2f(-28.0743,-10.667);input.facing_left = true; }
            if (tick == 53) { input.aim_pos += Vec2f(-28.2975,-10.667);input.facing_left = true; }
            if (tick == 54) { input.aim_pos += Vec2f(-28.4949,-10.667);input.facing_left = true; }
            if (tick == 55) { input.aim_pos += Vec2f(-28.6546,-10.667);input.facing_left = true; }
            if (tick == 56) { input.aim_pos += Vec2f(-28.7738,-10.667);input.facing_left = true; }
            if (tick == 57) { input.aim_pos += Vec2f(-28.8486,-10.667);input.facing_left = true; }
            if (tick == 58) { input.aim_pos += Vec2f(-28.9494,-10.667);input.facing_left = true; }
            if (tick == 59) { input.aim_pos += Vec2f(-29.0279,-10.667);input.facing_left = true; }
            if (tick == 60) { input.aim_pos += Vec2f(-29.0856,-10.667);input.action1 = true; input.facing_left = true; }
            if (tick == 61) { input.aim_pos += Vec2f(-29.1323,-10.667);input.action1 = true; input.facing_left = true; }
            if (tick == 62) { input.aim_pos += Vec2f(-29.1698,-10.667);input.action1 = true; input.facing_left = true; }
            if (tick == 63) { input.aim_pos += Vec2f(-29.1981,-10.667);input.facing_left = true; }
            if (tick == 64) { input.aim_pos += Vec2f(-29.2252,-10.667);input.facing_left = true; }
            if (tick == 65) { input.aim_pos += Vec2f(-29.2437,-10.667);input.facing_left = true; }
            if (tick == 66) { input.aim_pos += Vec2f(-29.254,-10.667);input.facing_left = true; }
            if (tick == 67) { input.aim_pos += Vec2f(-29.2695,-10.667);input.facing_left = true; }
            if (tick == 68) { input.aim_pos += Vec2f(-29.2817,-10.667);input.facing_left = true; }
            if (tick == 69) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 70) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 71) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 72) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 73) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 74) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 75) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 76) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 77) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 78) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 79) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 80) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 81) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 82) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 83) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 84) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 85) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 86) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 87) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 88) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 89) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 90) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 91) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 92) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 93) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 94) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 95) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 96) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 97) { input.aim_pos += Vec2f(-18.6658,-5.66699);input.left = true; input.facing_left = true; }
            if (tick == 98) { input.aim_pos += Vec2f(-4.99911,-2.66698);input.left = true; input.facing_left = true; }
            if (tick == 99) { input.aim_pos += Vec2f(7.45905,-1.33366);input.left = true; input.facing_left = true; }
            if (tick == 100) { input.aim_pos += Vec2f(38.6945,-0.666992);input.left = true; }
            if (tick == 101) { input.aim_pos += Vec2f(60.1826,-3.00032);input.left = true; }
            if (tick == 102) { input.aim_pos += Vec2f(72.573,-5.00032);input.left = true; }
            if (tick == 103) { input.aim_pos += Vec2f(96.8954,-9.66699);}
            if (tick == 104) { input.aim_pos += Vec2f(111.704,-14.0003);input.action1 = true; }
            if (tick == 105) { input.aim_pos += Vec2f(120.334,-16.0003);input.action1 = true; }
            if (tick == 106) { input.aim_pos += Vec2f(124.932,-17.667);input.action1 = true; }
            if (tick == 107) { input.aim_pos += Vec2f(128.557,-20.0003);}
            if (tick == 108) { input.aim_pos += Vec2f(132.662,-21.3337);}
            if (tick == 109) { input.aim_pos += Vec2f(133.374,-22.0003);}
            if (tick == 110) { input.aim_pos += Vec2f(132.867,-22.0003);}
            if (tick == 111) { input.aim_pos += Vec2f(132.456,-22.0003);}
            if (tick == 112) { input.aim_pos += Vec2f(132.124,-22.0003);}
            if (tick == 113) { input.aim_pos += Vec2f(131.835,-22.0003);}
            if (tick == 114) { input.aim_pos += Vec2f(131.622,-22.0003);}
            if (tick == 115) { input.aim_pos += Vec2f(131.421,-22.0003);}
            if (tick == 116) { input.aim_pos += Vec2f(130.609,-22.0003);}
            if (tick == 117) { input.aim_pos += Vec2f(129.491,-22.0003);}
            if (tick == 118) { input.aim_pos += Vec2f(128.398,-21.667);}
            if (tick == 119) { input.aim_pos += Vec2f(126.994,-21.3337);}
            if (tick == 120) { input.aim_pos += Vec2f(125.603,-21.0003);}
            if (tick == 121) { input.aim_pos += Vec2f(124.218,-20.3336);}
            if (tick == 122) { input.aim_pos += Vec2f(123.177,-20.3336);}
            if (tick == 123) { input.aim_pos += Vec2f(122.141,-20.0003);}
            if (tick == 124) { input.aim_pos += Vec2f(121.448,-19.667);}
            if (tick == 125) { input.aim_pos += Vec2f(120.762,-19.3336);}
            if (tick == 126) { input.aim_pos += Vec2f(120.077,-19.3336);}
            if (tick == 127) { input.aim_pos += Vec2f(119.73,-19.0003);}
            if (tick == 128) { input.aim_pos += Vec2f(119.385,-19.0003);}
            if (tick == 129) { input.aim_pos += Vec2f(119.375,-19.0003);}
            if (tick == 130) { input.aim_pos += Vec2f(119.367,-19.0003);}
            if (tick == 131) { input.aim_pos += Vec2f(119.361,-19.0003);}
            if (tick == 132) { input.aim_pos += Vec2f(119.023,-19.0003);}
            if (tick == 133) { input.aim_pos += Vec2f(118.686,-18.667);}
            if (tick == 134) { input.aim_pos += Vec2f(118.682,-18.667);}
            if (tick == 135) { input.aim_pos += Vec2f(118.679,-18.667);}
            if (tick == 136) { input.aim_pos += Vec2f(118.677,-18.667);}
            if (tick == 137) { input.aim_pos += Vec2f(118.008,-18.667);}
            if (tick == 138) { input.aim_pos += Vec2f(118.007,-18.667);}
            if (tick == 139) { input.aim_pos += Vec2f(117.672,-18.667);}
            if (tick == 140) { input.aim_pos += Vec2f(117.671,-18.667);}
            if (tick == 141) { input.aim_pos += Vec2f(117.337,-18.667);}
            if (tick == 142) { input.aim_pos += Vec2f(117.336,-18.667);}
            if (tick == 143) { input.aim_pos += Vec2f(117.003,-18.667);}
            if (tick == 144) { input.aim_pos += Vec2f(117.002,-18.667);}
            if (tick == 145) { input.aim_pos += Vec2f(117.002,-18.667);}
            if (tick == 146) { input.aim_pos += Vec2f(117.001,-18.667);}
            if (tick == 147) { input.aim_pos += Vec2f(116.334,-18.667);}
            if (tick == 148) { input.aim_pos += Vec2f(116.334,-18.667);}
            if (tick == 149) { input.aim_pos += Vec2f(116.001,-18.667);}
            if (tick == 150) { input.aim_pos += Vec2f(115.668,-18.667);}
            if (tick == 151) { input.aim_pos += Vec2f(115.001,-18.667);}
            if (tick == 152) { input.aim_pos += Vec2f(115.001,-18.667);}
            if (tick >= 153) { if (isServer() && bot !is null) KickPlayer(bot); }
            /*if (tick == 0) { blob.setPosition(Vec2f(292.576,136.3)); blob.setVelocity(Vec2f_zero); input.aim_pos = blob.getPosition(); }
            if (tick == 0) { input.aim_pos += Vec2f(-39.3341,10.333);input.facing_left = true; }
            if (tick == 1) { input.aim_pos += Vec2f(-39.3341,10.333);input.facing_left = true; }
            if (tick == 2) { input.aim_pos += Vec2f(-39.3341,10.333);input.facing_left = true; }
            if (tick == 3) { input.aim_pos += Vec2f(-39.3341,10.333);input.facing_left = true; }
            if (tick == 4) { input.aim_pos += Vec2f(-39.3341,10.333);input.facing_left = true; }
            if (tick == 5) { input.aim_pos += Vec2f(-39.3341,10.333);input.facing_left = true; }
            if (tick == 6) { input.aim_pos += Vec2f(-39.3341,10.333);input.facing_left = true; }
            if (tick == 7) { input.aim_pos += Vec2f(-39.3341,10.333);input.facing_left = true; }
            if (tick == 8) { input.aim_pos += Vec2f(-39.3341,10.333);input.facing_left = true; }
            if (tick == 9) { input.aim_pos += Vec2f(-39.3341,10.333);input.facing_left = true; }
            if (tick == 10) { input.aim_pos += Vec2f(-39.3341,10.333);input.facing_left = true; }
            if (tick == 11) { input.aim_pos += Vec2f(-39.3341,10.333);input.facing_left = true; }
            if (tick == 12) { input.aim_pos += Vec2f(-39.3341,10.333);input.facing_left = true; }
            if (tick == 13) { input.aim_pos += Vec2f(-39.3341,10.333);input.facing_left = true; }
            if (tick == 14) { input.aim_pos += Vec2f(-39.3341,10.333);input.facing_left = true; }
            if (tick == 15) { input.aim_pos += Vec2f(-39.3341,10.333);input.facing_left = true; }
            if (tick == 16) { input.aim_pos += Vec2f(-39.3341,10.333);input.facing_left = true; }
            if (tick == 17) { input.aim_pos += Vec2f(-39.3341,10.333);input.facing_left = true; }
            if (tick == 18) { input.aim_pos += Vec2f(-39.3341,10.333);input.facing_left = true; }
            if (tick == 19) { input.aim_pos += Vec2f(-39.3341,10.333);input.facing_left = true; }
            if (tick == 20) { input.aim_pos += Vec2f(-39.3341,10.333);input.left = true; input.facing_left = true; }
            if (tick == 21) { input.aim_pos += Vec2f(-38.8759,10.333);input.left = true; input.facing_left = true; }
            if (tick == 22) { input.aim_pos += Vec2f(-38.0022,10.333);input.left = true; input.facing_left = true; }
            if (tick == 23) { input.aim_pos += Vec2f(-36.7551,10.333);input.left = true; input.facing_left = true; }
            if (tick == 24) { input.aim_pos += Vec2f(-35.2812,10.333);input.left = true; input.facing_left = true; }
            if (tick == 25) { input.aim_pos += Vec2f(-33.6212,10.333);input.facing_left = true; }
            if (tick == 26) { input.aim_pos += Vec2f(-33.1087,10.333);input.facing_left = true; }
            if (tick == 27) { input.aim_pos += Vec2f(-33.2664,10.333);input.facing_left = true; }
            if (tick == 28) { input.aim_pos += Vec2f(-33.7208,10.333);input.facing_left = true; }
            if (tick == 29) { input.aim_pos += Vec2f(-34.4938,10.333);input.facing_left = true; }
            if (tick == 30) { input.aim_pos += Vec2f(-35.2715,10.333);input.facing_left = true; }
            if (tick == 31) { input.aim_pos += Vec2f(-35.8718,10.333);input.left = true; input.facing_left = true; }
            if (tick == 32) { input.aim_pos += Vec2f(-36.0243,10.333);input.left = true; input.facing_left = true; }
            if (tick == 33) { input.aim_pos += Vec2f(-35.6463,10.333);input.left = true; input.facing_left = true; }
            if (tick == 34) { input.aim_pos += Vec2f(-34.7357,10.333);input.left = true; input.facing_left = true; }
            if (tick == 35) { input.aim_pos += Vec2f(-33.5455,10.333);input.left = true; input.facing_left = true; }
            if (tick == 36) { input.aim_pos += Vec2f(-29.1372,9.99966);input.left = true; input.facing_left = true; }
            if (tick == 37) { input.aim_pos += Vec2f(-18.575,9.33301);input.facing_left = true; }
            if (tick == 38) { input.aim_pos += Vec2f(-3.82608,8.99965);input.facing_left = true; }
            if (tick == 39) { input.aim_pos += Vec2f(10.2788,7.66634);input.facing_left = true; }
            if (tick == 40) { input.aim_pos += Vec2f(17.0948,6.66632);}
            if (tick == 41) { input.aim_pos += Vec2f(27.4543,4.99966);}
            if (tick == 42) { input.aim_pos += Vec2f(29.8965,4.33299);}
            if (tick == 43) { input.aim_pos += Vec2f(31.4744,3.99968);}
            if (tick == 44) { input.aim_pos += Vec2f(38.5114,2.66634);}
            if (tick == 45) { input.aim_pos += Vec2f(43.041,1.99966);}
            if (tick == 46) { input.aim_pos += Vec2f(44.6004,1.99966);}
            if (tick == 47) { input.aim_pos += Vec2f(44.7044,1.99966);}
            if (tick == 48) { input.aim_pos += Vec2f(44.2205,1.99966);}
            if (tick == 49) { input.aim_pos += Vec2f(43.8669,1.99966);}
            if (tick == 50) { input.aim_pos += Vec2f(43.5584,1.99966);}
            if (tick == 51) { input.aim_pos += Vec2f(43.315,1.99966);}
            if (tick == 52) { input.aim_pos += Vec2f(43.1083,1.99966);}
            if (tick == 53) { input.aim_pos += Vec2f(42.9689,1.99966);}
            if (tick == 54) { input.aim_pos += Vec2f(43.8549,1.99966);}
            if (tick == 55) { input.aim_pos += Vec2f(45.7611,1.99966);}
            if (tick == 56) { input.aim_pos += Vec2f(47.3507,1.99966);}
            if (tick == 57) { input.aim_pos += Vec2f(47.283,1.99966);}
            if (tick == 58) { input.aim_pos += Vec2f(47.2288,1.99966);}
            if (tick == 59) { input.aim_pos += Vec2f(43.1917,1.33301);}
            if (tick == 60) { input.aim_pos += Vec2f(32.4933,0.666336);}
            if (tick == 61) { input.aim_pos += Vec2f(4.46664,-0.333664);}
            if (tick == 62) { input.aim_pos += Vec2f(-42.2224,-2.00034);}
            if (tick == 63) { input.aim_pos += Vec2f(-74.8991,-3.00034);}
            if (tick == 64) { input.aim_pos += Vec2f(-88.9186,-4.00034);input.facing_left = true; }
            if (tick == 65) { input.aim_pos += Vec2f(-90.2676,-4.33366);input.action1 = true; input.facing_left = true; }
            if (tick == 66) { input.aim_pos += Vec2f(-90.28,-4.33366);input.action1 = true; input.facing_left = true; }
            if (tick == 67) { input.aim_pos += Vec2f(-90.2909,-4.33366);input.action1 = true; input.facing_left = true; }
            if (tick == 68) { input.aim_pos += Vec2f(-90.2995,-4.33366);input.facing_left = true; }
            if (tick == 69) { input.aim_pos += Vec2f(-90.3052,-4.33366);input.facing_left = true; }
            if (tick == 70) { input.aim_pos += Vec2f(-90.31,-4.33366);input.facing_left = true; }
            if (tick == 71) { input.aim_pos += Vec2f(-90.3144,-4.33366);input.facing_left = true; }
            if (tick == 72) { input.aim_pos += Vec2f(-90.3176,-4.33366);input.facing_left = true; }
            if (tick == 73) { input.aim_pos += Vec2f(-89.987,-4.33366);input.facing_left = true; }
            if (tick == 74) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 75) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 76) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 77) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 78) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 79) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 80) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 81) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 82) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 83) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 84) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 85) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 86) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 87) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 88) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 89) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 90) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 91) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 92) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 93) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 94) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 95) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 96) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 97) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 98) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 99) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 100) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 101) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 102) { input.aim_pos += Vec2f(-88.9992,-4.00034);input.facing_left = true; }
            if (tick == 103) { input.aim_pos += Vec2f(-88.9992,-4.00034);input.facing_left = true; }
            if (tick == 104) { input.aim_pos += Vec2f(-88.9992,-4.00034);input.facing_left = true; }
            if (tick == 105) { input.aim_pos += Vec2f(-88.9992,-4.00034);input.facing_left = true; }
            if (tick == 106) { input.aim_pos += Vec2f(-88.9992,-4.00034);input.facing_left = true; }
            if (tick == 107) { input.aim_pos += Vec2f(-87.9992,-3.66701);input.facing_left = true; }
            if (tick == 108) { input.aim_pos += Vec2f(-78.3325,-3.33366);input.facing_left = true; }
            if (tick == 109) { input.aim_pos += Vec2f(-21.3325,-4.66701);input.facing_left = true; }
            if (tick == 110) { input.aim_pos += Vec2f(80.6675,-11.667);input.facing_left = true; }
            if (tick == 111) { input.aim_pos += Vec2f(163.334,-19.667);input.action1 = true; input.left = true; input.facing_left = true; }
            if (tick == 112) { input.aim_pos += Vec2f(205.459,-27.3337);input.action1 = true; input.left = true; }
            if (tick == 113) { input.aim_pos += Vec2f(219.829,-32.3337);input.left = true; }
            if (tick == 114) { input.aim_pos += Vec2f(225.372,-32.667);input.left = true; }
            if (tick == 115) { input.aim_pos += Vec2f(228.001,-32.3337);input.left = true; }
            if (tick == 116) { input.aim_pos += Vec2f(234.736,-31.3337);}
            if (tick == 117) { input.aim_pos += Vec2f(242.201,-30.3337);}
            if (tick == 118) { input.aim_pos += Vec2f(246.241,-29.667);}
            if (tick == 119) { input.aim_pos += Vec2f(247.041,-29.3337);}
            if (tick == 120) { input.aim_pos += Vec2f(246.868,-29.0003);}
            if (tick == 121) { input.aim_pos += Vec2f(246.635,-29.0003);}
            if (tick == 122) { input.aim_pos += Vec2f(246.544,-29.0003);}
            if (tick == 123) { input.aim_pos += Vec2f(246.2,-29.0003);}
            if (tick == 124) { input.aim_pos += Vec2f(245.896,-29.0003);}
            if (tick == 125) { input.aim_pos += Vec2f(245.656,-29.0003);}
            if (tick == 126) { input.aim_pos += Vec2f(245.451,-29.0003);}
            if (tick == 127) { input.aim_pos += Vec2f(245.323,-29.0003);}
            if (tick == 128) { input.aim_pos += Vec2f(245.205,-29.0003);}
            if (tick == 129) { input.aim_pos += Vec2f(245.109,-29.0003);}
            if (tick == 130) { input.aim_pos += Vec2f(245.024,-28.667);}
            if (tick == 131) { input.aim_pos += Vec2f(244.956,-28.667);}
            if (tick == 132) { input.aim_pos += Vec2f(244.904,-28.667);}
            if (tick == 133) { input.aim_pos += Vec2f(244.529,-28.3337);}
            if (tick == 134) { input.aim_pos += Vec2f(244.161,-28.0003);}
            if (tick == 135) { input.aim_pos += Vec2f(240.808,-26.667);}
            if (tick == 136) { input.aim_pos += Vec2f(236.786,-25.3337);}
            if (tick == 137) { input.aim_pos += Vec2f(233.432,-24.3337);}
            if (tick == 138) { input.aim_pos += Vec2f(232.082,-23.667);}
            if (tick == 139) { input.aim_pos += Vec2f(229.734,-22.3337);}
            if (tick == 140) { input.aim_pos += Vec2f(228.723,-21.667);}
            if (tick == 141) { input.aim_pos += Vec2f(228.045,-21.667);}
            if (tick == 142) { input.aim_pos += Vec2f(227.369,-21.0003);}
            if (tick == 143) { input.aim_pos += Vec2f(227.029,-20.667);}
            if (tick == 144) { input.aim_pos += Vec2f(226.69,-20.667);}
            if (tick == 145) { input.aim_pos += Vec2f(226.685,-20.667);}
            if (tick == 146) { input.aim_pos += Vec2f(226.682,-20.667);}
            if (tick == 147) { input.aim_pos += Vec2f(226.679,-20.667);}
            if (tick == 148) { input.aim_pos += Vec2f(226.677,-20.667);}
            if (tick == 149) { input.aim_pos += Vec2f(226.675,-20.667);}
            if (tick == 150) { input.aim_pos += Vec2f(226.673,-20.667);}
            if (tick == 151) { input.aim_pos += Vec2f(226.672,-20.667);}
            if (tick == 152) { input.aim_pos += Vec2f(226.671,-20.667);}
            if (tick == 153) { input.aim_pos += Vec2f(226.67,-20.667);}
            if (tick == 154) { input.aim_pos += Vec2f(226.67,-20.667);}
            if (tick == 155) { input.aim_pos += Vec2f(226.669,-20.667);}
            if (tick == 156) { input.aim_pos += Vec2f(226.669,-20.667);}
            if (tick == 157) { input.aim_pos += Vec2f(226.668,-20.667);}
            if (tick == 158) { input.aim_pos += Vec2f(226.668,-20.667);}
            if (tick == 159) { input.aim_pos += Vec2f(226.668,-20.667);}
            if (tick == 160) { input.aim_pos += Vec2f(226.668,-20.667);}
            if (tick == 161) { input.aim_pos += Vec2f(226.668,-20.667);}
            if (tick == 162) { input.aim_pos += Vec2f(226.668,-20.667);}
            if (tick == 163) { input.aim_pos += Vec2f(226.668,-20.667);}
            if (tick == 164) { input.aim_pos += Vec2f(226.668,-20.667);}
            if (tick == 165) { input.aim_pos += Vec2f(226.001,-20.3337);input.left = true; }
            if (tick == 166) { input.aim_pos += Vec2f(217.695,-19.0003);input.left = true; }
            if (tick == 167) { input.aim_pos += Vec2f(198.384,-14.0003);input.left = true; }
            if (tick == 168) { input.aim_pos += Vec2f(188.674,-11.667);input.left = true; }
            if (tick == 169) { input.aim_pos += Vec2f(188.515,-11.667);input.left = true; }
            if (tick == 170) { input.aim_pos += Vec2f(189.825,-11.667);input.left = true; }
            if (tick == 171) { input.aim_pos += Vec2f(191.342,-11.667);input.left = true; }
            if (tick == 172) { input.aim_pos += Vec2f(192.575,-11.667);input.left = true; }
            if (tick == 173) { input.aim_pos += Vec2f(193.62,-11.667);input.left = true; }
            if (tick == 174) { input.aim_pos += Vec2f(194.824,-11.667);input.left = true; }
            if (tick == 175) { input.aim_pos += Vec2f(195.431,-11.667);input.left = true; }
            if (tick == 176) { input.aim_pos += Vec2f(196.65,-11.667);input.left = true; }
            if (tick == 177) { input.aim_pos += Vec2f(196.792,-11.667);input.left = true; }
            if (tick == 178) { input.aim_pos += Vec2f(197.282,-11.667);}
            if (tick == 179) { input.aim_pos += Vec2f(196.739,-11.667);}
            if (tick == 180) { input.aim_pos += Vec2f(195.308,-11.667);}
            if (tick == 181) { input.aim_pos += Vec2f(193.906,-11.667);}
            if (tick == 182) { input.aim_pos += Vec2f(192.664,-11.667);}
            if (tick == 183) { input.aim_pos += Vec2f(191.487,-11.667);}
            if (tick == 184) { input.aim_pos += Vec2f(190.262,-11.667);}
            if (tick == 185) { input.aim_pos += Vec2f(189.387,-11.667);}
            if (tick == 186) { input.aim_pos += Vec2f(188.607,-11.667);}
            if (tick == 187) { input.aim_pos += Vec2f(187.982,-11.667);}
            if (tick == 188) { input.aim_pos += Vec2f(187.628,-11.667);}
            if (tick == 189) { input.aim_pos += Vec2f(187.209,-11.667);}
            if (tick == 190) { input.aim_pos += Vec2f(186.844,-11.667);}
            if (tick == 191) { input.aim_pos += Vec2f(186.686,-11.667);}
            if (tick == 192) { input.aim_pos += Vec2f(186.431,-11.667);}
            if (tick == 193) { input.aim_pos += Vec2f(186.226,-11.667);}
            if (tick == 194) { input.aim_pos += Vec2f(186.047,-11.667);}
            if (tick == 195) { input.aim_pos += Vec2f(185.906,-11.667);}
            if (tick == 196) { input.aim_pos += Vec2f(185.778,-11.667);}
            if (tick == 197) { input.aim_pos += Vec2f(185.698,-11.667);}
            if (tick == 198) { input.aim_pos += Vec2f(185.638,-11.667);}
            if (tick == 199) { input.aim_pos += Vec2f(185.579,-11.667);}
            if (tick == 200) { input.aim_pos += Vec2f(185.539,-11.667);}
            if (tick == 201) { input.aim_pos += Vec2f(185.499,-11.667);}
            if (tick == 202) { input.aim_pos += Vec2f(185.469,-11.667);}
            if (tick == 203) { input.aim_pos += Vec2f(185.455,-11.667);}
            if (tick == 204) { input.aim_pos += Vec2f(185.434,-11.667);}
            if (tick == 205) { input.aim_pos += Vec2f(185.414,-11.667);}
            if (tick == 206) { input.aim_pos += Vec2f(185.397,-11.667);}
            if (tick == 207) { input.aim_pos += Vec2f(185.384,-11.667);}
            if (tick == 208) { input.aim_pos += Vec2f(185.374,-11.667);}
            if (tick == 209) { input.aim_pos += Vec2f(185.366,-11.667);}
            if (tick == 210) { input.aim_pos += Vec2f(185.359,-11.667);}
            if (tick >= 211) { if (isServer() && bot !is null) KickPlayer(bot); }
            */}
    } else if (selected_training == Training::slash_direction_inside_shield) {
        if (frog) {
            if (tick == 0) { blob.setPosition(Vec2f(265.421,136.3)); blob.setVelocity(Vec2f_zero); input.aim_pos = blob.getPosition(); }
            if (tick == 0) { input.aim_pos += Vec2f(51.3325,3.99959);}
            if (tick == 1) { input.aim_pos += Vec2f(51.3325,3.99959);}
            if (tick == 2) { input.aim_pos += Vec2f(51.3325,3.99959);}
            if (tick == 3) { input.aim_pos += Vec2f(51.3325,3.99959);}
            if (tick == 4) { input.aim_pos += Vec2f(51.3325,3.99959);}
            if (tick == 5) { input.aim_pos += Vec2f(51.3325,3.99959);}
            if (tick == 6) { input.aim_pos += Vec2f(51.3325,3.99959);}
            if (tick == 7) { input.aim_pos += Vec2f(51.3325,3.99959);}
            if (tick == 8) { input.aim_pos += Vec2f(51.3325,3.99959);}
            if (tick == 9) { input.aim_pos += Vec2f(51.3325,3.99959);}
            if (tick == 10) { input.aim_pos += Vec2f(51.3325,3.99959);}
            if (tick == 11) { input.aim_pos += Vec2f(51.3325,3.99959);}
            if (tick == 12) { input.aim_pos += Vec2f(51.3325,3.99959);}
            if (tick == 13) { input.aim_pos += Vec2f(51.3325,3.99959);}
            if (tick == 14) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 15) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 16) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 17) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 18) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 19) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 20) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 21) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 22) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 23) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 24) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 25) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 26) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 27) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 28) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 29) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 30) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 31) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 32) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 33) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 34) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 35) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 36) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 37) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 38) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 39) { input.aim_pos += Vec2f(51.3325,3.99959);input.down = true; }
            if (tick == 40) { input.aim_pos += Vec2f(51.3325,3.99959);}
            if (tick == 41) { input.aim_pos += Vec2f(51.3325,1.33292);}
            if (tick == 42) { input.aim_pos += Vec2f(51.3325,-3.6671);}
            if (tick == 43) { input.aim_pos += Vec2f(51.3325,-5.00043);}
            if (tick == 44) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 45) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 46) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 47) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 48) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 49) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 50) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 51) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 52) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 53) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 54) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 55) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 56) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 57) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 58) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 59) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 60) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 61) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 62) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 63) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 64) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 65) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 66) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 67) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 68) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 69) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 70) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 71) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 72) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 73) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 74) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 75) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 76) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 77) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 78) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 79) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 80) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 81) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 82) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 83) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 84) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 85) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 86) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 87) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 88) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 89) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 90) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 91) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 92) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 93) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 94) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 95) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 96) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 97) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 98) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 99) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 100) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 101) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 102) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 103) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 104) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 105) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 106) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 107) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 108) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 109) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 110) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 111) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 112) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 113) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 114) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 115) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 116) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 117) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 118) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 119) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 120) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 121) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 122) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 123) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 124) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 125) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 126) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 127) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 128) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 129) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 130) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 131) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 132) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 133) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 134) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 135) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 136) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 137) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 138) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 139) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 140) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 141) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 142) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 143) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 144) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 145) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 146) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 147) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 148) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 149) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 150) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 151) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 152) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 153) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 154) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 155) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 156) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 157) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 158) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 159) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 160) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 161) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 162) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 163) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 164) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 165) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 166) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 167) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 168) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 169) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 170) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 171) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 172) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 173) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 174) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 175) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 176) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 177) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 178) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 179) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 180) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 181) { input.aim_pos += Vec2f(51.3325,-5.6671);input.action2 = true; }
            if (tick == 182) { input.aim_pos += Vec2f(51.3325,-5.6671);}
            if (tick == 183) { input.aim_pos += Vec2f(51.3325,-5.6671);}
            if (tick == 184) { input.aim_pos += Vec2f(51.3325,-5.6671);}
            if (tick == 185) { input.aim_pos += Vec2f(51.3325,-5.6671);}
            if (tick == 186) { input.aim_pos += Vec2f(51.3325,-5.6671);}
            if (tick >= 187) { if (isServer() && bot !is null) KickPlayer(bot); }
        } else if (tiger) {
            if (tick == 0) { blob.setPosition(Vec2f(290.874,136.3)); blob.setVelocity(Vec2f_zero); input.aim_pos = blob.getPosition(); }
            if (tick == 0) { input.aim_pos += Vec2f(-25.1812,0.986404);input.facing_left = true; }
            if (tick == 1) { input.aim_pos += Vec2f(-25.0285,0.988861);input.facing_left = true; }
            if (tick == 2) { input.aim_pos += Vec2f(-24.9965,0.989395);input.facing_left = true; }
            if (tick == 3) { input.aim_pos += Vec2f(-24.881,0.991241);input.facing_left = true; }
            if (tick == 4) { input.aim_pos += Vec2f(-24.7961,0.992599);input.facing_left = true; }
            if (tick == 5) { input.aim_pos += Vec2f(-24.7242,0.993744);input.facing_left = true; }
            if (tick == 6) { input.aim_pos += Vec2f(-24.6547,0.994858);input.facing_left = true; }
            if (tick == 7) { input.aim_pos += Vec2f(-24.6038,0.995667);input.facing_left = true; }
            if (tick == 8) { input.aim_pos += Vec2f(-24.5605,0.996368);input.facing_left = true; }
            if (tick == 9) { input.aim_pos += Vec2f(-24.5237,0.996948);input.facing_left = true; }
            if (tick == 10) { input.aim_pos += Vec2f(-24.4926,0.997437);input.facing_left = true; }
            if (tick == 11) { input.aim_pos += Vec2f(-24.4514,0.998093);input.facing_left = true; }
            if (tick == 12) { input.aim_pos += Vec2f(-24.4218,0.998566);input.facing_left = true; }
            if (tick == 13) { input.aim_pos += Vec2f(-24.4118,0.998718);input.facing_left = true; }
            if (tick == 14) { input.aim_pos += Vec2f(-24.3935,0.999039);input.facing_left = true; }
            if (tick == 15) { input.aim_pos += Vec2f(-24.3797,0.999207);input.facing_left = true; }
            if (tick == 16) { input.aim_pos += Vec2f(-24.3728,0.999313);input.facing_left = true; }
            if (tick == 17) { input.aim_pos += Vec2f(-24.366,0.999435);input.facing_left = true; }
            if (tick == 18) { input.aim_pos += Vec2f(-24.3604,0.999557);input.facing_left = true; }
            if (tick == 19) { input.aim_pos += Vec2f(-24.3561,0.999664);input.facing_left = true; }
            if (tick == 20) { input.aim_pos += Vec2f(-24.3525,0.999695);input.facing_left = true; }
            if (tick == 21) { input.aim_pos += Vec2f(-24.3499,0.999695);input.left = true; input.facing_left = true; }
            if (tick == 22) { input.aim_pos += Vec2f(-23.8881,0.99971);input.left = true; input.facing_left = true; }
            if (tick == 23) { input.aim_pos += Vec2f(-23.0147,0.99971);input.left = true; input.facing_left = true; }
            if (tick == 24) { input.aim_pos += Vec2f(-21.8412,0.99971);input.left = true; input.facing_left = true; }
            if (tick == 25) { input.aim_pos += Vec2f(-21.4021,0.99971);input.facing_left = true; }
            if (tick == 26) { input.aim_pos += Vec2f(-21.7734,0.99971);input.facing_left = true; }
            if (tick == 27) { input.aim_pos += Vec2f(-22.1371,0.99971);input.facing_left = true; }
            if (tick == 28) { input.aim_pos += Vec2f(-22.5597,0.99971);input.left = true; input.facing_left = true; }
            if (tick == 29) { input.aim_pos += Vec2f(-22.4944,0.99971);input.left = true; input.facing_left = true; }
            if (tick == 30) { input.aim_pos += Vec2f(-21.8661,0.99971);input.left = true; input.facing_left = true; }
            if (tick == 31) { input.aim_pos += Vec2f(-20.7503,0.99971);input.facing_left = true; }
            if (tick == 32) { input.aim_pos += Vec2f(-20.6049,0.99971);input.facing_left = true; }
            if (tick == 33) { input.aim_pos += Vec2f(-21.0775,0.99971);input.facing_left = true; }
            if (tick == 34) { input.aim_pos += Vec2f(-21.8467,0.99971);input.left = true; input.facing_left = true; }
            if (tick == 35) { input.aim_pos += Vec2f(-22.1744,0.99971);input.left = true; input.facing_left = true; }
            if (tick == 36) { input.aim_pos += Vec2f(-21.8812,0.99971);input.left = true; input.facing_left = true; }
            if (tick == 37) { input.aim_pos += Vec2f(-20.7117,0.99971);input.facing_left = true; }
            if (tick == 38) { input.aim_pos += Vec2f(-20.4428,0.99971);input.facing_left = true; }
            if (tick == 39) { input.aim_pos += Vec2f(-20.7103,0.99971);input.facing_left = true; }
            if (tick == 40) { input.aim_pos += Vec2f(-21.6522,0.99971);input.facing_left = true; }
            if (tick == 41) { input.aim_pos += Vec2f(-22.3047,0.99971);input.facing_left = true; }
            if (tick == 42) { input.aim_pos += Vec2f(-22.88,0.99971);input.facing_left = true; }
            if (tick == 43) { input.aim_pos += Vec2f(-23.2886,0.99971);input.facing_left = true; }
            if (tick == 44) { input.aim_pos += Vec2f(-23.8164,0.99971);input.facing_left = true; }
            if (tick == 45) { input.aim_pos += Vec2f(-24.3226,0.99971);input.facing_left = true; }
            if (tick == 46) { input.aim_pos += Vec2f(-24.83,0.99971);input.facing_left = true; }
            if (tick == 47) { input.aim_pos += Vec2f(-25.3129,0.99971);input.left = true; input.facing_left = true; }
            if (tick == 48) { input.aim_pos += Vec2f(-25.058,0.99971);input.left = true; input.facing_left = true; }
            if (tick == 49) { input.aim_pos += Vec2f(-24.4168,0.99971);input.left = true; input.facing_left = true; }
            if (tick == 50) { input.aim_pos += Vec2f(-23.378,0.99971);input.left = true; input.facing_left = true; }
            if (tick == 51) { input.aim_pos += Vec2f(-22.322,0.333054);input.facing_left = true; }
            if (tick == 52) { input.aim_pos += Vec2f(-22.4346,-0.000274658);input.facing_left = true; }
            if (tick == 53) { input.aim_pos += Vec2f(-23.2011,-1.00027);input.facing_left = true; }
            if (tick == 54) { input.aim_pos += Vec2f(-24.8506,-2.00027);input.action1 = true; input.facing_left = true; }
            if (tick == 55) { input.aim_pos += Vec2f(-25.6473,-2.00027);input.action1 = true; input.facing_left = true; }
            if (tick == 56) { input.aim_pos += Vec2f(-26.1976,-2.00027);input.action1 = true; input.facing_left = true; }
            if (tick == 57) { input.aim_pos += Vec2f(-26.9292,-2.00027);input.action1 = true; input.facing_left = true; }
            if (tick == 58) { input.aim_pos += Vec2f(-27.2747,-2.00027);input.action1 = true; input.facing_left = true; }
            if (tick == 59) { input.aim_pos += Vec2f(-27.6881,-2.00027);input.action1 = true; input.facing_left = true; }
            if (tick == 60) { input.aim_pos += Vec2f(-28.2904,-2.00027);input.action1 = true; input.facing_left = true; }
            if (tick == 61) { input.aim_pos += Vec2f(-28.5415,-2.00027);input.action1 = true; input.facing_left = true; }
            if (tick == 62) { input.aim_pos += Vec2f(-29.1366,-2.00027);input.action1 = true; input.facing_left = true; }
            if (tick == 63) { input.aim_pos += Vec2f(-29.3322,-2.00027);input.action1 = true; input.facing_left = true; }
            if (tick == 64) { input.aim_pos += Vec2f(-29.7919,-2.00027);input.action1 = true; input.facing_left = true; }
            if (tick == 65) { input.aim_pos += Vec2f(-29.877,-2.00027);input.action1 = true; input.facing_left = true; }
            if (tick == 66) { input.aim_pos += Vec2f(-29.933,-2.00027);input.action1 = true; input.facing_left = true; }
            if (tick == 67) { input.aim_pos += Vec2f(-30.0053,-2.00027);input.action1 = true; input.facing_left = true; }
            if (tick == 68) { input.aim_pos += Vec2f(-30.0468,-2.00027);input.action1 = true; input.facing_left = true; }
            if (tick == 69) { input.aim_pos += Vec2f(-30.0894,-2.00027);input.action1 = true; input.facing_left = true; }
            if (tick == 70) { input.aim_pos += Vec2f(-30.1477,-2.00027);input.action1 = true; input.facing_left = true; }
            if (tick == 71) { input.aim_pos += Vec2f(-30.1785,-2.00027);input.facing_left = true; }
            if (tick == 72) { input.aim_pos += Vec2f(-30.2147,-2.00027);input.facing_left = true; }
            if (tick == 73) { input.aim_pos += Vec2f(-30.2318,-2.00027);input.facing_left = true; }
            if (tick == 74) { input.aim_pos += Vec2f(-30.2466,-2.00027);input.facing_left = true; }
            if (tick == 75) { input.aim_pos += Vec2f(-30.2595,-2.00027);input.facing_left = true; }
            if (tick == 76) { input.aim_pos += Vec2f(-30.272,-2.00027);input.facing_left = true; }
            if (tick == 77) { input.aim_pos += Vec2f(-30.2825,-2.00027);input.facing_left = true; }
            if (tick == 78) { input.aim_pos += Vec2f(-30.2948,-2.00027);input.facing_left = true; }
            if (tick == 79) { input.aim_pos += Vec2f(-30.3019,-2.00027);input.facing_left = true; }
            if (tick == 80) { input.aim_pos += Vec2f(-30.3066,-2.00027);input.facing_left = true; }
            if (tick == 81) { input.aim_pos += Vec2f(-30.3121,-2.00027);input.facing_left = true; }
            if (tick == 82) { input.aim_pos += Vec2f(-30.3156,-2.00027);input.facing_left = true; }
            if (tick == 83) { input.aim_pos += Vec2f(-30.3183,-2.00027);input.facing_left = true; }
            if (tick == 84) { input.aim_pos += Vec2f(-30.3211,-2.00027);input.facing_left = true; }
            if (tick == 85) { input.aim_pos += Vec2f(-30.3238,-2.00027);input.facing_left = true; }
            if (tick == 86) { input.aim_pos += Vec2f(-30.3251,-2.00027);input.facing_left = true; }
            if (tick == 87) { input.aim_pos += Vec2f(-30.3263,-2.00027);input.action1 = true; input.facing_left = true; }
            if (tick == 88) { input.aim_pos += Vec2f(-30.3274,-2.00027);input.action1 = true; input.facing_left = true; }
            if (tick == 89) { input.aim_pos += Vec2f(-30.3288,-2.00027);input.action1 = true; input.facing_left = true; }
            if (tick == 90) { input.aim_pos += Vec2f(-30.3299,-1.66695);input.action1 = true; input.left = true; input.facing_left = true; }
            if (tick == 91) { input.aim_pos += Vec2f(-27.2546,-0.333603);input.action1 = true; input.left = true; input.facing_left = true; }
            if (tick == 92) { input.aim_pos += Vec2f(-10.18,1.33307);input.action1 = true; input.facing_left = true; }
            if (tick == 93) { input.aim_pos += Vec2f(25.4144,2.6664);input.action1 = true; }
            if (tick == 94) { input.aim_pos += Vec2f(71.4135,4.66638);input.action1 = true; }
            if (tick == 95) { input.aim_pos += Vec2f(116.92,5.6664);input.action1 = true; }
            if (tick == 96) { input.aim_pos += Vec2f(138.43,5.6664);input.action1 = true; }
            if (tick == 97) { input.aim_pos += Vec2f(153.185,4.99973);input.action1 = true; }
            if (tick == 98) { input.aim_pos += Vec2f(159.741,4.33305);input.action1 = true; }
            if (tick == 99) { input.aim_pos += Vec2f(163.615,3.99974);input.action1 = true; }
            if (tick == 100) { input.aim_pos += Vec2f(165.498,3.33307);input.action1 = true; }
            if (tick == 101) { input.aim_pos += Vec2f(165.775,3.33307);input.action1 = true; }
            if (tick == 102) { input.aim_pos += Vec2f(165.658,3.33307);input.action1 = true; }
            if (tick == 103) { input.aim_pos += Vec2f(165.591,3.33307);input.action1 = true; }
            if (tick == 104) { input.aim_pos += Vec2f(165.553,3.33307);}
            if (tick == 105) { input.aim_pos += Vec2f(165.5,3.33307);}
            if (tick == 106) { input.aim_pos += Vec2f(165.473,2.99973);}
            if (tick == 107) { input.aim_pos += Vec2f(165.442,2.99973);}
            if (tick == 108) { input.aim_pos += Vec2f(165.421,2.99973);}
            if (tick == 109) { input.aim_pos += Vec2f(165.408,2.99973);}
            if (tick == 110) { input.aim_pos += Vec2f(165.064,2.99973);}
            if (tick == 111) { input.aim_pos += Vec2f(164.054,2.99973);}
            if (tick == 112) { input.aim_pos += Vec2f(162.376,2.99973);}
            if (tick == 113) { input.aim_pos += Vec2f(161.372,2.99973);}
            if (tick == 114) { input.aim_pos += Vec2f(160.032,2.99973);}
            if (tick == 115) { input.aim_pos += Vec2f(159.358,2.99973);}
            if (tick == 116) { input.aim_pos += Vec2f(158.687,2.99973);}
            if (tick == 117) { input.aim_pos += Vec2f(158.683,2.99973);}
            if (tick == 118) { input.aim_pos += Vec2f(158.012,2.99973);}
            if (tick == 119) { input.aim_pos += Vec2f(157.676,2.99973);}
            if (tick == 120) { input.aim_pos += Vec2f(157.341,2.99973);}
            if (tick == 121) { input.aim_pos += Vec2f(156.34,2.99973);}
            if (tick == 122) { input.aim_pos += Vec2f(155.006,2.99973);}
            if (tick == 123) { input.aim_pos += Vec2f(153.671,2.99973);}
            if (tick == 124) { input.aim_pos += Vec2f(151.337,3.33307);}
            if (tick == 125) { input.aim_pos += Vec2f(150.003,3.6664);}
            if (tick == 126) { input.aim_pos += Vec2f(150.003,3.6664);}
            if (tick == 127) { input.aim_pos += Vec2f(150.002,3.6664);}
            if (tick == 128) { input.aim_pos += Vec2f(149.669,3.6664);}
            if (tick == 129) { input.aim_pos += Vec2f(149.668,3.6664);}
            if (tick == 130) { input.aim_pos += Vec2f(149.668,3.6664);}
            if (tick == 131) { input.aim_pos += Vec2f(149.335,3.6664);}
            if (tick == 132) { input.aim_pos += Vec2f(149.334,3.6664);}
            if (tick == 133) { input.aim_pos += Vec2f(149.334,3.6664);}
            if (tick == 134) { input.aim_pos += Vec2f(149.334,3.6664);}
            if (tick == 135) { input.aim_pos += Vec2f(149.334,3.6664);}
            if (tick == 136) { input.aim_pos += Vec2f(149.334,3.6664);}
            if (tick == 137) { input.aim_pos += Vec2f(149.334,3.6664);}
            if (tick == 138) { input.aim_pos += Vec2f(149.334,3.6664);}
            if (tick == 139) { input.aim_pos += Vec2f(149.334,3.6664);}
            if (tick == 140) { input.aim_pos += Vec2f(149.334,3.6664);}
            if (tick == 141) { input.aim_pos += Vec2f(149.334,3.6664);}
            if (tick == 142) { input.aim_pos += Vec2f(149.334,3.6664);}
            if (tick == 143) { input.aim_pos += Vec2f(149.001,3.6664);}
            if (tick == 144) { input.aim_pos += Vec2f(148.667,3.6664);}
            if (tick == 145) { input.aim_pos += Vec2f(148.001,3.6664);}
            if (tick == 146) { input.aim_pos += Vec2f(147.667,3.6664);}
            if (tick == 147) { input.aim_pos += Vec2f(147.001,3.6664);}
            if (tick == 148) { input.aim_pos += Vec2f(146.334,3.6664);}
            if (tick == 149) { input.aim_pos += Vec2f(146.334,3.33307);}
            if (tick == 150) { input.aim_pos += Vec2f(146.001,3.33307);}
            if (tick == 151) { input.aim_pos += Vec2f(145.667,3.33307);}
            if (tick == 152) { input.aim_pos += Vec2f(145.667,3.33307);}
            if (tick == 153) { input.aim_pos += Vec2f(145.001,3.33307);}
            if (tick == 154) { input.aim_pos += Vec2f(144.667,3.33307);}
            if (tick == 155) { input.aim_pos += Vec2f(144.334,2.99973);}
            if (tick == 156) { input.aim_pos += Vec2f(144.334,2.99973);}
            if (tick == 157) { input.aim_pos += Vec2f(144.001,2.99973);}
            if (tick == 158) { input.aim_pos += Vec2f(144.001,2.99973);}
            if (tick == 159) { input.aim_pos += Vec2f(143.667,2.6664);}
            if (tick == 160) { input.aim_pos += Vec2f(143.667,2.6664);}
            if (tick == 161) { input.aim_pos += Vec2f(143.667,2.6664);}
            if (tick >= 162) { if (isServer() && bot !is null) KickPlayer(bot); }
        }
    } else if (selected_training == Training::turnaround_slash_while_crouching_into_enemy_shield) { // NOTE(hobey): turn-around-slash while crouching into enemy
        if (frog) {
            if (tick == 0) { blob.setPosition(Vec2f(266.051,136.3)); blob.setVelocity(Vec2f_zero); input.aim_pos = blob.getPosition(); }
            if (tick == 0) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 1) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 2) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 3) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 4) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 5) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 6) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 7) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 8) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 9) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 10) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 11) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 12) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 13) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 14) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 15) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 16) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 17) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 18) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 19) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 20) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 21) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 22) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 23) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 24) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 25) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 26) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 27) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 28) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 29) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 30) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 31) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 32) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 33) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 34) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 35) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 36) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 37) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 38) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 39) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 40) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 41) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 42) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 43) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 44) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 45) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 46) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 47) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 48) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 49) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 50) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 51) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 52) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 53) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 54) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 55) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 56) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 57) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 58) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 59) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 60) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 61) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 62) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 63) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 64) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 65) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 66) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 67) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 68) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 69) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 70) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 71) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 72) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 73) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 74) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 75) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 76) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 77) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 78) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 79) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 80) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 81) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 82) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 83) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 84) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 85) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 86) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 87) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 88) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 89) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 90) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 91) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 92) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 93) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 94) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 95) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 96) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 97) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 98) { input.aim_pos += Vec2f(43.666,-2.33359);input.action2 = true; }
            if (tick == 99) { input.aim_pos += Vec2f(43.666,-2.33359);}
            if (tick == 100) { input.aim_pos += Vec2f(43.666,-2.33359);}
            if (tick == 101) { input.aim_pos += Vec2f(43.666,-2.33359);}
            if (tick == 102) { input.aim_pos += Vec2f(43.666,-2.33359);}
            if (tick == 103) { input.aim_pos += Vec2f(43.666,-2.33359);}
            if (tick == 104) { input.aim_pos += Vec2f(43.666,-2.33359);}
            if (tick == 105) { input.aim_pos += Vec2f(43.666,-2.33359);}
            if (tick >= 106) { if (isServer() && bot !is null) KickPlayer(bot); }
        } else if (tiger) {
            if (tick == 0) { blob.setPosition(Vec2f(292.18,136.3)); blob.setVelocity(Vec2f_zero); input.aim_pos = blob.getPosition(); }
            if (tick == 0) { input.aim_pos += Vec2f(-55.904,-4.33359);input.facing_left = true; }
            if (tick == 1) { input.aim_pos += Vec2f(-54.9744,-4.33359);input.facing_left = true; }
            if (tick == 2) { input.aim_pos += Vec2f(-54.6232,-4.33359);input.facing_left = true; }
            if (tick == 3) { input.aim_pos += Vec2f(-53.7912,-4.33359);input.facing_left = true; }
            if (tick == 4) { input.aim_pos += Vec2f(-53.1266,-4.33359);input.facing_left = true; }
            if (tick == 5) { input.aim_pos += Vec2f(-52.5914,-4.33359);input.facing_left = true; }
            if (tick == 6) { input.aim_pos += Vec2f(-52.1614,-4.33359);input.facing_left = true; }
            if (tick == 7) { input.aim_pos += Vec2f(-51.8159,-4.33359);input.facing_left = true; }
            if (tick == 8) { input.aim_pos += Vec2f(-51.5374,-3.66693);input.facing_left = true; }
            if (tick == 9) { input.aim_pos += Vec2f(-50.6451,-3.33359);input.facing_left = true; }
            if (tick == 10) { input.aim_pos += Vec2f(-50.476,-3.33359);input.facing_left = true; }
            if (tick == 11) { input.aim_pos += Vec2f(-50.3356,-3.33359);input.facing_left = true; }
            if (tick == 12) { input.aim_pos += Vec2f(-50.21,-3.33359);input.facing_left = true; }
            if (tick == 13) { input.aim_pos += Vec2f(-50.1081,-3.33359);input.facing_left = true; }
            if (tick == 14) { input.aim_pos += Vec2f(-50.0318,-3.33359);input.facing_left = true; }
            if (tick == 15) { input.aim_pos += Vec2f(-49.9631,-3.33359);input.facing_left = true; }
            if (tick == 16) { input.aim_pos += Vec2f(-49.9076,-3.33359);input.facing_left = true; }
            if (tick == 17) { input.aim_pos += Vec2f(-49.8592,-3.33359);input.facing_left = true; }
            if (tick == 18) { input.aim_pos += Vec2f(-49.8237,-3.33359);input.facing_left = true; }
            if (tick == 19) { input.aim_pos += Vec2f(-49.8017,-3.33359);input.facing_left = true; }
            if (tick == 20) { input.aim_pos += Vec2f(-49.7763,-3.33359);input.facing_left = true; }
            if (tick == 21) { input.aim_pos += Vec2f(-49.7542,-3.33359);input.facing_left = true; }
            if (tick == 22) { input.aim_pos += Vec2f(-49.738,-3.33359);input.facing_left = true; }
            if (tick == 23) { input.aim_pos += Vec2f(-49.7259,-3.33359);input.facing_left = true; }
            if (tick == 24) { input.aim_pos += Vec2f(-49.7158,-3.33359);input.facing_left = true; }
            if (tick == 25) { input.aim_pos += Vec2f(-49.7059,-3.33359);input.facing_left = true; }
            if (tick == 26) { input.aim_pos += Vec2f(-49.6992,-3.33359);input.facing_left = true; }
            if (tick == 27) { input.aim_pos += Vec2f(-49.6936,-3.33359);input.facing_left = true; }
            if (tick == 28) { input.aim_pos += Vec2f(-49.6882,-3.33359);input.facing_left = true; }
            if (tick == 29) { input.aim_pos += Vec2f(-49.6842,-3.33359);input.facing_left = true; }
            if (tick == 30) { input.aim_pos += Vec2f(-49.6809,-3.33359);input.left = true; input.facing_left = true; }
            if (tick == 31) { input.aim_pos += Vec2f(-49.2201,-3.33359);input.left = true; input.facing_left = true; }
            if (tick == 32) { input.aim_pos += Vec2f(-48.3479,-3.33359);input.left = true; input.facing_left = true; }
            if (tick == 33) { input.aim_pos += Vec2f(-47.1222,-3.33359);input.facing_left = true; }
            if (tick == 34) { input.aim_pos += Vec2f(-46.7042,-3.33359);input.facing_left = true; }
            if (tick == 35) { input.aim_pos += Vec2f(-46.7283,-3.33359);input.facing_left = true; }
            if (tick == 36) { input.aim_pos += Vec2f(-46.9639,-3.33359);input.facing_left = true; }
            if (tick == 37) { input.aim_pos += Vec2f(-47.267,-3.33359);input.facing_left = true; }
            if (tick == 38) { input.aim_pos += Vec2f(-47.6783,-3.33359);input.facing_left = true; }
            if (tick == 39) { input.aim_pos += Vec2f(-48.0301,-3.33359);input.left = true; input.facing_left = true; }
            if (tick == 40) { input.aim_pos += Vec2f(-47.8647,-3.33359);input.left = true; input.facing_left = true; }
            if (tick == 41) { input.aim_pos += Vec2f(-47.2247,-3.33359);input.facing_left = true; }
            if (tick == 42) { input.aim_pos += Vec2f(-47.0426,-3.33359);input.facing_left = true; }
            if (tick == 43) { input.aim_pos += Vec2f(-47.2076,-3.33359);input.facing_left = true; }
            if (tick == 44) { input.aim_pos += Vec2f(-47.4733,-3.33359);input.facing_left = true; }
            if (tick == 45) { input.aim_pos += Vec2f(-47.7957,-3.33359);input.facing_left = true; }
            if (tick == 46) { input.aim_pos += Vec2f(-48.0953,-3.33359);input.facing_left = true; }
            if (tick == 47) { input.aim_pos += Vec2f(-48.7124,-3.33359);input.facing_left = true; }
            if (tick == 48) { input.aim_pos += Vec2f(-48.945,-3.33359);input.facing_left = true; }
            if (tick == 49) { input.aim_pos += Vec2f(-49.4835,-3.33359);input.down = true; input.facing_left = true; }
            if (tick == 50) { input.aim_pos += Vec2f(-49.9689,-3.66693);input.down = true; input.facing_left = true; }
            if (tick == 51) { input.aim_pos += Vec2f(-50.104,-3.66693);input.action1 = true; input.down = true; input.facing_left = true; }
            if (tick == 52) { input.aim_pos += Vec2f(-50.204,-3.66693);input.action1 = true; input.down = true; input.facing_left = true; }
            if (tick == 53) { input.aim_pos += Vec2f(-50.2928,-3.66693);input.action1 = true; input.down = true; input.facing_left = true; }
            if (tick == 54) { input.aim_pos += Vec2f(-50.3591,-3.66693);input.action1 = true; input.down = true; input.facing_left = true; }
            if (tick == 55) { input.aim_pos += Vec2f(-50.4137,-3.66693);input.action1 = true; input.down = true; input.facing_left = true; }
            if (tick == 56) { input.aim_pos += Vec2f(-50.4586,-3.66693);input.action1 = true; input.down = true; input.facing_left = true; }
            if (tick == 57) { input.aim_pos += Vec2f(-50.4899,-3.66693);input.action1 = true; input.down = true; input.facing_left = true; }
            if (tick == 58) { input.aim_pos += Vec2f(-50.5219,-3.66693);input.action1 = true; input.down = true; input.facing_left = true; }
            if (tick == 59) { input.aim_pos += Vec2f(-50.5482,-3.66693);input.action1 = true; input.down = true; input.facing_left = true; }
            if (tick == 60) { input.aim_pos += Vec2f(-50.5695,-3.66693);input.action1 = true; input.down = true; input.facing_left = true; }
            if (tick == 61) { input.aim_pos += Vec2f(-50.5885,-3.66693);input.action1 = true; input.left = true; input.down = true; input.facing_left = true; }
            if (tick == 62) { input.aim_pos += Vec2f(-50.1944,-3.66693);input.action1 = true; input.left = true; input.down = true; input.facing_left = true; }
            if (tick == 63) { input.aim_pos += Vec2f(-49.4526,-3.66693);input.action1 = true; input.down = true; input.facing_left = true; }
            if (tick == 64) { input.aim_pos += Vec2f(-49.1938,-3.66693);input.action1 = true; input.down = true; input.facing_left = true; }
            if (tick == 65) { input.aim_pos += Vec2f(-49.253,-3.66693);input.action1 = true; input.down = true; input.facing_left = true; }
            if (tick == 66) { input.aim_pos += Vec2f(-49.4328,-3.66693);input.action1 = true; input.down = true; input.facing_left = true; }
            if (tick == 67) { input.aim_pos += Vec2f(-49.6324,-3.66693);input.action1 = true; input.down = true; input.facing_left = true; }
            if (tick == 68) { input.aim_pos += Vec2f(-49.8353,-3.66693);input.action1 = true; input.down = true; input.facing_left = true; }
            if (tick == 69) { input.aim_pos += Vec2f(-49.9856,-3.66693);input.action1 = true; input.down = true; input.facing_left = true; }
            if (tick == 70) { input.aim_pos += Vec2f(-50.0993,-3.66693);input.action1 = true; input.down = true; input.facing_left = true; }
            if (tick == 71) { input.aim_pos += Vec2f(-50.2025,-3.66693);input.action1 = true; input.down = true; input.facing_left = true; }
            if (tick == 72) { input.aim_pos += Vec2f(-50.2801,-3.66693);input.action1 = true; input.left = true; input.down = true; input.facing_left = true; }
            if (tick == 73) { input.aim_pos += Vec2f(-49.9419,-3.66693);input.action1 = true; input.left = true; input.down = true; input.facing_left = true; }
            if (tick == 74) { input.aim_pos += Vec2f(-49.2408,-3.66693);input.action1 = true; input.down = true; input.facing_left = true; }
            if (tick == 75) { input.aim_pos += Vec2f(-49.0411,-3.66693);input.action1 = true; input.down = true; input.facing_left = true; }
            if (tick == 76) { input.aim_pos += Vec2f(-49.1341,-3.66693);input.action1 = true; input.down = true; input.facing_left = true; }
            if (tick == 77) { input.aim_pos += Vec2f(-49.3196,-3.66693);input.action1 = true; input.down = true; input.facing_left = true; }
            if (tick == 78) { input.aim_pos += Vec2f(-49.5634,-3.66693);input.action1 = true; input.left = true; input.down = true; input.facing_left = true; }
            if (tick == 79) { input.aim_pos += Vec2f(-49.3578,-3.66693);input.action1 = true; input.left = true; input.down = true; input.facing_left = true; }
            if (tick == 80) { input.aim_pos += Vec2f(-48.757,-3.66693);input.action1 = true; input.down = true; input.facing_left = true; }
            if (tick == 81) { input.aim_pos += Vec2f(-48.6188,-3.66693);input.action1 = true; input.down = true; input.facing_left = true; }
            if (tick == 82) { input.aim_pos += Vec2f(-48.7929,-3.66693);input.action1 = true; input.down = true; input.facing_left = true; }
            if (tick == 83) { input.aim_pos += Vec2f(-49.0655,-3.66693);input.action1 = true; input.left = true; input.down = true; input.facing_left = true; }
            if (tick == 84) { input.aim_pos += Vec2f(-43.8463,-6.00026);input.action1 = true; input.left = true; input.down = true; input.facing_left = true; }
            if (tick == 85) { input.aim_pos += Vec2f(-32.6168,-10.3336);input.left = true; input.down = true; input.facing_left = true; }
            if (tick == 86) { input.aim_pos += Vec2f(36.5486,-23.6669);input.left = true; input.down = true; input.facing_left = true; }
            if (tick == 87) { input.aim_pos += Vec2f(214.553,-32.0003);input.left = true; input.down = true; input.facing_left = true; }
            if (tick == 88) { input.aim_pos += Vec2f(326.712,-24.6669);input.left = true; input.down = true; }
            if (tick == 89) { input.aim_pos += Vec2f(328.464,-18.3336);input.left = true; input.down = true; }
            if (tick == 90) { input.aim_pos += Vec2f(329.971,-6.66692);input.left = true; input.down = true; }
            if (tick == 91) { input.aim_pos += Vec2f(330.603,-4.66693);input.left = true; input.down = true; }
            if (tick == 92) { input.aim_pos += Vec2f(330.639,-4.66693);input.left = true; input.down = true; }
            if (tick == 93) { input.aim_pos += Vec2f(330.807,-5.3336);input.action1 = true; input.left = true; input.down = true; }
            if (tick == 94) { input.aim_pos += Vec2f(330.738,-5.3336);input.action1 = true; input.down = true; }
            if (tick == 95) { input.aim_pos += Vec2f(329.62,-5.3336);input.action1 = true; }
            if (tick == 96) { input.aim_pos += Vec2f(327.165,-5.3336);}
            if (tick == 97) { input.aim_pos += Vec2f(321.268,-5.3336);}
            if (tick == 98) { input.aim_pos += Vec2f(318.184,-5.3336);input.action1 = true; }
            if (tick == 99) { input.aim_pos += Vec2f(316.888,-5.3336);input.action1 = true; }
            if (tick == 100) { input.aim_pos += Vec2f(315.868,-5.3336);input.action1 = true; }
            if (tick == 101) { input.aim_pos += Vec2f(314.854,-5.3336);}
            if (tick == 102) { input.aim_pos += Vec2f(313.866,-5.3336);}
            if (tick == 103) { input.aim_pos += Vec2f(313.388,-6.66692);input.action1 = true; }
            if (tick == 104) { input.aim_pos += Vec2f(312.367,-7.66693);input.action1 = true; }
            if (tick == 105) { input.aim_pos += Vec2f(311.379,-8.3336);}
            if (tick == 106) { input.aim_pos += Vec2f(310.805,-9.00026);}
            if (tick == 107) { input.aim_pos += Vec2f(309.924,-10.0003);}
            if (tick == 108) { input.aim_pos += Vec2f(309.416,-10.0003);}
            if (tick == 109) { input.aim_pos += Vec2f(309.276,-10.0003);}
            if (tick == 110) { input.aim_pos += Vec2f(308.496,-10.0003);}
            if (tick == 111) { input.aim_pos += Vec2f(307.078,-10.0003);}
            if (tick == 112) { input.aim_pos += Vec2f(306.334,-9.66693);}
            if (tick == 113) { input.aim_pos += Vec2f(303.944,-9.00026);}
            if (tick == 114) { input.aim_pos += Vec2f(295.563,-8.00026);}
            if (tick == 115) { input.aim_pos += Vec2f(282.186,-6.00026);}
            if (tick == 116) { input.aim_pos += Vec2f(269.821,-4.33359);}
            if (tick == 117) { input.aim_pos += Vec2f(259.127,-1.66693);}
            if (tick == 118) { input.aim_pos += Vec2f(251.772,0.333069);}
            if (tick == 119) { input.aim_pos += Vec2f(245.087,2.99974);}
            if (tick == 120) { input.aim_pos += Vec2f(239.073,4.33307);}
            if (tick == 121) { input.aim_pos += Vec2f(234.393,5.66641);}
            if (tick == 122) { input.aim_pos += Vec2f(233.05,5.66641);}
            if (tick == 123) { input.aim_pos += Vec2f(233.04,5.99974);}
            if (tick == 124) { input.aim_pos += Vec2f(233.033,5.99974);}
            if (tick == 125) { input.aim_pos += Vec2f(233.026,5.99974);}
            if (tick == 126) { input.aim_pos += Vec2f(233.021,5.99974);}
            if (tick == 127) { input.aim_pos += Vec2f(232.35,5.99974);}
            if (tick == 128) { input.aim_pos += Vec2f(232.347,6.33308);}
            if (tick == 129) { input.aim_pos += Vec2f(231.679,6.33308);}
            if (tick == 130) { input.aim_pos += Vec2f(231.677,6.33308);}
            if (tick == 131) { input.aim_pos += Vec2f(231.342,6.33308);}
            if (tick == 132) { input.aim_pos += Vec2f(231.34,6.33308);}
            if (tick == 133) { input.aim_pos += Vec2f(231.339,6.33308);}
            if (tick == 134) { input.aim_pos += Vec2f(231.004,6.33308);}
            if (tick == 135) { input.aim_pos += Vec2f(230.67,6.33308);}
            if (tick == 136) { input.aim_pos += Vec2f(230.67,6.33308);}
            if (tick == 137) { input.aim_pos += Vec2f(230.336,6.33308);}
            if (tick == 138) { input.aim_pos += Vec2f(230.335,6.33308);}
            if (tick == 139) { input.aim_pos += Vec2f(230.002,6.33308);}
            if (tick >= 140) { if (isServer() && bot !is null) KickPlayer(bot); }
        }
    } else if (selected_training == Training::instajab) {
        if (frog) {
            if (tick == 0) { blob.setPosition(Vec2f(269.937,136.3)); blob.setVelocity(Vec2f_zero); input.aim_pos = blob.getPosition(); }
            if (tick == 0) { input.aim_pos += Vec2f(52.3325,3.3329);}
            if (tick == 1) { input.aim_pos += Vec2f(52.3325,3.3329);}
            if (tick == 2) { input.aim_pos += Vec2f(52.3325,3.3329);}
            if (tick == 3) { input.aim_pos += Vec2f(52.3325,3.3329);}
            if (tick == 4) { input.aim_pos += Vec2f(52.3325,3.3329);}
            if (tick == 5) { input.aim_pos += Vec2f(52.3325,3.3329);}
            if (tick == 6) { input.aim_pos += Vec2f(52.3325,3.3329);}
            if (tick == 7) { input.aim_pos += Vec2f(52.3325,3.3329);}
            if (tick == 8) { input.aim_pos += Vec2f(52.3325,3.3329);input.action1 = true; }
            if (tick == 9) { input.aim_pos += Vec2f(52.3325,3.3329);input.action1 = true; }
            if (tick == 10) { input.aim_pos += Vec2f(52.3325,3.33292);input.action1 = true; }
            if (tick == 11) { input.aim_pos += Vec2f(52.3325,3.33292);input.action1 = true; }
            if (tick == 12) { input.aim_pos += Vec2f(52.3325,3.33292);input.action1 = true; }
            if (tick == 13) { input.aim_pos += Vec2f(52.3325,3.33292);input.action1 = true; }
            if (tick == 14) { input.aim_pos += Vec2f(52.3325,3.33292);input.action1 = true; }
            if (tick == 15) { input.aim_pos += Vec2f(52.3325,3.33292);input.action1 = true; }
            if (tick == 16) { input.aim_pos += Vec2f(52.3325,3.33292);input.action1 = true; }
            if (tick == 17) { input.aim_pos += Vec2f(52.3325,3.33292);input.action1 = true; }
            if (tick == 18) { input.aim_pos += Vec2f(52.3325,3.33292);input.action1 = true; }
            if (tick == 19) { input.aim_pos += Vec2f(52.3325,3.33292);input.action1 = true; }
            if (tick == 20) { input.aim_pos += Vec2f(52.3325,3.33292);input.action1 = true; }
            if (tick == 21) { input.aim_pos += Vec2f(52.3325,3.33292);input.action1 = true; }
            if (tick == 22) { input.aim_pos += Vec2f(52.3325,3.33292);input.action1 = true; }
            if (tick == 23) { input.aim_pos += Vec2f(52.3325,3.33292);input.action1 = true; }
            if (tick == 24) { input.aim_pos += Vec2f(52.3325,3.33292);input.action1 = true; }
            if (tick == 25) { input.aim_pos += Vec2f(52.3325,3.33292);input.action1 = true; }
            if (tick == 26) { input.aim_pos += Vec2f(52.3325,3.33292);}
            if (tick == 27) { input.aim_pos += Vec2f(52.3325,3.33292);}
            if (tick == 28) { input.aim_pos += Vec2f(52.3325,3.33292);}
            if (tick == 29) { input.aim_pos += Vec2f(52.3325,3.33292);}
            if (tick == 30) { input.aim_pos += Vec2f(52.3325,3.33292);}
            if (tick == 31) { input.aim_pos += Vec2f(52.3325,3.33292);}
            if (tick == 32) { input.aim_pos += Vec2f(52.3325,3.33292);}
            if (tick == 33) { input.aim_pos += Vec2f(52.3325,3.33292);}
            if (tick == 34) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 35) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 36) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 37) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 38) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 39) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 40) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 41) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 42) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 43) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 44) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 45) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 46) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 47) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 48) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 49) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 50) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 51) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 52) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 53) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 54) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 55) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 56) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 57) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 58) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 59) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 60) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 61) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 62) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 63) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 64) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 65) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 66) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 67) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 68) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 69) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 70) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 71) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 72) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 73) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 74) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 75) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 76) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 77) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 78) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 79) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 80) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 81) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 82) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 83) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 84) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 85) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 86) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 87) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick == 88) { input.aim_pos += Vec2f(52.3325,3.33292);input.action2 = true; }
            if (tick >= 89) { if (isServer() && bot !is null) KickPlayer(bot); }
        } else if (tiger) {
            /*            if (tick == 0) { blob.setPosition(Vec2f(285.142,136.3)); blob.setVelocity(Vec2f_zero); input.aim_pos = blob.getPosition(); }
                        if (tick == 0) { input.aim_pos += Vec2f(-50.666,-3.66692);input.action2 = true; input.facing_left = true; }
                        if (tick == 1) { input.aim_pos += Vec2f(-50.666,-3.66692);input.action2 = true; input.facing_left = true; }
                        if (tick == 2) { input.aim_pos += Vec2f(-50.6661,-3.66692);input.action2 = true; input.facing_left = true; }
                        if (tick == 3) { input.aim_pos += Vec2f(-50.6661,-3.66692);input.action2 = true; input.facing_left = true; }
                        if (tick == 4) { input.aim_pos += Vec2f(-50.6661,-3.66692);input.action2 = true; input.facing_left = true; }
                        if (tick == 5) { input.aim_pos += Vec2f(-50.6661,-3.66692);input.action2 = true; input.facing_left = true; }
                        if (tick == 6) { input.aim_pos += Vec2f(-50.6661,-3.66692);input.action2 = true; input.facing_left = true; }
                        if (tick == 7) { input.aim_pos += Vec2f(-50.6661,-3.66692);input.action2 = true; input.facing_left = true; }
                        if (tick == 8) { input.aim_pos += Vec2f(-50.6661,-3.66692);input.action2 = true; input.facing_left = true; }
                        if (tick == 9) { input.aim_pos += Vec2f(-50.6661,-3.66692);input.action2 = true; input.facing_left = true; }
                        if (tick == 10) { input.aim_pos += Vec2f(-50.6661,-3.66692);input.action2 = true; input.facing_left = true; }
                        if (tick == 11) { input.aim_pos += Vec2f(-50.6661,-3.66692);input.action2 = true; input.facing_left = true; }
                        if (tick == 12) { input.aim_pos += Vec2f(-50.6661,-3.66692);input.action2 = true; input.facing_left = true; }
                        if (tick == 13) { input.aim_pos += Vec2f(-50.6661,-3.66692);input.action2 = true; input.facing_left = true; }
                        if (tick == 14) { input.aim_pos += Vec2f(-50.6661,-3.66692);input.action2 = true; input.facing_left = true; }
                        if (tick == 15) { input.aim_pos += Vec2f(-50.6661,-3.66692);input.action2 = true; input.facing_left = true; }
                        if (tick == 16) { input.aim_pos += Vec2f(-50.6661,-3.66692);input.action2 = true; input.facing_left = true; }
                        if (tick == 17) { input.aim_pos += Vec2f(-50.6661,-3.66692);input.action2 = true; input.facing_left = true; }
                        if (tick == 18) { input.aim_pos += Vec2f(-50.6661,-3.66692);input.action2 = true; input.facing_left = true; }
                        if (tick == 19) { input.aim_pos += Vec2f(-50.6661,-3.66692);input.action2 = true; input.facing_left = true; }
                        if (tick == 20) { input.aim_pos += Vec2f(-50.6661,-3.66692);input.action2 = true; input.facing_left = true; }
                        if (tick == 21) { input.aim_pos += Vec2f(-50.6661,-3.66692);input.action2 = true; input.facing_left = true; }
                        if (tick == 22) { input.aim_pos += Vec2f(-50.6661,-3.66692);input.action2 = true; input.facing_left = true; }
                        if (tick == 23) { input.aim_pos += Vec2f(-50.6661,-3.66692);input.action2 = true; input.facing_left = true; }
                        if (tick == 24) { input.aim_pos += Vec2f(-50.6661,-3.66692);input.action2 = true; input.facing_left = true; }
                        if (tick == 25) { input.aim_pos += Vec2f(-50.6661,-3.66692);input.action2 = true; input.facing_left = true; }
                        if (tick == 26) { input.aim_pos += Vec2f(-50.6661,-3.66692);input.action2 = true; input.facing_left = true; }
                        if (tick == 27) { input.aim_pos += Vec2f(-50.6661,-3.66692);input.action2 = true; input.facing_left = true; }
                        if (tick == 28) { input.aim_pos += Vec2f(-50.6661,-3.66692);input.action2 = true; input.facing_left = true; }
                        if (tick == 29) { input.aim_pos += Vec2f(-50.6661,-3.66692);input.action2 = true; input.facing_left = true; }
                        if (tick == 30) { input.aim_pos += Vec2f(-50.6661,-3.66692);input.action2 = true; input.facing_left = true; }
                        if (tick == 31) { input.aim_pos += Vec2f(-50.6661,-3.66692);input.action2 = true; input.facing_left = true; }
                        if (tick == 32) { input.aim_pos += Vec2f(-52.6544,-3.66692);input.action2 = true; input.facing_left = true; }
                        if (tick == 33) { input.aim_pos += Vec2f(-11.1741,0);input.facing_left = true; }
                        if (tick == 34) { input.aim_pos += Vec2f(-10.6809,0);input.facing_left = true; }
                        if (tick == 35) { input.aim_pos += Vec2f(-10.3821,0);input.facing_left = true; }
                        if (tick == 36) { input.aim_pos += Vec2f(-10.201,0);input.facing_left = true; }
                        if (tick == 37) { input.aim_pos += Vec2f(-10.0914,0);input.facing_left = true; }
                        if (tick == 38) { input.aim_pos += Vec2f(-10.0249,0);input.facing_left = true; }
                        if (tick == 39) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
                        if (tick == 40) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
                        if (tick == 41) { input.aim_pos += Vec2f(-51.6906,-3.66692);input.action1 = true; input.left = true; input.facing_left = true; }
                        if (tick == 42) { input.aim_pos += Vec2f(-51.2123,-3.66692);input.left = true; input.facing_left = true; }
                        if (tick == 43) { input.aim_pos += Vec2f(-50.6459,-3.66692);input.action2 = true; input.left = true; input.facing_left = true; }
                        if (tick == 44) { input.aim_pos += Vec2f(-49.7558,-3.66692);input.action2 = true; input.left = true; input.facing_left = true; }
                        if (tick == 45) { input.aim_pos += Vec2f(-48.6387,-3.66692);input.action2 = true; input.facing_left = true; }
                        if (tick == 46) { input.aim_pos += Vec2f(-46.959,-3.00024);input.action2 = true; input.facing_left = true; }
                        if (tick == 47) { input.aim_pos += Vec2f(-46.9504,-3.00024);input.action2 = true; input.facing_left = true; }
                        if (tick == 48) { input.aim_pos += Vec2f(-47.226,-3.00024);input.action2 = true; input.facing_left = true; }
                        if (tick == 49) { input.aim_pos += Vec2f(-47.5428,-3.00024);input.action2 = true; input.facing_left = true; }
                        if (tick == 50) { input.aim_pos += Vec2f(-47.804,-3.00024);input.action2 = true; input.facing_left = true; }
                        if (tick == 51) { input.aim_pos += Vec2f(-48.0409,-3.00024);input.action2 = true; input.facing_left = true; }
                        if (tick == 52) { input.aim_pos += Vec2f(-48.1608,-3.00024);input.action2 = true; input.facing_left = true; }
                        if (tick == 53) { input.aim_pos += Vec2f(-48.3007,-3.00024);input.action2 = true; input.facing_left = true; }
                        if (tick == 54) { input.aim_pos += Vec2f(-48.4421,-3.00024);input.action2 = true; input.facing_left = true; }
                        if (tick == 55) { input.aim_pos += Vec2f(-48.5543,-3.00024);input.action2 = true; input.facing_left = true; }
                        if (tick == 56) { input.aim_pos += Vec2f(-48.6354,-3.00024);input.action2 = true; input.facing_left = true; }
                        if (tick == 57) { input.aim_pos += Vec2f(-48.7018,-3.00024);input.action2 = true; input.facing_left = true; }
                        if (tick == 58) { input.aim_pos += Vec2f(-48.7399,-3.00024);input.action2 = true; input.facing_left = true; }
                        if (tick == 59) { input.aim_pos += Vec2f(-48.7836,-3.00024);input.action2 = true; input.facing_left = true; }
                        if (tick == 60) { input.aim_pos += Vec2f(-48.824,-3.00024);input.action2 = true; input.facing_left = true; }
                        if (tick == 61) { input.aim_pos += Vec2f(-48.8471,-3.00024);input.action2 = true; input.facing_left = true; }
                        if (tick == 62) { input.aim_pos += Vec2f(-48.8736,-3.00024);input.facing_left = true; }
                        if (tick == 63) { input.aim_pos += Vec2f(-48.8955,-3.00024);input.facing_left = true; }
                        if (tick == 64) { input.aim_pos += Vec2f(-48.9095,-3.00024);input.facing_left = true; }
                        if (tick == 65) { input.aim_pos += Vec2f(-48.9255,-3.00024);input.facing_left = true; }
                        if (tick == 66) { input.aim_pos += Vec2f(-48.9402,-3.00024);input.facing_left = true; }
                        if (tick == 67) { input.aim_pos += Vec2f(-48.9508,-3.00024);input.facing_left = true; }
                        if (tick == 68) { input.aim_pos += Vec2f(-48.9566,-3.00024);input.facing_left = true; }
                        if (tick == 69) { input.aim_pos += Vec2f(-48.9627,-3.00024);input.facing_left = true; }
                        if (tick == 70) { input.aim_pos += Vec2f(-48.9673,-3.00024);input.facing_left = true; }
                        if (tick == 71) { input.aim_pos += Vec2f(-48.9735,-3.00024);input.facing_left = true; }
                        if (tick == 72) { input.aim_pos += Vec2f(-48.9795,-3.00024);input.facing_left = true; }
                        if (tick == 73) { input.aim_pos += Vec2f(-48.9824,-3.00024);input.facing_left = true; }
                        if (tick == 74) { input.aim_pos += Vec2f(-48.9857,-3.00024);input.facing_left = true; }
                        if (tick == 75) { input.aim_pos += Vec2f(-48.9887,-3.00024);input.facing_left = true; }
                        if (tick == 76) { input.aim_pos += Vec2f(-48.9906,-3.00024);input.facing_left = true; }
                        if (tick == 77) { input.aim_pos += Vec2f(-48.9919,-3.00024);input.facing_left = true; }
                        if (tick == 78) { input.aim_pos += Vec2f(-48.9933,-3.00024);input.facing_left = true; }
                        if (tick == 79) { input.aim_pos += Vec2f(-48.9946,-3.00024);input.facing_left = true; }
                        if (tick == 80) { input.aim_pos += Vec2f(-48.9955,-3.00024);input.facing_left = true; }
                        if (tick == 81) { input.aim_pos += Vec2f(-48.9962,-3.00024);input.facing_left = true; }
                        if (tick == 82) { input.aim_pos += Vec2f(-48.997,-3.00024);input.facing_left = true; }
                        if (tick == 83) { input.aim_pos += Vec2f(-48.9975,-3.00024);input.facing_left = true; }
                        if (tick == 84) { input.aim_pos += Vec2f(-48.9981,-3.00024);input.facing_left = true; }
                        if (tick == 85) { input.aim_pos += Vec2f(-48.9984,-3.00024);input.facing_left = true; }
                        if (tick == 86) { input.aim_pos += Vec2f(-48.9987,-3.00024);input.facing_left = true; }
                        if (tick == 87) { input.aim_pos += Vec2f(-48.9989,-3.00024);input.facing_left = true; }
                        if (tick == 88) { input.aim_pos += Vec2f(-48.9991,-3.00024);input.facing_left = true; }
                        if (tick == 89) { input.aim_pos += Vec2f(-48.9994,-3.00024);input.facing_left = true; }
                        if (tick == 90) { input.aim_pos += Vec2f(-48.9994,-3.00024);input.facing_left = true; }
                        if (tick == 91) { input.aim_pos += Vec2f(-48.9994,-3.00024);input.facing_left = true; }
                        if (tick == 92) { input.aim_pos += Vec2f(-48.9994,-3.00024);input.facing_left = true; }
                        if (tick == 93) { input.aim_pos += Vec2f(-48.9994,-3.00024);input.facing_left = true; }
                        if (tick == 94) { input.aim_pos += Vec2f(-48.9994,-3.00024);input.facing_left = true; }
                        if (tick >= 95) { if (isServer() && bot !is null) KickPlayer(bot); }
*/            if (tick == 0) { blob.setPosition(Vec2f(276.86,136.3)); blob.setVelocity(Vec2f_zero); input.aim_pos = blob.getPosition(); }
            if (tick == 0) { input.aim_pos += Vec2f(-70.9992,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick == 1) { input.aim_pos += Vec2f(-70.9992,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick == 2) { input.aim_pos += Vec2f(-72.4172,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick == 3) { input.aim_pos += Vec2f(-73.2018,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick == 4) { input.aim_pos += Vec2f(-73.4458,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick == 5) { input.aim_pos += Vec2f(-73.3588,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick == 6) { input.aim_pos += Vec2f(-73.1454,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick == 7) { input.aim_pos += Vec2f(-72.8813,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick == 8) { input.aim_pos += Vec2f(-72.6362,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick == 9) { input.aim_pos += Vec2f(-72.3711,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick == 10) { input.aim_pos += Vec2f(-72.1429,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick == 11) { input.aim_pos += Vec2f(-71.9529,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick == 12) { input.aim_pos += Vec2f(-71.8068,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick == 13) { input.aim_pos += Vec2f(-71.6712,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick == 14) { input.aim_pos += Vec2f(-71.5589,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick == 15) { input.aim_pos += Vec2f(-71.4648,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick == 16) { input.aim_pos += Vec2f(-71.3736,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick == 17) { input.aim_pos += Vec2f(-71.3145,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick == 18) { input.aim_pos += Vec2f(-71.2634,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick == 19) { input.aim_pos += Vec2f(-71.2133,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick == 20) { input.aim_pos += Vec2f(-71.1786,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick == 21) { input.aim_pos += Vec2f(-71.1494,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick == 22) { input.aim_pos += Vec2f(-71.1229,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick == 23) { input.aim_pos += Vec2f(-71.1026,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick == 24) { input.aim_pos += Vec2f(-71.0857,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick == 25) { input.aim_pos += Vec2f(-71.0714,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick == 26) { input.aim_pos += Vec2f(-71.0605,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick == 27) { input.aim_pos += Vec2f(-71.0503,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick == 28) { input.aim_pos += Vec2f(-71.0418,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick == 29) { input.aim_pos += Vec2f(-71.0347,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick == 30) { input.aim_pos += Vec2f(-71.0302,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick == 31) { input.aim_pos += Vec2f(-71.0268,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick == 32) { input.aim_pos += Vec2f(-73.0117,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick == 33) { input.aim_pos += Vec2f(-11.1741,0);input.facing_left = true; }
            if (tick == 34) { input.aim_pos += Vec2f(-10.6809,0);input.facing_left = true; }
            if (tick == 35) { input.aim_pos += Vec2f(-10.3821,0);input.facing_left = true; }
            if (tick == 36) { input.aim_pos += Vec2f(-10.201,0);input.facing_left = true; }
            if (tick == 37) { input.aim_pos += Vec2f(-10.0914,0);input.facing_left = true; }
            if (tick == 38) { input.aim_pos += Vec2f(-10.0249,0);input.facing_left = true; }
            if (tick == 39) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 40) { input.aim_pos += Vec2f(-71.9488,-0.333588);input.action1 = true; input.facing_left = true; }
            if (tick == 41) { input.aim_pos += Vec2f(-71.7746,-0.333588);input.facing_left = true; }
            if (tick == 42) { input.aim_pos += Vec2f(-71.6323,-0.333588);input.facing_left = true; }
            if (tick == 43) { input.aim_pos += Vec2f(-71.5248,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick == 44) { input.aim_pos += Vec2f(-71.4217,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick == 45) { input.aim_pos += Vec2f(-71.3504,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick == 46) { input.aim_pos += Vec2f(-71.2816,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick == 47) { input.aim_pos += Vec2f(-71.2339,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick == 48) { input.aim_pos += Vec2f(-71.1911,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick == 49) { input.aim_pos += Vec2f(-71.1563,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick == 50) { input.aim_pos += Vec2f(-71.1257,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick == 51) { input.aim_pos += Vec2f(-71.103,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick == 52) { input.aim_pos += Vec2f(-71.0844,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick == 53) { input.aim_pos += Vec2f(-71.0691,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick == 54) { input.aim_pos += Vec2f(-71.0566,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick == 55) { input.aim_pos += Vec2f(-71.0456,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick == 56) { input.aim_pos += Vec2f(-71.0374,-0.333588);input.action2 = true; input.facing_left = true; }
            if (tick >= 57) { if (isServer() && bot !is null) KickPlayer(bot); }
        }
    } else if (selected_training == Training::instaslash_slashspammer) {
        if (frog) {
            if (tick == 0) { blob.setPosition(Vec2f(267.001,136.3)); blob.setVelocity(Vec2f_zero); input.aim_pos = blob.getPosition(); }
            if (tick == 0) { input.aim_pos += Vec2f(63.9801,-4.66708);}
            if (tick == 1) { input.aim_pos += Vec2f(63.9835,-4.66708);}
            if (tick == 2) { input.aim_pos += Vec2f(63.9866,-4.66708);}
            if (tick == 3) { input.aim_pos += Vec2f(63.989,-4.66708);}
            if (tick == 4) { input.aim_pos += Vec2f(63.991,-4.66708);}
            if (tick == 5) { input.aim_pos += Vec2f(63.9927,-4.66708);input.action1 = true; }
            if (tick == 6) { input.aim_pos += Vec2f(63.994,-4.66708);input.action1 = true; }
            if (tick == 7) { input.aim_pos += Vec2f(63.9951,-4.66708);input.action1 = true; }
            if (tick == 8) { input.aim_pos += Vec2f(63.996,-4.66708);input.action1 = true; }
            if (tick == 9) { input.aim_pos += Vec2f(63.9967,-4.66708);input.action1 = true; }
            if (tick == 10) { input.aim_pos += Vec2f(63.9973,-4.66708);input.action1 = true; }
            if (tick == 11) { input.aim_pos += Vec2f(63.9977,-4.66708);input.action1 = true; }
            if (tick == 12) { input.aim_pos += Vec2f(63.998,-4.66708);input.action1 = true; }
            if (tick == 13) { input.aim_pos += Vec2f(63.9982,-4.66708);input.action1 = true; }
            if (tick == 14) { input.aim_pos += Vec2f(63.9986,-4.66708);input.action1 = true; }
            if (tick == 15) { input.aim_pos += Vec2f(63.9989,-4.66708);input.action1 = true; }
            if (tick == 16) { input.aim_pos += Vec2f(63.9992,-4.66708);input.action1 = true; }
            if (tick == 17) { input.aim_pos += Vec2f(63.9992,-4.66708);input.action1 = true; }
            if (tick == 18) { input.aim_pos += Vec2f(63.9992,-4.66708);input.action1 = true; }
            if (tick == 19) { input.aim_pos += Vec2f(63.9992,-4.66708);input.action1 = true; }
            if (tick == 20) { input.aim_pos += Vec2f(63.9992,-4.66708);}
            if (tick == 21) { input.aim_pos += Vec2f(63.9992,-4.66708);input.action1 = true; }
            if (tick == 22) { input.aim_pos += Vec2f(63.9992,-4.66708);}
            if (tick == 23) { input.aim_pos += Vec2f(63.9992,-4.66708);}
            if (tick == 24) { input.aim_pos += Vec2f(63.9992,-4.66708);}
            if (tick == 25) { input.aim_pos += Vec2f(63.9992,-4.66708);}
            if (tick == 26) { input.aim_pos += Vec2f(63.9992,-4.66708);}
            if (tick == 27) { input.aim_pos += Vec2f(63.9992,-4.66708);}
            if (tick == 28) { input.aim_pos += Vec2f(63.9992,-4.66708);}
            if (tick == 29) { input.aim_pos += Vec2f(63.9992,-4.66708);input.action1 = true; }
            if (tick == 30) { input.aim_pos += Vec2f(63.9992,-4.66708);input.action1 = true; }
            if (tick == 31) { input.aim_pos += Vec2f(63.9992,-4.66708);input.action1 = true; }
            if (tick == 32) { input.aim_pos += Vec2f(63.9992,-4.66708);input.action1 = true; }
            if (tick == 33) { input.aim_pos += Vec2f(63.9992,-4.66708);input.action1 = true; }
            if (tick == 34) { input.aim_pos += Vec2f(63.9992,-4.66708);input.action1 = true; }
            if (tick == 35) { input.aim_pos += Vec2f(63.9992,-4.66708);input.action1 = true; }
            if (tick == 36) { input.aim_pos += Vec2f(63.9992,-4.66708);input.action1 = true; }
            if (tick == 37) { input.aim_pos += Vec2f(63.9992,-4.66708);input.action1 = true; }
            if (tick == 38) { input.aim_pos += Vec2f(63.9992,-4.66707);input.action1 = true; }
            if (tick == 39) { input.aim_pos += Vec2f(63.9992,-4.66707);input.action1 = true; }
            if (tick == 40) { input.aim_pos += Vec2f(63.9992,-4.66707);input.action1 = true; }
            if (tick == 41) { input.aim_pos += Vec2f(63.9992,-4.66707);input.action1 = true; }
            if (tick == 42) { input.aim_pos += Vec2f(63.9992,-4.66707);input.action1 = true; }
            if (tick == 43) { input.aim_pos += Vec2f(63.9992,-4.66707);input.action1 = true; }
            if (tick == 44) { input.aim_pos += Vec2f(63.9992,-4.66707);input.action1 = true; }
            if (tick == 45) { input.aim_pos += Vec2f(63.9992,-4.66707);input.action1 = true; }
            if (tick == 46) { input.aim_pos += Vec2f(63.9992,-4.66707);input.action1 = true; }
            if (tick == 47) { input.aim_pos += Vec2f(63.9992,-4.66707);input.action1 = true; }
            if (tick == 48) { input.aim_pos += Vec2f(63.9992,-4.66707);input.action1 = true; }
            if (tick == 49) { input.aim_pos += Vec2f(63.9992,-4.66707);input.action1 = true; }
            if (tick == 50) { input.aim_pos += Vec2f(63.9992,-4.66707);input.action1 = true; }
            if (tick == 51) { input.aim_pos += Vec2f(63.9992,-4.66707);input.action1 = true; }
            if (tick == 52) { input.aim_pos += Vec2f(63.9992,-4.66707);input.action1 = true; }
            if (tick == 53) { input.aim_pos += Vec2f(63.9992,-4.66707);input.action1 = true; }
            if (tick == 54) { input.aim_pos += Vec2f(63.9992,-4.66707);input.action1 = true; }
            if (tick == 55) { input.aim_pos += Vec2f(63.9992,-4.66707);input.action1 = true; }
            if (tick == 56) { input.aim_pos += Vec2f(63.9992,-4.66707);input.action1 = true; }
            if (tick == 57) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 58) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 59) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 60) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 61) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 62) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 63) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 64) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 65) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 66) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 67) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 68) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 69) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 70) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 71) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 72) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 73) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 74) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 75) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 76) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 77) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 78) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 79) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 80) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 81) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 82) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 83) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 84) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 85) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 86) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 87) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 88) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 89) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 90) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 91) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 92) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 93) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 94) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 95) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 96) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 97) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 98) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 99) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 100) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 101) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 102) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 103) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 104) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 105) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 106) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 107) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 108) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 109) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 110) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 111) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 112) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 113) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick == 114) { input.aim_pos += Vec2f(63.9992,-4.66707);}
            if (tick >= 115) { if (isServer() && bot !is null) KickPlayer(bot); }
        } else if (tiger) {
            /*
            if (tick == 0) { blob.setPosition(Vec2f(278.418,136.3)); blob.setVelocity(Vec2f_zero); input.aim_pos = blob.getPosition(); }
            if (tick == 0) { input.aim_pos += Vec2f(-33.4428,4.66621);input.action2 = true; input.facing_left = true; }
            if (tick == 1) { input.aim_pos += Vec2f(-33.4795,4.66621);input.action2 = true; input.facing_left = true; }
            if (tick == 2) { input.aim_pos += Vec2f(-34.0754,4.66623);input.action2 = true; input.facing_left = true; }
            if (tick == 3) { input.aim_pos += Vec2f(-34.4341,4.66623);input.action2 = true; input.facing_left = true; }
            if (tick == 4) { input.aim_pos += Vec2f(-34.5672,4.66623);input.action2 = true; input.facing_left = true; }
            if (tick == 5) { input.aim_pos += Vec2f(-34.5756,4.66623);input.action2 = true; input.facing_left = true; }
            if (tick == 6) { input.aim_pos += Vec2f(-34.5183,4.66623);input.action2 = true; input.facing_left = true; }
            if (tick == 7) { input.aim_pos += Vec2f(-34.3919,4.66623);input.action2 = true; input.facing_left = true; }
            if (tick == 8) { input.aim_pos += Vec2f(-34.3077,4.66623);input.action2 = true; input.facing_left = true; }
            if (tick == 9) { input.aim_pos += Vec2f(-34.2121,4.66623);input.action2 = true; input.facing_left = true; }
            if (tick == 10) { input.aim_pos += Vec2f(-34.1299,4.66623);input.action2 = true; input.facing_left = true; }
            if (tick == 11) { input.aim_pos += Vec2f(-34.0593,4.66623);input.action2 = true; input.facing_left = true; }
            if (tick == 12) { input.aim_pos += Vec2f(-34.004,4.66623);input.action2 = true; input.facing_left = true; }
            if (tick == 13) { input.aim_pos += Vec2f(-33.951,4.66623);input.action2 = true; input.facing_left = true; }
            if (tick == 14) { input.aim_pos += Vec2f(-33.9061,4.66623);input.action2 = true; input.facing_left = true; }
            if (tick == 15) { input.aim_pos += Vec2f(-33.868,4.66623);input.action2 = true; input.facing_left = true; }
            if (tick == 16) { input.aim_pos += Vec2f(-33.8339,4.66623);input.action2 = true; input.facing_left = true; }
            if (tick == 17) { input.aim_pos += Vec2f(-33.8097,4.66623);input.action2 = true; input.facing_left = true; }
            if (tick == 18) { input.aim_pos += Vec2f(-33.7889,4.66623);input.action2 = true; input.facing_left = true; }
            if (tick == 19) { input.aim_pos += Vec2f(-33.7722,4.66623);input.action2 = true; input.facing_left = true; }
            if (tick == 20) { input.aim_pos += Vec2f(-33.7546,4.66623);input.action2 = true; input.facing_left = true; }
            if (tick == 21) { input.aim_pos += Vec2f(-33.7399,4.66623);input.action2 = true; input.facing_left = true; }
            if (tick == 22) { input.aim_pos += Vec2f(-33.7277,4.66623);input.action2 = true; input.facing_left = true; }
            if (tick == 23) { input.aim_pos += Vec2f(-33.7175,4.66623);input.action2 = true; input.facing_left = true; }
            if (tick == 24) { input.aim_pos += Vec2f(-33.7096,4.66623);input.action2 = true; input.facing_left = true; }
            if (tick == 25) { input.aim_pos += Vec2f(-33.7017,4.66623);input.action2 = true; input.facing_left = true; }
            if (tick == 26) { input.aim_pos += Vec2f(-33.6958,4.66623);input.action2 = true; input.facing_left = true; }
            if (tick == 27) { input.aim_pos += Vec2f(-33.6909,4.66623);input.action2 = true; input.facing_left = true; }
            if (tick == 28) { input.aim_pos += Vec2f(-11.9883,0);input.facing_left = true; }
            if (tick == 29) { input.aim_pos += Vec2f(-11.1741,0);input.facing_left = true; }
            if (tick == 30) { input.aim_pos += Vec2f(-10.6809,0);input.facing_left = true; }
            if (tick == 31) { input.aim_pos += Vec2f(-10.3821,0);input.facing_left = true; }
            if (tick == 32) { input.aim_pos += Vec2f(-10.201,0);input.facing_left = true; }
            if (tick == 33) { input.aim_pos += Vec2f(-10.0914,0);input.facing_left = true; }
            if (tick == 34) { input.aim_pos += Vec2f(-10.0249,0);input.facing_left = true; }
            if (tick == 35) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 36) { input.aim_pos += Vec2f(-37.369,2.3329);input.action1 = true; input.facing_left = true; }
            if (tick == 37) { input.aim_pos += Vec2f(-37.1155,2.3329);input.action1 = true; input.facing_left = true; }
            if (tick == 38) { input.aim_pos += Vec2f(-36.9095,2.3329);input.action1 = true; input.facing_left = true; }
            if (tick == 39) { input.aim_pos += Vec2f(-36.742,2.3329);input.action1 = true; input.facing_left = true; }
            if (tick == 40) { input.aim_pos += Vec2f(-36.6055,2.3329);input.action1 = true; input.facing_left = true; }
            if (tick == 41) { input.aim_pos += Vec2f(-36.4944,2.3329);input.action1 = true; input.facing_left = true; }
            if (tick == 42) { input.aim_pos += Vec2f(-36.4041,2.3329);input.action1 = true; input.facing_left = true; }
            if (tick == 43) { input.aim_pos += Vec2f(-36.3301,2.3329);input.action1 = true; input.facing_left = true; }
            if (tick == 44) { input.aim_pos += Vec2f(-36.2656,2.3329);input.action1 = true; input.facing_left = true; }
            if (tick == 45) { input.aim_pos += Vec2f(-36.2175,2.3329);input.action1 = true; input.facing_left = true; }
            if (tick == 46) { input.aim_pos += Vec2f(-36.178,2.3329);input.action1 = true; input.facing_left = true; }
            if (tick == 47) { input.aim_pos += Vec2f(-36.1481,2.3329);input.action1 = true; input.facing_left = true; }
            if (tick == 48) { input.aim_pos += Vec2f(-36.1211,2.3329);input.action1 = true; input.facing_left = true; }
            if (tick == 49) { input.aim_pos += Vec2f(-36.099,2.3329);input.action1 = true; input.left = true; input.facing_left = true; }
            if (tick == 50) { input.aim_pos += Vec2f(-35.6717,2.3329);input.action1 = true; input.left = true; input.facing_left = true; }
            if (tick == 51) { input.aim_pos += Vec2f(-34.9052,1.99957);input.action1 = true; input.left = true; input.facing_left = true; }
            if (tick == 52) { input.aim_pos += Vec2f(-35.885,-2.33376);input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 53) { input.aim_pos += Vec2f(-38.3138,-3.92909);input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 54) { input.aim_pos += Vec2f(-39.3703,-2.17024);input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 55) { input.aim_pos += Vec2f(-38.6012,-1.05612);input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 56) { input.aim_pos += Vec2f(-37.7578,-0.357452);input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 57) { input.aim_pos += Vec2f(-35.369,1.00365);input.action2 = true; input.facing_left = true; }
            if (tick == 58) { input.aim_pos += Vec2f(-34.1368,0.727341);input.action2 = true; input.facing_left = true; }
            if (tick == 59) { input.aim_pos += Vec2f(-31.1154,0.826019);input.action2 = true; input.facing_left = true; }
            if (tick == 60) { input.aim_pos += Vec2f(-24.459,1.9599);input.action2 = true; input.facing_left = true; }
            if (tick == 61) { input.aim_pos += Vec2f(-24.2869,2.05803);input.action1 = true; input.action2 = true; input.facing_left = true; }
            if (tick == 62) { input.aim_pos += Vec2f(-24.8331,1.73227);input.action1 = true; input.action2 = true; input.facing_left = true; }
            if (tick == 63) { input.aim_pos += Vec2f(-25.9932,0.556229);input.action2 = true; input.facing_left = true; }
            if (tick == 64) { input.aim_pos += Vec2f(-26.9865,0.222855);input.action2 = true; input.facing_left = true; }
            if (tick == 65) { input.aim_pos += Vec2f(-28.0055,-0.598541);input.action2 = true; input.facing_left = true; }
            if (tick == 66) { input.aim_pos += Vec2f(-28.7027,-0.142365);input.action1 = true; input.action2 = true; input.facing_left = true; }
            if (tick == 67) { input.aim_pos += Vec2f(-29.3258,0.451508);input.action1 = true; input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 68) { input.aim_pos += Vec2f(-30.0134,-1.13853);input.action2 = true; input.facing_left = true; }
            if (tick == 69) { input.aim_pos += Vec2f(-31.713,-2.75948);input.action2 = true; input.facing_left = true; }
            if (tick == 70) { input.aim_pos += Vec2f(-32.1413,-2.424);input.action2 = true; input.facing_left = true; }
            if (tick == 71) { input.aim_pos += Vec2f(-32.5256,-2.13525);input.action1 = true; input.action2 = true; input.facing_left = true; }
            if (tick == 72) { input.aim_pos += Vec2f(-32.7899,-1.93697);input.action1 = true; input.action2 = true; input.facing_left = true; }
            if (tick == 73) { input.aim_pos += Vec2f(-33.0025,-1.77275);input.action2 = true; input.facing_left = true; }
            if (tick == 74) { input.aim_pos += Vec2f(-33.1912,-1.6266);input.action2 = true; input.facing_left = true; }
            if (tick == 75) { input.aim_pos += Vec2f(-33.3435,-1.50864);input.action2 = true; input.facing_left = true; }
            if (tick == 76) { input.aim_pos += Vec2f(-33.4662,-1.41353);input.action2 = true; input.facing_left = true; }
            if (tick == 77) { input.aim_pos += Vec2f(-33.5657,-1.33649);input.action2 = true; input.facing_left = true; }
            if (tick == 78) { input.aim_pos += Vec2f(-33.6407,-1.27841);input.action2 = true; input.facing_left = true; }
            if (tick == 79) { input.aim_pos += Vec2f(-33.3744,-1.22647);input.action2 = true; input.facing_left = true; }
            if (tick == 80) { input.aim_pos += Vec2f(-33.4324,-1.18155);input.action2 = true; input.facing_left = true; }
            if (tick == 81) { input.aim_pos += Vec2f(-33.4725,-1.15045);input.action2 = true; input.facing_left = true; }
            if (tick == 82) { input.aim_pos += Vec2f(-33.5085,-1.12263);input.action2 = true; input.facing_left = true; }
            if (tick == 83) { input.aim_pos += Vec2f(-33.5377,-1.09996);input.action2 = true; input.facing_left = true; }
            if (tick == 84) { input.aim_pos += Vec2f(-33.5631,-1.08023);input.action2 = true; input.facing_left = true; }
            if (tick == 85) { input.aim_pos += Vec2f(-33.582,-1.06558);input.action2 = true; input.facing_left = true; }
            if (tick == 86) { input.aim_pos += Vec2f(-33.5963,-1.05453);input.action2 = true; input.facing_left = true; }
            if (tick == 87) { input.aim_pos += Vec2f(-33.6101,-1.04382);input.action2 = true; input.facing_left = true; }
            if (tick == 88) { input.aim_pos += Vec2f(-33.6197,-1.03641);input.action2 = true; input.facing_left = true; }
            if (tick == 89) { input.aim_pos += Vec2f(-33.6283,-1.02974);input.action2 = true; input.facing_left = true; }
            if (tick == 90) { input.aim_pos += Vec2f(-33.6353,-1.02429);input.action2 = true; input.facing_left = true; }
            if (tick == 91) { input.aim_pos += Vec2f(-33.6406,-1.02017);input.action2 = true; input.facing_left = true; }
            if (tick == 92) { input.aim_pos += Vec2f(-33.6454,-1.01646);input.action2 = true; input.facing_left = true; }
            if (tick == 93) { input.aim_pos += Vec2f(-33.649,-1.01366);input.action2 = true; input.facing_left = true; }
            if (tick >= 94) { if (isServer() && bot !is null) KickPlayer(bot); }
            */
            if (tick == 0) { blob.setPosition(Vec2f(279.507,136.3)); blob.setVelocity(Vec2f_zero); input.aim_pos = blob.getPosition(); }
            if (tick == 0) { input.aim_pos += Vec2f(-55.3342,-13.3337);input.action2 = true; input.facing_left = true; }
            if (tick == 1) { input.aim_pos += Vec2f(-55.3342,-13.3337);input.action2 = true; input.facing_left = true; }
            if (tick == 2) { input.aim_pos += Vec2f(-55.7471,-13.3337);input.action2 = true; input.facing_left = true; }
            if (tick == 3) { input.aim_pos += Vec2f(-55.982,-13.3337);input.action2 = true; input.facing_left = true; }
            if (tick == 4) { input.aim_pos += Vec2f(-56.0545,-13.3337);input.action2 = true; input.facing_left = true; }
            if (tick == 5) { input.aim_pos += Vec2f(-56.0426,-13.3337);input.action2 = true; input.facing_left = true; }
            if (tick == 6) { input.aim_pos += Vec2f(-55.9483,-13.3337);input.action2 = true; input.facing_left = true; }
            if (tick == 7) { input.aim_pos += Vec2f(-55.8674,-13.3337);input.action2 = true; input.facing_left = true; }
            if (tick == 8) { input.aim_pos += Vec2f(-55.7948,-13.3337);input.action2 = true; input.facing_left = true; }
            if (tick == 9) { input.aim_pos += Vec2f(-55.7371,-13.3337);input.action2 = true; input.facing_left = true; }
            if (tick == 10) { input.aim_pos += Vec2f(-55.6847,-13.3337);input.action2 = true; input.facing_left = true; }
            if (tick == 11) { input.aim_pos += Vec2f(-55.6329,-13.3337);input.action2 = true; input.facing_left = true; }
            if (tick == 12) { input.aim_pos += Vec2f(-55.5921,-13.3337);input.action2 = true; input.facing_left = true; }
            if (tick == 13) { input.aim_pos += Vec2f(-55.5525,-13.3337);input.action2 = true; input.facing_left = true; }
            if (tick == 14) { input.aim_pos += Vec2f(-55.5186,-13.3337);input.action2 = true; input.facing_left = true; }
            if (tick == 15) { input.aim_pos += Vec2f(-55.4898,-13.3337);input.action2 = true; input.facing_left = true; }
            if (tick == 16) { input.aim_pos += Vec2f(-55.4633,-13.3337);input.action2 = true; input.facing_left = true; }
            if (tick == 17) { input.aim_pos += Vec2f(-55.4471,-13.3337);input.action2 = true; input.facing_left = true; }
            if (tick == 18) { input.aim_pos += Vec2f(-55.4292,-13.3337);input.action2 = true; input.facing_left = true; }
            if (tick == 19) { input.aim_pos += Vec2f(-55.4138,-13.3337);input.action2 = true; input.facing_left = true; }
            if (tick == 20) { input.aim_pos += Vec2f(-55.4018,-13.3337);input.action2 = true; input.facing_left = true; }
            if (tick == 21) { input.aim_pos += Vec2f(-55.3897,-13.3337);input.action2 = true; input.facing_left = true; }
            if (tick == 22) { input.aim_pos += Vec2f(-55.3806,-13.3337);input.action2 = true; input.facing_left = true; }
            if (tick == 23) { input.aim_pos += Vec2f(-55.3722,-13.3337);input.action2 = true; input.facing_left = true; }
            if (tick == 24) { input.aim_pos += Vec2f(-55.3664,-13.3337);input.action2 = true; input.facing_left = true; }
            if (tick == 25) { input.aim_pos += Vec2f(-55.361,-13.3337);input.action2 = true; input.facing_left = true; }
            if (tick == 26) { input.aim_pos += Vec2f(-57.3446,-13.3337);input.action2 = true; input.facing_left = true; }
            if (tick == 27) { input.aim_pos += Vec2f(-11.1741,0);input.facing_left = true; }
            if (tick == 28) { input.aim_pos += Vec2f(-10.6809,0);input.facing_left = true; }
            if (tick == 29) { input.aim_pos += Vec2f(-10.3821,0);input.facing_left = true; }
            if (tick == 30) { input.aim_pos += Vec2f(-10.201,0);input.facing_left = true; }
            if (tick == 31) { input.aim_pos += Vec2f(-10.0914,0);input.facing_left = true; }
            if (tick == 32) { input.aim_pos += Vec2f(-10.025,0);input.facing_left = true; }
            if (tick == 33) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 34) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 35) { input.aim_pos += Vec2f(-56.4353,-13.3337);input.action2 = true; input.facing_left = true; }
            if (tick == 36) { input.aim_pos += Vec2f(-56.2337,-13.3337);input.action1 = true; input.action2 = true; input.facing_left = true; }
            if (tick == 37) { input.aim_pos += Vec2f(-56.0688,-13.3337);input.action1 = true; input.action2 = true; input.facing_left = true; }
            if (tick == 38) { input.aim_pos += Vec2f(-55.9343,-13.3337);input.action1 = true; input.facing_left = true; }
            if (tick == 39) { input.aim_pos += Vec2f(-55.8327,-13.3337);input.action1 = true; input.facing_left = true; }
            if (tick == 40) { input.aim_pos += Vec2f(-55.7473,-13.3337);input.action1 = true; input.facing_left = true; }
            if (tick == 41) { input.aim_pos += Vec2f(-55.6764,-13.3337);input.action1 = true; input.facing_left = true; }
            if (tick == 42) { input.aim_pos += Vec2f(-55.6081,-13.3337);input.action1 = true; input.facing_left = true; }
            if (tick == 43) { input.aim_pos += Vec2f(-55.5611,-13.3337);input.action1 = true; input.facing_left = true; }
            if (tick == 44) { input.aim_pos += Vec2f(-55.5189,-13.3337);input.action1 = true; input.facing_left = true; }
            if (tick == 45) { input.aim_pos += Vec2f(-55.4846,-13.3337);input.action1 = true; input.facing_left = true; }
            if (tick == 46) { input.aim_pos += Vec2f(-55.4566,-13.3337);input.action1 = true; input.facing_left = true; }
            if (tick == 47) { input.aim_pos += Vec2f(-55.434,-13.3337);input.action1 = true; input.facing_left = true; }
            if (tick == 48) { input.aim_pos += Vec2f(-55.4155,-13.3337);input.action1 = true; input.facing_left = true; }
            if (tick == 49) { input.aim_pos += Vec2f(-55.4059,-13.3337);input.action1 = true; input.left = true; input.facing_left = true; }
            if (tick == 50) { input.aim_pos += Vec2f(-54.9839,-13.3337);input.action1 = true; input.left = true; input.facing_left = true; }
            if (tick == 51) { input.aim_pos += Vec2f(-55.8893,-15.6671);input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 52) { input.aim_pos += Vec2f(-63.5552,-21.0004);input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 53) { input.aim_pos += Vec2f(-83.4859,-29.3337);input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 54) { input.aim_pos += Vec2f(-81.5466,-29.0004);input.action2 = true; input.facing_left = true; }
            if (tick == 55) { input.aim_pos += Vec2f(-81.8275,-25.3337);input.action2 = true; input.facing_left = true; }
            if (tick == 56) { input.aim_pos += Vec2f(-81.1054,-23.3337);input.action2 = true; input.facing_left = true; }
            if (tick == 57) { input.aim_pos += Vec2f(-80.8557,-22.6671);input.action2 = true; input.facing_left = true; }
            if (tick == 58) { input.aim_pos += Vec2f(-80.9376,-22.6671);input.action2 = true; input.facing_left = true; }
            if (tick == 59) { input.aim_pos += Vec2f(-80.3176,-22.6671);input.action2 = true; input.facing_left = true; }
            if (tick == 60) { input.aim_pos += Vec2f(-80.3273,-22.0004);input.action2 = true; input.facing_left = true; }
            if (tick == 61) { input.aim_pos += Vec2f(-77.5806,-21.6671);input.action1 = true; input.action2 = true; input.facing_left = true; }
            if (tick == 62) { input.aim_pos += Vec2f(-76.4025,-21.3337);input.action1 = true; input.action2 = true; input.facing_left = true; }
            if (tick == 63) { input.aim_pos += Vec2f(-75.8358,-21.3337);input.action1 = true; input.action2 = true; input.facing_left = true; }
            if (tick == 64) { input.aim_pos += Vec2f(-74.1593,-21.0004);input.action2 = true; input.facing_left = true; }
            if (tick == 65) { input.aim_pos += Vec2f(-74.4266,-21.0004);input.action2 = true; input.facing_left = true; }
            if (tick == 66) { input.aim_pos += Vec2f(-74.6639,-21.0004);input.action2 = true; input.facing_left = true; }
            if (tick == 67) { input.aim_pos += Vec2f(-74.8411,-21.0004);input.action1 = true; input.action2 = true; input.facing_left = true; }
            if (tick == 68) { input.aim_pos += Vec2f(-74.9875,-21.0004);input.action1 = true; input.action2 = true; input.facing_left = true; }
            if (tick == 69) { input.aim_pos += Vec2f(-75.1075,-21.0004);input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 70) { input.aim_pos += Vec2f(-74.7978,-21.0004);input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 71) { input.aim_pos += Vec2f(-74.1276,-21.0004);input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 72) { input.aim_pos += Vec2f(-73.2112,-21.0004);input.action2 = true; input.facing_left = true; }
            if (tick == 73) { input.aim_pos += Vec2f(-72.979,-21.0004);input.action2 = true; input.facing_left = true; }
            if (tick == 74) { input.aim_pos += Vec2f(-73.1074,-21.0004);input.action2 = true; input.facing_left = true; }
            if (tick == 75) { input.aim_pos += Vec2f(-73.4622,-21.0004);input.action2 = true; input.facing_left = true; }
            if (tick == 76) { input.aim_pos += Vec2f(-73.5131,-20.3337);input.action2 = true; input.facing_left = true; }
            if (tick == 77) { input.aim_pos += Vec2f(-73.5015,-19.6671);input.action2 = true; input.facing_left = true; }
            if (tick == 78) { input.aim_pos += Vec2f(-73.7874,-19.6671);input.action2 = true; input.facing_left = true; }
            if (tick == 79) { input.aim_pos += Vec2f(-74.0172,-19.6671);input.action2 = true; input.facing_left = true; }
            if (tick == 80) { input.aim_pos += Vec2f(-74.2026,-19.3337);input.action2 = true; input.facing_left = true; }
            if (tick == 81) { input.aim_pos += Vec2f(-74.3525,-19.3337);input.action2 = true; input.facing_left = true; }
            if (tick == 82) { input.aim_pos += Vec2f(-74.4739,-19.3337);input.action2 = true; input.facing_left = true; }
            if (tick == 83) { input.aim_pos += Vec2f(-74.5722,-19.3337);input.action2 = true; input.facing_left = true; }
            if (tick == 84) { input.aim_pos += Vec2f(-74.6462,-19.3337);input.action2 = true; input.facing_left = true; }
            if (tick == 85) { input.aim_pos += Vec2f(-74.7122,-19.3337);input.action2 = true; input.facing_left = true; }
            if (tick == 86) { input.aim_pos += Vec2f(-74.7657,-19.3337);input.action2 = true; input.facing_left = true; }
            if (tick == 87) { input.aim_pos += Vec2f(-74.8061,-19.3337);input.action2 = true; input.facing_left = true; }
            if (tick == 88) { input.aim_pos += Vec2f(-74.8447,-19.3337);input.action2 = true; input.facing_left = true; }
            if (tick == 89) { input.aim_pos += Vec2f(-74.8713,-19.3337);input.facing_left = true; }
            if (tick == 90) { input.aim_pos += Vec2f(-74.8934,-19.3337);input.facing_left = true; }
            if (tick == 91) { input.aim_pos += Vec2f(-74.9133,-19.3337);input.facing_left = true; }
            if (tick == 92) { input.aim_pos += Vec2f(-74.9294,-19.3337);input.facing_left = true; }
            if (tick == 93) { input.aim_pos += Vec2f(-74.9424,-19.3337);input.facing_left = true; }
            if (tick == 94) { input.aim_pos += Vec2f(-74.9523,-19.3337);input.facing_left = true; }
            if (tick == 95) { input.aim_pos += Vec2f(-74.9612,-19.3337);input.facing_left = true; }
            if (tick == 96) { input.aim_pos += Vec2f(-74.9678,-19.3337);input.facing_left = true; }
            if (tick == 97) { input.aim_pos += Vec2f(-74.9738,-19.3337);input.facing_left = true; }
            if (tick == 98) { input.aim_pos += Vec2f(-74.9787,-19.3337);input.facing_left = true; }
            if (tick == 99) { input.aim_pos += Vec2f(-74.9826,-19.3337);input.facing_left = true; }
            if (tick == 100) { input.aim_pos += Vec2f(-74.9856,-19.3337);input.facing_left = true; }
            if (tick >= 101) { if (isServer() && bot !is null) KickPlayer(bot); }
        }
    } else if (selected_training == Training::instaslash_fast_slashspammer) {
        if (frog) {
            if (tick == 0) { blob.setPosition(Vec2f(266.875,136.3)); blob.setVelocity(Vec2f_zero); input.aim_pos = blob.getPosition(); }
            if (tick == 0) { input.aim_pos += Vec2f(41.8112,-1.33327);}
            if (tick == 1) { input.aim_pos += Vec2f(41.7834,-1.33327);}
            if (tick == 2) { input.aim_pos += Vec2f(41.7625,-1.33327);}
            if (tick == 3) { input.aim_pos += Vec2f(41.7453,-1.33327);}
            if (tick == 4) { input.aim_pos += Vec2f(41.7322,-1.33327);input.action1 = true; }
            if (tick == 5) { input.aim_pos += Vec2f(41.7204,-1.33327);input.action1 = true; }
            if (tick == 6) { input.aim_pos += Vec2f(41.7113,-1.33327);input.action1 = true; }
            if (tick == 7) { input.aim_pos += Vec2f(41.7026,-1.33327);input.action1 = true; }
            if (tick == 8) { input.aim_pos += Vec2f(41.6956,-1.33327);input.action1 = true; }
            if (tick == 9) { input.aim_pos += Vec2f(41.6904,-1.33327);input.action1 = true; }
            if (tick == 10) { input.aim_pos += Vec2f(41.6858,-1.33327);input.action1 = true; }
            if (tick == 11) { input.aim_pos += Vec2f(41.6822,-1.33327);input.action1 = true; }
            if (tick == 12) { input.aim_pos += Vec2f(41.6794,-1.33327);input.action1 = true; }
            if (tick == 13) { input.aim_pos += Vec2f(41.6771,-1.33327);input.action1 = true; }
            if (tick == 14) { input.aim_pos += Vec2f(41.6753,-1.33327);input.action1 = true; }
            if (tick == 15) { input.aim_pos += Vec2f(41.6736,-1.33327);input.action1 = true; }
            if (tick == 16) { input.aim_pos += Vec2f(41.6724,-1.33327);input.action1 = true; }
            if (tick == 17) { input.aim_pos += Vec2f(41.6713,-1.33327);input.action1 = true; }
            if (tick == 18) { input.aim_pos += Vec2f(41.6705,-1.33327);input.action1 = true; }
            if (tick == 19) { input.aim_pos += Vec2f(41.6697,-1.33327);input.action1 = true; }
            if (tick == 20) { input.aim_pos += Vec2f(41.6693,-1.33327);input.action1 = true; }
            if (tick == 21) { input.aim_pos += Vec2f(41.6689,-1.33327);input.action1 = true; }
            if (tick == 22) { input.aim_pos += Vec2f(41.6685,-1.33327);}
            if (tick == 23) { input.aim_pos += Vec2f(41.6681,-1.33327);}
            if (tick == 24) { input.aim_pos += Vec2f(41.6677,-1.33327);}
            if (tick == 25) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 26) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 27) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 28) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 29) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 30) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 31) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 32) { input.aim_pos += Vec2f(41.6676,-1.33327);input.action1 = true; }
            if (tick == 33) { input.aim_pos += Vec2f(41.6676,-1.33327);input.action1 = true; }
            if (tick == 34) { input.aim_pos += Vec2f(41.6676,-1.33327);input.action1 = true; }
            if (tick == 35) { input.aim_pos += Vec2f(41.6676,-1.33327);input.action1 = true; }
            if (tick == 36) { input.aim_pos += Vec2f(41.6676,-1.33327);input.action1 = true; }
            if (tick == 37) { input.aim_pos += Vec2f(41.6676,-1.33327);input.action1 = true; }
            if (tick == 38) { input.aim_pos += Vec2f(41.6676,-1.33327);input.action1 = true; }
            if (tick == 39) { input.aim_pos += Vec2f(41.6676,-1.33327);input.action1 = true; }
            if (tick == 40) { input.aim_pos += Vec2f(41.6676,-1.33327);input.action1 = true; }
            if (tick == 41) { input.aim_pos += Vec2f(41.6676,-1.33327);input.action1 = true; }
            if (tick == 42) { input.aim_pos += Vec2f(41.6676,-1.33327);input.action1 = true; }
            if (tick == 43) { input.aim_pos += Vec2f(41.6676,-1.33327);input.action1 = true; }
            if (tick == 44) { input.aim_pos += Vec2f(41.6676,-1.33327);input.action1 = true; }
            if (tick == 45) { input.aim_pos += Vec2f(41.6676,-1.33327);input.action1 = true; }
            if (tick == 46) { input.aim_pos += Vec2f(41.6676,-1.33327);input.action1 = true; }
            if (tick == 47) { input.aim_pos += Vec2f(41.6676,-1.33327);input.action1 = true; }
            if (tick == 48) { input.aim_pos += Vec2f(41.6676,-1.33327);input.action1 = true; }
            if (tick == 49) { input.aim_pos += Vec2f(41.6676,-1.33327);input.action1 = true; }
            if (tick == 50) { input.aim_pos += Vec2f(41.6676,-1.33327);input.action1 = true; }
            if (tick == 51) { input.aim_pos += Vec2f(41.6676,-1.33327);input.action1 = true; }
            if (tick == 52) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 53) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 54) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 55) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 56) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 57) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 58) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 59) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 60) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 61) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 62) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 63) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 64) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 65) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 66) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 67) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 68) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 69) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 70) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 71) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 72) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 73) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 74) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 75) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 76) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 77) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 78) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 79) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 80) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 81) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 82) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 83) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 84) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 85) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 86) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 87) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 88) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 89) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 90) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 91) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 92) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 93) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 94) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 95) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 96) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick == 97) { input.aim_pos += Vec2f(41.6676,-1.33327);}
            if (tick >= 98) { if (isServer() && bot !is null) KickPlayer(bot); }
        } else if (tiger) {
            if (tick == 0) { blob.setPosition(Vec2f(281.305,136.3)); blob.setVelocity(Vec2f_zero); input.aim_pos = blob.getPosition(); }
            if (tick == 0) { input.aim_pos += Vec2f(-47.0695,-1.66699);input.action2 = true; input.facing_left = true; }
            if (tick == 1) { input.aim_pos += Vec2f(-47.0581,-1.66699);input.action2 = true; input.facing_left = true; }
            if (tick == 2) { input.aim_pos += Vec2f(-47.0938,-1.66698);input.action2 = true; input.facing_left = true; }
            if (tick == 3) { input.aim_pos += Vec2f(-47.112,-1.66698);input.action2 = true; input.facing_left = true; }
            if (tick == 4) { input.aim_pos += Vec2f(-47.1154,-1.66698);input.action2 = true; input.facing_left = true; }
            if (tick == 5) { input.aim_pos += Vec2f(-47.1185,-1.66698);input.action2 = true; input.facing_left = true; }
            if (tick == 6) { input.aim_pos += Vec2f(-47.1191,-1.66698);input.action2 = true; input.facing_left = true; }
            if (tick == 7) { input.aim_pos += Vec2f(-47.1113,-1.66698);input.action2 = true; input.facing_left = true; }
            if (tick == 8) { input.aim_pos += Vec2f(-47.1044,-1.66698);input.action2 = true; input.facing_left = true; }
            if (tick == 9) { input.aim_pos += Vec2f(-47.096,-1.66696);input.action2 = true; input.facing_left = true; }
            if (tick == 10) { input.aim_pos += Vec2f(-47.0786,-1.66696);input.action2 = true; input.facing_left = true; }
            if (tick == 11) { input.aim_pos += Vec2f(-47.0717,-1.66696);input.action2 = true; input.facing_left = true; }
            if (tick == 12) { input.aim_pos += Vec2f(-47.0648,-1.66696);input.action2 = true; input.facing_left = true; }
            if (tick == 13) { input.aim_pos += Vec2f(-47.0567,-1.66696);input.action2 = true; input.facing_left = true; }
            if (tick == 14) { input.aim_pos += Vec2f(-47.0504,-1.66696);input.action2 = true; input.facing_left = true; }
            if (tick == 15) { input.aim_pos += Vec2f(-47.0455,-1.66696);input.action2 = true; input.facing_left = true; }
            if (tick == 16) { input.aim_pos += Vec2f(-47.034,-1.66696);input.action2 = true; input.facing_left = true; }
            if (tick == 17) { input.aim_pos += Vec2f(-47.028,-1.66696);input.action2 = true; input.facing_left = true; }
            if (tick == 18) { input.aim_pos += Vec2f(-47.0251,-1.66696);input.action2 = true; input.facing_left = true; }
            if (tick == 19) { input.aim_pos += Vec2f(-47.0199,-1.66696);input.action2 = true; input.facing_left = true; }
            if (tick == 20) { input.aim_pos += Vec2f(-47.0166,-1.66696);input.action2 = true; input.facing_left = true; }
            if (tick == 21) { input.aim_pos += Vec2f(-47.0144,-1.66696);input.action2 = true; input.facing_left = true; }
            if (tick == 22) { input.aim_pos += Vec2f(-47.0124,-1.66696);input.action2 = true; input.facing_left = true; }
            if (tick == 23) { input.aim_pos += Vec2f(-47.0105,-1.66696);input.action2 = true; input.facing_left = true; }
            if (tick == 24) { input.aim_pos += Vec2f(-47.0083,-1.66696);input.action2 = true; input.facing_left = true; }
            if (tick == 25) { input.aim_pos += Vec2f(-47.0065,-1.66696);input.action2 = true; input.facing_left = true; }
            if (tick == 26) { input.aim_pos += Vec2f(-47.0057,-1.66696);input.action2 = true; input.facing_left = true; }
            if (tick == 27) { input.aim_pos += Vec2f(-47.005,-1.66696);input.action2 = true; input.facing_left = true; }
            if (tick == 28) { input.aim_pos += Vec2f(-48.9926,-1.66696);input.action2 = true; input.facing_left = true; }
            if (tick == 29) { input.aim_pos += Vec2f(-11.1741,0);input.facing_left = true; }
            if (tick == 30) { input.aim_pos += Vec2f(-10.6809,0);input.facing_left = true; }
            if (tick == 31) { input.aim_pos += Vec2f(-10.3821,0);input.facing_left = true; }
            if (tick == 32) { input.aim_pos += Vec2f(-10.2011,0);input.facing_left = true; }
            if (tick == 33) { input.aim_pos += Vec2f(-10.0914,0);input.facing_left = true; }
            if (tick == 34) { input.aim_pos += Vec2f(-10.0249,0);input.facing_left = true; }
            if (tick == 35) { input.aim_pos += Vec2f(-10,0);input.facing_left = true; }
            if (tick == 36) { input.aim_pos += Vec2f(-47.9941,-1.66696);input.action1 = true; input.facing_left = true; }
            if (tick == 37) { input.aim_pos += Vec2f(-47.9941,-1.66696);input.action1 = true; input.facing_left = true; }
            if (tick == 38) { input.aim_pos += Vec2f(-47.8711,-1.66696);input.action1 = true; input.facing_left = true; }
            if (tick == 39) { input.aim_pos += Vec2f(-47.67,-1.66696);input.action1 = true; input.facing_left = true; }
            if (tick == 40) { input.aim_pos += Vec2f(-47.5514,-1.66696);input.action1 = true; input.facing_left = true; }
            if (tick == 41) { input.aim_pos += Vec2f(-47.4731,-1.66696);input.action1 = true; input.facing_left = true; }
            if (tick == 42) { input.aim_pos += Vec2f(-47.4044,-1.66696);input.action1 = true; input.facing_left = true; }
            if (tick == 43) { input.aim_pos += Vec2f(-47.3227,-1.66696);input.action1 = true; input.facing_left = true; }
            if (tick == 44) { input.aim_pos += Vec2f(-47.2697,-1.66696);input.action1 = true; input.facing_left = true; }
            if (tick == 45) { input.aim_pos += Vec2f(-47.2201,-1.66696);input.action1 = true; input.facing_left = true; }
            if (tick == 46) { input.aim_pos += Vec2f(-47.1654,-1.66696);input.action1 = true; input.facing_left = true; }
            if (tick == 47) { input.aim_pos += Vec2f(-47.1417,-1.66696);input.action1 = true; input.facing_left = true; }
            if (tick == 48) { input.aim_pos += Vec2f(-47.1138,-1.66696);input.action1 = true; input.facing_left = true; }
            if (tick == 49) { input.aim_pos += Vec2f(-47.0974,-1.66696);input.action1 = true; input.facing_left = true; }
            if (tick == 50) { input.aim_pos += Vec2f(-47.0832,-1.66696);input.action1 = true; input.facing_left = true; }
            if (tick == 51) { input.aim_pos += Vec2f(-47.0678,-1.66696);input.left = true; input.facing_left = true; }
            if (tick == 52) { input.aim_pos += Vec2f(-47.6449,-6.66695);input.left = true; input.facing_left = true; }
            if (tick == 53) { input.aim_pos += Vec2f(-55.5497,-11.0003);input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 54) { input.aim_pos += Vec2f(-57.3725,-11.0003);input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 55) { input.aim_pos += Vec2f(-55.5878,-10.3336);input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 56) { input.aim_pos += Vec2f(-54.8392,-9.00029);input.action2 = true; input.facing_left = true; }
            if (tick == 57) { input.aim_pos += Vec2f(-53.963,-6.66695);input.action1 = true; input.action2 = true; input.facing_left = true; }
            if (tick == 58) { input.aim_pos += Vec2f(-53.9531,-6.66695);input.action1 = true; input.action2 = true; input.facing_left = true; }
            if (tick == 59) { input.aim_pos += Vec2f(-54.7169,-6.66695);input.action2 = true; input.facing_left = true; }
            if (tick == 60) { input.aim_pos += Vec2f(-55.0142,-6.00029);input.action2 = true; input.facing_left = true; }
            if (tick == 61) { input.aim_pos += Vec2f(-53.1948,-4.33362);input.action1 = true; input.action2 = true; input.facing_left = true; }
            if (tick == 62) { input.aim_pos += Vec2f(-52.085,-3.00029);input.action1 = true; input.action2 = true; input.facing_left = true; }
            if (tick == 63) { input.aim_pos += Vec2f(-51.0431,-2.33362);input.action2 = true; input.facing_left = true; }
            if (tick == 64) { input.aim_pos += Vec2f(-48.7392,-2.00029);input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 65) { input.aim_pos += Vec2f(-47.7399,-2.00029);input.action1 = true; input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 66) { input.aim_pos += Vec2f(-46.8621,-2.00029);input.action1 = true; input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 67) { input.aim_pos += Vec2f(-46.0966,-2.00029);input.action1 = true; input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 68) { input.aim_pos += Vec2f(-45.2542,-2.00029);input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 69) { input.aim_pos += Vec2f(-44.9145,-2.00029);input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 70) { input.aim_pos += Vec2f(-44.9828,-2.00029);input.action1 = true; input.action2 = true; input.facing_left = true; }
            if (tick == 71) { input.aim_pos += Vec2f(-45.1246,-2.00029);input.action1 = true; input.action2 = true; input.facing_left = true; }
            if (tick == 72) { input.aim_pos += Vec2f(-45.5729,-2.00029);input.action1 = true; input.action2 = true; input.facing_left = true; }
            if (tick == 73) { input.aim_pos += Vec2f(-46.2223,-2.00029);input.action2 = true; input.facing_left = true; }
            if (tick == 74) { input.aim_pos += Vec2f(-46.7073,-2.00029);input.action2 = true; input.facing_left = true; }
            if (tick == 75) { input.aim_pos += Vec2f(-47.1315,-2.00029);input.action2 = true; input.facing_left = true; }
            if (tick == 76) { input.aim_pos += Vec2f(-47.5306,-2.00029);input.action2 = true; input.facing_left = true; }
            if (tick == 77) { input.aim_pos += Vec2f(-47.8591,-2.00029);input.action2 = true; input.facing_left = true; }
            if (tick == 78) { input.aim_pos += Vec2f(-48.2003,-2.00029);input.action2 = true; input.facing_left = true; }
            if (tick == 79) { input.aim_pos += Vec2f(-48.771,-2.00029);input.action2 = true; input.facing_left = true; }
            if (tick == 80) { input.aim_pos += Vec2f(-49.2597,-2.00029);input.action2 = true; input.facing_left = true; }
            if (tick == 81) { input.aim_pos += Vec2f(-49.4137,-2.00029);input.action2 = true; input.facing_left = true; }
            if (tick == 82) { input.aim_pos += Vec2f(-49.5241,-2.00029);input.facing_left = true; }
            if (tick == 83) { input.aim_pos += Vec2f(-49.5899,-2.00029);input.facing_left = true; }
            if (tick == 84) { input.aim_pos += Vec2f(-49.6478,-2.00029);input.facing_left = true; }
            if (tick == 85) { input.aim_pos += Vec2f(-49.7046,-2.00029);input.facing_left = true; }
            if (tick == 86) { input.aim_pos += Vec2f(-49.753,-2.00029);input.facing_left = true; }
            if (tick == 87) { input.aim_pos += Vec2f(-49.8143,-2.00029);input.facing_left = true; }
            if (tick == 88) { input.aim_pos += Vec2f(-49.8501,-2.00029);input.facing_left = true; }
            if (tick >= 89) { if (isServer() && bot !is null) KickPlayer(bot); }
        }
        
    } else if (selected_training == Training::hard_slash_stomp) {
        if (frog) {
            if (tick == 0) { blob.setPosition(Vec2f(277.187,136.3)); blob.setVelocity(Vec2f_zero); input.aim_pos = blob.getPosition(); }
            if (tick == 0) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 1) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 2) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 3) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 4) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 5) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 6) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 7) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 8) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 9) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 10) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 11) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 12) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 13) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 14) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 15) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 16) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 17) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 18) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 19) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 20) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 21) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 22) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 23) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 24) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 25) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 26) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 27) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 28) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 29) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 30) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 31) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 32) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 33) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 34) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 35) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 36) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 37) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 38) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 39) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 40) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 41) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 42) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 43) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 44) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 45) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 46) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 47) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 48) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 49) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 50) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 51) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 52) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 53) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 54) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 55) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 56) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 57) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 58) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 59) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 60) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 61) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 62) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 63) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 64) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 65) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 66) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 67) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 68) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 69) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 70) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick == 71) { input.aim_pos += Vec2f(2.00085,-95.0004);input.action2 = true; }
            if (tick >= 72) { if (isServer() && bot !is null) KickPlayer(bot); }
        } else if (tiger) {
            if (tick == 0) { blob.setPosition(Vec2f(279.457,115.099)); blob.setVelocity(Vec2f_zero); input.aim_pos = blob.getPosition(); }
            if (tick == 0) { input.aim_pos += Vec2f(33.6406,19.4893);}
            if (tick == 1) { input.aim_pos += Vec2f(33.6458,18.1446);}
            if (tick == 2) { input.aim_pos += Vec2f(33.6468,17.8864);}
            if (tick == 3) { input.aim_pos += Vec2f(33.6502,16.1199);}
            if (tick == 4) { input.aim_pos += Vec2f(33.6533,14.0831);}
            if (tick == 5) { input.aim_pos += Vec2f(33.6558,11.95);}
            if (tick == 6) { input.aim_pos += Vec2f(33.6578,9.73608);}
            if (tick == 7) { input.aim_pos += Vec2f(33.6595,7.44221);}
            if (tick == 8) { input.aim_pos += Vec2f(33.6608,5.10985);}
            if (tick == 9) { input.aim_pos += Vec2f(33.302,5.49088);}
            if (tick == 10) { input.aim_pos += Vec2f(33.2924,6.33392);}
            if (tick == 11) { input.aim_pos += Vec2f(33.2403,7.22525);}
            if (tick == 12) { input.aim_pos += Vec2f(33.1471,7.59238);}
            if (tick == 13) { input.aim_pos += Vec2f(33.1599,7.93403);}
            if (tick == 14) { input.aim_pos += Vec2f(33.1899,8.21715);}
            if (tick == 15) { input.aim_pos += Vec2f(33.1384,8.4155);}
            if (tick == 16) { input.aim_pos += Vec2f(33.157,8.60209);}
            if (tick == 17) { input.aim_pos += Vec2f(33.1849,8.74644);}
            if (tick == 18) { input.aim_pos += Vec2f(33.1354,8.86378);}
            if (tick == 19) { input.aim_pos += Vec2f(33.1527,8.95631);}
            if (tick == 20) { input.aim_pos += Vec2f(33.1843,9.04135);}
            if (tick == 21) { input.aim_pos += Vec2f(33.1286,9.08675);}
            if (tick == 22) { input.aim_pos += Vec2f(32.8143,9.47108);input.up = true; }
            if (tick == 23) { input.aim_pos += Vec2f(32.8421,10.5348);input.right = true; input.up = true; }
            if (tick == 24) { input.aim_pos += Vec2f(32.3634,5.56448);input.action1 = true; input.right = true; input.up = true; }
            if (tick == 25) { input.aim_pos += Vec2f(35.1198,-16.0188);input.action1 = true; input.right = true; input.up = true; }
            if (tick == 26) { input.aim_pos += Vec2f(37.2279,-40.8024);input.action1 = true; input.right = true; input.up = true; }
            if (tick == 27) { input.aim_pos += Vec2f(34.7223,-54.8011);input.action1 = true; input.right = true; input.up = true; }
            if (tick == 28) { input.aim_pos += Vec2f(31.4488,-60.2795);input.action1 = true; input.right = true; input.up = true; }
            if (tick == 29) { input.aim_pos += Vec2f(29.7307,-59.7813);input.action1 = true; input.right = true; input.up = true; }
            if (tick == 30) { input.aim_pos += Vec2f(28.6025,-59.6696);input.action1 = true; input.right = true; input.up = true; }
            if (tick == 31) { input.aim_pos += Vec2f(27.6997,-59.9714);input.action1 = true; input.right = true; }
            if (tick == 32) { input.aim_pos += Vec2f(26.7504,-60.816);input.action1 = true; }
            if (tick == 33) { input.aim_pos += Vec2f(25.0115,-59.7232);input.action1 = true; }
            if (tick == 34) { input.aim_pos += Vec2f(22.6578,-56.9532);input.action1 = true; input.left = true; }
            if (tick == 35) { input.aim_pos += Vec2f(20.0622,-51.5553);input.action1 = true; input.left = true; }
            if (tick == 36) { input.aim_pos += Vec2f(16.4884,-44.5815);input.action1 = true; input.left = true; input.down = true; }
            if (tick == 37) { input.aim_pos += Vec2f(10.4794,-32.8468);input.action1 = true; input.left = true; input.down = true; }
            if (tick == 38) { input.aim_pos += Vec2f(2.56955,-15.2333);input.action1 = true; input.left = true; input.down = true; }
            if (tick == 39) { input.aim_pos += Vec2f(-3.43231,-3.0229);input.action1 = true; input.left = true; input.down = true; }
            if (tick == 40) { input.aim_pos += Vec2f(-26.2151,30.1068);input.left = true; input.down = true; }
            if (tick == 41) { input.aim_pos += Vec2f(-88.3094,116.525);input.action2 = true; input.left = true; input.down = true; input.facing_left = true; }
            if (tick == 42) { input.aim_pos += Vec2f(-116.16,170.193);input.action2 = true; input.left = true; input.down = true; input.facing_left = true; }
            if (tick == 43) { input.aim_pos += Vec2f(-117.454,166.853);input.action2 = true; input.left = true; input.down = true; input.facing_left = true; }
            if (tick == 44) { input.aim_pos += Vec2f(-102.75,145.106);input.action2 = true; input.left = true; input.down = true; input.facing_left = true; }
            if (tick == 45) { input.aim_pos += Vec2f(-83.6003,106.775);input.action2 = true; input.left = true; input.down = true; input.facing_left = true; }
            if (tick == 46) { input.aim_pos += Vec2f(-71.3706,78.5286);input.action2 = true; input.left = true; input.down = true; input.facing_left = true; }
            if (tick == 47) { input.aim_pos += Vec2f(-57.5364,59.1087);input.action2 = true; input.left = true; input.down = true; input.facing_left = true; }
            if (tick == 48) { input.aim_pos += Vec2f(-49.5467,43.3904);input.down = true; input.facing_left = true; }
            if (tick == 49) { input.aim_pos += Vec2f(-48.9901,38.6317);input.facing_left = true; }
            if (tick == 50) { input.aim_pos += Vec2f(-49.9502,38.6412);input.facing_left = true; }
            if (tick == 51) { input.aim_pos += Vec2f(-50.8964,39.5243);input.facing_left = true; }
            if (tick == 52) { input.aim_pos += Vec2f(-50.7547,38.0461);input.facing_left = true; }
            if (tick == 53) { input.aim_pos += Vec2f(-50.0443,35.4385);input.facing_left = true; }
            if (tick == 54) { input.aim_pos += Vec2f(-49.8107,31.8387);input.facing_left = true; }
            if (tick == 55) { input.aim_pos += Vec2f(-48.8706,22.5043);input.facing_left = true; }
            if (tick == 56) { input.aim_pos += Vec2f(-48.325,18.6064);input.facing_left = true; }
            if (tick == 57) { input.aim_pos += Vec2f(-47.4175,16.6598);input.facing_left = true; }
            if (tick == 58) { input.aim_pos += Vec2f(-45.3933,13.1826);input.facing_left = true; }
            if (tick == 59) { input.aim_pos += Vec2f(-29.9185,-0.159637);input.facing_left = true; }
            if (tick == 60) { input.aim_pos += Vec2f(-19.369,-6.62827);input.facing_left = true; }
            if (tick == 61) { input.aim_pos += Vec2f(-16.8257,-8.41951);input.facing_left = true; }
            if (tick == 62) { input.aim_pos += Vec2f(-16.6571,-8.47462);input.facing_left = true; }
            if (tick == 63) { input.aim_pos += Vec2f(-16.8079,-8.22003);input.facing_left = true; }
            if (tick == 64) { input.aim_pos += Vec2f(-16.915,-7.70584);input.facing_left = true; }
            if (tick == 65) { input.aim_pos += Vec2f(-16.9995,-6.89668);input.facing_left = true; }
            if (tick == 66) { input.aim_pos += Vec2f(-17.0706,-6.7766);input.facing_left = true; }
            if (tick == 67) { input.aim_pos += Vec2f(-17.1254,-6.68414);input.facing_left = true; }
            if (tick == 68) { input.aim_pos += Vec2f(-17.1682,-6.61201);input.facing_left = true; }
            if (tick == 69) { input.aim_pos += Vec2f(-17.1995,-6.22583);input.facing_left = true; }
            if (tick == 70) { input.aim_pos += Vec2f(-17.2229,-5.18631);input.facing_left = true; }
            if (tick == 71) { input.aim_pos += Vec2f(-17.2438,-4.81764);input.facing_left = true; }
            if (tick == 72) { input.aim_pos += Vec2f(-17.2619,-4.45392);input.facing_left = true; }
            if (tick == 73) { input.aim_pos += Vec2f(-17.2751,-4.43155);input.facing_left = true; }
            if (tick == 74) { input.aim_pos += Vec2f(-17.2867,-4.41205);input.facing_left = true; }
            if (tick == 75) { input.aim_pos += Vec2f(-16.9619,-4.39766);input.facing_left = true; }
            if (tick == 76) { input.aim_pos += Vec2f(-16.9693,-4.38507);input.facing_left = true; }
            if (tick == 77) { input.aim_pos += Vec2f(-16.9749,-4.04236);input.facing_left = true; }
            if (tick == 78) { input.aim_pos += Vec2f(-16.9781,-4.03696);input.facing_left = true; }
            if (tick == 79) { input.aim_pos += Vec2f(-16.9824,-4.02956);input.facing_left = true; }
            if (tick == 80) { input.aim_pos += Vec2f(-16.9859,-4.02368);input.facing_left = true; }
            if (tick == 81) { input.aim_pos += Vec2f(-16.9885,-3.68602);input.facing_left = true; }
            if (tick == 82) { input.aim_pos += Vec2f(-16.6572,-3.34915);input.facing_left = true; }
            if (tick == 83) { input.aim_pos += Vec2f(-16.6591,-2.6794);input.facing_left = true; }
            if (tick == 84) { input.aim_pos += Vec2f(-16.3272,-2.3436);input.facing_left = true; }
            if (tick == 85) { input.aim_pos += Vec2f(-16.3279,-2.00911);input.facing_left = true; }
            if (tick == 86) { input.aim_pos += Vec2f(-16.3289,-1.67407);input.facing_left = true; }
            if (tick == 87) { input.aim_pos += Vec2f(-16.3296,-1.33946);input.facing_left = true; }
            if (tick == 88) { input.aim_pos += Vec2f(-15.9971,-1.33823);input.facing_left = true; }
            if (tick == 89) { input.aim_pos += Vec2f(-15.9976,-1.33725);input.facing_left = true; }
            if (tick == 90) { input.aim_pos += Vec2f(-15.998,-1.33652);input.facing_left = true; }
            if (tick == 91) { input.aim_pos += Vec2f(-15.9984,-1.33591);input.facing_left = true; }
            if (tick == 92) { input.aim_pos += Vec2f(-15.9987,-1.3354);input.facing_left = true; }
            if (tick == 93) { input.aim_pos += Vec2f(-15.9991,-1.33501);input.facing_left = true; }
            if (tick == 94) { input.aim_pos += Vec2f(-15.9991,-1.33467);input.facing_left = true; }
            if (tick == 95) { input.aim_pos += Vec2f(-15.9991,-1.33447);input.facing_left = true; }
            if (tick == 96) { input.aim_pos += Vec2f(-15.9991,-1.33427);input.facing_left = true; }
            if (tick == 97) { input.aim_pos += Vec2f(-15.9991,-1.33408);input.facing_left = true; }
            if (tick == 98) { input.aim_pos += Vec2f(-15.9991,-1.33389);input.facing_left = true; }
            if (tick == 99) { input.aim_pos += Vec2f(-15.9991,-1.33379);input.facing_left = true; }
            if (tick == 100) { input.aim_pos += Vec2f(-15.9991,-1.33376);input.facing_left = true; }
            if (tick == 101) { input.aim_pos += Vec2f(-15.9991,-1.33374);input.facing_left = true; }
            if (tick == 102) { input.aim_pos += Vec2f(-15.9991,-1.33374);input.facing_left = true; }
            if (tick == 103) { input.aim_pos += Vec2f(-15.9991,-1.33374);input.facing_left = true; }
            if (tick == 104) { input.aim_pos += Vec2f(-15.9991,-1.33374);input.facing_left = true; }
            if (tick == 105) { input.aim_pos += Vec2f(-15.9991,-1.33372);input.facing_left = true; }
            if (tick == 106) { input.aim_pos += Vec2f(-15.9991,-1.33372);input.facing_left = true; }
            if (tick == 107) { input.aim_pos += Vec2f(-15.9991,-1.33372);input.facing_left = true; }
            if (tick >= 108) { if (isServer() && bot !is null) KickPlayer(bot); }
        }
    } else if (selected_training == Training::shield_bash_and_jab) {
        if (frog) {
            if (tick == 0) { blob.setPosition(Vec2f(265.939,136.3)); blob.setVelocity(Vec2f_zero); input.aim_pos = blob.getPosition(); }
            if (tick == 0) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 1) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 2) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 3) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 4) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 5) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 6) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 7) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 8) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 9) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 10) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 11) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 12) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 13) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 14) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 15) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 16) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 17) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 18) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 19) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 20) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 21) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 22) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 23) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 24) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 25) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 26) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 27) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 28) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 29) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 30) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 31) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 32) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 33) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 34) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 35) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 36) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 37) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 38) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 39) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 40) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 41) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 42) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 43) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 44) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 45) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 46) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 47) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 48) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 49) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 50) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 51) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 52) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 53) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 54) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 55) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 56) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 57) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 58) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 59) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 60) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 61) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick == 62) { input.aim_pos += Vec2f(26.0008,-3.6671);input.action2 = true; }
            if (tick >= 63) { if (isServer() && bot !is null) KickPlayer(bot); }
        } else if (tiger) {
            if (tick == 0) { blob.setPosition(Vec2f(288.44,136.3)); blob.setVelocity(Vec2f_zero); input.aim_pos = blob.getPosition(); }
            if (tick == 0) { input.aim_pos += Vec2f(-35.1523,-0.0138092);input.facing_left = true; }
            if (tick == 1) { input.aim_pos += Vec2f(-35.3937,-0.0112);input.facing_left = true; }
            if (tick == 2) { input.aim_pos += Vec2f(-35.7124,-0.0107727);input.facing_left = true; }
            if (tick == 3) { input.aim_pos += Vec2f(-35.9739,-0.00874329);input.facing_left = true; }
            if (tick == 4) { input.aim_pos += Vec2f(-35.916,-0.00709534);input.facing_left = true; }
            if (tick == 5) { input.aim_pos += Vec2f(-36.536,-0.00576782);input.facing_left = true; }
            if (tick == 6) { input.aim_pos += Vec2f(-36.8288,-0.00460815);input.facing_left = true; }
            if (tick == 7) { input.aim_pos += Vec2f(-37.1277,-0.00363159);input.facing_left = true; }
            if (tick == 8) { input.aim_pos += Vec2f(-37.4361,-0.00291443);input.facing_left = true; }
            if (tick == 9) { input.aim_pos += Vec2f(-37.7495,-0.00236511);input.facing_left = true; }
            if (tick == 10) { input.aim_pos += Vec2f(-37.7324,-0.00189209);input.facing_left = true; }
            if (tick == 11) { input.aim_pos += Vec2f(-37.7199,-0.00152588);input.facing_left = true; }
            if (tick == 12) { input.aim_pos += Vec2f(-38.0425,0.332108);input.up = true; input.facing_left = true; }
            if (tick == 13) { input.aim_pos += Vec2f(-38.0346,1.36343);input.up = true; input.facing_left = true; }
            if (tick == 14) { input.aim_pos += Vec2f(-38.0282,3.67596);input.up = true; input.facing_left = true; }
            if (tick == 15) { input.aim_pos += Vec2f(-38.0241,7.84093);input.up = true; input.facing_left = true; }
            if (tick == 16) { input.aim_pos += Vec2f(-38.0205,12.2011);input.up = true; input.facing_left = true; }
            if (tick == 17) { input.aim_pos += Vec2f(-37.3499,15.832);input.up = true; input.facing_left = true; }
            if (tick == 18) { input.aim_pos += Vec2f(-36.0141,23.6391);input.facing_left = true; }
            if (tick == 19) { input.aim_pos += Vec2f(-34.6788,30.5205);input.facing_left = true; }
            if (tick == 20) { input.aim_pos += Vec2f(-34.6764,35.1346);input.left = true; input.facing_left = true; }
            if (tick == 21) { input.aim_pos += Vec2f(-34.1862,40.6669);input.left = true; input.facing_left = true; }
            if (tick == 22) { input.aim_pos += Vec2f(-33.2486,51.6398);input.left = true; input.facing_left = true; }
            if (tick == 23) { input.aim_pos += Vec2f(-32.2995,58.5164);input.left = true; input.facing_left = true; }
            if (tick == 24) { input.aim_pos += Vec2f(-31.6989,65.6615);input.left = true; input.facing_left = true; }
            if (tick == 25) { input.aim_pos += Vec2f(-31.4708,77.043);input.left = true; input.facing_left = true; }
            if (tick == 26) { input.aim_pos += Vec2f(-32.7777,87.8047);input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 27) { input.aim_pos += Vec2f(-33.5752,94.7179);input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 28) { input.aim_pos += Vec2f(-34.4507,97.9111);input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 29) { input.aim_pos += Vec2f(-37.6,102.368);input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 30) { input.aim_pos += Vec2f(-42.5558,107.551);input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 31) { input.aim_pos += Vec2f(-51.1069,106.127);input.action1 = true; input.left = true; input.facing_left = true; }
            if (tick == 32) { input.aim_pos += Vec2f(-72.7916,58.614);input.action1 = true; input.left = true; input.facing_left = true; }
            if (tick == 33) { input.aim_pos += Vec2f(-84.5841,18.8436);input.left = true; input.facing_left = true; }
            if (tick == 34) { input.aim_pos += Vec2f(-84.7396,19.6486);input.action1 = true; input.left = true; input.facing_left = true; }
            if (tick == 35) { input.aim_pos += Vec2f(-84.3883,19.8189);input.action1 = true; input.left = true; input.facing_left = true; }
            if (tick == 36) { input.aim_pos += Vec2f(-83.5468,19.8855);input.left = true; input.facing_left = true; }
            if (tick == 37) { input.aim_pos += Vec2f(-80.0489,21.5102);input.left = true; input.facing_left = true; }
            if (tick == 38) { input.aim_pos += Vec2f(-77.3813,21.3741);input.left = true; input.facing_left = true; }
            if (tick == 39) { input.aim_pos += Vec2f(-76.3626,19.9214);input.left = true; input.facing_left = true; }
            if (tick == 40) { input.aim_pos += Vec2f(-75.5909,18.2828);input.facing_left = true; }
            if (tick == 41) { input.aim_pos += Vec2f(-74.9706,16.4829);input.facing_left = true; }
            if (tick == 42) { input.aim_pos += Vec2f(-74.5966,13.8707);input.facing_left = true; }
            if (tick == 43) { input.aim_pos += Vec2f(-75.1453,11.8853);input.right = true; input.facing_left = true; }
            if (tick == 44) { input.aim_pos += Vec2f(-75.9041,9.70309);input.right = true; input.facing_left = true; }
            if (tick == 45) { input.aim_pos += Vec2f(-77.2736,7.51076);input.right = true; input.facing_left = true; }
            if (tick == 46) { input.aim_pos += Vec2f(-78.3453,4.91554);input.right = true; input.facing_left = true; }
            if (tick == 47) { input.aim_pos += Vec2f(-78.9118,2.08551);input.right = true; input.facing_left = true; }
            if (tick == 48) { input.aim_pos += Vec2f(-71.1771,-2.2148);input.right = true; input.facing_left = true; }
            if (tick == 49) { input.aim_pos += Vec2f(-64.6519,-3.80431);input.right = true; input.facing_left = true; }
            if (tick == 50) { input.aim_pos += Vec2f(-58.2398,-5.05417);input.right = true; input.facing_left = true; }
            if (tick == 51) { input.aim_pos += Vec2f(-56.9929,-4.10982);input.right = true; input.facing_left = true; }
            if (tick == 52) { input.aim_pos += Vec2f(-57.8102,-3.21936);input.right = true; input.facing_left = true; }
            if (tick == 53) { input.aim_pos += Vec2f(-59.7165,-2.054);input.facing_left = true; }
            if (tick == 54) { input.aim_pos += Vec2f(-60.3579,-1.09738);input.facing_left = true; }
            if (tick == 55) { input.aim_pos += Vec2f(-60.1198,-0.249725);input.facing_left = true; }
            if (tick == 56) { input.aim_pos += Vec2f(-59.5167,0.430054);input.facing_left = true; }
            if (tick == 57) { input.aim_pos += Vec2f(-58.7745,0.980179);input.facing_left = true; }
            if (tick == 58) { input.aim_pos += Vec2f(-58.0872,1.39224);input.facing_left = true; }
            if (tick == 59) { input.aim_pos += Vec2f(-57.4246,1.73412);input.facing_left = true; }
            if (tick == 60) { input.aim_pos += Vec2f(-56.87,1.99553);input.facing_left = true; }
            if (tick == 61) { input.aim_pos += Vec2f(-56.3987,2.21565);input.facing_left = true; }
            if (tick == 62) { input.aim_pos += Vec2f(-55.9354,2.43185);input.facing_left = true; }
            if (tick == 63) { input.aim_pos += Vec2f(-55.5912,2.59241);input.facing_left = true; }
            if (tick == 64) { input.aim_pos += Vec2f(-55.3069,2.72501);input.facing_left = true; }
            if (tick == 65) { input.aim_pos += Vec2f(-55.0915,2.82547);input.facing_left = true; }
            if (tick == 66) { input.aim_pos += Vec2f(-54.865,2.93098);input.facing_left = true; }
            if (tick == 67) { input.aim_pos += Vec2f(-54.6878,3.01349);input.facing_left = true; }
            if (tick == 68) { input.aim_pos += Vec2f(-54.558,3.07394);input.facing_left = true; }
            if (tick == 69) { input.aim_pos += Vec2f(-54.4529,3.12279);input.facing_left = true; }
            if (tick >= 70) { if (isServer() && bot !is null) KickPlayer(bot); }
        }
        
    } else if (selected_training == Training::shield_bash_and_jab_against_wall) {
        if (frog) {
            if (tick == 0) { blob.setPosition(Vec2f(215.7,136.3)); blob.setVelocity(Vec2f_zero); input.aim_pos = blob.getPosition(); }
            if (tick == 0) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 1) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 2) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 3) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 4) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 5) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 6) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 7) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 8) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 9) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 10) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 11) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 12) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 13) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 14) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 15) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 16) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 17) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 18) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 19) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 20) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 21) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 22) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 23) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 24) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 25) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 26) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 27) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 28) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 29) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 30) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 31) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 32) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 33) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 34) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 35) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 36) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 37) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 38) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 39) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 40) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 41) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 42) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 43) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 44) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 45) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 46) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 47) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 48) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick == 49) { input.aim_pos += Vec2f(62,-0.333191);input.action2 = true; }
            if (tick >= 50) { if (isServer() && bot !is null) KickPlayer(bot); }
        } else if (tiger) {
            if (tick == 0) { blob.setPosition(Vec2f(254.78,136.3)); blob.setVelocity(Vec2f_zero); input.aim_pos = blob.getPosition(); }
            if (tick == 0) { input.aim_pos += Vec2f(-73.6839,94.9997);input.facing_left = true; }
            if (tick == 1) { input.aim_pos += Vec2f(-73.6818,94.9997);input.facing_left = true; }
            if (tick == 2) { input.aim_pos += Vec2f(-73.6814,94.9997);input.facing_left = true; }
            if (tick == 3) { input.aim_pos += Vec2f(-73.6794,94.9997);input.facing_left = true; }
            if (tick == 4) { input.aim_pos += Vec2f(-73.6772,94.9997);input.facing_left = true; }
            if (tick == 5) { input.aim_pos += Vec2f(-73.6746,94.9997);input.facing_left = true; }
            if (tick == 6) { input.aim_pos += Vec2f(-73.6725,95.333);input.facing_left = true; }
            if (tick == 7) { input.aim_pos += Vec2f(-73.6712,97.6664);input.action2 = true; input.facing_left = true; }
            if (tick == 8) { input.aim_pos += Vec2f(-74.0035,99.6664);input.action2 = true; input.up = true; input.facing_left = true; }
            if (tick == 9) { input.aim_pos += Vec2f(-74.3364,102.965);input.action2 = true; input.up = true; input.facing_left = true; }
            if (tick == 10) { input.aim_pos += Vec2f(-74.336,105.207);input.action2 = true; input.up = true; input.facing_left = true; }
            if (tick == 11) { input.aim_pos += Vec2f(-74.3354,106.634);input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 12) { input.aim_pos += Vec2f(-73.8952,107.169);input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 13) { input.aim_pos += Vec2f(-73.0473,107.599);input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 14) { input.aim_pos += Vec2f(-71.8468,107.98);input.action2 = true; input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 15) { input.aim_pos += Vec2f(-70.5141,107.437);input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 16) { input.aim_pos += Vec2f(-68.9146,106.591);input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 17) { input.aim_pos += Vec2f(-66.9318,105.513);input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 18) { input.aim_pos += Vec2f(-65.724,104.096);input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 19) { input.aim_pos += Vec2f(-64.3452,103.01);input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 20) { input.aim_pos += Vec2f(-63.6034,103.312);input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 21) { input.aim_pos += Vec2f(-61.8219,103.632);input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 22) { input.aim_pos += Vec2f(-59.7464,103.875);input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 23) { input.aim_pos += Vec2f(-60.2517,102.139);input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 24) { input.aim_pos += Vec2f(-66.5908,97.6678);input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 25) { input.aim_pos += Vec2f(-75.3648,94.6832);input.left = true; input.facing_left = true; }
            if (tick == 26) { input.aim_pos += Vec2f(-83.8162,88.0387);input.left = true; input.facing_left = true; }
            if (tick == 27) { input.aim_pos += Vec2f(-89.2214,77.4068);input.facing_left = true; }
            if (tick == 28) { input.aim_pos += Vec2f(-93.435,63.2396);input.facing_left = true; }
            if (tick == 29) { input.aim_pos += Vec2f(-95.5685,58.8062);input.action1 = true; input.facing_left = true; }
            if (tick == 30) { input.aim_pos += Vec2f(-96.7256,57.6964);input.action1 = true; input.facing_left = true; }
            if (tick == 31) { input.aim_pos += Vec2f(-97.9571,54.3984);input.facing_left = true; }
            if (tick == 32) { input.aim_pos += Vec2f(-98.8528,50.3185);input.left = true; input.facing_left = true; }
            if (tick == 33) { input.aim_pos += Vec2f(-98.9342,47.7177);input.left = true; input.facing_left = true; }
            if (tick == 34) { input.aim_pos += Vec2f(-98.0005,45.8128);input.left = true; input.facing_left = true; }
            if (tick == 35) { input.aim_pos += Vec2f(-96.8583,43.9524);input.left = true; input.facing_left = true; }
            if (tick == 36) { input.aim_pos += Vec2f(-95.5132,42.0137);input.left = true; input.facing_left = true; }
            if (tick == 37) { input.aim_pos += Vec2f(-93.9178,39.9957);input.left = true; input.facing_left = true; }
            if (tick == 38) { input.aim_pos += Vec2f(-92.0911,37.7807);input.facing_left = true; }
            if (tick == 39) { input.aim_pos += Vec2f(-90.8129,38.3249);input.facing_left = true; }
            if (tick == 40) { input.aim_pos += Vec2f(-90.5768,39.4702);input.facing_left = true; }
            if (tick == 41) { input.aim_pos += Vec2f(-91.5544,40.4677);input.facing_left = true; }
            if (tick == 42) { input.aim_pos += Vec2f(-92.5216,41.396);input.facing_left = true; }
            if (tick == 43) { input.aim_pos += Vec2f(-93.2331,42.1048);input.facing_left = true; }
            if (tick == 44) { input.aim_pos += Vec2f(-93.5742,42.4444);input.facing_left = true; }
            if (tick == 45) { input.aim_pos += Vec2f(-94.0147,42.8949);input.facing_left = true; }
            if (tick == 46) { input.aim_pos += Vec2f(-94.308,43.194);input.facing_left = true; }
            if (tick == 47) { input.aim_pos += Vec2f(-94.5515,43.4438);input.facing_left = true; }
            if (tick == 48) { input.aim_pos += Vec2f(-94.7549,43.6539);input.facing_left = true; }
            if (tick == 49) { input.aim_pos += Vec2f(-94.9507,43.8591);input.facing_left = true; }
            if (tick == 50) { input.aim_pos += Vec2f(-95.058,43.9689);input.facing_left = true; }
            if (tick == 51) { input.aim_pos += Vec2f(-95.1631,44.0791);input.facing_left = true; }
            if (tick == 52) { input.aim_pos += Vec2f(-95.2429,44.1625);input.facing_left = true; }
            if (tick == 53) { input.aim_pos += Vec2f(-95.3411,44.2698);input.facing_left = true; }
            if (tick == 54) { input.aim_pos += Vec2f(-95.4216,44.3591);input.facing_left = true; }
            if (tick == 55) { input.aim_pos += Vec2f(-95.4666,44.4073);input.facing_left = true; }
            if (tick == 56) { input.aim_pos += Vec2f(-95.5145,44.4613);input.facing_left = true; }
            if (tick == 57) { input.aim_pos += Vec2f(-95.5386,44.4931);input.facing_left = true; }
            if (tick == 58) { input.aim_pos += Vec2f(-95.5637,44.5263);input.facing_left = true; }
            if (tick == 59) { input.aim_pos += Vec2f(-95.5855,44.5551);input.facing_left = true; }
            if (tick == 60) { input.aim_pos += Vec2f(-95.6,44.5743);input.facing_left = true; }
            if (tick == 61) { input.aim_pos += Vec2f(-95.6108,44.5885);input.facing_left = true; }
            if (tick == 62) { input.aim_pos += Vec2f(-95.6201,44.6008);input.facing_left = true; }
            if (tick == 63) { input.aim_pos += Vec2f(-95.6272,44.6102);input.facing_left = true; }
            if (tick == 64) { input.aim_pos += Vec2f(-95.637,44.6232);input.facing_left = true; }
            if (tick == 65) { input.aim_pos += Vec2f(-95.6444,44.633);input.facing_left = true; }
            if (tick == 66) { input.aim_pos += Vec2f(-95.6535,44.6385);input.facing_left = true; }
            if (tick == 67) { input.aim_pos += Vec2f(-95.6568,44.6444);input.facing_left = true; }
            if (tick == 68) { input.aim_pos += Vec2f(-95.6583,44.6479);input.facing_left = true; }
            if (tick == 69) { input.aim_pos += Vec2f(-95.6602,44.6522);input.facing_left = true; }
            if (tick == 70) { input.aim_pos += Vec2f(-95.6612,44.6545);input.facing_left = true; }
            if (tick == 71) { input.aim_pos += Vec2f(-95.6622,44.6568);input.facing_left = true; }
            if (tick == 72) { input.aim_pos += Vec2f(-95.6632,44.659);input.facing_left = true; }
            if (tick == 73) { input.aim_pos += Vec2f(-95.6636,44.66);input.facing_left = true; }
            if (tick == 74) { input.aim_pos += Vec2f(-95.664,44.6609);input.facing_left = true; }
            if (tick == 75) { input.aim_pos += Vec2f(-95.6644,44.6617);input.facing_left = true; }
            if (tick == 76) { input.aim_pos += Vec2f(-95.6648,44.6627);input.facing_left = true; }
            if (tick == 77) { input.aim_pos += Vec2f(-95.6652,44.6635);input.facing_left = true; }
            if (tick == 78) { input.aim_pos += Vec2f(-95.6655,44.6642);input.facing_left = true; }
            if (tick >= 79) { if (isServer() && bot !is null) KickPlayer(bot); }
        }
        
    } else if (selected_training == Training::shield_bash_and_slash_against_wall) {
        if (frog) {
            if (tick == 0) { blob.setPosition(Vec2f(215.7,136.3)); blob.setVelocity(Vec2f_zero); input.aim_pos = blob.getPosition(); }
            if (tick == 0) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 1) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 2) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 3) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 4) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 5) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 6) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 7) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 8) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 9) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 10) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 11) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 12) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 13) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 14) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 15) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 16) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 17) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 18) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 19) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 20) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 21) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 22) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 23) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 24) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 25) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 26) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 27) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 28) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 29) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 30) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 31) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 32) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 33) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 34) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 35) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 36) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 37) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 38) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 39) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 40) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 41) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 42) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 43) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 44) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 45) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 46) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 47) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 48) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 49) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 50) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 51) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 52) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 53) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 54) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 55) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 56) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 57) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 58) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 59) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 60) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 61) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 62) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 63) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 64) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 65) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 66) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 67) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 68) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 69) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 70) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 71) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 72) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 73) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 74) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 75) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 76) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 77) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 78) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 79) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 80) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 81) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 82) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 83) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 84) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 85) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 86) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 87) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 88) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 89) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 90) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 91) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 92) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 93) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 94) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick == 95) { input.aim_pos += Vec2f(42.667,-12.9996);input.action2 = true; }
            if (tick >= 96) { if (isServer() && bot !is null) KickPlayer(bot); }
        } else if (tiger) {
            if (tick == 0) { blob.setPosition(Vec2f(248.65,136.3)); blob.setVelocity(Vec2f_zero); input.aim_pos = blob.getPosition(); }
            if (tick == 0) { input.aim_pos += Vec2f(-56.6695,5.66634);input.facing_left = true; }
            if (tick == 1) { input.aim_pos += Vec2f(-56.6689,5.66634);input.facing_left = true; }
            if (tick == 2) { input.aim_pos += Vec2f(-56.6689,5.66634);input.facing_left = true; }
            if (tick == 3) { input.aim_pos += Vec2f(-56.6686,5.66635);input.facing_left = true; }
            if (tick == 4) { input.aim_pos += Vec2f(-56.6683,5.66635);input.facing_left = true; }
            if (tick == 5) { input.aim_pos += Vec2f(-56.668,5.66635);input.facing_left = true; }
            if (tick == 6) { input.aim_pos += Vec2f(-56.6678,5.66635);input.facing_left = true; }
            if (tick == 7) { input.aim_pos += Vec2f(-56.6676,5.66635);input.up = true; input.facing_left = true; }
            if (tick == 8) { input.aim_pos += Vec2f(-56.6674,6.69749);input.up = true; input.facing_left = true; }
            if (tick == 9) { input.aim_pos += Vec2f(-56.6673,8.66844);input.up = true; input.facing_left = true; }
            if (tick == 10) { input.aim_pos += Vec2f(-56.6671,13.0292);input.up = true; input.facing_left = true; }
            if (tick == 11) { input.aim_pos += Vec2f(-56.667,17.1583);input.up = true; input.facing_left = true; }
            if (tick == 12) { input.aim_pos += Vec2f(-56.3337,20.3236);input.facing_left = true; }
            if (tick == 13) { input.aim_pos += Vec2f(-55.667,24.6719);input.facing_left = true; }
            if (tick == 14) { input.aim_pos += Vec2f(-54.667,29.6486);input.facing_left = true; }
            if (tick == 15) { input.aim_pos += Vec2f(-54.0003,33.7115);input.facing_left = true; }
            if (tick == 16) { input.aim_pos += Vec2f(-53.3337,37.9312);input.facing_left = true; }
            if (tick == 17) { input.aim_pos += Vec2f(-52.3337,42.5059);input.left = true; input.facing_left = true; }
            if (tick == 18) { input.aim_pos += Vec2f(-51.5118,43.1769);input.left = true; input.facing_left = true; }
            if (tick == 19) { input.aim_pos += Vec2f(-50.2515,47.5436);input.left = true; input.facing_left = true; }
            if (tick == 20) { input.aim_pos += Vec2f(-49.6262,52.8752);input.left = true; input.facing_left = true; }
            if (tick == 21) { input.aim_pos += Vec2f(-50.0534,58.725);input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 22) { input.aim_pos += Vec2f(-49.8998,63.4458);input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 23) { input.aim_pos += Vec2f(-49.491,64.7322);input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 24) { input.aim_pos += Vec2f(-49.2846,66.2629);input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 25) { input.aim_pos += Vec2f(-49.4491,67.7819);input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 26) { input.aim_pos += Vec2f(-49.3268,67.8327);input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 27) { input.aim_pos += Vec2f(-48.6824,66.4849);input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 28) { input.aim_pos += Vec2f(-48.411,66.2134);input.action1 = true; input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 29) { input.aim_pos += Vec2f(-50.4112,68.4294);input.action1 = true; input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 30) { input.aim_pos += Vec2f(-54.2829,73.0384);input.action1 = true; input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 31) { input.aim_pos += Vec2f(-58.616,70.3501);input.action1 = true; input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 32) { input.aim_pos += Vec2f(-65.1346,52.8314);input.action1 = true; input.left = true; input.facing_left = true; }
            if (tick == 33) { input.aim_pos += Vec2f(-67.7489,47.0491);input.action1 = true; input.left = true; input.facing_left = true; }
            if (tick == 34) { input.aim_pos += Vec2f(-67.9657,45.4739);input.action1 = true; input.left = true; input.facing_left = true; }
            if (tick == 35) { input.aim_pos += Vec2f(-67.7045,45.6062);input.action1 = true; input.facing_left = true; }
            if (tick == 36) { input.aim_pos += Vec2f(-67.2669,41.6122);input.action1 = true; input.facing_left = true; }
            if (tick == 37) { input.aim_pos += Vec2f(-67.0095,32.195);input.action1 = true; input.facing_left = true; }
            if (tick == 38) { input.aim_pos += Vec2f(-68.2151,21.1009);input.action1 = true; input.facing_left = true; }
            if (tick == 39) { input.aim_pos += Vec2f(-69.8248,11.417);input.action1 = true; input.facing_left = true; }
            if (tick == 40) { input.aim_pos += Vec2f(-70.2592,9.12833);input.action1 = true; input.facing_left = true; }
            if (tick == 41) { input.aim_pos += Vec2f(-70.3298,7.32285);input.action1 = true; input.facing_left = true; }
            if (tick == 42) { input.aim_pos += Vec2f(-70.4606,5.41351);input.action1 = true; input.facing_left = true; }
            if (tick == 43) { input.aim_pos += Vec2f(-70.6027,3.39485);input.facing_left = true; }
            if (tick == 44) { input.aim_pos += Vec2f(-71.8398,-4.16327);input.facing_left = true; }
            if (tick == 45) { input.aim_pos += Vec2f(-81.7651,-21.6751);input.left = true; input.facing_left = true; }
            if (tick == 46) { input.aim_pos += Vec2f(-86.2417,-25.3299);input.left = true; input.facing_left = true; }
            if (tick == 47) { input.aim_pos += Vec2f(-88.7722,-19.7702);input.left = true; input.facing_left = true; }
            if (tick == 48) { input.aim_pos += Vec2f(-91.3049,-7.43494);input.left = true; input.facing_left = true; }
            if (tick == 49) { input.aim_pos += Vec2f(-89.2375,2.11583);input.left = true; input.facing_left = true; }
            if (tick == 50) { input.aim_pos += Vec2f(-88.3955,2.57086);input.facing_left = true; }
            if (tick == 51) { input.aim_pos += Vec2f(-85.6946,0.915619);input.facing_left = true; }
            if (tick == 52) { input.aim_pos += Vec2f(-82.529,-3.12659); input.facing_left = true; }
            if (tick == 53) { input.aim_pos += Vec2f(-80.953,-4.52829);input.facing_left = true; }
            if (tick == 54) { input.aim_pos += Vec2f(-81.0268,-4.29549);input.facing_left = true; }
            if (tick == 55) { input.aim_pos += Vec2f(-81.0861,-4.10872);input.facing_left = true; }
            if (tick == 56) { input.aim_pos += Vec2f(-80.7968,-4.97006);input.facing_left = true; }
            if (tick == 57) { input.aim_pos += Vec2f(-80.1666,-5.85558);input.facing_left = true; }
            if (tick == 58) { input.aim_pos += Vec2f(-80.1964,-5.76184);input.action1 = true; input.facing_left = true; }
            if (tick == 59) { input.aim_pos += Vec2f(-79.8895,-6.34546);input.action1 = true; input.facing_left = true; }
            if (tick == 60) { input.aim_pos += Vec2f(-79.5759,-7.28355);input.facing_left = true; }
            if (tick == 61) { input.aim_pos += Vec2f(-79.2575,-7.57013);input.facing_left = true; }
            if (tick == 62) { input.aim_pos += Vec2f(-79.272,-7.85779);input.facing_left = true; }
            if (tick == 63) { input.aim_pos += Vec2f(-79.2838,-8.1544);input.facing_left = true; }
            if (tick == 64) { input.aim_pos += Vec2f(-78.9592,-8.46032);input.facing_left = true; }
            if (tick == 65) { input.aim_pos += Vec2f(-78.9675,-8.4343);input.facing_left = true; }
            if (tick == 66) { input.aim_pos += Vec2f(-78.6399,-8.41647);input.facing_left = true; }
            if (tick == 67) { input.aim_pos += Vec2f(-78.645,-8.40073);input.facing_left = true; }
            if (tick == 68) { input.aim_pos += Vec2f(-78.6488,-8.38885);input.facing_left = true; }
            if (tick == 69) { input.aim_pos += Vec2f(-78.6958,-8.37904);input.facing_left = true; }
            if (tick == 70) { input.aim_pos += Vec2f(-78.6951,-8.37096);input.facing_left = true; }
            if (tick == 71) { input.aim_pos += Vec2f(-78.6897,-8.36378);input.facing_left = true; }
            if (tick == 72) { input.aim_pos += Vec2f(-78.6857,-8.35844);input.facing_left = true; }
            if (tick == 73) { input.aim_pos += Vec2f(-78.6818,-8.35331);input.facing_left = true; }
            if (tick == 74) { input.aim_pos += Vec2f(-78.7261,-8.34957);input.facing_left = true; }
            if (tick == 75) { input.aim_pos += Vec2f(-78.8806,-8.34631);input.facing_left = true; }
            if (tick == 76) { input.aim_pos += Vec2f(-78.914,-8.34409);input.facing_left = true; }
            if (tick == 77) { input.aim_pos += Vec2f(-78.8706,-8.34194);input.facing_left = true; }
            if (tick == 78) { input.aim_pos += Vec2f(-78.8359,-8.34048);input.facing_left = true; }
            if (tick == 79) { input.aim_pos += Vec2f(-78.8046,-8.33915);input.facing_left = true; }
            if (tick == 80) { input.aim_pos += Vec2f(-78.7791,-8.3381);input.facing_left = true; }
            if (tick == 81) { input.aim_pos += Vec2f(-78.76,-8.33729);input.facing_left = true; }
            if (tick == 82) { input.aim_pos += Vec2f(-78.7439,-8.33662);input.facing_left = true; }
            if (tick == 83) { input.aim_pos += Vec2f(-78.7296,-8.33602);input.facing_left = true; }
            if (tick == 84) { input.aim_pos += Vec2f(-78.7171,-8.33547);input.facing_left = true; }
            if (tick == 85) { input.aim_pos += Vec2f(-78.7078,-8.33511);input.facing_left = true; }
            if (tick == 86) { input.aim_pos += Vec2f(-78.7002,-8.33474);input.facing_left = true; }
            if (tick == 87) { input.aim_pos += Vec2f(-78.6941,-8.33453);input.facing_left = true; }
            if (tick == 88) { input.aim_pos += Vec2f(-78.6894,-8.33436);input.facing_left = true; }
            if (tick == 89) { input.aim_pos += Vec2f(-78.6853,-8.33418);input.facing_left = true; }
            if (tick == 90) { input.aim_pos += Vec2f(-78.6818,-8.00066);input.facing_left = true; }
            if (tick == 91) { input.aim_pos += Vec2f(-78.6792,-8.00049);input.facing_left = true; }
            if (tick == 92) { input.aim_pos += Vec2f(-78.6769,-8.00044);input.facing_left = true; }
            if (tick == 93) { input.aim_pos += Vec2f(-78.6749,-8.00044);input.facing_left = true; }
            if (tick == 94) { input.aim_pos += Vec2f(-78.6734,-8.00044);input.facing_left = true; }
            if (tick == 95) { input.aim_pos += Vec2f(-78.6723,-8.00044);input.facing_left = true; }
            if (tick == 96) { input.aim_pos += Vec2f(-78.6713,-8.00044);input.facing_left = true; }
            if (tick == 97) { input.aim_pos += Vec2f(-78.6704,-8.00044);input.facing_left = true; }
            if (tick == 98) { input.aim_pos += Vec2f(-78.6697,-8.00044);input.facing_left = true; }
            if (tick == 99) { input.aim_pos += Vec2f(-78.6694,-8.00043);input.facing_left = true; }
            if (tick == 100) { input.aim_pos += Vec2f(-78.6689,-8.00043);input.facing_left = true; }
            if (tick == 101) { input.aim_pos += Vec2f(-78.6685,-8.00043);input.facing_left = true; }
            if (tick == 102) { input.aim_pos += Vec2f(-78.6682,-8.00043);input.facing_left = true; }
            if (tick == 103) { input.aim_pos += Vec2f(-78.6679,-8.00043);input.facing_left = true; }
            if (tick == 104) { input.aim_pos += Vec2f(-78.6677,-8.00043);input.facing_left = true; }
            if (tick == 105) { input.aim_pos += Vec2f(-78.6675,-8.00043);input.facing_left = true; }
            if (tick == 106) { input.aim_pos += Vec2f(-78.6673,-8.00043);input.facing_left = true; }
            if (tick == 107) { input.aim_pos += Vec2f(-78.6671,-8.00043);input.facing_left = true; }
            if (tick == 108) { input.aim_pos += Vec2f(-78.6671,-8.00043);input.facing_left = true; }
            if (tick == 109) { input.aim_pos += Vec2f(-78.6671,-8.00043);input.facing_left = true; }
            if (tick >= 110) { if (isServer() && bot !is null) KickPlayer(bot); }
        }
        
    } else if (selected_training == Training::late_slashing_and_jabbing) {
        if (frog) {
            if (tick == 0) { blob.setPosition(Vec2f(265.425,136.245)); blob.setVelocity(Vec2f_zero); input.aim_pos = blob.getPosition(); }
            if (tick == 0) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 1) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 2) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 3) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 4) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 5) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 6) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 7) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 8) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 9) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 10) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 11) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 12) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 13) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 14) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 15) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 16) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 17) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 18) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 19) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 20) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 21) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 22) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 23) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 24) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 25) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 26) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 27) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 28) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 29) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 30) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 31) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 32) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 33) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 34) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 35) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 36) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 37) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 38) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 39) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 40) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 41) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 42) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 43) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 44) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 45) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 46) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 47) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 48) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 49) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 50) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 51) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 52) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 53) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 54) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 55) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 56) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 57) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 58) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 59) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 60) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 61) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 62) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 63) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick == 64) { input.aim_pos += Vec2f(102.666,-6.66701);input.action2 = true; }
            if (tick >= 65) { if (isServer() && bot !is null) KickPlayer(bot); }
        } else if (tiger) {
            if (tick == 0) { blob.setPosition(Vec2f(283.256,136.245)); blob.setVelocity(Vec2f_zero); input.aim_pos = blob.getPosition(); }
            if (tick == 0) { input.aim_pos += Vec2f(76.0006,-2.33359);}
            if (tick == 1) { input.aim_pos += Vec2f(75.6673,-2.33359);}
            if (tick == 2) { input.aim_pos += Vec2f(75.334,-2.33359);}
            if (tick == 3) { input.aim_pos += Vec2f(75.0006,-2.33359);}
            if (tick == 4) { input.aim_pos += Vec2f(75.0006,-2.33359);}
            if (tick == 5) { input.aim_pos += Vec2f(74.6673,-2.33359);}
            if (tick == 6) { input.aim_pos += Vec2f(74.334,-2.33359);}
            if (tick == 7) { input.aim_pos += Vec2f(74.334,-2.33359);}
            if (tick == 8) { input.aim_pos += Vec2f(74.0006,-2.33359);}
            if (tick == 9) { input.aim_pos += Vec2f(74.0006,-2.33359);}
            if (tick == 10) { input.aim_pos += Vec2f(73.6673,-2.33359);}
            if (tick == 11) { input.aim_pos += Vec2f(73.334,-2.33359);}
            if (tick == 12) { input.aim_pos += Vec2f(73.334,-2.33359);}
            if (tick == 13) { input.aim_pos += Vec2f(73.334,-2.33359);}
            if (tick == 14) { input.aim_pos += Vec2f(73.334,-2.33359);input.action1 = true; }
            if (tick == 15) { input.aim_pos += Vec2f(73.334,-2.33359);input.action1 = true; }
            if (tick == 16) { input.aim_pos += Vec2f(73.334,-2.33359);input.action1 = true; }
            if (tick == 17) { input.aim_pos += Vec2f(73.334,-2.33359);input.action1 = true; }
            if (tick == 18) { input.aim_pos += Vec2f(73.334,-2.33359);input.action1 = true; }
            if (tick == 19) { input.aim_pos += Vec2f(73.334,-2.33359);input.action1 = true; }
            if (tick == 20) { input.aim_pos += Vec2f(73.334,-2.33359);input.action1 = true; }
            if (tick == 21) { input.aim_pos += Vec2f(73.334,-2.33359);input.action1 = true; }
            if (tick == 22) { input.aim_pos += Vec2f(73.334,-2.33359);input.action1 = true; }
            if (tick == 23) { input.aim_pos += Vec2f(73.334,-2.33359);input.action1 = true; }
            if (tick == 24) { input.aim_pos += Vec2f(73.334,-2.33359);input.action1 = true; }
            if (tick == 25) { input.aim_pos += Vec2f(73.334,-2.33359);input.action1 = true; }
            if (tick == 26) { input.aim_pos += Vec2f(73.334,-2.33359);input.action1 = true; }
            if (tick == 27) { input.aim_pos += Vec2f(73.334,-2.33359);input.action1 = true; }
            if (tick == 28) { input.aim_pos += Vec2f(73.334,-2.33359);input.action1 = true; }
            if (tick == 29) { input.aim_pos += Vec2f(73.334,-2.33359);input.action1 = true; }
            if (tick == 30) { input.aim_pos += Vec2f(73.334,-2.33359);input.action1 = true; }
            if (tick == 31) { input.aim_pos += Vec2f(73.334,-2.33359);input.action1 = true; }
            if (tick == 32) { input.aim_pos += Vec2f(73.334,-2.33359);}
            if (tick == 33) { input.aim_pos += Vec2f(73.334,-2.33359);}
            if (tick == 34) { input.aim_pos += Vec2f(73.334,-2.33359);}
            if (tick == 35) { input.aim_pos += Vec2f(73.334,-2.33359);}
            if (tick == 36) { input.aim_pos += Vec2f(73.334,-2.33359);}
            if (tick == 37) { input.aim_pos += Vec2f(73.334,-2.33359);}
            if (tick == 38) { input.aim_pos += Vec2f(73.334,-2.33359);}
            if (tick == 39) { input.aim_pos += Vec2f(73.334,-2.33359);}
            if (tick == 40) { input.aim_pos += Vec2f(69.0006,-1.66693);}
            if (tick == 41) { input.aim_pos += Vec2f(51.334,-1.3336);}
            if (tick == 42) { input.aim_pos += Vec2f(-21.3327,-0.333588);input.facing_left = true; }
            if (tick == 43) { input.aim_pos += Vec2f(-126.666,-2.00026);input.facing_left = true; }
            if (tick == 44) { input.aim_pos += Vec2f(-208.333,-7.33359);input.facing_left = true; }
            if (tick == 45) { input.aim_pos += Vec2f(-212.999,-9.66693);input.facing_left = true; }
            if (tick == 46) { input.aim_pos += Vec2f(-197.999,-12.0003);input.action1 = true; input.facing_left = true; }
            if (tick == 47) { input.aim_pos += Vec2f(-196.999,-12.3336);input.action1 = true; input.facing_left = true; }
            if (tick == 48) { input.aim_pos += Vec2f(-196.666,-12.3336);input.facing_left = true; }
            if (tick == 49) { input.aim_pos += Vec2f(-191.999,-9.00026);input.facing_left = true; }
            if (tick == 50) { input.aim_pos += Vec2f(-188.666,-8.00026);input.facing_left = true; }
            if (tick == 51) { input.aim_pos += Vec2f(-188.666,-8.00026);input.facing_left = true; }
            if (tick == 52) { input.aim_pos += Vec2f(-188.666,-8.00026);input.facing_left = true; }
            if (tick == 53) { input.aim_pos += Vec2f(-188.333,-8.00026);input.facing_left = true; }
            if (tick == 54) { input.aim_pos += Vec2f(-188.333,-7.66693);input.facing_left = true; }
            if (tick == 55) { input.aim_pos += Vec2f(-188.333,-7.66693);input.facing_left = true; }
            if (tick == 56) { input.aim_pos += Vec2f(-188.333,-7.66693);input.facing_left = true; }
            if (tick == 57) { input.aim_pos += Vec2f(-188.333,-7.66693);input.facing_left = true; }
            if (tick == 58) { input.aim_pos += Vec2f(-188.333,-7.66693);input.facing_left = true; }
            if (tick == 59) { input.aim_pos += Vec2f(-188.333,-7.66693);input.facing_left = true; }
            if (tick == 60) { input.aim_pos += Vec2f(-188.333,-7.66693);input.facing_left = true; }
            if (tick == 61) { input.aim_pos += Vec2f(-186.999,-6.66692);input.facing_left = true; }
            if (tick == 62) { input.aim_pos += Vec2f(-185.333,-5.3336);input.facing_left = true; }
            if (tick == 63) { input.aim_pos += Vec2f(-182.666,-3.33359);input.facing_left = true; }
            if (tick == 64) { input.aim_pos += Vec2f(-180.999,-2.33359);input.facing_left = true; }
            if (tick == 65) { input.aim_pos += Vec2f(-180.999,-2.00026);input.facing_left = true; }
            if (tick == 66) { input.aim_pos += Vec2f(-180.666,-1.66693);input.facing_left = true; }
            if (tick == 67) { input.aim_pos += Vec2f(-180.666,-1.66693);input.facing_left = true; }
            if (tick == 68) { input.aim_pos += Vec2f(-180.666,-1.66693);input.facing_left = true; }
            if (tick == 69) { input.aim_pos += Vec2f(-180.666,-1.66693);input.facing_left = true; }
            if (tick == 70) { input.aim_pos += Vec2f(-180.666,-1.66693);input.facing_left = true; }
            if (tick == 71) { input.aim_pos += Vec2f(-180.666,-1.66693);input.facing_left = true; }
            if (tick == 72) { input.aim_pos += Vec2f(-180.666,-1.66693);input.facing_left = true; }
            if (tick == 73) { input.aim_pos += Vec2f(-180.666,-1.66693);input.facing_left = true; }
            if (tick == 74) { input.aim_pos += Vec2f(-180.666,-1.66693);input.facing_left = true; }
            if (tick == 75) { input.aim_pos += Vec2f(-180.666,-1.66693);input.facing_left = true; }
            if (tick == 76) { input.aim_pos += Vec2f(-180.666,-1.66693);input.facing_left = true; }
            if (tick == 77) { input.aim_pos += Vec2f(-180.666,-1.66693);input.facing_left = true; }
            if (tick == 78) { input.aim_pos += Vec2f(-180.666,-1.66693);input.facing_left = true; }
            if (tick == 79) { input.aim_pos += Vec2f(-180.666,-1.66693);input.facing_left = true; }
            if (tick == 80) { input.aim_pos += Vec2f(-180.666,-1.66693);input.facing_left = true; }
            if (tick == 81) { input.aim_pos += Vec2f(-180.666,-1.66693);input.facing_left = true; }
            if (tick == 82) { input.aim_pos += Vec2f(-180.666,-1.66693);input.facing_left = true; }
            if (tick == 83) { input.aim_pos += Vec2f(-180.666,-1.66693);input.facing_left = true; }
            if (tick == 84) { input.aim_pos += Vec2f(-180.666,-1.66693);input.facing_left = true; }
            if (tick >= 85) { if (isServer() && bot !is null) KickPlayer(bot); }
        }
        
    } else if (selected_training == Training::easy_slash_stomp) {
        if (frog) {
            if (tick == 0) { blob.setPosition(Vec2f(62.3068,112.3)); blob.setVelocity(Vec2f_zero); input.aim_pos = blob.getPosition(); }
            if (tick == 0) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 1) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 2) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 3) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 4) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 5) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 6) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 7) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 8) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 9) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 10) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 11) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 12) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 13) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 14) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 15) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 16) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 17) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 18) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 19) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 20) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 21) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 22) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 23) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 24) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 25) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 26) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 27) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 28) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 29) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 30) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 31) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 32) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 33) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 34) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 35) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 36) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 37) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 38) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 39) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 40) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 41) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 42) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 43) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 44) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 45) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 46) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 47) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 48) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 49) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 50) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 51) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 52) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 53) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 54) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 55) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 56) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 57) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 58) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 59) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 60) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 61) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 62) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 63) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 64) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 65) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 66) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 67) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 68) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 69) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 70) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick >= 71) { if (isServer() && bot !is null) KickPlayer(bot); }
        } else if (tiger) {
            if (tick == 0) { blob.setPosition(Vec2f(39.6999,88.3003)); blob.setVelocity(Vec2f_zero); input.aim_pos = blob.getPosition(); }
            if (tick == 0) { input.aim_pos += Vec2f(21.35,12.8299);}
            if (tick == 1) { input.aim_pos += Vec2f(21.3473,12.8577);}
            if (tick == 2) { input.aim_pos += Vec2f(21.3468,12.8627);}
            if (tick == 3) { input.aim_pos += Vec2f(21.3442,12.8892);}
            if (tick == 4) { input.aim_pos += Vec2f(21.3421,12.9104);}
            if (tick == 5) { input.aim_pos += Vec2f(21.3405,12.9275);}
            if (tick == 6) { input.aim_pos += Vec2f(21.3392,12.9403);input.up = true; }
            if (tick == 7) { input.aim_pos += Vec2f(21.338,13.9835);input.up = true; }
            if (tick == 8) { input.aim_pos += Vec2f(21.3371,15.9575);input.up = true; }
            if (tick == 9) { input.aim_pos += Vec2f(21.3364,18.7116);input.up = true; }
            if (tick == 10) { input.aim_pos += Vec2f(21.3357,20.4863);input.up = true; }
            if (tick == 11) { input.aim_pos += Vec2f(21.3353,22.367);input.up = true; }
            if (tick == 12) { input.aim_pos += Vec2f(21.3349,23.4749);input.left = true; input.up = true; }
            if (tick == 13) { input.aim_pos += Vec2f(21.3346,24.0828);input.left = true; input.up = true; }
            if (tick == 14) { input.aim_pos += Vec2f(18.001,24.5332);input.left = true; input.up = true; }
            if (tick == 15) { input.aim_pos += Vec2f(6.66755,24.6943);input.left = true; input.up = true; }
            if (tick == 16) { input.aim_pos += Vec2f(-6.9993,25.8071);input.left = true; input.up = true; }
            if (tick == 17) { input.aim_pos += Vec2f(-16.3327,25.8706);input.left = true; input.up = true; }
            if (tick == 18) { input.aim_pos += Vec2f(-26.3328,24.143);input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 19) { input.aim_pos += Vec2f(-31.9996,23.5749);input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 20) { input.aim_pos += Vec2f(-33.333,22.1378);input.left = true; input.up = true; input.facing_left = true; }
            if (tick == 21) { input.aim_pos += Vec2f(-32.9997,20.9058);input.left = true; input.right = true; input.up = true; input.facing_left = true; }
            if (tick == 22) { input.aim_pos += Vec2f(-26.3331,15.6464);input.action1 = true; input.right = true; input.up = true; input.facing_left = true; }
            if (tick == 23) { input.aim_pos += Vec2f(-16.5798,11.4989);input.action1 = true; input.right = true; input.up = true; input.facing_left = true; }
            if (tick == 24) { input.aim_pos += Vec2f(7.20996,8.69586);input.action1 = true; input.right = true; input.up = true; }
            if (tick == 25) { input.aim_pos += Vec2f(27.5389,5.17524);input.action1 = true; input.right = true; }
            if (tick == 26) { input.aim_pos += Vec2f(29.0971,3.32468);input.action1 = true; input.right = true; }
            if (tick == 27) { input.aim_pos += Vec2f(27.4626,2.17603);input.action1 = true; input.right = true; }
            if (tick == 28) { input.aim_pos += Vec2f(25.562,3.10176);input.action1 = true; input.right = true; }
            if (tick == 29) { input.aim_pos += Vec2f(23.2539,3.84455);input.action1 = true; input.right = true; }
            if (tick == 30) { input.aim_pos += Vec2f(15.8894,5.40361);input.action1 = true; }
            if (tick == 31) { input.aim_pos += Vec2f(7.3099,6.25343);input.action1 = true; }
            if (tick == 32) { input.aim_pos += Vec2f(-0.704254,6.53523);input.action1 = true; }
            if (tick == 33) { input.aim_pos += Vec2f(-5.28344,6.0607);input.action1 = true; input.facing_left = true; }
            if (tick == 34) { input.aim_pos += Vec2f(-7.39443,5.5396);input.action1 = true; input.left = true; input.facing_left = true; }
            if (tick == 35) { input.aim_pos += Vec2f(-9.76709,7.60632);input.action1 = true; input.left = true; input.facing_left = true; }
            if (tick == 36) { input.aim_pos += Vec2f(-14.0936,11.9519);input.action1 = true; input.left = true; input.facing_left = true; }
            if (tick == 37) { input.aim_pos += Vec2f(-20.6079,16.9918);input.action1 = true; input.left = true; input.facing_left = true; }
            if (tick == 38) { input.aim_pos += Vec2f(-25.7391,21.5834);input.action1 = true; input.left = true; input.facing_left = true; }
            if (tick == 39) { input.aim_pos += Vec2f(-28.703,25.5688);input.action1 = true; input.left = true; input.facing_left = true; }
            if (tick == 40) { input.aim_pos += Vec2f(-41.2978,44.8861);input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 41) { input.aim_pos += Vec2f(-55.9268,72.2627);input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 42) { input.aim_pos += Vec2f(-59.717,91.6606);input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 43) { input.aim_pos += Vec2f(-64.5258,103.104);input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 44) { input.aim_pos += Vec2f(-62.289,99.7039);input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 45) { input.aim_pos += Vec2f(-60.4876,95.9293);input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 46) { input.aim_pos += Vec2f(-58.0561,91.6111);input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 47) { input.aim_pos += Vec2f(-56.6783,86.6302);input.action2 = true; input.left = true; input.facing_left = true; }
            if (tick == 48) { input.aim_pos += Vec2f(-10.4735,0.00494385);input.facing_left = true; }
            if (tick == 49) { input.aim_pos += Vec2f(-10.4416,0.00453186);input.facing_left = true; }
            if (tick == 50) { input.aim_pos += Vec2f(-10.2991,0.00357056);input.facing_left = true; }
            if (tick == 51) { input.aim_pos += Vec2f(-10.221,0.00268555);input.facing_left = true; }
            if (tick == 52) { input.aim_pos += Vec2f(-10.1856,0.00202942);input.facing_left = true; }
            if (tick == 53) { input.aim_pos += Vec2f(-10.1564,0.00152588);input.facing_left = true; }
            if (tick == 54) { input.aim_pos += Vec2f(-10.1319,0.0011673);input.facing_left = true; }
            if (tick == 55) { input.aim_pos += Vec2f(-10.1113,0.000907898);input.facing_left = true; }
            if (tick == 56) { input.aim_pos += Vec2f(-10.0939,0.000694275);input.facing_left = true; }
            if (tick == 57) { input.aim_pos += Vec2f(-10.0793,0.000549316);input.facing_left = true; }
            if (tick == 58) { input.aim_pos += Vec2f(-40.9799,19.4709);input.facing_left = true; }
            if (tick == 59) { input.aim_pos += Vec2f(-41.0195,20.2052);input.facing_left = true; }
            if (tick == 60) { input.aim_pos += Vec2f(-41.0487,20.7982);input.facing_left = true; }
            if (tick == 61) { input.aim_pos += Vec2f(-41.0697,21.2766);input.facing_left = true; }
            if (tick == 62) { input.aim_pos += Vec2f(-41.0845,21.6615);input.facing_left = true; }
            if (tick == 63) { input.aim_pos += Vec2f(-41.0933,21.9939);input.facing_left = true; }
            if (tick == 64) { input.aim_pos += Vec2f(-41.0973,22.2746);input.facing_left = true; }
            if (tick == 65) { input.aim_pos += Vec2f(-41.083,22.4527);input.facing_left = true; }
            if (tick == 66) { input.aim_pos += Vec2f(-41.0682,22.6355);input.facing_left = true; }
            if (tick == 67) { input.aim_pos += Vec2f(-41.058,22.761);input.facing_left = true; }
            if (tick == 68) { input.aim_pos += Vec2f(-41.0498,22.8638);input.facing_left = true; }
            if (tick == 69) { input.aim_pos += Vec2f(-41.0424,22.9543);input.facing_left = true; }
            if (tick == 70) { input.aim_pos += Vec2f(-41.0366,23.0267);input.facing_left = true; }
            if (tick == 71) { input.aim_pos += Vec2f(-41.0318,23.0849);input.facing_left = true; }
            if (tick == 72) { input.aim_pos += Vec2f(-41.0283,23.1288);input.facing_left = true; }
            if (tick == 73) { input.aim_pos += Vec2f(-41.0617,23.1701);input.facing_left = true; }
            if (tick == 74) { input.aim_pos += Vec2f(-41.4047,23.53);input.facing_left = true; }
            if (tick == 75) { input.aim_pos += Vec2f(-41.4095,23.5524);input.facing_left = true; }
            if (tick == 76) { input.aim_pos += Vec2f(-41.4103,23.5743);input.facing_left = true; }
            if (tick == 77) { input.aim_pos += Vec2f(-41.4107,23.5907);input.facing_left = true; }
            if (tick == 78) { input.aim_pos += Vec2f(-41.4098,23.6042);input.facing_left = true; }
            if (tick == 79) { input.aim_pos += Vec2f(-41.409,23.6146);input.facing_left = true; }
            if (tick == 80) { input.aim_pos += Vec2f(-41.4062,23.624);input.facing_left = true; }
            if (tick == 81) { input.aim_pos += Vec2f(-41.4031,23.6318);input.facing_left = true; }
            if (tick == 82) { input.aim_pos += Vec2f(-41.4005,23.6377);input.facing_left = true; }
            if (tick == 83) { input.aim_pos += Vec2f(-41.3984,23.6422);input.facing_left = true; }
            if (tick == 84) { input.aim_pos += Vec2f(-41.3933,23.6471);input.facing_left = true; }
            if (tick >= 85) { if (isServer() && bot !is null) KickPlayer(bot); }
        }
        
    } else if (selected_training == Training::slash_stomp) {
        if (frog) {
            if (tick == 0) { blob.setPosition(Vec2f(62.3068,112.3)); blob.setVelocity(Vec2f_zero); input.aim_pos = blob.getPosition(); }
            if (tick == 0) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 1) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 2) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 3) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 4) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 5) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 6) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 7) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 8) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 9) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 10) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 11) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 12) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 13) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 14) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 15) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 16) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 17) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 18) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 19) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 20) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 21) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 22) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 23) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 24) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 25) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 26) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 27) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 28) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 29) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 30) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 31) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 32) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 33) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 34) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 35) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 36) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 37) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 38) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 39) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 40) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 41) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 42) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 43) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 44) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 45) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 46) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 47) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 48) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 49) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 50) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 51) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 52) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 53) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 54) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 55) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 56) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 57) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 58) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 59) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 60) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 61) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 62) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 63) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 64) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 65) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 66) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 67) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 68) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 69) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick == 70) { input.aim_pos += Vec2f(-1.99993,-84.3335);input.action2 = true; input.facing_left = true; }
            if (tick >= 71) { if (isServer() && bot !is null) KickPlayer(bot); }
        } else if (tiger) {
            if (tick == 0) { blob.setPosition(Vec2f(39.6877,88.1212)); blob.setVelocity(Vec2f_zero); input.aim_pos = blob.getPosition(); }
            if (tick == 0) { input.aim_pos += Vec2f(25.4044,29.0163);}
            if (tick == 1) { input.aim_pos += Vec2f(25.3917,29.0135);}
            if (tick == 2) { input.aim_pos += Vec2f(25.3896,29.013);}
            if (tick == 3) { input.aim_pos += Vec2f(25.3786,29.0106);}
            if (tick == 4) { input.aim_pos += Vec2f(25.3691,29.0084);}
            if (tick == 5) { input.aim_pos += Vec2f(25.3621,29.0069);}
            if (tick == 6) { input.aim_pos += Vec2f(25.3564,29.0056);}
            if (tick == 7) { input.aim_pos += Vec2f(25.3518,29.0046);}
            if (tick == 8) { input.aim_pos += Vec2f(25.3478,29.0037);}
            if (tick == 9) { input.aim_pos += Vec2f(25.3448,29.003);}
            if (tick == 10) { input.aim_pos += Vec2f(25.3422,29.0024);}
            if (tick == 11) { input.aim_pos += Vec2f(25.338,29.002);input.up = true; }
            if (tick == 12) { input.aim_pos += Vec2f(25.3348,30.0328);input.up = true; }
            if (tick == 13) { input.aim_pos += Vec2f(26.3328,29.6858);input.action1 = true; input.right = true; input.up = true; }
            if (tick == 14) { input.aim_pos += Vec2f(28.5109,26.1281);input.action1 = true; input.right = true; input.up = true; }
            if (tick == 15) { input.aim_pos += Vec2f(29.2895,14.3595);input.action1 = true; input.right = true; input.up = true; }
            if (tick == 16) { input.aim_pos += Vec2f(28.4105,9.36005);input.action1 = true; input.right = true; input.up = true; }
            if (tick == 17) { input.aim_pos += Vec2f(27.6064,7.05627);input.action1 = true; input.right = true; input.up = true; }
            if (tick == 18) { input.aim_pos += Vec2f(25.949,7.21198);input.action1 = true; input.right = true; input.up = true; }
            if (tick == 19) { input.aim_pos += Vec2f(24.1666,7.19138);input.action1 = true; }
            if (tick == 20) { input.aim_pos += Vec2f(22.9024,6.98753);input.action1 = true; }
            if (tick == 21) { input.aim_pos += Vec2f(22.0143,6.85545);input.action1 = true; }
            if (tick == 22) { input.aim_pos += Vec2f(19.1113,9.50692);input.action1 = true; }
            if (tick == 23) { input.aim_pos += Vec2f(16.8481,11.5228);input.action1 = true; }
            if (tick == 24) { input.aim_pos += Vec2f(14.0452,15.406);input.action1 = true; }
            if (tick == 25) { input.aim_pos += Vec2f(12.3413,18.4857);input.action1 = true; }
            if (tick == 26) { input.aim_pos += Vec2f(11.0059,22.126);input.action1 = true; }
            if (tick == 27) { input.aim_pos += Vec2f(10.4531,26.97);input.action1 = true; input.down = true; }
            if (tick == 28) { input.aim_pos += Vec2f(8.66513,40.7776);input.action1 = true; input.down = true; }
            if (tick == 29) { input.aim_pos += Vec2f(0.236904,76.8464);input.action2 = true; input.down = true; }
            if (tick == 30) { input.aim_pos += Vec2f(-5.12588,111.536);input.action2 = true; input.down = true; }
            if (tick == 31) { input.aim_pos += Vec2f(-4.66198,117.231);input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 32) { input.aim_pos += Vec2f(-3.27369,112.678);input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 33) { input.aim_pos += Vec2f(-1.54626,103.877);input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 34) { input.aim_pos += Vec2f(-3.55701,92.038);input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 35) { input.aim_pos += Vec2f(-5.08113,82.9418);input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 36) { input.aim_pos += Vec2f(-4.97113,69.9332);input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 37) { input.aim_pos += Vec2f(-2.34082,53.9401);input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 38) { input.aim_pos += Vec2f(-1.04594,48.6588);input.action2 = true; input.down = true; input.facing_left = true; }
            if (tick == 39) { input.aim_pos += Vec2f(-0.366211,47.2376);input.facing_left = true; }
            if (tick == 40) { input.aim_pos += Vec2f(-0.0792732,45.9748);input.facing_left = true; }
            if (tick == 41) { input.aim_pos += Vec2f(0.405693,43.5129);input.facing_left = true; }
            if (tick == 42) { input.aim_pos += Vec2f(0.617195,43.8451);input.facing_left = true; }
            if (tick == 43) { input.aim_pos += Vec2f(0.8046,44.3215);}
            if (tick == 44) { input.aim_pos += Vec2f(0.856987,44.9736);}
            if (tick == 45) { input.aim_pos += Vec2f(0.990578,45.5206);}
            if (tick == 46) { input.aim_pos += Vec2f(1.10698,45.9399);}
            if (tick == 47) { input.aim_pos += Vec2f(1.09397,46.2514);}
            if (tick == 48) { input.aim_pos += Vec2f(1.16637,46.4996);}
            if (tick == 49) { input.aim_pos += Vec2f(1.2515,46.7343);}
            if (tick == 50) { input.aim_pos += Vec2f(1.20148,46.8674);}
            if (tick == 51) { input.aim_pos += Vec2f(1.26715,47.0276);}
            if (tick == 52) { input.aim_pos += Vec2f(1.33968,47.1691);}
            if (tick == 53) { input.aim_pos += Vec2f(1.26978,47.2122);}
            if (tick == 54) { input.aim_pos += Vec2f(1.31165,47.2955);}
            if (tick == 55) { input.aim_pos += Vec2f(1.36927,47.3758);}
            if (tick == 56) { input.aim_pos += Vec2f(1.28951,47.3718);}
            if (tick == 57) { input.aim_pos += Vec2f(1.31259,47.4123);}
            if (tick == 58) { input.aim_pos += Vec2f(1.36883,47.4686);}
            if (tick == 59) { input.aim_pos += Vec2f(1.28499,47.4383);}
            if (tick == 60) { input.aim_pos += Vec2f(1.30086,47.4603);}
            if (tick == 61) { input.aim_pos += Vec2f(1.35231,47.502);}
            if (tick == 62) { input.aim_pos += Vec2f(1.27071,47.4574);}
            if (tick == 63) { input.aim_pos += Vec2f(1.27074,47.4629);}
            if (tick == 64) { input.aim_pos += Vec2f(1.33478,47.5063);}
            if (tick == 65) { input.aim_pos += Vec2f(1.25459,47.4512);}
            if (tick == 66) { input.aim_pos += Vec2f(1.24223,47.4462);}
            if (tick >= 67) { if (isServer() && bot !is null) KickPlayer(bot); }
        }
        
    } else if (selected_training == Training::foo) {
        if (frog) {
        } else if (tiger) {
        }
        
    } else {
        if (frog) {
            if (isServer() && bot !is null) KickPlayer(bot);
        } else if (tiger) {
            if (isServer() && bot !is null) KickPlayer(bot);
        }
    }
    
    
    blob.setKeyPressed(key_action1, input.action1);
    blob.setKeyPressed(key_action2, input.action2);
    blob.setKeyPressed(key_action3, input.action3);
    
    blob.setKeyPressed(key_left, input.left);
    blob.setKeyPressed(key_right, input.right);
    blob.setKeyPressed(key_up, input.up);
    blob.setKeyPressed(key_down, input.down);
    
    blob.SetFacingLeft(input.facing_left);
    blob.setAimPos(input.aim_pos);
    
    getRules().set("shown_input", @input);
}

const f32 lineheight = 16;
const f32 padheight = 6;
const f32 stepheight = lineheight + padheight + 2;

Vec2f draw_training_mode (Vec2f pos, CControls@ controls, string text, int mode) {
    Vec2f mousePos = controls.getMouseScreenPos();
    SColor color = SColor(255, 200, 200, 200);
    SColor background_color = SColor(200, 100, 100, 100);
    
    int selected_mode = getRules().get_s32("selected_training");
    
    if (mode == selected_mode) {
        color = SColor(255, 210, 220, 252);
        background_color = SColor(250, 80, 120, 150);
    }
    
    if ((mousePos.x >= pos.x - 3) && (mousePos.x <= pos.x + 500) &&
        (mousePos.y >= pos.y - 2) && (mousePos.y <= pos.y + 18)) {
        if (mode == selected_mode) {
            color = SColor(255, 210, 220, 252);
            background_color = SColor(250, 80, 150, 160);
        } else {
            color = SColor(255, 252, 252, 252);
            background_color = SColor(230, 150, 150, 150);
        }
        
        if (controls.mousePressed1) {
            if (isServer()) { // TODO(hobey): gui only happens on client, but all of this really is for local only; just remove all isServer() stuff?
                for (int i = 0; i < getPlayerCount(); i += 1) {
                    CPlayer@ p = getPlayer(i);
                    if (p is null) continue;
                    string username = p.getUsername();
                    if (p.isBot()) {
                        if (is_a_frog(username) ||
                            (is_a_tiger(username))) {
                            // if (p.getBlob() !is null) p.getBlob().server_Die();
                            KickPlayer(p);
                        }
                    }
                }
            }
            getRules().set_s32("selected_training", mode);
        }
    }
    
    GUI::DrawRectangle(pos + Vec2f(-3, -2), pos + Vec2f(500, 18), background_color);
    GUI::DrawText(text, pos, color);
    pos.y += stepheight;
    
    return pos;
}

void onRenderScoreboard(CRules@ rules) {
    float resolution_scale = getDriver().getResolutionScaleFactor(); // NOTE(hobey): relative to 1280x720
    GUI::SetFont("menu");
    
    
    Vec2f pos = Vec2f(100, 150);
    
    CControls@ controls = getControls();
    
    // NOTE(hobey): :TrainingMode
    pos = draw_training_mode(pos, controls, "Crouch shieldslide", Training::crouch_shieldslide);
    pos = draw_training_mode(pos, controls, "Crouch+jab shieldslide", Training::crouch_jab_shieldslide);
    pos = draw_training_mode(pos, controls, "Overhead slash shieldslide", Training::overhead_slash_shieldslide);
    pos.y += stepheight;
    
    pos = draw_training_mode(pos, controls, "Crouching into someone's shield", Training::crouching_into_someones_shield);
    pos = draw_training_mode(pos, controls, "Crouching into someone's shield from above", Training::crouching_into_someones_shield_from_above);
    pos.y += stepheight;
    
    pos = draw_training_mode(pos, controls, "Correct jab direction inside enemy shield", Training::jab_direction_inside_shield);
    pos = draw_training_mode(pos, controls, "Correct slash direction inside enemy shield", Training::slash_direction_inside_shield);
    pos.y += stepheight;
    
    pos = draw_training_mode(pos, controls, "Turnaround slash while crouching into enemy shield", Training::turnaround_slash_while_crouching_into_enemy_shield);
    pos.y += stepheight;
    
    pos = draw_training_mode(pos, controls, "Instajab", Training::instajab);
    pos = draw_training_mode(pos, controls, "Instaslashing a slashspammer", Training::instaslash_slashspammer);
    pos = draw_training_mode(pos, controls, "Instaslashing a fast slashspammer", Training::instaslash_fast_slashspammer);
    pos.y += stepheight;
    
    pos = draw_training_mode(pos, controls, "Slash stomping", Training::slash_stomp);
    pos = draw_training_mode(pos, controls, "Wall jump slash stomping", Training::easy_slash_stomp);
    pos = draw_training_mode(pos, controls, "Hard slash stomping", Training::hard_slash_stomp);
    pos.y += stepheight;
    
    pos = draw_training_mode(pos, controls, "Shieldbash+jab", Training::shield_bash_and_jab);
    pos = draw_training_mode(pos, controls, "Shieldbash+jab against a wall", Training::shield_bash_and_jab_against_wall);
    pos = draw_training_mode(pos, controls, "Shieldbash+slash against a wall", Training::shield_bash_and_slash_against_wall);
    pos.y += stepheight;
    
    pos = draw_training_mode(pos, controls, "Late slashing and jabbing", Training::late_slashing_and_jabbing);
    
}
