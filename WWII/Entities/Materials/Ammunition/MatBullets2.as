
void onInit(CBlob@ this)
{
  if (getNet().isServer())
  {
    this.set_u16('decay time', 60);
  }

  this.maxQuantity = 80;

  this.getCurrentScript().runFlags |= Script::remove_after_this;
}
