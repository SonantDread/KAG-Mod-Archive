// //handy dandy frame lookup
// namespace Emotes
// {
	// enum Emote_Indices
	// {
		// skull = 0,  //0
		// blueflag,
		// note,
		// right,
		// smile,
		// redflag,
		// flex,
		// down,
		// frown,
		// troll,
		// finger,		//10
		// left,
		// mad,
		// archer,
		// sweat,
		// up,
		// laugh,
		// knight,
		// question,
		// thumbsup,
		// wat,		//20
		// builder,
		// disappoint,
		// thumbsdown,
		// derp,
		// ladder,
		// attn,
		// pickup,
		// cry,
		// wall,
		// heart,		//30
		// fire,
		// check,
		// cross,
		// dots,
		// cog,

		// emotes_total,
		// off
	// };
// }

//handy dandy frame lookup
namespace Emotes
{
	//note: it's recommended to use the names in-config
	//		for future compatibility; emote indices _may_ get re-ordered
	//		but we will try not to rename emoticons

	enum Emote_Indices
	{
		skull = 0,  //0
		blueflag,
		note,
		right,
		smile,
		redflag,
		flex,
		down,
		frown,
		troll,
		finger,		//10
		left,
		mad,
		archer,
		sweat,
		up,
		laugh,
		knight,
		question,
		thumbsup,
		wat,		//20
		builder,
		disappoint,
		thumbsdown,
		drool,
		ladder,
		attn,
		okhand,
		cry,
		wall,
		heart,		//30
		fire,
		check,
		cross,
		dots,
		cog,
		think,
		laughcry,
		derp,
		awkward,
		smug,       //40
		love,
		kiss,
		pickup,
		raised,

		emotes_total,
		off
	};

	//careful to keep these in sync!
	const string[] names = {
		"skull",
		"blueflag",
		"note",
		"right",
		"smile",
		"redflag",
		"flex",
		"down",
		"frown",
		"troll",
		"finger",
		"left",
		"mad",
		"archer",
		"sweat",
		"up",
		"laugh",
		"knight",
		"question",
		"thumbsup",
		"wat",
		"builder",
		"disappoint",
		"thumbsdown",
		"drool",
		"ladder",
		"attn",
		"okhand",
		"cry",
		"wall",
		"heart",
		"fire",
		"check",
		"cross",
		"dots",
		"cog",
		"think",
		"laughcry",
		"derp",
		"awkward",
		"smug",
		"love",
		"kiss",
		"pickup",
		"raised"
	};
}

void set_emote(CBlob@ this, u8 emote, int time)
{
	if (emote >= Emotes::emotes_total)
	{
		emote = Emotes::off;
	}

	this.set_u8("emote", emote);
	this.set_u32("emotetime", getGameTime() + time);
	bool client = this.getPlayer() !is null && this.isMyPlayer();
	this.Sync("emote", !client);
	this.Sync("emotetime", !client);
	
	// if (emote < sounds.length && getGameTime() >= this.get_u32("next_emote_sound") && sounds[emote] != "")
	// {
		// if (getNet().isClient())
		// {
			// f32 pitch = this.getSexNum() == 0 ? 0.9f : 1.5f;
			// if (this.exists("voice pitch")) pitch = this.get_f32("voice pitch");
			
			// this.getSprite().PlaySound(sounds[emote], 1.00f, pitch);
		// }
		
		// this.set_u32("next_emote_sound", getGameTime() + 20);
	// }
}

void set_emote(CBlob@ this, u8 emote)
{
	set_emote(this, emote, 90);
}

bool is_emote(CBlob@ this, u8 emote = 255, bool checkBlank = false)
{
	u8 index = emote;
	if (index == 255) index = this.get_u8("emote");

	u32 time = this.get_u32("emotetime");

	return time > getGameTime() && index != Emotes::off && (!checkBlank || (index != Emotes::dots));
}

