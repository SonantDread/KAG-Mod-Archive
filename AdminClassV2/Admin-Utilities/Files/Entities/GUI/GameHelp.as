#define CLIENT_ONLY
#include "ActorHUDStartPos.as"
#include "TeamColour.as"
#include "GUI.as";


bool showHelp = true;
bool previous_showHelp = true;
bool justJoined = true;
bool page1 = true;
const int slotsSize = 6;
f32 boxMargin = 50.0f;
//key names
const string party_key = getControls().getActionKeyKeyName( AK_PARTY );
const string inv_key = getControls().getActionKeyKeyName( AK_INVENTORY );
const string pick_key = getControls().getActionKeyKeyName( AK_PICKUP );
const string taunts_key = getControls().getActionKeyKeyName( AK_TAUNTS );
const string use_key = getControls().getActionKeyKeyName( AK_USE );
const string action1_key = getControls().getActionKeyKeyName( AK_ACTION1 );
const string action2_key = getControls().getActionKeyKeyName( AK_ACTION2 );
const string action3_key = getControls().getActionKeyKeyName( AK_ACTION3 );
const string map_key = getControls().getActionKeyKeyName( AK_MAP );
const string zoomIn_key = getControls().getActionKeyKeyName( AK_ZOOMIN );
const string zoomOut_key = getControls().getActionKeyKeyName( AK_ZOOMOUT );

const string lastChangesInfo = "-DISCORD OF Z'PLACE :\n\n"
								"(https://discord.gg/TVc9fky\n\n"+
								"(Press N for get link easily)\n\n\n"
							   "-DASHBOARD OF Z'PLACE :\n\n" 
							   "https://trello.com/b/AR1Z1ins/zplace-development";

const string textInfo = 
		/*"# RULES :\n\n\n" +
		"- THERE IS NO RULES\n\n"+
		"- THERE IS NO BLACKLIST\n\n"+*/
		
		" - Destroying an structure made by players (Griefing) is not tolerated\n\n"+
		" - Spamming commands (Like making lag on server) is not tolerated.\n\n"+
		" - Preventing a person from reappearing is not tolerated\n\n"+
		" ** [By closing this page, you accept the rules. No one is supposed to ignore the rules] **\n\n"+
		"\n# Basic Gameplay:\n\n\n" +
		"This server aims to be a very varied sandbox.\n\n You can build, kill people or going to war if both parties agree. Z'place works with \n\n commands, here are the basic commands :\n\n"+
		"- !wood\n\n"+
		"- !stone\n\n"+
		"- !gold\n\n"+
		"- !allmats\n\n\n"+
		"Fed up to use pickaxe for destroying blocks ? Use keyboard editor :\n\n"+
		"- Z : Place blocks.\n\n"+
		"- X : Destroy blocks (Try on bedrock !).\n\n"+
		"- N : Discord Link.\n\n";

const string eventInfo = "#NEWS : \n\n\n\n"+
"- Update all gun weapon .\n\n"+
"- Polymer and Electronic can be craftable on Tech Factories \n\n"+
"- Add old ambiance underground (Kag classic).\n\n"+
"- Reduce cost of different sentry.\n\n"+
"- Add Texture pack of Christmas.\n\n\n"+

"#EVENT : \n\n\n"
" Merry Christmas Everyone !\n\n"+
"Build, Fight or Kill. But above all, have a good time on the server!\n\n"+
"After the incessant attacks of the zombies, the arrival of winter reduced their appearances.\n\n\n";

/*"What is ANARCHY WEEK ?\n\n\n\n"+
"Anarchy Week is a period of complete withdrawal from the rules and blacklisting.\n\n"+
"That is, from a certain time of the month, anyone on the server can do whatever they \n\n want without any restrictions.\n\n\n"+
"Remember, there is NO RESTRICTION. So revenge can quickly come.\n\n"+
"Have a good game and above all good luck to all!";*/


const Vec2f windowDimensions = Vec2f(600,600); //temp

//----KGUI ELEMENTS----\\
	Window@ helpWindow;
	Label@ introText;
	Label@ infoText;
	Label@ eventText;
	Label@ helpText;
	Label@ changeText;
	Label@ particleText;
    Label@ itemDistanceText;
    Label@ hoverDistanceText;
	Button@ changeBtn;
	Button@ infoBtn;
	Button@ introBtn;
	Button@ optionsBtn;
	Button@ startCloseBtn;
	Button@ eventBtn;
    Button@ togglemenuBtn;
    Button@ toggleHotkeyEmotesBtn;
	Rectangle@ optionsFrame;
	Icon@ helpIcon;
	ScrollBar@ particleCount;
    ScrollBar@ itemDistance;
    ScrollBar@ hoverDistance;

