void LoadMap()
{
	RegisterFileExtensionScript("Scripts/MapLoaders/LoadPNGMap.as", "png");
	LoadRules("Rules/PolishedZombies/gamemode.cfg");
	LoadMapCycle("Rules/PolishedZombies/mapcycle.cfg");
	LoadNextMap();
}
