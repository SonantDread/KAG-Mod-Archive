void onTick(CBlob@ this)
{
if (this.hasTag("add force again"))
	{
		this.setVelocity(this.getVelocity()+this.get_Vec2f("original velocity")); 
		this.Untag("add force again");
	}
}
