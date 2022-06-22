//SuperArcher Include

namespace SuperArcherParams
{
	enum Aim
	{
		not_aiming = 0,
		readying,
		charging,
		fired,
		no_arrows,
		stabbing,
		legolas_ready,
		legolas_charging
	}

	const ::s32 ready_time = 11;

	const ::s32 shoot_period = 30;
	const ::s32 shoot_period_1 = SuperArcherParams::shoot_period / 3;
	const ::s32 shoot_period_2 = 2 * SuperArcherParams::shoot_period / 3;
	const ::s32 legolas_period = SuperArcherParams::shoot_period * 3;

	const ::s32 fired_time = 7;
	const ::f32 shoot_max_vel = 17.59f;

	const ::s32 legolas_charge_time = 5;
	const ::s32 legolas_arrows_count = 1;
	const ::s32 legolas_arrows_volley = 3;
	const ::s32 legolas_arrows_deviation = 5;
	const ::s32 legolas_time = 60;
}

//TODO: move vars into superArcher params namespace
const f32 superArcher_grapple_length = 1.0f;
const f32 superArcher_grapple_slack = 1.0f;
const f32 superArcher_grapple_throw_speed = 1.0f;

const f32 superArcher_grapple_force = 0.1f;
const f32 superArcher_grapple_accel_limit = 0.5f;
const f32 superArcher_grapple_stiffness = 0.01f;

namespace ArrowType
{
	enum type
	{
		normal = 0,
		water,
		fire,
		bomb,
		count
	};
}

shared class SuperArcherInfo
{
	s8 charge_time;
	u8 charge_state;
	bool has_arrow;
	u8 stab_delay;
	u8 fletch_cooldown;
	u8 arrow_type;

	u8 legolas_arrows;
	u8 legolas_time;

	bool grappling;
	u16 grapple_id;
	f32 grapple_ratio;
	f32 cache_angle;
	Vec2f grapple_pos;
	Vec2f grapple_vel;

	SuperArcherInfo()
	{
		charge_time = 1;
		charge_state = 0;
		has_arrow = false;
		stab_delay = 0;
		fletch_cooldown = 0;
		arrow_type = ArrowType::normal;
		grappling = false;
	}
};

const string grapple_sync_cmd = "grapple sync";

void SyncGrapple(CBlob@ this)
{
	SuperArcherInfo@ superArcher;
	if (!this.get("superArcherInfo", @superArcher)) { return; }

	CBitStream bt;
	bt.write_bool(superArcher.grappling);

	if (superArcher.grappling)
	{
		bt.write_u16(superArcher.grapple_id);
		bt.write_u8(u8(superArcher.grapple_ratio * 20));
		bt.write_Vec2f(superArcher.grapple_pos);
		bt.write_Vec2f(superArcher.grapple_vel);
	}

	this.SendCommand(this.getCommandID(grapple_sync_cmd), bt);
}

//TODO: saferead
void HandleGrapple(CBlob@ this, CBitStream@ bt, bool apply)
{
	SuperArcherInfo@ superArcher;
	if (!this.get("superArcherInfo", @superArcher)) { return; }

	bool grappling;
	u16 grapple_id;
	f32 grapple_ratio;
	Vec2f grapple_pos;
	Vec2f grapple_vel;

	grappling = bt.read_bool();

	if (grappling)
	{
		grapple_id = bt.read_u16();
		u8 temp = bt.read_u8();
		grapple_ratio = temp / 250.0f;
		grapple_pos = bt.read_Vec2f();
		grapple_vel = bt.read_Vec2f();
	}

	if (apply)
	{
		superArcher.grappling = grappling;
		if (superArcher.grappling)
		{
			superArcher.grapple_id = grapple_id;
			superArcher.grapple_ratio = grapple_ratio;
			superArcher.grapple_pos = grapple_pos;
			superArcher.grapple_vel = grapple_vel;
		}
	}
}

const string[] arrowTypeNames = { "mat_arrows",
                                  "mat_waterarrows",
                                  "mat_firearrows",
                                  "mat_bombarrows"
                                };

const string[] arrowNames = { "Devil's Tool",
                              "ZA WARUDO",
                              "HELL arrows",
                              "DESTRUCTION arrow"
                            };

const string[] arrowIcons = { "$Arrow$",
                              "$WaterArrow$",
                              "$FireArrow$",
                              "$BombArrow$"
                            };


bool hasArrows(CBlob@ this)
{
	SuperArcherInfo@ superArcher;
	if (!this.get("superArcherInfo", @superArcher))
	{
		return false;
	}
	if (superArcher.arrow_type >= 0 && superArcher.arrow_type < arrowTypeNames.length)
	{
		return this.getBlobCount(arrowTypeNames[superArcher.arrow_type]) > 0;
	}
	return false;
}

bool hasArrows(CBlob@ this, u8 arrowType)
{
	return this.getBlobCount(arrowTypeNames[arrowType]) > 0;
}

void SetArrowType(CBlob@ this, const u8 type)
{
	SuperArcherInfo@ superArcher;
	if (!this.get("superArcherInfo", @superArcher))
	{
		return;
	}
	superArcher.arrow_type = type;
}

u8 getArrowType(CBlob@ this)
{
	SuperArcherInfo@ superArcher;
	if (!this.get("superArcherInfo", @superArcher))
	{
		return 0;
	}
	return superArcher.arrow_type;
}
