// TDM PNG loader base class - extend this to add your own PNG loading functionality!

#include "BasePNGLoader.as";

// TDM custom map colors
namespace tdm_colors
{
	enum color
	{
		tradingpost_1 = 0xFF8888FF,
		tradingpost_2 = 0xFFFF8888,
		impaledcorpse = 0xFF99423E,
		randomcorpse  = 0xFF8E150F
	};
}

//the loader

class TDMPNGLoader : PNGLoader
{
	TDMPNGLoader()
	{
		super();
	}

	//override this to extend functionality per-pixel.
	void handlePixel(const SColor &in pixel, int offset) override
	{
		PNGLoader::handlePixel(pixel, offset);

		switch (pixel.color)
		{
			case tdm_colors::tradingpost_1: autotile(offset); spawnBlob(map,"trader",offset,0); break;
			case tdm_colors::tradingpost_2: autotile(offset); spawnBlob(map,"tradingpost",offset,0); break;
			case tdm_colors::impaledcorpse: autotile(offset); spawnBlob(map,"impaledknight",offset,0); break;
			case tdm_colors::randomcorpse: {
				autotile(offset);
				string blobName;
				if(offset%3<=1) {
					blobName=	"randomcorpse";
				}else{
					if(offset%2==0) {
						blobName=	"corpsestill";
					}else{
						blobName=	"corpsestillcrossbowman";
					}
				}
				spawnBlob(map,blobName,offset,0);
				break;
			}
		};
	}
};

// --------------------------------------------------

bool LoadMap(CMap@ map, const string& in fileName)
{
	print("!!!!!!!!!!!!!!!!!! LOADING TDM PNG MAP " + fileName);

	TDMPNGLoader loader();

	return loader.loadMap(map , fileName);
}
