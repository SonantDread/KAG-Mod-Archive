
#include "Hitters.as";
#include "EnchantCommon.as";
#include "Magic.as";

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	if(damage <= 0.0f || this is hitterBlob)return damage;
	
	if(hasEnchant(this, Enchantment::UnstableGem))
	if(customData != Hitters::burn && customData != Hitters::fire){
		MagicExplosion(this.getPosition(), "UnstableMagic"+XORRandom(4)+".png", damage*0.5f);
		
		if(hitterBlob !is null)MagicExplosion(hitterBlob.getPosition(), "UnstableMagic"+XORRandom(4)+".png", damage*0.25f);
	}
	
	return damage;
}

void onHitBlob( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData )
{
	if(damage <= 0.0f || this is hitBlob)return;
	
	if(hasEnchant(this, Enchantment::UnstableGem))
	if(customData != Hitters::burn && customData != Hitters::fire){
		if(hitBlob !is null)
		if(hitBlob.hasTag("flesh"))MagicExplosion(hitBlob.getPosition(), "UnstableMagic"+XORRandom(4)+".png", damage*0.25f);
	}
}

void onDie(CBlob@ this){
	if(isServer())
	if(!this.hasTag("dropped_gems")){

		u32 Enchants = this.get_u32("enchants");

		if(hasEnchant(Enchants,Enchantment::WeakGem))if(XORRandom(2) == 0)server_CreateBlob("weak_gem",-1,this.getPosition());
		if(hasEnchant(Enchants,Enchantment::Gem)){
			if(XORRandom(2) == 0)server_CreateBlob("weak_gem",-1,this.getPosition());
			else server_CreateBlob("gem",-1,this.getPosition());
		}
		if(hasEnchant(Enchants,Enchantment::StrongGem))server_CreateBlob("strong_gem",-1,this.getPosition());
		if(hasEnchant(Enchants,Enchantment::UnstableGem))server_CreateBlob("unstable_gem",-1,this.getPosition());
		
		this.Tag("dropped_gems");
	}
}