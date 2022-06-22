// Butcher logic

#include "ButcherCommon.as"
#include "ThrowCommon.as"
#include "KnockedCommon.as"
#include "Hitters.as"
#include "RunnerCommon.as"
#include "ShieldCommon.as";
#include "Help.as";
#include "MakeDustParticle.as";
#include "Requirements.as"
#include "FireParticle.as";
#include "MakeFood.as";
#include "SplashWater.as";// but only getBombForce()
#include "ProductionCommon.as";// for MakeFood.as

void onInit(CBlob@ this)
{
	ButcherInfo butch;
	this.set("butcherInfo", @butch);

	this.set_f32("gib health", -1.5f);
	this.Tag("player");
	this.Tag("flesh");

	//centered on arrows
	//this.set_Vec2f("inventory offset", Vec2f(0.0f, 122.0f));
	//centered on items
	this.set_Vec2f("inventory offset", Vec2f(0.0f, 0.0f));

	//no spinning
	this.getShape().SetRotationsAllowed(false);
	this.getShape().getConsts().net_threshold_multiplier = 0.5f;

	this.addCommandID("knife");
	this.addCommandID("throwmeat");
	this.addCommandID("oil");

	AddIconToken("$KitchenKnife$", "LWBHelpIcons.png", Vec2f(16, 16), 14);

	SetHelp(this, "help self action", "butcher", getTranslatedString("$KitchenKnife$Butch corpse$LMB$"), "", 3);

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (player !is null)
	{
		player.SetScoreboardVars("LWBScoreboardIcons.png", 13, Vec2f(16, 16));
	}
}

