#include "Logging.as";
#include "FleshHit.as";
#include "PowersCommon.as"; // new

// See FleshHit for damage reduction

void onInit(CBlob@ this) {
    this.getShape().SetMass(this.getMass() * 1.0);
    this.getCurrentScript().runFlags |= Script::remove_after_this;
	this.getCurrentScript().tickFrequency=this.getConfig()=="juggernaut" ? 4 : 5;
}
f32 onHit(Cblob @this, f32 damage, CBlob@ hitterBlob) {
	if (hasPower(this, Powers::MOUNTAIN)) {
		this.Damage(damage*0.5, hitterBlob);
	} else {
		this.Damage(damage, hitterBlob);
		}
	}