// gem_healer.as

void onInit(CBlob@ this)
{
    this.Tag("builder always hit");
}

void onTick(CBlob@ this)
{
	int quant = this.getInventory().getCount("gem");
	
	if(quant > 0){
		
		f32 Radius = 160.0f;
		
		if(getGameTime() % 60 == 0){
			CBlob@[] blobs;
			getMap().getBlobsInRadius(this.getPosition(), Radius, @blobs);
			
			for(int i = 0;i < blobs.length;i++){
				CBlob @blob = blobs[i];
				Vec2f pos = blob.getPosition();
				
				if(blob.hasTag("player") && (blob.getTeamNum() == this.getTeamNum() || this.getTeamNum() >= 20)){
				
					if(isServer())blob.server_Heal(quant);
				}
			}
		}

		Vec2f vec = Vec2f(Radius,0);
		for(int r = 0; r < 360; r += 45){
			vec.RotateBy(r+XORRandom(90));
			Vec2f dir = this.getPosition()-(this.getPosition()+vec);
			dir.Normalize();
			Vec2f pos = this.getPosition()+dir*XORRandom(Radius)+Vec2f(XORRandom(3)-1,XORRandom(3)-1);
			ParticleAnimated("HealParticle2.png", pos, Vec2f(XORRandom(5)-2,XORRandom(5))*0.25, 0, 0.5f, 5, -0.1f, true);
			pos = this.getPosition()+dir*Radius+Vec2f(XORRandom(3)-1,XORRandom(3)-1);
			ParticleAnimated("HealParticle2.png", pos, Vec2f(XORRandom(5)-2,XORRandom(5))*0.25, 0, 0.5f, 5, -0.1f, true);
		}
	}
}

void onRender( CSprite@ this ){

	GUI::DrawIcon("GemHealer.png", 5, Vec2f(24,24), getDriver().getScreenPosFromWorldPos(this.getBlob().getPosition()+Vec2f(-12,-12)), getCamera().targetDistance, SColor(255.0f*(float(Maths::Abs((getGameTime() % 60) - 30))/30.0f),255,255,255));

}