#include "Hitters.as";

void onTick( CBlob@ this ) {
	CMap@ map = getMap();
	f32 x = this.getVelocity().x;
	f32 y = this.getVelocity().y;

    if (this.isOnMap() && (Maths::Abs(x) + Maths::Abs(y) > 2.0f)) {
        this.server_Die();
        this.getSprite().PlaySound("Glass-breaking-sound.ogg", 5.0f);
        if (isServer()) {
	        server_CreateBlob("skeleton",-1,this.getPosition());
        }
    }
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob) {
    if (blob.hasTag("player")) {
        const u8 hitter = this.get_u8("custom_hitter");
        if (hitter == Hitters::water)
            return blob.getTeamNum() != this.getTeamNum();
        return (blob.getTeamNum() != this.getTeamNum() && blob.hasTag("shielded"));
    }
    string name = blob.getName();
    if (name == "fishy" || name == "food" || name == "steak" || name == "grain" || name == "heart") {
        return false; }
    return true;
}

void onTick( CSprite@ this ) {
    CBlob@ blob = this.getBlob();
    Vec2f vel = blob.getVelocity();
    this.RotateAllBy(9 * vel.x, Vec2f_zero);	 		  
}

void onDie(CBlob@ this) {
    this.getSprite().SetEmitSoundPaused(true);
}
