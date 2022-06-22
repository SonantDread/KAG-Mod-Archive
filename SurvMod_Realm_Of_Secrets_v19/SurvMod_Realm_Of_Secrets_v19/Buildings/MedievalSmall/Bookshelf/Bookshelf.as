void onInit( CBlob@ this )
{
	this.Tag("bookshelf");
}


bool isInventoryAccessible( CBlob@ this, CBlob@ forBlob )
{
	return forBlob.isOverlapping(this);
}