void onInit(CBlob@ this)
{
	CShape@ shape = this.getShape();
	shape.getConsts().mapCollisions = false;
	shape.setDrag(shape.getDrag() + 0.4f);
	this.setVelocity(this.getVelocity() / 2.0f); //half vel.
}
bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return false;
}