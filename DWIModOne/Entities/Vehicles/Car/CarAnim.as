void onInit(CSprite@ this)
{
	ReloadSprites(this);
}

void ReloadSprites(CSprite@ sprite)
{
	string filename = sprite.getFilename();

	sprite.SetZ(-25.0f);
	sprite.ReloadSprite(filename);

	// (re)init arm and cage sprites
	sprite.RemoveSpriteLayer("rollcage");
	CSpriteLayer@ rollcage = sprite.addSpriteLayer("rollcage", filename, 48, 32);

	if (rollcage !is null)
	{
		Animation@ anim = rollcage.addAnimation("default", 0, false);
		anim.AddFrame(3);
		rollcage.SetOffset(Vec2f(0, -8.0f));
		rollcage.SetRelativeZ(-0.01f);
	}
}
