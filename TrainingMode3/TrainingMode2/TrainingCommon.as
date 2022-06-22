#include "Logging.as";

const SColor BLUE_COLOR(255, 0, 255, 255);
const SColor RED_COLOR(255, 255, 0, 0);
const SColor GREEN_COLOR(255, 0, 255, 0);

SColor GetTeamColor(int teamNum) {
    if (teamNum == 0) {
        return BLUE_COLOR;
    }
    else if (teamNum == 1) {
        return RED_COLOR;
    }
    else {
        return color_white;
    }
}

CBlob@ CreateText(CBlob@ parent, string text, int team, Vec2f pos) {
    log("CreateText", "Creating: " + text);
    CBlob@ textBlob = server_CreateBlob("textblob", team, pos);
    textBlob.set_string("text", "" + text);
    textBlob.set_netid("parent", parent.getNetworkID());
    return textBlob;
}
