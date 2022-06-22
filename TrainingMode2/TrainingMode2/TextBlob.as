#include "Logging.as";
#include "TrainingCommon.as";

const u16 TEXT_LIFETIME = 140;

void onInit(CBlob@ this) {
    this.set_string("text", "NO TEXT");
    this.getShape().SetStatic(true);
    this.set_u16("lifetime", TEXT_LIFETIME);
    this.getSprite().server_SetActive(false);
    this.set_u16("color", color_white.color);

}

void onTick(CBlob@ this) {
    //log("onTick", "test");
    u16 lifetime = this.get_u16("lifetime");
    if (lifetime == 0) {
        this.server_Die();
    }
    else {
        this.set_u16("lifetime", lifetime-1);
    }

    // Remove old attack timer text
    if (getGameTime() % 5 == 0 && this.exists("parent")) {
        u16 parentNetID = this.get_netid("parent");
        CBlob@ parent = getBlobByNetworkID(parentNetID);
        if (parent is null) {
            log("onTick", "parent is null");
            this.server_Die();
        }
        else {
            u16 recentTextID = 0;
            if (this.hasTag("attack text") && parent.exists("recent attack text")) {
                recentTextID = parent.get_netid("recent attack text");
            }
            else if (this.hasTag("distance text") && parent.exists("recent distance text")) {
                recentTextID = parent.get_netid("recent distance text");
            }

            //log("onTick", "parent has most recent text");
            if (recentTextID > 0 && recentTextID != this.getNetworkID()) {
                log("onTick", "Killing text since it's not most recent: " + this.get_string("text"));
                this.server_Die();
            }
        }
    }
}

u8 GetAlpha(CBlob@ this) {
    // Fade text over its lifetime
    u16 lifetime = this.get_u16("lifetime");
    float maxLifetime = TEXT_LIFETIME;
    float alpha = lifetime / maxLifetime;
    u8 result = Maths::Round(alpha * 255);
    /*
    log("GetAlpha", "alpha= " + alpha +
            ", lifetime= " + lifetime +
            ", result= " + result);
            */
    return result;
}

void onRender(CSprite@ this) {
    Vec2f worldPos = this.getBlob().getPosition();
    Vec2f screenPos = getDriver().getScreenPosFromWorldPos(worldPos);
    //log("onRender", "worldPos = (" +worldPos.x + "," + worldPos.y+")");
    //log("onRender", "screenPos = (" +screenPos.x + "," + screenPos.y+")");
    Vec2f dims;
    SColor color(this.getBlob().get_u16("color"));
    color.setAlpha(GetAlpha(this.getBlob()));
    string text = this.getBlob().get_string("text");
    GUI::GetTextDimensions(text, dims);
    GUI::SetFont("menu");
    GUI::DrawTextCentered(text, screenPos, color);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob) {
    return false;
}
