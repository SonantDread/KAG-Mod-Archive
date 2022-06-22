
void onInit(CBlob@ this)
{
  if (getNet().isServer())
  {
    this.set_u16('decay time', 90);
  }

  this.maxQuantity = 125;

  this.getCurrentScript().runFlags |= Script::remove_after_this;
}