

namespace Enchantment
{
	enum type
	{
		Soul,
		Spirit,
		Nature,
		Gem,
		WeakGem,
		StrongGem,
		UnstableGem,
		
		length
	};
}

u32 addEnchant(u32 Enchants, int Enchant){
	return Enchants | (1 << Enchant);
}
void addEnchant(CBlob @this, int Enchant){
	this.set_u32("enchants",addEnchant(this.get_u32("enchants"),Enchant));
}



bool hasEnchant(u32 Enchants, int Enchant){
	return (Enchants & (1 << Enchant)) != 0;
}
bool hasEnchant(CBlob @this, int Enchant){
	return hasEnchant(this.get_u32("enchants"),Enchant);
}

u32 removeEnchant(u32 Enchants, int Enchant){
	return Enchants & ~(1 << Enchant);
}
void removeEnchant(CBlob @this, int Enchant){
	this.set_u32("enchants",removeEnchant(this.get_u32("enchants"),Enchant));
}

string EnchantName(int Enchant){
	switch(Enchant){
		case Enchantment::Soul: return "Soul";
		case Enchantment::Spirit: return "Spirit";
		case Enchantment::Nature: return "Nature";
		
		case Enchantment::WeakGem: return "WeakGem";
		case Enchantment::Gem: return "Gem";
		case Enchantment::StrongGem: return "StrongGem";
		case Enchantment::UnstableGem: return "UnstableGem";
	}
	return "None";
}

bool AnimatedEnchant(CBlob @this){
	u32 Enchants = this.get_u32("enchants");
	
	for(int i = 0;i < Enchantment::length;i++){
		if(hasEnchant(Enchants, i)){
			switch(i){
				case Enchantment::Soul: return true;
				case Enchantment::Spirit: return true;
			}
		}
	}
	
	return false;
}

bool LimbManipulationEnchant(CBlob @this){
	u32 Enchants = this.get_u32("enchants");
	
	for(int i = 0;i < Enchantment::length;i++){
		if(hasEnchant(Enchants, i)){
			switch(i){
				case Enchantment::Soul: return true;
				case Enchantment::Spirit: return true;
				case Enchantment::Nature: return true;
			}
		}
	}
	
	return false;
}