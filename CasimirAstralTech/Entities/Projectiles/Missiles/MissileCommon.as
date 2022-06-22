//Missile Include

#include "SpaceshipGlobal.as"

const string targetNetIDString = "target_net_ID";
const string hasTargetTicksString = "has_target_ticks";

namespace AAMissileParams
{
	// movement general
	const ::f32 main_engine_force = 0.35f;
	const ::f32 secondary_engine_force = 0.18f;
	const ::f32 rcs_force = 0.15f;
	const ::f32 ship_turn_speed = 12.0f; // degrees per tick, 0 = instant (30 ticks a second)
	const ::f32 max_speed = 18.0f; // 0 = infinite speed

	//targeting
	const ::u32 lose_target_ticks = 90; //ticks until targetblob is null again
}

class MissileInfo
{
	bool forward_thrust;
	bool backward_thrust;
	bool port_thrust;
	bool starboard_thrust;

	// movement general
	f32 main_engine_force;
	f32 secondary_engine_force;
	f32 rcs_force;
	f32 ship_turn_speed; // degrees per tick, 0 = instant (30 ticks a second)
	f32 max_speed; // 0 = infinite speed

	//targeting
	CBlob@ target_blob;
	u32 lose_target_ticks; //ticks until targetblob is null again

	MissileInfo()
	{
		forward_thrust = false;
		backward_thrust = false;
		port_thrust = false;
		starboard_thrust = false;

		//movement general
		main_engine_force = 3.0f;
		secondary_engine_force = 2.0f;
		rcs_force = 1.0f;
		ship_turn_speed = 1.0f;
		max_speed = 200.0f;

		//targeting
		lose_target_ticks = 30;
	}
};

void turnOffAllThrust( MissileInfo@ missile )
{
	missile.forward_thrust = false;
	missile.backward_thrust = false;
	missile.port_thrust = false;
	missile.starboard_thrust = false;
}