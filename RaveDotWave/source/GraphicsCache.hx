package;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;


// this class is used to help cache graphics that might be re-used throughout the game.

class GraphicsCache
{

	public static var graphics:Map<String, FlxGraphic>;
	
	public static function init():Void
	{
		graphics = new Map();
	}
	
	public static function loadGraphicFromAtlas(Name:String, AtlasImage:String, AtlasXML:String):FlxGraphic
	{
		// first, see if we already have this graphic in the map (by name), if so, return it
		
		if (graphics == null)
			init();
		
		var g:FlxGraphic;
		g = graphics.get(Name);
		if (g == null)
		{
			// okay, load up this atlas file, add it to the cache, and then return it
			
			var t:FlxAtlasFrames = FlxAtlasFrames.fromSparrow(AtlasImage, AtlasXML);
			g = FlxGraphic.fromFrames(t);
			g.persist = true;
			g.destroyOnNoUse = false;
			graphics.set(Name, g);
			
		}
		return g;
		
	}
	
	
	
	
}