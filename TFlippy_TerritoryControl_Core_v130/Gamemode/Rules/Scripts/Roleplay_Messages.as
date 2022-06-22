/* Roleplay_Messages.as
 * author: Aphelion3371
 */

#define CLIENT_ONLY

const u16 JOIN_MESSAGE_DELAY = 5 * 30;
const u16 MESSAGE_INTERVAL = 90 * 30;

const string[] messages = {
	
	// -- GAME INFO
	"This server has a discord, get notified about all updates and suggest ur ideas Mikill#9150",
	
	// -- OTHER
	"Join the discord at https://discord.gg/md24hwp6qb \n" +
	"Where you can report rule breakers, share your ideas, and get notified about updates"
};

bool just_joined = true;
int counter = 0;

void onTick( CRules@ this )
{
	const u32 time = getGameTime();
	
	if (just_joined && (time % JOIN_MESSAGE_DELAY) == 0)
	{
		client_AddToChat("Welcome to Mikill Territory Control Server!", SColor(255, 127, 0, 127));
		client_AddToChat("Join the discord at https://discord.gg/md24hwp6qb", SColor(255, 127, 0, 127));
	    just_joined = false;
	}
	else if(time % MESSAGE_INTERVAL == 0)
	{
	    client_AddToChat(messages[counter++ % messages.length], SColor(255, 127, 0, 127));
	}
}
