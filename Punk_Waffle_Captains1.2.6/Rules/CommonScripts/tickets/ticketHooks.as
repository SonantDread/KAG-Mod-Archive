
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
		string configstr = CFileMatcher("tickets.cfg").getFirst();
		if (this.exists("ticketsconfig")){
			configstr = this.get_string("ticketsconfig");
		}
		ConfigFile cfg = ConfigFile( configstr );
		
		ticketsPerTeam = cfg.read_s16("ticketsPerTeam",40);
		ticketsPerPlayer = cfg.read_s16("ticketsPerPlayer",0);
		ticketsPerPlayerInTeam0 = cfg.read_s16("ticketsPerPlayerInTeam0",0);
		
		numBlueTickets = cfg.read_s16("numBlueTickets",0);
		numRedTickets = cfg.read_s16("numRedTickets",0);

		numBlueTicketsPerPlayerInTeam = cfg.read_s16("numBlueTicketsPerPlayerInTeam",0);
		numRedTicketsPerPlayerInTeam = cfg.read_s16("numRedTicketsPerPlayerInTeam",0);
		numBlueTicketsPerPlayerInGame = cfg.read_s16("numBlueTicketsPerPlayerInGame",0);
		numRedTicketsPerPlayerInGame = cfg.read_s16("numRedTicketsPerPlayerInGame",0);
		
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
		this.set_s16("TugOfTickets", 0);
		this.Sync("TugOfTickets", true);
		this.set_bool("enabletickets", false);
		this.Sync("enabletickets", true);
	}
}

void onInit(CRules@ this){
	reset(this);
}

void onRestart(CRules@ this){
	reset(this);
}
void onRender(CRules@ this){
	if(this.get_bool("enabletickets")){
		s16 blueTickets = 0;
		s16 redTickets = 0;
		SColor light_red = SColor(255, 240, 128, 128);
		SColor light_blue = SColor(255, 135, 206, 250);

		int TicketCap = this.get_s16("TugOfTickets");
		blueTickets = this.get_s16("blueTickets");
		redTickets = this.get_s16("redTickets");

		GUI::DrawText("Spawns Remaining:", Vec2f(345,getScreenHeight()-100), color_white );
		GUI::DrawText(redTickets +(redTickets < TicketCap ? "!!" : ""), Vec2f(430,getScreenHeight()-80), (redTickets < TicketCap ? light_red : getTeamColor(1)) );		//shows tickets just above bottom left HUD
		GUI::DrawText(blueTickets +(blueTickets < TicketCap ? "!!" : ""), Vec2f(380,getScreenHeight()-80), (blueTickets < TicketCap ? light_blue : getTeamColor(0)) );
	}
}

void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ killer, u8 customData){

	int teamNum=victim.getTeamNum();
	// checkGameOver(this, teamNum);

	if(this.isMatchRunning()){
		int numTickets=0;

		numTickets=this.get_s16((teamNum == 0 ? "blueTickets" : "redTickets"));
		if(numTickets<=5){
			Sound::Play("/depleting.ogg");
		}
		if(killer !is null && victim !is null){		
			if(this.get_s16((killer.getTeamNum() == 0 ? "blueTickets" : "redTickets"))<this.get_s16("TugOfTickets")){
				if (killer.getTeamNum() != teamNum && isServer()){
					getNet().server_SendMsg( killer.getUsername() + " retrieved a ticket by killing " + victim.getUsername() + "!" );
					this.set_s16((killer.getTeamNum() == 0 ? "blueTickets" : "redTickets"), (this.get_s16((killer.getTeamNum() == 0 ? "blueTickets" : "redTickets")) + 1));
					this.Sync((killer.getTeamNum() == 0 ? "blueTickets" : "redTickets"), true);
				}
			}
		}
		return;
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
