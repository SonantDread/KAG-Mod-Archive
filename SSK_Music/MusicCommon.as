// Game Music

const u8 SONG_BUFFER = 4;

shared class Song
{
	string fileHandle;
	string description;
	u16 lengthSeconds;

	Song(string _fileHandle, string _description, u16 _lengthSeconds)
	{
		fileHandle = _fileHandle;
		description = _description;
		lengthSeconds = _lengthSeconds;
	}
};

namespace Music
{
	const ::Song@[] songs = 
	{
		Song("../Mods/SSK_Music/Songs/music_xenoblade2.ogg", "Mor Ardain [Roaming the Wastes] - Xenoblade Chronicles 2", 193),
		Song("../Mods/SSK_Music/Songs/MarioKart.ogg", "'Mount Must Dash' level theme from Super Mario 3D World", 102),
		Song("../Mods/SSK_Music/Songs/GreenHill.ogg", "'Green Hill Zone' theme from the Sonic Utopia OST", 205),
		//Song("../Mods/SSK_Music/Songs/StrangeSunset.ogg", "Guile's theme, 'Strange Sunset', from Street Fighter EX3", 197),
		Song("../Mods/SSK_Music/Songs/music_yoshi.ogg", "Yoshi's Story (Super Smash Bros. Melee remix)", 126),
		Song("../Mods/SSK_Music/Songs/Targets.ogg", "'Break the Targets' theme from Super Smash Bros. Melee", 88),
		Song("../Mods/SSK_Music/Songs/Xenoblade.ogg", "'Gaur Plains' theme from Xenoblade Chronicles", 256),
		Song("../Mods/SSK_Music/Songs/RainbowRoad.ogg", "'Rainbow Road' theme from Mario Kart 7", 121),
		//Song("../Mods/SSK_Music/Songs/Hyrule.ogg", "'Hyrule Circuit' theme from Mario Kart 8", 76),
		//Song("../Mods/SSK_Music/Songs/Fates.ogg", "'End of All (Land)' from Fire Emblem Fates", 264),
		Song("../Mods/SSK_Music/Songs/music_destiny.ogg", "Destiny [Ablaze] (Fire Emblem Awakening) - SSB Ultimate REMIX", 160),
		//Song("../Mods/SSK_Music/Songs/Smash4.ogg", "Menu theme from Super Smash Bros. 4", 132),
		Song("../Mods/SSK_Music/Songs/music_ssbu.ogg", "Menu theme from Super Smash Bros. Ultimate", 164),
		Song("../Mods/SSK_Music/Songs/Ridley.ogg", "'Vs. Ridley', a Super Metroid Remix. Featured in Super Smash Bros. Brawl", 108),
		Song("../Mods/SSK_Music/Songs/music_metalslug.ogg", "Main Theme from Metal Slug - SSB Ultimate REMIX", 144),
		Song("../Mods/SSK_Music/Songs/music_pokemonxy.ogg", "Battle! (Trainer Battle) - Pokemon X & Pokemon Y", 129),
		Song("../Mods/SSK_Music/Songs/music_balladofthegoddess.ogg", "Ballad of the Goddess - SSB Ultimate REMIX", 126)
	};
}
