//Get stuck running forward/backward based on facing direction
//make sure this goes before the actual mover code in execution order

#include "FireCommon.as";
#include "PowersCommon.as";

void onInit(CMovement@ this)
{
	this.getCurrentScript().tickIfTag = burning_tag;
	this.getCurrentScript().removeIfTag = "dead";
}

void onTick(CMovement@ this) {
    if (this.getBlob().hasTag(getPowerName(Powers::FIRE_LORD)))
        this.getCurrentScript().runFlags |= Script::remove_after_this; }