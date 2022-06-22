
#include "Hitters.as";
#include "Knocked.as";
#include "ThrowCommon.as";
#include "RunnerCommon.as";
#include "HumanoidAnimCommon.as";
#include "FireCommon.as";
#include "LimbsCommon.as";
#include "Health.as";
#include "EnchantCommon.as";
#include "TimeCommon.as";

void onInit(CBlob@ this)
{
	this.Tag("player");
	this.Tag("flesh");

	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	shape.getConsts().net_threshold_multiplier = 0.5f;
	
	this.set_u8("sex",XORRandom(2));
	
	this.set_Vec2f("inventory offset", Vec2f(0.0f, 48.0f));
	
	this.set_u8("bag_sprite",0);
	
	this.set_u32("enchants", 0);
	
	this.Tag("in_dark");
	
	this.addCommandID("dark_sync");
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if(player !is null)
	{
		player.SetScoreboardVars("HumanoidIcon.png", 0, Vec2f(16, 16));
	}
}

void onTick(CBlob@ this)
{
	bool serverSide = getNet().isServer();
	bool clientSide = getNet().isClient();

	if(this.isInInventory())return;
	const bool ismyplayer = this.isMyPlayer();
	
	LimbInfo@ limbs;
	if (!this.get("limbInfo", @limbs))return;

	CPlayer @player = this.getPlayer();
	
	if(player !is null){
		this.set_string("player_name",player.getUsername());

		if(getGameTime() % 180 == 59){
			
			if(serverSide){
				this.set_u8("sex",player.getSex());
				this.Sync("sex",true);
				
				this.Sync("alive",true);
				this.Sync("animated",true);
			}
			this.setSexNum(this.get_u8("sex"));
			
			int icon = 0;
			if(limbs.Torso == BodyType::Wraith)icon = 1;
			else if(limbs.Torso == BodyType::Golem)icon = 2;
			else if(limbs.Torso == BodyType::Wood)icon = 3;
			else if(limbs.Torso == BodyType::Zombie)icon = 4;
			else if(limbs.Torso == BodyType::Cannibal)icon = 5;
			else if(limbs.Torso == BodyType::Ghoul)icon = 6;
			else if(limbs.Torso == BodyType::Gold)icon = 7;
			else if(limbs.Torso == BodyType::Metal)icon = 8;
			player.SetScoreboardVars("HumanoidIcon.png", icon, Vec2f(16, 16));
		}
	}
	
	//////////////////////////////////Clientstuff
	
	if(clientSide){
		if(ismyplayer){
		
			if(this.isKeyPressed(key_inventory)){
				if(this.get_u8("bag_sprite") < 2)this.add_u8("bag_sprite",1);
			} else {
				if(this.get_u8("bag_sprite") > 0)this.sub_u8("bag_sprite",1);
			}
			
			if(this.get_f32("head_hit") > 0)this.sub_f32("head_hit",0.05f);
			if(this.get_f32("torso_hit") > 0)this.sub_f32("torso_hit",0.05f);
			if(this.get_f32("main_arm_hit") > 0)this.sub_f32("main_arm_hit",0.05f);
			if(this.get_f32("sub_arm_hit") > 0)this.sub_f32("sub_arm_hit",0.05f);
			if(this.get_f32("front_leg_hit") > 0)this.sub_f32("front_leg_hit",0.05f);
			if(this.get_f32("back_leg_hit") > 0)this.sub_f32("back_leg_hit",0.05f);
			
			if(getGameTime() % 60 == 0
			|| (getGameTime() % 20 == 0 && this.hasTag("in_dark"))){
				bool d = isNight();
				if(d)d = inDarkness(this);
				if(d != this.hasTag("in_dark")){
					if(d)this.Tag("in_dark");
					else this.Untag("in_dark");
					CBitStream params;
					params.write_bool(d);
					this.SendCommand(this.getCommandID("dark_sync"), params);
				}
			}
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("dark_sync"))
	{
		bool InDark = params.read_bool();
		
		if(InDark)this.Tag("in_dark");
		else this.Untag("in_dark");
	}
}