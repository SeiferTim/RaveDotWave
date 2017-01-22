package;

import flash.media.Video;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.nape.FlxNapeSprite;
import flixel.effects.particles.FlxEmitter;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.gamepad.FlxGamepadAnalogStick;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import haxe.ds.StringMap;
import haxe.macro.Expr.Catch;
import openfl.Assets;
import nape.callbacks.CbType;
import nape.callbacks.InteractionType;
import nape.callbacks.PreCallback;
import nape.callbacks.PreFlag;
import nape.callbacks.PreListener;
import nape.constraint.Constraint;
import nape.constraint.DistanceJoint;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Compound;
#if desktop
import openfl.system.System;
#end

class MainState extends FlxState 
{

	private var frequency:Float = 60.0;
    private var damping:Float = 1.0;
	private inline static var NUM_TORSO:Int = 10;
	private inline static var NUM_ARM:Int = 16;
	
	private var torso:Array<TorsoSegment>;
	private var anchor:FlxPoint;
	private var torsoType:CbType;
	private var wallType:CbType;
	private var handType:CbType;
	
	private var airTimer:Float = 0;
	private var airSpeed:Vec2;
	
	private inline static var XAIR_MAX:Float = 1;
	private inline static var MOVE_SPEED:Float = 2000;
	
	private var leftHand:HandSegment;
	private var rightHand:HandSegment;
	
	private var starting:Bool = true;
	
	private var bound_left:FlxNapeSprite;
	private var bound_right:FlxNapeSprite;
	
	private var leftArm:Array<HandSegment>;
	private var rightArm:Array<HandSegment>;
	
	private var torsoCompound:Compound;
	private var leftArmCompound:Compound;
	private var rightArmCompound:Compound;
	
	private var midPoint:TorsoSegment;
	
	private var BaseLeftBeats:Array<String>;
	private var BaseRightBeats:Array<String>;
	
	private var PreLeftBeats:Array<String>;
	private var PreRightBeats:Array<String>;
	private var LeftBeats:Array<String>;
	private var RightBeats:Array<String>;
	
	
	private var leftButtons:Array<FlxSprite>;
	private var rightButtons:Array<FlxSprite>;
	
	private var arrowGroup:FlxTypedGroup<Arrow>;
	private var arrowGlows:FlxTypedGroup<ArrowGlow>;
	
	private var face:FlxNapeSprite;
	
	private var rating:FlxSprite;
	private var ratingPointer:FlxSprite;
	
	private var ratingValue:Int = 20;
	
	private var strobes:Array<FlxSprite>;
	
	private var strobeTimer:Float = 0;
	private var gameOver:Bool  = false;
	
	private var scoreValue:Int=0;
	private var multiValue:Int=1;
	
	private var score:FlxText;
	private var multi:FlxText;
	
	private var audienceGroup:FlxTypedGroup<Cat>;
	
	private var preGame:Bool = true;
	private var hud:FlxSprite;
	private var finishedFadeIn:Bool = false;
	
	private var hudElements:Array<FlxSprite>;
	
	private var logo:FlxSprite;
	private var cursor:FlxSprite;
	private var txtBegin:FlxText;
	private var txtCredits:FlxText;
	private var txtExit:FlxText;
	
	private var startCursorIn:Bool = false;
	private var finishCursorIn:Bool = false;
	
	private var startingGame:Bool = false;
	
	private var selected:Int = 0;
	private var colorTimer:Float = 0;
	
	private var confettiLeft:FlxEmitter;
	private var confettiRight:FlxEmitter;
	
