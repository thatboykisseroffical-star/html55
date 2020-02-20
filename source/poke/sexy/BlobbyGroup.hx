package poke.sexy;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.filters.BlurFilter;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;

/**
 * Combines a blur and threshold filter to create a blobby effect. Used for
 * rendering sexual fluids and sweat
 */
class BlobbyGroup extends FlxGroup
{
	private var _zeroPoint:Point;

	public var _blobColour:Int;
	public var _blobThreshold:Int;
	public var _shineColour:Int = 0xFFFFFF;
	public var _shineThreshold:Int;

	private var _blur:BlurFilter;

	// the buffer which gets drawn to and blurred
	private var _blurBuffer:BitmapData;
	public var _targetBuffer:BitmapData;
	private var _highlightBuffer:BitmapData;

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
		_blur = new BlurFilter(6, 6, 3);
		_highlightMatrix = new Matrix();
		_highlightMatrix.translate(2, 4);
		_blurBuffer = new BitmapData(FlxG.camera.width, FlxG.camera.height, true, 0x00);
		_targetBuffer = new BitmapData(FlxG.camera.width, FlxG.camera.height, true, 0x00);
		_highlightBuffer = new BitmapData(FlxG.camera.width, FlxG.camera.height, true, 0x00);
	}

	public function setBlurAmount(BlurAmount:Int)
	{
		_blur.blurX = BlurAmount;
		_blur.blurY = BlurAmount;
	}

	private function _clearCameraBuffer():Void
	{
		FlxG.camera.fill(FlxColor.TRANSPARENT, false);
	}

	private function _swapCameraBuffer():Void
	{
		var tmpBuffer:BitmapData = FlxG.camera.buffer;
		FlxG.camera.buffer = _blurBuffer;
		_blurBuffer = tmpBuffer;
	}

	private function _postProcess():Void
	{
		_blurBuffer.applyFilter(_blurBuffer, _blurBuffer.rect, _zeroPoint, _blur);
		_targetBuffer.fillRect(_targetBuffer.rect, FlxColor.TRANSPARENT);
		_highlightBuffer.fillRect(_highlightBuffer.rect, FlxColor.TRANSPARENT);

		_targetBuffer.threshold(_blurBuffer, _blurBuffer.rect, _zeroPoint, '>', _blobThreshold << 16, _blobOpacity << 24 | _blobColour, 0x00FF0000, false);

		_highlightBuffer.copyPixels(_blurBuffer, _highlightBuffer.rect, _zeroPoint);
		_highlightBuffer.draw(_blurBuffer, _highlightMatrix, null, BlendMode.SUBTRACT);
		_targetBuffer.threshold(_highlightBuffer, _blurBuffer.rect, _zeroPoint, '>', _shineThreshold << 16, _shineOpacity << 24 | _shineColour, 0x00FF0000, false);

		FlxG.camera.buffer.copyPixels(_targetBuffer, _clipRect, _clipRect.topLeft, null, null, true);
	}

	override public function draw():Void
	{
		// TODO: Need to handle non-flash targets, possibly by using PixelFilterUtils
		#if flash
		// Swap the camera to a different screen buffer
		_swapCameraBuffer();

		// then empty the camera buffer
		_clearCameraBuffer();
		#end

		// then render using the parent code
		super.draw();

		#if flash
		// then restore the camera buffer
		_swapCameraBuffer();

		// and draw the new one over the top
		_postProcess();
		#end
	}

	public function getBlurAmount()
	{
		return _blur.blurX;
	}

	override public function destroy():Void
	{
		super.destroy();

		_zeroPoint = null;
		_blur = null;
		_blurBuffer = FlxDestroyUtil.dispose(_blurBuffer);
		_targetBuffer = FlxDestroyUtil.dispose(_targetBuffer);
		_highlightBuffer = FlxDestroyUtil.dispose(_highlightBuffer);
		_clipRect = null;
		_highlightMatrix = null;
	}
}