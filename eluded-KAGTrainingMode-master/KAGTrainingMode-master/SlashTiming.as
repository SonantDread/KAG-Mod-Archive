#include "Logging.as";
#include "KnightCommon.as";
#include "TrainingCommon.as";

void onRender(CSprite@ this) {
    Vec2f pos = GetAttackCenter(this.getBlob());
    Vec2f screenPos = getDriver().getScreenPosFromWorldPos(pos);
    float factor = getCamera().targetFactor;
    float dist = getCamera().targetDistance;
    float circleRadius = GetAttackRange(this.getBlob()) * (1/factor) * dist * 1.3;
    GUI::DrawCircle(screenPos, circleRadius, GetTeamColor(this.getBlob().getTeamNum()));
    /*
    log("onRender", "dist: " + getCamera().targetDistance +
            ", factor: " + getCamera().targetFactor + 
            ", attackrange: " + GetAttackRange(this.getBlob()));
            */
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params) {
    //log("onCommand", "called");
    if (cmd == this.getCommandID("begin attack")) {
        //log("onCommand", "begin attack cmd");
        this.set_Vec2f("begin attack pos", this.getPosition());
    }
    else if (cmd == this.getCommandID("release attack")) {
        u8 swordTimer = params.read_u8();
        //log("onCommand", "release attack cmd. swordTimer=" + swordTimer);
        if (getNet().isServer()) {
            CBlob @ text = CreateText(this, "" + swordTimer, this.getTeamNum(), this.getPosition());
            text.Tag("attack text");
            this.set_netid("recent attack text", text.getNetworkID());
        }
        const SColor GREEN_COLOR(255, 0, 255, 0);
    }
    else if (cmd == this.getCommandID("finish attack")) {
        //log("onCommand", "finish attack cmd");
        if (getNet().isServer()) {
            if (this.exists("begin attack pos")) {
                Vec2f beginPos = this.get_Vec2f("begin attack pos");
                Vec2f deltaTravelled = this.getPosition() - beginPos;
                Vec2f deltaBlocks = deltaTravelled / 8.0;
                float deltaX = Maths::Round(10*deltaBlocks.x)*0.1;
                float deltaY = Maths::Round(10*deltaBlocks.y)*0.1;
                //log("onCommand", "deltaX = " + deltaX);
                //log("onCommand", "deltaY = " + deltaY);
                if (Maths::Abs(deltaX) > 3 || Maths::Abs(deltaY) > 3) {
                    CBlob@ text = CreateText(this, "(" + deltaX + ", " + deltaY + ")",
                            this.getTeamNum(), this.getPosition() - Vec2f(0, 8));
                    text.Tag("distance text");
                    this.set_netid("recent distance text", text.getNetworkID());
                }
                else {
                    //log("onCommand", "Not creating distance text since we didn't go far enough.");
                }
            }
            // Do this since the game puts you into sword drawn state immediately
            // after finishing an attack. 
            this.set_Vec2f("begin attack pos", this.getPosition());
        }
    }
}

f32 GetAttackRange(CBlob@ this) {
    KnightInfo@ knight;
    if (!this.get("knightInfo", @knight)) {
        return 0.0;
    }

    f32 aimangle = getCutAngle(this);
    Vec2f blobPos = this.getPosition();
	Vec2f vel = this.getVelocity();
	Vec2f thinghy(1, 0);
	thinghy.RotateBy(aimangle);
	Vec2f pos = blobPos - thinghy * 6.0f + vel + Vec2f(0, -2);
	vel.Normalize();

	f32 attack_distance = Maths::Min(DEFAULT_ATTACK_DISTANCE + Maths::Max(0.0f, 1.75f * this.getShape().vellen * (vel * thinghy)), MAX_ATTACK_DISTANCE);
    return attack_distance + this.getRadius();
}

Vec2f GetAttackCenter(CBlob@ this) {
    KnightInfo@ knight;
    if (!this.get("knightInfo", @knight)) {
        return Vec2f(0,0);
    }

    f32 aimangle = getCutAngle(this);
    Vec2f blobPos = this.getPosition();
	Vec2f vel = this.getVelocity();
	Vec2f thinghy(1, 0);
	thinghy.RotateBy(aimangle);
	Vec2f pos = blobPos - thinghy * 6.0f + vel + Vec2f(0, -2);
    return pos;
}
