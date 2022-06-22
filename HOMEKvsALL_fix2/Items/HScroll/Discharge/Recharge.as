#define SERVER_ONLY
#include "Hitters.as";
// regen hp back to

const string max_prop = "regen maximum";
const string rate_prop = "regen rate";
void onInit(CBlob@ this)
{
	if (!this.exists(max_prop))
		this.set_f32(max_prop, this.getInitialHealth());

	if (!this.exists(rate_prop))
		this.set_f32(rate_prop, 0.25f); //0.5 hearts per second

	this.getCurrentScript().tickFrequency = 60;
}

void onTick(CBlob@ this)
{
	if(this !is null )
	{
	this.server_Heal(this.get_f32(rate_prop));
	}

	}



