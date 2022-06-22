#define SERVER_ONLY;
#include "tickets.as";

void onTick(CRules@ this)
{
    bool teamsHaveTickets = ticketsRemaining(this, 0) > 0 && ticketsRemaining(this, 1) > 0;

    if (getGameTime() % (teamsHaveTickets ? 30 : 15) == 0)
    {
        for (int i = 0; i < getPlayersCount(); i++)
        {
            CPlayer@ p = getPlayer(i);
            if (p.getCoins() < (this.getCurrentState() == GameState::game ? 150 : 100))
            {
                p.server_setCoins(p.getCoins() + 1);
            }
        }
    }
}