
#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("builder always hit");
	
	this.set_u16("target",0);
	this.set_f32("burst",0.0f);
	this.set_u16("charge",0);
	
	this.addCommandID("pew");

}

void onTick(CBlob@ this)
{
	int quant = this.getInventory().getCount("gem");
	
	CBlob @closest = null;
	
	if(quant > 0){
		CBlob@[] blobs;
		getMap().getBlobsInRadius(this.getPosition(), 160.0f, @blobs);
		
		
		for(int i = 0;i < blobs.length;i++){
			CBlob @blob = blobs[i];
			Vec2f pos = blob.getPosition();
			
			if(blob.hasTag("player") && blob.getTeamNum() != this.getTeamNum())
			if(!getMap().rayCastSolid(this.getPosition(), blob.getPosition())){
			
				if(closest is null){
					@closest = blob;
				} else {
					if(this.getDistanceTo(blob) < this.getDistanceTo(closest)){
						@closest = blob;
					}
				}
			
			}
		}
		
		
	}
	
	if(closest !is null){
		this.set_u16("target",closest.getNetworkID());
		this.add_u16("charge",1);
		if(this.get_u16("charge") >= 30){
			if(isServer())this.SendCommand(this.getCommandID("pew"));
			this.set_u16("charge",0);
		}
	} else {
		this.set_u16("target",0);
		this.set_u16("charge",0);
	}
	
	if(isClient())
	if(this.get_f32("burst") > 0.0f){
		this.sub_f32("burst",0.1f);
		if(this.get_f32("burst") < 0.0f){
			this.set_f32("burst",0.0f);
		}
	}
	
	//print("Burst:"+this.get_f32("burst"));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("pew"))
	{
		this.set_u16("charge",0);
		if(isClient())this.set_f32("burst",1.0f);
		if(isServer()){
			u16 targ_id = this.get_u16("target");
			if(targ_id != 0){
				CBlob @target = getBlobByNetworkID(targ_id);
				if(target !is null){
					int quant = this.getInventory().getCount("gem");
					this.server_Hit(target, target.getPosition(), Vec2f(0,0), quant, Hitters::burn);
				}
			}
		}
	}

}

void onInit(CSprite@ this)
{
	CSpriteLayer@ LaserHead = this.addSpriteLayer("head", "GemLaser.png", 16, 16);
	if (LaserHead !is null)
	{
		{
			LaserHead.addAnimation("default", 0, false);
			int[] frames = { 8,9 };
			LaserHead.animation.AddFrames(frames);
		}
		LaserHead.SetOffset(Vec2f(0.0f, 1.0f));
		LaserHead.SetRelativeZ(2);
	}
	
	CSpriteLayer@ Laser = this.addSpriteLayer("laser", "GemLaser.png", 8, 8);
	if (Laser !is null)
	{
		{
			Laser.addAnimation("default", 0, false);
			int[] frames = { 15 };
			Laser.animation.AddFrames(frames);
		}
		Laser.SetOffset(Vec2f(0.0f, 1.0f));
		Laser.SetRelativeZ(1);
		//Laser.ScaleBy(1.0f, 0.25f);
	}

}

void onAddToInventory(CBlob@ this, CBlob@ blob)
{
    if(this.getSprite() !is null){
		CSpriteLayer@ LaserHead = this.getSprite().getSpriteLayer("head");
		if (LaserHead !is null){
			int quant = this.getInventory().getCount("gem");
			if(quant > 0){
				LaserHead.SetFrameIndex(1);
			} else {
				LaserHead.SetFrameIndex(0);
			}
		}
	}
}

void onRemoveFromInventory(CBlob@ this, CBlob@ blob)
{
    if(this.getSprite() !is null){
		CSpriteLayer@ LaserHead = this.getSprite().getSpriteLayer("head");
		if (LaserHead !is null){
			int quant = this.getInventory().getCount("gem");
			if(quant > 0){
				LaserHead.SetFrameIndex(1);
			} else {
				LaserHead.SetFrameIndex(0);
			}
		}
	}
}

void onTick(CSprite@ this)
{
	CBlob @blob = this.getBlob();
	CSpriteLayer@ LaserHead = this.getSpriteLayer("head");
	CSpriteLayer@ Laser = this.getSpriteLayer("laser");
	if (LaserHead !is null && Laser !is null)
	{
		u16 targ_id = blob.get_u16("target");
		if(targ_id != 0){
			CBlob @target = getBlobByNetworkID(targ_id);
			if(target !is null){
				LaserHead.ResetTransform();
				LaserHead.RotateByDegrees(-(blob.getPosition()-target.getPosition()).AngleDegrees(),Vec2f(0,0));
				
				Vec2f off = target.getPosition() - blob.getPosition();

				f32 scale = (float(blob.get_u16("charge"))/30.0f);
				if(blob.get_f32("burst") > 0.0f)scale = 1.0f;

				f32 ropelen = Maths::Max(0.1f, off.Length() / 8.0f)*scale;

				Laser.ResetTransform();
				Laser.ScaleBy(Vec2f(ropelen, 1.0f));
				//Laser.ScaleBy(ropelen, (0.25f)+0.75f*blob.get_f32("burst"));

				Laser.TranslateBy(Vec2f(ropelen * 4.0f, 0.0f));

				Laser.RotateBy(-off.Angle() , Vec2f());
			}
		} else {
			Laser.ResetTransform();
			Laser.ScaleBy(Vec2f(0.1f, 1.0f));
		}
	}

}