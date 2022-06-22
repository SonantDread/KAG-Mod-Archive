
#include "RunnerCommon.as";
#include "Knocked.as";
#include "Hitters.as";
#include "LimbsCommon.as";
#include "AbilityCommon.as";

void onInit(CBlob@ this)
{
	this.set_s8("temperature",50);
}

void onInit(CSprite@ this)
{
	this.RemoveSpriteLayer("frozen");
	CSpriteLayer@ frozen = this.addSpriteLayer("frozen", "Frozen.png" , 24, 24);
	if (frozen !is null)
	{
		frozen.SetOffset(Vec2f(0,0));
		frozen.SetRelativeZ(5.0f);
		frozen.setRenderStyle(RenderStyle::light);
		frozen.SetIgnoreParentFacing(true);
		frozen.SetFacingLeft(false);
		frozen.SetVisible(false);
	}
}

void onTick(CSprite@ this)
{
	int Temp = this.getBlob().get_s8("temperature");
	
	CSpriteLayer@ frozen = this.getSpriteLayer("frozen");
	if (frozen !is null)
	{
		if(Temp <= 0){
			frozen.SetVisible(true);
			frozen.setRenderStyle(RenderStyle::light);
		} else {
			frozen.SetVisible(false);
		}
	}
}

void onTick(CBlob@ this)
{
	int Temp = this.get_s8("temperature");
	
	if(Temp < 35){
		RunnerMoveVars@ moveVars;
		if (this.get("moveVars", @moveVars))
		{
			if(this.hasTag("frozen")){
				SetKnocked(this, 5);
			} else 
			if(Temp < 10){
				moveVars.jumpFactor *= 0.5f;
				moveVars.walkFactor *= 0.5f;
			} else {
				moveVars.jumpFactor *= 0.8f;
				moveVars.walkFactor *= 0.7f;
			}
		}
	}
	
	if(Temp > 100){
		this.server_Hit(this, this.getPosition(), Vec2f(0,0), 0.25f, Hitters::fire, true);
		this.sub_s8("temperature",1);
		Temp--;
	}
	
	if(getGameTime() % 15 == 0){
	
		if(hasEye(this, EyeType::Seared) > 0)addAbility(this,Ability::FireWave);
	
		int TempGoal = 50;
		
		if(this.hasBlob("lantern",1))TempGoal += 10;
		
		CBlob@[] blobsInRadius;	   
		if (this.getMap().getBlobsInRadius(this.getPosition(), 48.0f, @blobsInRadius)) 
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob@ b = blobsInRadius[i];
				if(b.getName() == "fireplace"){
					TempGoal = Maths::Min(75,TempGoal+25);
				}
			}
		}
		
		if(this.isInWater())TempGoal = Maths::Max(25,TempGoal-25);
		else {
			if(getBlobByName("rain") !is null)
			if (!getMap().rayCastSolidNoBlobs(Vec2f(this.getPosition().x, 0), this.getPosition()))
			{
				TempGoal = Maths::Max(25,TempGoal-25);
			}
		}
		
		if(this.hasTag("burning"))TempGoal = 100;
		
		if(TempGoal < 1)TempGoal = 1;
		
		if(Temp <= 0){
			if(!this.hasTag("frozen")){
				this.Tag("frozen");
				if(isServer())this.Sync("frozen",true);
				this.set_s8("temperature",-10);
			}
			if(isServer())this.server_Hit(this,this.getPosition(),Vec2f(0,0),0.25f,Hitters::drown,true);
		} else {
			if(this.hasTag("frozen")){
				this.Untag("frozen");
				if(isServer())this.Sync("frozen",true);
			}
		}
		
		if(Temp > 110){
			this.set_s8("temperature",110);
		}
		
		if(Temp > TempGoal){
			this.sub_s8("temperature",1);
		}
		if(Temp < TempGoal){
			this.add_s8("temperature",1);
		}
		
		if(isServer() && Temp != TempGoal)this.Sync("temperature",true);
	}
}

void onRender(CSprite@ this)
{
	if (g_videorecording)
		return;

	CBlob@ blob = this.getBlob();
	
	if(getLocalPlayerBlob() !is blob)return;

	int Temp = blob.get_s8("temperature");
	if(Temp < 0)Temp = 0;
	if(Temp > 100)Temp = 100;
	int TempBar = Temp/5;
	
	GUI::DrawIcon("TempGauge_strip24.png", TempBar, Vec2f(9,24), Vec2f(30*2,getDriver().getScreenHeight()-70*2));
	
	if(getGameTime() % 30 < 15){
		if(Temp < 35)GUI::DrawIcon("TempGauge_strip24.png", 21, Vec2f(9,24), Vec2f(30*2,getDriver().getScreenHeight()-70*2));
		if(Temp > 75)GUI::DrawIcon("TempGauge_strip24.png", 22, Vec2f(9,24), Vec2f(30*2,getDriver().getScreenHeight()-70*2));
	}
}