bool isGUINull()
{
	if ( helpWindow is null
		|| introText is null
		|| infoText is null
		|| eventText is null
		|| helpText is null
		|| changeText is null
		|| particleText is null
        || itemDistanceText is null
        || hoverDistanceText is null
		|| changeBtn is null
		|| infoBtn is null
		|| introBtn is null
		|| optionsBtn is null
        || togglemenuBtn is null
        || toggleHotkeyEmotesBtn is null
		|| startCloseBtn is null
		|| eventBtn is null
		|| optionsFrame is null
		|| helpIcon is null
		|| particleCount is null
        || itemDistance is null
        || hoverDistance is null )
	{
		return true;
	}
	
	return false;
}
	
void onInit( CRules@ this )
{
	this.set_bool("GUI initialized", false);

	this.addCommandID("join");
	//this.addCommandID("updateBAchieve");
	
	u_showtutorial = true;// for ShowTipOnDeath to work


	string configstr = "../Cache/zp_ST.cfg";
	ConfigFile cfg = ConfigFile( configstr );
	if (!cfg.exists("Version"))
	{
		cfg.add_string("Version","KGUI 2.3");
		cfg.saveFile("zp_ST.cfg");
	}
}

void ButtonClickHandler(int x , int y , int button, IGUIItem@ sender){ //Button click handler for KGUI
	if(sender is changeBtn){
		changeText.isEnabled = true;
		infoText.isEnabled = false;
		introText.isEnabled = false;
		helpIcon.isEnabled = false;
		optionsFrame.isEnabled = false;
		eventText.isEnabled = false;
	}
	if(sender is infoBtn){
		changeText.isEnabled = false;
		infoText.isEnabled = true;
		introText.isEnabled = false;
		helpIcon.isEnabled = false;
		optionsFrame.isEnabled = false;
		eventText.isEnabled = false;
	}
	if(sender is introBtn){
		changeText.isEnabled = false;
		infoText.isEnabled = false;
		introText.isEnabled = true;
		helpIcon.isEnabled = true;
		optionsFrame.isEnabled = false;
		eventText.isEnabled = false;
	}
	if(sender is optionsBtn){
		changeText.isEnabled = false;
		infoText.isEnabled = false;
		introText.isEnabled = false;
		helpIcon.isEnabled = false;
		optionsFrame.isEnabled = true;
		eventText.isEnabled = false;
	}

	if(sender is eventBtn){
		changeText.isEnabled = false;
		infoText.isEnabled = false;
		introText.isEnabled = false;
		helpIcon.isEnabled = false;
		optionsFrame.isEnabled = false;
		eventText.isEnabled = true;
	}

    if(sender is togglemenuBtn){
        showHelp = !showHelp;
    }


	if (sender is startCloseBtn){
		startCloseBtn.toggled = !startCloseBtn.toggled;
		startCloseBtn.desc = (startCloseBtn.toggled) ? "Start Help Closed Enabled" : "Start Help Closed Disabled";
		startCloseBtn.saveBool("Start Closed",!startCloseBtn.toggled,"Z'place");
	}
  

    if (sender is toggleHotkeyEmotesBtn)
    {
        toggleHotkeyEmotesBtn.toggled = !toggleHotkeyEmotesBtn.toggled;
		toggleHotkeyEmotesBtn.desc = (toggleHotkeyEmotesBtn.toggled) ? "Hotkey Emotes Enabled" : "Hotkey Emotes Disabled";
		toggleHotkeyEmotesBtn.saveBool("Hotkey Emotes", toggleHotkeyEmotesBtn.toggled,"Z'place");
        
        getRules().set_bool("hotkey_emotes", toggleHotkeyEmotesBtn.toggled);
    }
}

void SliderClickHandler(int dType ,Vec2f mPos, IGUIItem@ sender){
	//if (sender is test){test.slide();}
}