	private var readyForRetry:Bool = false;
	private var gameOverLogo:FlxSprite;
	private var txtRetry:FlxText;
	
	
	override public function create():Void 
	{
		super.create();
		
		Reg.djColorID = FlxG.random.int(0, Reg.djColors.length - 1);
		
		add(new FlxSprite(0, 0, AssetPaths.bg__jpg));
		
		
		buildBeats();
		
		FlxNapeSpace.init();
		FlxNapeSpace.createWalls(0, 0, FlxG.width, (FlxG.height * .8) + 10,50);
		
		FlxNapeSpace.space.gravity.setxy(0, 500);
		
		
		anchor = FlxPoint.get(FlxG.width / 2, FlxG.height * .8);
		
		createTorso();
		
		audienceGroup = new FlxTypedGroup<Cat>(500);
		
		add(audienceGroup);
		add(new FlxSprite(0, 0, AssetPaths.BG_Bottom_Gradient__png));
		
		airSpeed = Vec2.get();
		
		
		
		createStrobes();
		
		createHUD();
		
		arrowGroup = new  FlxTypedGroup<Arrow>(100);
		add(arrowGroup);
		
		arrowGlows = new  FlxTypedGroup<ArrowGlow>(100);
		add(arrowGlows);
		
		rating = new FlxSprite();
		rating.loadGraphic(AssetPaths.rating__png);
		rating.x = FlxG.width / 2 - rating.width / 2;
		rating.y = 24;
		add(rating);
		
		ratingPointer = new FlxSprite(0, 0, AssetPaths.rating_pointer__png);
		ratingPointer.x = rating.x;
		ratingPointer.y = rating.y - 16;
		add(ratingPointer);
		
		score = new  FlxText(0, 0, 0, StringTools.lpad(Std.string(scoreValue), "0", 8), 48);
		score.color = FlxColor.WHITE;
		score.borderStyle = FlxTextBorderStyle.OUTLINE;
		score.borderColor = FlxColor.GRAY;
		score.borderSize = 4;
		
		add(score);
		multi = new FlxText(0, 0, 0, StringTools.rpad("x1"," ", 5), 48);
		multi.color = FlxColor.WHITE;
		multi.borderStyle = FlxTextBorderStyle.OUTLINE;
		multi.borderColor = FlxColor.GRAY;
		multi.borderSize = 4;
		add(multi);
		
		score.x = 48;
		score.y = FlxG.height - 48 - score.height;
		
		multi.x = score.x + score.width + 12;
		multi.y = FlxG.height - 48 - multi.height;
		
		//
		
		hudElements = [];
	
		
		for (s in strobes)
		{
			hudElements.push(s);
			s.visible = false;
			s.alpha = 0;
		}
		hudElements.push(hud);
		hud.visible = false;
		hud.alpha = 0;
		
		for (b in leftButtons)
		{
			hudElements.push(b);
			b.visible = false;
			b.alpha = 0;
		}
		
		for (b in rightButtons)
		{
			hudElements.push(b);
			b.visible = false;
			b.alpha = 0;
		}
		
		hudElements.push(rating);
		rating.visible = false;
		rating.alpha = 0;
		
		hudElements.push(ratingPointer);
		ratingPointer.visible = false;
		ratingPointer.alpha = 0;
		
		logo = new FlxSprite(0, 0, AssetPaths.LOGO__png);
		
		logo.x = FlxG.width / 2 - logo.width / 2;
		logo.y = 12;
		add(logo);
		
		logo.alpha = 0;
		
		score.alpha = 0;
		score.visible = false;
		multi.alpha = 0;
		multi.visible = false;
		
		hudElements.push(score);
		hudElements.push(multi);
		
		
		
		txtBegin = new FlxText(0, 0, 0, "Begin", 32);
		txtBegin.borderStyle = FlxTextBorderStyle.OUTLINE;
		txtBegin.borderColor = FlxColor.GRAY;
		txtBegin.borderSize = 4;
		txtBegin.x = FlxG.width - 48 - txtBegin.width;
		txtBegin.y = FlxG.height - 24 - (txtBegin.height * 3) - 24;
		add(txtBegin);
		txtBegin.alpha = 0;
		
		txtCredits = new FlxText(0, 0, 0, "Credits", 32);
		txtCredits.borderStyle = FlxTextBorderStyle.OUTLINE;
		txtCredits.borderColor = FlxColor.GRAY;
		txtCredits.borderSize = 4;
		txtCredits.x = txtBegin.x;
		txtCredits.y = FlxG.height - 24 - (txtCredits.height * 2) - 12;
		add(txtCredits);
		txtCredits.alpha = 0;
		
		txtExit = new FlxText(0, 0, 0, "Quit", 32);
		txtExit.borderStyle = FlxTextBorderStyle.OUTLINE;
		txtExit.borderColor = FlxColor.GRAY;
		txtExit.borderSize = 4;
		txtExit.x = txtBegin.x;
		txtExit.y = FlxG.height - 24 - (txtExit.height );
		add(txtExit);
		txtExit.alpha = 0;
		
		
		cursor = new FlxSprite(0, 0, AssetPaths.rating_pointer__png);
		cursor.angle = -90;
		cursor.x = txtBegin.x - cursor.width;
		cursor.y = txtBegin.y - (cursor.height / 2) + (txtBegin.height / 2);
		cursor.alpha = 0;
		add(cursor);
	
		confettiLeft = new FlxEmitter();
		confettiLeft.loadParticles(AssetPaths.confetti__png, 100, 16, true, true);
		confettiLeft.x = -20;
		confettiLeft.y = -20;
		confettiLeft.speed.set(1000, 3000);
		confettiLeft.angularVelocity.set( -100, 100, -20, 20);
		confettiLeft.acceleration.set(0, 500, 0, 1000, 0, 1000, 0, 2000);
		confettiLeft.lifespan.set(100);
		confettiLeft.alpha.set(1, 1, 0, 0);
		confettiLeft.launchMode = FlxEmitterMode.CIRCLE;
		confettiLeft.launchAngle.set(10, 80);
		
		add(confettiLeft);
		
		
		confettiRight = new FlxEmitter();
		confettiRight.loadParticles(AssetPaths.confetti__png, 100, 16, true, true);
		confettiRight.x = FlxG.width + 20;
		confettiRight.y = -20;
		confettiRight.speed.set(1000, 3000);
		confettiRight.angularVelocity.set( -100, 100, -20, 20);
		confettiRight.acceleration.set(0, 500, 0, 1000, 0, 1000, 0, 2000);
		confettiRight.lifespan.set(100);
		confettiRight.alpha.set(1, 1, 0, 0);
		confettiRight.launchMode = FlxEmitterMode.CIRCLE;
		confettiRight.launchAngle.set(100, 170);
		
		add(confettiRight);
		
		gameOverLogo = new FlxSprite(0, 0, AssetPaths.gameover__png);
		gameOverLogo.screenCenter(FlxAxes.XY);
		gameOverLogo.visible = false;
		gameOverLogo.alpha = 0;
		gameOverLogo.y = 32;
		add(gameOverLogo);
		
		txtRetry = new FlxText(0, 0, 0, "Retry?", 32);
		txtRetry.borderStyle = FlxTextBorderStyle.OUTLINE;
		txtRetry.borderColor = FlxColor.GRAY;
		txtRetry.borderSize = 4;
		txtRetry.screenCenter(FlxAxes.XY);
		txtRetry.y = FlxG.height - 48 - txtRetry.height;
		txtRetry.visible = false;
		txtRetry.alpha = 0;
		add(txtRetry);
		
		
		FlxG.camera.fade(FlxColor.BLACK, 2, true, function(){finishedFadeIn = true; });
	}
	
	
	private function changeColor():Void
	{
		Reg.djColorID++;
		if (Reg.djColorID >= Reg.djColors.length)
			Reg.djColorID = 0;
		for (t in torso)
			t.changeColor(Reg.djColorID);
		for (h in leftArm)
			h.changeColor(Reg.djColorID);
		for (h in rightArm)
			h.changeColor(Reg.djColorID);
	}
	
