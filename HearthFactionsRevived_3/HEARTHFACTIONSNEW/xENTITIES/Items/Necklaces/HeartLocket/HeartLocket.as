void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint@ attachedPoint)
{
    attached.Tag("Healing2");
}
void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
    detached.Untag("Healing2");
}