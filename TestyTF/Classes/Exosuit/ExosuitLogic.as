// Knight logic

#include "ThrowCommon.as"
#include "KnightCommon.as";
#include "RunnerCommon.as";
#include "Hitters.as";
#include "ShieldCommon.as";
#include "Knocked.as"
#include "Help.as";
#include "Requirements.as"
#include "ParticleSparks.as";

//attacks limited to the one time per-actor before reset.

void knight_actorlimit_setup(CBlob@ this)
{
	u16[] networkIDs;
	this.set("LimitedActors", networkIDs);
}

bool knight_has_hit_actor(CBlob@ this, CBlob@ actor)
{
	u16[]@ networkIDs;
	this.get("LimitedActors", @networkIDs);
	return networkIDs.find(actor.getNetworkID()) >= 0;
}

u32 knight_hit_actor_count(CBlob@ this)
{
	u16[]@ networkIDs;
	this.get("LimitedActors", @networkIDs);
	return networkIDs.length;
}

void knight_add_actor_limit(CBlob@ this, CBlob@ actor)
{
	this.push("LimitedActors", actor.getNetworkID());
}

void knight_clear_actor_limits(CBlob@ this)
{
	this.clear("LimitedActors");
}

void onInit(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();

	KnightInfo knight;

	knight.state = KnightStates::normal;
	knight.swordTimer = 0;
	knight.slideTime = 0;
	knight.doubleslash = false;
	knight.tileDestructionLimiter = 0;

	this.set("knightInfo", @knight);

	this.set_f32("gib health", -3.0f);
	knight_actorlimit_setup(this);
	this.getShape().SetRotationsAllowed(false);
	this.getShape().getConsts().net_threshold_multiplier = 0.5f;
	this.Tag("player");
	this.Tag("flesh");
	this.Tag("gas immune");

	this.set_u32("next warp", 0);
	// this.set_u32("last hit", 0);
	
	this.set_u8("override head", 100);

	this.set_Vec2f("inventory offset", Vec2f(0.0f, 0.0f));

	this.getSprite().PlaySound("Exosuit_Equip.ogg", 1, 1);
	
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	
	this.SetLight(false);
	this.SetLightRadius(64.0f);
	this.SetLightColor(SColor(255, 10, 250, 200));
}

void onInit(CSprite@ this)
{
	this.RemoveSpriteLayer("ghost");
	CSpriteLayer@ ghost = this.addSpriteLayer("ghost", "Exosuit_Ghost.png", 64, 24, this.getBlob().getTeamNum(), 0);
	
	if (ghost !is null)
	{
		Animation@ anim = ghost.addAnimation("default", 0, false);
		anim.AddFrame(0);
		ghost.SetRelativeZ(-1.0f);
		ghost.SetVisible(false);
	}
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (player !is null)
	{
		player.SetScoreboardVars("ScoreboardIcons.png", 3, Vec2f(16, 16));
	}
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	u32 time = getGameTime();
	
	if ((blob.get_u32("next warp") - 59) < time)
	{
		CSpriteLayer@ ghost = this.getSpriteLayer("ghost");
	
		this.setRenderStyle(RenderStyle::normal);
		ghost.SetOffset(Vec2f(this.isFacingLeft() ? 16 : 48, 0.0f));
		ghost.SetVisible(false);
	}
	
	if (blob.isKeyPressed(key_action1) && !blob.hasTag("noLMB")) this.setRenderStyle(RenderStyle::outline_front);
	
	// this.setRenderStyle(blob.get_u32("last hit") + 10 > time ? RenderStyle::additive : RenderStyle::normal);
	
	// this.setRenderStyle(blob.isKeyPressed(key_action1) && !blob.hasTag("noLMB") ? RenderStyle::shadow : RenderStyle::normal);
}

