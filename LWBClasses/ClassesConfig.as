namespace ClassesConfig
{
	//set false to disable classes.

	//support
	const bool builder = true;
	const bool rockthrower = true;
	const bool medic = true;

	//melee
	const bool knight = true;
	const bool spearman = true;
	const bool assassin = true;

	//ranged
	const bool archer = true;
	const bool crossbowman = true;
	const bool musketman = true;
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

	if(classes.length > 0)
		return classes[XORRandom(classes.length)];
	else
	{
		if(!ClassesConfig::builder)
			warn("No class is allowed: See ClassesConfig.as");
		return "builder";
	}
}