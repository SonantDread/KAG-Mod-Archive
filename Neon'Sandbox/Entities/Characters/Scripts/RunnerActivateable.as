void onInit(CBlob@ this)
{
	//these don't actually use it, they take the controls away
	this.push("names to activate", "lantern");
	this.push("names to activate", "detonator");
	this.push("names to activate", "airstrike");
	this.push("names to activate", "summoner");
	this.push("names to activate", "fl");
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}