void onTick(CBlob@ this)
{
	u8 knocked = getKnocked(this);
	
	if (this.isInInventory())
		return;

	RunnerMoveVars@ moveVars;
	if (!this.get("moveVars", @moveVars))
	{
		return;
	}

	u32 time = getGameTime();
	
	Vec2f pos = this.getPosition();
	Vec2f aimpos = this.getAimPos();
	const bool inair = (!this.isOnGround() && !this.isOnLadder());

	CMap@ map = getMap();
	
	bool pressed_a1 = this.isKeyPressed(key_action1) && !this.hasTag("noLMB");
	bool pressed_a2 = this.isKeyPressed(key_action2);
	bool walking = (this.isKeyPressed(key_left) || this.isKeyPressed(key_right));

	const bool myplayer = this.isMyPlayer();

	moveVars.walkFactor *= 1.25f;
	moveVars.jumpFactor *= 1.50f;
		
	this.SetLight(pressed_a1);
		
	// if (getNet().isServer() && time % 90 == 0) this.server_Heal(0.25f); // OP
		
	if (knocked > 0)
	{
		pressed_a1 = false;
		pressed_a2 = false;
		walking = false;
		
		return;
	}
		
	if (!pressed_a1 && pressed_a2 && this.get_u32("next warp") < time)
	{		
		Vec2f aimDir = pos - aimpos;
		aimDir.Normalize();

		HitInfo@[] hitInfos;
		Vec2f hitPos;
		
		map.rayCastSolid(pos, pos + (aimDir * -96.0f), hitPos);

		f32 length = (hitPos - pos).Length();
		f32 angle =	-aimDir.Angle() + 180;
	
		this.setPosition(hitPos);
		this.setVelocity(-aimDir * (length / 12.0f));
	
		if(getNet().isClient())
		{
			this.getSprite().PlaySound("Exosuit_Teleport.ogg", 1.0f, 1.0f);
			this.getSprite().setRenderStyle(RenderStyle::additive);
			
			DrawGhost(this.getSprite(), 0, pos, length / 96, angle, this.isFacingLeft());
			ShakeScreen(64, 32, this.getPosition());	
		}
		
		if(getNet().isServer())
		{
			map.server_DestroyTile(hitPos, 32.0f);
			map.server_DestroyTile(hitPos + aimDir * -8, 16.0f);
			map.server_DestroyTile(hitPos + aimDir * -16, 8.0f);
			map.server_DestroyTile(hitPos + aimDir * -24, 4.0f);
			map.server_DestroyTile(hitPos + aimDir * -32, 2.0f);
			map.server_DestroyTile(hitPos + aimDir * -40, 1.0f);
			
			if (map.getHitInfosFromRay(pos, angle, length, this, @hitInfos))
			{
				for (int i = 0; i < hitInfos.length; i++)
				{
					if (hitInfos[i].blob !is null)
					{	
						CBlob@ blob = hitInfos[i].blob;
						
						if ((blob.isCollidable() || blob.hasTag("flesh")) && blob.getTeamNum() != this.getTeamNum()) 
						{
							this.server_Hit(blob, hitInfos[i].hitpos, Vec2f(0,0), 4.0f, Hitters::crush);
							SetKnocked(blob, length * 0.5f);
							blob.setVelocity(blob.getVelocity() + (-aimDir * (length / 12.0f)));
						}
					}
				}
			}
		}
		
		this.set_u32("next warp", time + 60);
	}
}

void DrawGhost(CSprite@ this, u8 index, Vec2f startPos, f32 length, f32 angle, bool flip)
{
	CSpriteLayer@ ghost =this.getSpriteLayer("ghost");
	
	ghost.SetVisible(true);
	
	ghost.ResetTransform();
	ghost.ScaleBy(Vec2f(length, 1.0f));
	ghost.TranslateBy(Vec2f(length * 16.0f, 0.0f));
	ghost.RotateBy(angle + (flip ? 180 : 0), Vec2f());
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	CPlayer@ player = this.getPlayer();
	
	if (this.hasTag("invincible") || (player !is null && player.freeze)) 
	{
		return 0;
	}
	
	switch (customData)
	{
		case Hitters::suicide:
			damage *= 10.0f;
			break;
	
		case Hitters::stab:
		case Hitters::sword:
		case Hitters::fall:
			damage *= 0.1f;
			break;
	
		case Hitters::explosion:
		case Hitters::keg:
		case Hitters::mine:
		case Hitters::mine_special:
		case Hitters::bomb:
			damage *= 0.7f;
			this.getSprite().PlaySound("Exosuit_Hit.ogg", 1, 1);			
			break;
	
	
		case Hitters::arrow:
			damage *= 0.45f; 
			break;

		case Hitters::burn:
		case Hitters::fire:
		case Hitters::spikes:
		case Hitters::bite:
		case Hitters::builder:
			damage *= 0.00f;
			break;
			
		default:
			damage *= 0.60f;
			this.getSprite().PlaySound("Exosuit_Hit.ogg", 1, 1);		
			break;
	}

	if (hitterBlob !is null && hitterBlob !is this && this.isKeyPressed(key_action1) && !this.hasTag("noLMB"))
	{
		if (getNet().isServer())
		{
			this.server_Hit(hitterBlob, worldPoint, velocity, damage * 0.95f, customData);
		}

		hitterBlob.setVelocity(hitterBlob.getVelocity() - velocity * damage * 2);
		this.setVelocity(this.getVelocity() + velocity * damage);
		
		SetKnocked(hitterBlob, 20.0f * damage);
		SetKnocked(this, 10.0f * damage);
	
		if (getNet().isClient())
		{
			this.getSprite().PlaySound("Exosuit_Deflect.ogg", 1, 1);
			if (this.isMyPlayer()) SetScreenFlash(100, 255, 255, 255);			
		}

		return 0.05f;
	}
	else
	{
		return damage;
	}
}

void onDie(CBlob@ this)
{
	if (getNet().isServer()) server_CreateBlob("exosuititem", this.getTeamNum(), this.getPosition());
}
