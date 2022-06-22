// A script by TFlippy, and used by Z'place. thanks TFlippy!

const string[] names =
{
	"La Chanla",
	"blank"

};

void onInit(CBlob@ this)
{
	this.addCommandID("set");
	this.set_u8("trackID", XORRandom(2)); // Temporary 
	
	SetTrack(this, this.get_u8("trackID"));
	this.set_u32("decaytime",0);
}

void onTick(CBlob@ this)
{
	this.set_u32("decaytime",this.get_u32("decaytime") + 1);
	if(this.get_u32("decaytime") > 1800)
	{
		this.server_Die();
	}
}

void SetTrack(CBlob@ this, u8 inIndex)
{
	if (inIndex > names.length - 1) return;

	this.set_u8("trackID", inIndex);
	this.getSprite().SetAnimation("track" + inIndex);
	this.setInventoryName("Bekkit Record (" + names[inIndex] + ")");
	
	// print("Current: " + this.getSprite().animation.name + "; Should be: " + "track" + inIndex);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	// print("cmd");

	//if (getNet().isClient())
	//{
		if (cmd == this.getCommandID("set"))
		{
			// print("set");
			SetTrack(this, params.read_u8());
		}
	//}
}