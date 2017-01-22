package;

import flixel.addons.nape.FlxNapeSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;

class HandSegment extends FlxNapeSprite 
{

	public function new() 
	{
		super();
		
		//makeGraphic(32, 32, FlxColor.BLUE);
		
		frames = GraphicsCache.loadGraphicFromAtlas("hand", AssetPaths.hand__png, AssetPaths.hand__xml).atlasFrames;
		animation.addByNames("ORANGE", ["arm_ORANGE.png"],60);
		animation.addByNames("BLUE", ["arm_BLUE.png"],60);
		animation.addByNames("GREEN", ["arm_GREEN.png"],60);
		animation.addByNames("YELLOW", ["arm_YELLOW.png"],60);
		animation.play(Reg.djColors[Reg.djColorID]);
		
		createRectangularBody(32, 32);
		
		setBodyMaterial(0.2, 1.0, 1.4, 0.1, 0.01);
	}
	
	public function changeColor(Color:Int):Void
	{
		animation.play(Reg.djColors[Reg.djColorID],true);
	}
}
