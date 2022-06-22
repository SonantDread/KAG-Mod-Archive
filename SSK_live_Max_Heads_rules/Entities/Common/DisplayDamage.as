#include "FighterVarsCommon.as"
#include "TeamColour.as";

// shows damage of fighters

#define CLIENT_ONLY

void onRender(CSprite@ thisSprite)
{
	CBlob@ thisBlob = thisSprite.getBlob();

	f32 screenWidth = getScreenWidth();
	f32 screenHeight = getScreenHeight();

	Vec2f pos2d = thisBlob.getInterpolatedScreenPos();
	//Vec2f pos2d = getDriver().getScreenPosFromWorldPos( blob.getSprite().getWorldTranslation() );
	Vec2f dim = Vec2f(24,8);
	const f32 y = thisBlob.getHeight()*1.4f;

	SSKFighterVars@ fighterVars;
	if (thisBlob.get("fighterVars", @fighterVars))
	{
		f32 damageStatus = fighterVars.damageStatus;
		
		f32 fractionHealth = damageStatus/1000.0f;
		int hue = 255 - Maths::Min(255 * fractionHealth*1.75f,255);

		SColor col =  SColor(255, 255, hue, hue);
		GUI::DrawText(""+Maths::Round(damageStatus)+"%", Vec2f(pos2d.x - dim.x+10, pos2d.y + y-75), col);
	}
}