
void onInit(CBlob@ this)
{
  if (getNet().isServer())
  {
    this.set_u8('decay step', 18);
  }

  this.maxQuantity = 500;

  this.getCurrentScript().runFlags |= Script::remove_after_this;
}
