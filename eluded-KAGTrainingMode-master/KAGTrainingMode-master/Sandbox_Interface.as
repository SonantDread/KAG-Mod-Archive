#include "CTF_Structs.as";

const int LINE_SPACING = 14;

void onInit(CRules@ this)
{
}

void onRender(CRules@ this)
{
    Vec2f topLeftPtr(8,200);
    GUI::SetFont("menu");
    GUI::DrawText("Optimal attack speeds:", topLeftPtr, color_white);
    topLeftPtr.y += LINE_SPACING;
    GUI::DrawText("Jab: 2", topLeftPtr, color_white); 
    topLeftPtr.y += LINE_SPACING;
    GUI::DrawText("Slash: 16", topLeftPtr, color_white); 
    topLeftPtr.y += LINE_SPACING;
    GUI::DrawText("Double slash: 39", topLeftPtr, color_white); 
    topLeftPtr.y += LINE_SPACING;
}
