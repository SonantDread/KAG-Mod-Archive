
shared class Loot
{
    string name; 
    int rarity;
    int quantity;
};

f32 openHealth = 1.0f; //health of wooden chest when it will be opened     0.5f = 1 heart
int itemVelocity = 2.0f; //how far item will fly from from the chest on open
bool button = true; //open chest by button (hold E) or by hit

void InitLoot( CBlob@ this )
{
    /*if you want a random quantity then write "addLoot(this, item name, item rarity, XORRandom(item quantity));"
      if you want to add coins then write "addLoot(this, "coins", item rarity, item quantity);" 
      if you want to make item drop always set "item quantity" as "0"
    */

	addLoot(this, "coins", 0, XORRandom(399) + 1); //chest will drop coins with quantity 1 - 30
	addLoot(this, "mat_gold", 0, 500);
	addLoot(this, "lifeforce", 0, 1);
	
	//first scroll
	int rs1 = XORRandom(8);
	
	if (rs1==0)
		addLoot(this, "carnage", 0, 1);
	else if (rs1==1)
		addLoot(this, "drought", 0, 1);
	else if (rs1==2)
		addLoot(this, "sfshark", 0, 1);
	else if (rs1==3)
		addLoot(this, "selemental", 0, 1);
	else if (rs1==4)
		addLoot(this, "smeteor", 0, 1);
	else if (rs1==5)
		addLoot(this, "sreturn", 0, 1);
	else if (rs1==6)
		addLoot(this, "sreinforce", 0, 1);
	else if (rs1==7)
		addLoot(this, "midas", 0, 1);

	//second scroll
	int rs2 = XORRandom(8);
	
	if (rs2==0)
		addLoot(this, "carnage", 0, 1);
	else if (rs2==1)
		addLoot(this, "drought", 0, 1);
	else if (rs2==2)
		addLoot(this, "sfshark", 0, 1);
	else if (rs2==3)
		addLoot(this, "selemental", 0, 1);
	else if (rs2==4)
		addLoot(this, "smeteor", 0, 1);
	else if (rs2==5)
		addLoot(this, "sreturn", 0, 1);
	else if (rs2==6)
		addLoot(this, "sreinforce", 0, 1);
	else if (rs2==7)
		addLoot(this, "midas", 0, 1);
	
	//first soul
	int rc1 = XORRandom(6);
	
	if (rc1==0)
		addLoot(this, "spyro", 0, 1);
	else if (rc1==1)
		addLoot(this, "sburd", 0, 1);
	else if (rc1==2)
		addLoot(this, "sdragoon", 0, 1);
	else if (rc1==3)
		addLoot(this, "swizard", 0, 1);
	else if (rc1==4)
		addLoot(this, "scrossbow", 0, 1);
	else if (rc1==5)
		addLoot(this, "sassassin", 0, 1);
	
	//second soul
	int rc2 = XORRandom(6);
	
	if (rc2==0)
		addLoot(this, "spyro", 0, 1);
	else if (rc2==1)
		addLoot(this, "sburd", 0, 1);
	else if (rc2==2)
		addLoot(this, "sdragoon", 0, 1);
	else if (rc2==3)
		addLoot(this, "swizard", 0, 1);
	else if (rc2==4)
		addLoot(this, "scrossbow", 0, 1);
	else if (rc2==5)
		addLoot(this, "sassassin", 0, 1);
		
	//third soul
	int rc3 = XORRandom(6);
	
	if (rc3==0)
		addLoot(this, "spyro", 0, 1);
	else if (rc3==1)
		addLoot(this, "sburd", 0, 1);
	else if (rc3==2)
		addLoot(this, "sdragoon", 0, 1);
	else if (rc3==3)
		addLoot(this, "swizard", 0, 1);
	else if (rc3==4)
		addLoot(this, "scrossbow", 0, 1);
	else if (rc3==5)
		addLoot(this, "sassassin", 0, 1);	
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