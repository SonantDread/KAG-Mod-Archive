#include "Factions.as";
#include "RPGCommon.as";

#define SERVER_ONLY;

void onRestart( CRules@ this )
{
    this.server_setShowHoverNames(false);

    Factions _factions();
    this.set("factions", @_factions);

    RPGRespawns res(this);
    RPGCore core(this, res);
    this.set("core", @core);

    this.SetCurrentState(GAME);

    for(int i = 0; i < getPlayerCount(); i++)
    {
        CPlayer@ p = getPlayer(i);
        if(p !is null)
        {
            p.server_setTeamNum(-1); //factionless
        }
    }
}

void onInit( CRules@ this )
{
    onRestart( this );
}