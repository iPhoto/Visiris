// This Shader takes two textures and blend them together.

#version 120

uniform float layermode;
uniform sampler2D textures[2];

varying vec2 texcoord;

vec3 RGBToHSL(vec3 color)
{
	vec3 hsl; // init to 0 to avoid warnings ? (and reverse if + remove first part)
	
	float fmin = min(min(color.r, color.g), color.b);    //Min. value of RGB
	float fmax = max(max(color.r, color.g), color.b);    //Max. value of RGB
	float delta = fmax - fmin;             //Delta RGB value
    
	hsl.z = (fmax + fmin) / 2.0; // Luminance
    
	if (delta == 0.0)		//This is a gray, no chroma...
	{
		hsl.x = 0.0;	// Hue
		hsl.y = 0.0;	// Saturation
	}
	else                                    //Chromatic data...
	{
		if (hsl.z < 0.5)
			hsl.y = delta / (fmax + fmin); // Saturation
		else
			hsl.y = delta / (2.0 - fmax - fmin); // Saturation
		
		float deltaR = (((fmax - color.r) / 6.0) + (delta / 2.0)) / delta;
		float deltaG = (((fmax - color.g) / 6.0) + (delta / 2.0)) / delta;
		float deltaB = (((fmax - color.b) / 6.0) + (delta / 2.0)) / delta;
        
		if (color.r == fmax )
			hsl.x = deltaB - deltaG; // Hue
		else if (color.g == fmax)
			hsl.x = (1.0 / 3.0) + deltaR - deltaB; // Hue
		else if (color.b == fmax)
			hsl.x = (2.0 / 3.0) + deltaG - deltaR; // Hue
        
		if (hsl.x < 0.0)
			hsl.x += 1.0; // Hue
		else if (hsl.x > 1.0)
			hsl.x -= 1.0; // Hue
	}
    
	return hsl;
}

float HueToRGB(float f1, float f2, float hue)
{
	if (hue < 0.0)
		hue += 1.0;
	else if (hue > 1.0)
		hue -= 1.0;
	float res;
	if ((6.0 * hue) < 1.0)
		res = f1 + (f2 - f1) * 6.0 * hue;
	else if ((2.0 * hue) < 1.0)
		res = f2;
	else if ((3.0 * hue) < 2.0)
		res = f1 + (f2 - f1) * ((2.0 / 3.0) - hue) * 6.0;
	else
		res = f1;
	return res;
}

vec3 HSLToRGB(vec3 hsl)
{
	vec3 rgb;
	
	if (hsl.y == 0.0)
		rgb = vec3(hsl.z); // Luminance
	else
	{
		float f2;
		
		if (hsl.z < 0.5)
			f2 = hsl.z * (1.0 + hsl.y);
		else
			f2 = (hsl.z + hsl.y) - (hsl.y * hsl.z);
        
		float f1 = 2.0 * hsl.z - f2;
		
		rgb.r = HueToRGB(f1, f2, hsl.x + (1.0/3.0));
		rgb.g = HueToRGB(f1, f2, hsl.x);
		rgb.b= HueToRGB(f1, f2, hsl.x - (1.0/3.0));
	}
	
	return rgb;
}

vec3 ContrastSaturationBrightness(vec3 color, float brt, float sat, float con)
{
	// Increase or decrease theese values to adjust r, g and b color channels seperately
	const float AvgLumR = 0.5;
	const float AvgLumG = 0.5;
	const float AvgLumB = 0.5;
	
	const vec3 LumCoeff = vec3(0.2125, 0.7154, 0.0721);
	
	vec3 AvgLumin = vec3(AvgLumR, AvgLumG, AvgLumB);
	vec3 brtColor = color * brt;
	vec3 intensity = vec3(dot(brtColor, LumCoeff));
	vec3 satColor = mix(intensity, brtColor, sat);
	vec3 conColor = mix(AvgLumin, satColor, con);
	return conColor;
}


//This are helper defines
#define Blend(base, blend, funcf) 		vec4(funcf(base.r, blend.r), funcf(base.g, blend.g), funcf(base.b, blend.b), funcf(base.a, blend.a))

