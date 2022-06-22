void DrawDarkBar(CBlob@ this, Vec2f tl)
{
	f32 darkness = this.get_s16("darkness");
	
	if(darkness >= 50 || this.hasTag("darkness_sworn") || this.hasTag("had_darkness")){
		GUI::DrawIcon("DarkBarHUD.png", 1, Vec2f(80,21), tl);
		
		for (int i = 0; i < Maths::Ceil(darkness/20.0f); i++)GUI::DrawIcon("DarkBarHUD.png", 2, Vec2f(80,21), tl+Vec2f(i*2,0));
		
		GUI::DrawIcon("DarkBarHUD.png", 3, Vec2f(80,21), tl);
		
		GUI::SetFont("menu");
		string disp = "" + darkness;
		GUI::DrawText(disp, tl+Vec2f(2,12), SColor(255, 19, 13, 29));
		
		this.Tag("had_darkness");
	}
}