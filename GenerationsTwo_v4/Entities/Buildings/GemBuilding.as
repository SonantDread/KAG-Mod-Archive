// GemBuilding.as
// Made by Rajang
// Much love - Rob

#include "GenericButtonCommon.as"

void onInit(CBlob@ this)
{
    this.SetLightColor(SColor(255,0,255,0));
}

bool checkName(string blobName)
{
	return (blobName == "gem");
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
    if((forBlob.getTeamNum() == this.getTeamNum() || this.getTeamNum() >= 20) && forBlob.isOverlapping(this) && canSeeButtons(this, forBlob)){
        if(forBlob.getCarriedBlob() is null){return true;}
        else if(checkName(forBlob.getCarriedBlob().getName())){return true;}
    }
    return false;
    
}

void onAddToInventory(CBlob@ this, CBlob@ blob)
{
    if (checkName(blob.getName()))
    {
        int quant = this.getInventory().getCount("gem");
		this.getSprite().SetFrame(quant);
		if(quant > 0){
			this.SetLightRadius(quant*12+12);
			this.SetLight(true);
		} else {
			this.SetLight(false);
		}
    }
}

void onRemoveFromInventory(CBlob@ this, CBlob@ blob)
{
    if (checkName(blob.getName()))
    {
        int quant = this.getInventory().getCount("gem");
		this.getSprite().SetFrame(quant);
		if(quant > 0){
			this.SetLightRadius(quant*12+12);
			this.SetLight(true);
		} else {
			this.SetLight(false);
		}
    }
}

void onInit(CSprite@ this)
{
    CBlob @blob = this.getBlob();
    if(blob !is null)
	this.SetFrame(blob.getInventory().getCount("gem"));
}