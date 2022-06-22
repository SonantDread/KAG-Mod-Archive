#include "StandardControlsCommon.as"
#include "ArcherCommon.as"
#include "Explosion.as"
#include "MakeDustParticle.as"
#include "KnockedCommon.as"
#include "CharmCommon.as"
#include "EmotesCommon.as"

void onInit(CBlob@ this)
{
	this.addCommandID("multiply force");
	this.addCommandID("act 3");
	this.addCommandID("stasis field");
	this.addCommandID("summon arrows");
	this.addCommandID("killer queen");
	this.addCommandID("swap places");
	this.addCommandID("teleport charm");
}

//Disable highlighting for items with a map luminance lower than this
const uint map_luminance_threshold = 40;

//Update latency in ticks, optimization, should be at least 3
//This is also used as the delay before useful materials shine
const uint update_latency = 15;

//The ticks spent since pressing [C]
uint ticks_since_pressed = 0;

//Double-buffering logic
u16[] highlighted_blobs_buf1, highlighted_blobs_buf2;
u16[]@ front_buffer = @highlighted_blobs_buf1;

//Blobs being processed for the back buffer. Updated on the first update stage.
u16[] processed_blobs;

void onTick(CSprite@ sprite)
{
	CMap@ map = getMap();
	CBlob@ playerblob = sprite.getBlob();
	CPlayer@ player = playerblob.getPlayer();

	CRules@ rules = getRules();

	CControls@ controls = playerblob.getControls();

	if (map is null || player is null || !player.isMyPlayer()) return;

	if (controls.isKeyPressed(getKey(rules.get_string("key_swapplacescharm_" + player.getUsername()))) && rules.get_bool("swapplacescharm_" + player.getUsername()))
	{
		u16[]@ back_buffer = front_buffer is @highlighted_blobs_buf1 ? @highlighted_blobs_buf2 : @highlighted_blobs_buf1;

		const u8 current_stage = ticks_since_pressed++ % update_latency;
		if (current_stage == 0)
		{
			Driver@ driver = getDriver();
			Vec2f world_lowerright = driver.getWorldPosFromScreenPos(driver.getScreenDimensions());
			Vec2f world_upperleft = driver.getWorldPosFromScreenPos(Vec2f_zero);

			CBlob@[] collected_blobs;
			map.getBlobsInBox(world_lowerright, world_upperleft, collected_blobs);
			processed_blobs.clear();
			for (uint i = 0; i < collected_blobs.length; i++)
			{
				processed_blobs.push_back(collected_blobs[i].getNetworkID());
			}
		}

		for (uint i = current_stage; i < processed_blobs.length; i += update_latency)
		{
			CBlob@ blob = getBlobByNetworkID(processed_blobs[i]);
			if (blob !is null && !blob.isInInventory() && !blob.hasTag("player") && !blob.isMyPlayer())
			{
				back_buffer.push_back(blob.getNetworkID());
			}
		}

		//Swap out buffers and clear the new backbuffer
		if (current_stage == update_latency - 1)
		{
			front_buffer.clear();
			@front_buffer = @back_buffer;
		}
	}
	else
	{
		ticks_since_pressed = 0;
	}
}

