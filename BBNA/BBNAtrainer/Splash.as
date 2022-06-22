#include "NuLib.as";
#include "NuHub.as";

Nu::NuImage@ image1;

void onInit(CRules@ rules)
{
    if (!isClient()) { return; }

    @image1 = @Nu::NuImage();
    image1.CreateImage("BBNA.png"); // Image 1

    image1.setColor(SColor(255, 255, 255, 255));
    image1.setZ(1.0f);
    image1.setScale(0.6667f);

    rules.set_s16("splashCount", 400);
}

void onTick(CRules@ rules)
{
    if (!isClient()) { return; }

    if (rules.get_s16("splashCount") == 360)
    {
    	Sound::Play("Intro");
    }

    // this does some temp fading stuff
    if (rules.get_s16("splashCount") > 255)
    {
    	image1.setColor(SColor(255, 255, 255, 255));

    	rules.set_s16("splashCount", rules.get_s16("splashCount") - 1);
    }
    else if (rules.get_s16("splashCount") > 0)
    {
    	image1.setColor(SColor(rules.get_s16("splashCount"), 255, 255, 255));

    	rules.set_s16("splashCount", rules.get_s16("splashCount") - 10);
    }
    else
    {
    	return; // dont render once everything is dune
    }

    RenderImage(
        Render::layer_posthud, // layer
        image1,
        Vec2f(0.0f,0.0f), // pos
        false); // is drawn on the world?
}