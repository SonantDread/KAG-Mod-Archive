#include "RulesCore.as";

// Todo: less hacky pls
int SpawnListSize = 5;

void onInit(CRules@ this)
{
    this.set_u8("Item_CurrentNum", 0);
    this.set_bool("canSwitchTeams", false);
    this.set_bool("winCounterEnabled", false);
    // Todo: iterate through all teams instead of doing this manually
    this.set_u32("team_0_win_score",0);
    this.set_u32("team_1_win_score",0);

    this.addCommandID("admin-team");
    this.addCommandID("admin-setting");
    this.addCommandID("admin-add-menu");
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
    if (isServer())
    {
        this.SyncToPlayer("canSwitchTeams", player);
        this.SyncToPlayer("winCounterEnabled", player);
        this.SyncToPlayer("team_0_win_score", player);
        this.SyncToPlayer("team_1_win_score", player);

        if (player.isMod())
        {
            CBitStream stream;
            stream.write_u8(this.get_u8("Item_CurrentNum"));
            this.SendCommand(this.getCommandID("admin-add-menu"), stream, player);
        }
    }
}

void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
    if (cmd == this.getCommandID("admin-team"))
    {
        CPlayer@ player = getPlayerByNetworkId(params.read_u16());
        int teamNum = params.read_s32();

        if (player is null || (isServer() && !isPlayerAdmin(params.read_u16())))
            return;

        if (isServer())
        {
            RulesCore@ core;
            this.get("core", @core);

            if (core !is null)
            	 core.ChangePlayerTeam(player, teamNum);

        }
    }
    else if (cmd == this.getCommandID("admin-setting"))
    {
        u8 setting = params.read_u8();

        // Can cause desync! Player is always not an admin on clients
        if (isServer() && !isPlayerAdmin(params.read_u16()))
            return;

        switch(setting)
        {
            case 0:
                if (this.add_u8("Item_CurrentNum", 1) > SpawnListSize)
                    this.set_u8("Item_CurrentNum", 0);
                break;

            case 1:
                this.set_bool("canSwitchTeams", !this.get_bool("canSwitchTeams"));
                break;

            case 2:
                this.set_bool("winCounterEnabled", !this.get_bool("winCounterEnabled"));
                this.set_u32("team_0_win_score", 0);
                this.set_u32("team_1_win_score", 0);
                break;
        }

    }
    else if (cmd == this.getCommandID("admin-add-menu"))
    {
        // TODO: Some sort of key (unique to each player) so exploiter's cant add menu on their own
        if (isClient())
        {
            this.set_u8("Item_CurrentNum", params.read_u8());
            this.AddScript("AdminUI.as");
        }
    }
}


bool isPlayerAdmin(u16 networkId)
{
    CPlayer@ player = getPlayerByNetworkId(networkId);

    if (player is null)
    {
        warn("Player with id " + networkId + " does not exist!");
        return false;
    }

    if (!player.isMod())
    {
        warn("Player " + player.getUsername() + " is not an admin, but has tried to execute an admin command!");
        return false;
    }

    return true;
}
