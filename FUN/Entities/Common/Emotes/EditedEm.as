//handy dandy frame lookup
namespace Emotes {
enum Emote_Indices {
    skull = 0,
    blueflag,
    note,
    right,
    smile,
    redflag,
    flex,
    down,
    frown,
    troll,
    finger,
    left,
    mad,
    archer,
    sweat,
    up,
    laugh,
    knight,
    question,
    thumbsup,
    wat,
    builder,
    disappoint,
    thumbsdown,
    derp,
    ladder,
    attn,
    pickup,
    cry,
    wall,
    heart,
    fire,
    check,
    cross,
    dots,
    cog,
	
	castle,
	nothing,
	no,
	tease,
	teased,
	gold,
	afk,
	idea,
	yes,
    emotes_total,
    off
};
}

void set_emote(CBlob@ this, u8 emote, int time)
{
    this.set_u8("emote", emote);
    this.set_u32("emotetime", getGameTime()+time);
	bool client = this.getPlayer() !is null;
    this.Sync("emote", !client);
    this.Sync("emotetime", !client);
}

void set_emote(CBlob@ this, u8 emote)
{
    set_emote(this, emote, 90);
}

bool is_emote(CBlob@ this, u8 emote = 255, bool checkBlank = false)
{
	u8 index = emote;
	if (index == 255)
		index = this.get_u8("emote");
	
    u32 time = this.get_u32("emotetime");
    
    return time > getGameTime() && index != Emotes::off && (!checkBlank || (index != Emotes::dots));
}

