// Knockback on hit - put before any damaging things but after any scalers
#include "FighterVarsCommon.as"
#include "SSKRunnerCommon.as"
#include "SSKShieldCommon.as";
#include "Hitters.as"

void onInit(CBlob@ this)
{
	this.getCurrentScript().removeIfTag = "dead";
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (this.hasTag("invincible")) //pass through if invince
		return 0;

	if (customData == Hitters::fall)
		return damage;

	SSKFighterVars@ fighterVars;
	if (!this.get("fighterVars", @fighterVars))
	{
		return damage;
	}

	// player got hit, so disable shield if somehow damage went through
	fighterVars.isShielding = false;

	// reduce grab time of grabber if held player is taking damage
	if (this.isAttached())
	{
		SSKFighterVars@ hitterFighterVars;
		if (hitterBlob.get("fighterVars", @hitterFighterVars)) 
		{
			if (hitterFighterVars.grabTime > 0)
			{
				hitterFighterVars.grabTime += damage*3.0f;
			}
		}
	}

	// drop anything held with a small chance depending on damage (damage/60 chance)
	if (damage > XORRandom(60))
	{
		CBlob @carried = this.getCarriedBlob();
		if (carried !is null)
		{
			carried.server_DetachFromAll();
		}	
	}

	// handle the hard-coded case of collapsed tiles hitting runner
	if (customData == Hitters::crush)
	{
		if (getNet().isServer())
		{
			f32 crushDamage = damage*4.0f;
			fighterVars.damageStatus += crushDamage;
			SyncDamageStatus(this);

			u8 hitstunTime = 8;
			Vec2f tumbleVec = Vec2f(0,1)*crushDamage;
			u16 tumbleTime = Maths::Max(crushDamage*8.0f, fighterVars.tumbleTime);

			CBitStream params;
			params.write_u8( hitstunTime );
			params.write_u16( tumbleTime );	
			params.write_Vec2f( tumbleVec );	
			this.SendCommand(this.getCommandID("sync knockback"), params);
		}
	}

	fighterVars.inMoveAnimation = false;
	fighterVars.fallSpecial = false;

	if (fighterVars.tumbleTime > 0)
	{
		this.getSprite().PlaySound("/Stun", 1.0f, this.getSexNum() == 0 ? 1.0f : 2.0f);
	}

	// do sprite shaking effect
	this.set_u8("shake seq", 0);
	this.set_Vec2f("hit vel", velocity);
	fighterVars.runAutoTickFunc("sprite shake", doSpriteShake, endSpriteShake, false, true, fighterVars.hitstunTime);

	// hide all sprite layers when applicable
	for(int i = 0; i < fighterVars.autoTickFuncs.length(); i++)
	{
		AutoTickFunc@ AutoTickFunc = fighterVars.autoTickFuncs[i];
		if (AutoTickFunc.disableOnHit)
		{
			AutoTickFunc.onDeactivate(this, fighterVars);
			
			// delete AutoTickFunc so it's no longer in our array
			// fighterVars.autoTickFuncs.removeAt(i);
		}
	}

	return damage; //damage not affected
}

// sprite shake effect functions
void doSpriteShake(CBlob@ fighterBlob, SSKFighterVars@ fighterVars)
{
	CSprite@ sprite = fighterBlob.getSprite();

	// calculate offset for the current frame
	Vec2f hitVel = fighterBlob.get_Vec2f("hit vel");
	s8 shakeStartDir = hitVel.x > 0 ? 1 : -1;

	u8 shakeSeq = fighterBlob.get_u8("shake seq");
	f32 offset = 0;
	if (shakeSeq == 0)
		offset = 2.0f*shakeStartDir;
	else if (shakeSeq == 1)
		offset = -2.0f*shakeStartDir;
	else if (shakeSeq == 2)
		offset = 1.0f*shakeStartDir;
	else if (shakeSeq == 3)
		offset = -1.0f*shakeStartDir;
	else if (shakeSeq == 4)
		offset = 0.0f;

	offset *= Maths::Min(fighterVars.hitstunTime*0.5f,8.0f);

	// set shake offset
	Vec2f shakeVec = Vec2f(offset,0).RotateBy(-hitVel.getAngleDegrees());

	sprite.ResetWorldTransform();
	sprite.TranslateAllBy(shakeVec);

	// iterate offset values
	if (shakeSeq < 4)
		shakeSeq++;
	else
		shakeSeq = 0;

	fighterBlob.set_u8("shake seq", shakeSeq);
}

void endSpriteShake(CBlob@ fighterBlob, SSKFighterVars@ fighterVars)
{
	CSprite@ sprite = fighterBlob.getSprite();

	sprite.ResetWorldTransform();
}