//Auto-mining quarry
//sells a bundle of stone on a cooldown

#include "Costs.as"
#include "GenericButtonCommon.as"

// Balance
// For reference, one person's resupply is 100 stone / 67 seconds (2.3 resupplies)
const int stone_amount_dropped = 100; // stone dropped
const int max_time = 180; // Seconds to produce stone

// For variable efficiency depending on where quarry was built
const bool faster_when_forward = true;
const int min_time = 75; // Seconds to produce stone at (/past) center map

const int tick_rate = 30;

void onInit(CSprite@ this)
{
	CSpriteLayer@ belt = this.addSpriteLayer("belt", "QuarryBelt.png", 32, 32);
	if (belt !is null)
	{
		//default anim
		{
			Animation@ anim = belt.addAnimation("default", 0, true);
			int[] frames = {
				0, 1, 2, 3,
				4, 5, 6, 7,
				8, 9, 10, 11,
				12, 13
			};
			anim.AddFrames(frames);
		}
		//belt setup
		belt.SetOffset(Vec2f(-7.0f, -4.0f));
		belt.SetRelativeZ(1);
		belt.SetVisible(true);
	}

	CSpriteLayer@ stone = this.addSpriteLayer("stone", "Quarry.png", 16, 16);
	if (stone !is null)
	{
		stone.SetOffset(Vec2f(8.0f, -1.0f));
		stone.SetVisible(false);
		stone.SetFrameIndex(5);
	}

	this.SetEmitSound("/Quarry.ogg");
	this.SetEmitSoundPaused(false);
}

void onInit(CBlob@ this)
{
	InitCosts();

	//building properties
	this.set_TileType("background tile", CMap::tile_castle_back);
	this.getSprite().SetZ(-50);
	this.getShape().getConsts().mapCollisions = false;
	this.getCurrentScript().tickFrequency = tick_rate;

	//gold building properties
	this.set_s32("gold building amount", 50);

	//quarry properties
	if (faster_when_forward)
	{
		SetQuarryEfficiency(this);

		// for the display text
		this.Tag("new_quarry");
	}
	else
	{
		this.set_u16("cooldown", max_time);
		// math will use max_time, so this is just for animation
		this.set_u8("efficiency", 50);
	}

	// progress starts at 50% when built
	this.set_u16("ticks_worked", this.get_u16("cooldown") * 30 / 2);
	this.set_bool("working", true);

	//commands
	this.addCommandID("collect stone");
}

void onTick(CBlob@ this)
{
	bool client = getNet().isClient();
	if (this.get_bool("working"))
	{
		// If we've worked long enough to make stone, stop working and wait for button press
		if (this.get_u16("ticks_worked") >= this.get_u16("cooldown") * 30)
		{
			this.set_bool("working", false);
			this.set_u16("ticks_worked", 0);
			if (client)
			{
				CSprite@ sprite = this.getSprite();
				UpdateStoneLayer(sprite);
				sprite.SetEmitSoundPaused(true);
				// Speed up tickrate temporarily to make sure the belt stops quickly
				this.getCurrentScript().tickFrequency = 10;
			}
			if (getNet().isServer())
			{
				SetQuarryLantern(this, true);
			}
		}
		else
		{
			this.add_u16("ticks_worked", this.getCurrentScript().tickFrequency);
		}
	}

	if (client)
	{
		AnimateBelt(this);
	}
}

