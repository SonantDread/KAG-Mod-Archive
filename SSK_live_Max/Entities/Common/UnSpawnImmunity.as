void onInit(CBlob@ this)
{
	this.Tag("invincible");

	u32 maximumImmuneTicks = getRules().get_f32("immunity sec") * getTicksASecond();
	this.set_u32("spawn immunity time", maximumImmuneTicks);
}

void onTick(CBlob@ this)
{
	bool immunity = false;

	u32 immunityTime = this.get_u32("spawn immunity time");
	u32 ticksSinceImmune = getGameTime() - this.get_u32("spawn immunity time");
	u32 maximumImmuneTicks = getRules().get_f32("immunity sec") * getTicksASecond();
	if (immunityTime > 0)
	{
		CSprite@ s = this.getSprite();
		if (s !is null)
		{
			s.setRenderStyle(getGameTime() % 7 < 5 ? RenderStyle::normal : RenderStyle::additive);
			CSpriteLayer@ layer = s.getSpriteLayer("head");
			if (layer !is null)
				layer.setRenderStyle(getGameTime() % 7 < 5 ? RenderStyle::normal : RenderStyle::additive);
		}
		immunity = true;

		if (!this.isAttached())
		{
			immunityTime--;
			this.set_u32("spawn immunity time", immunityTime);
		}
	}

	if (!immunity || this.getPlayer() is null)
	{
		this.Untag("invincible");
		this.getCurrentScript().runFlags |= Script::remove_after_this;
		this.getSprite().setRenderStyle(RenderStyle::normal);
	}
}
