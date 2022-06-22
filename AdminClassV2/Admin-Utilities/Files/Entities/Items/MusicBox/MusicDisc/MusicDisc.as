// A script by TFlippy, and used by Z'place. thanks TFlippy!

const string[] names =
{
	"Knight of The Caribbean",
	"Mortal Kombat",
	"You Will Not Supposed To Listen This",
	"Ghost Busters",
 	"Let it Snow",
	"What Is Love",
	"Rick Astley",
	"Take On Me",
	"Queen",
	"One More time",
 	"Can't Touch This",
	"Toxic",
	"Call On Me",
	"Gta San Andreas",
	"Ice Ice Baby",
	"I'm Too Sexy",
	"1999",
	"The Sweet Escape",
	"Wasted On You",
	"Welcome To The Club",
	"Spider Riders",
	"Solitude",
	"Coldplay",
	"C418 Minecraft",
	"Smoke Weed Everyday",
	"blank"
};

void onInit(CBlob@ this)
{
	this.addCommandID("set");
	this.set_u8("trackID", XORRandom(25)); // Temporary 
	
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
	this.setInventoryName("Gramophone Record (" + names[inIndex] + ")");
	
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