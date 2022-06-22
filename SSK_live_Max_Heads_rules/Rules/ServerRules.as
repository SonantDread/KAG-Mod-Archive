#define CLIENT_ONLY

void onTick(CRules@ this)
{
    if (getGameTime() % 6000 == 0){
       client_AddToChat("Do not attack players that have stocks or drop spikes on them if you are eliminated");
    }
}