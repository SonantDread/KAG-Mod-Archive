
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

void onInit (CBlob@ blob) {
}

void onTick (CBlob@ blob) {
    if (blob.getPlayer() !is null) {
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
        
    } else if (!blob.hasTag("dead")) {
        // getCamera().setTarget(blob);
        
        Tick_Input@ input; getRules().get("training_input", @input);
        // Tick_Input input;
        if (false) {
            input.action1 = false;
            input.action2 = false;
            input.action3 = false;
            input.left  = false;
            input.right = false;
            input.up    = false;
            input.down  = false;
            input.facing_left  = false;
            input.aim_pos = blob.getPosition();
            
            input.action2 = true;
            int ticks = blob.getTickSinceCreated();
            if (ticks % 120 < 60) {
                // input.aim_pos = blob.getPosition() + Vec2f(2, 10)*8.f;
                input.aim_pos = blob.getPosition() + Vec2f(200, 350);
                input.right = true;
            } else {
                input.facing_left = true;
                input.aim_pos = blob.getPosition() + Vec2f(-200, 350);
                input.left = true;
            }
            
            CBlob@[] blobs; getBlobsByTag("slow", blobs);
            bool slow = false;
            if (blobs.length == 0) {
                slow = true;
                blob.Tag("slow");
            } else if (blobs[0] is blob) {
                slow = true;
            }
            
            if (slow) {
                input.up = true;
            } else {
                // getCamera().setTarget(blob);
                // if (ticks % 2 < 1) input.up = true;
                if (ticks % 7 < 2) input.up = true; // NOTE(hobey): humanly possible keyboard input
            }
            
            // if (isServer()) if (ticks > 60) blob.server_Die();
        } else if (false) {
            input.action1 = false;
            input.action2 = false;
            input.action3 = false;
            input.left  = false;
            input.right = false;
            input.up    = false;
            input.down  = false;
            input.facing_left  = false;
            input.aim_pos = blob.getPosition();
            
            int ticks = blob.getTickSinceCreated();
            
            int total_time = 120;
            if (ticks == 0) {
                blob.set_Vec2f("starting_position", blob.getPosition());
            }
            // if (isServer()) {
            // if ((ticks > 0) && (ticks == total_time)) blob.server_setPosition(blob.get_Vec2f("starting_position"));
            // }
            ticks %= total_time;
            
            input.aim_pos = blob.getPosition() + Vec2f(200, -350);
            // input.aim_pos = blob.getPosition() + Vec2f(-200, -350);
            
            if (false) {
                if (ticks < 37) {
                    input.action1 = true;
                } else if (ticks < 39) {
                    input.up = true;
                    input.action1 = true;
                } else if (ticks < 40) {
                    input.up = true;
                } else if (ticks < 41) {
                    input.action1 = true;
                    input.up = true;
                } else if (ticks < 80) {
                    input.action1 = true;
                    input.up = true;
                    input.right = true;
                }
            } else {
                
                do {
                    if (ticks >=  0) input.action1 = true;
                    if (ticks >= 12) input.up      = true;
                    if (ticks >= 15) input.action1 = false;
                    
                    if (ticks >= 25) input.right   = true;
                    
                    if (ticks >= 40) input.right   = false;
                    if (ticks >= 40) input.left    = true;
                    if (ticks >= 40) input.action2 = true;
                    if (ticks >= 41) input.left    = false;
                    if (ticks >= 41) input.right   = true;
                    
                    if (ticks >= 60) input.up      = false;
                    if (ticks >= 60) input.right   = false;
                    
                    
                } while (false);
                
            }
            // if (isServer()) if (ticks > 120) blob.server_Die();
            
            // input.facing_left = false;
            
        }
        
        // blob.server_Die();
        
        blob.setKeyPressed(key_action1, input.action1);
        blob.setKeyPressed(key_action2, input.action2);
        blob.setKeyPressed(key_action3, input.action3);
        
        blob.setKeyPressed(key_left, input.left);
        blob.setKeyPressed(key_right, input.right);
        blob.setKeyPressed(key_up, input.up);
        blob.setKeyPressed(key_down, input.down);
        
        blob.SetFacingLeft(input.facing_left);
        blob.setAimPos(input.aim_pos);
        getRules().set("training_input", @input);
    }
}
/*
void onRender (CRules@ rules) {
    Tick_Input@ input; rules.get("training_input", @input);
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
*/