package;

import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	private var isOldIcon:Bool = false;
	private var isPlayer:Bool = false;
	private var char:String = '';
	public var id:Int;

	public var defualtIconScale:Float = 1;
	public var iconScale:Float = 1;
	public var iconSize:Float;

	private var tween:FlxTween;

	public function new(char:String = 'bf', isPlayer:Bool = false, ?_id:Int = -1)
	{
		super();
		isOldIcon = (char == 'bf-old');
		this.isPlayer = isPlayer;
		changeIcon(char);
		scrollFactor.set();

		animation.play(char);
		scrollFactor.set();

		tween = FlxTween.tween(this, {}, 0);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}

	public function swapOldIcon() {
		if(isOldIcon = !isOldIcon) changeIcon('bf-old');
		else changeIcon('bf');
	}

	public function changeIcon(char:String) {
		if(this.char != char) {
			var name:String = 'icons/' + char;
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-' + char; //Older versions of psych engine's support
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-face'; //Prevents crash from missing icon
			var file:Dynamic = Paths.image(name);

			loadGraphic(file, true, 150, 150);
			animation.add(char, [0, 1, 2], 0, false, isPlayer);
			animation.play(char);
			this.char = char;

			antialiasing = ClientPrefs.globalAntialiasing;
			if(char.endsWith('-pixel') || char == 'bambi-3d' || char == 'dave-3d' || char == 'bambi-unfair' || char == 'bambi-god' || char == 'gary' || char == 'expunged' || char == 'bombu' || char == 'bamburg' || char == 'bamburg-player' || char == 'bambi-piss-3d') {
				antialiasing = false;
			}
		}
	}

	public function getCharacter():String {
		return char;
	}

	public function tweenToDefaultScale(_time:Float, _ease:Null<flixel.tweens.EaseFunction>){

		tween.cancel();
		tween = FlxTween.tween(this, {iconScale: this.defualtIconScale}, _time, {ease: _ease});

	}
}