	private function startGame():Void
	{
		startingGame = true;
		FlxTween.num(1, 0, .66, {type:FlxTween.ONESHOT, ease:FlxEase.circOut, onComplete:function(_){
			FlxTween.num(0, 1, .66, {type:FlxTween.ONESHOT, ease:FlxEase.circOut, onComplete:function(_){
				preGame = false;
				#if flash
				FlxG.sound.playMusic(AssetPaths.bensound_dubstep__mp3, 1, true);
				#else
				FlxG.sound.playMusic(AssetPaths.bensound_dubstep__ogg, 1, true);
				#end
				
			}}, fadeInHud);
		}}, fadeOutIntro);
		
		
		
	}
	
	private function fadeInHud(Value:Float):Void
	{
		for (o in hudElements)
		{
			if (!o.visible)
				o.visible = true;
			o.alpha = Value;
		}
		for (s in strobes)
		{
			s.alpha = 0;
		}
	}
	
	private function fadeOutIntro(Value:Float):Void
	{
		logo.alpha = Value;
		txtBegin.alpha = Value;
		txtCredits.alpha = Value;
		cursor.alpha = Value;
		txtExit.alpha = Value;
	}
	
	private function addCat():Void
	{
		var c:Cat = audienceGroup.recycle(Cat);
		if (c == null)
		{
			c = new Cat();
		}
		c.spawn();
		audienceGroup.add(c);
	}
	
	private function removeCat():Void
	{
		
		var c:Cat = audienceGroup.getRandom();
		
		
		if ( c != null)
		{
			if (c.alive)
				c.leave();
		}
	}
	
	private function createStrobes():Void
	{
		strobes = [];
		
		var s:FlxSprite = new FlxSprite(0, 0, AssetPaths.strobe_blue__png);
		s.x = -s.width/2;
		s.y = -s.height/2;
		s.angle = FlxG.random.float(0, 360);
		s.alpha = 0;
		s.angularVelocity = FlxG.random.int(2, 10) * 30;
		add(s);
		strobes.push(s);
		
		s = new FlxSprite(0, 0, AssetPaths.strobe_pink__png);
		s.x = -s.width/2;
		s.y = -s.height/2;
		s.angle = FlxG.random.float(0, 360);
		s.alpha = 0;
		s.angularVelocity = FlxG.random.int(2, 10) * 30;
		add(s);
		strobes.push(s);
		
		var s = new FlxSprite(0, 0, AssetPaths.strobe_yellow__png);
		s.x = -s.width/2;
		s.y = -s.height/2;
		s.angle = FlxG.random.float(0, 360);
		s.alpha = 0;
		s.angularVelocity = FlxG.random.int(2, 10) * 30;
		add(s);
		strobes.push(s);
		
		s = new FlxSprite(0,0,AssetPaths.strobe_blue__png);
		s.x = FlxG.width - (s.width / 2);
		s.y = -s.height / 2;
		s.angle = FlxG.random.float(0, 360);
		s.alpha = 0;
		s.angularVelocity = FlxG.random.int(2, 10) * 30;
		s.flipX = true;
		add(s);
		strobes.push(s);
		
		s = new FlxSprite();
		s.loadGraphic(AssetPaths.strobe_pink__png);
		s.x = FlxG.width - (s.width / 2);
		s.y = -s.height / 2;
		s.angle = FlxG.random.float(0, 360);
		s.alpha = 0;
		s.angularVelocity = FlxG.random.int(2, 10) * 30;
		s.flipX = true;
		add(s);
		strobes.push(s);
		
		s = new FlxSprite();
		s.loadGraphic(AssetPaths.strobe_yellow__png);
		s.x = FlxG.width - (s.width / 2);
		s.y = -s.height / 2;
		s.angle = FlxG.random.float(0, 360);
		s.alpha = 0;
		s.angularVelocity = FlxG.random.int(2, 10) * 30;
		s.flipX = true;
		add(s);
		strobes.push(s);
	}
	
