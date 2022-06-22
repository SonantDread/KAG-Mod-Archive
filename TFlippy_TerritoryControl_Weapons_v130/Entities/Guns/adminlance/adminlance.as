#include "GunCommon.as";

void onInit(CBlob@ this)
{
	GunSettings settings = GunSettings();

	//General
	settings.CLIP = 10; //Amount of ammunition in the gun at creation
	settings.TOTAL = 10; //Max amount of ammo that can be in a clip
	settings.FIRE_INTERVAL = 1; //Time in between shots
	settings.RELOAD_TIME = 1; //Time it takes to reload (in ticks)
	settings.AMMO_BLOB = "mat_adminrod"; //Ammunition the gun takes

	//Bullet
	settings.B_PER_SHOT = 25; //Shots per bullet | CHANGE B_SPREAD, otherwise both bullets will come out together
	settings.B_SPREAD = 10; //the higher the value, the more 'uncontrollable' bullets get
	settings.B_GRAV = Vec2f(0, 0.0); //Bullet gravity drop
	settings.B_SPEED = 200; //Bullet speed, STRONGLY AFFECTED/EFFECTS B_GRAV
	settings.B_TTL = 20; //TTL = 'Time To Live' which determines the time the bullet lasts before despawning
	settings.B_DAMAGE = 50.0f; //1 is 1 heart
	settings.B_TYPE = HittersTC::railgun_lance; //Type of bullet the gun shoots | hitter

	//Recoil
	settings.G_RECOIL = -25; //0 is default, adds recoil aiming up
	settings.G_RANDOMX = true; //Should we randomly move x
	settings.G_RANDOMY = false; //Should we randomly move y, it ignores g_recoil
	settings.G_RECOILT = 8; //How long should recoil last, 10 is default, 30 = 1 second (like ticks)
	settings.G_BACK_T = 0; //Should we recoil the arm back time? (aim goes up, then back down with this, if > 0, how long should it last)

	//Sound
	settings.FIRE_SOUND = "ChargeLanceFire.ogg"; //Sound when shooting
	settings.RELOAD_SOUND = "ChargeLanceReload.ogg"; //Sound when reloading

	//Offset
	settings.MUZZLE_OFFSET = Vec2f(-19, 0); //Where the muzzle flash appears

	this.set("gun_settings", @settings);

	//Custom
	this.set_u8("CustomKnock", 6);
	this.set_f32("CustomBulletLength", 20.0f);
	this.set_string("CustomCycle", "ChargeLanceCycle.ogg");
	this.set_string("CustomBullet", "Bullet_Lance.png");
	this.set_string("CustomSoundEmpty", "");
	this.set_string("CustomSoundObject", "Sulphur_Explode.ogg");
        this.set_f32("scope_zoom", 0.35f);
	this.set_u8("CustomKnock", 7);
	this.Tag("CustomSemiAuto");
	this.Tag("medium weight");

	CSprite@ sprite = this.getSprite();

	CSpriteLayer@ laser = sprite.addSpriteLayer("laser", "Laser.png", 32, 1);
	if (laser !is null)
	{
		Animation@ anim = laser.addAnimation("default", 0, false);
		anim.AddFrame(0);
		laser.SetRelativeZ(-1.0f);
		laser.SetVisible(true);
		laser.setRenderStyle(RenderStyle::additive);
		laser.SetOffset(Vec2f(-15.0f, 0.5f));
	}
}

void onTick(CBlob@ this)
{
	if (this.isAttached())
	{
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		if (point is null) return;

		CBlob@ holder = point.getOccupied();
		if (holder is null) return;

		Vec2f hitPos;
		f32 length;
		f32 range = 1100.0f;
		bool flip = this.isFacingLeft();
		f32 angle = getAimAngle(this, holder);
		Vec2f dir = Vec2f((this.isFacingLeft() ? -1 : 1), 0.0f).RotateBy(angle);
		Vec2f startPos = this.getPosition();
		Vec2f endPos = startPos + dir * range;

		bool mapHit = getMap().rayCastSolid(startPos, endPos, hitPos);
		length = (hitPos - startPos).Length();

		CSpriteLayer@ laser = this.getSprite().getSpriteLayer("laser");

		if (laser !is null)
		{
			laser.ResetTransform();
			laser.ScaleBy(Vec2f(length / 32.0f - 0.4, 1.0f));
			laser.TranslateBy(Vec2f(length / 2 - 7, 0.0f));
			laser.RotateBy((flip ? 180 : 0), Vec2f());
			if (holder.isMyPlayer()) laser.SetVisible(true);
		}
	}
	else
	{
		CSpriteLayer@ laser = this.getSprite().getSpriteLayer("laser");

		if (laser !is null)
		{
			laser.SetVisible(false);
		}
	}
}


