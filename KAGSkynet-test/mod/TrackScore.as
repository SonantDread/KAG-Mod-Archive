// This script controls the score assigned to a bot for each game
// It is included at the top of Knight.cfg
#include "Logging.as";
#include "SkynetConfig.as";
#include "FitnessFunction.as";

void onInit(CBlob@ this) {
    //log("onInit", "Hook called");
    this.set_f32(SUPERBOT_SCORE_PROP, 0.0);

    // After this blob dies we still need access to the FitnessVars computed
    // So they are actually attached to the player
}

void onSetPlayer(CBlob@ this, CPlayer@ player) {
    //log("onSetPlayer", "Hook called");
    
    if (player !is null) {
        FitnessVars vars();
        player.set(SUPERBOT_FITNESS_VARS_PROP, @vars);
    }
}

void onTick(CBlob@ this) {
    if (this.hasTag("dead")) {
        this.getCurrentScript().runFlags |= Script::remove_after_this;
        return;
    }
    else if (this.getPlayer() is null) {
        // Wait til FitnessVars are set on player
        return;
    }

    // Detect if idle
    FitnessVars@ vars = GetVars(this);
    if (IsIdle(this)) {
        vars.idleTicks++;
        vars.totalIdle++;
    }
    else {
        vars.idleTicks = 0;
    }

    // Average velocity computation
    vars.velMeasurements++;
    float vel = this.getVelocity().Length();

    float s1 = vars.averageVel * vars.velMeasurements;
    float t1 = vars.velMeasurements;
    vars.averageVel = (s1 + vel) / (t1 + 1);
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData) {
    damage = damage * 2; // weird damage scaling stuff
    //log("onHitBlob", "Hook called. " + damage);
    if (hitBlob.getName() != "knight") {
        log("onHitBlob", "Hit a weird blob");
        return;
    }

    if (damage > 0) {
        GetVars(this).damageDealt += damage;
    }
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
    //log("onHit", "Hook called. " + damage);
    if (hitterBlob.getName() != "knight") {
        log("onHit", "Hit by a weird blob");
        return damage;
    }

    if (damage > 0) {
        GetVars(this).damageTaken += damage;
    }

    return damage;
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params) {
    if (cmd == this.getCommandID("block attack cmd")) {
        if (params !is null && GetVars(this) !is null) {
            float damage = params.read_f32();
            //log("onCommand", "block attack cmd received: " + damage);
            GetVars(this).damageBlocked += damage;
        }
    }
}


bool IsIdle(CBlob@ this) {
    bool active = (this.isKeyPressed(key_up) ||
            this.isKeyPressed(key_down)      ||
            this.isKeyPressed(key_left)      ||
            this.isKeyPressed(key_right)     ||
            this.isKeyPressed(key_action1)   ||
            this.isKeyPressed(key_action2));

    if (this.hasTag(SUPERBOT_TAG)) {
        DebugKeys(this);
        log("IsIdle", "active = " + active);
    }
    return !active;
}

void DebugKeys(CBlob@ this) {
    log("DebugKeys", "Keys pressed: " + 
            "down = " + this.isKeyPressed(key_down) +
            ", up = " + this.isKeyPressed(key_up) +
            ", left = " + this.isKeyPressed(key_left) +
            ", right = " + this.isKeyPressed(key_right) +
            ", action1 = " + this.isKeyPressed(key_action1) +
            ", action2 = " + this.isKeyPressed(key_action2));
}

FitnessVars@ GetVars(CBlob@ this) {
    FitnessVars@ vars;
    if (this.getPlayer() !is null) {
        bool check = this.getPlayer().get("fitness vars", @vars);
        if (!check) {
            log("GetVars", "ERROR couldn't get vars");
        }
    }

    return vars;
}
