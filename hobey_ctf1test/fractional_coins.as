
void add_coins_to_player (CPlayer@ p, float coins) {
    CRules@ rules = getRules();
    if (rules.isWarmup()) {
        coins *= 0.2;
    }
    
    p.server_setCoins(p.getCoins() + coins);
    float fractional_coins = rules.get_f32("fractional_coins_"+p.getUsername());
    fractional_coins += coins - float(int(coins));
    
    if (fractional_coins >= 1.0) {
        p.server_setCoins(p.getCoins() + int(fractional_coins));
        fractional_coins -= float(int(fractional_coins));
    }
    rules.set_f32("fractional_coins_"+p.getUsername(), fractional_coins);
}
