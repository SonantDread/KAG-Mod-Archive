#include "FighterMovesetCommon.as"
#include "ThrowCommon.as"

// Fighter attack logic

void onInit(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();

	this.addCommandID("start move");
}

void onTick(CBlob@ this)
{
	SSKFighterVars@ fighterVars;
	if (!this.get("fighterVars", @fighterVars))
	{
		return;
	}

	updateMoveAnimLogic(this, fighterVars);
}

void updateMoveAnimLogic(CBlob@ this, SSKFighterVars@ fighterVars)
{
	u16 hitstunTime = fighterVars.hitstunTime;
	u16 tumbleTime = fighterVars.tumbleTime;
	u16 dazeTime = fighterVars.dazeTime;
	if (this.isAttached() || hitstunTime > 0 || tumbleTime > 0 || dazeTime > 0)
	{
		return;
	}

	bool inMoveAnimation = fighterVars.inMoveAnimation;

	CSprite@ sprite = this.getSprite();

	MoveAnimation@ moveAnim = fighterVars.currMoveAnimation;
	if (inMoveAnimation)
	{
		if (moveAnim != null)
		{
			updateCommonMoves(this, fighterVars, moveAnim);
		}
	}
	else
	{
		// throw / activate
		if (this.isKeyJustPressed(key_action1))	//this.isKeyJustPressed(key_action3)
		{
			CBlob @carryBlob = this.getCarriedBlob();
			if (carryBlob !is null)
			{
				if (!carryBlob.hasTag("player") && !carryBlob.hasTag("usable"))
				{
					if (carryBlob.hasTag("activated") || !carryBlob.hasTag("activatable"))
					{
						client_SendThrowCommand(this);
						startMove(this, fighterVars, MoveTypes::THROW);
					}
					else
					{
						client_SendThrowOrActivateCommand(this);
					}
				}
			}
			else	// check if any nearby items to grab
			{
				if (getNet().isServer())
				{
					bool dontHitMore = false;

					CBlob@[]@ pickupBlobs;
					this.get("pickup blobs", @pickupBlobs);
					pickupBlobs.clear();
					CBlob@[] blobsInRadius;

					Vec2f thisPos = this.getPosition();
					f32 grabOffset = 4.0f;
					Vec2f grabCenterPos = thisPos + (this.isFacingLeft() ? Vec2f(-grabOffset,0) : Vec2f(grabOffset,0));
					if (this.getMap().getBlobsInRadius(grabCenterPos, this.getRadius() + 6.0f, @blobsInRadius))
					{
						for (uint i = 0; i < blobsInRadius.length; i++)
						{
							CBlob@ b = blobsInRadius[i];

							if (b is this)
								continue;

							if (b !is null) // blob
							{
								if ( b.hasTag("heavy weight") && !this.isOnGround() )
									continue;

								if (!dontHitMore)
								{
									Vec2f velocity = b.getPosition() - thisPos;
									if (b.canBePickedUp(this) && !b.hasTag("material") && !b.getShape().isStatic())
									{
										SyncGrabEvent(this);

										this.server_Pickup(b);
										dontHitMore = true;

										startMove(this, fighterVars, MoveTypes::GRAB_ITEM, true);
									}
								}
							}
						}
					}
				}
			}
		}

		// make sure fighter isn't in the middle of another action/attack
		if (fighterVars.inMiscAttack)
		{
			fighterVars.inMiscAttack = false;
			return;
		}

		// drop / pickup / throw
		if (this.isKeyPressed(key_pickup))
		{
			CBlob @carryBlob = this.getCarriedBlob();

			if (this.isAttached()) // default drop from attachment
			{
				int count = this.getAttachmentPointCount();

				for (int i = 0; i < count; i++)
				{
					AttachmentPoint @ap = this.getAttachmentPoint(i);

					if (ap.getOccupied() !is null && ap.name != "PICKUP" && ap.name != "CONTAINER")
					{
						CBitStream params;
						params.write_netid(ap.getOccupied().getNetworkID());
						this.SendCommand(this.getCommandID("detach"), params);
						this.set_bool("release click", false);
						break;
					}
				}
			}
			else if (carryBlob !is null && !carryBlob.hasTag("custom drop") && (!carryBlob.hasTag("temp this") || carryBlob.getName() == "ladder"))
			{
				if (this.isKeyJustPressed(key_pickup))
				{
					this.clear("pickup thiss");
					client_SendThrowCommand(this);

					this.set_bool("release click", false);

					startMove(this, fighterVars, MoveTypes::THROW);
				}
			}
			else
			{
				this.set_bool("release click", true);

				startMove(this, fighterVars, MoveTypes::GRAB_ATTACK);
			}
		}

		// shielding
		if (this.isKeyPressed(key_action3) && this.isOnGround())
		{
			f32 shieldHealth = fighterVars.shieldHealth;
			if (shieldHealth > 0)
				startMove(this, fighterVars, MoveTypes::SHIELD);
		}

		// Fire Strike!!!
		if (this.isKeyPressed(key_up) && this.isKeyJustPressed(key_action2))
		{
			if (!fighterVars.fallSpecial)
			{
				// carrying heavy
				bool carryingHeavy = false;
				CBlob@ carryBlob = this.getCarriedBlob();
				if (carryBlob !is null)
				{
					if (carryBlob.hasTag("heavy weight") || carryBlob.hasTag("player"))
					{
						carryingHeavy = true;
					}
				}

				if (!carryingHeavy)
				{
					startMove(this, fighterVars, MoveTypes::UP_SPECIAL);
				}
			}
		}

		// Down Special Attack
		if (this.isKeyPressed(key_down) && this.isKeyJustPressed(key_action2))
		{	
			// carrying heavy
			bool carryingHeavy = false;
			CBlob@ carryBlob = this.getCarriedBlob();
			if (carryBlob !is null)
			{
				if (carryBlob.hasTag("heavy weight") || carryBlob.hasTag("player"))
				{
					carryingHeavy = true;
				}
			}

			if (!carryingHeavy)
			{
				startMove(this, fighterVars, MoveTypes::DOWN_SPECIAL);
			}
		}
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("start move"))
	{
		u8 moveType = params.read_u8();
		bool sendMoveFromServer = params.read_bool();

		if (!canSendMove(this) || (sendMoveFromServer && getNet().isClient()))
		{
			MoveAnimation[]@ fighterMoveset;
			if (getRules().get("fighterMoveset"+this.get_u8("fighterClass"), @fighterMoveset))
			{
				int moveIndex = getMoveIndexByType(fighterMoveset, moveType);
				if (moveIndex >= 0)
				{
					MoveAnimation@ moveAnim = fighterMoveset[moveIndex];
					handleStartMove(this, moveAnim);
				}
			}
		}
	}
}

void startMove(CBlob@ this, SSKFighterVars@ fighterVars, u8 moveType, bool sendMoveFromServer = false)
{
	if ( canSendMove(this) || (sendMoveFromServer && getNet().isServer()) )	//getNet().isServer()
	{
		MoveAnimation[]@ fighterMoveset;
		if (getRules().get("fighterMoveset"+this.get_u8("fighterClass"), @fighterMoveset))
		{
			int moveIndex = getMoveIndexByType(fighterMoveset, moveType);
			if (moveIndex >= 0)
			{
				MoveAnimation@ moveAnim = fighterMoveset[moveIndex];
				handleStartMove(this, moveAnim);
			}

			CBitStream bt;
			bt.write_u8( moveType );
			bt.write_bool( sendMoveFromServer );
			this.SendCommand(this.getCommandID("start move"), bt);
		}
	}
}

bool canSendMove(CBlob@ this)
{
	return (this.isMyPlayer() || this.getPlayer() is null || this.getPlayer().isBot());
}