#define BlendLinearDodgef               BlendAddf
#define BlendLinearBurnf                BlendSubstractf
#define BlendAddf(base, blend)          min(base + blend, 1.0)
#define BlendSubstractf(base, blend) 	max(base + blend - 1.0, 0.0)
#define BlendLightenf(base, blend) 		max(blend, base) 
#define BlendDarkenf(base, blend) 		min(blend, base)
#define BlendLinearLightf(base, blend) 	(blend < 0.5 ? BlendLinearBurnf(base, (2.0 * blend)) : BlendLinearDodgef(base, (2.0 * (blend - 0.5))))
#define BlendScreenf(base, blend) 		(1.0 - ((1.0 - base) * (1.0 - blend)))
#define BlendOverlayf(base, blend)      (base < 0.5 ? (2.0 * base * blend) : (1.0 - 2.0 * (1.0 - base) * (1.0 - blend)))
#define BlendSoftLightf(base, blend) 	((blend < 0.5) ? (2.0 * base * blend + base * base * (1.0 - 2.0 * blend)) : (sqrt(base) * (2.0 * blend - 1.0) + 2.0 * base * (1.0 - blend)))
#define BlendColorDodgef(base, blend) 	((blend == 1.0) ? blend : min(base / (1.0 - blend), 1.0))
#define BlendColorBurnf(base, blend) 	((blend == 0.0) ? blend : max((1.0 - ((1.0 - base) / blend)), 0.0))
#define BlendVividLightf(base, blend) 	((blend < 0.5) ? BlendColorBurnf(base, (2.0 * blend)) : BlendColorDodgef(base, (2.0 * (blend - 0.5))))
#define BlendPinLightf(base, blend) 	((blend < 0.5) ? BlendDarkenf(base, (2.0 * blend)) : BlendLightenf(base, (2.0 *(blend - 0.5))))
#define BlendHardMixf(base, blend)      ((BlendVividLightf(base, blend) < 0.5) ? 0.0 : 1.0)
#define BlendReflectf(base, blend) 		((blend == 1.0) ? blend : min(base * base / (1.0 - blend), 1.0))


//Blendmodes
#define BlendNormal(base, blend)        (blend  + base*(1.0 - blend.a))
#define BlendLighten                    BlendLightenf
#define BlendDarken(base, blend)        (BlendDarkenf(base, blend) + base*(1.0 - blend.a))
#define BlendMultiply(base, blend) 		(base * blend + base*(1.0 - blend.a))
#define BlendAverage(base, blend) 		((base + blend) / 2.0)
#define BlendAdd(base, blend)           min(base + blend, vec4(1.0))
#define BlendSubstract(base, blend) 	(max(base + blend - vec4(1.0), vec4(0.0)) + base*(1.0 - blend.a))
#define BlendDifference(base, blend) 	abs(base - blend)
#define BlendNegation(base, blend)      (vec4(1.0) - abs(vec4(1.0) - base - blend))
#define BlendExclusion(base, blend) 	(base + blend - 2.0 * base * blend)
#define BlendScreen(base, blend) 		Blend(base, blend, BlendScreenf)
#define BlendOverlay(base, blend) 		(Blend(base, blend, BlendOverlayf))
#define BlendSoftLight(base, blend) 	Blend(base, blend, BlendSoftLightf)
#define BlendHardLight(base, blend) 	(BlendOverlay(blend, base) + base*(1.0 - blend.a))
#define BlendColorDodge(base, blend) 	(Blend(base, blend, BlendColorDodgef))
#define BlendColorBurn(base, blend)     (Blend(base, blend, BlendColorBurnf) + base*(1.0 - blend.a))
#define BlendLinearDodge                BlendAdd
#define BlendLinearBurn                 BlendSubstract
// Linear Light is another contrast-increasing mode
// If the blend color is darker than midgray, Linear Light darkens the image by decreasing the brightness. If the blend color is lighter than midgray, the result is a brighter image due to increased brightness.
#define BlendLinearLight(base, blend) 	(Blend(base, blend, BlendLinearLightf) + base*(1.0 - blend.a))
#define BlendVividLight(base, blend) 	(Blend(base, blend, BlendVividLightf) + base*(1.0 - blend.a))
#define BlendPinLight(base, blend) 		(Blend(base, blend, BlendPinLightf) + base*(1.0 - blend.a))
#define BlendHardMix(base, blend) 		(Blend(base, blend, BlendHardMixf) + base*(1.0 - blend.a))
#define BlendReflect(base, blend) 		Blend(base, blend, BlendReflectf)
#define BlendGlow(base, blend)          (BlendReflect(blend, base) + base*(1.0 - blend.a))
#define BlendPhoenix(base, blend) 		(min(base, blend) - max(base, blend) + vec4(1.0))
#define BlendLuminosity(base, blend)    (BlendLuminosityf(base, blend) + base*(1.0 - blend.a))


vec4 BlendHue(vec4 base, vec4 blend)
{
	vec3 baseHSL = RGBToHSL(base.rgb);
	vec3 temp = HSLToRGB(vec3(RGBToHSL(blend.rgb).r, baseHSL.g, baseHSL.b));
    return vec4(temp.r,temp.g,temp.b,(base.a+blend.a)/2.0);
}

