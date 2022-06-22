
void LoadDefaultMapLoaders()
{
	printf("############ GAMEMODE Map Maker Online");
	
	RegisterFileExtensionScript("Scripts/MapLoaders/LoadPNGMap.as", "png");
	RegisterFileExtensionScript("Scripts/MapLoaders/GenerateMapMakerGen.as", "kaggen.cfg");
}