	private function createHUD():Void
	{
		hud = new FlxSprite(0, 0, AssetPaths.hud_back__png);
		add(hud);
		
		leftButtons = [];
		rightButtons = [];
		
		var button:FlxSprite = new FlxSprite();
		button.frames = GraphicsCache.loadGraphicFromAtlas("arrow_boxes", AssetPaths.arrow_boxes__png, AssetPaths.arrow_boxes__xml).atlasFrames;
		button.animation.addByNames("off", ["ArrowBoxLeft.png","ArrowBoxLeft.png"], 60, false);
		button.animation.addByNames("on", ["ArrowBoxLeft_Glow.png","ArrowBoxLeft_Glow.png"], 60, false);
		button.animation.addByNames("good", ["ArrowBoxLeft_Goal.png", "ArrowBoxLeft_Goal.png", "ArrowBoxLeft_Goal.png", "ArrowBoxLeft_Goal.png", "ArrowBoxLeft_Goal.png","ArrowBoxLeft_Goal.png", "ArrowBoxLeft_Goal.png", "ArrowBoxLeft_Goal.png", "ArrowBoxLeft_Goal.png", "ArrowBoxLeft_Goal.png"], 16, false);
		button.animation.play("off");
		button.x = 48;
		button.y = 288;
		leftButtons.push(button);
		add(button);
		
		button = new FlxSprite();
		button.frames = GraphicsCache.loadGraphicFromAtlas("arrow_boxes", AssetPaths.arrow_boxes__png, AssetPaths.arrow_boxes__xml).atlasFrames;
		button.animation.addByNames("off", ["ArrowBoxUp.png","ArrowBoxUp.png"], 60, false);
		button.animation.addByNames("on", ["ArrowBoxUp_Glow.png","ArrowBoxUp_Glow.png"], 60, false);
		button.animation.addByNames("good", ["ArrowBoxUp_Goal.png","ArrowBoxUp_Goal.png","ArrowBoxUp_Goal.png","ArrowBoxUp_Goal.png","ArrowBoxUp_Goal.png","ArrowBoxUp_Goal.png","ArrowBoxUp_Goal.png","ArrowBoxUp_Goal.png","ArrowBoxUp_Goal.png","ArrowBoxUp_Goal.png"],16, false);
		button.animation.play("off");
		button.x = 48 + (button.width + 3);
		button.y = 288;
		leftButtons.push(button);
		add(button);
		
		button = new FlxSprite();
		button.frames = GraphicsCache.loadGraphicFromAtlas("arrow_boxes", AssetPaths.arrow_boxes__png, AssetPaths.arrow_boxes__xml).atlasFrames;
		button.animation.addByNames("off", ["ArrowBoxDown.png","ArrowBoxDown.png"], 60, false);
		button.animation.addByNames("on", ["ArrowBoxDown_Glow.png","ArrowBoxDown_Glow.png"], 60, false);
		button.animation.addByNames("good", ["ArrowBoxDown_Goal.png","ArrowBoxDown_Goal.png","ArrowBoxDown_Goal.png","ArrowBoxDown_Goal.png","ArrowBoxDown_Goal.png","ArrowBoxDown_Goal.png","ArrowBoxDown_Goal.png","ArrowBoxDown_Goal.png","ArrowBoxDown_Goal.png","ArrowBoxDown_Goal.png"], 16, false);
		button.animation.play("off");
		button.x = 48 + ((button.width  + 3) * 2);
		button.y = 288;
		leftButtons.push(button);
		add(button);
		
		button = new FlxSprite();
		button.frames = GraphicsCache.loadGraphicFromAtlas("arrow_boxes", AssetPaths.arrow_boxes__png, AssetPaths.arrow_boxes__xml).atlasFrames;
		button.animation.addByNames("off", ["ArrowBoxRight.png","ArrowBoxRight.png"], 60, false);
		button.animation.addByNames("on", ["ArrowBoxRight_Glow.png","ArrowBoxRight_Glow.png"], 60, false);
		button.animation.addByNames("good", ["ArrowBoxRight_Goal.png","ArrowBoxRight_Goal.png","ArrowBoxRight_Goal.png","ArrowBoxRight_Goal.png","ArrowBoxRight_Goal.png","ArrowBoxRight_Goal.png","ArrowBoxRight_Goal.png","ArrowBoxRight_Goal.png","ArrowBoxRight_Goal.png","ArrowBoxRight_Goal.png"], 16, false);
		button.animation.play("off");
		button.x = 48 + ((button.width  + 3) * 3);
		button.y = 288;
		leftButtons.push(button);
		add(button);
		
		
		
		button = new FlxSprite();
		button.frames = GraphicsCache.loadGraphicFromAtlas("arrow_boxes", AssetPaths.arrow_boxes__png, AssetPaths.arrow_boxes__xml).atlasFrames;
		button.animation.addByNames("off", ["ArrowBoxRight.png"], 12, false);
		button.animation.addByNames("on", ["ArrowBoxRight_Glow.png"], 12, false);
		button.animation.addByNames("good", ["ArrowBoxRight_Goal.png","ArrowBoxRight_Goal.png","ArrowBoxRight_Goal.png","ArrowBoxRight_Goal.png","ArrowBoxRight_Goal.png","ArrowBoxRight_Goal.png","ArrowBoxRight_Goal.png","ArrowBoxRight_Goal.png","ArrowBoxRight_Goal.png","ArrowBoxRight_Goal.png"], 16, false);
		button.animation.play("off");
		button.x = FlxG.width - 48 - button.width;
		button.y = 288;
		rightButtons.unshift(button);
		add(button);
		
		button = new FlxSprite();
		button.frames = GraphicsCache.loadGraphicFromAtlas("arrow_boxes", AssetPaths.arrow_boxes__png, AssetPaths.arrow_boxes__xml).atlasFrames;
		button.animation.addByNames("off", ["ArrowBoxDown.png"], 12, false);
		button.animation.addByNames("on", ["ArrowBoxDown_Glow.png"], 12, false);
		button.animation.addByNames("good", ["ArrowBoxDown_Goal.png","ArrowBoxDown_Goal.png","ArrowBoxDown_Goal.png","ArrowBoxDown_Goal.png","ArrowBoxDown_Goal.png","ArrowBoxDown_Goal.png","ArrowBoxDown_Goal.png","ArrowBoxDown_Goal.png","ArrowBoxDown_Goal.png","ArrowBoxDown_Goal.png"], 16, false);
		button.animation.play("off");
		button.x = FlxG.width - 48 - button.width - ((button.width+3));
		button.y = 288;
		rightButtons.unshift(button);
		add(button);
		
		button = new FlxSprite();
		button.frames = GraphicsCache.loadGraphicFromAtlas("arrow_boxes", AssetPaths.arrow_boxes__png, AssetPaths.arrow_boxes__xml).atlasFrames;
		button.animation.addByNames("off", ["ArrowBoxUp.png"], 12, false);
		button.animation.addByNames("on", ["ArrowBoxUp_Glow.png"], 12, false);
		button.animation.addByNames("good", ["ArrowBoxUp_Goal.png","ArrowBoxUp_Goal.png","ArrowBoxUp_Goal.png","ArrowBoxUp_Goal.png","ArrowBoxUp_Goal.png","ArrowBoxUp_Goal.png","ArrowBoxUp_Goal.png","ArrowBoxUp_Goal.png","ArrowBoxUp_Goal.png","ArrowBoxUp_Goal.png"],16, false);
		button.animation.play("off");
		button.x = FlxG.width - 48 - button.width - ((button.width+3)*2);
		button.y = 288;
		rightButtons.unshift(button);
		add(button);
		
		button = new FlxSprite();
		button.frames = GraphicsCache.loadGraphicFromAtlas("arrow_boxes", AssetPaths.arrow_boxes__png, AssetPaths.arrow_boxes__xml).atlasFrames;
		button.animation.addByNames("off", ["ArrowBoxLeft.png"], 12, false);
		button.animation.addByNames("on", ["ArrowBoxLeft_Glow.png"], 12, false);
		button.animation.addByNames("good", ["ArrowBoxLeft_Goal.png", "ArrowBoxLeft_Goal.png", "ArrowBoxLeft_Goal.png", "ArrowBoxLeft_Goal.png", "ArrowBoxLeft_Goal.png", "ArrowBoxLeft_Goal.png", "ArrowBoxLeft_Goal.png", "ArrowBoxLeft_Goal.png", "ArrowBoxLeft_Goal.png", "ArrowBoxLeft_Goal.png"], 16, false);		
		button.animation.play("off");
		button.x = FlxG.width - 48 - button.width - ((button.width+3)*3);
		button.y = 288;
		rightButtons.unshift(button);
		add(button);
	}
	
