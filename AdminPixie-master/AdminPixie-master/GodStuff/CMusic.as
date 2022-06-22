#include "godCommon.as"

class CMusic : CEffectModeBase
{
	string getType() override {return "music";}

	void init(CBlob@ blob) override
	{
		CEffectModeBase::init(blob);
		blob.AddScript("Bucket_Music.as");
		blob.getSprite().AddScript("Bucket_Display.as");

		client_AddToChat("Music playing was derived from Terracraft's version of Musical Bucket", SColor(255,255,255,255));
	}

	void onTick() override
	{
		blob.getShape().SetStatic(true);
		CEffectModeBase::onTick();
	}

	void processCommand(u8 cmd, CBitStream@ params) override
	{
		if(cmd == blob.getCommandID("setMode"))
		{
			blob.getShape().SetStatic(false);
		}

		if(cmd == blob.getCommandID("_note"))
		{
//                                           this was done with mutiple files because I couldn't get frames to work
			CParticle@ p = ParticleAnimated("MusicNote"+(XORRandom(3) + 1)+".png", blob.getPosition(), getRandomVelocity(0,1,360), 0,1, RenderStyle::Style::normal,0,Vec2f(10,10),0,0,true);
			if (p !is null)
			{
				p.fastcollision = true;
				p.gravity = Vec2f(0,0);
				p.bounce = 1;
				p.lighting = false;
				p.timeout = 90;
			}
		}

		CEffectModeBase::processCommand(cmd, @params);
	}

	void render(CSprite@ sprite, f32 scale) override
	{
		
		if(getLocalPlayer() is blob.getPlayer())
		{
			int width = 93 * 2;
			int height = 15;
			int teamNum = blob.getTeamNum();

			Vec2f mainPos = Vec2f(getScreenWidth() - width * scale - 20, 20  + (blob.getConfig() == "pixie" ? 88 * scale : 0));

			GUI::DrawIcon("MusicGUI.png",0, Vec2f(width,height), mainPos, scale, teamNum);
		}
		
		CEffectModeBase::render(@sprite,scale);
	}
}