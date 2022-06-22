#define CLIENT_ONLY

#include "KnightCommon.as";
#include "CharmSizeCommon.as";

void onTick(CRules@ this)
{
		if (getLocalPlayer() is null)
			return;

		CBlob@ blob = getLocalPlayer().getBlob();

		if (blob is null)
			return;

		CControls@ controls = blob.getControls();

		string username = getLocalPlayer().getUsername();

		if (blob.isKeyPressed(key_action1) && blob !is null && (blob.isKeyJustPressed(key_action1) || this.get_bool(username + "fclick")))
		{
			Vec2f cursor = controls.getMouseScreenPos();

			const string image = "plusandminus.png";

			if(cursor.x > 56 && cursor.x < 96 && cursor.y > 156 && cursor.y < 198)
			{
				username = getLocalPlayer().getUsername();

				CBitStream bs7;
				bs7.write_string(username);

				if (this.get_bool(username + "fclick") == false)
				{
					this.set_u32(username + "_ctime", getGameTime());
					this.SendCommand(this.getCommandID("smaller icons"), bs7);

					u32 gtime = getGameTime();

					this.set_bool(username + "fclick", true);

					bool temporary = true;

					CBitStream bs6;
					bs6.write_string(username);
					bs6.write_u32(gtime);
					bs6.write_bool(temporary);

					this.SendCommand(this.getCommandID("sync fclick"), bs6);
				}

				if(getGameTime() > this.get_u32(username + "_ctime") + 22 && getGameTime() % 5 == 0 && this.get_bool(username + "fclick"))
				{
					this.SendCommand(this.getCommandID("smaller icons"), bs7);
				}
			}
			
			if(cursor.x > 16 && cursor.x < 48 && cursor.y > 156 && cursor.y < 198)
			{
				username = getLocalPlayer().getUsername();
				
				CBitStream bs;
				bs.write_string(username);

				if (this.get_bool(username + "fclick") == false)
				{
					this.set_u32(username + "_ctime", getGameTime());
					this.SendCommand(this.getCommandID("bigger icons"), bs);

					u32 gtime = getGameTime();

					this.set_bool(username + "fclick", true);

					bool temporary = true;

					CBitStream bs2;
					bs2.write_string(username);
					bs2.write_u32(gtime);
					bs2.write_bool(temporary);

					this.SendCommand(this.getCommandID("sync fclick"), bs2);
				}

				if(getGameTime() > this.get_u32(username + "_ctime") + 22 && getGameTime() % 5 == 0 && this.get_bool(username + "fclick"))
				{
					this.SendCommand(this.getCommandID("bigger icons"), bs);
				}
			}
		}
		else
		{

			this.set_bool(username + "fclick", false);

			bool temporary = false;

			u32 gtime = getGameTime();

			CBitStream bs3;
			bs3.write_string(username);
			bs3.write_u32(gtime);
			bs3.write_bool(temporary);

			this.SendCommand(this.getCommandID("sync fclick"), bs3);
		}

}

void onRender(CRules@ this)
{
		if (getLocalPlayer() is null)
			return;

		string username = getLocalPlayer().getUsername();

		const string image = "plusandminus.png";

		GUI::DrawRectangle(Vec2f(16, 156), Vec2f(48, 188));
		GUI::DrawIcon(image, 1, Vec2f(32, 32), Vec2f(16, 156), 0.5f);

		GUI::DrawRectangle(Vec2f(56, 156), Vec2f(88, 188));
		GUI::DrawIcon(image, 0, Vec2f(32, 32), Vec2f(56, 156), 0.5f);

		this.Sync(username + "_size", true);

		GUI::DrawText("Resize charm icons\nCurrent size: " + this.get_f32(username + "_size"), Vec2f(96, 156), color_white);


	//if(isClient())
	//{	
	/*	CPlayer@ player = getLocalPlayer();

		if (player is null)
			return;

		CBlob@ blob = player.getBlob();

		if (blob is null)
			return;

		CControls@ controls = blob.getControls();

		if (controls is null)
			return;

		string username = "HomekGod";

		if (showresize)
		{
			CGridMenu@ menu = CreateGridMenu(Vec2f(120, 16), blob, Vec2f(1, 2), "Icon Size");
			printf("hi4");

			CBitStream bs;
			bs.write_string(username);

			if (button is null && buttond is null && menu !is null)
			{
				CGridButton@ button = menu.AddButton("ScoreboardIcons.png", 0, "-", this.getCommandID("smaller icons"), bs);
				CGridButton@ buttond = menu.AddButton("ScoreboardIcons.png", 1, "+", this.getCommandID("bigger icons"), bs);

				printf("hi5");
			}
		}/*
	//}

	/*if (button !is null)
	{
		if(rules.get_bool(charm_user) == true)
		{
			button.SetSelected(1);
			printf("Bruh?");
		}
		else if(rules.get_bool(charm_user) == false && pcharm.slots > rules.get_u8(charm_user_slots))
		{
			button.SetEnabled(false);
			printf("bruh!");
		}
	}*/
}

void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
		if (cmd == this.getCommandID("smaller icons"))
		{
			string username;

			if (!params.saferead_string(username))
			{
				print("failed to parse some shit");
				return;
			}

			if(this.get_f32(username + "_size") > 1.0f)
			{
				this.set_f32(username + "_size", this.get_f32(username + "_size") - 0.1f);
				if(getPlayerByUsername(username).isMyPlayer())
					Sound::Play("buttonclick.ogg");
				this.Sync(username + "_size", true);
			}
		}

		if (cmd == this.getCommandID("bigger icons"))
		{
			string username;

			if (!params.saferead_string(username))
			{
				print("failed to parse some shit");
				return;
			}

			if(this.get_f32(username + "_size") < 2.95f)
			{
				this.set_f32(username + "_size", this.get_f32(username + "_size") + 0.1f);
				if(getPlayerByUsername(username).isMyPlayer())
					Sound::Play("buttonclick.ogg");
				this.Sync(username + "_size", true);
			}
		}
}