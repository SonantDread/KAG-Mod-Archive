
#include "TimeCommon.as";
#include "Magic.as";

void onTick(CRules@ this)
{
	int Time = (getTime() + (f32(DayLength)/24.0f*22.0f)) % DayLength ;
	f32 perc = f32(Time)/f32(DayLength);
	
	if(perc < 0.4f)perc = (perc/0.4f)*0.1f;
	else if(perc > 0.6f)perc = 0.9f+((perc-0.6f)/0.4f)*0.1f;
	else perc = 0.1f+((perc-0.4f)/0.2f)*0.8f;
	
	getMap().SetDayTime(perc);
	
	if(getTime() >= 22*60*30 || getTime() <= 4*60*30){
		if(getTime() % (60*30*2) == 0)if(isServer())TriggerNightOccurance();
		if(getTime() % (60*30) == 45*30)if(isServer() && XORRandom(2) == 0)TriggerLanterns();
		if(isServer())HandleShadows();
	} else {
		eventDone.clear();
	}
}

void onRender(CRules@ this)
{
	if (g_videorecording)
		return;

	
	SColor col = SColor(255, 255, 255, 255);
	GUI::SetFont("menu");
	Vec2f dimensions(0,0);
	string disp = getTimeFromTicks(getTime());
	GUI::GetTextDimensions(disp, dimensions);
	if(getHour() < 21 || 21*60+XORRandom(53) >= getMinute())
	if(getHour() >= 6)
	GUI::DrawText(disp, Vec2f(0,0), col);
}

void TriggerLanterns(){
	CBlob@[] lanterns;
	getBlobsByName("lantern", lanterns);
	getBlobsByName("ward", lanterns);
	for(int i = 0;i < lanterns.length;i++){
		if(XORRandom(10) == 0){
			CBlob @l = lanterns[i];
			if(l !is null)
			if(l.isLight()){
				l.SendCommand(l.getCommandID("activate"));
			}
		}
	}
}

void HandleShadows(){
	if(XORRandom(10) == 0){
		CBlob@[] shadows;
		getBlobsByName("evil_ghost", shadows);
		if(shadows.length < 10){
			server_CreateBlob("evil_ghost", -1, Vec2f(XORRandom(getMap().tilemapwidth) * getMap().tilesize, -320.0f));
		}
	}
	
}

int[] eventDone;
int events = 7;

void TriggerNightOccurance(){

	int event = XORRandom(events);
	int forceBreak = 0;
	
	while(eventDone.find(event)> -1 && forceBreak < 100){
		event = XORRandom(events);
		forceBreak++;
	}
	eventDone.push_back(event);
	
	//event = 3;
	
	//print("Event:"+event);
	
	switch(event){
	
		case 0:{
			server_CreateBlob("meteor", 255, Vec2f(XORRandom(getMap().tilemapwidth) * getMap().tilesize, 0.0f));
		return;}
		
		case 1:{
			CBlob@[] trees;
					
			getBlobsByName("tree_pine", trees);
			getBlobsByName("tree_bushy", trees);
			getBlobsByName("tree_large", trees);
			if(trees.length > 0){
				int ran = XORRandom(trees.length);
				trees[ran].server_Hit(trees[ran], trees[ran].getPosition(), Vec2f(0,0), 30.0f, 0, true);
			}
		return;}
		
		case 2:{

			CBlob@[] nature;
					
			getBlobsByName("tree_pine", nature);
			getBlobsByName("tree_bushy", nature);
			getBlobsByName("tree_large", nature);
			getBlobsByName("big_bush", nature);
			getBlobsByName("humanoid", nature);
			if(nature.length > 0){
				int ran = XORRandom(nature.length);
				bool speak = true;
				if(nature[ran].getName() == "humanoid"){
					speak = false;
					if(nature[ran].hasTag("animated") && nature[ran].getPlayer() is null){
						speak = true;
					}
				}
				if(speak){
					
					string str = "...";
					
					switch(XORRandom(18)){
						case 0: str = "it wont hurt much";break;
						case 1: str = "come here";break;
						case 2: str = "it will only sting";break;
						case 3: str = "the pain will be temporary";break;
						case 4: str = "you wont feel afterwards";break;
						case 5: str = "I can help you";break;
						case 6: str = "I will fix you";break;
						case 7: str = "is your heart still beating";break;
						case 8: str = "isnt breathing tiresome";break;
						case 9: str = "over here";break;
						case 10: str = "this way";break;
						case 11: str = "come, trust me";break;
						case 12: str = "close your eyes";break;
						case 13: str = "can you see me";break;
						case 14: str = "where are you";break;
						case 15: str = "make it stop";break;
						case 16: str = "please it hurts";break;
						case 17: str = "I cant see";break;
					}
					
					nature[ran].Chat(str);
				}
			}
		return;}
		
		case 3:{
			server_CreateBlob("poltergeist", -1, Vec2f(XORRandom(getMap().tilemapwidth) * getMap().tilesize, -320.0f));
			server_CreateBlob("poltergeist", -1, Vec2f(XORRandom(getMap().tilemapwidth) * getMap().tilesize, -320.0f));
			server_CreateBlob("poltergeist", -1, Vec2f(XORRandom(getMap().tilemapwidth) * getMap().tilesize, -320.0f));
		return;}
		
		case 4:{
			bool side = (XORRandom(2) == 0);
			for(int i = 0;i < 10+XORRandom(10);i++){
				Vec2f pos = Vec2f(0.0f, XORRandom(getMap().tilemapheight*8/3));
				if(side)pos.x = getMap().tilemapwidth*8-1;
				else pos.x = 0;
				CBlob @g = server_CreateBlob("passing_ghost", 255, pos);
				g.setPosition(pos);
				g.set_u32("delay",getGameTime()+XORRandom(30*10+i*10));
				if(!side)g.Tag("going_right");
			}
		return;}
		
		case 5:{
			s8 j = 3;
			
			CBlob@[] animals;
						
			getBlobsByName("chicken", animals);
			getBlobsByName("bison", animals);
			getBlobsByName("fish", animals);
			
			while(j >= 0){
				j--;
				
				if(animals.length > 0){
					int ran = XORRandom(animals.length);
					MagicExplosion(animals[ran].getPosition(), "UnstableMagic"+XORRandom(4)+".png", 5.0f);
				}
			}
		return;}
		
		case 6:{
			CBlob@[] rain;
						
			getBlobsByName("rain", rain);
			
			if(rain.length <= 0){
				CBlob @r = server_CreateBlobNoInit("rain");
				r.Tag("bloodrain");
				r.Init();
			}
		return;}
	
	}
	

}

//Events todo:
//Ghost flower bloom
//light in the dark
//life rain
//maggots

//threats:
//smoke monster
//leaper, wierd mass on the ground, jumps at you if you get close
//repear flying accross the land
//Shadows
