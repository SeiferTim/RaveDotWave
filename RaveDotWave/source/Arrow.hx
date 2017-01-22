package;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.gamepad.FlxGamepadInputID;

class Arrow extends FlxSprite
{
	private var side:Int = -1;
	private var button:Int = -1;
	public var parent:MainState;
	private var didBad:Bool = false;
	
	public function new(Parent:MainState) 
	{
		super();
		
		parent = Parent;
		
		frames = GraphicsCache.loadGraphicFromAtlas("arrows", AssetPaths.arrows__png, AssetPaths.arrows__xml).atlasFrames;
		animation.addByNames("down", ["ArrowDown.png"]);
		animation.addByNames("up", ["ArrowUp.png"]);
		animation.addByNames("left", ["ArrowLeft.png"]);
		animation.addByNames("right", ["ArrowRight.png"]);
		
		kill();
	}
	
	public function spawn(WhichButton:Int, WhichSide:Int):Void
	{
		button = WhichButton;
		side = WhichSide;
		didBad = false;
		var posx:Float = 0;
		if (WhichSide == 0)
		{
			switch (WhichButton) 
			{
				case 0:
					posx = 48;
					animation.play("left");
				case 1:
					posx = 48 + ((width + 3) * 1);
					animation.play("up");
				case 2:
					posx = 48 + ((width + 3) * 2);
					animation.play("down");
				case 3:
					posx = 48 + ((width + 3) * 3);
					animation.play("right");
					
			}
		}
		else
		{
			switch (WhichButton) 
			{
				case 0:
					posx = FlxG.width - 48 - (width * 4) - (3 * 3);
					animation.play("left");
				case 1:
					posx = FlxG.width - 48 - (width * 3) - (3 * 2);
					animation.play("up");
				case 2:
					posx = FlxG.width - 48 - (width*2) - 3;
					animation.play("down");
				case 3:
					posx = FlxG.width - 48 - width;
					animation.play("right");
			}
		}
		reset(posx, -height);
	}
	
	override public function update(elapsed:Float):Void 
	{
		if (y >= 288 && y <=  288 + height)
		{
			if (side == 0)
			{
				switch(button)
				{
					case 0:
						if (FlxG.gamepads.anyPressed(FlxGamepadInputID.LEFT_STICK_DIGITAL_LEFT))
						{
							// good!
							parent.goodButton(button, side);
							kill();
						}
					case 1:
						if (FlxG.gamepads.anyPressed(FlxGamepadInputID.LEFT_STICK_DIGITAL_UP))
						{
							// good!
							parent.goodButton(button, side);
							kill();
						}
						
					case 2:
						if (FlxG.gamepads.anyPressed(FlxGamepadInputID.LEFT_STICK_DIGITAL_DOWN))
						{
							// good!
							parent.goodButton(button, side);
							kill();
						}
					
					case 3:
						if (FlxG.gamepads.anyPressed(FlxGamepadInputID.LEFT_STICK_DIGITAL_RIGHT))
						{
							// good!
							parent.goodButton(button, side);
							kill();
						}
						
				}
			}
			else
			{
				switch(button)
				{
					case 0:
						if (FlxG.gamepads.anyPressed(FlxGamepadInputID.RIGHT_STICK_DIGITAL_LEFT))
						{
							// good!
							parent.goodButton(button, side);
							kill();
						}
					case 1:
						if (FlxG.gamepads.anyPressed(FlxGamepadInputID.RIGHT_STICK_DIGITAL_UP))
						{
							// good!
							parent.goodButton(button, side);
							kill();
						}
						
					case 2:
						if (FlxG.gamepads.anyPressed(FlxGamepadInputID.RIGHT_STICK_DIGITAL_DOWN))
						{
							// good!
							parent.goodButton(button, side);
							kill();
						}
					
					case 3:
						if (FlxG.gamepads.anyPressed(FlxGamepadInputID.RIGHT_STICK_DIGITAL_RIGHT))
						{
							// good!
							parent.goodButton(button, side);
							kill();
						}
						
				}
			}
		}
		else if (y > 288 +height && !didBad)
		{
			didBad = true;
			parent.badButton();
		}
		
		super.update(elapsed);
	}
	
}