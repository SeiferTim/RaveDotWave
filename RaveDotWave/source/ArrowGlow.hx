package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.tweens.FlxTween;

class ArrowGlow extends FlxSprite 
{
	private var parent:Arrow;
	private var tween:FlxTween;
	
	public function new() 
	{
		super();
		frames = GraphicsCache.loadGraphicFromAtlas("arrows", AssetPaths.arrows__png, AssetPaths.arrows__xml).atlasFrames;
		animation.addByNames("glow", ["ArrowGlow.png"]);
		animation.addByNames("x", ["XX.png"]);
		
		kill();
		
	}
	
	public function spawn(Parent:Arrow):Void
	{
		parent = Parent;
		reset(parent.x, parent.y);
		animation.play("glow");
		switch(parent.animation.name)
		{
			case "up":
				angle = -90;
			case "down":
				angle = 90;
			case "left":
				angle = 180;
			case "right":
				angle = 0;
		}
		alpha = 1;
		tween = FlxTween.tween(this, {alpha:0}, .1, {type:FlxTween.PINGPONG});
	}
	
	override public function update(elapsed:Float):Void 
	{
		if (!parent.alive)
		{
			kill();
			
		}
		else if (parent.y > FlxG.height / 2)
		{
			if (tween != null)
			{
				tween.cancel();
				tween = null;
				alpha = 1;
			}
			
			animation.play("x");
			angle = 0;
		}
		y = parent.y;
		super.update(elapsed);
	}
	
	override public function kill():Void 
	{
		if (tween != null)
		{
			tween.cancel();
			tween = null;
			alpha = 1;
		}
		super.kill();
	}
	
}