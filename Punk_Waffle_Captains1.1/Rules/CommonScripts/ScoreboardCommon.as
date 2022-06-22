#include "ColoredNameToggleCommon.as"
#include "SpareCode.as"

f32 getKDR(CPlayer@ p)
{
	return p.getKills() / Maths::Max(f32(p.getDeaths()), 1.0f);
}

SColor getNameColour(CPlayer@ p)
{
	SColor c;
	CPlayer@ localplayer = getLocalPlayer();
	bool showColor = (p !is localplayer && isSpecial(localplayer)) || coloredNameEnabled(getRules(), p);

	if (p.isDev() && showColor) {
		c = SColor(0xffb400ff); //dev
	} else if (p.isGuard() && showColor) {
		c = SColor(0xffa0ffa0); //guard
	} else if (isAdmin(p) && showColor) {
		c = SColor(0xfffa5a00); //admin
	} else if (p.getOldGold() && !p.isBot()) {
		c = SColor(0xffffEE44); //my player
	} else {
		c = SColor(0xffffffff); //normal
	}

	if(p.getBlob() is null && p.getTeamNum() != getRules().getSpectatorTeamNum())
	{
		uint b = c.getBlue();
		uint g = c.getGreen();
		uint r = c.getRed();

		b -= 75;
		g -= 75;
		r -= 75;

		b = Maths::Max(b, 25);
		g = Maths::Max(g, 25);
		r = Maths::Max(r, 25);

		c.setBlue(b);
		c.setGreen(g);
		c.setRed(r);

	}

	return c;

}

void setSpectatePlayer(string username)
{
	CPlayer@ player = getLocalPlayer();
	CPlayer@ target = getPlayerByUsername(username);
	if((player.getBlob() is null || player.getBlob().hasTag("dead")) && player !is target && target !is null)
	{
		CRules@ rules = getRules();
		rules.set_bool("set new target", true);
		rules.set_string("new target", username);

	}

}

float drawServerInfo(float y)
{
	GUI::SetFont("menu");

	Vec2f pos(getScreenWidth()/2, y);
	float width = 200;


	CNet@ net = getNet();
	CMap@ map = getMap();
	CRules@ rules = getRules();

	string info = getTranslatedString(rules.gamemode_name) + ": " + getTranslatedString(rules.gamemode_info);
	SColor white(0xffffffff);
	string mapName = getTranslatedString("Map name : ")+rules.get_string("map_name");
	Vec2f dim;
	GUI::GetTextDimensions(info, dim);
	if(dim.x + 15 > width)
		width = dim.x + 15;

	GUI::GetTextDimensions(net.joined_servername, dim);
	if(dim.x + 15 > width)
		width = dim.x + 15;

	GUI::GetTextDimensions(mapName, dim);
	if(dim.x + 15 > width)
		width = dim.x + 15;


	pos.x -= width/2;
	Vec2f bot = pos;
	bot.x += width;
	bot.y += 95;

	Vec2f mid(getScreenWidth()/2, y);


	GUI::DrawPane(pos, bot, SColor(0xffcccccc));

	mid.y += 15;
	GUI::DrawTextCentered(net.joined_servername, mid, white);
	mid.y += 15;
	GUI::DrawTextCentered(info, mid, white);
	mid.y += 15;
	GUI::DrawTextCentered(net.joined_ip, mid, white);
	mid.y += 17;
	GUI::DrawTextCentered(mapName, mid, white);
	mid.y += 17;
	GUI::DrawTextCentered(getTranslatedString("Match time: {TIME}").replace("{TIME}", "" + timestamp((getRules().exists("match_time") ? getRules().get_u32("match_time") : getGameTime())/getTicksASecond())), mid, white);


	return bot.y;

}

string timestamp(uint s)
{
	string ret;
	int hours = s/60/60;
	if (hours > 0)
		ret += hours + getTranslatedString("h ");

	int minutes = s/60%60;
	if (minutes < 10)
		ret += "0";

	ret += minutes + getTranslatedString("m ");

	int seconds = s%60;
	if (seconds < 10)
		ret += "0";

	ret += seconds + getTranslatedString("s ");

	return ret;
}


void drawPlayerCard(CPlayer@ player, Vec2f pos)
{
	print("DrawCardPls");
	if(player!is null)
	{
		GUI::SetFont("menu");

		f32 stepheight = 8;
		Vec2f atopleft = pos;
		atopleft.x -= stepheight;
		atopleft.y -= stepheight*2;

		string statName;
        GUI::DrawPane(atopleft, Vec2f(atopleft.x + 180, (atopleft.y + (checklist.size() * 26))));
		GUI::DrawText(player.getUsername(), Vec2f(pos.x + 2, atopleft.y+10), SColor(0xffffffff));
		atopleft.y += 40;
		for (int i; i < checklist.size(); i++){
			if(i == 2 or i == 3){
				statName = (i == 3 ? "Capt Wins" : "Capt Losses");
			}
			else{
				statName = checklist[i];
			}
			GUI::DrawText(statName, Vec2f(pos.x + 2, (atopleft.y+(18*i))), SColor(0xffffffff));
			GUI::DrawText(getStats( getRules(), player, checklist[i])+"", Vec2f(pos.x + 110, atopleft.y+(18*i)), SColor(0xffffffff));
		}

	}

}
