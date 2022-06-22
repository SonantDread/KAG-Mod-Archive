// Strings to translate:
// 	"Select a head"
// 	"Change head to vanilla"
// 	"Change Head"
string config_filename = "CHMSettings.cfg";
//These are set with config file
u8 MENU_HEIGHT, MENU_WIDTH;
u16 HEADS_COUNT;
string HEADS_FILENAME;

void ReadSettings()
{
	ConfigFile cfg = ConfigFile();
	cfg.loadFile(config_filename);
	MENU_HEIGHT = cfg.read_u8("menu_height");
	MENU_WIDTH = cfg.read_u8("menu_width");
	HEADS_COUNT = cfg.read_u16("heads_count");
	HEADS_FILENAME = cfg.read_string("heads_filename");
}

string getIconName(u16 head_num)
{
	return "$HEAD" + head_num + "$";
}
void onInit(CRules@ this)
{
	ReadSettings();
	this.addCommandID("set_head");
	this.addCommandID("set_vanilla_head");
	this.addCommandID("send_settings");
}

void ShowMenu()
{
	CPlayer@ player = getLocalPlayer();
	if (player !is null && player.isMyPlayer())
	{
		Menu::CloseAllMenus();
		getHUD().ClearMenus(true);
		CRules@ rules = getRules();
		Vec2f center = getDriver().getScreenCenterPos();
		//Create a menu for heads.
		string description1 = getTranslatedString("Select a head");
		string description2 = getTranslatedString("Change head to vanilla");
		CGridMenu@ heads_menu = CreateGridMenu(center, null, Vec2f(MENU_WIDTH, MENU_HEIGHT), description1);
		for (int i = 0; i < HEADS_COUNT; i++)
		{
			CBitStream params;
		    	params.write_u16(player.getNetworkID());
			params.write_u16(i);
			heads_menu.AddButton(getIconName(i), description1, rules.getCommandID("set_head"), Vec2f(1,1), params);
		}
		//Let's create a new menu to set a head to vanilla, so everything looks nice.
		Vec2f under_center = Vec2f(center.x, center.y + (MENU_HEIGHT * 45));
		CGridMenu@ menu = CreateGridMenu(under_center, null, Vec2f(2, 2), description2);
		CBitStream params;
		params.write_u16(player.getNetworkID());
		menu.AddButton("$red_cross$", description2, rules.getCommandID("set_vanilla_head"), Vec2f(2,2), params);
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
	//Sync settings with a client
	if (cmd == this.getCommandID("send_settings"))
	{
		MENU_HEIGHT = params.read_u8();
		MENU_WIDTH = params.read_u8();
		HEADS_COUNT = params.read_u16();
		HEADS_FILENAME = params.read_string();
		for (u16 i = 0; i < HEADS_COUNT; i++)
		{
			//Every first frame of the i-head (3 frames for one head)
			u16 frame_num = i * 4;
			AddIconToken(getIconName(i), HEADS_FILENAME, Vec2f(16,16), frame_num);
		}
		AddIconToken("$red_cross$", "MenuItems.png", Vec2f(32,32), 13);
	}
	else if (cmd == this.getCommandID("set_head"))
	{
		CPlayer@ p = getPlayerByNetworkId(params.read_u16());
		if (p !is null)
		{
			u16 index = params.read_u16();
			p.set_bool("is_custom_head_set", true);
			p.set_u16("custom_head_index", index);
			p.Sync("is_custom_head_set", true);
			p.Sync("custom_head_index", true);
		}
	}
	else if (cmd == this.getCommandID("set_vanilla_head"))
	{
		CPlayer@ p = getPlayerByNetworkId(params.read_u16());
		if (p !is null)
		{
			p.set_bool("is_custom_head_set", false);
			p.Sync("is_custom_head_set", true);
		}
	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	if (getNet().isServer())
	{
		//Sync settings with a client
		CBitStream params;
		params.write_u8(MENU_HEIGHT);
		params.write_u8(MENU_WIDTH);
		params.write_u16(HEADS_COUNT);
		params.write_string(HEADS_FILENAME);
		this.SendCommand(this.getCommandID("send_settings"), params, player);
		this.set_string("custom_heads_filename", HEADS_FILENAME);
		this.SyncToPlayer("custom_heads_filename", player);
	}
}

void onMainMenuCreated(CRules@ this, CContextMenu@ menu)
{
	//get our player first - if there isn't one, move on
	CPlayer@ me = getLocalPlayer();
	if (me is null) return;

	//and advance context menu when clicked
	Menu::addContextItem(menu, getTranslatedString("Change Head"), "CHM.as", "void ShowMenu()");
}
