#include "RulesCore.as";
#include "TeamColour.as";

#include "tickets.as";

int redTicketsLeft;
int blueTicketsLeft;

s16 ticketsPerTeam;
s16 ticketsPerPlayer;
s16 ticketsPerPlayerInTeam0;

bool unevenTickets;
s16 numBlueTickets;
s16 numRedTickets;

s16 numBlueTicketsPerPlayerInTeam;
s16 numRedTicketsPerPlayerInTeam;
s16 numBlueTicketsPerPlayerInGame;
s16 numRedTicketsPerPlayerInGame;


void reset(CRules@ this){

	if(getNet().isServer()){

		//string configstr = "../Mods/tickets/Rules/CommonScripts/tickets/tickets.cfg";
		string configstr = "../Mods/AvA2Tent/settings/tickets.cfg";
		if (this.exists("ticketsconfig")){
			configstr = this.get_string("ticketsconfig");
		}
		ConfigFile cfg = ConfigFile( configstr );
		
		ticketsPerTeam = 0;
		ticketsPerPlayer = 0;
		ticketsPerPlayerInTeam0 = 0;
		
		numBlueTickets = 500;
		numRedTickets = 200;

		numBlueTicketsPerPlayerInTeam = 0;
		numRedTicketsPerPlayerInTeam = 0;
		numBlueTicketsPerPlayerInGame = 0;
		numRedTicketsPerPlayerInGame = 0;

		
		RulesCore@ core;
		this.get("core", @core);
		if(core is null) print("core is null!!!");
		

		s16 redTickets=ticketsPerTeam;
		s16 blueTickets=ticketsPerTeam;

		int playersInGame=getPlayersCount();

		blueTickets+=(ticketsPerPlayer*playersInGame);
		redTickets+=(ticketsPerPlayer*playersInGame);
		blueTickets+=(ticketsPerPlayerInTeam0*(core.getTeam(0).players_count));
		redTickets+=(ticketsPerPlayerInTeam0*(core.getTeam(0).players_count));

		blueTickets+=numBlueTickets;
		redTickets+=numRedTickets;
		blueTickets+=(numBlueTicketsPerPlayerInTeam*core.getTeam(0).players_count);
		redTickets+=(numRedTicketsPerPlayerInTeam*core.getTeam(1).players_count);
		blueTickets+=(numBlueTicketsPerPlayerInGame*playersInGame);
		redTickets+=(numRedTicketsPerPlayerInGame*playersInGame);

		this.set_s16("redTickets", redTickets);
		this.set_s16("blueTickets", blueTickets);
		this.Sync("redTickets", true);
		this.Sync("blueTickets", true);

	}
}

void onInit(CRules@ this){
	reset(this);
}

void onRestart(CRules@ this){
	reset(this);
}

void onRender(CRules@ this){

	s16 blueTickets=0;
	s16 redTickets=0;

	blueTickets=this.get_s16("blueTickets");
	redTickets=this.get_s16("redTickets");

	GUI::DrawText( "Spawns Remaining:", Vec2f(345,getScreenHeight()-100), color_white );
	GUI::DrawText( ""+redTickets, Vec2f(430,getScreenHeight()-80), getTeamColor(1) );		//shows tickets just above bottom left HUD
	GUI::DrawText( ""+blueTickets, Vec2f(380,getScreenHeight()-80), getTeamColor(0) );

}


void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ killer, u8 customData){
print("onplayerdie");
	int teamNum=victim.getTeamNum();
        checkGameOver(this, teamNum);

        if(this.isMatchRunning()){
        	int numTickets=0;

        	if(teamNum==0){
                	numTickets=this.get_s16("blueTickets");
        	}else{
                	numTickets=this.get_s16("redTickets");
        	}
        	if(numTickets<=0){          //play sound if running/run out of tickets
                	Sound::Play("/depleted.ogg");
                	return;
        	}else if(numTickets<=5){
                	Sound::Play("/depleting.ogg");
                	return;
        	}
        }
}

void onPlayerLeave( CRules@ this, CPlayer@ player ){

	CBlob @blob = player.getBlob();
	if (blob !is null && !blob.hasTag("dead"))
	{
		int teamNum=player.getTeamNum();
        	checkGameOver(this, teamNum);
        }

}

void onPlayerChangedTeam( CRules@ this, CPlayer@ player, u8 oldteam, u8 newteam ){
	checkGameOver(this, oldteam);
}