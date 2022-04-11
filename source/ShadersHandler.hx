package;

import openfl.Lib;
import openfl.display.Shader;
import openfl.filters.ShaderFilter;
import openfl8.*;

// OPENFL 3 ME CHUPA EL PICO AJAJAJAU
class ShadersHandler
{
	public static var chromaticAberration:ShaderFilter = new ShaderFilter(new ChromaticAberration());

	public static function setChrome(chromeOffset:Float):Void
	{
		chromaticAberration.shader.data.rOffset.value = [chromeOffset];
		chromaticAberration.shader.data.gOffset.value = [0.0];
		chromaticAberration.shader.data.bOffset.value = [chromeOffset * -1];
	}

	// NO SE COMO CAMBIAR EL VEC4 ASI QUESOLO VECTORES DE VEC2 JIJIJI VIVA EL 2D
}
