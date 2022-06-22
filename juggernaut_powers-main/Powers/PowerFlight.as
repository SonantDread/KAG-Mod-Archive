#include "Logging.as";

// See KnightLogic for longer shield gliding

void onTick(CBlob@ this)
{
    this.getShape().getVars().onladder = true;
}

/*void onTick(CBlob@ this) {
    this.set_f32("gravity scale", 0.5);
    this.getCurrentScript().runFlags |= Script::remove_after_this;
}*/ //originally power Feather