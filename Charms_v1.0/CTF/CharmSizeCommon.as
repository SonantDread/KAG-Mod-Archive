void onInit(CRules@ this)
{
	this.addCommandID("smaller icons");
	this.addCommandID("bigger icons");
	this.addCommandID("sync fclick");

	if (getLocalPlayer() is null)
		return;

	string username = getLocalPlayer().getUsername();

	/*bool temporary = false;

	uint gtime = getGameTime();

	CBitStream bs2;
	bs2.write_string(username);
	bs2.write_u32(gtime);
	bs2.write_bool(temporary);

	this.SendCommand(this.getCommandID("sync fclick"), bs2);*/
}