#include "Hitters.as";
#include "HittersTC.as";
#include "CommonGun.as";

void onInit(CBlob@ this)
{
	GunInitRaycast(
		this,
		true,				//If true, gun will be fully automatic and players will be able to just hold the fire button
		0.80f,				//Weapon damage / projectile blob name
		400.0f,				//Weapon raycast range
		2,					//Weapon fire delay, in ticks
		40,					//Weapon clip size
		1.00f,				//Ammo usage factor, completely ignore for now
		45,					//Weapon reload time
		false,				//If true, gun will be reloaded like a shotgun
		0,					//For shotguns: Additional delay to reload end
		1,					//Bullet count - for shotguns
		0.8f,				//Bullet Jitter
		"mat_pistolammo",	//Ammo item blob name
		false,				//If true, firing sound will be looped until player stops firing
		SoundInfo("Uzi_Shoot", 0, 1.0f, 1.0f),	//Sound to play when firing
		SoundInfo("SMGReload", 1, 1.0f, 0.8f),	//Sound to play when reloading
		SoundInfo(),						//Sound to play some time after firing
		0,					//Delay for the delayed sound, in ticks
		Vec2f(-7.0f, 1.0f)	//Visual offset for raycast bullets
	);
	
	this.set_u8("gun_hitter", HittersTC::bullet_low_cal);
}

void onTick(CBlob@ this)
{
	GunTick(this);
}