void onTick(CBlob@ this)
{
	ButcherInfo@ butch;
	if (!this.get("butcherInfo", @butch))
	{
		return;
	}

	if (isKnocked(this) || this.isInInventory())
	{
		this.getSprite().SetEmitSoundPaused(true);
		return;
	}

	CSprite@ sprite = this.getSprite();
	bool knife = sprite.isAnimation("kitchen_knife");
	bool throwing = sprite.isAnimation("throw");

	if (knife || throwing)
	{
		RunnerMoveVars@ moveVars;
		if (this.get("moveVars", @moveVars))
		{
			moveVars.walkFactor = 0.8f;
			moveVars.jumpFactor = 0.6f;
		}
		this.Tag("prevent crouch");
	}

	if(knife && sprite.isFrameIndex(2) && !(sprite.getFrameIndex() < 2))// like builder's pickaxe
	{
		Sound::Play("/SwordSlash", this.getPosition());
		if (this.isMyPlayer()) this.SendCommand(this.getCommandID("knife"));
	}
	else if(throwing && sprite.isFrameIndex(2) && !(sprite.getFrameIndex() < 2))// like builder's pickaxe
	{
		if (this.getBlobCount("mat_poisonmeats") > 0)
		{
			Sound::Play("/ArgLong", this.getPosition());
			if (this.isMyPlayer())
			{
				Vec2f offset(this.isFacingLeft() ? 2 : -2, -2);
				Vec2f rockPos = this.getPosition() + offset;
				Vec2f rockVel = this.getAimPos() - rockPos;
				CBitStream params;
				params.write_Vec2f(rockPos);
				params.write_Vec2f(rockVel);
				this.SendCommand(this.getCommandID("throwmeat"), params);
			}
		}
		else
		{
			if (this.isMyPlayer())
			{
				Sound::Play("/NoAmmo");
			}
		}
	}

	if(this.isMyPlayer())
	{
		// space

		if (this.isKeyJustPressed(key_action3))
		{
			if (hasItem(this, "mat_cookingoils"))
			{
				CBitStream params;
				Vec2f aimLength = this.getAimPos() - this.getPosition();
				aimLength.y /= -1;
				Vec2f sprayPos = Vec2f_lengthdir(Maths::Min(30.0f, (aimLength.getLength())), aimLength.Angle()) + this.getPosition();
				params.write_Vec2f(sprayPos);
				this.SendCommand(this.getCommandID("oil"), params);
			}
			else
			{
				client_SendThrowOrActivateCommand(this);
			}
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("knife"))
	{
		if (!getNet().isServer())
		{
			return;
		}

		ButcherInfo@ info;
		if (!this.get("butcherInfo", @info))
		{
			return;
		}

		Vec2f blobPos = this.getPosition();
		Vec2f vel = this.getVelocity();
		Vec2f vec;
		this.getAimDirection(vec);
		Vec2f thinghy(1, 0);
		f32 aimangle = -(vec.Angle());
		if (aimangle < 0.0f)
		{
			aimangle += 360.0f;
		}
		thinghy.RotateBy(aimangle);
		Vec2f pos = blobPos - thinghy * 6.0f + vel + Vec2f(0, -2);
		vel.Normalize();

		f32 radius = this.getRadius();
		CMap@ map = this.getMap();
		bool dontHitMore = false;
		bool dontHitMoreMap = false;
		bool dontHitMoreLogs = false;

		//get the actual aim angle
		f32 exact_aimangle = (this.getAimPos() - blobPos).Angle();

		// this gathers HitInfo objects which contain blob or tile hit information
		HitInfo@[] hitInfos;
		if (map.getHitInfosFromArc(pos, aimangle, 90.0f, radius + 10.0f, this, @hitInfos))
		{
			//HitInfo objects are sorted, first come closest hits
			for (uint i = 0; i < hitInfos.length; i++)
			{
				HitInfo@ hi = hitInfos[i];
				CBlob@ b = hi.blob;
				if (b !is null && !dontHitMore) // blob
				{
					if (b.hasTag("ignore sword")) continue;

					//big things block attacks
					const bool large = b.hasTag("blocks sword") && !b.isAttached() && b.isCollidable();

					if (!canHit(this, b))
					{
						// no TK
						if (large)
							dontHitMore = true;

						continue;
					}

					f32 temp_damage = 1.0f;

					if (!dontHitMore && (b.getName() != "log" || !dontHitMoreLogs))
					{
						Vec2f velocity = b.getPosition() - pos;

						if (b.getName() == "log")
						{
							temp_damage /= 3;
							dontHitMoreLogs = true;
							CBlob@ wood = server_CreateBlobNoInit("mat_wood");
							if (wood !is null)
							{
								int quantity = Maths::Ceil(float(temp_damage) * 20.0f);
								int max_quantity = b.getHealth() / 0.024f; // initial log health / max mats
								
								quantity = Maths::Max(
									Maths::Min(quantity, max_quantity),
									0
								);

								wood.Tag('custom quantity');
								wood.Init();
								wood.setPosition(hi.hitpos);
								wood.server_SetQuantity(quantity);
							}

						}

						this.server_Hit(b, hi.hitpos, velocity, temp_damage, Hitters::sword, true);  // server_Hit() is server-side only

						// end hitting if we hit something solid, don't if its flesh
						if (large)
						{
							dontHitMore = true;
						}
					}
				}
				else  // hitmap
					if (!dontHitMoreMap)
					{
						bool ground = map.isTileGround(hi.tile);
						bool dirt_stone = map.isTileStone(hi.tile);
						bool gold = map.isTileGold(hi.tile);
						bool wood = map.isTileWood(hi.tile);
						if (ground || wood || dirt_stone || gold)
						{
							Vec2f tpos = map.getTileWorldPosition(hi.tileOffset) + Vec2f(4, 4);
							Vec2f offset = (tpos - blobPos);
							f32 tileangle = offset.Angle();
							f32 dif = Maths::Abs(exact_aimangle - tileangle);
							if (dif > 180)
								dif -= 360;
							if (dif < -180)
								dif += 360;

							dif = Maths::Abs(dif);
							//print("dif: "+dif);

							if (dif < 20.0f)
							{
								//detect corner

								int check_x = -(offset.x > 0 ? -1 : 1);
								int check_y = -(offset.y > 0 ? -1 : 1);
								if (map.isTileSolid(hi.hitpos - Vec2f(map.tilesize * check_x, 0)) &&
								        map.isTileSolid(hi.hitpos - Vec2f(0, map.tilesize * check_y)))
									continue;

								bool canhit = true; //default true if not jab
								info.tileDestructionLimiter++;
								canhit = ((info.tileDestructionLimiter % ((wood || dirt_stone) ? 3 : 2)) == 0);

								//dont dig through no build zones
								canhit = canhit && map.getSectorAtPosition(tpos, "no build") is null;

								dontHitMoreMap = true;
								if (canhit)
								{
									map.server_DestroyTile(hi.hitpos, 0.1f, this);
									info.tileDestructionLimiter = 0;
									if (gold)
									{
										// Note: 0.1f damage doesn't harvest anything I guess
										// This puts it in inventory - include MaterialCommon
										//Material::fromTile(this, hi.tile, 1.f);

										CBlob@ ore = server_CreateBlobNoInit("mat_gold");
										if (ore !is null)
										{
											ore.Tag('custom quantity');
		     								ore.Init();
		     								ore.setPosition(hi.hitpos);
		     								ore.server_SetQuantity(4);
		     							}
									}
								}
							}
						}
					}
			}
		}
	}
	else if (cmd == this.getCommandID("throwmeat"))
	{
		Vec2f meatPos;
		if (!params.saferead_Vec2f(meatPos)) return;
		Vec2f meatVel;
		if (!params.saferead_Vec2f(meatVel)) return;

		if (!getNet().isServer() || this.getBlobCount("mat_poisonmeats") < 0)
			return;
		CBlob@ meat = server_CreateBlobNoInit("poisonmeat");
		if (meat !is null)
		{
			meat.SetDamageOwnerPlayer(this.getPlayer());
			meat.Init();
		
			meat.IgnoreCollisionWhileOverlapped(this);
			meat.server_setTeamNum(this.getTeamNum());
			meat.setPosition(meatPos);
			meatVel.Normalize();
			meatVel *= 10.0f;
			meat.setVelocity(meatVel);
			this.TakeBlob("mat_poisonmeats", 1);
		}
	}
	else if (cmd == this.getCommandID("oil"))
	{
		Vec2f sprayPos;
		if(params !is null && !params.saferead_Vec2f(sprayPos)) return;
		const uint splash_halfwidth = 2;
		const uint splash_halfheight = 2;
		CMap@ map = this.getMap();
		Sound::Play("splat.ogg", this.getPosition(), 3.0f);
		if (map !is null)
		{
			bool is_server = getNet().isServer();

			for (int x_step = -splash_halfwidth; x_step < splash_halfwidth; ++x_step)
			{
				for (int y_step = -splash_halfheight; y_step < splash_halfheight; ++y_step)
				{
					Vec2f wpos = sprayPos + Vec2f(x_step * map.tilesize, y_step * map.tilesize);
					Vec2f outpos;

					//extinguish the fire or destroy tile at this pos
					if (is_server)
					{
						map.server_setFireWorldspace(wpos, true);
					}

					//make a splash!
					makeFireParticle(wpos, 0);
				}
			}

			const f32 radius = Maths::Max(splash_halfwidth * map.tilesize + map.tilesize, splash_halfheight * map.tilesize + map.tilesize);

			Vec2f offset = Vec2f(splash_halfwidth * map.tilesize + map.tilesize, splash_halfheight * map.tilesize + map.tilesize);
			Vec2f tl = sprayPos - offset * 0.5f;
			Vec2f br = sprayPos + offset * 0.5f;
			CBlob@[] blobs;
			map.getBlobsInBox(tl, br, @blobs);
			for (uint i = 0; i < blobs.length; i++)
			{
				CBlob@ blob = blobs[i];

				bool hitHard = blob.getTeamNum() != this.getTeamNum();

				Vec2f hit_blob_pos = blob.getPosition();
				f32 scale;
				Vec2f bombforce = getBombForce(this, radius, hit_blob_pos, sprayPos, blob.getMass(), scale);
				string blobName = blob.getName();
				if(!blob.isInWater())
				{
					if(blobName == "steak" || blobName == "fishy")
					{
						Sound::Play("Cooked.ogg", this.getPosition(), 3.0f);
						if (is_server)
						{
							cookFood(blob);
							if(blobName == "steak") server_MakeFood(blob.getPosition(), "Cooked Steak", 0);
						}
					}
					else if (hitHard && is_server)
					{
						this.server_Hit(blob, sprayPos, bombforce, 0.25f, Hitters::fire, true);
					}
				}
			}
		}

		CSprite@ sprite = this.getSprite();
		sprite.SetAnimation("oil");
		if(getNet().isServer())
			TakeItem(this, "mat_cookingoils");
	}
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	if (customData == Hitters::sword)
	{
		if (damage > 0.0f && hitBlob.hasTag("flesh") && hitBlob.hasTag("dead") && !hitBlob.hasTag("butched") && hitBlob.getHealth() - hitBlob.get_f32("gib health") <= 0.0f)
		{
			//hitBlob.Tag("butched");//safety, no double butch
			Vec2f blobPos = hitBlob.getPosition();

			CBlob@ meat = server_CreateBlobNoInit("mat_poisonmeats");
			if (meat !is null)
			{
				meat.Tag('custom quantity');
	     		meat.Init();
	     		meat.setPosition(blobPos);
	     		meat.server_SetQuantity(2);
	     	}
			CBlob@ steak = server_CreateBlob("steak");
			if (steak !is null)
			{
	     		steak.setPosition(blobPos);
	     	}
		}

		if (blockAttack(hitBlob, velocity, 0.0f))
		{
			this.getSprite().PlaySound("/Stun", 1.0f, this.getSexNum() == 0 ? 1.0f : 1.5f);
			setKnocked(this, 20, true);
		}
	}
	if (customData == Hitters::fire && hitBlob.getName() == "keg" && !hitBlob.hasTag("exploding") && !(this.getTeamNum() == hitBlob.getTeamNum()))
	{
		hitBlob.SendCommand(hitBlob.getCommandID("activate"));
	}
}

// Blame Fuzzle.
// as same as knight
bool canHit(CBlob@ this, CBlob@ b)
{

	if (b.hasTag("invincible") || b.getName() == "steak")
		return false;

	// Don't hit temp blobs and items carried by teammates.
	if (b.isAttached())
	{

		CBlob@ carrier = b.getCarriedBlob();

		if (carrier !is null)
			if (carrier.hasTag("player")
			        && (this.getTeamNum() == carrier.getTeamNum() || b.hasTag("temp blob")))
				return false;

	}

	if (b.hasTag("dead"))
		return true;

	return b.getTeamNum() != this.getTeamNum();

}

//ball management

bool hasItem(CBlob@ this, const string &in name)
{
	CBitStream reqs, missing;
	AddRequirement(reqs, "blob", name, "Oil Bottles", 1);
	CInventory@ inv = this.getInventory();

	if (inv !is null)
	{
		return hasRequirements(inv, reqs, missing);
	}
	else
	{
		warn("our inventory was null! ButcherLogic.as");
	}

	return false;
}

void TakeItem(CBlob@ this, const string &in name)
{
	CBlob@ carried = this.getCarriedBlob();
	if (carried !is null)
	{
		if (carried.getName() == name)
		{
			carried.server_Die();
			return;
		}
	}

	CBitStream reqs, missing;
	AddRequirement(reqs, "blob", name, "Smoke Balls", 1);
	CInventory@ inv = this.getInventory();

	if (inv !is null)
	{
		if (hasRequirements(inv, reqs, missing))
		{
			server_TakeRequirements(inv, reqs);
		}
		else
		{
			warn("took a ball even though we dont have one! ButcherLogic.as");
		}
	}
	else
	{
		warn("our inventory was null! ButcherLogic.as");
	}
}

void onAddToInventory(CBlob@ this, CBlob@ blob)
{
	if (blob.getName() == "mat_poisonmeats")
		SetHelp(this, "help self action2", "butcher", "$mat_poisonmeats$ Throw poisonous meat $RMB$", "", 3);
	if (blob.getName() == "mat_cookingoils")
		SetHelp(this, "help inventory", "butcher", "$mat_cookingoils$Burn/Cook steak or fish $KEY_SPACE$", "", 3);
}