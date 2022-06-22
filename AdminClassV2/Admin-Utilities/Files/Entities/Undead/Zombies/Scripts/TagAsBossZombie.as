#include "CreatureCommon.as";

void onInit( CBlob@ this )
{
	this.Tag("boss_zombie");
	SetupTargets(this);
}

void SetupTargets( CBlob@ this )
{
	TargetInfo[] infos;

	addTargetInfo(infos, "survivorplayer", 1.0f, true, true);
	addTargetInfo(infos, "undeadplayer", 1.0f, true, true);
	addTargetInfo(infos, "ally", 1.0f, true);
	addTargetInfo(infos, "pet", 0.9f, true);
	addTargetInfo(infos, "stone_door", 0.0f);
	addTargetInfo(infos, "lantern", 0.5f);
	addTargetInfo(infos, "wooden_door", 0.5f);
	addTargetInfo(infos, "stone_block", 0.5f);
	addTargetInfo(infos, "survivorbuilding", 0.4f, true);
	addTargetInfo(infos, "mounted_bow", 0.4f);
	addTargetInfo(infos, "mounted_bazooka", 0.5f);
	addTargetInfo(infos, "wooden_platform", 0.2f);
	addTargetInfo(infos, "wood_block", 0.5f);
	addTargetInfo(infos, "lasergun", 0.2f);
	

	//for EatOthers
	string[] tags = {"dead"};
	this.set("tags to eat", tags);
	
	this.set("target infos", @infos);
}