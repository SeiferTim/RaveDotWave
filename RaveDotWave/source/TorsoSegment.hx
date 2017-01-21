package;
import flixel.FlxG;
import flixel.addons.nape.FlxNapeSprite;
import flixel.util.FlxColor;
import nape.shape.Shape;


class TorsoSegment extends FlxNapeSprite
{

	public function new() 
	{
		super();
		
		makeGraphic(96, 48, FlxColor.RED);
		
		createRectangularBody(96, 48);
		
		setBodyMaterial(0.2, 1.0, 1.4, 0.1, 0.01);
		
	}
	
}