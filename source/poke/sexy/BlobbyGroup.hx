package poke.sexy;

import openfl.geom.ColorTransform;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSpriteUtil;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;

/**
 * Uses a threshold filter to create a blobby effect. Used for rendering
 * sexual fluids and sweat
 */
class BlobbyGroup extends FlxGroup
{
	private var _zeroPoint:Point;

	public var _blobColour:Int;
	public var _blobThreshold:Int;
	public var _shineColour:Int = 0xFFFFFF;
	public var _shineThreshold:Int;

	// the buffer which gets initially rendered to to
	private var _sourceBuffer:FlxSprite;
	private var _targetBuffer:FlxSprite;
	private var _highlightBuffer:FlxSprite;


	public var _blobOpacity:Int;
	private var _clipRect:Rectangle;
	private var _highlightMatrix:Matrix;
	public var _shineOpacity:Int = 0xFF;

	public function new(MaxSize:Int=0, BlobColour:Int = 0xFFFFFF, BlobThreshold:Int = 0x20, BlobOpacity:Int = 0xFF)
	{
		super(MaxSize);

		_blobColour = BlobColour;
		_blobThreshold = BlobThreshold;
		_shineThreshold = BlobThreshold;
		_blobOpacity = BlobOpacity;

		_clipRect = new Rectangle(256 + 5, 0 + 5, 248 - 4, 424 - 2);
		_zeroPoint = new Point(0, 0);
		_highlightMatrix = new Matrix();
		_highlightMatrix.translate(2, 4);

		_sourceBuffer = new FlxSprite(0, 0, new BitmapData(FlxG.camera.width, FlxG.camera.height, true, 0x00));
		_targetBuffer = new FlxSprite(0, 0, new BitmapData(FlxG.camera.width, FlxG.camera.height, true, 0x00));
		_highlightBuffer = new FlxSprite(0, 0, new BitmapData(FlxG.camera.width, FlxG.camera.height, true, 0x00));
	}

	private function _clearCameraBuffer():Void
	{
		FlxG.camera.fill(FlxColor.TRANSPARENT, false);
	}

	private function _clearSourceBuffer():Void
	{
		_sourceBuffer.graphic.bitmap.fillRect(_sourceBuffer.graphic.bitmap.rect, FlxColor.TRANSPARENT);
	}

	private function _swapCameraBuffer():Void
	{
		var tmpBuffer:BitmapData = FlxG.camera.buffer;
		FlxG.camera.buffer = _sourceBuffer.graphic.bitmap;
		_sourceBuffer.graphic.bitmap = tmpBuffer;
	}

	private function _postProcess():Void
	{
		_targetBuffer.graphic.bitmap.fillRect(_targetBuffer.graphic.bitmap.rect, FlxColor.TRANSPARENT);
		
		_targetBuffer.graphic.bitmap.threshold(_sourceBuffer.graphic.bitmap, _sourceBuffer.graphic.bitmap.rect, _zeroPoint, '>', _blobThreshold << 24, _blobOpacity << 24 | _blobColour, 0xFF000000, false);

		#if (hl || windows)
		// HashLink's threshold() function is broken, and draws translucent bright colors as black. We manually
		// recolor them using a ColorTransform.
		var redOffset:Int = (_blobColour & 0x00FF0000) >> 16;
		var greenOffset:Int = (_blobColour & 0x0000FF00) >> 8;
		var blueOffset:Int = (_blobColour & 0x000000FF) >> 0;
		var hashlinkColorTransform: ColorTransform = new ColorTransform(0, 0, 0, 1, redOffset, greenOffset, blueOffset);
		
		_targetBuffer.graphic.bitmap.colorTransform(_targetBuffer.graphic.bitmap.rect, hashlinkColorTransform);
		#end

		#if flash
		// Flash premultiplies the alpha, and supports the 'subtract'
		// BlendMode. We render highlights by rendering the blob shapes, and
		// erasing the unhighlighted sections with the 'Subtract' blend mode.
		
		_highlightBuffer.graphic.bitmap.copyPixels(_sourceBuffer.graphic.bitmap, _highlightBuffer.graphic.bitmap.rect, _zeroPoint);
		_highlightBuffer.graphic.bitmap.draw(_sourceBuffer.graphic.bitmap, _highlightMatrix, null, BlendMode.SUBTRACT);
		_targetBuffer.graphic.bitmap.threshold(_highlightBuffer.graphic.bitmap, _sourceBuffer.graphic.bitmap.rect, _zeroPoint, '>', _shineThreshold << 16, _shineOpacity << 24 | _shineColour, 0x00FF0000, false);
		#else
		// Non-flash do not premultiply the alpha, and do not support the
		// 'subtract' BlendMode. We render highlights by rendering the blob
		// shapes against a black background, drawing over the unhighlighted
		// sections with black.
		
		_highlightBuffer.graphic.bitmap.fillRect(_highlightBuffer.graphic.bitmap.rect, FlxColor.BLACK);
		_highlightBuffer.graphic.bitmap.draw(_sourceBuffer.graphic.bitmap, null, new ColorTransform(1, 1, 1, 0.75));
		_highlightBuffer.graphic.bitmap.draw(_sourceBuffer.graphic.bitmap, _highlightMatrix, new ColorTransform(0, 0, 0, 2));
		_targetBuffer.graphic.bitmap.threshold(_highlightBuffer.graphic.bitmap, _sourceBuffer.graphic.bitmap.rect, _zeroPoint, '>', _shineThreshold << 16, _shineOpacity << 24 | _shineColour, 0x00FF0000, false);
		#end
	}

	override public function draw():Void
	{
		#if flash
		// Swap the camera to a different screen buffer
		_swapCameraBuffer();

		// then empty the camera buffer
		_clearCameraBuffer();

		// then render using the parent code
		super.draw();

		// then restore the camera buffer
		_swapCameraBuffer();
		#else
		_clearSourceBuffer();
		
		// render using the parent code
		PixelFilterUtils.drawToBuffer(_sourceBuffer, this);
		#end
		
		_postProcess();

		// draw _targetBuffer to camera
		#if flash
		FlxG.camera.buffer.copyPixels(_targetBuffer.graphic.bitmap, _clipRect, _clipRect.topLeft, null, null, true);
		#else
		_targetBuffer.draw();
		#end
	}

	override public function destroy():Void
	{
		super.destroy();

		_zeroPoint = null;
		_sourceBuffer = FlxDestroyUtil.destroy(_sourceBuffer);
		_targetBuffer = FlxDestroyUtil.destroy(_targetBuffer);
		_highlightBuffer = FlxDestroyUtil.destroy(_highlightBuffer);
		_clipRect = null;
		_highlightMatrix = null;
	}
}