// Admin UI by Vamist, with big thanks to KGui
//
// NOTE: This uses a custom KGUI.as file:
// Fixes:
//   - Dragging children of a window now works
//   - Null fixes
// Changes:
//   - Changed DrawWindow to DrawFramedPane
//   - DrawRulesFont changed to DrawText

#define CLIENT_ONLY

#include "KGui.as"

namespace Admin
{
    enum AdminMenu
    {
        NotOpened = 0, // Show icon
        Options,   // Show all the options
        Settings,  // Show game rule settings
        Counter,   // Show counter settings
        TeamPicker // Show team picker menu
    }
}

Admin::AdminMenu CurrentScreen;

//// Core Windows:
Icon NotOpened;
Window Options;
Window Settings;
Window Team;

//// Variables:
const SColor Options_NoHoveredColor = SColor(255, 200, 200, 200);
const SColor Options_HoverColor = SColor(255, 255, 255, 255);

/// Options Menu:
const string Options_Header_Main = "   !gold!Beheerder menu v1\n!grey! ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯";
const string Options_Header_Egg =  "   !white!Made by !gold!Vamist !white!;)\n!grey! ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯";

const string Server_Text = "Server settings";
const string Team_Text = "Team picker";
const string Counter_Text = "Counter settings";


/// Settings:
const string Settings_Header = "     !gold!Global Server Settings\n!grey! ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯";

// TODO: Have a synced list with TDM.as
const string[] SpawnItem_List = {
    "bomb",
    "waterbomb",
    "mine",
    "keg",
    "chicken",
    "nothing"
};

// Used to know what num we are in the list (hacky but good enough for now)
u8 SpawnItem_CurrentNum = 0;

/// TeamSwitch:
// Used to store the start pos for when we start to drag text
Vec2f Text_StartLocalPos;


void onInit(CRules@ this)
{
    AddColorToken("!gold!", SColor(255, 255, 215, 0));
    AddColorToken("!white!", SColor(255, 255, 255, 255));
    AddColorToken("!grey!", SColor(255, 100, 100, 100));
    AddColorToken("!red!", SColor(255, 192, 36, 36));
    AddColorToken("!blu!", SColor(255, 0, 128, 255));

    AddIconToken("$ArrowLeft$", "ArrowLeft.png", Vec2f(8,8), 0);
    AddIconToken("$ArrowRight$", "ArrowRight.png", Vec2f(8,8), 0);
    GUI::LoadFont("uni", CFileMatcher("uni0553.ttf").getFirst(), 16, true);

    onReload(this);
}


// Hack to redraw the current team picker menu
void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
    if (CurrentScreen == Admin::TeamPicker)
        UpdateTeamPicker();
}

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
    if (CurrentScreen == Admin::TeamPicker)
        UpdateTeamPicker();
}

void onPlayerChangedTeam(CRules@ this, CPlayer@ player, u8 oldteam, u8 newteam)
{
    if (CurrentScreen == Admin::TeamPicker)
        UpdateTeamPicker();
}

// Hack to redraw the settings menu to sync it up
void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
    if (cmd == this.getCommandID("admin-setting"))
    {
        RedrawSettings();
    }
}


void onReload(CRules@ this)
{
    // Set the current screen to be closed
    CurrentScreen = Admin::NotOpened;

#ifdef STAGING
    warn("Staging build has not been tested with AdminUI, you may experience weird errors!");
    warn("Example: Screen resizing is currently not supported!");
#endif

    /// Common vars
    Driver@ driver = getDriver();
    int screenWidth = driver.getScreenWidth();
    int screenHeight = driver.getScreenHeight();

    /// Not opened:
    {
        NotOpened = Icon(
            Vec2f(screenWidth - 16, (screenHeight / 2)),
            Vec2f(20, 20),
            "$ArrowLeft$"
        );

        NotOpened.addClickListener(NotOpened_onClick);
    }


    /// Options:
    {
        Options = Window(
            Vec2f(screenWidth - 194, (screenHeight / 2) - 100 ),
            Vec2f(200, 200)
        );

        Label header = Label(
            Vec2f(0, 0),
            Vec2f(200, 40),
            Options_Header_Main,
            color_white,
            false
        );

        Icon goBack = Icon(
            Vec2f(180, 100),
            Vec2f(20, 20),
            "$ArrowRight$"
        );

        Label serverSettings = Label(
            Vec2f(10, 50),
            Vec2f(200, 25),
            "- " + Server_Text,
            Options_NoHoveredColor,
            false
        );

        Label teamSwitch = Label(
            Vec2f(10, 80),
            Vec2f(200, 25),
            "- " + Team_Text,
            Options_NoHoveredColor,
            false
        );


        serverSettings.addHoverStateListener(LabelColor_onHover);
        teamSwitch.addHoverStateListener(LabelColor_onHover);

        serverSettings.addClickListener(ServerSettings_onClick);
        teamSwitch.addClickListener(TeamPicker_onClick);
        header.addClickListener(Header_EasterEgg);
        goBack.addClickListener(GoBack_onClick);

        Options.addChild(serverSettings);
        Options.addChild(teamSwitch);
        Options.addChild(header);
        Options.addChild(goBack);
    }

    /// Settings:
    RedrawSettings();

}

