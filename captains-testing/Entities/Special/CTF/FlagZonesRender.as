
#include "FlagZonesCommon.as";

const string zoneTextureName = "zone_texture";

int global_id;

// Vec2f[][]	floating_zones;

int zone_count = 0;
Vec2f[]		floating_v_pos;
Vec2f[]		floating_v_uv;
SColor[]	floating_v_col;
u16[]		floating_v_i;

enum ZoneRenderIndices
{
	ul = 0,
	ur,
	lr,
	ll,
	ul2,
	ur2,
	lr2,
	ll2
}

void RenderFlagZoneEdges(CBlob@ this, int id)
{
	array<Vec2f>@ old_v_pos;
	array<Vec2f>@ old_v_uv;
	array<SColor>@ old_v_col;
	array<u16>@ old_v_i;
	if (this.hasTag("keep_zone_render"))
	{
		this.get("v_pos", @old_v_pos);
		this.get("v_uv", @old_v_uv);
		this.get("v_col", @old_v_col);
		this.get("v_i", @old_v_i);
		Render::SetAlphaBlend(true);
		Render::TrianglesColoredIndexed(zoneTextureName, 1, // Do I care about the Z?
										old_v_pos, old_v_uv, old_v_col, old_v_i);
	}
	else
	{
		SetupTexture();

		array<Vec2f> v_pos;
		array<Vec2f> v_uv;
		array<SColor> v_col;
		array<u16> v_i;
		CMap::Sector@ zone = getMyZone(this, getMap());
		if (zone is null || zone.name == "no build")
		{
			Render::RemoveScript(id);
			return;
		}

		AddTrisFromZone(zone.upperleft, zone.lowerright, 0, @v_pos, @v_uv, @v_col, @v_i);

		this.set("v_pos", @v_pos);
		this.set("v_uv", @v_uv);
		this.set("v_col", @v_col);
		this.set("v_i", @v_i);
		this.Tag("keep_zone_render");
		// print("z=" + this.getSprite().getZ());

		// Render::RemoveScript(id);
	}
}

void RenderOwnerlessZone(int id)
{
	CRules@ rules = getRules();
	if (rules.hasTag("new_floating_zones"))
	{
		if (rules.hasTag("remove_old_floating_zones"))
		{
			// print("Removing old zones...");
			rules.Untag("remove_old_floating_zones");
			floating_v_pos.clear();
			floating_v_uv.clear();
			floating_v_col.clear();
			floating_v_i.clear();
			zone_count = 0;

			// floating_zones.clear();
		}
		AddFloatingZones(rules);
		rules.Untag("new_floating_zones");
	}

	Render::SetAlphaBlend(true);
	Render::TrianglesColoredIndexed(zoneTextureName, 1, // Do I care about the Z?
									floating_v_pos,
									floating_v_uv,
									floating_v_col,
									floating_v_i);
									// old_v_pos, old_v_uv, old_v_col, old_v_i);
}

void AddFloatingZones(CRules@ rules)
{
	Vec2f[][]@ new_zones;
	if (rules.exists("new_zones"))
		rules.get("new_zones", @new_zones);
	// else
	// 	print("WTF? there's no zones");

	// print("trying to add, new_zones=" + new_zones.length);

	for (int i = 0; i < new_zones.length; ++i)
	{
		Vec2f[]@ floating_zone = new_zones[i];

		// for (int i = 0; i < floating_zone.length; ++i)
		// {
		// 	print("Corner=" + floating_zone[i]);
		// }

		if (floating_zone.length > 1)
		{
			SetupTexture();
			AddTrisFromZone(floating_zone[0], floating_zone[1], zone_count,
							@floating_v_pos, @floating_v_uv,
							@floating_v_col, @floating_v_i);
			zone_count++;
		}
		// else
		// {
		// 	print("Ehhhh?");
		// }

		// floating_zones.push_back(floating_zone);
		// print("zones=" + floating_zones.length + " vertices=" + floating_v_pos.length);
		// for (int i = 0; i < floating_zones.length; ++i)
		// {
		// 	print("	zone=" + floating_zones[i][0] + " " + floating_zones[i][1]);
		// }
	}
	new_zones.clear();
}

