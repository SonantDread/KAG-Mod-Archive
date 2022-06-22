#include "MakeSign.as"
#include "TeamIconToken.as"

// Add text and configure the bulletin in Cache/ServerBulletin.cfg

bool g_needIcons = false;

void onInit(CBlob@ this)
{
	this.addCommandID("load_bulletin_icon");
	this.addCommandID("request_bulletin_icons");

	// Todo: maybe avoid spamming server with these commands when it's disabled?
	// if (isClient() && getRules().hasTag("update_bulletin_icons")) // this tag won't always work
	if (isClient())
	{
		if (!LocalPlayerRequestIcons(this))
		{
			g_needIcons = true;
			return;
		}
	}

	// Only tick if local player was null and client
	this.getCurrentScript().tickFrequency = 0;

	if (!isServer()) return;

	ConfigFile cfg = ConfigFile();
	if (!cfg.loadFile("../Cache/ServerBulletin.cfg"))
	{
		cfg.add_bool("disabled", true);
		cfg.add_string("text", "");
		cfg.saveFile("ServerBulletin.cfg");
	}

	bool disabled;
	if (cfg.exists("disabled"))
	{
		disabled = cfg.read_bool("disabled", true);
	}
	else
	{
		disabled = true;
		cfg.add_bool("disabled", true);
	}

	CRules@ rules = getRules();
	if (!disabled)
	{
		string text;
		if (cfg.exists("text"))
		{
			array<string>@ lines = cfg.read_string("text", "").split("\n");
			for (int i = 0; i < lines.length; i++)
			{
				string line = lines[i];

				// Get rid of the indent
				if (i > 0) line = line.substr(1, line.length() - 1);

				if (line == ".") line = "";

				// Add newline unless this is the last line
				if (i+1 < lines.length) line += "\n";

				text += line;
			}

			if (cfg.exists("icons"))
			{
				CBitStream[] bulletin_icon_params;

				array<string>@ lines = cfg.read_string("icons", "").split("\n");
				for (int i = 0; i < lines.length; i++)
				{
					string line = lines[i];
					// Get rid of the indent
					if (i > 0) line = line.substr(1, line.length()-1);

					array<string>@ args = line.split(" ");
					if (args.length() < 3) continue;

					CBitStream params;
					params.write_string(args[0]);		// icon base name (heart)
					params.write_u8(parseInt(args[1])); // icon "teamnum" (3)
					params.write_string(args[2]); 		// source filename

					// 3=width and 4=height
					if (args.length() > 4)
						params.write_Vec2f(Vec2f(parseInt(args[3]), parseInt(args[4])));

					if (args.length() > 5)
						params.write_u8(parseInt(args[5]));

					bulletin_icon_params.push_back(params);
				}

				rules.set("bulletin_icon_params", @bulletin_icon_params);
			}
		}
		else
		{
			cfg.add_string("text", "");
			text = "";
		}

		if (text == "")
		{
			disabled = true;
			warn("Bulletin text not found - Put some in Cache/ServerBulletin.cfg");
		}
		else
		{
			CBlob@ sign = CreateBulletin(this, text);
			// if (sign !is null)
			// {
			// 	this.set_netid("bulletin_id", sign.getNetworkID());
			// 	this.Sync("bulletin_id", true);
			// }
		}
	}

	if (disabled)
		rules.Untag("update_bulletin_icons");

	else
		rules.Tag("update_bulletin_icons");

	// rules.Sync("update_bulletin_icons", true); // Doesn't sync in time for clients onInit?
}

void onTick(CBlob@ this)
{
	if (g_needIcons)
	{
		if (LocalPlayerRequestIcons(this))
		{
			g_needIcons = false;
			this.getCurrentScript().tickFrequency = 0;
		}
	}
	else this.getCurrentScript().tickFrequency = 0;
}

bool LocalPlayerRequestIcons(CBlob@ this)
{
	CPlayer@ player = getLocalPlayer();
	if (player is null) return false;

	CBitStream params;
	params.write_netid(getLocalPlayer().getNetworkID());
	this.SendCommandOnlyServer(this.getCommandID("request_bulletin_icons"), params);
	return true;
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("load_bulletin_icon"))
	{
		if (isClient())
		{
			// print("loaded=" + LoadIcon(params));
			LoadIcon(params);
		}
	}
	else if (cmd == this.getCommandID("request_bulletin_icons"))
	{
		if (!isServer()) return;

		CRules@ rules = getRules();
		if (!rules.hasTag("update_bulletin_icons")) return;

		u16 netid;
		if (!params.saferead_netid(netid)) return;
		CPlayer@ player = getPlayerByNetworkId(netid);
		if (player !is null && rules.exists("bulletin_icon_params"))
		{
			CBitStream[]@ bulletin_icon_params;
			rules.get("bulletin_icon_params", @bulletin_icon_params);
			for (int i = 0; i < bulletin_icon_params.length; ++i)
			{
				this.server_SendCommandToPlayer(this.getCommandID("load_bulletin_icon"),
												bulletin_icon_params[i], player);
			}
			// print("sending icons to player=" + player.getUsername());
		}
	}
}

CBlob@ CreateBulletin(CBlob@ this, string text, int x_offset=24, int y_offset=8)
{
	Vec2f pos = this.getPosition();
	CMap@ map = this.getMap();
	bool left_side = (pos.x < map.tilemapwidth * 8 / 2);
	pos.x += (left_side) ? -x_offset : x_offset + 8;
	pos.y += y_offset;

	// Move it up if blocks are in the way
	while (map.isTileSolid(pos + Vec2f(4, 0)) || map.isTileSolid(pos + Vec2f(-4, 0)))
		pos.y -= 8;

	CBlob@ sign = createSign(pos, text);
	if (!left_side)
		sign.Tag("flip_sign");
	sign.Tag("invincible");

	// // idk if I care about this
	// pos.y += 8;
	// if (!map.isTileSolid(pos + Vec2f(4, 0)))
	// 	print("pos=" + pos + "empty below right");
	// if (!map.isTileSolid(pos + Vec2f(-4, 0)))
	// 	print("pos=" + pos + "empty below left");

	return sign;
}

string LoadIcon(CBitStream @params)
{
	string icon;
	u8 teamnum;
	string filename;
	Vec2f framesize;
	u8 framenum;

	if (!params.saferead_string(icon)) return "";
	if (!params.saferead_u8(teamnum)) return "";
	if (!params.saferead_string(filename)) return "";

	if (!params.saferead_Vec2f(framesize))
		framesize = Vec2f(8, 8);

	if (!params.saferead_u8(framenum))
		framenum = 0;

	// print("icon " + icon + " " + filename 	+ " " + teamnum + " " + framesize + " " + framenum);
	return getTeamIcon(icon, filename, teamnum, framesize, framenum);
}