// We render different menu's based on what one we currently got active
void onRender(CRules@ this)
{
    switch (CurrentScreen)
    {
        case Admin::TeamPicker:
            GUI::SetFont("uni");
            Team.draw();
            break;

        case Admin::Options:
            GUI::SetFont("uni");
            Options.draw();
            break;

        case Admin::Settings:
            GUI::SetFont("uni");
            Settings.draw();
            break;

        case Admin::NotOpened:
        default:
            NotOpened.draw();
            break;
    }
}


/// Custom funcs

// Draw an up to date team picker (this will require a user to refresh if somebody new joins, but that's fine for v1)
void UpdateTeamPicker()
{
    Driver@ driver = getDriver();
    int screenWidth = driver.getScreenWidth();
    int screenHeight = driver.getScreenHeight();

    Team.clearChildren();

    Team = Window(
        Vec2f(screenWidth - 244, (screenHeight / 2) - 100 ),
        Vec2f(250, 200)
    );

    Icon goBack = Icon(
        Vec2f(230, 100),
        Vec2f(20, 20),
        "$ArrowRight$"
    );

    Label teamText = Label(
        Vec2f(0,0),
        Vec2f(250, 20),
        "    !blu!Blu!blu!         !grey!Spec!grey!       !red!Red!red!",
        color_white,
        false
    );

    Line left = Line(
        Vec2f(85,5),
        Vec2f(0,190),
        color_black
    );

    Line right = Line(
        Vec2f(169,5),
        Vec2f(0,190),
        color_black
    );

    Team.addChild(left);
    Team.addChild(right);

    int yPos = 0;
    for (int a = 0; a < getPlayerCount(); a++)
    {
        CPlayer@ player = getPlayer(a);

        if (player is null)
            continue;

        int xPos = 0;
        yPos += 20;

        switch (player.getTeamNum())
        {
            case 0:
                xPos = 8;
                break;

            case 1:
                xPos = 173;
                break;

            default:
                xPos = 90;
                break;
        }

        // Encode player's network id (u16) into two u8's
        // I do this so I dont need to write a custom class to store it separately
        // To do this, we use bitwise operators
        u16 id = player.getNetworkID();

        u8 red = (id >> 8) & 0xff;
        u8 green = id & 0xff;

        Label user = Label(
            Vec2f(xPos, yPos),
            Vec2f(90, 19),
            "!white!"+player.getUsername().substr(0, 7),
            SColor(255, red, green, 255),
            false
        );

        user.isDragable = true;

        user.addDragEventListener(userDrag);

        Team.addChild(user);
    }

    // Extend UI when we get a lot of players,
    // could be done better but for v1 its good enough
    if (yPos > 150)
    {
        yPos -= 150;

        Vec2f size = Team.size;
        Team.size = Vec2f(size.x, size.y + yPos);

        size = left.size;
        left.size = Vec2f(size.x, size.y + yPos);
        right.size = left.size;
    }

    Team.addChild(goBack);
    Team.addChild(teamText);

    goBack.addClickListener(GoBack_onClick);
}

void RedrawSettings()
{
    Driver@ driver = getDriver();
    int screenWidth = driver.getScreenWidth();
    int screenHeight = driver.getScreenHeight();

    SpawnItem_CurrentNum = getRules().get_u8("Item_CurrentNum");

    Settings = Window(
        Vec2f(screenWidth - 244, (screenHeight / 2) - 100 ),
        Vec2f(250, 200)
    );

    Icon goBack = Icon(
        Vec2f(230, 100),
        Vec2f(20, 20),
        "$ArrowRight$"
    );

    Label header = Label(
        Vec2f(0, 0),
        Vec2f(250, 25),
        Settings_Header,
        color_white,
        false
    );

    Label spawnItem = Label(
        Vec2f(10, 40),
        Vec2f(250, 19),
        "Spawn with: " + SpawnItem_List[SpawnItem_CurrentNum],
        Options_NoHoveredColor,
        false
    );


    Label manualSwitch = Label(
        Vec2f(10, 60),
        Vec2f(250, 19),
        "Allow team switch: " + getRules().get_bool("canSwitchTeams"),
        Options_NoHoveredColor,
        false
    );

    Label enableCounter = Label(
        Vec2f(10, 80),
        Vec2f(250, 19),
        "Enable win counter: " + getRules().get_bool("winCounterEnabled"),
        Options_NoHoveredColor,
        false
    );

    enableCounter.addHoverStateListener(LabelColor_onHover);
    enableCounter.addClickListener(EnableCounter_onClick);
    manualSwitch.addHoverStateListener(LabelColor_onHover);
    manualSwitch.addClickListener(ManualSwitch_onClick);
    spawnItem.addHoverStateListener(LabelColor_onHover);
    spawnItem.addClickListener(SpawnItem_onClick);
    goBack.addClickListener(GoBack_onClick);

    Settings.addChild(header);
    Settings.addChild(spawnItem);
    Settings.addChild(manualSwitch);
    Settings.addChild(goBack);
    Settings.addChild(enableCounter);
}

