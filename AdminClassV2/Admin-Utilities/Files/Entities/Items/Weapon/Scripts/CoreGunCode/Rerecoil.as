void Rerecoil(CBlob@ this, CBlob@ holder, f32 myrerecoil)
{
	CControls@ controls = getControls();
	Driver@ driver = getDriver();
	
	f32 len = (controls.getMouseScreenPos() - driver.getScreenCenterPos()).Length();
	f32 angle = (controls.getMouseScreenPos() - driver.getScreenCenterPos()).Angle() - ((myrerecoil * (this.isFacingLeft() ? 1.0f : -1.0f)));
	
	Vec2f rerecoil = Vec2f(Maths::Cos(angle * 3.14f/180.0f), -Maths::Sin(angle * 3.14f/180.0f));
	controls.setMousePosition((driver.getScreenDimensions() / 2.0f) + (rerecoil * len));
}
