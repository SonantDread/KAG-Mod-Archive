#include "ShopCommon.as";
#include "TechsCommon.as";
#include "ScrollCommon.as";
#include "MakeScroll.as";
#include "MiniIconsInc.as";

void SetupScrolls(CRules@ this)
{
	ScrollSet _all, _super, _medium, _crappy;
	this.set("all scrolls", _all);

	ScrollSet@ all = getScrollSet("all scrolls");

	{
		ScrollDef def;
		def.name = "Scroll of Taming";
		def.scrollFrame = 24;
		def.scripts.push_back("ScrollTaming.as");
		all.scrolls.set("tame", def);
	}
	{
		ScrollDef def;
		def.name = "Scroll of the Necromancer";
		def.scrollFrame = 18;
		def.scripts.push_back("ScrollNecro.as");
		all.scrolls.set("necro", def);
	}
	{
		ScrollDef def;
		def.name = "Scroll of Carnage";
		def.scrollFrame = 20;
		def.scripts.push_back("ScrollCarnage.as");
		all.scrolls.set("carnage", def);
	}
	{
		ScrollDef def;
		def.name = "Scroll of Midas";
		def.scrollFrame = 17;
		def.scripts.push_back("ScrollMidas.as");
		all.scrolls.set("midas", def);
	}
	{
		ScrollDef def;
		def.name = "Scroll of Bison";
		def.scrollFrame = 21;
		def.scripts.push_back("ScrollBison.as");
		all.scrolls.set("bison", def);
	}
	{
		ScrollDef def;
		def.name = "Scroll of Drought";
		def.scrollFrame = 22;
		def.scripts.push_back("ScrollDrought.as");
		all.scrolls.set("drought", def);
	}
	{
		ScrollDef def;
		def.name = "Scroll of Healing";
		def.scrollFrame = 24;
		def.scripts.push_back("ScrollHealing.as");
		all.scrolls.set("healing", def);
	}
	{
		ScrollDef def;
		def.name = "Scroll of Light";
		def.scrollFrame = 23;
		def.scripts.push_back("ScrollLight.as");
		all.scrolls.set("light", def);
	}
	{
		ScrollDef def;
		def.name = "Scroll of Stone";
		def.scrollFrame = 21;
		def.scripts.push_back("ScrollStone.as");
		all.scrolls.set("stone", def);
	}
	{
		ScrollDef def;
		def.name = "Scroll of Shark";
		def.scrollFrame = 23;
		def.scripts.push_back("ScrollShark.as");
		all.scrolls.set("shark", def);
	}
	{
		ScrollDef def;
		def.name = "Scroll of Chicken";
		def.scrollFrame = 24;
		def.scripts.push_back("ScrollChicken.as");
		all.scrolls.set("chicken", def);
	}
	{
		ScrollDef def;
		def.name = "Scroll of Horde";
		def.scrollFrame = 16;
		def.scripts.push_back("ScrollHorde.as");
		all.scrolls.set("horde", def);
	}
	{
		ScrollDef def;
		def.name = "Scroll of Meteor";
		def.scrollFrame = 18;
		def.scripts.push_back("ScrollMeteor.as");
		all.scrolls.set("meteor", def);
	}
	{
		ScrollDef def;
		def.name = "Scroll of Return";
		def.scrollFrame = 23;
		def.scripts.push_back("ScrollReturn.as");
		all.scrolls.set("return", def);
	}
	{
		ScrollDef def;
		def.name = "Scroll of Skeleton";
		def.scrollFrame = 22;
		def.scripts.push_back("ScrollSkeleton.as");
		all.scrolls.set("skeleton", def);
	}
	{
		ScrollDef def;
		def.name = "Scroll of Zombie";
		def.scrollFrame = 22;
		def.scripts.push_back("ScrollZombie.as");
		all.scrolls.set("zombie", def);
	}

	all.names = all.scrolls.getKeys();
}