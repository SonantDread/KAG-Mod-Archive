// make a crate that when unpacked become blobName
// inventoryName for GUI

shared CBlob@ server_MakeCrate(string blobName, string inventoryName, int frameIndex, int team, Vec2f pos, bool init = true)
{
	CBlob@ crate = server_CreateBlobNoInit("crate");

	if (crate !is null)
	{
		if(blobName == "necromancer")
		{
			crate.setPosition(pos);
			return crate;
		}
		if(blobName == "bison")
		{
			crate.setPosition(pos);
			return crate;
		}
		if(blobName == "oct")
		{
			crate.setPosition(pos);
			return crate;
		}
		if(blobName == "hayrock")
		{
			crate.setPosition(pos);
			return crate;
		}
		if(blobName == "shark")
		{
			crate.setPosition(pos);
			return crate;
		}
		if(blobName == "greg")
		{
			crate.setPosition(pos);
			return crate;
		}
		if(blobName == "abomination")
		{
			crate.setPosition(pos);
			return crate;
		}
		if(blobName == "catto")
		{
			crate.setPosition(pos);
			return crate;
		}
		if(blobName == "catto2")
		{
			crate.setPosition(pos);
			return crate;
		}
		if(blobName == "digger")
		{
			crate.setPosition(pos);
			return crate;
		}
		if(blobName == "gasbag")
		{
			crate.setPosition(pos);
			return crate;
		}
		if(blobName == "gasbag2")
		{
			crate.setPosition(pos);
			return crate;
		}
		if(blobName == "greg2")
		{
			crate.setPosition(pos);
			return crate;
		}
		if(blobName == "horror")
		{
			crate.setPosition(pos);
			return crate;
		}
		if(blobName == "pankou")
		{
			crate.setPosition(pos);
			return crate;
		}
		if(blobName == "pankou")
		{
			crate.setPosition(pos);
			return crate;
		}
		if(blobName == "pbanshee")
		{
			crate.setPosition(pos);
			return crate;
		}
		if(blobName == "pbrute")
		{
			crate.setPosition(pos);
			return crate;
		}
		if(blobName == "pcrawler")
		{
			crate.setPosition(pos);
			return crate;
		}
		if(blobName == "pcrawler2")
		{
			crate.setPosition(pos);
			return crate;
		}
		if(blobName == "pgreg")
		{
			crate.setPosition(pos);
			return crate;
		}
		if(blobName == "greg0")
		{
			crate.setPosition(pos);
			return crate;
		}
		if(blobName == "phellknight")
		{
			crate.setPosition(pos);
			return crate;
		}
		if(blobName == "skeleton")
		{
			crate.setPosition(pos);
			return crate;
		}
		if(blobName == "skeleton2")
		{
			crate.setPosition(pos);
			return crate;
		}
		if(blobName == "wraith")
		{
			crate.setPosition(pos);
			return crate;
		}
		if(blobName == "wraith2")
		{
			crate.setPosition(pos);
			return crate;
		}
		if(blobName == "zbison2")
		{
			crate.setPosition(pos);
			return crate;
		}
		if(blobName == "zbison2")
		{
			crate.setPosition(pos);
			return crate;
		}
		if(blobName == "zchicken")
		{
			crate.setPosition(pos);
			return crate;
		}
		if(blobName == "zombie")
		{
			crate.setPosition(pos);
			return crate;
		}
		if(blobName == "zombie2")
		{
			crate.setPosition(pos);
			return crate;
		}
		if(blobName == "zombiearm")
		{
			crate.setPosition(pos);
			return crate;
		}
		if(blobName == "zombieknight")
		{
			crate.setPosition(pos);
			return crate;
		}
		if(blobName == "zombieknight2")
		{
			crate.setPosition(pos);
			return crate;
		}
		if(blobName == "OCT")
		{
			crate.setPosition(pos);
			return crate;
		}
		if(blobName == "bison")
		{
			crate.setPosition(pos);
			return crate;
		}
		if(blobName == "shark")
		{
			crate.setPosition(pos);
			return crate;
		}
		
		crate.server_setTeamNum(team);
		crate.setPosition(pos);
		crate.set_string("packed", blobName);
		crate.set_string("packed name", inventoryName);
		crate.set_u8("frame", frameIndex);
		if (init)
			crate.Init();
	}

	return crate;
}

shared CBlob@ server_MakeCrateOnParachute(string blobName, string inventoryName, int frameIndex, int team, Vec2f pos)
{
	CBlob@ crate = server_MakeCrate(blobName, inventoryName, frameIndex, team, pos, false);

	if (crate !is null)
	{
		crate.Tag("parachute");
		//if (blobName == "catapult" || blobName == "ballista") {
		//  crate.Tag("unpack on land");
		//}
		crate.Init();
	}

	return crate;
}

shared Vec2f getDropPosition(Vec2f drop)
{
	drop.x += -16.0f + 32.0f * 0.01f * XORRandom(100);
	drop.y = 32.0f + 8.0f * 0.01f * XORRandom(100);; // sky
	return drop;
}

shared void PackIntoCrate(CBlob@ this, int frameIndex)
{
	server_MakeCrate(this.getName(), this.getInventoryName(), frameIndex, this.getTeamNum(), this.getPosition());
	this.server_Die();
}