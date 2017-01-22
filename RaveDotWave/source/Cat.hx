package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class Cat extends FlxSprite
{
	
	private var tween:FlxTween;
	private var tmpY:Float;

	public function new()
	{
		super();
		frames = GraphicsCache.loadGraphicFromAtlas("cats", AssetPaths.audience__png, AssetPaths.audience__xml).atlasFrames;
		kill();
	}

	public function spawn():Void
	{
		animation.randomFrame();
		reset(FlxG.random.int( Std.int(-width / 2), Std.int(FlxG.width + (width / 2))), FlxG.height);
		tween = FlxTween.tween(this, {y: FlxG.height - (height * FlxG.random.float(.33, .8))}, .5, {startDelay:FlxG.random.float(0, .5), type:FlxTween.ONESHOT, ease:FlxEase.quadIn, onStart:function(_){
			if (FlxG.random.bool(15))
			{		
				var rnd:Int = FlxG.random.int(0, 3);
				switch(rnd)
				{
					case 0:
						FlxG.sound.play(AssetPaths.shortmeow1__wav);
					case 1:
						FlxG.sound.play(AssetPaths.shortmeow2__wav);
					case 2:
						FlxG.sound.play(AssetPaths.shortmeow3__wav);
					case 3:
						FlxG.sound.play(AssetPaths.shortmeow4__wav);
				
				}
			}
			
		}, onComplete:function(_){
			tween.cancel();
			tween = null;
		}});
		
	}
	
	public function leave():Void
	{
		alive = false;
		exists = true;
		if (tween != null)
		{
			tween.cancel();
			tween = null;
		}
		tween = FlxTween.tween(this, {y: FlxG.height}, .5, {startDelay:FlxG.random.float(0,.5),type:FlxTween.ONESHOT, ease:FlxEase.quadIn, onComplete:function(_){kill(); } });
		
	}
	override public function kill():Void 
	{
		if (tween != null)
		{
			tween.cancel();
			tween = null;
		}
		super.kill();
	}
	
	public function bounce(Amount:Float):Void
	{
		if (tween != null)
		{
			return;
			
		}
		tmpY = y;
		tween = FlxTween.tween(this, {y:y - Amount}, .2, {startDelay:FlxG.random.float(0,.1),type:FlxTween.ONESHOT, ease:FlxEase.quintOut, onComplete:finishBounce});
		
	}
	
	private function finishBounce(_):Void
	{
		tween = FlxTween.tween(this, {y:tmpY}, .2, {type:FlxTween.ONESHOT, ease:FlxEase.quintIn, onComplete:totallyFinishBounce});
	}
	
	private function totallyFinishBounce(_):Void
	{
		tween.cancel();
		tween = null;
	}
}