	private function buildBeats():Void
	{
		BaseLeftBeats = [];
		BaseRightBeats = [];
		var leftData:String = Assets.getText(AssetPaths.LEFT_CHANNEL__txt);
		var rightData:String = Assets.getText(AssetPaths.RIGHT_CHANNEL__txt);
		
		var regex:EReg = new EReg("[ \t]*((\r\n)|\r|\n)[ \t]*", "g");
		var leftLines:Array<String> = regex.split(leftData);
		var rightLines:Array<String> = regex.split(rightData);
		var lastLeft:Float = 0;
		var lastRight:Float = 0;
		for (l in leftLines)
		{
			var parts:Array<String> = l.split(String.fromCharCode(9));
			if (Std.parseFloat(parts[0]) > lastLeft + 1)
			{
				lastLeft = Std.parseFloat(parts[0]);
				BaseLeftBeats.push(parts[0]);
			}
		}
		for (r in rightLines)
		{
			var parts:Array<String> = r.split(String.fromCharCode(9));
			if (Std.parseFloat(parts[0]) > lastRight + 1)
			{
				lastRight = Std.parseFloat(parts[0]);
				BaseRightBeats.push(parts[0]);
			}
		}
		PreLeftBeats = [];
		PreRightBeats = [];
		LeftBeats = [];
		RightBeats = [];
		
	}
	
	public function goodButton(Button:Int, Side:Int):Void
	{
		if (Side == 0)
		{
			leftButtons[Button].animation.play("good", true);
		}
		else
		{
			rightButtons[Button].animation.play("good", true);
		}
		ratingValue += 4;
		ratingValue = Std.int(FlxMath.bound(ratingValue, 0, 100));
		
		FlxG.camera.flash(FlxColor.fromHSB(FlxG.random.int(0, 24) * 15, 1, 1,  (ratingValue * .01)), .15);
		face.animation.randomFrame();
		scoreValue+= 5 * multiValue;
		multiValue++;
		score.text = StringTools.lpad(Std.string(scoreValue), "0", 8);
		multi.text = "x" + Std.string(multiValue);
		
		if (ratingValue >= 80)
		{
			if (Side == 0)
			{
				confettiLeft.start(true, 0, 0);
		
			}
			else
			{
				confettiRight.start(true, 0, 0);
			}
		}
		
		
		if (ratingValue >= 100)
		{
			FlxG.sound.play(AssetPaths.PERFECT_edit__wav);
		}
		else if (ratingValue >= 85)
		{
			FlxG.sound.play(AssetPaths.EXCELLENT_edit__wav);
		}
		else if (ratingValue >= 75)
		{
			FlxG.sound.play(AssetPaths.GREAT_edit__wav);
		}
		
	}
	public function badButton():Void
	{
		ratingValue -= 5;
		ratingValue = Std.int(FlxMath.bound( ratingValue, 0, 100));
		if (ratingValue <= 0)
		{
			// GAME OVER
			triggerGameOver();
			return;
		}
		multiValue = 0;
		multi.text = "x" + Std.string(multiValue);
		
	}
	
	private function triggerGameOver():Void
	{
		if (gameOver)
			return;
		gameOver = true;
		FlxG.sound.music.fadeOut(1, 0, function(_){
			FlxG.sound.play(AssetPaths.sega_rally_15_game_over_yeah1__wav);
		});
		gameOverLogo.visible = true;
		txtRetry.visible = true;
		FlxTween.tween(gameOverLogo, {alpha:1}, .66, {type:FlxTween.ONESHOT, ease:FlxEase.circInOut, onComplete:function(_){
			FlxTween.tween(txtRetry, {alpha:1},.66, {type:FlxTween.ONESHOT, ease:FlxEase.circInOut, onComplete:function(_){
				readyForRetry = true;
				
			}});
		}});
			
	}
	
	private function spawnArrow(Side:Int):Void
	{
		
		var a:Arrow = arrowGroup.recycle();
		if (a == null)
			a = new Arrow(this);
		a.spawn(FlxG.random.int(0, 3), Side);
		a.velocity.y = FlxG.height/4;
		arrowGroup.add(a);
	
		var g:ArrowGlow = arrowGlows.recycle();
		if (g == null)
			g = new ArrowGlow();
		g.spawn(a);
		arrowGlows.add(g);
			
	}
	
	override public function draw():Void 
	{
		face.body.position.x = torso[NUM_TORSO - 1].body.position.x;
		face.body.position.y = torso[NUM_TORSO - 1].body.position.y;
		super.draw();
	}
	
	private function updateRating():Void
	{
		ratingPointer.x = rating.x  + ((rating.width - ratingPointer.width ) * ratingValue * .01);
	}
	
	private function updateStrobes(elapsed:Float):Void
	{
		for (s in strobes)
		{
			if (ratingValue < 50)
			{
				s.alpha = 0;
			}
			else
			{
				s.alpha = (ratingValue - 50) / 50;
				
			}
			
			strobeTimer -= elapsed;
			if (strobeTimer <= 0)
			{
				s.angularVelocity = FlxG.random.int(2, 10) * 30;
			}
		}
	}
	
