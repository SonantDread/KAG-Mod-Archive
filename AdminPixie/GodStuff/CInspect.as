

class CInspect : CEffectModeBase
{
	string getType(){return "Inspect";}
    CBlob@ _selectedBlob;
    CBlob@ selectedBlob
    {
        get{return _selectedBlob;}
        set
        {
            if(_selectedBlob !is null)
            {
                _selectedBlob.getSprite().setRenderStyle(RenderStyle::Style::normal);
            }

            @_selectedBlob = value;
            if(_selectedBlob !is null)
            {
                _selectedBlob.getSprite().setRenderStyle(RenderStyle::Style::shadow);
                CBitStream params;
                params.write_u16(_selectedBlob.getNetworkID());
                blob.SendCommand(blob.getCommandID("setSelectedBlob"),params);
            }
            else
            {
                blob.SendCommand(blob.getCommandID("resetSelectedBlob"));
            }
        }
    }
    CBlob@ hoveredBlob;
    CMap@ map;

    void init(CBlob@ blob) override
    {
        @map = getMap();
        blob.addCommandID("setSelectedBlob");
        blob.addCommandID("resetSelectedBlob");


        CEffectModeBase::init(blob);
    }
	void onTick() override
    {
        if(blob.getPlayer() !is null && blob.getPlayer().isLocal())
        {
            CControls@ controls = getControls();

            if(hoveredBlob !is null && hoveredBlob !is selectedBlob)
            {
                hoveredBlob.getSprite().setRenderStyle(RenderStyle::Style::normal);
            }
            @hoveredBlob = map.getBlobAtPosition(this.blob.getAimPos());
            if(hoveredBlob !is null)
            {
                this.hoveredBlob.getSprite().setRenderStyle(RenderStyle::Style::outline);
            }

            if(controls.isKeyJustPressed(KEY_LBUTTON))
            {
                @selectedBlob = hoveredBlob;//it's ok if hoverBlob is null, allows to unselect something
            }
        }
        CEffectModeBase::onTick();
    }
	void render(CSprite@ sprite, f32 scale)
    {

        CEffectModeBase::render(sprite,scale);
    }
	void processCommand(u8 cmd, CBitStream @params)
    {
        if(cmd == blob.getCommandID("setMode"))
        {
            if(hoveredBlob !is null)
            {
                hoveredBlob.getSprite().setRenderStyle(RenderStyle::Style::normal);
            }
        }
        else if(cmd == blob.getCommandID("setSelectedBlob"))
        {
            CBlob@ sblob = getBlobByNetworkID(params.read_u16());
            if(sblob !is null)
            {
                @_selectedBlob = sblob;
            }
        }
        else if(cmd == blob.getCommandID("resetSelectedBlob"))
        {
            @_selectedBlob = null;
        }

        CEffectModeBase::processCommand(cmd, @params);
    }
}