
void onInit(CBlob@ this)
{
  this.maxQuantity = 6;

  this.getCurrentScript().runFlags |= Script::remove_after_this;
}
