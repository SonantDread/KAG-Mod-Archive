// DefaultGUI.as

void LoadDefaultGUI()
{
	if (v_driver > 0)
	{
		// TC Icons
		// Components
		AddIconToken("$mat_copperwire$", "Material_CopperWire.png", Vec2f(9, 11), 0);
		AddIconToken("$icon_tankshell$", "Material_TankShell.png", Vec2f(16, 16), 3);
		
		// Merchant
		AddIconToken("$bp_mechanist$", "Blueprints.png", Vec2f(16, 16), 2);
		AddIconToken("$mat_goldingot$", "Material_GoldIngot.png", Vec2f(16, 16), 1);
		AddIconToken("$musicdisc$", "MusicDisc.png", Vec2f(8, 8), 0);
		AddIconToken("$seed$", "Seed.png",Vec2f(8,8),0);
		AddIconToken("$icon_cake$", "Cake.png", Vec2f(16, 8), 0);
		AddIconToken("$icon_car$", "Icon_Car.png", Vec2f(16, 8), 0);
		
		// Chicken Market
		AddIconToken("$bobomax$", "Bobomax.png", Vec2f(8, 8), 0);
		AddIconToken("$badgerplushie$", "BadgerPlushie.png", Vec2f(16, 16), 0);
		AddIconToken("$icecream$", "IceCream.png", Vec2f(8, 8), 0);
		AddIconToken("$fuger$", "Fuger.png", Vec2f(16, 8), 0);
		AddIconToken("$mat_battery$", "Material_Battery.png", Vec2f(8, 16), 0);
		AddIconToken("$taser$", "Taser.png", Vec2f(16, 8), 0);
		AddIconToken("$lotteryticket$", "LotteryTicket.png", Vec2f(16, 8), 0);
		AddIconToken("$buyshop$", "ChickenMarket_PartnerIcon.png", Vec2f(64, 16), 0);
		AddIconToken("$icon_sam$", "SAM_Icon.png", Vec2f(32, 24), 0);
		AddIconToken("$icon_lws$", "LWS_Icon.png", Vec2f(32, 24), 0);
		AddIconToken("$sammissile$", "SAM_Missile.png", Vec2f(8, 16), 0);
		AddIconToken("$zapper$", "Zapper.png", Vec2f(24, 24), 0);
		
		// Ammo
		AddIconToken("$icon_gatlingammo$", "Material_GatlingAmmo.png", Vec2f(16, 16), 2);
		AddIconToken("$icon_rifleammo$", "Material_RifleAmmo.png", Vec2f(16, 16), 3);
		AddIconToken("$icon_shotgunammo$", "Material_ShotgunAmmo.png", Vec2f(16, 16), 3);
		AddIconToken("$icon_pistolammo$", "Material_PistolAmmo.png", Vec2f(16, 16), 3);
		AddIconToken("$icon_howitzershell$", "Material_HowitzerShell.png", Vec2f(16, 8), 0);
		
		// Explosives
		AddIconToken("$icon_smallbomb$", "Material_SmallBomb.png", Vec2f(16, 16), 0);
		AddIconToken("$icon_incendiarybomb$", "Material_IncendiaryBomb.png", Vec2f(16, 16), 0);
		AddIconToken("$icon_bigbomb$", "Material_BigBomb.png", Vec2f(16, 32), 0);
		AddIconToken("$icon_fragmine$", "FragMine.png", Vec2f(16, 16), 0);
		AddIconToken("$icon_rocket$", "Rocket.png", Vec2f(24, 40), 0);
		AddIconToken("$icon_smallrocket$", "Material_SmallRocket.png", Vec2f(8, 16), 0);
		AddIconToken("$icon_nuke$", "Nuke.png", Vec2f(40, 32), 0);
		AddIconToken("$icon_claymore$", "Claymore.png", Vec2f(16, 16), 1);
		AddIconToken("$icon_claymoreremote$", "ClaymoreRemote.png", Vec2f(8, 16), 0);
		AddIconToken("$icon_grenade$", "Material_Grenade.png", Vec2f(8, 8), 0);
		AddIconToken("$icon_bunkerbuster$", "Material_BunkerBuster.png", Vec2f(16, 16), 0);
		AddIconToken("$icon_stunbomb$", "Material_StunBomb.png", Vec2f(16, 16), 0);
		AddIconToken("$icon_clusterbomb$", "Material_ClusterBomb.png", Vec2f(16, 16), 0);
		AddIconToken("$icon_guidedrocket$", "GuidedRocket.png", Vec2f(16, 24), 0);
		AddIconToken("$icon_smokegrenade$", "SmokeGrenade.png", Vec2f(16, 16), 0);
		AddIconToken("$icon_dynamite$", "Dynamite.png", Vec2f(8, 16), 0);
		AddIconToken("$icon_mininuke$", "Material_MiniNuke.png", Vec2f(16, 16), 0);
		AddIconToken("$icon_fraggrenade$", "FragGrenade.png", Vec2f(8, 8), 0);

		// Metal
		AddIconToken("$mat_copperingot$", "Material_CopperIngot.png", Vec2f(16, 16), 1);
		AddIconToken("$mat_ironingot$", "Material_IronIngot.png", Vec2f(16, 16), 1);
		AddIconToken("$mat_steelingot$", "Material_SteelIngot.png", Vec2f(16, 16), 1);
		AddIconToken("$mat_goldingot$", "Material_GoldIngot.png", Vec2f(16, 16), 1);
		AddIconToken("$mat_mithrilingot$", "Material_MithrilIngot.png", Vec2f(16, 16), 1);
		AddIconToken("$mat_plasteel$", "Material_Plasteel.png", Vec2f(16, 16), 1);

		// Ores
		AddIconToken("$mat_copper$", "Material_Copper.png", Vec2f(16, 16), 1);
		AddIconToken("$mat_iron$", "Material_Iron.png", Vec2f(16, 16), 1);
		AddIconToken("$mat_steel$", "Material_Steel.png", Vec2f(16, 16), 1);
		AddIconToken("$mat_gold$", "Material_Gold.png", Vec2f(16, 16), 1);
		AddIconToken("$mat_coal$", "Material_Coal.png", Vec2f(16, 16), 1);
		AddIconToken("$mat_concrete$", "Material_Concrete.png", Vec2f(16, 16), 1);
		AddIconToken("$mat_mithril$", "Material_Mithril.png", Vec2f(16, 16), 1);
		AddIconToken("$mat_mithrilenriched$", "Material_MithrilEnriched.png", Vec2f(16, 16), 1);
		
		// Builder shop
		AddIconToken("$gramophone$", "Gramophone.png", Vec2f(16, 16), 0);
		AddIconToken("$powerdrill$", "PowerDrill.png", Vec2f(32, 16), 0);
		AddIconToken("$artisancertificate$", "ArtisanCertificate.png", Vec2f(8, 8), 0);
		AddIconToken("$table$", "Table.png", Vec2f(24, 16), 0);
		AddIconToken("$chair$", "Chair.png", Vec2f(16, 24), 0);
		AddIconToken("$jackolantern$", "JackOLantern.png", Vec2f(16, 16), 0);

		// Armory
		AddIconToken("$royalarmor$", "RoyalArmor.png", Vec2f(16, 8), 0);
		AddIconToken("$icon_shackles$", "Shackles.png", Vec2f(16, 8), 0);
		AddIconToken("$icon_nightstick$", "Nightstick.png", Vec2f(16, 8), 0);
		AddIconToken("$icon_militaryhelmet$", "MilitaryHelmet.png", Vec2f(16, 16), 0);
		AddIconToken("$icon_bulletproofvest$", "Bulletproofvest.png", Vec2f(16, 16), 0);
		AddIconToken("$icon_combatboots$", "CombatBoots.png", Vec2f(16, 16), 0);
		
		// Mechanist
		AddIconToken("$icon_klaxon$", "Klaxon.png", Vec2f(24, 16), 0);
		AddIconToken("$icon_automat$", "Automat.png", Vec2f(16, 16), 0);
		AddIconToken("$icon_gasextractor$", "GasExtractor.png", Vec2f(24, 16), 0);
		AddIconToken("$icon_mustard$", "Material_Mustard.png", Vec2f(8, 16), 0);
		AddIconToken("$icon_scubagear$", "ScubaGear.png", Vec2f(16, 16), 0);
		AddIconToken("$icon_radpill$", "Radpill.png", Vec2f(8, 8), 0);
		AddIconToken("$icon_raygun$", "Raygun.png", Vec2f(24, 16), 0);
		AddIconToken("$icon_jetpack$", "Jetpack.png", Vec2f(16, 16), 0);
		AddIconToken("$icon_flippers$", "Flippers.png", Vec2f(16, 16), 0);
		AddIconToken("$icon_minershelmet$", "MinersHelmet.png", Vec2f(16, 16), 0);
		AddIconToken("$icon_flashlight$", "Flashlight.png", Vec2f(16, 8), 0);
		AddIconToken("$icon_backpack$", "Backpack.png", Vec2f(16, 16), 0);
		AddIconToken("$icon_suicidevest$", "SuicideVest.png", Vec2f(16, 16), 0);
		AddIconToken("$icon_binoculars$", "Binoculars.png", Vec2f(16, 8), 0);
		AddIconToken("$icon_firework$", "Firework.png", Vec2f(16, 24), 0);
		
		// Gunsmith
		AddIconToken("$rifle$", "Rifle.png", Vec2f(24, 8), 0);
		AddIconToken("$smg$", "SMG.png", Vec2f(24, 8), 0);
		AddIconToken("$revolver$", "Revolver.png", Vec2f(16, 8), 0);
		AddIconToken("$icon_bazooka$", "Bazooka.png", Vec2f(16, 8), 0);
		AddIconToken("$icon_flamethrower$", "Flamethrower.png", Vec2f(16, 8), 0);
		AddIconToken("$icon_shotgun$", "Shotgun.png", Vec2f(16, 8), 0);
		AddIconToken("$icon_grenadelauncher$", "GrenadeLauncher.png", Vec2f(16, 8), 0);		
		AddIconToken("$icon_mininukelauncher$", "MiniNukeLauncher.png", Vec2f(40, 8), 0);		
	
		// Bandits
		AddIconToken("$ratburger$", "RatBurger.png", Vec2f(16, 16), 0);
		AddIconToken("$ratfood$", "Rat.png", Vec2f(16, 16), 0);
		AddIconToken("$faultymine$", "FaultyMine.png", Vec2f(16, 16), 0);
		AddIconToken("$badger$", "Badger.png", Vec2f(32, 16), 0);
		AddIconToken("$icon_banditammo$", "Material_BanditAmmo.png", Vec2f(16, 16), 3);
		AddIconToken("$icon_banditpistol$", "BanditPistol.png", Vec2f(16, 8), 0);
		AddIconToken("$icon_banditrifle$", "BanditRifle.png", Vec2f(24, 16), 0);
		AddIconToken("$icon_foodcan$", "FoodCan.png", Vec2f(16, 16), 0);
		AddIconToken("$icon_bigfoodcan$", "BigFoodCan.png", Vec2f(16, 24), 0);
		AddIconToken("$icon_vodka$", "Vodka.png", Vec2f(8, 16), 0);
	
		// Misc
		AddIconToken("$icon_cargocontainer$", "CargoContainer.png", Vec2f(64, 24), 0);
		AddIconToken("$icon_armoredcar$", "ArmoredCar_Icon.png", Vec2f(48, 32), 0);

	
		// add color tokens
		AddColorToken("$RED$", SColor(255, 105, 25, 5));
		AddColorToken("$GREEN$", SColor(255, 5, 105, 25));
		AddColorToken("$GREY$", SColor(255, 195, 195, 195));

		// add default icon tokens
		string interaction = "/GUI/InteractionIcons.png";
		AddIconToken("$NONE$", interaction, Vec2f(32, 32), 9);
		AddIconToken("$TIME$", interaction, Vec2f(32, 32), 0);
		AddIconToken("$COIN$", "Sprites/coins.png", Vec2f(16, 16), 1);
		AddIconToken("$TEAMS$", "GUI/MenuItems.png", Vec2f(32, 32), 1);
		AddIconToken("$SPECTATOR$", "GUI/MenuItems.png", Vec2f(32, 32), 19);
		AddIconToken("$FLAG$", CFileMatcher("flag.png").getFirst(), Vec2f(32, 16), 0);
		AddIconToken("$DISABLED$", interaction, Vec2f(32, 32), 9, 1);
		AddIconToken("$CANCEL$", "GUI/MenuItems.png", Vec2f(32, 32), 29);
		AddIconToken("$RESEARCH$", interaction, Vec2f(32, 32), 27);
		AddIconToken("$ALERT$", interaction, Vec2f(32, 32), 10);
		AddIconToken("$down_arrow$", "GUI/ArrowDown.png", Vec2f(8, 8), 0);
		AddIconToken("$ATTACK_LEFT$", interaction, Vec2f(32, 32), 18, 1);
		AddIconToken("$ATTACK_RIGHT$", interaction, Vec2f(32, 32), 17, 1);
		AddIconToken("$ATTACK_THIS$", interaction, Vec2f(32, 32), 19, 1);
		AddIconToken("$DEFEND_LEFT$", interaction, Vec2f(32, 32), 18, 2);
		AddIconToken("$DEFEND_RIGHT$", interaction, Vec2f(32, 32), 17, 2);
		AddIconToken("$DEFEND_THIS$", interaction, Vec2f(32, 32), 19, 2);
		AddIconToken("$CLASSCHANGE$", "Rules/Tutorials/TutorialImages.png", Vec2f(32, 32), 7);
		AddIconToken("$BUILD$", interaction, Vec2f(32, 32), 15);
		AddIconToken("$STONE$", "Sprites/World.png", Vec2f(8, 8), 48);
		AddIconToken("$!!!$", "/Emoticons.png", Vec2f(22, 22), 48);

		// classes
		AddIconToken("$ARCHER$",        "ClassIcons.png",       Vec2f(16, 16), 2);
		AddIconToken("$KNIGHT$",        "ClassIcons.png",       Vec2f(16, 16), 1);
		AddIconToken("$BUILDER$",       "ClassIcons.png",       Vec2f(16, 16), 0);

		// blocks
		AddIconToken("$stone_block$", "Sprites/World.png", Vec2f(8, 8), CMap::tile_castle);
		AddIconToken("$back_stone_block$", "Sprites/World.png", Vec2f(8, 8), CMap::tile_castle_back);
		AddIconToken("$wood_block$", "Sprites/World.png", Vec2f(8, 8), CMap::tile_wood);
		AddIconToken("$back_wood_block$", "Sprites/World.png", Vec2f(8, 8), CMap::tile_wood_back);

		// SOURCE
		AddIconToken("$coin_slot$",     "CoinSlot.png",         Vec2f(16, 16), 3);
		AddIconToken("$lever$",         "Lever.png",            Vec2f(8, 16), 3);
		AddIconToken("$pressureplate$", "PressurePlate.png",    Vec2f(8, 16), 0);
		AddIconToken("$pushbutton$",    "PushButton.png",       Vec2f(8, 8), 3);

		// PASSIVE
		AddIconToken("$diode$",         "Diode.png",            Vec2f(8, 16), 3);
		AddIconToken("$elbow$",         "Elbow.png",            Vec2f(16, 16), 3);
		AddIconToken("$junction$",      "Junction.png",         Vec2f(16, 16), 3);
		AddIconToken("$inverter$",      "Inverter.png",         Vec2f(8, 16), 3);
		AddIconToken("$oscillator$",    "Oscillator.png",       Vec2f(8, 16), 7);
		AddIconToken("$magazine$",      "Magazine.png",         Vec2f(16, 16), 3);
		AddIconToken("$randomizer$",    "Randomizer.png",       Vec2f(8, 16), 7);
		AddIconToken("$resistor$",      "Resistor.png",         Vec2f(8, 16), 3);
		AddIconToken("$tee$",           "Tee.png",              Vec2f(16, 16), 3);
		AddIconToken("$toggle$",        "Toggle.png",           Vec2f(8, 16), 3);
		AddIconToken("$transistor$",    "Transistor.png",       Vec2f(16, 16), 3);
		AddIconToken("$wire$",          "Wire.png",             Vec2f(16, 16), 3);

		// LOAD
		AddIconToken("$bolter$",        "Bolter.png",           Vec2f(16, 16), 3);
		AddIconToken("$dispenser$",     "Dispenser.png",        Vec2f(16, 16), 3);
		AddIconToken("$lamp$",          "Lamp.png",             Vec2f(16, 16), 3);
		AddIconToken("$obstructor$",    "Obstructor.png",       Vec2f(16, 16), 3);
		AddIconToken("$spiker$",        "Spiker.png",           Vec2f(16, 16), 3);

		// techs
		AddIconToken("$tech_stone$", "GUI/TechnologyIcons.png", Vec2f(16, 16), 16);

		// keys
		const Vec2f keyIconSize(16, 16);
		AddIconToken("$KEY_W$", "GUI/Keys.png", keyIconSize, 6);
		AddIconToken("$KEY_A$", "GUI/Keys.png", keyIconSize, 0);
		AddIconToken("$KEY_S$", "GUI/Keys.png", keyIconSize, 1);
		AddIconToken("$KEY_D$", "GUI/Keys.png", keyIconSize, 2);
		AddIconToken("$KEY_E$", "GUI/Keys.png", keyIconSize, 3);
		AddIconToken("$KEY_F$", "GUI/Keys.png", keyIconSize, 4);
		AddIconToken("$KEY_C$", "GUI/Keys.png", keyIconSize, 5);
		AddIconToken("$KEY_M$", "GUI/Keys.png", keyIconSize, 10);
		AddIconToken("$KEY_Q$", "GUI/Keys.png", keyIconSize, 7);
		AddIconToken("$LMB$", "GUI/Keys.png", keyIconSize, 8);
		AddIconToken("$RMB$", "GUI/Keys.png", keyIconSize, 9);
		AddIconToken("$KEY_SPACE$", "GUI/Keys.png", Vec2f(24, 16), 8);
		AddIconToken("$KEY_HOLD$", "GUI/Keys.png", Vec2f(24, 16), 9);
		AddIconToken("$KEY_TAP$", "GUI/Keys.png", Vec2f(24, 16), 10);
		AddIconToken("$KEY_F1$", "GUI/Keys.png", Vec2f(24, 16), 12);
		AddIconToken("$KEY_ESC$", "GUI/Keys.png", Vec2f(24, 16), 13);
		AddIconToken("$KEY_ENTER$", "GUI/Keys.png", Vec2f(24, 16), 14);

		// vehicles
		AddIconToken("$LoadAmmo$", interaction, Vec2f(16, 16), 7, 7);
	}
}