void AddTrisFromZone(Vec2f upperleft, Vec2f lowerright, int i, // Which zone is this?
					 Vec2f[]@ v_pos_out, Vec2f[]@ v_uv_out, SColor[]@ v_col_out, u16[]@ v_i_out)
{
	int width = lowerright.x - upperleft.x;
	int height = lowerright.y - upperleft.y;

	const int thicc = 16;

	// Outer corners
	v_pos_out.push_back(upperleft);									// 0 - ul
	v_pos_out.push_back(upperleft + Vec2f(width, 0));				// 1 - ur
	v_pos_out.push_back(lowerright);								// 2 - lr
	v_pos_out.push_back(upperleft + Vec2f(0, height));				// 3 - ll
	// Inner corners
	v_pos_out.push_back(upperleft + Vec2f(thicc, thicc));			// 4 - ul2
	v_pos_out.push_back(upperleft + Vec2f(width-thicc, thicc));		// 5 - ur2
	v_pos_out.push_back(lowerright + Vec2f(-thicc, -thicc));		// 6 - lr2
	v_pos_out.push_back(upperleft + Vec2f(thicc, height-thicc));	// 7 - ll2

	// Outer corners
	v_uv_out.push_back(Vec2f(0, 0));
	v_uv_out.push_back(Vec2f(1, 0));
	v_uv_out.push_back(Vec2f(1, 1));
	v_uv_out.push_back(Vec2f(0, 1));
	// Inner corners
	v_uv_out.push_back(Vec2f(0.1, 0.1));
	v_uv_out.push_back(Vec2f(0.9, 0.1));
	v_uv_out.push_back(Vec2f(0.9, 0.9));
	v_uv_out.push_back(Vec2f(0.1, 0.9));

	v_col_out.push_back(SColor(0x4fff00ff));
	v_col_out.push_back(SColor(0x4fff00ff));
	v_col_out.push_back(SColor(0x4fff00ff));
	v_col_out.push_back(SColor(0x4fff00ff));
	v_col_out.push_back(SColor(0x00ff00ff));
	v_col_out.push_back(SColor(0x00ff00ff));
	v_col_out.push_back(SColor(0x00ff00ff));
	v_col_out.push_back(SColor(0x00ff00ff));

	// Top quad
	v_i_out.push_back(ul + 8 * i);
	v_i_out.push_back(ur + 8 * i);
	v_i_out.push_back(ur2 + 8 * i);
	v_i_out.push_back(ul + 8 * i);
	v_i_out.push_back(ur2 + 8 * i);
	v_i_out.push_back(ul2 + 8 * i);

	// Right quad
	v_i_out.push_back(ur + 8 * i);
	v_i_out.push_back(lr + 8 * i);
	v_i_out.push_back(lr2 + 8 * i);
	v_i_out.push_back(ur + 8 * i);
	v_i_out.push_back(lr2 + 8 * i);
	v_i_out.push_back(ur2 + 8 * i);

	// Bottom quad
	v_i_out.push_back(lr + 8 * i);
	v_i_out.push_back(ll + 8 * i);
	v_i_out.push_back(ll2 + 8 * i);
	v_i_out.push_back(lr + 8 * i);
	v_i_out.push_back(ll2 + 8 * i);
	v_i_out.push_back(lr2 + 8 * i);

	// Left quad
	v_i_out.push_back(ll + 8 * i);
	v_i_out.push_back(ul + 8 * i);
	v_i_out.push_back(ul2 + 8 * i);
	v_i_out.push_back(ll + 8 * i);
	v_i_out.push_back(ul2 + 8 * i);
	v_i_out.push_back(ll2 + 8 * i);
}

void SetupTexture()
{
	if(!Texture::exists(zoneTextureName))
	{
		if(!Texture::createBySize(zoneTextureName, 1, 1))
		{
			warn("texture creation failed");
		}
		else
		{
			ImageData@ edit = Texture::data(zoneTextureName);

			for(int i = 0; i < edit.size(); i++)
			{
				edit[i] = SColor(0xffffffff);
			}

			if(!Texture::update(zoneTextureName, edit))
			{
				warn("texture update failed");
			}
		}
	}
}
