void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint@ attachedPoint)
{
    attached.Tag("Speed");
}
void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
    detached.Untag("Speed");
}