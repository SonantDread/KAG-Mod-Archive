
#include "MaterialCommon.as"
#include "Hitters.as"

void onHitMap( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, u8 customData){
	if(damage <= 0.0f) return;
	if(!isServer()) return;
	
	f32 collectedWood = 0.0f;
	f32 collectedStone = 0.0f;
	f32 collectedGold = 0.0f;

	while(damage > 0.0f){
		damage -= 1.0f;
		
		CMap@ map = getMap();
		int type = map.getTile(worldPoint).type;
		
		if(type == CMap::tile_gold_brick+7)server_CreateBlob("gold_bar",-1,this.getPosition());
		if(type >= CMap::tile_gold_pile && type <= CMap::tile_gold_pile+4)server_CreateBlob("gold_bar",-1,this.getPosition());
		
		if (type >= CMap::tile_gold_gem_weak && type <= CMap::tile_gold_gem_unstable+19){
		  if(XORRandom(10) == 0)collectedGold += 1.0f;
		  if(type >= CMap::tile_gold_gem_unstable){
			MagicExplosion(this.getPosition(), "UnstableMagic"+XORRandom(4)+".png", 1.0f);
		  }
		}
		
		if(type == CMap::tile_gold_gem_weak+5)server_CreateBlob("weak_gem",-1,this.getPosition());
		if(type == CMap::tile_gold_gem+7)server_CreateBlob("gem",-1,this.getPosition());
		if(type == CMap::tile_gold_gem_strong+12)server_CreateBlob("strong_gem",-1,this.getPosition());
		if(type == CMap::tile_gold_gem_unstable+19)server_CreateBlob("unstable_gem",-1,this.getPosition());
		
		

		if(type >= CMap::tile_stone_hard && type <= CMap::tile_stone_hard+23){
			if(type == CMap::tile_stone_hard+23)server_CreateBlob("metal_ore",-1,this.getPosition());
			collectedStone += 5.0f;
		}
		

		if(map.isTileSolid(type)){
			if(map.isTileThickStone(type))collectedStone += 5.0f;
			if(map.isTileStone(type))collectedStone += 5.0f;
			if(map.isTileCastle(type))collectedStone += 1.0f;
			if(map.isTileWood(type))collectedWood += 1.0f;
			if(map.isTileGold(type))if(XORRandom(10) == 0 || type == 94)collectedGold += 1.0f;
		}

		map.server_DestroyTile(worldPoint, 1.0f, this);
	}
	
	if(customData == Hitters::muscles){ //Pole
		collectedWood *= 0.0f;
		collectedStone *= 0.20f;
		collectedGold *= 0.5f;
	}
	
	if(collectedWood > 0.0f)Material::createFor(this, 'mat_wood', collectedWood);
	if(collectedStone > 0.0f)Material::createFor(this, 'mat_stone', collectedStone);
	while(collectedGold >= 1.0f){
		collectedGold -= 1.0f;
		server_CreateBlob("gold_ore",-1,this.getPosition());
	}
	if(collectedGold > 0.0f)
	if(f32(XORRandom(1000))/1000.0f < collectedGold){
		server_CreateBlob("gold_ore",-1,this.getPosition());
	}
}