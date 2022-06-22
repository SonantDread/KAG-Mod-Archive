// Boss health bar

const string linadj_hp = "linear adjustment";

void onInit(CBlob@ this)
{
	// Set to current/init hp
	this.set_f32(linadj_hp, this.getHealth());
}

void onTick(CBlob@ this)
{
	// Get init hp
	const f32 initialHealth = this.getInitialHealth();

	// Slowly match to real hp
	if ((this.get_f32(linadj_hp) != this.getHealth()))
	{
		if (this.get_f32(linadj_hp)+0.2 < this.getHealth())
			this.set_f32(linadj_hp, this.get_f32(linadj_hp) + 0.1);
		else if (this.get_f32(linadj_hp)-0.2 > this.getHealth())
			this.set_f32(linadj_hp, this.get_f32(linadj_hp) - 0.1);
	}
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	Vec2f center = blob.getPosition();
	Vec2f mouseWorld = getControls().getMouseWorldPos();

	Vec2f pos2d = blob.getScreenPos() + Vec2f(0, 60);
	Vec2f dim = Vec2f(96, 24);
	const f32 y = blob.getHeight() * 2.1f;
	const f32 initialHealth = blob.getInitialHealth();

	CMap@ map = getMap();
	bool inGround = map.isTileSolid(blob.getPosition());

	if (inGround)
		{ return; }

	if (initialHealth > 0.0f)
	{
		const f32 perc  = blob.getHealth() / initialHealth;
		const f32 perc2 = blob.get_f32(linadj_hp) / initialHealth;

		if (perc >= 0.0f)
		{
			// Border
			GUI::DrawRectangle(Vec2f(pos2d.x - dim.x - 2,                        pos2d.y + y - 2),
							   Vec2f(pos2d.x + dim.x + 2,                        pos2d.y + y + dim.y + 2));
			// Red portion
			GUI::DrawRectangle(Vec2f(pos2d.x - dim.x + 2,                        pos2d.y + y + 2),
							   Vec2f(pos2d.x + dim.x,                            pos2d.y + y + dim.y - 2), SColor(0xff852d29));
			// Health linear adj
			GUI::DrawRectangle(Vec2f(pos2d.x - dim.x + 1,                        pos2d.y + y + 1),
							   Vec2f(pos2d.x - dim.x + perc2 * 2.0f * dim.x - 1, pos2d.y + y + dim.y - 1), SColor(0xff96aa83));
			// Health meter trim
			GUI::DrawRectangle(Vec2f(pos2d.x - dim.x + 1,                        pos2d.y + y + 1),
							   Vec2f(pos2d.x - dim.x + perc  * 2.0f * dim.x - 1, pos2d.y + y + dim.y - 1), SColor(0xff56d534));
			// Health meter inside
			GUI::DrawRectangle(Vec2f(pos2d.x - dim.x + 3,                        pos2d.y + y + 3),
							   Vec2f(pos2d.x - dim.x + perc  * 2.0f * dim.x - 3, pos2d.y + y + dim.y - 3), SColor(0xff43b22e));
		}
	}
}