// events.as; is called on gamestart or when a key building is built, which starts the event chain.
s32 event_time = 0;
// (255, 214, 19, 25) bright red.
SColor color = SColor(255, 214, 19, 25);

void onInit(CBlob@ this)
{
	// prompt text.
	client_AddToChat("The Fire senses that one of you wishes to become an Apprentice of the Sun.", color);
	client_AddToChat("If you can protect the sun shrine for one day, you will be granted the knowledge of a thousand millenia.", color);
	client_AddToChat("You have (2) minutes to prepare.", color);
	// event_time; catagorized game time so can read gametime one way.
	print("// Event script was called.");
	print("// Sun Shrine Defense.");
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
	    if (event_time == 18)
	    {
	        client_AddToChat("30 seconds remaining...", color);
	    }
	    if (event_time == 22)
	    {
	        client_AddToChat("10 seconds remaining...", color);
	    }
	    if (event_time == 24) //2 minute
	    {
	        client_AddToChat("The ritual has begun! Stage (1) incoming...", color);
	    }
	    if (event_time == 25) //2:05 minute
	    {
			CBlob@ b = server_CreateBlob("meteor");
     		if (b !is null) b.setPosition(Vec2f(this.getPosition().x+(XORRandom(variance_compact)-(variance_compact/2)),0));
	    }

	    //stage2
	    if (event_time == 30) //2,30 minute
	    {
	        client_AddToChat("Stage (2) begins in 30 seconds...", color);
	    }
	    if (event_time == 36) //3 minute
	    {
	        client_AddToChat("Stage (2) incoming...", color);
	    }
	    if (event_time == 37) //3:05 minute
	    {
	    	for (int i = 0; i < 4; i++)
			{
	    		CBlob@ b = server_CreateBlob("firewall");
	     		if (b !is null) b.setPosition(Vec2f(this.getPosition().x+(XORRandom(variance)-(variance/2)),0));
	     		{b.server_SetTimeToDie(250.0f/30);
	     		}
		    }
	    }
	    if (event_time == 38) //3:10 minute
	    {
	    	for (int i = 0; i < 8; i++)
			{
	    		CBlob@ b = server_CreateBlob("molotov");
	     		if (b !is null) b.setPosition(Vec2f(this.getPosition().x+(XORRandom(variance)-(variance/2)),0));
		    }
	    }

	    //stage3
	    if (event_time == 42) //3,30 minute
	    {
	        client_AddToChat("Stage (3) begins in 30 seconds...", color);
	    }
	    if (event_time == 48) //4 minute
	    {
	        client_AddToChat("Stage (3) incoming...", color);
	    }
	    if (event_time == 49) //4:05 minute
	    {
	    	for (int i = 0; i < 10; i++)
			{
	    		CBlob@ b = server_CreateBlob("keg");
	     		if (b !is null) b.setPosition(Vec2f(this.getPosition().x+(XORRandom(variance)-(variance/2)),0));
	     		{b.SendCommand(b.getCommandID("activate"));
	     		}
		    }
	    }
	    if (event_time == 50) //4:10 minute
	    {
	    	for (int i = 0; i < 10; i++)
			{
	    		CBlob@ b = server_CreateBlob("keg");
	     		if (b !is null) b.setPosition(Vec2f(this.getPosition().x+(XORRandom(variance)-(variance/2)),0));
	     		{b.SendCommand(b.getCommandID("activate"));
	     		}
		    }
	    }
	    if (event_time == 51) //4:15 minute
	    {
	    	for (int i = 0; i < 10; i++)
			{
	    		CBlob@ b = server_CreateBlob("keg");
	     		if (b !is null) b.setPosition(Vec2f(this.getPosition().x+(XORRandom(variance)-(variance/2)),0));
	     		{b.SendCommand(b.getCommandID("activate"));
	     		}
		    }
	    }
	    if (event_time == 52) //4:20 minute
	    {
	    	for (int i = 0; i < 10; i++)
			{
	    		CBlob@ b = server_CreateBlob("keg");
	     		if (b !is null) b.setPosition(Vec2f(this.getPosition().x+(XORRandom(variance)-(variance/2)),0));
	     		{b.SendCommand(b.getCommandID("activate"));
	     		}
		    }
	    }
	    if (event_time == 53) //4:25 minute
	    {
	    	for (int i = 0; i < 10; i++)
			{
	    		CBlob@ b = server_CreateBlob("keg");
	     		if (b !is null) b.setPosition(Vec2f(this.getPosition().x+(XORRandom(variance)-(variance/2)),0));
	     		{b.SendCommand(b.getCommandID("activate"));
	     		}
		    }
	    }

	    //stage4
	    if (event_time == 54) //4,30 minute
	    {
	        client_AddToChat("Stage (4) begins in 30 seconds...", color);
	    }
	    if (event_time == 60) //5 minute
	    {
	        client_AddToChat("Stage (4) incoming...", color);
	    }
	    if (event_time == 61) //5:05 minute
	    {
	    	for (int i = 0; i < 8; i++)
			{
	    		CBlob@ b = server_CreateBlob("firewall");
	     		if (b !is null) b.setPosition(Vec2f(this.getPosition().x+(XORRandom(variance)-(variance/2)),0));
	     		{b.server_SetTimeToDie(250.0f/30);
	     		}
		    }
	    }
	    if (event_time == 63) //5:15 minute
	    {
	    	for (int i = 0; i < 3; i++)
			{
    			CBlob@ b = server_CreateBlob("meteor");
 				if (b !is null) b.setPosition(Vec2f(this.getPosition().x+(XORRandom(variance_compact)-(variance_compact/2)),0));
 			}
	    }
	    if (event_time == 64) //5:20 minute
	    {
	    	for (int i = 0; i < 10; i++)
			{
	    		CBlob@ b = server_CreateBlob("keg");
	     		if (b !is null) b.setPosition(Vec2f(this.getPosition().x+(XORRandom(variance)-(variance/2)),0));
	     		{b.SendCommand(b.getCommandID("activate"));
	     		}
		    }
	    }
	    if (event_time == 65) //5:25 minute
	    {
	    	for (int i = 0; i < 10; i++)
			{
	    		CBlob@ b = server_CreateBlob("keg");
	     		if (b !is null) b.setPosition(Vec2f(this.getPosition().x+(XORRandom(variance)-(variance/2)),0));
	     		{b.SendCommand(b.getCommandID("activate"));
	     		}
		    }
	    }
	    //stage5
	    if (event_time == 66) //5,30 minute
	    {
	        client_AddToChat("Stage (5) begins in 30 seconds...", color);
	    }
	    if (event_time == 72) //6 minute
	    {
	        client_AddToChat("Stage (5) incoming...", color);
	    }
	    if (event_time == 73) //6:05 minute
	    {
	    	for (int i = 0; i < 8; i++)
			{
	    		CBlob@ b = server_CreateBlob("firewall");
	     		if (b !is null) b.setPosition(Vec2f(this.getPosition().x+(XORRandom(variance)-(variance/2)),0));
	     		{b.server_SetTimeToDie(250.0f/30);
	     		}
		    }
	    }
	    if (event_time == 74) //6:10 minute
	    {
	    	for (int i = 0; i < 4; i++)
			{
    			CBlob@ b = server_CreateBlob("meteor");
 				if (b !is null) b.setPosition(Vec2f(this.getPosition().x+(XORRandom(variance)-(variance/2)),0));
 			}
	    }
	    if (event_time == 75) //6:15 minute
	    {
	    	for (int i = 0; i < 10; i++)
			{
	    		CBlob@ b = server_CreateBlob("keg");
	     		if (b !is null) b.setPosition(Vec2f(this.getPosition().x+(XORRandom(variance)-(variance/2)),0));
	     		{b.SendCommand(b.getCommandID("activate"));
	     		}
		    }
	    }
	    if (event_time == 76) //6:20 minute
	    {
	    	for (int i = 0; i < 6; i++)
			{
	    		CBlob@ b = server_CreateBlob("keg");
	     		if (b !is null) b.setPosition(Vec2f(this.getPosition().x+(XORRandom(variance_compact)-(variance_compact/2)),0));
	     		{b.SendCommand(b.getCommandID("activate"));
	     		}
		    }
	    }

	    //stage6
	    if (event_time == 78) //6,30 minute
	    {
	        client_AddToChat("Stage (6) begins in 30 seconds...", color);
	    }
	    if (event_time == 84) //7 minute
	    {
	        client_AddToChat("Stage (6) incoming...", color);
	    }
	    if (event_time == 85) //7:05 minute
	    {
	    	for (int i = 0; i < 10; i++)
			{
	    		CBlob@ b = server_CreateBlob("eternalmolotov");
	     		if (b !is null) b.setPosition(Vec2f(this.getPosition().x+(XORRandom(variance)-(variance/2)),0));
	     		{b.server_SetTimeToDie(150.0f/30);
	     		}
		    }
	    }
	    if (event_time == 86) //7:10 minute
	    {
    		CBlob@ b = server_CreateBlob("meteor");
 			if (b !is null) b.setPosition(Vec2f(this.getPosition().x+(XORRandom(variance_compact)-(variance_compact/2)),0));
	    }
	    if (event_time == 87) //7:15 minute
	    {
    		CBlob@ b = server_CreateBlob("meteor");
 			if (b !is null) b.setPosition(Vec2f(this.getPosition().x+(XORRandom(variance_compact)-(variance_compact/2)),0));
	    }
	    if (event_time == 88) //7:20 minute
	    {
    		CBlob@ b = server_CreateBlob("meteor");
 			if (b !is null) b.setPosition(Vec2f(this.getPosition().x+(XORRandom(variance_compact)-(variance_compact/2)),0));
	    }
	    if (event_time == 89) //7:25 minute
	    {
    		CBlob@ b = server_CreateBlob("meteor");
 			if (b !is null) b.setPosition(Vec2f(this.getPosition().x+(XORRandom(variance_compact)-(variance_compact/2)),0));
	    }

	    //stage7
	    if (event_time == 90) //7,30 minute
	    {
	        client_AddToChat("The final Stage (7) begins in 30 seconds... Beware!", color);
	    }
	    if (event_time == 96) //8 minute
	    {
	        client_AddToChat("Stage (7) incoming...", color);
	    }
	    if (event_time == 97) //8:05 minute
	    {
	    	for (int i = 0; i < 10; i++)
			{
	    		CBlob@ b = server_CreateBlob("bigfirewall");
	     		if (b !is null) b.setPosition(Vec2f(this.getPosition().x+(XORRandom(variance)-(variance/2)),0));
	     		{b.server_SetTimeToDie(100.0f/30);
	     		}
		    }
	    }
	    if (event_time == 98) //8:10 minute
	    {
    		CBlob@ b = server_CreateBlob("meteor");
 			if (b !is null) b.setPosition(Vec2f(this.getPosition().x+(XORRandom(variance_compact)-(variance_compact/2)),0));
	    }
	    if (event_time == 99) //8:15 minute
	    {
    		for (int i = 0; i < 13; i++)
			{
	    		CBlob@ b = server_CreateBlob("keg");
	     		if (b !is null) b.setPosition(Vec2f(this.getPosition().x+(XORRandom(variance)-(variance/2)),0));
	     		{b.SendCommand(b.getCommandID("activate"));
	     		}
		    }
	    }
	    if (event_time == 100) //8:20 minute
	    {
	    	for (int i = 0; i < 8; i++)
			{
	    		CBlob@ b = server_CreateBlob("bigfirewall");
	     		if (b !is null) b.setPosition(Vec2f(this.getPosition().x+(XORRandom(variance)-(variance/2)),0));
	     		{b.server_SetTimeToDie(100.0f/30);
	     		}
		    }
	    }
	    if (event_time == 101) //8:25 minute
	    {
	    	for (int i = 0; i < 3; i++)
			{
    			CBlob@ b = server_CreateBlob("meteor");
 				if (b !is null) b.setPosition(Vec2f(this.getPosition().x+(XORRandom(variance_compact)-(variance_compact/2)),0));
 			}
	    }
	    if (event_time == 102) //8:30 minute
	    {
    		for (int i = 0; i < 12; i++)
			{
	    		CBlob@ b = server_CreateBlob("keg");
	     		if (b !is null) b.setPosition(Vec2f(this.getPosition().x+(XORRandom(variance)-(variance/2)),0));
	     		{b.SendCommand(b.getCommandID("activate"));
	     		}
		    }
	    }
	    if (event_time == 103) //8:35 minute
	    {
	    	for (int i = 0; i < 9; i++)
			{
	    		CBlob@ b = server_CreateBlob("bigfirewall");
	     		if (b !is null) b.setPosition(Vec2f(this.getPosition().x+(XORRandom(variance)-(variance/2)),0));
	     		{b.server_SetTimeToDie(100.0f/30);
	     		}
		    }
	    }
	    if (event_time == 104) //8:40 minute
	    {
	    	for (int i = 0; i < 4; i++)
			{
    			CBlob@ b = server_CreateBlob("meteor");
 				if (b !is null) b.setPosition(Vec2f(this.getPosition().x+(XORRandom(variance_compact)-(variance_compact/2)),0));
 			}
	    }
	    if (event_time == 105) //8:45 minute
	    {
    		for (int i = 0; i < 13; i++)
			{
	    		CBlob@ b = server_CreateBlob("keg");
	     		if (b !is null) b.setPosition(Vec2f(this.getPosition().x+(XORRandom(variance)-(variance/2)),0));
	     		{b.SendCommand(b.getCommandID("activate"));
	     		}
		    }
	    }

	    if (event_time == 107) //8:55 minute
	    {
	    	// REWARD!!!
    		print("// Event was endured!");

    		client_AddToChat("Well done young acolyte!", color);
	    }
	    if (event_time == 108) //9 minute
	    {
    		client_AddToChat("You have endured well.", color);
	    }
	    if (event_time == 109) //9:05 minute
	    {
    		client_AddToChat("And now... your reward!", color);
	    }
	    if (event_time == 110) //9:10 minute
	    {
    		//Give reward
    		print("// Give reward.");
	    	CBlob@ b = server_CreateBlob("sunshard");
	     	if (b !is null) b.setPosition(Vec2f(this.getPosition().x,this.getPosition().y));

	    }
	    if (event_time == 111) //9:15 minute
	    {
    		for (int i = 0; i < 24; i++)
			{
	    		CBlob@ b = server_CreateBlob("pouchofcoins");
	     		if (b !is null) b.setPosition(Vec2f(this.getPosition().x+(XORRandom(variance)-(variance/2)),0));
		    }
	    }
	}
    // event_time updater/counter.
	if (getGameTime() % 150 == 0)
    {
    	// add one to event_time when time is met.
        event_time += 1;
    }
}