	private function bounceCat(C:Cat):Void
	{
		C.bounce(ratingValue * .01 * 15);
	}
	
	override public function update(elapsed:Float):Void 
	{
		
		for (s in leftButtons)
		{
			
			if (s.animation.finished)
				s.animation.play("off");
		}
		for (s in rightButtons)
		{
			
			if (s.animation.finished)
				s.animation.play("off");
		}	
		
		if (preGame)
		{
			if (!startingGame)
			{
				
				if (finishedFadeIn)
				{
					if (!startCursorIn)
					{
						startCursorIn = true;
						FlxTween.tween(logo, {alpha: 1}, 1, {type:FlxTween.ONESHOT, ease:FlxEase.sineOut});
						FlxTween.tween(txtBegin, {alpha: 1}, 1, {type:FlxTween.ONESHOT, ease:FlxEase.sineOut, startDelay:1});
						FlxTween.tween(txtCredits, {alpha: 1}, 1, {type:FlxTween.ONESHOT, ease:FlxEase.sineOut, startDelay:1.1});
						FlxTween.tween(txtExit, {alpha: 1}, 1, {type:FlxTween.ONESHOT, ease:FlxEase.sineOut, startDelay:1.2});
						FlxTween.tween(cursor, {alpha: 1}, 1, {type:FlxTween.ONESHOT, ease:FlxEase.sineOut, startDelay:1.3, onComplete:function(_) {finishCursorIn = true; } });
					}
					if (finishCursorIn)
					{
						if (FlxG.gamepads.anyJustReleased(FlxGamepadInputID.LEFT_STICK_DIGITAL_DOWN) || FlxG.keys.anyJustReleased([S, DOWN]) )
						{
							if (selected == 0)
							{
								selected = 1;
								cursor.y = txtCredits.y + (txtCredits.height / 2) - (cursor.height / 2);
							}
							else if (selected == 1)
							{
								selected = 2;
								cursor.y = txtExit.y + (txtExit.height / 2) - (cursor.height / 2);
							}
							else
							{
								selected = 0;
								cursor.y = txtBegin.y + (txtBegin.height / 2) - (cursor.height / 2);
							}
							
							
						}
						else if ( FlxG.keys.anyJustReleased([W, UP]) || FlxG.gamepads.anyJustReleased(FlxGamepadInputID.LEFT_STICK_DIGITAL_UP))
						{
							if (selected == 0)
							{
								selected = 2;
								cursor.y = txtExit.y + (txtExit.height / 2) - (cursor.height / 2);
							}
							else if (selected == 1)
							{
								selected = 0;
								cursor.y = txtBegin.y + (txtBegin.height / 2) - (cursor.height / 2);
							}
							else
							{
								selected = 1;
								cursor.y = txtCredits.y + (txtCredits.height / 2) - (cursor.height / 2);
							}
						}
						else if (FlxG.gamepads.anyJustReleased(FlxGamepadInputID.START) || FlxG.gamepads.anyJustReleased(FlxGamepadInputID.A) || FlxG.gamepads.anyJustReleased(FlxGamepadInputID.B) || FlxG.keys.anyJustReleased([X, SPACE, ENTER]))
						{
							if (selected ==0)
							{
								startGame();
							}
							else if (selected == 1)
							{
								openSubState(new Credits());
							}
							else if (selected == 2)
							{
								#if desktop
								System.exit(0);
								#end
							}
						}
					}
				}
			}
		}
		else if (gameOver)
		{
			if (readyForRetry)
			{
				if (FlxG.gamepads.anyJustReleased(FlxGamepadInputID.START) || FlxG.gamepads.anyJustReleased(FlxGamepadInputID.A) || FlxG.gamepads.anyJustReleased(FlxGamepadInputID.B) || FlxG.keys.anyJustReleased([X, SPACE, ENTER]))
				{
					FlxG.camera.fade(FlxColor.BLACK, .33, false, function() {
						FlxG.resetState();
					});
				}
			}
		}
		else
		{
			var count:Int = audienceGroup.countLiving();
			//trace(count, ratingValue * 1.5);
			if (count < (ratingValue-25) * 1.5)
			{
				addCat();
			}
			else if (count > ((ratingValue-25) * 1.5) + 5)
			{
				removeCat();
			}
			
			updateRating();
			updateStrobes(elapsed);
			
			if (PreLeftBeats.length == 0 && FlxG.sound.music.time * .001 < 5)
			{
				//trace(BaseLeftBeats);
				PreLeftBeats = [];
				for (i in BaseLeftBeats)
				{
					PreLeftBeats.push(i);
				}
			}
			if (PreRightBeats.length == 0 && FlxG.sound.music.time * .001 < 5)
			{
				PreRightBeats = [];
				for (i in BaseRightBeats)
				{
					PreRightBeats.push(i);
				}
			}
			if (LeftBeats.length == 0 && FlxG.sound.music.time * .001 < 5)
			{
				LeftBeats = [];
				for (i in BaseLeftBeats)
				{
					LeftBeats.push(i);
				}
			}
			if (RightBeats.length == 0 && FlxG.sound.music.time * .001 < 5)
			{
				RightBeats = [];
				for (i in BaseRightBeats)
				{
					RightBeats.push(i);
				}
			}
			
			colorTimer -= elapsed;
			if (colorTimer <= 0)
			{
				colorTimer = .1;
				if (ratingValue > 85)
					changeColor();
			}
			
			if ((FlxG.sound.music.time * .001) + 2 >= Std.parseFloat( PreLeftBeats[0]) )
			{
				// LEFT BEAT!
				spawnArrow(0);
				PreLeftBeats.shift();
			}
			if ((FlxG.sound.music.time * .001) + 2 >= Std.parseFloat( PreRightBeats[0]) )
			{
				// RIGHT BEAT!
				spawnArrow(1);
				PreRightBeats.shift();
			}
			if ((FlxG.sound.music.time * .001) >= Std.parseFloat( LeftBeats[0]) )
			{
				// LEFT BEAT!
				//FlxG.camera.flash(FlxColor.WHITE, .1);
				LeftBeats.shift();
				audienceGroup.forEachAlive(bounceCat);
				
			}
			if ((FlxG.sound.music.time * .001) >= Std.parseFloat( RightBeats[0]) )
			{
				// RIGHT BEAT!
				//FlxG.camera.flash(FlxColor.WHITE, .1);
				RightBeats.shift();
				audienceGroup.forEachAlive(bounceCat);
				
			}
			
			if (starting)
			{
				if (airSpeed.y < 8 *-15)
				{
					airSpeed.y -= .5 * elapsed;
				}
				else
				{
					airTimer = 0;
					starting = false;
				}
			}
			else
			{
				airTimer -= elapsed;
				if (airTimer <= 0)
				{
					airTimer = FlxG.random.int(1, 5) * .1;
				
					airSpeed.y = FlxG.random.int(4, 12) * -15;
				}
				airSpeed.x += FlxG.random.int(1, 5) * .05 * FlxG.random.sign();
				airSpeed.x = FlxMath.bound(airSpeed.x, -XAIR_MAX, XAIR_MAX);
			}
			
			torso[torso.length - 1].body.applyImpulse(airSpeed);
			
			
			
			if (FlxG.gamepads.anyPressed(FlxGamepadInputID.LEFT_STICK_DIGITAL_UP) || FlxG.keys.anyJustReleased([W]))
			{
				//rightHand.body.applyImpulse(Vec2.weak(0, -200));
				rightHand.body.velocity =  Vec2.weak(0, -MOVE_SPEED);
				if (leftButtons[1].animation.name != "good")
					leftButtons[1].animation.play("on", true);
			}
			else if (FlxG.gamepads.anyPressed(FlxGamepadInputID.LEFT_STICK_DIGITAL_DOWN) || FlxG.keys.anyJustReleased([S]))
			{
				//rightHand.body.applyImpulse(Vec2.weak(0, 200));
				rightHand.body.velocity =  Vec2.weak(0, MOVE_SPEED);
				if (leftButtons[2].animation.name != "good")
					leftButtons[2].animation.play("on", true);
			}
			else if (FlxG.gamepads.anyPressed(FlxGamepadInputID.LEFT_STICK_DIGITAL_LEFT) || FlxG.keys.anyJustReleased([A]))
			{
				//rightHand.body.applyImpulse(Vec2.weak(-200, 0));
				rightHand.body.velocity =  Vec2.weak( -MOVE_SPEED, 0);
				if (leftButtons[0].animation.name != "good")
					leftButtons[0].animation.play("on", true);
			}
			else if (FlxG.gamepads.anyPressed(FlxGamepadInputID.LEFT_STICK_DIGITAL_RIGHT) || FlxG.keys.anyJustReleased([D]))
			{
				//rightHand.body.applyImpulse(Vec2.weak(200, 0));
				rightHand.body.velocity =  Vec2.weak(MOVE_SPEED, 0);
				if (leftButtons[3].animation.name != "good")
					leftButtons[3].animation.play("on", true);
			}
			
			if (FlxG.gamepads.anyPressed(FlxGamepadInputID.RIGHT_STICK_DIGITAL_UP) || FlxG.keys.anyJustReleased([UP]))
			{
				//leftHand.body.applyImpulse(Vec2.weak(0, -200));
				leftHand.body.velocity =  Vec2.weak(0, -MOVE_SPEED);
				if (rightButtons[1].animation.name != "good")
					rightButtons[1].animation.play("on", true);
			}
			else if (FlxG.gamepads.anyPressed(FlxGamepadInputID.RIGHT_STICK_DIGITAL_DOWN) || FlxG.keys.anyJustReleased([DOWN]))
			{
				//leftHand.body.applyImpulse(Vec2.weak(0, 200));
				leftHand.body.velocity =  Vec2.weak(0, MOVE_SPEED);
				if (rightButtons[2].animation.name != "good")
					rightButtons[2].animation.play("on", true);
			}
			else if (FlxG.gamepads.anyPressed(FlxGamepadInputID.RIGHT_STICK_DIGITAL_LEFT) || FlxG.keys.anyJustReleased([LEFT]) )
			{
				//leftHand.body.applyImpulse(Vec2.weak( -200, 0));
				leftHand.body.velocity =  Vec2.weak( -MOVE_SPEED, 0);
				if (rightButtons[0].animation.name != "good")
					rightButtons[0].animation.play("on", true);
			}
			else if (FlxG.gamepads.anyPressed(FlxGamepadInputID.RIGHT_STICK_DIGITAL_RIGHT) || FlxG.keys.anyJustReleased([RIGHT]))
			{
				//leftHand.body.applyImpulse(Vec2.weak(200, 0));
				leftHand.body.velocity =  Vec2.weak(MOVE_SPEED, 0);
				if (rightButtons[3].animation.name != "good")
					rightButtons[3].animation.play("on", true);
			}
		}
		
		super.update(elapsed);
	}
	