// Saturation Blend mode creates the result color by combining the luminance and hue of the base color with the saturation of the blend color.
vec4 BlendSaturation(vec4 base, vec4 blend)
{
	vec3 baseHSL = RGBToHSL(base.rgb);
	vec3 temp = HSLToRGB(vec3(baseHSL.r, RGBToHSL(blend.rgb).g, baseHSL.b));
    return vec4(temp.r,temp.g,temp.b,(base.a+blend.a)/2.0);
}

// Color Mode keeps the brightness of the base color and applies both the hue and saturation of the blend color.
vec4 BlendColor(vec4 base, vec4 blend)
{
	vec3 blendHSL = RGBToHSL(blend.rgb);
	vec3 temp = HSLToRGB(vec3(blendHSL.r, blendHSL.g, RGBToHSL(base.rgb).b));
    return vec4(temp.r,temp.g,temp.b,(base.a+blend.a)/2.0);
}

// Luminosity Blend mode creates the result color by combining the hue and saturation of the base color with the luminance of the blend color.
vec4 BlendLuminosityf(vec4 base, vec4 blend)
{
	vec3 baseHSL = RGBToHSL(base.rgb);
	vec3 temp = HSLToRGB(vec3(baseHSL.r, baseHSL.g, RGBToHSL(blend.rgb).b));
    return vec4(temp.r,temp.g,temp.b,(base.a+blend.a)/2.0);
}

void main()
{
    vec4 base = texture2D(textures[0], texcoord);
    vec4 blend = texture2D(textures[1], texcoord);
    
    blend *= vec4(blend.a);
    
    if (layermode == 1.0) {
        gl_FragColor = BlendNormal(base, blend);
    }
    else
    {
        if (layermode < 16.0)
        {
            if (layermode < 9.0)
            {
                if (layermode < 6.0)
                {
                    if (layermode < 4.0)
                    {
                        if (layermode < 3.0)  gl_FragColor = BlendLighten(base, blend);
                        else                gl_FragColor = BlendDarken(base, blend);
                    }
                    else
                    {
                        if (layermode < 5.0)  gl_FragColor = BlendMultiply(base, blend);
                        else                gl_FragColor = BlendAverage(base, blend);
                    }
                }
                else
                    if (layermode < 8.0)
                    {
                        if (layermode < 7.0)  gl_FragColor = BlendAdd(base, blend);
                        else                gl_FragColor = BlendSubstract(base, blend);
                    }
                    else                    gl_FragColor = BlendDifference(base, blend);
            }
            else
            {
                if (layermode < 13.0)
                {
                    if (layermode < 11.0)
                    {
                        if (layermode < 10.0)     gl_FragColor = BlendNegation(base, blend);
                        else                    gl_FragColor = BlendExclusion(base, blend);
                    }
                    else
                    {
                        if (layermode < 12.0)     gl_FragColor = BlendScreen(base, blend);
                        else                    gl_FragColor = BlendOverlay(base, blend);
                    }
                }
                else
                    if (layermode < 15.0)
                    {
                        if (layermode < 14.0)     gl_FragColor = BlendSoftLight(base, blend);
                        else                    gl_FragColor = BlendHardLight(base, blend);
                    }
                    else                        gl_FragColor = BlendColorDodge(base, blend);
            }
        }
        else
        {
            if (layermode < 24.0)
            {
                if (layermode < 20.0)
                {
                    if (layermode < 18.0)
                    {
                        if (layermode < 17.0)     gl_FragColor = BlendColorBurn(base, blend);
                        else                    gl_FragColor = BlendLinearDodge(base, blend);
                    }
                    else
                    {
                        if (layermode < 19.0)     gl_FragColor = BlendLinearBurn(base, blend);
                        else                    gl_FragColor = BlendLinearLight(base, blend);
                    }
                }
                else
                {
                    if (layermode < 22.0)
                    {
                        if (layermode < 21.0)     gl_FragColor = BlendVividLight(base, blend);
                        else                    gl_FragColor = BlendPinLight(base, blend);
                    }
                    else
                    {
                        if (layermode < 23.0)     gl_FragColor = BlendHardMix(base, blend);
                        else                    gl_FragColor = BlendReflect(base, blend);
                    }
                }
            }
            else
            {
                if (layermode < 28.0)
                {
                    if (layermode < 26.0)
                    {
                        if (layermode < 25.0)   gl_FragColor = BlendGlow(base, blend);
                        else                    gl_FragColor = BlendPhoenix(base, blend);
                    }
                    else                        gl_FragColor = BlendHue(base, blend);
                }
                else
                    if (layermode < 30.0)
                    {
                        if (layermode < 29.0)   gl_FragColor = BlendSaturation(base, blend);
                        else                    gl_FragColor = BlendColor(base, blend);
                    }
                    else                        gl_FragColor = BlendLuminosity(base, blend);
            }
        }
    }
}
