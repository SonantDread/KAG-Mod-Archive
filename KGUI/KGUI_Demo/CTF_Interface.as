#include "CTF_Structs.as";
#include "KGUI.as";
/*
void onTick( CRules@ this )
{
    //see the logic script for this
}
*/
Window@ demoWindow;
Label@ displayLbl;
Button@ hiBtn;
Button@ byeBtn;
Rectangle@ hiddenBtn;

void onInit( CRules@ this )
{
    CBitStream stream;
    stream.write_u16(0xDEAD); //check bits rewritten when theres something useful
    this.set_CBitStream("ctf_serialised_team_hud", stream);

    //KGUI Stuff
    //Windows
    @demoWindow = @Window("Demo Window",Vec2f(30,30),Vec2f(100,90));
    demoWindow.loadPos("Demo",222.0f,251.0f);
    demoWindow.addDragEventListener(DemoDragEvent);
    demoWindow.isDragable = true;

    //Images
    Icon@ KGUIa = @Icon("animationtest.png",Vec2f(34,16),3,Vec2f(102, 30),Vec2f(100,32),"KGUI Animation",1.0f);
    KGUIa.addFrame(0,16);
    KGUIa.setToolTip("This is an animated GUI item", 5, SColor(255,255,255,255));

    //Buttons
    @hiBtn = @Button(Vec2f(2,65),Vec2f(42,20),"Hello",SColor(255,255,255,255));
    hiBtn.addClickListener(ButtonClickHandler);

    @byeBtn = @Button(Vec2f(46,65),Vec2f(42,20),"Bye",SColor(255,255,255,255));
    byeBtn.addClickListener(ButtonClickHandler);

    @hiddenBtn = @Rectangle(Vec2f(0,-30),Vec2f(100,30),SColor(0,0,0,0));
    hiddenBtn.addClickListener(ButtonClickHandler);

    //Labels
    @displayLbl = @Label(Vec2f(2,2),Vec2f(92,36),"Hi! \nThis is KGUI!",SColor(255,0,0,0),true);
    displayLbl.setToolTip("Try clicking right above the window to close", 5, SColor(255,255,255,255));

    //Parenting -- Order matters, later children render ontop earlier ones when drawn 
            //though does allow for interesting effects with semi-transparent renderings ontop of others
    demoWindow.addChild(hiBtn);
    demoWindow.addChild(byeBtn);
    demoWindow.addChild(hiddenBtn);
    demoWindow.addChild(KGUIa);
    demoWindow.addChild(displayLbl);
}

void onRender( CRules@ this )
{

    if (demoWindow.isEnabled){demoWindow.draw();} //telling window to draw iteself

    CPlayer@ p = getLocalPlayer();

    if (p is null || !p.isMyPlayer()) { return; }

    CBitStream serialised_team_hud;
    this.get_CBitStream("ctf_serialised_team_hud", serialised_team_hud);

    if (serialised_team_hud.getBytesUsed() > 8)
    {
        serialised_team_hud.Reset();
        u16 check;

        if (serialised_team_hud.saferead_u16(check) && check == 0x5afe)
        {
            const string gui_image_fname = "Rules/CTF/CTFGui.png";

            while (!serialised_team_hud.isBufferEnd())
            {
                CTF_HUD hud(serialised_team_hud);
                Vec2f topLeft = Vec2f(8,8+64*hud.team_num);
                
                int step = 0;
                Vec2f startFlags = Vec2f(0,8);
                
                string pattern = hud.flag_pattern;
                string flag_char = "";
                int size = int(pattern.size());
                
                GUI::DrawRectangle( topLeft+Vec2f(4,4), topLeft+Vec2f(size*32+26, 60) );

                while (step < size)
                {
                    flag_char = pattern.substr(step,1);
                    
                    int frame = 0;
                    //c captured
                    if(flag_char == "c")
                    {
						frame = 2;
					}
					//m missing
					else if(flag_char == "m")
                    {
						frame = getGameTime() % 20 > 10 ? 1 : 2;
					}
					//f fine
					else if(flag_char == "f")
                    {
						frame = 0;
					}

                    GUI::DrawIcon(gui_image_fname, frame , Vec2f(16,24), topLeft+startFlags+Vec2f( 14 + step*32,0 ) , 1.0f, hud.team_num );
                    
                    step++;
                }
            }
        }

        serialised_team_hud.Reset();
    }

    string propname = "ctf spawn time "+p.getUsername();	
    if (p.getBlob() is null && this.exists(propname) )
    {
        u8 spawn = this.get_u8(propname);

        if (spawn != 255)
        {
            string spawn_message = "Respawn in: "+spawn;
            if(spawn >= 250)
            {
                spawn_message = "Respawn in: (approximately never)";
            }

            GUI::DrawText( spawn_message , Vec2f( getScreenWidth()/2 - 70, getScreenHeight()/3 + Maths::Sin(getGameTime() / 3.0f) * 5.0f ), SColor(255, 255, 255, 55) );
        }
    }
}

//GUI Clicking and Dragging handlers
void ButtonClickHandler(int x , int y , int button, IGUIItem@ sender){
    if (sender is hiBtn){
        displayLbl.setText("Hello there!");
    }
    if (sender is byeBtn){
        displayLbl.setText("Don't Leave!");
    }
    if (sender is hiddenBtn){
        demoWindow.isEnabled = false;
    }
}

void DemoDragEvent(int dType ,Vec2f mPos, IGUIItem@ sender){
    if (dType == 0) {}
    if (dType == 1) {}
    if (dType ==  DragFinished) {sender.savePos("Demo");}
}
