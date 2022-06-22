int GetScore(CRules@ this, int team) {
    string prop = "team" + team + "score";
    if (this.exists(prop)) {
        return this.get_u8(prop);
    }
    else {
        log("GetScore", "No score found for team " + team);
        return 0;
    }
}

// Only called by server
void SetScore(CRules@ this, int team0Score, int team1Score) {
    log("SetScore", "Score is " + team0Score + ", " + team1Score);
    this.set_u8("team0score", team0Score);
    this.set_u8("team1score", team1Score);

    // Sync scores
    CBitStream params;
    params.write_u8(team0Score);
    params.write_u8(team1Score);
    this.SendCommand(this.getCommandID("CMD_SET_SCORE"), params, true);
    //this.Sync("team0score", true);
    //this.Sync("team1score", true);
}

void ToggleScore(CRules@ this) {
    this.set_bool("show score", !this.get_bool("show score"));
    this.Sync("show score", true);
}