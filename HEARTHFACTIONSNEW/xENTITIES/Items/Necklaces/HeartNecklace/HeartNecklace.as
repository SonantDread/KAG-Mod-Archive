void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint@ attachedPoint)
{
    attached.Tag("Healing");
}
void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
    detached.Untag("Healing");
}