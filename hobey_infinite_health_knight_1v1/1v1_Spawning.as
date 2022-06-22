


void onInit (CRules@ rules) {
    onRestart(rules);
}
void onRestart (CRules@ rules) {
    rules.set_s32("knight_initial_health", 999999);
}

void onTick (CRules@ rules) {
    
    if (isServer()) {
        Vec2f respawnPos;
        Vec2f respawnPos_red;
        
        {
            // NOTE(hobey): figure out respawn pos
            
            CMap@ map = getMap();
            Vec2f[] respawnPositions;
            if (!map.getMarkers("blue main spawn", respawnPositions))
            {
                // warn("Blue spawn marker not found on map");
                respawnPos = Vec2f(150.0f, map.getLandYAtX(150.0f / map.tilesize) * map.tilesize - 32.0f);
                respawnPos.y -= 16.0f;
            }
            /*
            else if (!map.getMarkers("red main spawn", respawnPositions))
            {
                // warn("Blue spawn marker not found on map");
                respawnPos_red = Vec2f(150.0f, map.getLandYAtX(150.0f / map.tilesize) * map.tilesize - 32.0f);
                respawnPos_red.y -= 16.0f;
            }
            */
            else
            {
                // for (uint i = 0; i < respawnPositions.length; i++)
                int i = 0;
                {
                    respawnPos = respawnPositions[i];
                    respawnPos.y -= 16.0f;
                    // respawnPos_red = respawnPositions[i];
                    // respawnPos_red.y -= 16.0f;
                }
            }
        }
        
        for (int i = 0; i < getPlayerCount(); i += 1) {
            CPlayer@ p = getPlayer(i);
            if (p !is null && (p.getBlob() is null || p.getBlob().hasTag("dead"))) {
                
                int team_num = p.getTeamNum(); // NOTE(hobey): stay in the same team by default
                if (team_num == 255) team_num = 0; // NOTE(hobey): team on first join seems to be set to 255
                
                for (int j = 0; j < getPlayerCount(); j += 1) {
                    if (j == i) continue;
                    
                    CPlayer@ other_player = getPlayer(j);
                    if (other_player.getTeamNum() == team_num) {
                        
                        // NOTE(hobey): find an empty team
                        for (team_num = 0; team_num < 255; team_num += 1) {
                            bool empty = true;
                            for (int l = 0; l < getPlayerCount(); l += 1) {
                                CPlayer@ player = getPlayer(l);
                                if (player.getTeamNum() == team_num) {
                                    empty = false;
                                    break;
                                }
                            }
                            if (empty) {
                                break;
                            }
                        }
                        break;
                    }
                }
                
                CBlob@ newBlob = server_CreateBlob("knight", team_num, respawnPos);
                // CBlob@ newBlob = server_CreateBlob("knight", 1, respawnPos_red);
                
                if (newBlob !is null) {
                    newBlob.server_SetPlayer(p);
                    newBlob.server_SetHealth(rules.get_s32("knight_initial_health"));
                    p.server_setTeamNum(newBlob.getTeamNum());
                }
            }
        }
    }
}
