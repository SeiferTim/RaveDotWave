package;
import flixel.FlxG;
import flixel.addons.nape.FlxNapeSprite;
import flixel.util.FlxColor;
import nape.phys.BodyType;
import nape.shape.Shape;


class TorsoSegment extends FlxNapeSprite
{

	public function new(?Static:Bool = false, ?Head:Bool = false) 
	{
		super();
		
		if (Head)
		{
			frames = GraphicsCache.loadGraphicFromAtlas("head", AssetPaths.head__png, AssetPaths.head__xml).atlasFrames;
			animation.addByNames("ORANGE", ["head_ORANGE.png"],60);
			animation.addByNames("BLUE", ["head_BLUE.png"],60);
			animation.addByNames("GREEN", ["head_GREEN.png"],60);
			animation.addByNames("YELLOW", ["head_YELLOW.png"],60);
			animation.play(Reg.djColors[Reg.djColorID]);
			createRectangularBody(96, 96, Static ? BodyType.STATIC : BodyType.DYNAMIC);
		}
		else
		{
			//makeGraphic(96, 48, FlxColor.RED);
			frames = GraphicsCache.loadGraphicFromAtlas("torso", AssetPaths.torso__png, AssetPaths.torso__xml).atlasFrames;
			animation.addByNames("ORANGE", ["torso_ORANGE.png"],60);
			animation.addByNames("BLUE", ["torso_BLUE.png"],60);
			animation.addByNames("YELLOW", ["torso_YELLOW.png"],60);
			animation.addByNames("GREEN", ["torso_GREEN.png"],60);
			animation.play(Reg.djColors[Reg.djColorID]);
			createRectangularBody(96, 48, Static ? BodyType.STATIC : BodyType.DYNAMIC);
		}
		
		setBodyMaterial(0.2, 1.0, 1.4, 0.1, 0.01);
		
	}
	
	public function changeColor(Color:Int):Void
	{
		animation.play(Reg.djColors[Reg.djColorID], true);
	}
}