void onRender(CSprite@ this)
{
	Vec2f pos = this.getBlob().getPosition();
	Vec2f mouse_pos = getControls().getMouseWorldPos();
	Vec2f mouse_screen = getControls().getMouseScreenPos();
	Vec2f draw_pos(0,0);
	Vec2f player_screen_pos = getDriver().getScreenPosFromWorldPos(pos);
	CCamera@ camera = getCamera();
	f32 zoom = camera.targetDistance;

	CRules@ rules = getRules();

	if (rules is null || this.getBlob() is null) return;

	CMap@ map = getMap();
	CPlayer@ player = this.getBlob().getPlayer();
	CControls@ controls = this.getBlob().getControls();
	float screen_size_y = getDriver().getScreenHeight();
    float resolution_scale = screen_size_y / 720.f;

	if (player is null || map is null || controls is null) return;

	if (controls.isKeyPressed(KEY_LCONTROL) /*&& insert charm check here*/)
	{
		CBlob@[] targets;
		f32 radius = 16.0f;
		if (map.getBlobsInRadius(mouse_pos, radius, @targets))
		{
			for (int i = 0; i < targets.length(); i++)
			{
				CBlob@ blob = targets[i];
				if (blob.getInventory() !is null)
				{
					DrawInventoryOfBlob(blob);
					break;
				}
			}
		}	
	}

	f32 diameter = 0;

	if  (controls.isKeyPressed(getKey(rules.get_string("key_velocity3xcharm_" + player.getUsername())))) diameter = 32.0f;

	if  (controls.isKeyPressed(getKey(rules.get_string("key_heavycharm_" + player.getUsername())))) diameter = 48.0f;

	if  (controls.isKeyPressed(getKey(rules.get_string("key_stasischarm_" + player.getUsername())))) diameter = (88.0f)*2;

	if  (controls.isKeyPressed(getKey(rules.get_string("key_swapplacescharm_" + player.getUsername())))) diameter = 32.0f;

	if  (controls.isKeyPressed(getKey(rules.get_string("key_teleportcharm_" + player.getUsername())))) diameter = 18.0f;

	map.rayCastSolid(pos, mouse_pos, draw_pos);

	Vec2f draw_world_pos = draw_pos;

	draw_pos = getDriver().getScreenPosFromWorldPos(draw_pos);

	if (diameter > 0 && (
		(controls.isKeyPressed(getKey(rules.get_string("key_velocity3xcharm_" + player.getUsername()))) && rules.get_bool("velocity3xcharm_" + player.getUsername()) && getGameTime() - getRules().get_u32("velocity3xcharm_cd"+player.getUsername()) > getCharmByName("velocity3xcharm").cooldown)
	||	(controls.isKeyPressed(getKey(rules.get_string("key_heavycharm_" + player.getUsername()))) && rules.get_bool("heavycharm_" + player.getUsername()) && getGameTime() - getRules().get_u32("heavycharm_cd" +player.getUsername()) > getCharmByName("heavycharm").cooldown )
	||	(controls.isKeyPressed(getKey(rules.get_string("key_stasischarm_" + player.getUsername()))) && rules.get_bool("stasischarm_" + player.getUsername()) && getGameTime() - getRules().get_u32("stasischarm_cd"+player.getUsername()) > getCharmByName("stasischarm").cooldown)
	||  (controls.isKeyPressed(getKey(rules.get_string("key_swapplacescharm_" + player.getUsername()))) && rules.get_bool("swapplacescharm_" + player.getUsername()) && getGameTime() - getRules().get_u32("swapplacescharm_cd" + player.getUsername()) > getCharmByName("swapplacescharm").cooldown)
	||  (controls.isKeyPressed(getKey(rules.get_string("key_teleportcharm_" + player.getUsername()))) && rules.get_bool("teleportcharm_" + player.getUsername()) && getGameTime() - getRules().get_u32("teleportcharm_cd" + player.getUsername()) > getCharmByName("teleportcharm").cooldown)
	))
	{
		set_emote(this.getBlob(), Emotes::off);

		Vec2f testg = (draw_world_pos.Length() > pos.Length()) ? (draw_world_pos - pos) : (pos - draw_world_pos);
		f32 lenf = testg.Length();

		Vec2f distance = draw_world_pos - pos;

		if(controls.isKeyPressed(getKey(rules.get_string("key_teleportcharm_" + player.getUsername()))) && lenf < 160.0f && getGameTime() - getRules().get_u32("teleportcharm_cd" + player.getUsername()) > getCharmByName("teleportcharm").cooldown)
		{
			GUI::DrawCircle(getDriver().getScreenPosFromWorldPos(pos + distance), diameter * zoom * resolution_scale, SColor(255, 255, 125, 125));
			GUI::DrawLine(pos, pos + distance, SColor(255, 255, 125, 125));

			CBlob @rBlob = this.getBlob();

			if (rBlob !is null)
			{
				rBlob.RenderForHUD(pos + distance - pos, RenderStyle::outline);
			}
			//printf("ting!" + draw_pos);
		}
		else if(controls.isKeyPressed(getKey(rules.get_string("key_teleportcharm_" + player.getUsername()))) && getGameTime() - getRules().get_u32("teleportcharm_cd" + player.getUsername()) > getCharmByName("teleportcharm").cooldown)
		{
			Vec2f temporary = distance;
			temporary.Normalize();

			temporary *= 160;

			temporary = pos + temporary;

			//temporary *= 100.0f;
			//printf("drawpos!" + draw_pos + "hehe" + pepega);
			GUI::DrawCircle(getDriver().getScreenPosFromWorldPos(temporary), diameter * zoom * resolution_scale, SColor(255, 255, 125, 125));
			GUI::DrawLine(pos, temporary, SColor(255, 255, 125, 125));

			CBlob @rBlob = this.getBlob();

			if (rBlob !is null)
			{
				rBlob.RenderForHUD(temporary - pos, RenderStyle::outline);
			}

		}
		else if(controls.isKeyPressed(getKey(rules.get_string("key_swapplacescharm_" + player.getUsername()))) && lenf < 250.0f && getGameTime() - getRules().get_u32("swapplacescharm_cd" + player.getUsername()) > getCharmByName("swapplacescharm").cooldown)
		{
			GUI::DrawCircle(getDriver().getScreenPosFromWorldPos(pos + distance), diameter * zoom * resolution_scale, SColor(255, 255, 125, 125));
			GUI::DrawLine(pos, pos + distance, SColor(255, 255, 125, 125));
		}
		else if(controls.isKeyPressed(getKey(rules.get_string("key_swapplacescharm_" + player.getUsername()))) && getGameTime() - getRules().get_u32("swapplacescharm_cd" + player.getUsername()) > getCharmByName("swapplacescharm").cooldown)
		{
			Vec2f temporary = distance;
			temporary.Normalize();

			temporary *= 250;

			temporary = pos + temporary;

			//temporary *= 100.0f;
			//printf("drawpos!" + draw_pos + "hehe" + pepega);
			GUI::DrawCircle(getDriver().getScreenPosFromWorldPos(temporary), diameter * zoom * resolution_scale, SColor(255, 255, 125, 125));
			GUI::DrawLine(pos, temporary, SColor(255, 255, 125, 125));

		}
		else 
		{			
			GUI::DrawCircle(draw_pos, diameter * zoom * resolution_scale, SColor(255, 255, 125, 125));
			GUI::DrawLine(pos, draw_world_pos, SColor(255, 255, 125, 125));
		}

	}

	if(controls.isKeyPressed(getKey(rules.get_string("key_swapplacescharm_" + player.getUsername()))) && getGameTime() - getRules().get_u32("swapplacescharm_cd" + player.getUsername()) > getCharmByName("swapplacescharm").cooldown)
	{
		set_emote(this.getBlob(), Emotes::off);
		if (!player.isMyPlayer() || ticks_since_pressed <= update_latency) return;

		const float base_brightness = Maths::Abs(Maths::Sin((ticks_since_pressed - update_latency) / 20.0f));

		for (uint i = 0; i < front_buffer.length; ++i)
		{
			CBlob@ blob = getBlobByNetworkID(front_buffer[i]);

			//Check for conditions that might have been invalidated recently!
			if (blob is null || blob.isInInventory()) continue;

			const u8 map_luminance = map.getColorLight(blob.getPosition()).getLuminance();
			if (map_luminance >= map_luminance_threshold)
			{
				//Fading effect, brightness depends on the map color
				const uint effect_brightness = base_brightness * map_luminance;

				//Render the normal and light effects

					Vec2f pos(0,0);
					Vec2f player_pos = this.getBlob().getPosition();
					Vec2f mouse_pos = controls.getMouseWorldPos();

					map.rayCastSolid(player_pos, mouse_pos, pos);

					CBlob@[] targets;
					f32 radius = 16.0f;
					if (!map.getBlobsInRadius(pos, radius, @targets))
						return;

					u16 count = 0;

					for (int i = 0; i < targets.length(); i++)
					{
						CBlob@ blobt = targets[i];

						if (blobt is null || blobt.getTeamNum() == player.getTeamNum() || !blobt.hasTag("player")) 
						{
							targets.removeAt(i);
							continue;
						}
						/*if (blob.getShape().isStatic())
						{
							targets.removeAt(i);
							continue;
						}
						*/

						Vec2f targetpos = blobt.getPosition();
						Vec2f ourpos = player.getBlob().getPosition();

						count++;

						if (targetpos == ourpos) continue;

						if (map.rayCastSolid(pos, targetpos)) continue;

						if (map.rayCastSolid(pos, blobt.getPosition())) continue;

						blobt.RenderForHUD(Vec2f_zero, 0.0f, SColor(255, map_luminance, map_luminance, map_luminance), RenderStyle::normal);
						blobt.RenderForHUD(Vec2f_zero, 0.0f, SColor(255, effect_brightness, effect_brightness, effect_brightness / 2), RenderStyle::light);

						break;
					}
			}
		}
	}
}

