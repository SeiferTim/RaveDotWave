package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.display.FlxSpriteAniRot;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;


class Credits extends FlxSubState 
{

	public function new(BGColor:FlxColor=FlxColor.TRANSPARENT) 
	{
		super(BGColor);
		
		
	}
	
	override public function create():Void 
	{
		var cred:FlxSprite = new FlxSprite(0, 0, AssetPaths.Rave_Wave_Credits_demo__jpg);
		cred.screenCenter(FlxAxes.XY);
		add(cred);
		
		
		super.create();
	}
	
	override public function update(elapsed:Float):Void 
	{
		if (FlxG.keys.anyJustReleased([SPACE, ENTER, ESCAPE]) || FlxG.gamepads.anyJustReleased(FlxGamepadInputID.A) || FlxG.gamepads.anyJustReleased(FlxGamepadInputID.A) || FlxG.gamepads.anyJustReleased(FlxGamepadInputID.B) || FlxG.gamepads.anyJustReleased(FlxGamepadInputID.START))
		{
			close();
		}
		super.update(elapsed);
	}
	
}