	private function createTorso():Void
	{
		torsoCompound = new Compound();
		leftArmCompound = new Compound();
		rightArmCompound = new Compound();
		
		torsoCompound.space = FlxNapeSpace.space;
		leftArmCompound.space = FlxNapeSpace.space;
		rightArmCompound.space = FlxNapeSpace.space;
		
		torsoType = new CbType();
		wallType = new CbType();
		handType = new CbType();
		
		torso = new Array<TorsoSegment>();
		for (i in 0...NUM_TORSO)
		{
			var t:TorsoSegment = new TorsoSegment(i == NUM_TORSO, i == NUM_TORSO-1);
			t.body.cbTypes.push(torsoType);
			t.body.allowRotation = false;
			torso.push(t);
			add(t);
			t.body.position.x =  FlxG.width / 2;
			t.body.position.y = FlxG.height * .8 - 48;
			t.body.compound = torsoCompound;
		}
		
		
		
		for (i in 0...NUM_TORSO - 1)
		{
			var b1:Body = torso[i].body;
			var b2:Body = torso[i+1].body;
			var c:Constraint = new DistanceJoint(b1, b2, Vec2.weak(0, 0), Vec2.weak(0, 0), 0, 46);
			//c.damping = damping;
			c.stiff = false;
			c.frequency = frequency;
			c.space = FlxNapeSpace.space;
			
			
		}
		
		leftArm = new Array<HandSegment>();
		rightArm = new Array<HandSegment>();
		for (i in 0...NUM_ARM)
		{
			var a:HandSegment = new HandSegment();
			a.body.cbTypes.push(handType);
			a.body.allowRotation = false;
			leftArm.push(a);
			add(a);
			a.body.position.x = FlxG.width / 2;// (FlxG.width / 2) - (24 * i);
			a.body.position.y = FlxG.height * .8 - 40;
			a.body.compound = leftArmCompound;
			
			var b:HandSegment = new HandSegment();
			b.body.cbTypes.push(handType);
			b.body.allowRotation = false;
			rightArm.push(b);
			add(b);
			b.body.position.x = FlxG.width / 2;// (FlxG.width / 2) + (24 * i);
			b.body.position.y = FlxG.height * .8 - 40;
			b.body.compound = rightArmCompound;
		}
		
		
		
		
		
		for (i in 0...NUM_ARM - 1)
		{
			var a1:Body = leftArm[i].body;
			var a2:Body = leftArm[i + 1].body;
			var c:Constraint = new DistanceJoint(a1, a2, Vec2.weak(0, 0), Vec2.weak(0, 0), 0, 16);
			//c.damping = damping;
			c.stiff = false;
			c.frequency = frequency;
			c.space = FlxNapeSpace.space;
			
			a1 = rightArm[i].body;
			a2 = rightArm[i + 1].body;
			c = new DistanceJoint(a1, a2, Vec2.weak(0, 0), Vec2.weak(0, 0), 0, 16);
			//c.damping = damping;
			c.stiff = false;
			c.frequency = frequency;
			c.space = FlxNapeSpace.space;
			
		}
		
		midPoint = torso[7];
		leftHand = leftArm[NUM_ARM - 1];
		rightHand = rightArm[NUM_ARM - 1];
		
		
		var c:Constraint = new DistanceJoint(leftArm[0].body,midPoint.body,  Vec2.weak(-48, 0), Vec2.weak(0, 0), 0, 2);
		//c.damping = damping;
		c.stiff = false;
		c.frequency = frequency;
		c.space = FlxNapeSpace.space;
		c = new DistanceJoint(rightArm[0].body, midPoint.body, Vec2.weak( 48,0), Vec2.weak(0, 0), 0, 2);
		//c.damping = damping;
		c.stiff = false;
		c.frequency = frequency;
		c.space = FlxNapeSpace.space;
		
		c = new DistanceJoint(leftHand.body, midPoint.body, Vec2.weak( -288, 0), Vec2.weak(0, 0), 0, 128);
		//c.damping = damping;
		c.stiff = false;
		c.frequency = frequency;
		c.space = FlxNapeSpace.space;
		
		c = new DistanceJoint(rightHand.body, midPoint.body, Vec2.weak( 288, 0), Vec2.weak(0, 0), 0, 128);
		//c.damping = damping;
		c.stiff = false;
		c.frequency = frequency;
		c.space = FlxNapeSpace.space;
		
		
		
		
		
		
		
		bound_left = new FlxNapeSprite((FlxG.width / 2) - 154, FlxG.height/2, null, false,false);
		bound_left.createRectangularBody(10, FlxG.height, BodyType.STATIC);
		bound_left.body.space = FlxNapeSpace.space;
		bound_left.visible = false;
		bound_left.body.cbTypes.push(wallType);
		add(bound_left);
		bound_right = new FlxNapeSprite((FlxG.width / 2) + 144, FlxG.height/2, null, false,false);
		bound_right.createRectangularBody(10, FlxG.height, BodyType.STATIC);
		bound_right.body.space = FlxNapeSpace.space;
		bound_right.visible = false;
		bound_right.body.cbTypes.push(wallType);
		add(bound_right);
		
		
		torso[0].body.allowMovement = false;
		//torso[0].body
		
		var listener = new PreListener(InteractionType.COLLISION, torsoType, torsoType, ignoreCollision, 0, true);
		listener.space = FlxNapeSpace.space;
		
		listener = new PreListener(InteractionType.COLLISION, handType, wallType, ignoreCollision, 0, true);
		listener.space = FlxNapeSpace.space;
		
		listener = new PreListener(InteractionType.COLLISION, handType, torsoType, ignoreCollision, 0, true);
		listener.space = FlxNapeSpace.space;
		
		listener = new PreListener(InteractionType.COLLISION, handType, handType, ignoreCollision, 0, true);
		listener.space = FlxNapeSpace.space;
		
		
		face = new FlxNapeSprite();
		face.frames = GraphicsCache.loadGraphicFromAtlas("faces", AssetPaths.faces__png, AssetPaths.faces__xml).atlasFrames;
		face.animation.randomFrame();
		face.createRectangularBody(96, 96, BodyType.KINEMATIC);
		face.body.cbTypes.push(torsoType);
		face.body.allowRotation = false;
		face.body.position.x = torso[NUM_TORSO - 1].body.position.x;
		face.body.position.y = torso[NUM_TORSO - 1].body.position.y;
		add(face);
		
		
		
	}
	
	function ignoreCollision(cb:PreCallback):PreFlag
	{
		return PreFlag.IGNORE;
	}
	
	
}