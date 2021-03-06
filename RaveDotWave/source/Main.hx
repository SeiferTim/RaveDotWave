package;

import flixel.FlxGame;
import openfl.Lib;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		#if debug
		addChild(new FlxGame(0, 0, MainState));
		#else
		addChild(new FlxGame(0, 0, IntroState));
		
		#end
	}
}
