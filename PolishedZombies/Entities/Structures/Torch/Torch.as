void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(false);
    this.SetLight(true);
    this.SetLightRadius(64.0f);
    this.SetLightColor(SColor(255, 255, 240, 171));
    this.getShape().getConsts().mapCollisions = false;

    this.Tag("dont deactivate");
    this.Tag("fire source");
    this.Tag("place norotate");
    this.set_TileType("background tile", CMap::tile_wood_back);
}