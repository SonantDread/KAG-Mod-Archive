#include "FighterMovesetCommon.as"
#include "FighterVarsCommon.as"

// Fighter shield logic

void onInit(CBlob@ this)
{
	addShieldSpriteLayer(this);
}

void onTick(CBlob@ this)
{
	SSKFighterVars@ fighterVars;
	if (!this.get("fighterVars", @fighterVars))
	{
		return;
	}

	u16 hitstunTime = fighterVars.hitstunTime;
	f32 shieldHealth = fighterVars.shieldHealth;

	if (this.isAttached())
	{
		fighterVars.isShielding = false;
	}

	// shield health update logic
	if (hitstunTime <= 0)
	{
		if (fighterVars.isShielding)
		{
			if (shieldHealth >= SHIELD_DEPLETION)
				fighterVars.shieldHealth -= SHIELD_DEPLETION;
			else
				fighterVars.shieldHealth = 0;
		}
		else
		{
			if (shieldHealth <= MAX_SHIELD_HEALTH - SHIELD_REGENERATION)
				fighterVars.shieldHealth += SHIELD_REGENERATION;
			else
				fighterVars.shieldHealth = MAX_SHIELD_HEALTH;
		}
	}

	// shield break logic
	if (getNet().isServer())
	{
		if (fighterVars.shieldHealth <= 0 && fighterVars.dazeTime <= 0)
		{
			SendShieldBreak(this);
		}
	}

	// shield rendering
	CSprite@ sprite = this.getSprite();

	CSpriteLayer@ shieldBubble = sprite.getSpriteLayer("shield bubble");
	CSpriteLayer@ shieldShine = sprite.getSpriteLayer("shield shine");

	if (fighterVars.isShielding)
	{
		f32 shieldScale = this.get_f32("shieldScale");
		f32 MIN_SHIELD_SCALE = 0.25f;
		f32 MAX_SHIELD_SCALE = 0.75f;
		f32 scaleFactor = shieldHealth/MAX_SHIELD_HEALTH;
		f32 adjustedScale = MIN_SHIELD_SCALE + scaleFactor*(MAX_SHIELD_SCALE-MIN_SHIELD_SCALE);
		Vec2f scaleVec = Vec2f(adjustedScale, adjustedScale);
		Vec2f unScaleVec = Vec2f(1.0f/shieldScale, 1.0f/shieldScale);

		if (shieldBubble !is null)
		{
			shieldBubble.SetVisible(true);

			if (hitstunTime > 0)
			{
				shieldBubble.SetFrame(1 + XORRandom(4));
				shieldBubble.SetFacingLeft(XORRandom(2) == 0 ? true : false);
			}
			else
			{
				shieldBubble.SetFrame(0);
			}

			//shieldBubble.SetHUD(true); // enables transparency in sprite layer
			
			shieldBubble.ScaleBy(unScaleVec);	// ResetTransform() does not reset scale back to 1.0f
			shieldBubble.ScaleBy(scaleVec);
		}

		if (shieldShine !is null)
		{
			if (hitstunTime <= 0)
			{
				shieldShine.SetVisible(true);
			}
			else
			{
				shieldShine.SetVisible(false);
			}

			//shieldShine.SetHUD(true); // enables transparency in sprite layer
			
			shieldShine.ScaleBy(unScaleVec);	// ResetTransform() does not reset scale back to 1.0f
			shieldShine.ScaleBy(scaleVec);

			shieldShine.RotateBy(this.isFacingLeft() ? 25.0f : -25.0f, Vec2f(0,0));
		}

		this.set_f32("shieldScale", adjustedScale);
	}
	else
	{
		if (shieldBubble !is null)
		{
			shieldBubble.SetVisible(false);
		}

		if (shieldShine !is null)
		{
			shieldShine.SetVisible(false);
		}
	}
}

void onChangeTeam(CBlob@ this, const int oldTeam)
{
	addShieldSpriteLayer(this);
}

void addShieldSpriteLayer(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();

	// add or reset shield bubble sprite layer
	sprite.RemoveSpriteLayer("shield bubble");
	CSpriteLayer@ shieldBubble = sprite.addSpriteLayer("shield bubble", "ShieldBubble.png", 48, 48);
	if (shieldBubble !is null)
	{
		shieldBubble.SetRelativeZ(10.0f);
		shieldBubble.SetVisible(false);
	}	

	sprite.RemoveSpriteLayer("shield shine");
	CSpriteLayer@ shieldShine = sprite.addSpriteLayer("shield shine", "ShieldShine.png", 48, 48);
	if (shieldShine !is null)
	{
		shieldShine.SetRelativeZ(20.0f);
		shieldShine.SetVisible(false);
	}

	sprite.RemoveSpriteLayer("shield wave");
	CSpriteLayer@ shieldWave = sprite.addSpriteLayer("shield wave", "ShieldWave.png", 64, 64);
	if (shieldWave !is null)
	{
		Animation@ defaultAnim = shieldWave.addAnimation("default", 2, false);
		defaultAnim.AddFrame(12);

		Animation@ waveOutAnim = shieldWave.addAnimation("wave out", 2, false);
		waveOutAnim.AddFrame(0);
		waveOutAnim.AddFrame(1);
		waveOutAnim.AddFrame(2);
		waveOutAnim.AddFrame(3);
		waveOutAnim.AddFrame(4);
		waveOutAnim.AddFrame(5);
		waveOutAnim.AddFrame(6);
		waveOutAnim.AddFrame(7);
		waveOutAnim.AddFrame(8);
		waveOutAnim.AddFrame(9);
		waveOutAnim.AddFrame(10);
		waveOutAnim.AddFrame(11);
		waveOutAnim.AddFrame(12);

		Animation@ waveInAnim = shieldWave.addAnimation("wave in", 1, false);
		waveInAnim.AddFrame(11);
		waveInAnim.AddFrame(9);
		waveInAnim.AddFrame(7);
		waveInAnim.AddFrame(5);
		waveInAnim.AddFrame(3);
		waveInAnim.AddFrame(1);
		waveInAnim.AddFrame(0);
		waveInAnim.AddFrame(12);

		Animation@ waveBreakAnim = shieldWave.addAnimation("break", 5, false);
		waveBreakAnim.AddFrame(13);
		waveBreakAnim.AddFrame(14);
		waveBreakAnim.AddFrame(15);
		waveBreakAnim.AddFrame(16);
		waveBreakAnim.AddFrame(17);

		shieldWave.ScaleBy(Vec2f(0.6f,0.6f));
		shieldWave.SetRelativeZ(5.0f);
		shieldWave.SetVisible(true);
	}

	// reset shield scale
	this.set_f32("shieldScale", 1.0f);
}