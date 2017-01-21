package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.nape.FlxNapeSpace;
import flixel.math.FlxPoint;
import nape.callbacks.CbType;
import nape.callbacks.InteractionType;
import nape.callbacks.PreCallback;
import nape.callbacks.PreFlag;
import nape.callbacks.PreListener;
import nape.constraint.Constraint;
import nape.constraint.DistanceJoint;
import nape.geom.Vec2;
import nape.phys.Body;

class MainState extends FlxState 
{

	private var frequency:Float = 60.0;
    private var damping:Float = 1.0;
	private inline static var NUM_TORSO:Int = 10;
	
	private var torso:Array<TorsoSegment>;
	private var anchor:FlxPoint;
	private var torsoType:CbType;
	
	private var airTimer:Float = 0;
	private var airSpeed:Float = 0;
	
	
	override public function create():Void 
	{
		super.create();
		FlxNapeSpace.init();
		
		FlxNapeSpace.space.gravity.setxy(0, 500);
		
		
		anchor = FlxPoint.get(FlxG.width / 2, FlxG.height * .8);
		
		createTorso();
		
		
		
		
	}
	
	override public function update(elapsed:Float):Void 
	{
		
		airTimer -= elapsed;
		if (airTimer <= 0)
		{
			airTimer = FlxG.random.int(1, 5) * .1;
		
			airSpeed = FlxG.random.int(2, 6) * -15;
		}
		
		torso[torso.length - 1].body.applyImpulse(Vec2.weak((FlxG.random.int(0, 4) - 2.5) * 2, airSpeed)); 
		
		super.update(elapsed);
	}
	
	private function createTorso():Void
	{
		
		torsoType = new CbType();
		
		torso = new Array<TorsoSegment>();
		for (i in 0...NUM_TORSO)
		{
			var t:TorsoSegment = new TorsoSegment();
			t.body.cbTypes.push(torsoType);
			t.body.allowRotation = false;
			torso.push(t);
			add(t);
			t.body.position.x=  FlxG.width / 2 - 24;
			t.body.position.y = FlxG.height * .8 - 48;
		}
		
		
		
		for (i in 0...NUM_TORSO - 1)
		{
			var b1:Body = torso[i].body;
			var b2:Body = torso[i+1].body;
			var c:Constraint = new DistanceJoint(b1, b2, Vec2.weak(0, -90 / 2), Vec2.weak(0, -90 / 2), 24, 48);
			//c.damping = damping;
			c.stiff = false;
			c.frequency = frequency;
			c.space = FlxNapeSpace.space;
			
			
		}
		
		
		torso[0].body.allowMovement = false;
		
		var listener = new PreListener(InteractionType.COLLISION, torsoType, torsoType, ignoreCollision, 0, true);
		listener.space = FlxNapeSpace.space;
		
		
	}
	
	function ignoreCollision(cb:PreCallback):PreFlag
	{
		return PreFlag.IGNORE;
	}
	
	
}