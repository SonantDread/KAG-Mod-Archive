/* 1aqpmf4.as
 * author: Aphelion
 */

#include "9cfe72.as";

void onInit( CRules@ this )
{
	GunInfo[] guns;
	AddGunInfos(guns);
	
	this.set(gun_infos_property, guns);
}
