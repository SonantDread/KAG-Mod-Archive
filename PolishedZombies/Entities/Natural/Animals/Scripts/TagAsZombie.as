#include "CreatureCommon.as";

void onInit(CBlob@ this)
{
	this.Tag("zombie");
	SetupTargets(this);
}

void SetupTargets(CBlob@ this)
{
	TargetInfo[] infos;

	{
		TargetInfo i("player", 1.0f, true, true);
		infos.push_back(i);
	}
	{
		TargetInfo i("survivor", 1.0f, true, true);
		infos.push_back(i);
	}
	{
		TargetInfo i("building", 0.8f, true);
		infos.push_back(i);
	}
	{
		TargetInfo i("bison", 0.7f);
		infos.push_back(i);
	}
	{
		TargetInfo i("wooden_door", 0.6f);
		infos.push_back(i);
	}
	{
		TargetInfo i("stone_door", 0.6f);
		infos.push_back(i);
	}
	{
		TargetInfo i("gold_door", 0.6f);
		infos.push_back(i);
	}
	{
		TargetInfo i("wooden_platform", 0.5f);
		infos.push_back(i);
	}
	{
		TargetInfo i("wood_block", 0.3f);
		infos.push_back(i);
	}
	{
		TargetInfo i("stone_block", 0.3f);
		infos.push_back(i);
	}
	{
		TargetInfo i("gold_block", 0.3f);
		infos.push_back(i);
	}
	{
		TargetInfo i("log", 0.2f);
		infos.push_back(i);
	}
	{
		TargetInfo i("lantern", 0.2f);
		infos.push_back(i);
	}
	
	this.set("target infos", @infos);

	TargetInfo[] infos2;

	{
		TargetInfo i("zknight", 1.0f, true, true);
		infos2.push_back(i);
	}
	{
		TargetInfo i("zombie", 1.0f, true, true);
		infos2.push_back(i);
	}
	{
		TargetInfo i("wraith", 1.0f, true, true);
		infos2.push_back(i);
	}
	{
		TargetInfo i("skeleton", 1.0f, true, true);
		infos2.push_back(i);
	}
	{
		TargetInfo i("king", 1.0f, true, true);
		infos2.push_back(i);
	}
	{
		TargetInfo i("horror", 1.0f, true, true);
		infos2.push_back(i);
	}
	{
		TargetInfo i("greg", 1.0f, true, true);
		infos2.push_back(i);
	}
	{
		TargetInfo i("gasbag", 1.0f, true, true);
		infos2.push_back(i);
	}
	{
		TargetInfo i("zchicken", 1.0f, true, true);
		infos2.push_back(i);
	}
	{
		TargetInfo i("catto", 1.0f, true, true);
		infos2.push_back(i);
	}
	{
		TargetInfo i("banshee", 1.0f, true, true);
		infos2.push_back(i);
	}
	{
		TargetInfo i("ankou", 1.0f, true, true);
		infos2.push_back(i);
	}
	{
		TargetInfo i("abomination", 1.0f, true, true);
		infos2.push_back(i);
	}
	{
		TargetInfo i("zombiearm", 1.0f, true, true);
		infos2.push_back(i);
	}

	this.set("target infos2", @infos2);
}