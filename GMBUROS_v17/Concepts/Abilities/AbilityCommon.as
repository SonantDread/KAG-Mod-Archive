
namespace Ability
{
	shared enum abils
	{
		///Spirit
		ShardSelf,
		ImbueCorpse,
		GuardianSwitch,
		
		///Darkness
		SummonDarkBlade,
		SummonDarkGreatBlade,
		SummonGreaterDarkStaff,
		CorruptOrb,
		CorruptTendril,
		
		///Heat
		FireWave
	}
}

AbilityData[] Abilities = { //I recommend keeping the ability data list and enum in the same order unless you like headaches
	///Spirit
	AbilityData(-1,"Shard Self", "ShardSelf", "Turn your soul into a solid crystal."),
	AbilityData(-1,"Imbue: Corpse", "ImbueCorpse", "Imbue a held corpse with spirit energy, animating it to life."),
	AbilityData(-1,"Guardian's Switch", "GuardianSwitch", "Switch positions."),
	
	///Darkness
	AbilityData(-1,"Forge Dark Blade", "ShadowBladeIcon", "Forge a blade of shadows.\nKilling with this blade grants extra darkness.\nCosts 40 darkness."),
	AbilityData(-1,"Forge Dark Great-Blade", "DarkBladeIcon", "Forge a great-blade of shadows for the leader of your army.\nOnly one can exist at once.\nCosts 200 darkness."),
	AbilityData(-1,"Craft Greater Dark Staff", "DarkStaff", "Craft a staff of darkness, for the builder of your fortress.\nOnly one can exist at once."),
	
	AbilityData(2,"Dissolving Orb", "CorruptOrb", "Send forth a sphere of darkness."),
	AbilityData(3,"Tendrils of Hate", "CorruptTendril", "Weave a tendril of destruction through the landscape."),
	
	///Heat
	AbilityData(1,"Fire Wave", "SearingIntake", "Spew fire forth from your hand, burning those in front of you.")
};

void addAbility(CBlob @this,int AbilityID){
	int[] @AbilitiesKnown;
	if(this.get("AbilitiesKnown",@AbilitiesKnown)){
		if(AbilitiesKnown.find(AbilityID) < 0)AbilitiesKnown.push_back(AbilityID);
		if(Abilities[AbilityID].hand_cast >= 0)this.Tag("has_hand_casting");
	}
}

void removeAbility(CBlob @this,int AbilityID){
	int[] @AbilitiesKnown;
	if(this.get("AbilitiesKnown",@AbilitiesKnown)){
		if(AbilitiesKnown.find(AbilityID) >= 0){
			AbilitiesKnown. removeAt(AbilitiesKnown.find(AbilityID));
		}
	}
}

bool hasAbility(CBlob @this,int AbilityID){
	int[] @AbilitiesKnown;
	if(this.get("AbilitiesKnown",@AbilitiesKnown)){
		if(AbilitiesKnown.find(AbilityID) >= 0)return true;
	}
	return false;
}

class AbilityData
{
	string name;
	string icon;
	string hover_text;
	int hand_cast;

	AbilityData(int hand_cast, string name, string icon, string hover_text)
	{
		this.name = name;
		AddIconToken("$"+icon+"$", icon+".png", Vec2f(24, 24), 0);
		this.icon = "$"+icon+"$";
		this.hover_text = hover_text;
		this.hand_cast = hand_cast;
	}
}