void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint@ attachedPoint)
{
    attached.Tag("Float");
}
void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
    detached.Untag("Float");
}
