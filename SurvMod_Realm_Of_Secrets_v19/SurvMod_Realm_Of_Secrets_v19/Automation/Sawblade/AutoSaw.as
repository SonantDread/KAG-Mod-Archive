// TrapBlock.as

#include "Hitters.as";
#include "MapFlags.as";
#include "MaterialCommon.as";
#include "TreeCommon.as"

void onInit(CBlob@ this)
{
	
	this.getShape().SetRotationsAllowed(false);
	
	this.Tag("place norotate");
	this.Tag("blocks sword");

	this.getCurrentScript().runFlags |= Script::tick_not_attached;

	this.Tag("builder always hit");
	
	this.getCurrentScript().tickFrequency = 10;
}

void onTick(CBlob@ this)
{
	
	CBlob@[] blobsInRadius;
	if (this.getMap().getBlobsInRadius(this.getPosition(), 12, @blobsInRadius))
	{
		for(int i = 0;i < blobsInRadius.length;i++){
			CBlob @blob = blobsInRadius[i];
			if((blob.hasTag("flesh") && this.getDistanceTo(blob) <= 12) || blob.exists("harvest")){
				if(isServer()){
					this.server_Hit(blob, this.getPosition(),  blob.getPosition()-this.getPosition(), 0.5f, Hitters::saw, true);
					Material::fromBlob(this, blob, 0.5f);
				}
				
				if(blob.hasTag("flesh")){
					CSpriteLayer@ sawblade = this.getSprite().getSpriteLayer("sawblade");
					if(sawblade !is null)
					{
						sawblade.SetFrame(2);
					}
				}
			}

			if(isServer())
			if(blob.hasTag("tree")){
				
				TreeVars@ vars;
				blob.get("TreeVars", @vars);

				if (vars !is null){
					if(vars.height >= vars.max_height)this.server_Hit(blob, this.getPosition(),  blob.getPosition()-this.getPosition(), 0.5f, Hitters::saw, true);
				}
			}
		}
	}
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	if (!isStatic) return;

	this.getSprite().PlaySound("/build_door.ogg");

	if(isServer()){
		CMap@ map = getMap();
		if (map.getTile(this.getPosition()).type != CMap::tile_castle_back)map.server_SetTile(this.getPosition(), CMap::tile_castle_back);
	}
}

void onInit(CSprite@ this)
{
	this.SetZ(50);
	CSpriteLayer@ sawblade = this.addSpriteLayer( "sawblade","AutoSaw.png", 16,16);
	if(sawblade !is null)
	{
		sawblade.addAnimation("default",0,false);
		int[] frames = {1};
		sawblade.animation.AddFrames(frames);
		sawblade.SetRelativeZ(100);
		sawblade.SetIgnoreParentFacing(true);
		sawblade.SetFacingLeft(true);
	}
}

void onTick(CSprite@ this)
{
	CSpriteLayer@ sawblade = this.getSpriteLayer( "sawblade");
	if(sawblade !is null)
	{
		sawblade.RotateBy(-20,Vec2f(-0.5f,-0.5f));
		//sawblade.ResetTransform();
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}