/*

	Blunt mostly ignores armour
	Pierce either ignores armour or does no damage (so if pierce damage is less than the armour, it bounces)
	Slash is directly reduced by armour
	Hack ignores shields, but reduced by armour

	Modifiers:
		Armour: Defense equal to tier-1;
		Tier: Damage equal to tier
		Slash: +1 Dmg
		Hack: +0 Dmg
		Stab: +0 Dmg
		Blunt: +0 Dmg
		Long/Reach: -1 Dmg
		TwoHands: +1 Dmg

	Tier 0: Flesh
		Naked Armour: 0.0f
		Punch, Blunt: 0.5f

	Tier 1: Wood
		Cloth Armour: 0.5f
		Stick, long blunt: 0.5f
		Mallet, blunt: 1.0f
		
	Tier 2: Stone
		Leather Armour: 1.0f
		Spear, long pierce: 1.0f
		Knife, pierce: 2.0f;
		Hachet, hack: 2.0f
		Hammer, blunt: 2.0f;
		
	Tier 3: Metal
		Metal Armour: 2.0f
		Pike, long pierce: 2.0f
		Knife, pierce: 3.0f;
		Axe, hack: 3.0f
		Hammer, blunt: 3.0f;
		Sword, slash: 4.0f;
		
*/