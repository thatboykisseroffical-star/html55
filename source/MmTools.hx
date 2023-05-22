package;
import haxe.Timer;

/**
 * A collection of utility functions for MonsterMind
 */
class MmTools
{
	#if html5
	public static var just_sayin_font:String = AssetPaths.just_sayin__woff;
	#else
	public static var just_sayin_font:String = AssetPaths.just_sayin__ttf;
	#end

	/**
	 * Returns the system time in milliseconds.
	 *
	 * This is intended as a cross-platform replacement for ActionScript's Date.getTime() method.
	 */
	public static inline function time():Float
	{
		return Timer.stamp() * 1000;
	}
}