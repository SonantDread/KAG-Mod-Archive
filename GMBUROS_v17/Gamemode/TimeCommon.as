
const int DayLength = 24*60*30;

int getTime(){
	return (getGameTime()+(12*(DayLength/24))) % DayLength;
}

int getHour(){
	return getTime()/(60*30);
}

int getMinute(){
	return getTime()/(30);
}

string getTimeFromTicks(int tick){
	f32 perc = f32(tick)/f32(DayLength);
	
	int hour = 24.0f*perc;
	int minute = f32(24*60)*perc;
	while(minute >= 60){
		minute -= 60;
	}
	
	string t = ":";
	if(tick % 60 < 30)t = " ";
	if(hour < 10)t = "0"+hour+t;
	else t = ""+hour+t;
	
	if(minute < 10)t = t+"0"+minute;
	else t = t+minute;
	
	return t;
}

bool isNight(){
	f32 perc = f32(getTime())/f32(DayLength);
	
	int hour = 24.0f*perc;
	
	if(hour >= 21 || hour < 5)return true;
	
	return false;
}

bool inDarkness(CBlob @this){

	//Light doesn't work server side, go figure
	SColor here = getMap().getColorLight(this.getPosition());
	int light = here.getGreen();
	if(light > here.getRed())light = here.getRed();
	if(light > here.getBlue())light = here.getBlue();
	
	//print("rgb: "+getMap().getColorLight(this.getPosition()).getRed()+","+getMap().getColorLight(this.getPosition()).getGreen()+","+getMap().getColorLight(this.getPosition()).getBlue());
	
	if(light < 160)return true;
	
	return false;
}