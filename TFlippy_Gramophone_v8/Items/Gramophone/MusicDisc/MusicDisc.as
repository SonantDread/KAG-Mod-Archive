// A script by TFlippy

const string[] names =
{
	"Ancient Stones",
	"Mountain King",
	"Lucio",
	"The Flying Circus",
	"It is a Mystery",
	"All The Things",
	"Circus!",
	"Hobbits",
	"Maple Leaf",
	"Drunken Sailor",
	"Suite Punta del Este",
	"Glowing Embers Inn",
	"Handlebars",
	"Lonely Day",
	"Shooting Stars",
	"You Dont Own Me",
	"Castle Bard",
	"Odd Couple",
	"Bandit Radio",
	"King And Country",
	"Tea for Two"
};

void onInit(CBlob@ this)
{
	if (!this.exists("trackID")) this.set_u8("trackID", XORRandom(names.length)); // Temporary 

	const u8 trackID = this.get_u8("trackID");
	
	this.set_u8("trackID", trackID);
	this.getSprite().SetAnimation("track" + trackID);
	this.setInventoryName("Gramophone Record (" + (trackID < names.length ? names[trackID] : "ERROR") + ")");
}