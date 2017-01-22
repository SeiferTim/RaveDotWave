package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;

class MenuState extends FlxState
{
	
	private var music:FlxSound;
	private var amps:Array<Array<Float>>;
	private var timer:Float = 0;
	
	override public function create():Void
	{
		super.create();
		amps = new Array<Array<Float>>();
		
		music = new FlxSound();
		music.loadEmbedded(AssetPaths.bensound_dubstep__mp3, false, true, musicFinished);
		//music.volume = 0;
		music.play();
	}

	private function musicFinished():Void
	{
		trace(amps);
	}
	
	override public function update(elapsed:Float):Void
	{
		if (music.playing)
		{
			timer += elapsed;
			if (timer >= .1)
			{
				timer -= .1;
				trace(music.amplitudeLeft, music.amplitudeRight);
				amps.push([music.amplitudeLeft, music.amplitudeRight]);
			}
		}
		
		super.update(elapsed);
	}
}
