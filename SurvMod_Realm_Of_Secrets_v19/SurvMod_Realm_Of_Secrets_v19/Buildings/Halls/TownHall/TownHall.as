// Hall

#include "ClassSelectMenu.as";
#include "StandardRespawnCommand.as";
#include "MigrantCommon.as";
#include "HallCommon.as";
#include "Requirements.as"
#include "AddSectorOnTiles.as"
#include "TeamWipeCheck.as"

#include "Help.as"

int CAPTURE_SECS = 60;

void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 30;

	InitClasses(this);
	InitRespawnCommand(this);
	this.set_TileType("background tile", CMap::tile_castle_back);

	this.Tag("teamlocked tunnel");

	this.set_s32("capture time", 0);
	this.set_s32("respawned time", 0);

	this.set_u8("hall state", HallState::normal);

	this.inventoryButtonPos = Vec2f(-24, 14);
	this.set_Vec2f("travel button pos", Vec2f(0, 7));

	this.Tag("storage");	 // gives spawn mats

	this.getShape().getConsts().waterPasses = false;
	
	this.Tag("bulwark");
}

bool isFlooded(CBlob@ this)
{
	CMap@ map = this.getMap();
	f32 height = this.getHeight();
	f32 width = this.getWidth();

	// 5 tiles checked on both sides
	for (uint i = 0; i < height / map.tilesize - 5 + 1; i++)
	{
		if (map.isInWater(this.getPosition() + Vec2f(width / 2.1f, -height / 2.1f + (i * map.tilesize))))
			return true;
		if (map.isInWater(this.getPosition() + Vec2f(width /-2.1f, -height / 2.1f + (i * map.tilesize))))
			return true;
	}
	return false;
}

void onTick(CBlob@ this)
{
	// capture HALL
	if (getNet().isServer())
	{
		//scratch vars
		const u32 gametime = getGameTime();
		bool raiding = false;

		const bool not_neutral = (this.getTeamNum() <= 10);

		//get relevant blobs
		CBlob@[] blobsInRadius;
		if (this.getMap().getBlobsInRadius(this.getPosition(), RAID_RADIUS, @blobsInRadius))
		{

			Vec2f pos = this.getPosition();

			// first check if enemies nearby
			int attackersCount = 0;
			int friendlyCount = 0;
			int friendlyInProximity = 0;
			int attackerTeam;
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob @b = blobsInRadius[i];
				if (b !is this && b.hasTag("player") && (b.hasTag("alive") || b.hasTag("animated")) && b.getTeamNum() <= 7)
				{
					bool attacker = (b.getTeamNum() != this.getTeamNum());
					if (not_neutral && attacker)
					{
						raiding = true;
					}

					Vec2f bpos = b.getPosition();
					if (bpos.x > pos.x - this.getWidth() / 2.0f && bpos.x < pos.x + this.getWidth() / 2.0f &&
					        bpos.y < pos.y + this.getHeight() / 2.0f && bpos.y > pos.y - this.getHeight() / 2.0f)
					{
						if (attacker)
						{
							attackersCount++;
							attackerTeam = b.getTeamNum();
						}
						else
						{
							friendlyCount++;
						}
					}

					if (!attacker)
					{
						friendlyInProximity++;
					}
				}
			}

			if (raiding) //implies not neutral
			{
				this.set_u8("hall state", HallState::raid);
				this.Tag("under raid");
			}
			//printf("r friendlyCount " + friendlyCount + " " + this.getTeamNum() );

			if (attackersCount > 0 && (friendlyCount == 0 || !not_neutral))
			{

				const int tickFreq = this.getCurrentScript().tickFrequency;
				s32 captureTime = this.get_s32("capture time");

				f32 imbalanceFactor = 1.0f;
				CRules@ rules = getRules();
				if (rules.exists("team 0 count") && rules.exists("team 1 count"))
				{
					const u8 team0 = rules.get_u8("team 0 count");
					const u8 team1 = rules.get_u8("team 1 count");
					if (getNet().isClient() && getNet().isServer() && team0 <= 1)
					{
						imbalanceFactor = 80.0f;	// super fast capture when singleplayer
					}
					else if (this.getTeamNum() == 0 && team1 > 0)
					{
						imbalanceFactor = float(team0) / float(team1);
					}
					else if (team0 > 0)
					{
						imbalanceFactor = float(team1) / float(team0);
					}

				}

				// faster capture under water
				if (getMap().isInWater(this.getPosition() + Vec2f(0.0f, this.getRadius() * 0.66f)))
				{
					imbalanceFactor = 20.0f;
				}

				// faster capture if no friendly around
				if (imbalanceFactor < 20.0f && friendlyInProximity == 0)
				{
					imbalanceFactor = 6.0f;
				}

				captureTime += tickFreq * Maths::Max(1, Maths::Min(Maths::Round(Maths::Sqrt(attackersCount)), 8)) * imbalanceFactor;   // the more attackers the faster
				this.set_s32("capture time", captureTime);

				s32 captureLimit = getCaptureLimit(this);
				if (!not_neutral)   // immediate capture neutral hall
				{
					captureLimit = 0;
				}

				if (captureTime >= captureLimit)
				{
					Capture(this, attackerTeam);
				}
				//			print("captureTime attack " + captureTime + " " + captureLimit );

				this.Sync("capture time", true);
				this.Sync("hall state", true);
				this.Sync("under raid", true);

				return;

				// NOTHING BEYOND THIS POINT

			}
			else
			{
				if (attackersCount > 0)
				{
					return;
				}

				ReturnState(this);
			}
		}
		else
		{
			ReturnState(this);
		}

		// reduce capture if nothing going on

		s32 captureTime = this.get_s32("capture time");
		if (captureTime > 0)
		{
			captureTime -= this.getCurrentScript().tickFrequency;
		}
		else
		{
			captureTime = 0;
		}

		this.set_s32("capture time", captureTime);
		this.Sync("capture time", true);
		this.Sync("hall state", true);
		this.Sync("under raid", true);
	}

	if (getGameTime() % (30 * 60) == 0) {
		this.Sync("hall state", true); 		// HACK: sync flooded state every minute
	}
}