void onDie(CBlob@ this)
{
	if (getNet().isServer() && not this.get_bool("working"))
	{
		// Drop the stone that was there so it isn't wasted
		SpawnOre(this);

		// Kill the light, free lanterns OP
		SetQuarryLantern(this, false);
	}
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	
	// If efficiency is enabled, shows efficiency message when quarry is built
	if (faster_when_forward && blob.hasTag("new_quarry"))
	{
		SColor text_color = color_white;
		u16 quarry_age = blob.getTickSinceCreated();
		if (quarry_age > 30)
		{
			text_color.setAlpha(Maths::Max(0, 255 - 3 * (quarry_age - 30)));
		}

		if (text_color.getAlpha() == 0)
		{
			blob.Untag("new_quarry");
		}
		else
		{
			GUI::SetFont("menu");
			Vec2f shift = Vec2f(0, -30.0 - quarry_age);
			GUI::DrawTextCentered("{COOLDOWN} seconds".replace(
								  "{COOLDOWN}", "" + blob.get_u16("cooldown")),
								  blob.getScreenPos() + shift,
								  text_color);
			shift.y += 15;
			GUI::DrawTextCentered("({EFFICIENCY}% towards mid)".replace(
								   "{EFFICIENCY}", "" + blob.get_u8("efficiency")),
								  blob.getScreenPos() + shift,
								  text_color);
		}	

	}

	// Draw progress bar
	if (blob.get_bool("working"))
	{
		CBlob@ localBlob = getLocalPlayerBlob();
		if (localBlob is null
			|| localBlob.getTeamNum() != blob.getTeamNum() // enemies can't see
			|| not localBlob.isKeyPressed(key_use)) // have to press E
		{
			return;
		}

		if ((getControls().getMouseWorldPos() - blob.getPosition()).getLength()
			< (blob.getRadius() * 0.95f)) // mouse over blob
		{
			Vec2f pos = blob.getScreenPos();
			Vec2f upperleft = Vec2f(pos.x - 30.f, pos.y - 15.f);
			Vec2f lowerright = Vec2f(pos.x + 30.f, pos.y);
			float prog = (1.0 * blob.get_u16("ticks_worked") / (blob.get_u16("cooldown")*30.0));
			GUI::DrawProgressBar(upperleft, lowerright, prog);
			GUI::SetFont("menu");
			GUI::DrawTextCentered("{SEC} sec".replace(
				 				  "{SEC}", "" + (blob.get_u16("cooldown") + 1
				 				  	 		    - (blob.get_u16("ticks_worked") / 30))),
					              Vec2f(blob.getScreenPos() + Vec2f(0, -20.0)),
					              color_white);
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!canSeeButtons(this, caller)) return;

	CBitStream params;
	params.write_u16(caller.getNetworkID());

	if (not this.get_bool("working") and this.isOverlapping(caller))
	{
		CButton@ button = caller.CreateGenericButton("$COIN$", Vec2f(-4.0f, 0.0f), this,
													 this.getCommandID("collect stone"), 
													 "" + CTFCosts::dispense_stone 
													 	+ " coins", params);
		if (button !is null)
		{
			button.deleteAfterClick = true;
			button.SetEnabled(caller.getPlayer().getCoins() >= CTFCosts::dispense_stone);
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("collect stone"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller is null) return;

		if (getNet().isServer())
		{
			// Make sure it's actually ready
			if (not this.get_bool("working"))
			{
				// Sell the stone
				CPlayer@ player = caller.getPlayer();
				if (player !is null)
				{
					player.server_setCoins(player.getCoins() - CTFCosts::dispense_stone);
				}
				this.set_bool("working", true);
				SpawnOre(this);

				// Turn off the light
				SetQuarryLantern(this, false);
			}
		}

		if (getNet().isClient())
		{
			if (caller.isMyPlayer())
			{
				this.getSprite().PlaySound("/ChaChing.ogg");
			}

			this.set_bool("working", true);

			CSprite@ sprite = this.getSprite();
			UpdateStoneLayer(sprite);
			sprite.SetEmitSoundPaused(false);
			AnimateBelt(this);
		}
	}
}

void SetQuarryEfficiency(CBlob@ this)
{
	// Sets efficiency property based on how far forward quarry was placed
	u8 efficiency;
	f32 xpos = this.getPosition().x;

	CBlob@[] spawns;
	if (not (getRespawnBlobs(spawns, this.getTeamNum())))
	{
		efficiency = 50;
		this.set_u16("cooldown", max_time);
		return;
	}
	Vec2f my_tent = spawns[0].getPosition();

	CBlob@[] enemy_spawns;
	if (not (getRespawnBlobs(enemy_spawns, this.getTeamNum() == 1 ? 0 : 1)))
	{
		efficiency = 50;
		this.set_u16("cooldown", max_time);
		return;
	}
	Vec2f enemy_tent = enemy_spawns[0].getPosition();

	f32 center_x = (my_tent.x + enemy_tent.x) / 2;
	bool enemy_is_to_right = my_tent.x < enemy_tent.x;

	// Quarry behind tent (cowards!)
	if (enemy_is_to_right ? xpos < my_tent.x : xpos > my_tent.x)
	{
		efficiency = 0;
		this.set_u16("cooldown", max_time);
	}
	// Not to center map yet
	else if (enemy_is_to_right ? xpos < center_x : xpos > center_x)
	{
		u8 percent_to_mid =  100 - (Maths::Abs(xpos - center_x)
									/ Maths::Abs(my_tent.x - center_x)) * 100;
		this.set_u16("cooldown", max_time - (percent_to_mid / 100.0f) * (max_time - min_time));
		efficiency = percent_to_mid;
	}
	else // Past center map
	{
		this.set_u16("cooldown", min_time);
		efficiency = 100;
	}

	this.set_u8("efficiency", efficiency);
}

void SpawnOre(CBlob@ this)
{
	CBlob@ ore = server_CreateBlobNoInit("mat_stone");

	if (ore is null) return;

	ore.Tag('custom quantity');
	ore.Init();
	ore.setPosition(this.getPosition() + Vec2f(-8.0f, 0.0f));
	ore.server_SetQuantity(stone_amount_dropped);
}

void UpdateStoneLayer(CSprite@ this)
{
	CSpriteLayer@ layer = this.getSpriteLayer("stone");
	CBlob@ blob = this.getBlob();

	if (layer is null) return;

	if (this.getBlob().get_bool("working"))
	{
		layer.SetVisible(false);
	}
	else // Not working
	{
		layer.SetVisible(true);
	}
}

void AnimateBelt(CBlob@ this)
{
	//safely fetch the animation to modify
	CSprite@ sprite = this.getSprite();
	if (sprite is null) return;
	CSpriteLayer@ belt = sprite.getSpriteLayer("belt");
	if (belt is null) return;
	Animation@ anim = belt.getAnimation("default");
	if (anim is null) return;

	if (this.get_bool("working"))
	{
		// slowly start animation
		if (anim.time == 0) anim.time = 8;
		// max speed increases with efficiency
		if (anim.time > 7 - 5 * (this.get_u8("efficiency")/100.0))
		{
			anim.time--;
		}
	}
	else
	{
		//(not tossing stone)
		if (anim.frame < 2 || anim.frame > 8)
		{
			if (anim.time != 0)
			{
				this.getCurrentScript().tickFrequency = tick_rate;
			}
			anim.time = 0;
		}
	}
}

void SetQuarryLantern(CBlob@ this, bool lit)
{
	if (not getNet().isServer())
	{
		return;
	}

	if (lit) // make sure there's a lantern
	{
		// Attach a lantern *ding*
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("LANTERN");
		if (point.getOccupied() is null)
		{
			CBlob@ lantern = server_CreateBlob("lantern");
			if (lantern !is null)
			{
				lantern.server_setTeamNum(this.getTeamNum());
				lantern.getShape().getConsts().collidable = false;
				this.server_AttachTo(lantern, "LANTERN");
				this.set_u16("lantern id", lantern.getNetworkID());
				Sound::Play("SparkleShort.ogg", lantern.getPosition());
			}
		}
	}
	else
	{
		if (this.exists("lantern id"))
		{
			CBlob@ lantern = getBlobByNetworkID(this.get_u16("lantern id"));
			if (lantern !is null)
			{
				lantern.server_Die();
			}
		}
	}
}
