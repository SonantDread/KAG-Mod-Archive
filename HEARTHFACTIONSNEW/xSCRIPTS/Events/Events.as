// events.as; is called on gamestart or when a key building is built, which starts the event chain.
s32 event_time = 0;
// (255, 214, 19, 25) bright red.
SColor color = SColor(255, 214, 19, 25);

void onInit(CBlob@ this)
{
	client_AddToChat("A Sunshrine has been built somewhere in the world.", color);
	client_AddToChat("If you can kill The Pheonix, you will be rewarded.", color);
	client_AddToChat("You have (2) minutes to prepare.", color);
	print("// Sun Shrine Built.");
	event_time = 0;
}

void onTick(CBlob@ this)
{
	s32 variance = 300;
	s32 variance_compact = (variance/4);

	if (getGameTime() % 150 == 0)
    {
	    if (event_time == 12) //1 minute
	    {
	        client_AddToChat("1 minute remaining...", color);
	    }
	    if (event_time == 22)
	    {
	        client_AddToChat("10 seconds remaining...", color);
	    }
	    if (event_time == 24) //2 minute
	    {
	        client_AddToChat("The ritual has begun! Pheonix incoming...", color);
	    }
	    if (event_time == 25) //2:05 minute
	    {
			CBlob@ b = server_CreateBlob("pheonix");
     		if (b !is null) b.setPosition(Vec2f(this.getPosition().x+(XORRandom(variance)-(variance/2)),0));
	    }
	}
    // event_time updater/counter.
	if (getGameTime() % 150 == 0)
    {
    	// add one to event_time when time is met.
        event_time += 1;
    }
}