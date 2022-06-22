/* RP_Knowledge.as
 * author: Aphelion
 */

#include "rd52f9.as";

void onInit( CRules@ this )
{
	GiveFreeTechs(this);
}

void onRestart( CRules@ this )
{
	GiveFreeTechs(this);
}

void GiveFreeTechs(CRules@ this)
{
	if (getNet().isServer())
	{
		print("giving free techs");
		setTechResearched("Wizardry I", 0);
		setTechResearched("Smithing I", 1);
		setTechResearched("Marksmanship I", 2);
		setTechResearched("Endurance I", 3);
	}
}