void onTick( CRules@ this )
{
	bool initialized = this.get_bool("GUI initialized");
	if ( !initialized || isGUINull() )		//this little trick is so that the GUI shows up on local host 
	{
        ConfigFile cfg;
        
        u16 itemDistance_value = 6;

        u16 hoverDistance_value = 6;

        if(cfg.loadFile("../Cache/Z'place_setting.cfg"))//Load file, if file exists
        {
            print("options loaded");
            if(cfg.exists("item_distance"))//Value already set?
            {
                print("default set");
                itemDistance_value = cfg.read_u8("item_distance");//Set default
                print(""+itemDistance_value);
            }
            if(cfg.exists("hover_distance"))//Value already set?
            {
                hoverDistance_value = cfg.read_u8("hover_distance");//Set default
            }
        }





		CFileImage@ image = CFileImage( "ZPoster.png" );
		Vec2f imageSize = Vec2f( image.getWidth(), image.getHeight() );
		AddIconToken( "$HELP$", "ZPoster.png", imageSize, 0 );
	
		//---KGUI setup---\\
		@helpIcon = @Icon("ZPoster.png",Vec2f(40,40),imageSize,0,1.0f);
		@helpWindow = @Window(Vec2f(400,180),Vec2f(800,530)); //(200,-530),Vec2f(800,530));
		helpWindow.name = "Help Window";

		@infoText  = @Label(Vec2f(20,40),Vec2f(780,34),"",SColor(255,0,0,0),false);
		infoText.setText(infoText.textWrap(textInfo));
		@infoBtn = @Button(Vec2f(210,495),Vec2f(100,30),"Rules & Tips",SColor(255,255,255,255));
		infoBtn.addClickListener(ButtonClickHandler);

		@changeText  = @Label(Vec2f(20,40),Vec2f(780,34),"",SColor(255,0,0,0),false);
		changeText.setText(changeText.textWrap(lastChangesInfo));
		@changeBtn = @Button(Vec2f(450,495),Vec2f(100,30),"Website",SColor(255,255,255,255));
		changeBtn.addClickListener(ButtonClickHandler);

		@introText  = @Label(Vec2f(20,10),Vec2f(780,15),"",SColor(255,0,0,0),false);
		introText.setText(introText.textWrap("Howdy ho ! Welcom to Z'place."));
		@introBtn = @Button(Vec2f(90,495),Vec2f(100,30),"Z'place Page",SColor(255,255,255,255));
		introBtn.addClickListener(ButtonClickHandler);

		@helpText  = @Label(Vec2f(6,10),Vec2f(100,34),"",SColor(255,0,0,0),false);
		helpText.setText(helpText.textWrap(lastChangesInfo));

		@optionsBtn = @Button(Vec2f(575,495),Vec2f(120,30),"Options",SColor(255,255,255,255));
		optionsBtn.addClickListener(ButtonClickHandler);
		
		@startCloseBtn = @Button(Vec2f(10,50),Vec2f(200,30),"",SColor(255,255,255,255));
		startCloseBtn.addClickListener(ButtonClickHandler);

		@eventText  = @Label(Vec2f(20,40),Vec2f(780,34),"",SColor(255,0,0,0),false);
		eventText.setText(eventText.textWrap(eventInfo));
		@eventBtn = @Button(Vec2f(330,495),Vec2f(100,30),"News & Event",SColor(255,255,255,255));
		eventBtn.addClickListener(ButtonClickHandler);

        @toggleHotkeyEmotesBtn = @Button(Vec2f(10,250),Vec2f(200,30),"",SColor(255,255,255,255));
		toggleHotkeyEmotesBtn.addClickListener(ButtonClickHandler);

        @togglemenuBtn = @Button(Vec2f(702,06),Vec2f(90,30),"Exit Menu",SColor(255,255,255,255));//How do close menu? durp. The pain i have gone through has warrented this.
		togglemenuBtn.addClickListener(ButtonClickHandler);

		@optionsFrame = @Rectangle(Vec2f(20,10),Vec2f(760,490), SColor(0,0,0,0));

        @particleCount = @ScrollBar(Vec2f(10,105),80,4,true,2);
		@particleText = @Label(Vec2f(10,90),Vec2f(100,10),"Particle counts:",SColor(255,0,0,0),false);
		particleCount.addSlideEventListener(SliderClickHandler);

		@itemDistance = @ScrollBar(Vec2f(10,350),160,10,true, itemDistance_value);
		@itemDistanceText = @Label(Vec2f(10,330),Vec2f(100,10),"Item distance:",SColor(255,0,0,0),false);
		itemDistance.addSlideEventListener(SliderClickHandler);

        @hoverDistance = @ScrollBar(Vec2f(10,400),160,10,true, hoverDistance_value);
		@hoverDistanceText = @Label(Vec2f(10,380),Vec2f(100,10),"Hover distance:",SColor(255,0,0,0),false);
		hoverDistance.addSlideEventListener(SliderClickHandler);

		//---KGUI Parenting---\\
		helpWindow.addChild(introText);
		helpWindow.addChild(helpIcon);
		helpWindow.addChild(infoText);
		helpWindow.addChild(eventText);
		helpWindow.addChild(changeText);
		helpWindow.addChild(introBtn);
		helpWindow.addChild(infoBtn);
		helpWindow.addChild(changeBtn);
		helpWindow.addChild(optionsBtn);
		helpWindow.addChild(optionsFrame);
		helpWindow.addChild(eventBtn);
        helpWindow.addChild(togglemenuBtn);
		optionsFrame.addChild(startCloseBtn);
        optionsFrame.addChild(toggleHotkeyEmotesBtn);
		optionsFrame.addChild(particleCount);
		optionsFrame.addChild(particleText);
        
        optionsFrame.addChild(itemDistance);
		optionsFrame.addChild(itemDistanceText);
        optionsFrame.addChild(hoverDistance);
		optionsFrame.addChild(hoverDistanceText);
		showHelp = startCloseBtn.getBool("Start Closed","Z'place");
		startCloseBtn.toggled = !startCloseBtn.getBool("Start Closed","Z'place");
		startCloseBtn.desc = (startCloseBtn.toggled) ? "Start Help Closed Enabled" : "Start Help Closed Disabled";
        

        toggleHotkeyEmotesBtn.toggled = toggleHotkeyEmotesBtn.getBool("Hotkey Emotes","Z'place");
		toggleHotkeyEmotesBtn.desc = (toggleHotkeyEmotesBtn.toggled) ? "Hotkey Emotes Enabled" : "Hotkey Emotes Disabled";
        this.set_bool("hotkey_emotes", toggleHotkeyEmotesBtn.toggled);


		optionsFrame.isEnabled = false;
		changeText.isEnabled = false;
		infoText.isEnabled = false;
		eventText.isEnabled = false;



       updateOptionSliderValues();//Takes slider values and sets other settings
		
		this.set_bool("GUI initialized", true);
		print("GUI has been initialized");
	}

	CControls@ controls = getControls();
	if ( controls.isKeyJustPressed( KEY_F1 ) )
	{
		showHelp = !showHelp;
	}


    if(previous_showHelp != showHelp)//Menu just closed or opened
    {
        if(previous_showHelp)//Menu closed
        {
            ConfigFile cfg;
            cfg.loadFile("../Cache/Z'place_setting.cfg");

            cfg.add_u16("item_distance", itemDistance.value);
            cfg.add_u16("hover_distance", hoverDistance.value);

            cfg.saveFile("Z'place_setting.cfg");
        }
    }

    if(showHelp)//Only do if the help menu is open
    {
        updateOptionSliderValues();
    }


    bool previous_showHelp = showHelp;//Must be last
}

