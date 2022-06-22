//Unnecessary?
void onInit(CBlob@ this)
{
	CShape@ shape = this.getShape();
	shape.SetGravityScale(0);
	shape.setDrag(shape.getDrag() + 0.6f);
}