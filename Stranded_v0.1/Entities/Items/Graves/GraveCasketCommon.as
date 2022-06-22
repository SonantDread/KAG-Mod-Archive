
shared class Loot
{
    string name; 
    int rarity;
    int quantity;
};

f32 openHealth = 0.0f; //health of wooden chest when it will be opened     0.5f = 1 heart
int itemVelocity = 0.5f; //how far item will fly from from the chest on open
bool button = false; //open chest by button (hold E) or by hit

void InitLoot( CBlob@ this )
{
    /*if you want a random quantity then write "addLoot(this, item name, item rarity, XORRandom(item quantity));"
      if you want to add coins then write "addLoot(this, "coins", item rarity, item quantity);" 
      if you want to make item drop always set "item quantity" as "0"
    */

    //addLoot(this, item name, item rarity, item quantity)
    addLoot(this, "coins", 0, XORRandom(39) + 1); //chest will drop coins with quantity 1 - 30
	
	int rs = XORRandom(17);
	
	if (rs==0)
		addLoot(this, "carnage", 1, 1);
	else if (rs==1)
		addLoot(this, "drought", 1, 1);
	else if (rs==2)
		addLoot(this, "sfshark", 1, 1);
	else if (rs==3)
		addLoot(this, "selemental", 1, 1);
	else if (rs==4)
		addLoot(this, "timeskip", 1, 1);
	else if (rs==5)
		addLoot(this, "vodka", 1, 1);
	else if (rs==6)
		addLoot(this, "sreinforce", 1, 1);
	else if (rs==7)
		addLoot(this, "midas", 1, 1);
	else if (rs==8)
		addLoot(this, "sgreg", 1, 1);
	else if (rs==9)
		addLoot(this, "shorde", 1, 1);
	else if (rs==10)
		addLoot(this, "sshark", 2, 1);
	else if (rs==11)
		addLoot(this, "golddrill", 1, 1);
	else if (rs==12)
		addLoot(this, "goldenegg", 1, 1);
	else if (rs==13)
		addLoot(this, "sreturn", 1, 1);
	else if (rs>=14 or rs<=17)
		addLoot(this, "shard", 1, 1);


	int ruc = XORRandom(10);
	
	if (ruc==0)
		addLoot(this, "sarsonist", 2, 1);
	else if (ruc==1)
		addLoot(this, "sbunny", 2, 1);
	else if (ruc==2)
		addLoot(this, "sgargoyle", 2, 1);
	else if (ruc==3)
		addLoot(this, "snecromancer", 2, 1);
	else if (ruc==4)
		addLoot(this, "sslayer", 2, 1);
	else if (ruc==5)
		addLoot(this, "sstalker", 2, 1);
	else if (rs>=6 or rs<=9)
		addLoot(this, "shard", 1, 1);
	
	int rz = XORRandom(7);
	
	if (rz==0)
		addLoot(this, "evilwraith", 3, 1);
	else if (rz==1)
		addLoot(this, "evilzombie", 3, 1);
	else if (rz==2)
		addLoot(this, "crawler", 3, 1);
	else if (rz==3)
		addLoot(this, "evilskeleton", 3, 1);
	else if (rz==4)
		addLoot(this, "zombieknight", 3, 1);
	else if (rz==5)
		addLoot(this, "lifeforce", 3, 1);
	else if (rs>=6)
		addLoot(this, "shard", 1, 1);
}



void addLoot(CBlob@ this, string NAME, int RARITY, int QUANTITY)
{    
    if (!this.exists("loot"))
    {
        Loot[] loot;
        this.set( "loot", loot );
    }

    Loot l;
    l.name = NAME;
    l.rarity = RARITY;
    l.quantity = QUANTITY;

    this.push("loot", l);
}