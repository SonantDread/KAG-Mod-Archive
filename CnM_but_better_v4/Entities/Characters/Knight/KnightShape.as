
void onInit(CShape@ this)
{
	Vec2f[] points = {
		Vec2f(-4.2f, -7.5f),
		Vec2f(4.2f, -7.5f),
		Vec2f(0.0f, -6.0f),
	};
	this.AddShape(points);
	this.getCurrentScript().removeIfTag = "dead";
}

void onTick(CShape@ this)
{
	CBlob@ blob = this.getBlob();
	if(blob !is null && blob.hasTag("dead"))
	{
		//mmmmmmmmmmmmmm
	}
}