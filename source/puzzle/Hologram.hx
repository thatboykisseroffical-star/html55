package puzzle;

import critter.Critter;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import openfl.display.BlendMode;
using flixel.util.FlxSpriteUtil;

/**
 * During the harder puzzles there are some holographic pads the player can use
 * as a solving tool.
 * 
 * The Hologram class controls the actual holograms which look like little
 * transparent versions of the bug.
 */
class Hologram extends FlxSprite
{
	public var _holopad:Holopad;
	var disruption0:Float;
	var disruption1:Float;
	var delay:Float = 0;
	public var _pegIndex:Int = 0;

	public function new(holopad:Holopad, pegIndex:Int, X:Float=0, Y:Float=0) 
	{
		super(X, Y);
		this._holopad = holopad;
		this._pegIndex = pegIndex;
		makeGraphic(64, 64, FlxColor.TRANSPARENT, true);
		setSize(36, 10);
		offset.set(14, 39);
		alpha = 0.70;
		disruption0 = disruption1 = FlxG.random.float(0, pixels.height * 1.5);
	}
	
	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		fill(FlxColor.TRANSPARENT);
		if (_holopad._critter != null) {
			stamp(_holopad._critter._bodySprite, 0, 0);
			stamp(_holopad._critter._headSprite, 0, 0);
		}
		delay -= elapsed;
		if (delay < 0) {
			delay += 1 / Critter._FRAME_RATE;
			disruption0 -= 0.2 * pixels.height / Critter._FRAME_RATE;
			if (disruption0 < 0) {
				disruption0 += FlxG.random.float(pixels.height, pixels.height * 1.5);
			}
			disruption1 = FlxG.random.float(disruption0 - 5, disruption0 + 5);
		}
		// Erase a little stripe of the hologram to make it look more hologrammy
		drawLine(0, disruption0, pixels.width, disruption1, { color:FlxColor.WHITE, thickness: 3 }, { blendMode: BlendMode.ERASE } );
	}
	
	override public function destroy():Void {
		super.destroy();
	}
}