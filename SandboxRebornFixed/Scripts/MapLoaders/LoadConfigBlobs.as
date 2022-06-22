void onInit(CRules@ this)
{
	this.set_bool("blobs created", false);
	this.set_u32("current", 0);
}
void onRestart(CRules@ this)
{
	this.set_bool("blobs created", false);
	this.set_u32("current", 0);
}
void onTick(CRules@ this)
{
	bool done = this.get_bool("blobs created");
	if(!done)
	{
		string filename = getMap().getMapName();

		u32 current = this.get_u32("current");

		ConfigFile cfg = ConfigFile();
		string filenameonly = getFilenameWithoutExtension(filename);
		string cfgFileName = "sbr/"+filenameonly+".cfg";

		if (cfg.loadFile("../Cache/" + cfgFileName))
		{
			u32 blob_count = cfg.read_u32("blob_count");
			//error("blob_count: "+blob_count);
			if(current < blob_count)
			{
				u16 chunk = Maths::Min(10, blob_count - current);
				for(uint e = 0; e < chunk; e++)
				{
					u32 i = current;
					current++;
					f32 pos_x = cfg.read_f32("pos_x"+i);
					f32 pos_y = cfg.read_f32("pos_y"+i);
					f32 vel_x = cfg.read_f32("vel_x"+i);
					f32 vel_y = cfg.read_f32("vel_y"+i);
					s32 team = cfg.read_s32("team"+i);
					f32 angle = cfg.read_f32("angle"+i);
					u32 health = cfg.read_u32("health"+i);
					string blob_name = cfg.read_string("name"+i);

					Vec2f pos = Vec2f(pos_x, pos_y);
					Vec2f vel = Vec2f(vel_x, vel_y);
					if(blob_name != "bush" && blob_name != "bison" && blob_name != "tree_pine" && blob_name != "tree_bushy" && blob_name != "spawnpoint" && blob_name != "grain_plant" &&  blob_name != "wooden_platform")
					{
						CBlob@ blob = server_CreateBlob(blob_name, team, pos);
						if(blob !is null)
						{
							//print("created "+blob_name+" "+current);
							blob.setVelocity(vel);
							blob.server_SetHealth(health);
							blob.setAngleDegrees(angle);
							if(cfg.exists("player"+i))
							{
								string playername = cfg.read_string("player"+i);
								CPlayer@ player = getPlayerByUsername(playername);
								if(player !is null)
								{
									CBlob@ lastblob = player.getBlob();
									if(lastblob !is null)
									{
										lastblob.server_SetPlayer(null);
										blob.server_SetPlayer(player);
										error("player set!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
									}
								}
							}
						}
					}

				}
			}


			this.set_u32("current", current);
		}
		else
		{
			(error("no file exists"));
			this.set_bool("blobs created", true);
		}

	}
}