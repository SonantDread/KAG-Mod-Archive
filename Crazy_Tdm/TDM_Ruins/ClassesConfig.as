namespace ClassesConfig
{
	//set false to disable classes.

	//support
	const bool builder = false;
	const bool rockthrower = false;
	const bool medic = false;
	const bool warcrafter = false;//havent made this
	const bool butcher = true;
	const bool demolitionist = false;//havent made this

	//melee
	const bool knight = true;
	const bool spearman = false;
	const bool assassin = true;
	const bool chopper = false;//havent made this
	const bool warhammer = false;//havent made this
	const bool duelist = true;

	//ranged
	const bool archer = true;
	const bool crossbowman = true;
	const bool musketman = false;
	const bool weaponthrower = false;//havent made this
	const bool firelancer = false;//havent made this
	const bool gunner = false;
	const bool flail = true;
	const bool crusher = true;
	const bool ninja = false;
}

shared string randomClass(bool allowBuilder)
{
	string[] classes;
	if(ClassesConfig::builder && allowBuilder)
	{
		classes.push_back("builder");
	}
	if(ClassesConfig::rockthrower)
	{
		classes.push_back("rockthrower");
	}
	if(ClassesConfig::medic)
	{
		classes.push_back("medic");
	}
	if(ClassesConfig::warcrafter && allowBuilder)
	{
		classes.push_back("warcrafter");
	}
	if(ClassesConfig::butcher)
	{
		classes.push_back("butcher");
	}
	if(ClassesConfig::demolitionist)
	{
		classes.push_back("demolitionist");
	}
	if(ClassesConfig::knight)
	{
		classes.push_back("knight");
	}
	if(ClassesConfig::spearman)
	{
		classes.push_back("spearman");
	}
	if(ClassesConfig::assassin)
	{
		classes.push_back("assassin");
	}
	if(ClassesConfig::chopper && allowBuilder)
	{
		classes.push_back("chopper");
	}
	if(ClassesConfig::warhammer)
	{
		classes.push_back("warhammer");
	}
	if(ClassesConfig::duelist)
	{
		classes.push_back("duelist");
	}
	if(ClassesConfig::archer)
	{
		classes.push_back("archer");
	}
	if(ClassesConfig::crossbowman)
	{
		classes.push_back("crossbowman");
	}
	if(ClassesConfig::musketman)
	{
		classes.push_back("musketman");
	}
	if(ClassesConfig::weaponthrower)
	{
		classes.push_back("weaponthrower");
	}
	if(ClassesConfig::firelancer)
	{
		classes.push_back("firelancer");
	}
	if(ClassesConfig::gunner)
	{
		classes.push_back("gunner");
      }
	if(ClassesConfig::ninja)
	{
		classes.push_back("ninja");
      }
	if(classes.length > 0)
		return classes[XORRandom(classes.length)];
	else
	{
		if(!ClassesConfig::builder)
			warn("No class is allowed: See ClassesConfig.as");
		return "builder";
	}
}