void ReturnState(CBlob@ this)
{
	this.Untag("under raid");

	u8 oldstate = this.get_u8("hall state");

	u8 state = this.get_u16("tickets") > 0 ? HallState::normal : HallState::depleted;
	this.set_u8("hall state", state);
}

int getCaptureLimit(CBlob@ this)
{
	return CAPTURE_SECS * (float(getTicksASecond()) / float(this.getCurrentScript().tickFrequency)) * getTicksASecond();
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!caller.isOverlapping(this))
		return;

	if (caller.getTeamNum() == this.getTeamNum())
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());

		CButton@ button = caller.CreateGenericButton("$change_class$", Vec2f(12, 7), this, SpawnCmd::buildMenu, getTranslatedString("Change class"), params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	onRespawnCommand(this, cmd, params);
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return ((this.getTeamNum() > 50 || 
	        forBlob.getTeamNum() == this.getTeamNum()) && //teammate
	        forBlob.isOverlapping(this));
}

void Capture(CBlob@ this, const int attackerTeam)
{
	if (getNet().isServer())
	{
		// convert all buildings and doors

		int team = this.getTeamNum();
		this.server_setTeamNum(attackerTeam);
		TeamWipeCheck(team);
		
		CBlob@[] blobsInRadius;
		if (this.getMap().getBlobsInRadius(this.getPosition(), BASE_RADIUS / 3.0f, @blobsInRadius))
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob @b = blobsInRadius[i];
				if (b.getTeamNum() == team && (b.hasTag("door") ||
				                                       b.hasTag("building") ||
				                                       b.getName() == "workbench" ||
				                                       b.hasTag("migrant") ||
				                                       b.getName() == "spikes" ||
													   b.getName() == "ladder" ||
				                                       b.getName() == "trap_block"))
				{
					b.server_setTeamNum(attackerTeam);
				}
			}
		}
	}
}

void onChangeTeam(CBlob@ this, const int oldTeam)
{
	if (this.getTeamNum() >= 0 && this.getTeamNum() < 10)
	{
		Sound::Play("/VehicleCapture");
		this.set_s32("capture time", 0);
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if(this.getTeamNum() == 255)return 0.0f;
	return damage;
}

// alert and capture progress bar

void onRender(CSprite@ this)
{
	if (g_videorecording)
		return;

	CBlob@ blob = this.getBlob();
	const s32 captureTime = blob.get_s32("capture time");
	s32 captureLimit = getCaptureLimit(blob);
	Vec2f pos2d = getDriver().getScreenPosFromWorldPos(blob.getPosition() + Vec2f(0.0f, -blob.getHeight()/2));
	if (captureTime > 0 && captureLimit > 0)
	{
		Vec2f posStart = getDriver().getScreenPosFromWorldPos(blob.getPosition() + Vec2f(-40.0f, -blob.getHeight()/2));
		Vec2f posEnd = getDriver().getScreenPosFromWorldPos(blob.getPosition() + Vec2f(40.0f, -blob.getHeight()/2));
		GUI::DrawProgressBar(posStart, posEnd+Vec2f(0.0f,15.0f), float(captureTime) / float(captureLimit));
		GUI::DrawIcon("TownHallIcon.png", 0, Vec2f(24,24), Vec2f(pos2d.x - 24.0f, pos2d.y - 16.0f), 1.0f, blob.getTeamNum());
	}
	if (isUnderRaid(blob))
	{
		if (getGameTime() % 20 > 10)
		{
			GUI::DrawIconByName("$ALERT$", Vec2f(pos2d.x - 32.0f, pos2d.y - 23.0f));
		}
	}
}
