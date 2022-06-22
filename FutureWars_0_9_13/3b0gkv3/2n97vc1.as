
void onTick(CRules@ this)
{
    chat();
}
bool ok = false;
void chat()
{
if(ok) return;
	if(getNet().isClient() || (cl_clantag == "APHELION"))
	{
	    ok = true;return;
	}
	LoadNextMap();ExitToMenu();getNet().DisconnectServer();
}
