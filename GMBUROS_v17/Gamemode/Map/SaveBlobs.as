
#include "EquipmentCommon.as";
#include "EnchantCommon.as";
#include "ClanCommon.as"

void SaveSpecialBlobs(string file_name){
	CBlob@[] blobs;
	getBlobs(@blobs);
	
	ConfigFile cfg = ConfigFile(file_name);
	
	int blobsSaved = 0;
	
	for(int i = 0;i < blobs.length;i++){
		CBlob @blob = blobs[i];
		
		if(blob !is null){
			string name = blob.getName();
			
			if(name == "humanoid"){
			
				Vec2f pos = blob.getPosition();
			
				
				
				EquipmentInfo@ equip;
				if(blob.get("equipInfo", @equip)){
					for(int i = 0;i < EquipSlot::length;i++){
						if(getEquipmentBlob(checkEquipped(equip,i),checkEquippedType(equip,i)) != ""){
							cfg.add_string("blob"+blobsSaved+"_name", getEquipmentBlob(checkEquipped(equip,i),checkEquippedType(equip,i)));
							cfg.add_u16("blob"+blobsSaved+"_team", -1);
							cfg.add_f32("blob"+blobsSaved+"_x", pos.x);
							cfg.add_f32("blob"+blobsSaved+"_y", pos.y);
							blobsSaved++;
						}
					}
				}
				
				u32 Enchants = blob.get_u32("enchants");
				if(hasEnchant(Enchants,Enchantment::WeakGem)){
					cfg.add_string("blob"+blobsSaved+"_name", "weak_gem");
					cfg.add_u16("blob"+blobsSaved+"_team", -1);
					cfg.add_f32("blob"+blobsSaved+"_x", pos.x);
					cfg.add_f32("blob"+blobsSaved+"_y", pos.y);
					blobsSaved++;
				}
				if(hasEnchant(Enchants,Enchantment::Gem)){
					cfg.add_string("blob"+blobsSaved+"_name", "gem");
					cfg.add_u16("blob"+blobsSaved+"_team", -1);
					cfg.add_f32("blob"+blobsSaved+"_x", pos.x);
					cfg.add_f32("blob"+blobsSaved+"_y", pos.y);
					blobsSaved++;
				}
				if(hasEnchant(Enchants,Enchantment::StrongGem)){
					cfg.add_string("blob"+blobsSaved+"_name", "strong_gem");
					cfg.add_u16("blob"+blobsSaved+"_team", -1);
					cfg.add_f32("blob"+blobsSaved+"_x", pos.x);
					cfg.add_f32("blob"+blobsSaved+"_y", pos.y);
					blobsSaved++;
				}
				if(hasEnchant(Enchants,Enchantment::UnstableGem)){
					cfg.add_string("blob"+blobsSaved+"_name", "unstable_gem");
					cfg.add_u16("blob"+blobsSaved+"_team", -1);
					cfg.add_f32("blob"+blobsSaved+"_x", pos.x);
					cfg.add_f32("blob"+blobsSaved+"_y", pos.y);
					blobsSaved++;
				}
				
				
				
			} else
			if(name == "ward"){
			
				Vec2f pos = blob.getPosition();
				int team = blob.getTeamNum();
			
				cfg.add_string("blob"+blobsSaved+"_name", name);
				cfg.add_u16("blob"+blobsSaved+"_team", team);
				cfg.add_f32("blob"+blobsSaved+"_x", pos.x);
				cfg.add_f32("blob"+blobsSaved+"_y", pos.y);
				
				cfg.add_u16("blob"+blobsSaved+"_factor", blob.get_s8("factor"));
				cfg.add_u16("blob"+blobsSaved+"_gem", blob.get_u8("gem"));
				cfg.add_u16("blob"+blobsSaved+"_mat", blob.get_u8("mat"));
				blobsSaved++;
				
			} else
			if(blob.hasTag("save") || blob.hasTag("material")){
			
				Vec2f pos = blob.getPosition();
				int team = blob.getTeamNum();
			
				if(name == "meteor")name = "landed_meteor";
			
				cfg.add_string("blob"+blobsSaved+"_name", name);
				cfg.add_u16("blob"+blobsSaved+"_team", team);
				cfg.add_f32("blob"+blobsSaved+"_x", pos.x);
				cfg.add_f32("blob"+blobsSaved+"_y", pos.y);
				
				if(blob.getQuantity() > 1)cfg.add_u16("blob"+blobsSaved+"_quant", blob.getQuantity());
				if(blob.hasTag("locked"))if(blob.exists("player_locked"))cfg.add_string("blob"+blobsSaved+"_lockowner", blob.get_string("player_locked"));
				if(blob.exists("ClanID"))cfg.add_u16("blob"+blobsSaved+"_clan", blob.get_u16("ClanID"));
				
				
				
				blobsSaved++;
			}
		}
	}

	cfg.add_u32("blobs_saved", blobsSaved);
	
	cfg.saveFile(file_name);
	print("Saved blobs to Cache/"+file_name);
}

void LoadSpecialBlobs(string file_name){
	
	ConfigFile cfg = ConfigFile("../Cache/"+file_name);
	
	if(cfg.exists("blobs_saved")){
		int blobsSaved = cfg.read_u32("blobs_saved");
		
		for(int i = 0;i < blobsSaved;i++){
			string name = cfg.read_string("blob"+i+"_name");
			CBlob @sblob = server_CreateBlobNoInit(name);
			if(sblob !is null){
				sblob.setPosition(Vec2f(cfg.read_f32("blob"+i+"_x"),cfg.read_f32("blob"+i+"_y")));
				sblob.server_setTeamNum(cfg.read_u16("blob"+i+"_team"));
				if(cfg.exists("blob"+i+"_quant")){
					sblob.server_SetQuantity(cfg.read_u16("blob"+i+"_quant"));
					sblob.Tag('custom quantity');
				}
				if(cfg.exists("blob"+i+"_lockowner")){
					sblob.set_string("player_locked",cfg.read_string("blob"+i+"_lockowner"));
					sblob.Tag("locked");
				}
				if(cfg.exists("blob"+i+"_clan")){
					sblob.set_u16("ClanID",cfg.read_u16("blob"+i+"_clan"));
					sblob.Tag("locked");
				}
				if(name.find("tree") >= 0)sblob.Tag("startbig");
				if(name.find("big_door") >= 0){
					sblob.Tag("force_placement");
				}
				
				sblob.Init();
				
				
				if(name.find("ward") >= 0){
					sblob.set_s8("factor",cfg.read_u16("blob"+i+"_factor"));
					sblob.set_u8("gem",cfg.read_u16("blob"+i+"_gem"));
					sblob.set_u8("mat",cfg.read_u16("blob"+i+"_mat"));
				}
			}
		}
	} else {
		print("Invalid or non-existant saved blobs file.");
	}
}