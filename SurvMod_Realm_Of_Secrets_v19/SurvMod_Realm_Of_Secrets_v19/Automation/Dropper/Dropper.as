
void onInit(CBlob@ this)
{
	string[] DropList;
	string[] HopList;
	this.set("DropList", @DropList);
	this.set("HopList", @HopList);
	
	this.addCommandID("droplist");
	this.addCommandID("hoplist");
	this.addCommandID("removehoplist");
	this.addCommandID("removedroplist");
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if(onDropList(this,blob.getName()))return false;
	
	return true;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if(blob is null)return;
		
	if(blob.getPosition().x > this.getPosition().x-2)
	if(blob.getPosition().x < this.getPosition().x+2){
		if(onHopList(this,blob.getName()))blob.setVelocity(Vec2f(0, -4.0f));
	}
}

bool onDropList(CBlob @this, string item){
	string[] @DropList;
	this.get("DropList",@DropList);
	
	for(int i = 0;i < DropList.length;i++){
		if(DropList[i] == item)return true;
	}
	
	return false;
}

void removeDropList(CBlob @this, string item){
	string[] @DropList;
	this.get("DropList",@DropList);
	
	for(int i = 0;i < DropList.length;i++){
		if(DropList[i] == item){
			DropList.removeAt(i);
			return;
		}
	}
}


bool onHopList(CBlob @this, string item){
	string[] @HopList;
	this.get("HopList",@HopList);
	
	for(int i = 0;i < HopList.length;i++){
		if(HopList[i] == item)return true;
	}
	
	return false;
}
void removeHopList(CBlob @this, string item){
	string[] @HopList;
	this.get("HopList",@HopList);
	
	for(int i = 0;i < HopList.length;i++){
		if(HopList[i] == item){
			HopList.removeAt(i);
			return;
		}
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(caller.getTeamNum() == this.getTeamNum())
	if(caller.getPosition().x > this.getPosition().x-12)
	if(caller.getPosition().x < this.getPosition().x+12){
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		
		int flip = 1;
		
		if(this.isFacingLeft())flip = -1;

		if(caller.getCarriedBlob() is null){
			caller.CreateGenericButton(16, Vec2f(-4*flip,0), this, this.getCommandID("hoplist"), "Check HopList", params);
			caller.CreateGenericButton(19, Vec2f(4*flip,0), this, this.getCommandID("droplist"), "Check DropList", params);
		} else {
			caller.CreateGenericButton(16, Vec2f(-4*flip,0), this, this.getCommandID("hoplist"), "Add item to HopList", params);
			caller.CreateGenericButton(19, Vec2f(4*flip,0), this, this.getCommandID("droplist"), "Add item to DropList", params);
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("droplist"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if(caller !is null)
		if(getLocalPlayerBlob() is caller)
		{
			string[] @DropList;
			if(this.get("DropList",@DropList)){
				
				if(caller.getCarriedBlob() is null){
					if(caller is getLocalPlayerBlob() && DropList.length > 0){
						CGridMenu @menu = CreateGridMenu(Vec2f(getDriver().getScreenWidth()/2,getDriver().getScreenHeight()/2), this, Vec2f(3,DropList.length), "Droplist");
						for(int i = 0;i < DropList.length;i++){
							CBitStream params;
							params.write_string(DropList[i]);
							menu.AddButton("$"+DropList[i]+"$", DropList[i], this.getCommandID("removedroplist"), Vec2f(1,1), params);
							menu.AddTextButton("Remove:\n"+DropList[i], this.getCommandID("removedroplist"), Vec2f(2,1), params);
						}
					} else {
						CGridMenu @menu = CreateGridMenu(Vec2f(getDriver().getScreenWidth()/2,getDriver().getScreenHeight()/2), this, Vec2f(3,1), "Empty Droplist");
						menu.AddTextButton("Empty Droplist", Vec2f(3,1));
					}
				} else {
					if(!onDropList(this,caller.getCarriedBlob().getName())){
						DropList.push_back(caller.getCarriedBlob().getName());
					}
				}
			}
		}
	}
	if (cmd == this.getCommandID("removedroplist"))
	{
		string item = params.read_string();
		removeDropList(this,item);
		
	}
	if (cmd == this.getCommandID("hoplist"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if    (caller !is null)
		if(getLocalPlayerBlob() is caller)
		{
			string[] @HopList;
			if(this.get("HopList",@HopList)){
				
				if(caller.getCarriedBlob() is null){
					if(caller is getLocalPlayerBlob() && HopList.length > 0){
						CGridMenu @menu = CreateGridMenu(Vec2f(getDriver().getScreenWidth()/2,getDriver().getScreenHeight()/2), this, Vec2f(3,HopList.length), "HopList");
						if(menu !is null)
						for(int i = 0;i < HopList.length;i++){
							CBitStream params;
							params.write_string(HopList[i]);
							menu.AddButton("$"+HopList[i]+"$", HopList[i], this.getCommandID("removehoplist"), Vec2f(1,1), params);
							menu.AddTextButton("Remove:\n"+HopList[i], this.getCommandID("removehoplist"), Vec2f(2,1), params);
						}
					} else {
						CGridMenu @menu = CreateGridMenu(Vec2f(getDriver().getScreenWidth()/2,getDriver().getScreenHeight()/2), this, Vec2f(3,1), "Empty HopList");
						if(menu !is null)menu.AddTextButton("Empty HopList", Vec2f(3,1));
					}
				} else {
					if(!onHopList(this,caller.getCarriedBlob().getName())){
						HopList.push_back(caller.getCarriedBlob().getName());
					}
				}
			}
		}
	}
	if (cmd == this.getCommandID("removehoplist"))
	{
		string item = params.read_string();
		removeHopList(this,item);
		
	}
}