void onTick(CBlob@ this)
{
	CControls@ controls = getControls();
	CMap@ map = getMap();
	CPlayer@ player = this.getPlayer();
	CRules@ rules = getRules();

	if (controls is null || map is null || player is null) return;

	if (!rules.exists("playercharms_" + player.getUsername()))
	{
		PlayerCharm[] charms;
		rules.set("playercharms_" + player.getUsername(), charms);
		rules.Sync("playercharms_" + player.getUsername(), true);
	}

	PlayerCharm[]@ charms;

	if (this.get("playercharms_" + player.getUsername(), @charms))
	{
		for (uint i = 0 ; i < charms.length; i++)
		{
			PlayerCharm @pcharm = charms[i];

			if (pcharm.active == false) continue;

			if(rules.get_u32(pcharm.configFilename + "_cd" + player.getUsername()) > (pcharm.cooldown + 5))
			{
				rules.set_u32(pcharm.configFilename + "_cd" + player.getUsername(), 1);
				rules.Sync(pcharm.configFilename + "_cd" + player.getUsername(), true);
				printf("hihi");
			}
		}
	}

	if (getGameTime() - this.get_u32("summon arrows time") > 300 
	|| controls.isKeyJustPressed (getKey(rules.get_string("key_arrowraincharm_" + player.getUsername())))) 
		this.Untag("summoning arrows");

	if (getGameTime()%5 == 0 && this.hasTag("summoning arrows"))
	{
		u8 arrowType = ArrowType::normal;
		if (hasArrows(this, arrowType)) 
		{
			bool play_sound;
			
			Vec2f ray = this.getAimPos() - this.getPosition();
			ray.Normalize();
		
			f32 angle = ray.Angle();
			angle += 0;

			Vec2f vel (20.0f, 0.0f);
			vel.RotateByDegrees(-angle);

			f32 max_radius = 56.0f;
			Vec2f offset(XORRandom(max_radius*10)/10, 0);
			angle = XORRandom(3600)/10;
			offset.RotateByDegrees(angle);

			Vec2f spawn_pos = this.getPosition() + offset;

			if (!map.rayCastSolid(this.getPosition(), spawn_pos, spawn_pos))
			{
				if (isServer())
				{
					CBlob@ arrow = CreateArrow(this, spawn_pos, vel, ArrowType::normal);
					this.TakeBlob(arrowTypeNames[arrowType], 1);
				}
				play_sound = true;
			}
			
			if (play_sound) this.getSprite().PlaySound("Entities/Characters/Archer/BowFire.ogg");
		}
		else 
		{
			this.Untag("summoning arrows");
			this.Sync("summoning arrows", true);
		}
		
	}

	if (player !is getLocalPlayer()) return;

	if (rules.get_u32("buytime_" + player.getUsername()) > getGameTime())
	{
		rules.set_u32("buytime_" + player.getUsername(), 1);
		rules.Sync("buytime_" + player.getUsername(), true);
	}

	if (rules.get_u32("buytime_" + player.getUsername()) + 40 > getGameTime())
	{
		return;
	}

	if(isClient())
	{
		if(getHUD().hasMenus())
		return;
	}

	bool force_mult = controls.isKeyJustReleased(getKey(rules.get_string("key_velocity3xcharm_" + player.getUsername()))) && getGameTime() - getRules().get_u32("velocity3xcharm_cd"+player.getUsername()) > getCharmByName("velocity3xcharm").cooldown && hasCharm(player, getCharmByName("velocity3xcharm"));
	bool act_three = controls.isKeyJustReleased(getKey(rules.get_string("key_heavycharm_" + player.getUsername()))) && getGameTime() - getRules().get_u32("heavycharm_cd" +player.getUsername()) > getCharmByName("heavycharm").cooldown && hasCharm(player, getCharmByName("heavycharm"));
	bool swap_places = controls.isKeyJustReleased(getKey(rules.get_string("key_swapplacescharm_" + player.getUsername()))) && getGameTime() - getRules().get_u32("swapplacescharm_cd" + player.getUsername()) > getCharmByName("swapplacescharm").cooldown && hasCharm(player, getCharmByName("swapplacescharm"));
	bool teleport = controls.isKeyJustReleased(getKey(rules.get_string("key_teleportcharm_" + player.getUsername()))) && getGameTime() - getRules().get_u32("teleportcharm_cd" + player.getUsername()) > getCharmByName("teleportcharm").cooldown && hasCharm(player, getCharmByName("teleportcharm"));

	if (force_mult || act_three || swap_places)
	{
		set_emote(this, Emotes::off);
		//print("key pressed");
		//print("game time: "+getGameTime());

		PlayerCharm@ charm = getCharmByName(force_mult ? "velocity3xcharm" : act_three ? "heavycharm" : "swapplacescharm");

		Vec2f pos(0,0);
		Vec2f player_pos = this.getPosition();
		Vec2f mouse_pos = controls.getMouseWorldPos();

		map.rayCastSolid(player_pos, mouse_pos, pos);

		Vec2f temporary = pos - player_pos;
		f32 len = temporary.Length();
		if (len > charm.range)
		{
			temporary.Normalize();

			temporary *= charm.range;

			pos = player_pos + temporary;
		}
		CBlob@[] targets;
		f32 radius = charm.radius;
		if (!map.getBlobsInRadius(pos, radius, @targets))
			return;

		CBitStream params;
		u16 count = 0;

		for (int i = 0; i < targets.length(); i++)
		{
			CBlob@ blob = targets[i];

			if (blob is null) 
			{
				targets.removeAt(i);
				continue;
			}
			count++;
		}
		if (targets.length() > 0) 
		{
			params.write_u16(count);
			params.write_u16(player.getNetworkID());
			params.write_Vec2f(pos);
		}
		else return;
		for (int i = 0; i < targets.length(); i++)
		{
			params.write_u16(targets[i].getNetworkID());
		}

		if (force_mult) this.SendCommand(this.getCommandID("multiply force"), params);
		else if (act_three) this.SendCommand(this.getCommandID("act 3"), params);
		else if (swap_places) this.SendCommand(this.getCommandID("swap places"), params);
		//print("command sent");
	}

	if(teleport)
	{
		set_emote(this, Emotes::off);
		Vec2f pos = this.getPosition();
		Vec2f mouse_pos = getControls().getMouseWorldPos();
		Vec2f mouse_screen = getControls().getMouseScreenPos();
		Vec2f draw_pos(0,0);
		Vec2f player_screen_pos = getDriver().getScreenPosFromWorldPos(pos);

		CRules@ rules = getRules();

		if (rules is null) return;

		CMap@ map = getMap();
		CPlayer@ player = this.getPlayer();

		if (player is null || map is null) return;

		PlayerCharm@ charm = getCharmByName("teleportcharm");

		bool rcast = map.rayCastSolid(pos, mouse_pos, draw_pos);

		Vec2f offset = draw_pos - pos;
		f32 len = offset.Length();

		if (len > charm.range)
		{
			offset.Normalize();
			offset *= charm.range;
		}

		if (rcast) offset -= offset * (12.0f/offset.Length());

		CBitStream params;

		params.write_u16(player.getNetworkID());
		params.write_Vec2f(offset);

		this.SendCommand(this.getCommandID("teleport charm"), params);	
	}

	bool stasis_field = controls.isKeyJustReleased(getKey(rules.get_string("key_stasischarm_" + player.getUsername()))) && getGameTime() - getRules().get_u32("stasischarm_cd"+player.getUsername()) > getCharmByName("stasischarm").cooldown && hasCharm(player, getCharmByName("stasischarm"));

	if (stasis_field)
	{
		set_emote(this, Emotes::off);
		//print("key pressed");
		//print("game time: "+getGameTime());

		Vec2f pos(0,0);
		Vec2f player_pos = this.getPosition();
		Vec2f mouse_pos = controls.getMouseWorldPos();

		PlayerCharm@ charm = getCharmByName("stasischarm");

		map.rayCastSolid(player_pos, mouse_pos, pos);

		Vec2f offset = pos - player_pos;
		f32 len = offset.Length();

		if (len > charm.range)
		{
			offset.Normalize();
			offset *= charm.range;
		}
		
		CBitStream params;

		params.write_u16(player.getNetworkID());
		params.write_Vec2f(pos);

		this.SendCommand(this.getCommandID("stasis field"), params);		

	}

	bool summon_arrows = controls.isKeyJustReleased(getKey(rules.get_string("key_arrowraincharm_" + player.getUsername()))) && getGameTime() - getRules().get_u32("arrowraincharm_cd"+player.getUsername()) > getCharmByName("arrowraincharm").cooldown && hasCharm(player, getCharmByName("arrowraincharm"));

	if (summon_arrows)
	{
		set_emote(this, Emotes::off);
		//print("key pressed");
		//print("game time: "+getGameTime());

		Vec2f pos(0,0);
		Vec2f player_pos = this.getPosition();
		Vec2f mouse_pos = controls.getMouseWorldPos();

		CBitStream params;

		params.write_u16(player.getNetworkID());
		//params.write_Vec2f(player_pos);
		//params.write_Vec2f(mouse_pos);

		this.SendCommand(this.getCommandID("summon arrows"), params);				
	}

	bool killer_queen = controls.isKeyJustPressed(getKey(rules.get_string("key_killerqueencharm_" + player.getUsername()))) && getGameTime() - getRules().get_u32("killerqueencharm_cd"+player.getUsername()) > getCharmByName("killerqueencharm").cooldown && hasCharm(player, getCharmByName("killerqueencharm"));

	if (killer_queen)
	{


		set_emote(this, Emotes::off);
		print("key pressed");
		CBitStream params;
		params.write_u16(player.getNetworkID());

		this.SendCommand(this.getCommandID("killer queen"), params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("multiply force"))
	{
		u16 count;
		u16 player_id;
		Vec2f pos;
		if (!params.saferead_u16(count)) return;
		if (!params.saferead_u16(player_id)) return;
		if (!params.saferead_Vec2f(pos)) return;

		CPlayer@ player = getPlayerByNetworkId(player_id);
		if (player is null) return;

		u16 blob_id;
		//print("got count");
		for (int i = 0; i < count; i++)
		{
			if (!params.saferead_u16(blob_id)) return;
			CBlob@ blob = getBlobByNetworkID(blob_id);
			//print("got blob");
			if (blob is null) continue;
			Vec2f vel = blob.getVelocity();

			f32 vellen = vel.Length();

			Vec2f new_vel = vel * 3;

			f32 newvellen = new_vel.Length();

			if (newvellen > 15.0f && blob.getPlayer() !is null)
			{
				new_vel = new_vel * (15.0f / newvellen);
			}

			blob.setVelocity(new_vel);
			blob.set_u32("velocity3xcharm_cd", getGameTime());
			//print("velocity applied to "+ blob.getName());
		}

		for (int i = 0; i < 50; i++)
		{
			f32 radius = getCharmByName("velocity3xcharm").radius;
			Vec2f pos2(radius + XORRandom(20)/10 - 1.0f, 0.0f);
			f32 angle = XORRandom(3600)/10;
			pos2.RotateByDegrees(angle);

			Vec2f vel(radius/300, 0.0f);
			angle = XORRandom(3600)/10;
			vel.RotateByDegrees(angle);

			CParticle@ particle = ParticlePixel(pos+ pos2, vel, SColor(255, 128, 0, 128), false, 30);
			if (particle is null) continue;
			particle.gravity = Vec2f(0,0);
		}

		getRules().set_u32("velocity3xcharm_cd" + player.getUsername(), getGameTime());
		getRules().Sync("velocity3xcharm_cd" + player.getUsername(), true);
	}
	else
	if (cmd == this.getCommandID("act 3"))
	{
		u16 count;
		u16 player_id;
		Vec2f pos;
		if (!params.saferead_u16(count)) return;
		if (!params.saferead_u16(player_id)) return;
		if (!params.saferead_Vec2f(pos)) return;

		CPlayer@ player = getPlayerByNetworkId(player_id);
		if (player is null) return;

		u16 blob_id;
		//print("got count");
		for (int i = 0; i < count; i++)
		{
			if (!params.saferead_u16(blob_id)) return;
			CBlob@ blob = getBlobByNetworkID(blob_id);
			//print("got blob");
			if (blob is null) continue;

			CPlayer@ victim = blob.getPlayer();
			if (victim !is null)
			{
				if (victim.getTeamNum() == player.getTeamNum() && victim !is player) continue;
			}
			CShape@ shape = blob.getShape();
			
			shape.SetGravityScale(3.0f);
			//shape.SetMass(shape.getConsts().mass*5);
			blob.Tag("act 3'd");
			blob.set_u32("act 3'd time", getGameTime());
			blob.Sync("act 3'd", true);
			blob.Sync("act 3'd time", true);

			//print("act 3 applied to "+ blob.getName() + " on " + getGameTime());
		}

		for (int i = 0; i < 50; i++)
		{
			f32 radius = getCharmByName("heavycharm").radius;
			Vec2f pos2(radius + XORRandom(20)/10 - 1.0f, 0.0f);
			f32 angle = XORRandom(3600)/10;
			pos2.RotateByDegrees(angle);

			Vec2f vel(radius/300, 0.0f);
			angle = XORRandom(3600)/10;
			vel.RotateByDegrees(angle);

			CParticle@ particle = ParticlePixel(pos+ pos2, vel, SColor(255, 255, 255, 0), false, 30);
			if (particle is null) continue;
			particle.gravity = Vec2f(0,0);
		}

		getRules().set_u32("heavycharm_cd" + player.getUsername(), getGameTime());
		getRules().Sync("heavycharm_cd" + player.getUsername(), true);
	}

	else if (cmd == this.getCommandID("swap places"))
	{
		u16 count;
		u16 player_id;
		Vec2f pos;
		if (!params.saferead_u16(count)) return;
		if (!params.saferead_u16(player_id)) return;
		if (!params.saferead_Vec2f(pos)) return;

		CPlayer@ player = getPlayerByNetworkId(player_id);
		if (player is null || player.getBlob() is null) return;

		u16 blob_id;
		//print("got count");
		for (int i = 0; i < count; i++)
		{
			if (player.getBlob() is null) return;

			if (!params.saferead_u16(blob_id)) return;

			CBlob@ blob = getBlobByNetworkID(blob_id);
			//print("got blob");
			if (blob is null || blob.getTeamNum() == player.getTeamNum() || !blob.hasTag("player")) continue;

			Vec2f targetpos = blob.getPosition();
			Vec2f ourpos = player.getBlob().getPosition();

			if (targetpos == ourpos) continue;

			CMap@ map = getMap();
			CControls@ controls = player.getControls();

			if (map.rayCastSolid(pos, targetpos)) continue;

			blob.setPosition(ourpos);
			player.getBlob().setPosition(targetpos);

			CParticle@ temp = ParticleAnimated(CFileMatcher("TeamColoredLargeSmoke.png").getFirst(), targetpos - Vec2f(0, 8), Vec2f(0, 0), 0.0f, 1.0f, 3, 0.0f, false);

			if (temp !is null)
			{
				temp.width = 32;
				temp.height = 32;
			}

			CParticle@ temp2 = ParticleAnimated(CFileMatcher("TeamColoredLargeSmoke.png").getFirst(), ourpos - Vec2f(0, 8), Vec2f(0, 0), 0.0f, 1.0f, 3, 0.0f, false);

			if (temp2 !is null)
			{
				temp2.width = 32;
				temp2.height = 32;
			}

			getRules().set_u32("swapplacescharm_cd" + player.getUsername(), getGameTime());
			getRules().Sync("swapplacescharm_cd" + player.getUsername(), true);

			break;

			//print("swap places applied to "+ blob.getName() + " on " + getGameTime());
		}

	}

	else if (cmd == this.getCommandID("teleport charm"))
	{
		u16 player_id;
		Vec2f offset;

		if (!params.saferead_u16(player_id)) return;
		if (!params.saferead_Vec2f(offset)) return;

		CPlayer@ player = getPlayerByNetworkId(player_id);
		if (player is null || player.getBlob() is null) return;

		Vec2f ourpos = player.getBlob().getPosition();
		Vec2f pos = ourpos+offset;
		
		player.getBlob().setPosition(pos);
		player.getBlob().AddForce(Vec2f(0.01, 0));
		player.getBlob().getSprite().PlaySound("/Stun", 1.0f, this.getSexNum() == 0 ? 1.0f : 1.5f);
		setKnocked(player.getBlob(), 2);

		CParticle@ temp = ParticleAnimated(CFileMatcher("TeamColoredLargeSmoke.png").getFirst(), pos - Vec2f(0, 8), Vec2f(0, 0), 0.0f, 1.0f, 3, 0.0f, false);

		if (temp !is null)
		{
			temp.width = 32;
			temp.height = 32;
		}

		CParticle@ temp2 = ParticleAnimated(CFileMatcher("TeamColoredLargeSmoke.png").getFirst(), ourpos - Vec2f(0, 8), Vec2f(0, 0), 0.0f, 1.0f, 3, 0.0f, false);

		if (temp2 !is null)
		{
			temp2.width = 32;
			temp2.height = 32;
		}

		getRules().set_u32("teleportcharm_cd" + player.getUsername(), getGameTime());
		getRules().Sync("teleportcharm_cd" + player.getUsername(), true);
	}

	else if (cmd == this.getCommandID("stasis field") && isServer())
	{
		u16 player_id;
		Vec2f pos;

		if (!params.saferead_u16(player_id)) return;
		if (!params.saferead_Vec2f(pos)) return;

		CPlayer@ player = getPlayerByNetworkId(player_id);
		if (player is null) return;

		server_CreateBlob("gravfield22", player.getTeamNum(), pos);

		getRules().set_u32("stasischarm_cd" + player.getUsername(), getGameTime());
		getRules().Sync("stasischarm_cd" + player.getUsername(), true);
	}

	else if (cmd == this.getCommandID("summon arrows"))
	{
		u16 player_id;
		
		if (!params.saferead_u16(player_id)) return;

		CPlayer@ player = getPlayerByNetworkId(player_id);
		if (player is null) return;

		CBlob@ blob = player.getBlob();
		if (blob is null) return;

		u8 arrowType = ArrowType::normal;

		if (!hasArrows(blob, arrowType)) return;

		blob.set_u32("summon arrows time", getGameTime());
		blob.Sync("summon arrows time", true);

		blob.Tag("summoning arrows");
		blob.Sync("summoning arrows", true);

		getRules().set_u32("arrowraincharm_cd" + player.getUsername(), getGameTime());
		getRules().Sync("arrowraincharm_cd" + player.getUsername(), true);
	}
	else if (cmd == this.getCommandID("killer queen"))
	{
		
		u16 player_id;
		
		if (!params.saferead_u16(player_id)) { return;  }

		CPlayer@ player = getPlayerByNetworkId(player_id);
		if (player is null) { return;}

		CBlob@ blob = player.getBlob();
		if (blob is null)  { return;}

		CBlob@ bomb = getBlobByNetworkID(getRules().get_u16(player.getUsername() + "bomb id"));
		if (bomb is null) { return;}

		if (!bomb.hasTag("is a bomb")) return;

		Vec2f bomb_pos = bomb.getPosition();
		Vec2f player_pos = blob.getPosition();

		if ((bomb_pos - player_pos).Length() > getCharmByName("killerqueencharm").range) return;

		string bomb_name = bomb.getName();
		bool dont_kill = (bomb_name == "mat_gold");

		bomb.SetDamageOwnerPlayer(player);
		bomb.server_setTeamNum(player.getTeamNum());
		blob.getSprite().PlaySound("bokudan.ogg", 2.0f);
		bomb.getSprite().PlaySound("bokudan.ogg", 2.0f);
		Explode(bomb, 30.0f, 3.0f);
		if (!dont_kill) bomb.server_Die();

		if (dont_kill) bomb.Untag("is a bomb");

		getRules().set_u32("killerqueencharm_cd" + player.getUsername(), getGameTime());
		getRules().Sync("killerqueencharm_cd" + player.getUsername(), true);
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	
	CPlayer@ player = this.getPlayer();
	if (player is null) return;
	string username = player.getUsername();
	if (!getRules().get_bool("killerqueencharm_" + username)) return;
	string name = attached.getName();
	string[] names = {"bomb", "keg", "waterbomb", "spikes", "wooden_door", "stone_door", "wooden_platform", "trap_block", "ladder", "ctf_flag", "seed", "catapult", "ballista", "longboat", "warboat", "dinghy", "mat_gold"};
	if (names.find(name) >=0) return;
	
	CBlob@ prev_bomb = getBlobByNetworkID(this.get_u16("bomb id"));
	if (prev_bomb !is null) prev_bomb.Untag("is a bomb");

	
	attached.Tag("is a bomb");
	attached.Sync("is a bomb", true);
	getRules().set_u16(username+"bomb id", attached.getNetworkID());
	getRules().Sync(username+"bomb id", true);
}

void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData)
{
    if (victim !is null)
    {
        CBlob@ bomb = getBlobByNetworkID(this.get_u16(victim.getUsername()+"bomb id"));
        if (bomb !is null)
        { 
        	this.set_u16(victim.getUsername()+"bomb id",0);
        	u8 count = 0;
        	for(int a = 0; a < getPlayerCount(); a++) 
			{ 
				CPlayer@ player = getPlayer(a);
				CBlob@ blob = getBlobByNetworkID(this.get_u16(player.getUsername()+"bomb id"));
				if (blob is null) continue;
				if (bomb is blob) count++;

			}
			if (count == 0)
        		bomb.Untag("is a bomb");
    	}

        if (attacker !is null)
        {
            if (this.get_bool("materialsextractioncharm_" + attacker.getUsername()) && isServer())
            {
                CBlob@ blob = victim.getBlob();
                if (blob is null) return;

                Vec2f pos = blob.getPosition();
                CBlob@ mat = server_CreateBlob("mat_wood", blob.getTeamNum(), pos);


                if (mat !is null)
                {
	                mat.server_SetQuantity(50);
	                mat.setVelocity(getRandomVelocity(90, 4, 90));
	            }

                CBlob@ mat2 = server_CreateBlob("mat_stone", blob.getTeamNum(), pos);
                if (mat2 !is null)
                {
	                mat2.server_SetQuantity(15);
	                mat2.setVelocity(getRandomVelocity(90, 4, 90));
	            }
            }
        }
    }
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (this.getPlayer() is null)
	{ return damage;}

	if (customData == Hitters::suicide) return damage;

	if (damage >= this.getHealth()*2 && !this.hasTag("invincible") && !blockAttack(this, velocity, 0.0f))
	{
		if (hasCharm(this.getPlayer(), getCharmByName("divineprotectioncharm")) && getGameTime() - getRules().get_u32("divineprotectioncharm_cd" + this.getPlayer().getUsername()) > getCharmByName("divineprotectioncharm").cooldown)// && getGameTime() - getRules().get_u32("divineprotectioncharm_cd" + this.getPlayer().getUsername()) > 90)
		{
			getRules().set_u32("divineprotectioncharm_cd" + this.getPlayer().getUsername(), getGameTime());
			getRules().Sync("divineprotectioncharm_cd" + this.getPlayer().getUsername(), true);
			this.set_u32("protection time", getGameTime());
			this.Sync("protection time", true);
			damage *= 0;
		}

		CParticle@[] particles;
		if (this.get("particles", particles))
		{
			for (int i = 0; i < particles.length(); i++)
			{
				CParticle@ part = particles[i];
				Vec2f vel (XORRandom(80)/10-4, XORRandom(80)/10-4);
				part.velocity = vel;
				part.timeout = 30;
			}
			this.set("particles", null);
		}
	}

	if (getGameTime() - this.get_u32("protection time") < 6) damage *= 0;
	
	return damage;
}


void onDie(CBlob@ this)
{
	CParticle@[] particles;
	if (this.get("particles", particles))
			{
				for (int i = 0; i < particles.length(); i++)
								{
									particles[i].timeout = 0;
								}
								this.set("particles", null);
			}
}

CBlob@ CreateArrow(CBlob@ this, Vec2f arrowPos, Vec2f arrowVel, u8 arrowType)
{
	CBlob@ arrow = server_CreateBlobNoInit("golden_arrow");
	if (arrow !is null)
	{
		// fire arrow?
		arrow.set_u8("arrow type", arrowType);
		arrow.SetDamageOwnerPlayer(this.getPlayer());
		arrow.Init();

		arrow.IgnoreCollisionWhileOverlapped(this);
		arrow.server_setTeamNum(this.getTeamNum());
		arrow.setPosition(arrowPos);
		arrow.setVelocity(arrowVel);
		arrow.Tag("arrow rain");
	}
	return arrow;
}

void DrawInventoryOfBlob(CBlob@ this)
{
	SColor col;
	CInventory@ inv = this.getInventory();
	string[] drawn;
	Vec2f tl = this.getPosition();
	tl = getDriver().getScreenPosFromWorldPos(tl);
	Vec2f offset (-40, -120);
	u8 j = 0;
	for (int i = 0; i < inv.getItemsCount(); i++)
	{
		CBlob@ item = inv.getItem(i);
		const string name = item.getName();

		if (drawn.find(name) == -1)
		{

			if (j%2 == 0 && j>0)
			{
				offset.x = -40;
				offset.y += 60;
			}
			else if (j>0) offset.x += 40;
			j++;

			Vec2f tempoffset(0,0);
			if (item.hasTag("material")) tempoffset.x = 5;

			const int quantity = this.getBlobCount(name);
			drawn.push_back(name);

			GUI::DrawIcon(item.inventoryIconName, item.inventoryIconFrame, item.inventoryFrameDimension, tl + offset + tempoffset, 1.0f);

			f32 ratio = float(quantity) / float(item.maxQuantity);
			col = SColor(255, 255, 255, 255);


			GUI::SetFont("menu");
			Vec2f dimensions(0,0);
			string disp = "" + quantity;
			GUI::GetTextDimensions(disp, dimensions);
			GUI::DrawText(disp, tl + Vec2f(offset.x + 10, offset.y + 30), col);
		}
	}

	PlayerCharm[] @charms;
	CPlayer@ player = this.getPlayer();
	if (player is null) return;

	if (getRules().get("playercharms_"+player.getUsername(), @charms))
	{
		print("has charms");
		Vec2f offset(40, -40-40*charms.length()/2);
		for (int i = 0; i<charms.length(); i++)
		{
			PlayerCharm @charm = @charms[i];
			offset.x+=40;
			GUI::DrawIconByName(charm.iconName, this.getPosition()+offset, 1.5f);
		}
	}
}