void Recoil(CBlob@ this, CBlob@ holder, f32 myrecoil)
{
	CControls@ controls = getControls();
	Driver@ driver = getDriver();
	
	f32 len = (controls.getMouseScreenPos() - driver.getScreenCenterPos()).Length();
	f32 angle = (controls.getMouseScreenPos() - driver.getScreenCenterPos()).Angle() - ((myrecoil * (this.isFacingLeft() ? 1.0f : -1.0f)));
	
	Vec2f recoil = Vec2f(Maths::Cos(angle * 3.14f/180.0f), -Maths::Sin(angle * 3.14f/180.0f));
	controls.setMousePosition((driver.getScreenDimensions() / 2.0f) + (recoil * len));
}