void updateOptionSliderValues()
{
    float item_distance = 0.3f;//used for changing the value and storing the final value
    for(uint i = 0; i < itemDistance.value; i++)
    {
        item_distance += 0.1f;
    }
   
}

void onCommand( CRules@ this, u8 cmd, CBitStream @params )
{
	
}

//a work in progress
void onRender( CRules@ this )
{
	CPlayer@ player = getLocalPlayer();
	if ( player is null )
		return;

	
	string temp = "Particle count: ";
	if (particleCount.value == 0){
		temp += "None";
	}else if (particleCount.value == 1){
		temp += "Low";
	}else if (particleCount.value == 2){
		temp += "Medium";
	} else{
		temp += "High";
	}
	particleText.setText(temp);


	int minHelpYPos = -530;
	int maxHelpYPos = 48;
	int scrollSpeed = 40;
	
	if ( helpWindow.position.y != minHelpYPos )
		helpWindow.draw();
	
	if (showHelp && helpWindow.position.y < maxHelpYPos) //controls opening and closing the gui
	{
		helpWindow.position = Vec2f( helpWindow.position.x,  Maths::Min(helpWindow.position.y + scrollSpeed, maxHelpYPos) );
	}
	if (!showHelp && helpWindow.position.y > minHelpYPos)
	{
		helpWindow.position = Vec2f( helpWindow.position.x, Maths::Max( helpWindow.position.y - scrollSpeed, minHelpYPos) );
	}

	CBlob@ localBlob = getLocalPlayerBlob();
	CControls@ controls = getControls();
	
}