void userDrag(int type, Vec2f pos, IGUIItem@ source)
{
    Label@ label = cast<Label@>(source);
    switch(type)
    {

        // When user starts dragging
        case 0:
            Text_StartLocalPos = label.localPosition;
        break;

        // When user is dragging
        // case 1:
        // break;

        // When user stops dragging
        case 2:
        {
            Vec2f newPos = Vec2f(label.localPosition.x, Text_StartLocalPos.y);
            Vec2f mousePosToLocal = newPos + (pos - label.position);

            SColor col = label.color;

            // Decode and get the ID back from SColor
            int id = (col.getRed() & 0xff) << 8;
            id += col.getGreen() & 0xff;

            if (mousePosToLocal.x < 75)
            {
                newPos.x = 8;
                SwitchTeam(id, 0);
            }
            else if (mousePosToLocal.x < 169)
            {
                newPos.x = 90;
                SwitchTeam(id, getRules().getSpectatorTeamNum());
            }
            else
            {
                newPos.x = 173;
                SwitchTeam(id, 1);
            }

            label.localPosition = newPos;
        }
        break;
    }
}

void SwitchTeam(u16 playerID, int teamNum)
{
    CPlayer@ player = getPlayerByNetworkId(playerID);
    if (player is null)
    {
        // Player no longer in game, so lets force update our menu
        warn("Player placed is null! Rebuilding UI");
        UpdateTeamPicker();
        return;
    }

    CBitStream stream;
    stream.write_u16(playerID);
    stream.write_s32(teamNum);
    stream.write_u16(getLocalPlayer().getNetworkID());

    CRules@ rules = getRules();
    rules.SendCommand(rules.getCommandID("admin-team"), stream);

}


/// CALLBACKS:

// Back icon
void GoBack_onClick(int x, int y, int button, IGUIItem@ source)
{
    switch (CurrentScreen)
    {
        case Admin::TeamPicker:
        case Admin::Settings:
            CurrentScreen = Admin::Options;
            break;

        case Admin::Options:
            CurrentScreen = Admin::NotOpened;
            getRules().set_bool("AdminMenuOpened",false);
            break;
    }
}

// Used to highlight selected text
// Warning: You need to change the text or the colour will never change #blameirrlicht
void LabelColor_onHover(bool isHovered, IGUIItem@ source)
{
    // Cast this back into a label (since it inherits from IGuitItem)
    Label@ label = cast<Label@>(source);

    if (isHovered)
    {
        label.color = Options_HoverColor;

        // if it contains -, replace it with -- or add space to the end
        if (label.label.substr(0, 1) == "-")
            label.label = label.label.replace("-", "--");
        else
            label.label = label.label + " ";
    }
    else
    {
        label.color = Options_NoHoveredColor;

        // if it contains --, convert it to -, otherwise remove space at the end
        if (label.label.substr(0, 1) == "-")
            label.label = label.label.replace("--", "-");
        else
            label.label = label.label.substr(0, label.label.size() - 1);
    }
}



// Not Opened:
void NotOpened_onClick(int x, int y, int button, IGUIItem@ source)
{
    CurrentScreen = Admin::Options;
    getRules().set_bool("AdminMenuOpened",true);
}

// Options:
void ServerSettings_onClick(int x, int y, int button, IGUIItem@ source)
{
    CurrentScreen = Admin::Settings;
}

void TeamPicker_onClick(int x, int y, int button, IGUIItem@ source)
{
    CurrentScreen = Admin::TeamPicker;

    // Redraw team picker (because we might have new players)
    UpdateTeamPicker();
}

void Header_EasterEgg(int x, int y, int button, IGUIItem@ source)
{
    Label@ label = cast<Label@>(source);

    // color is just a hack to tell what text we are on
    // without having to compare text
    if (label.color ==  color_white)
    {
        label.label = Options_Header_Egg;
        label.color = color_black;
    }
    else
    {
        label.label = Options_Header_Main;
        label.color = color_white;
    }
}


/// Settings:
void SpawnItem_onClick(int x, int y, int button, IGUIItem@ source)
{
    SendAdminSettingButton(0);
}


void ManualSwitch_onClick(int x, int y, int button, IGUIItem@ source)
{
    SendAdminSettingButton(1);
}


void EnableCounter_onClick(int x, int y, int button, IGUIItem@ source)
{
    SendAdminSettingButton(2);
}


void SendAdminSettingButton(u8 id)
{
    CRules@ rules = getRules();

    CBitStream params;
    params.write_u8(id);
    params.write_u16(getLocalPlayer().getNetworkID());

    rules.SendCommand(rules.getCommandID("admin-setting"), params);
}
