#include "TeamColour.as";
#include "ScoreboardCommon.as";

void onRenderScoreboard(CRules@ this)
{
    GUI::SetFont("menu");
    //sort players
    CPlayer@[] sortedplayers;
    CPlayer@[] spectators;

    for (u32 i = 0; i < getPlayersCount(); i++) {
        CPlayer@ p = getPlayer(i);
        s8 team = p.getTeamNum();
        bool inserted = false;
        for (u32 j = 0; j < sortedplayers.length; j++) {
            if (sortedplayers[j].getTeamNum() < team) {
                sortedplayers.insert(j, p);
                inserted = true;
                break;
            }
        }
        if (!inserted)
            sortedplayers.push_back(p);
    }

    //draw board
    f32 stepheight = 16;
    Vec2f topleft(100, 150);
    Vec2f bottomright(getScreenWidth() - 100, topleft.y + (sortedplayers.length + (spectators.length == 0 ? 0 : 2) + 3.5) * stepheight + getPlayersCount()*4);
    GUI::DrawRectangle(topleft, bottomright);

    //offset border
    topleft.x += stepheight;
    bottomright.x -= stepheight;
    topleft.y += stepheight;

    //draw player table header
    GUI::DrawText("Username", Vec2f(topleft.x+20, topleft.y), SColor(0xffffffff));
    GUI::DrawText("Title", Vec2f(topleft.x+220, topleft.y), SColor(0xffffffff));
    GUI::DrawText("Coins", Vec2f(bottomright.x - 400, topleft.y), SColor(0xffffffff));
    GUI::DrawText("Nickname", Vec2f(bottomright.x - 600, topleft.y), SColor(0xffffffff));
    GUI::DrawText("Ping", Vec2f(bottomright.x - 200, topleft.y), SColor(0xffffffff));
    //GUI::DrawText("Kills", Vec2f(bottomright.x - 260, topleft.y), SColor(0xffffffff));

    topleft.y += stepheight * 0.5f;

    //draw players
    for (u32 i = 0; i < sortedplayers.length; i++)
    {
        CPlayer@ p = sortedplayers[i];
        CPlayer@ localp = getLocalPlayer();
        topleft.y += stepheight + 4;
        bottomright.y = topleft.y + stepheight;
 
        GUI::DrawPane(Vec2f(topleft.x+16, topleft.y-1), Vec2f(bottomright.x, bottomright.y+2), SColor(getTeamColor(p.getTeamNum())) );

        string tex = p.getScoreboardTexture();
        if(tex != "" && p.getBlob() != null && localp.getBlob() != null && !p.getBlob().hasTag("dead") && p.getBlob().getTeamNum() == localp.getBlob().getTeamNum())
        {
                u16 frame = p.getScoreboardFrame();
            Vec2f framesize = p.getScoreboardFrameSize();
                GUI::DrawIcon( tex, frame, framesize, topleft, 0.5f, p.getTeamNum() );
        }

        //have to calc this from ticks
        s32 ping_in_ms = s32(p.getPing() * 1000.0f / 30.0f);

        //Titles for players
        if (p.getUsername()=="Yeti5000707" || p.getUsername()=="FrothyFruitbat" || p.getUsername()=="the1sad1numanator") {  // Developer of mod
        	GUI::DrawText(p.getUsername(), topleft + Vec2f(20, 0), SColor(0xffe27b66));
        	GUI::DrawText(p.getCharacterName(), Vec2f(bottomright.x - 600, topleft.y), SColor(0xffe27b66));
        	GUI::DrawText("Developer", topleft + Vec2f(220, 0), SColor(0xffe27b66));
   		}
   		else if (p.getUsername()=="xxxTentacion") { 																			  //Patreon supporter ... yup :droplet:
        	GUI::DrawText(p.getUsername(), topleft + Vec2f(20, 0), SColor(0xffb200ff));
        	GUI::DrawText(p.getCharacterName(), Vec2f(bottomright.x - 600, topleft.y), SColor(0xffb200ff));
        	GUI::DrawText("Notable", topleft + Vec2f(220, 0), SColor(0xffb200ff));
   		}
   		else if (p.getUsername()=="xxxTentacion") { 																			  //Patreon supporter ... yup :droplet:
        	GUI::DrawText(p.getUsername(), topleft + Vec2f(20, 0), SColor(0xffb200ff));
        	GUI::DrawText(p.getCharacterName(), Vec2f(bottomright.x - 600, topleft.y), SColor(0xffb200ff));
        	GUI::DrawText("Patreon", topleft + Vec2f(220, 0), SColor(0xffb200ff));
   		}
        else
        {
            GUI::DrawText(p.getUsername(), topleft + Vec2f(20, 0), SColor(0xffd7a376));
            GUI::DrawText(p.getCharacterName(), Vec2f(bottomright.x - 600, topleft.y), SColor(0xffd7a376));
        }
   		
        GUI::DrawText("" + ping_in_ms, Vec2f(bottomright.x - 200, topleft.y), SColor(0xffffffff));

        GUI::DrawText("" + p.getCoins(), Vec2f(bottomright.x - 400, topleft.y), SColor(0xffffffff));

        //GUI::DrawText("" + p.getKills(), Vec2f(bottomright.x - 260, topleft.y), SColor(0xffffffff));
    }
}