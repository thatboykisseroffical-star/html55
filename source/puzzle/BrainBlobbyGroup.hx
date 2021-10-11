package puzzle;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import openfl.display.BitmapData;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;

/**
 * Graphics for the blue blobs which glow and move around the brain when
 * synching
 */
class BrainBlobbyGroup extends FlxGroup
{
	private var _zeroPoint:Point;

	public var _blobColour:Int = 0x40A4C0;
	public var _blobThreshold:Int = 0x10;
	public var _shineColour:Int = 0x7FE4FF;
	public var _shineThreshold:Int = 0x40;

	// the buffer which gets drawn to
	private var _sourceBuffer:BitmapData;
	public var _targetBuffer:BitmapData;
	private var _highlightBuffer:BitmapData;

	public var _blobOpacity:Int = 0xFF;
	private var _clipRect:Rectangle;
	private var _maskMatrix:Matrix;
	public var _shineOpacity:Int = 0xFF;

	private var _maskGraphic:FlxGraphic;

	public function new(x:Float, y:Float, maskGraphic:FlxGraphic)
	{
		super(0);

		_clipRect = new Rectangle(x, y, maskGraphic.width, maskGraphic.height);
		_maskGraphic = maskGraphic;
		_zeroPoint = new Point(0, 0);
		_maskMatrix = new Matrix();
		_maskMatrix.translate(_clipRect.x, _clipRect.y);
		_sourceBuffer = new BitmapData(FlxG.camera.width, FlxG.camera.height, true, 0x00);
		_targetBuffer = new BitmapData(FlxG.camera.width, FlxG.camera.height, true, 0x00);
		_highlightBuffer = new BitmapData(FlxG.camera.width, FlxG.camera.height, true, 0x00);
	}

	private function _clearCameraBuffer():Void
	{
		FlxG.camera.buffer.fillRect(FlxG.camera.buffer.rect, FlxColor.TRANSPARENT);
	}

	private function _swapCameraBuffer():Void
	{
		var tmpBuffer:BitmapData = FlxG.camera.buffer;
		FlxG.camera.buffer = _sourceBuffer;
		_sourceBuffer = tmpBuffer;
	}

	private function _postProcess():Void
	{
		_targetBuffer.fillRect(_targetBuffer.rect, 0xFF2084A0);

		_targetBuffer.threshold(_sourceBuffer, _sourceBuffer.rect, _zeroPoint, '>', _blobThreshold << 16, _blobOpacity << 24 | _blobColour, 0x00FF0000, false);

		_targetBuffer.threshold(_sourceBuffer, _sourceBuffer.rect, _zeroPoint, '>', _shineThreshold << 16, _shineOpacity << 24 | _shineColour, 0x00FF0000, false);

		_targetBuffer.draw(_maskGraphic.bitmap, _maskMatrix);
		_targetBuffer.threshold(_targetBuffer, new Rectangle(0, 0, _targetBuffer.width, _targetBuffer.height), new Point(0, 0), "==", 0xffff00ff, 0x00000000);

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

	override public function destroy():Void
	{
		super.destroy();

		_zeroPoint = null;
		_sourceBuffer = FlxDestroyUtil.dispose(_sourceBuffer);
		_targetBuffer = FlxDestroyUtil.dispose(_targetBuffer);
		_highlightBuffer = FlxDestroyUtil.dispose(_highlightBuffer);
		_clipRect = null;
	}
}