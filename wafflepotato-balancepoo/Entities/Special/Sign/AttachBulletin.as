#include "MakeSign.as"
#include "TeamIconToken.as"

const string default_text = "Add text to Cache/ServerBulletin.cfg\n\n...or modify \nAttachBulletin.as";

const bool ignore_cfg = true;
const bool use_custom_text = true;
const string custom_text = ""
						 + "$ballista$ + Faster capping\n"
						 + "                 Harder to unpack\n\n"
						 + "$WaterArrow$ $WaterBomb$ + Knockback\n"
						 + "                  - Stun nerfed\n"
						 + "                    (you can still act)\n"
						 + "$FireArrow$\n"
						 + "        + Spreads from player\n"
						 + "            to player, does "
						 + "$heart1$"
						 + "$heart3$" + "\n"
						 + "\n$killfeed_fire$$KEY_D$$KEY_A$ to change\n"
						 + "                                 direction\n"
						 + "\n" + "$tunnel3$"
						 + " + 250 stone only\n"
						 + "                     - Decays in 150s\n\n"
						 + "$quarry3$"
						 + " + Quarry rework\n"
						 + "                         (faster at mid)\n"
						 + "\n$trampoline$ Weaker horizontal\n"
						 + "                $KEY_SPACE$ keep angle\n"
						 + "$saw$\n"
						 + "                - Sawjump nerfed\n"
						 + "\n$crate$$mat_bombarrows$ Crate acts \n"
						 + "                          as quiver"
						 ;

void onInit(CBlob@ this)
{
	if (!isServer()) 
	{
		// Hack in some icons to make sure they load
		getTeamIcon("heart", "GUI/HeartNBubble.png", 1, Vec2f(12, 12), 1);
		getTeamIcon("heart", "GUI/HeartNBubble.png", 3, Vec2f(12, 12), 3);
		getTeamIcon("tunnel", "Tunnel.png", 3, Vec2f(40, 24));
		getTeamIcon("quarry", "Quarry.png", 3, Vec2f(40, 24), 4);
		return;
	}

	if (ignore_cfg)
	{
		if (use_custom_text)
			CreateBulletin(this, custom_text);
		return;
	}

	ConfigFile cfg = ConfigFile();
	if (!cfg.loadFile("../Cache/ServerBulletin.cfg"))
	{
		cfg.add_bool("disabled", true);
		cfg.add_string("text", "");
		cfg.saveFile("ServerBulletin.cfg");
	}
	else if (cfg.exists("disabled"))
	{
		if (cfg.read_bool("disabled", true)) 
			return;

		string text;
		if (use_custom_text && !(cfg.exists("override_custom_text")
								 && cfg.read_bool("override_custom_text", false)))
		{
			text = custom_text;
		}
		else
		{
			if (cfg.exists("text"))
			{
				text = cfg.read_string("text", "");
			}
			else
			{
				cfg.add_string("text", "");
				text = "";
			}

			if (text == "")
			{
				text = default_text;
			}
		}

		CreateBulletin(this, text);
	}
	else
	{
		cfg.add_bool("disabled", true);
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

	// // idk if I care about this
	// pos.y += 8;
	// if (!map.isTileSolid(pos + Vec2f(4, 0)))
	// 	print("pos=" + pos + "empty below right");
	// if (!map.isTileSolid(pos + Vec2f(-4, 0)))
	// 	print("pos=" + pos + "empty below left");

	return sign;
}
