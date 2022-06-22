void onInit( CBlob@ this )
{
    this.set_s32("growth", 0);
}

void onInit( CSprite@ this )
{
    this.SetFrameIndex(0);
}

void onTick( CBlob@ this )
{
    CMap@ map = this.getMap();
    Tile tile = map.getTile(this.getPosition());

    if (this.isOnGround() && map.isTileGrass(tile.type)) 
    {
        if (getGameTime() % 350 == 0)
        {
            this.add_s32("growth", 1);
            //print(this.get_s32("growth")+" ");
        }
    }
    else
    {
        this.set_s32("growth", 0);
    }

    if (this.get_s32("growth") > 25) //Finish time
	{
		this.server_Die();
		server_CreateBlob("corn",-1,this.getPosition());
	}
}

void onTick(CSprite@ this)
{
    if (this.getBlob().get_s32("growth") > 20)
    {
        this.SetFrameIndex(4);
    }
    else if (this.getBlob().get_s32("growth") > 15)
    {
        this.SetFrameIndex(3);
    }
    else if (this.getBlob().get_s32("growth") > 10)
    {
        this.SetFrameIndex(2);
    }
    else if (this.getBlob().get_s32("growth") > 5)
    {
        this.SetFrameIndex(1);
    }
}