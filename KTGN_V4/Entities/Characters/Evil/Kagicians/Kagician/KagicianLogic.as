// Kagician logic

#include "Hitters.as";
#include "MagicalHitters.as";
#include "Knocked.as";
#include "ThrowCommon.as";
#include "RunnerCommon.as";
#include "MagicCommon.as";

void onInit(CBlob@ this)
{

	this.Tag("player");
	this.Tag("flesh");


	CShape@ shape = this.getShape();


	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
	if(getNet().isServer())
	{
		string[] scripts;
		scripts.push_back("Gravity");
		scripts.push_back("Bounce");
		scripts.push_back("Harm");
		this.set("scripts", scripts);
	}
	this.set_u16("charge", 0); //The amount of time the spell has been charged.
	this.set_u8("firestyle", 0); //Style of shooting spells.
	this.set_u8("stylepower", 0);//Strength of fire style's attack.
	this.set_u8("abilityindex", 255);
	this.getSprite().SetEmitSound("/WaterSparkle.ogg");
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if(player !is null)
	{
		player.SetScoreboardVars("ScoreboardIcons.png", 1, Vec2f(16, 16));
	}
}



void onTick(CBlob@ this)
{
	RunnerMoveVars@ moveVars;
	if (!this.get("moveVars", @moveVars))
	{
		return;
	}
	moveVars.walkFactor *= 0.7f;
	if(this.isInInventory())
		return;

	const bool ismyplayer = this.isMyPlayer();
	if(ismyplayer && getHUD().hasMenus())
	{
		return;
	}
	// activate/throw
	if(ismyplayer)
	{

		if(this.isKeyJustPressed(key_action3))
		{
			CBlob@ carried = this.getCarriedBlob();
			if(carried is null || !carried.hasTag("temp blob"))
			{
				client_SendThrowOrActivateCommand(this);
			}
		}
	}
	CSprite@ sprite = this.getSprite();
	Vec2f vel = this.getVelocity();
	int charge = this.get_u16("charge");
	u8 firestyle = this.get_u8("firestyle");
	u8 stylepower = this.get_u8("stylepower");
	
	bool action2 = this.isKeyPressed(key_action2);
	bool action1 = this.isKeyPressed(key_action1);
	if(this.isKeyJustPressed(key_action2) || this.isKeyJustPressed(key_action1))
	{
		sprite.SetEmitSoundPaused(false);
	}
	if(action2)
	{
		charge = Maths::Min(getChargeMax(firestyle, stylepower), charge + 1);
		sprite.SetEmitSoundSpeed((charge / 200.0f));
	}
	else if(action1)
	{
		charge = Maths::Min(getCasterThreshold(stylepower) + 1, charge + 1);
		sprite.SetEmitSoundSpeed((charge / 400.0f));
	}
	
	//meddling with wizardry. Moved to function because Caster
	if(this.isKeyJustReleased(key_action2))
	{
		doSpellStuff(this, this.getAimPos());
		charge = 0;
	}

	if(this.isKeyJustReleased(key_action1)) //cast Caster
	{
		sprite.SetEmitSoundPaused(true);
		if(canCastCaster(this))
		{
			if(getNet().isServer())
			{
				CBlob@ caster = server_CreateBlob("caster", this.getTeamNum(), this.getPosition());
				if(caster !is null)
				{
					string[] scripts;
					this.get("scripts", scripts);
					caster.set("scripts", scripts);
					caster.set_u8("stylepower", this.get_u8("stylepower"));
					caster.set_u8("firestyle", this.get_u8("firestyle"));
					caster.set_Vec2f("aimpos", this.getAimPos());
					caster.SetFacingLeft(this.isFacingLeft());
				}
			}
		}
		charge = 0;
	}
	this.set_u16("charge", charge);	
}

void onHit(CBlob@ this) //Reset charge if user was pressing key_action1.
{
	if(this.isKeyPressed(key_action1))
	{
		this.set_u16("charge", 0);
	}
}