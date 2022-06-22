#include "CharmCommon.as"

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (this !is null && this.getPlayer() !is null && getRules() !is null)
	{
		getRules().set_u32("lastknocktime" + this.getPlayer().getUsername(), getGameTime());
		getRules().Sync("lastknocktime" + this.getPlayer().getUsername(), true);
	}

	return damage;
}

void onTick(CBlob@ this)
{
	if (this.getPlayer() is null)
		return;

	if (getRules() is null)
		return;

	PlayerCharm@ hotcharm = getCharmByName("clockcharm");

	if (hotcharm is null)
		return;

	u16 cooldown = hotcharm.cooldown;

	if (getRules().get_u32("lastknocktime" + this.getPlayer().getUsername()) > getGameTime())
	{
		getRules().set_u32("lastknocktime" + this.getPlayer().getUsername(), getGameTime());
		getRules().Sync("lastknocktime" + this.getPlayer().getUsername(), true);
	}

	else if (getRules().get_u32("lastknocktime" + this.getPlayer().getUsername()) + cooldown < getGameTime() && getRules().get_bool("clockcharm_" + this.getPlayer().getUsername()))
	{
		if (getGameTime() % 60 == 0)
		{
			if (this.getHealth() < this.getInitialHealth())
			{
				if (this.isMyPlayer())
				{
					Sound::Play("Heart.ogg", this.getPosition(), 0.5);
				}
				if (isServer())
				{
					f32 oldHealth = this.getHealth();
					this.server_Heal(0.25f);
					this.add_f32("heal amount", this.getHealth() - oldHealth);
				}
			}
		}
	}
}