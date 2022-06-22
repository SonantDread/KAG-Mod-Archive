

bool checkName(string blobName)
{
	return (blobName == "gem" || blobName == "weak_gem" || blobName == "strong_gem" || blobName == "unstable_gem");
}

int gemCount(CBlob@ this)
{
	int quant = this.getInventory().getCount("gem");
	quant += this.getInventory().getCount("weak_gem");
	quant += this.getInventory().getCount("strong_gem");
	quant += this.getInventory().getCount("unstable_gem");
	return quant;
}

float gemPower(CBlob@ this)
{
	float power = float(this.getInventory().getCount("gem"));
	power += float(this.getInventory().getCount("weak_gem"))*0.5f;
	power += float(this.getInventory().getCount("strong_gem"))*2.0f;
	power += float(this.getInventory().getCount("unstable_gem"))*(float(XORRandom(6))*0.5f+0.5f);
	return power;
}

bool isUnstable(CBlob@ this)
{
	return (this.getInventory().getCount("unstable_gem") > 0);
}