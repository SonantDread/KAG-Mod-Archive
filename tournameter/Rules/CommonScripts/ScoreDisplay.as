#include "Logging.as";
#include "RulesCore.as";
#include "ScoreCommon.as";

const SColor TEAM0COLOR(255,25,94,157);
const SColor TEAM1COLOR(255,192,36,36);
const u8 FONT_SIZE = 30;

void onInit(CRules@ this) {
    if (!GUI::isFontLoaded("big score font")) {
        GUI::LoadFont("big score font",
                      "GUI/Fonts/AveriaSerif-Bold.ttf", 
                      FONT_SIZE,
                      true);
    }
    this.set_bool("show score", true);
    this.addCommandID("CMD_SET_SCORE");

    if (isServer()) {
        SetScore(this, 0, 0);
    }
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player) {
    this.SyncToPlayer("show score", player);
    this.SyncToPlayer("team0score", player);
    this.SyncToPlayer("team1score", player);
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params) {
    if (cmd == this.getCommandID("CMD_SET_SCORE")) {
        u8 team0Score;
        u8 team1Score;

        if (params.saferead_u8(team0Score) && params.saferead_u8(team1Score)) {
            this.set_u8("team0score", team0Score);
            this.set_u8("team1score", team1Score);
        }
    }
}

void onStateChange(CRules@ this, const u8 oldState) {
    if (!isServer()) return;

    // Detect game over
    if (this.getCurrentState() == GAME_OVER &&
            oldState != GAME_OVER) {
        int winningTeam = this.getTeamWon();
        //log("onStateChange", "Detected game over! Winning team: " + winningTeam);

        if (winningTeam == 0) {
            //log("onStateChange", "Winning team is 0");
            SetScore(this, GetScore(this, 0) + 1, GetScore(this, 1));
        }
        else if (winningTeam == 1) {
            //log("onStateChange", "Winning team is 1");
            SetScore(this, GetScore(this, 0), GetScore(this, 1) + 1);
        }
    }
}

void onRender(CRules@ this)
{
    if (!this.get_bool("show score")) return;

    GUI::SetFont("big score font");
    u8 team0Score = GetScore(this, 0);
    u8 team1Score = GetScore(this, 1);
    //log("onRender", "" + team0Score + ", " + team1Score);
    Vec2f team0ScoreDims;
    Vec2f team1ScoreDims;
    Vec2f scoreSeperatorDims;
    GUI::GetTextDimensions("" + team0Score, team0ScoreDims);
    GUI::GetTextDimensions("" + team1Score, team1ScoreDims);
    GUI::GetTextDimensions("-", scoreSeperatorDims);

    Vec2f scoreDisplayCentre(getScreenWidth()/2, getScreenHeight() / 5.0);
    int scoreSpacing = 24;

    Vec2f topLeft0(
            scoreDisplayCentre.x - scoreSpacing - team0ScoreDims.x,
            scoreDisplayCentre.y);
    Vec2f topLeft1(
            scoreDisplayCentre.x + scoreSpacing,
            scoreDisplayCentre.y);
    GUI::DrawText("" + team0Score, topLeft0, TEAM0COLOR);
    GUI::DrawText("-", Vec2f(scoreDisplayCentre.x - scoreSeperatorDims.x/2.0, scoreDisplayCentre.y), color_black);
    GUI::DrawText("" + team1Score, topLeft1, TEAM1COLOR);
}
