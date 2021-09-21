package;
import flixel.FlxG;

/**
 * A collection of utility functions for MonsterMind
 */
class MmTools
{
	/**
	 * Returns the system time in milliseconds.
	 */
	public static inline function time():Float
	{
		#if flash
			return Date.now.getTime();
		#else
			return Sys.time() * 1000.0;
		#end
	}
}