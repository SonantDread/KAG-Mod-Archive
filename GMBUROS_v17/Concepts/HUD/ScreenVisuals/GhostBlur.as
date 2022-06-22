
#include "HumanoidCommon.as";
#include "DrawOverlay.as";

void onRender(CSprite@ this)
{

	CBlob@ blob = this.getBlob();

	if(getLocalPlayer() !is blob.getPlayer())return;

	LimbInfo@ limbs;
	if (!this.get("limbInfo", @limbs))return;
	
	if(limbs.Head == BodyType::Ghost || limbs.Head == BodyType::Wraith){
		DrawOverlay("GhostBlur.png");
	}
	
}
