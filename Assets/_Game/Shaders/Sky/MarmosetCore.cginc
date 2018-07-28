// Marmoset Skyshop
// Copyright 2013 Marmoset LLC
// http://marmoset.co

#ifndef MARMOSET_CORE_CGINC
#define MARMOSET_CORE_CGINC

#define INV_2PI 0.15915494309189533576888376337251
#define INV_2PIx2 0.31830988618379067153776752674502

//Linear - unity_ColorSpaceGrey.r is 0.19
//Gamma - unity_ColorSpaceGrey.r is 0.5			
//linear ? 1 : 0 = (Grey - 0.5) / (0.19 - 0.5) = one clever MAD instruction
#define IS_LINEAR ((-3.22581*unity_ColorSpaceGrey.r) + 1.6129)
#define IS_GAMMA  (( 3.22581*unity_ColorSpaceGrey.r) - 0.6129)

//x: IS_LINEAR, y: IS_GAMMA
#define IS_GAMMA_LINEAR (half2(3.22581,-3.22581)*unity_ColorSpaceGrey.rr + half2(-0.6129,1.6129))

#ifdef MARMO_SPECULAR_IBL
uniform samplerCUBE _SpecCubeIBL;
#endif

uniform half4 		_ExposureIBL;		//IBL intensities
uniform half2		_ExposureLM; 		//IBL intensities when lightmapping
uniform half2		_UniformOcclusion;	//Uniform diffuse and specular IBL occlusion terms

uniform float4x4	_SkyMatrix;
uniform float4x4	_InvSkyMatrix;
uniform float3		_SkySize;
uniform float3		_SkyMin;
uniform float3		_SkyMax;

uniform float3		_SH0;
uniform float3		_SH1;
uniform float3		_SH2;
uniform float3		_SH3;
uniform float3		_SH4;
uniform float3		_SH5;
uniform float3		_SH6;
uniform float3		_SH7;
uniform float3		_SH8;

#ifdef MARMO_SKY_BLEND
	uniform float		_BlendWeightIBL;
	
	uniform half4 		_ExposureIBL1;		//IBL intensities
	uniform half2		_ExposureLM1; 		//IBL intensities when lightmapping
	
	uniform float4x4	_SkyMatrix1;
	uniform float4x4	_InvSkyMatrix1;
	uniform float3		_SkySize1;
	uniform float3		_SkyMin1;
	uniform float3		_SkyMax1;

	#ifdef MARMO_SPECULAR_IBL
	uniform samplerCUBE _SpecCubeIBL1;
	#endif

	uniform float3		_SH01;
	uniform float3		_SH11;
	uniform float3		_SH21;
	uniform float3		_SH31;
	uniform float3		_SH41;
	uniform float3		_SH51;
	uniform float3		_SH61;
	uniform float3		_SH71;
	uniform float3		_SH81;
#endif

//Color-correction
half3 toLinearApprox3(half3 c){ return c*c; }
half3 toLinear3(half3 c)      { return pow(c,2.2); }
half  toLinearFast1(half  c)  { half  c2 = c*c; return dot(half2(0.7532,0.2468),half2(c2,c*c2)); }
half3 toLinearFast3(half3 c)  { half3 c2 = c*c; return 0.7532*c2 + 0.2468*c*c2; }

half  toGammaApprox1(half c)	  { return sqrt(c); }
half3 toGammaApprox3(half3 c) { return sqrt(c); }
half  toGamma1(half c)		  { return pow(c,0.454545); }
half3 toGamma3(half3 c)		  { return pow(c,0.454545); }
half  toGammaFast1(half c)	{
	c = 1.0 - c;
	half c2 = c*c;
	half3 c16 = half3(c2*c2,c2,c);	//^4
	c16.x *= c16.x;					//^8
	c16.x *= c16.x;					//^16
	c16 = half3(1.0,1.0,1.0)-c16;
	return dot(half3(0.326999,0.249006,0.423995),c16);
}
half3 toGammaFast3(half3 c) {
	half3 one = half3(1.0,1.0,1.0);
	c = one - c;
	half3 c2 = c*c;
	half3 c16 = c2*c2;	//^4
	c16 *= c16;			//^8
	c16 *= c16;			//^16
	return  0.326999*(one-c16) + 0.249006*(one-c2) + 0.423995*(one-c);
}

//(1-t)a + t*a*a;
//a - t*a + t*a*a;
//a( 1-t + t*a);
//mul(a, mad(t,a,1-t));  //4 inst, 2 inst if t and 1-t are constants
//lerp(a, a*a, t);       //4 inst, 3 inst if constant t

//3 instructions, IS_LINEAR and IS_GAMMA are computed at once
half  toLinearAuto1(half a)  { return dot(half2(a, a*a), IS_GAMMA_LINEAR); }
half3 toLinearAuto3(half3 a) { half2 IGL = IS_GAMMA_LINEAR; return a * ((a * IGL.yyy) + IGL.xxx); }


//(1-t)*sqrt(a) + t*a
//(1-s)*a + s*sqrt(a)
//a - s*a + s*sqrt(a)
//a - s*a + s*a/sqrt(a)
//a*(1-s+s*invsqrt(a))
//mul(a,mad(s,invsqrt(a),1-s))
//mul(a,mad(s,invsqrt(a),t)) //5 inst, 3 inst if constant t
//lerp(a*invsqrt(a), a, t)   //5 inst, 4 if constant t

//4 instructions, IS_LINEAR and IS_GAMMA are computed at once
half  toGammaAuto1(half a)  { half2 IGL = IS_GAMMA_LINEAR; return a*((IGL.x*rsqrt(a)) + IGL.y); }
half3 toGammaAuto3(half3 a) { half2 IGL = IS_GAMMA_LINEAR; return a*((IGL.xxx*rsqrt(a)) + IGL.yyy); }

half gammaLerpFast(half2 gammaLinear) 				{ return dot(gammaLinear, IS_GAMMA_LINEAR); }
half gammaLerp1(half gammaValue, half linearValue) 	{ return dot(half2(gammaValue,linearValue), IS_GAMMA_LINEAR); }
half3 gammaLerp3(half3 gammaValue, half3 linearValue) { half2 IGL = IS_GAMMA_LINEAR; return gammaValue*IGL.xxx  + (linearValue*IGL.yyy); }
half4 gammaLerp4(half4 gammaValue, half4 linearValue) {	half2 IGL = IS_GAMMA_LINEAR; return gammaValue*IGL.xxxx + (linearValue*IGL.yyyy); }

//approximations for the true, step-wise gamma curve used in sRGB compression
float linearTosRGB1( float c ) {
	float sqrtc = sqrt( c ); //SQRT/MAD/MAD/MAD (accurate)
	return (sqrtc - sqrtc*c) + c*(0.4672*c + 0.5328);
}
float3 linearTosRGB3( float3 c ) {
	float3 sqrtc = sqrt( c ); //SQRT/MAD/MAD/MAD (accurate)
	return (sqrtc - sqrtc*c) + c*(float3(0.4672,0.4672,0.4672)*c + float3(0.5328,0.5328,0.5328));
}
float4 linearTosRGB4( float4 c ) {
	float4 sqrtc = sqrt( c ); //SQRT/MAD/MAD/MAD (accurate)
	return (sqrtc - sqrtc*c) + c*(float4(0.4672,0.4672,0.4672,0.4672)*c + float4(0.5328,0.5328,0.5328,0.5328));
}

float sRGBToLinear1( float c ) {
	return (c*c)*(c*0.2848 + 0.7152); //MAD/MUL/MUL (accurate)
}
float3 sRGBToLinear3( float3 c ) {
	return (c*c)*(c*float3(0.2848,0.2848,0.2848) + float3(0.7152,0.7152,0.7152)); //MAD/MUL/MUL (accurate)
}		
float4 sRGBToLinear4( float4 c ) {
	return (c*c)*(c*float4(0.2848,0.2848,0.2848,0.2848) + float4(0.7152,0.7152,0.7152,0.7152)); //MAD/MUL/MUL (accurate)
}		

float3 mulVec3( float4x4 m, float3 v ) {
	return float3(dot(m[0].xyz,v.xyz),
				  dot(m[1].xyz,v.xyz),
				  dot(m[2].xyz,v.xyz));
}

float3 mulPoint3( float4x4 m, float3 p ) {
	float4 v = float4(p.x,p.y,p.z,1.0);
	return float3(dot(m[0],v),
				  dot(m[1],v),
				  dot(m[2],v));
}

float3 transposeMulVec3( float4x4 m, float3 v ) {
	return m[0].xyz*v.x + (m[1].xyz*v.y + (m[2].xyz*v.z));
}

float3 transposeMulVec3( float3x3 m, float3 v ) {
	return m[0].xyz*v.x + (m[1].xyz*v.y + (m[2].xyz*v.z));
}

float3 transposePoint3( float4x4 m, float3 p ) {
	return m[0].xyz*p.x + (m[1].xyz*p.y + (m[2].xyz*p.z + m[3].xyz));
}

half3 fromRGBM(half4 c) {
	//c.a *= 6.0;	
	//return c.rgb * lerp(c.a, toLinearFast1(c.a), IS_LINEAR);
	//7 instructions
	///
		
	//combined 6.0 * toLinear
	half4 IGL; //.xyz: modified versions of IS_GAMMA_LINEAR, .w: c.a*c.a
	IGL =
		half4(
			 19.35486,				// 3.22581 * 6.0,
			-87.468483312,			//-3.22581 * 0.7532 * 36.0,
			-171.964060128,			//-3.22581 * 0.2468 * 216.0,	
			 c.a
		) *
		half4(
			unity_ColorSpaceGrey.r,
			unity_ColorSpaceGrey.r,
			unity_ColorSpaceGrey.r,
			c.a
		) + 
		half4(
			-3.6774,				//-0.6129 * 6.0,
			 43.73410608,			// 1.6129 * 0.7532 * 36.0,
			 85.98176352,			// 1.6129 * 0.2468 * 216.0,
			 0.0
		);
	return c.rgb * dot(IGL.xyz, half3(c.a, IGL.w, c.a*IGL.w));
	//4 instructions
	///
}

half3 diffCubeLookup(samplerCUBE diffCube, float3 worldNormal) {
	half4 diff = texCUBE(diffCube, worldNormal);
	return fromRGBM(diff);
}

half3 specCubeLookup(samplerCUBE specCube, float3 worldRefl) {
	half4 spec = texCUBE(specCube, worldRefl);
	return fromRGBM(spec);
}

half3 glossCubeLookup(samplerCUBE specCube, float3 worldRefl, float glossLod) {
#ifdef MARMO_BIAS_GLOSS
	half4 lookup = half4(worldRefl,glossLod);
	half4 spec = texCUBEbias(specCube, lookup);
#else
	half4 lookup = half4(worldRefl,glossLod);
	half4 spec = texCUBElod(specCube, lookup);
#endif
	return fromRGBM(spec);
}

half glossLOD(half glossMap, half shininess) {
	glossMap = 1.0-glossMap;
	glossMap = 1.0-(glossMap*glossMap);
	return 7.0 + glossMap - (shininess*glossMap);
}

half glossExponent(half glossLod) {
	return exp2(8.0-glossLod);
}

//returns 1/spec. function integral
float specEnergyScalar(float gloss) {
	return (gloss*INV_2PI) + INV_2PIx2;
}

//returns fresnel*specIntensity in proper color space
half splineFresnel(float3 N, float3 E, half specIntensity, half fresnel) {
	half factor = saturate(dot(N,E));
	factor = 1.0 - factor;
	half factor3 = factor*factor*factor;
	
	//a spline between 1, factor, and factor^3
	half3 p = half3(1.0, factor, factor3);
	half2 t = half2(1.0-fresnel,fresnel);
	p.x = dot(p.xy,t);
	p.y = dot(p.yz,t);
	factor = dot(p.xy,t);
	factor = (0.95 * factor) + 0.05;
	factor *= specIntensity;
	
	//The math above is performed in linear space. If rendering in gamma space,
	//fresnel*specInt needs to be applied in gamma-space.
	// Note: specInt is also a linear value, it comes from a slider.
	factor = lerp(sqrt(factor), factor, IS_LINEAR);
	return factor;
}

//returns fresnel*specIntensity in proper color space
half fastFresnel(float3 N, float3 E, half specIntensity, half fresnel) {
	//fresnel math performed in gamma space
	half factor = saturate(dot(N,E));
	factor = 1.0 - factor;
	factor *= (0.5*factor) + 0.5;
	factor = (factor*0.85) + 0.15;
	factor = lerp(1.0, factor, fresnel);
	factor = specIntensity * factor;
	factor = lerp(factor, factor*factor, IS_LINEAR);
	return factor;
}

// x: fresnel term
// y: old fresnel*specIntensity term
// z: specIntensity
// All in proper color space
half3 schlickFresnel(float3 N, float3 H, half specIntensity, half fresnel) {
	half4 factor;
	factor.x = saturate(dot(N,H));
	//factor.x = 1.0 - factor.x*1.0;
	//factor.y = 1.25 - factor.x*fresnel;	//fade out old term by fresnel and bias the base-line some with 1.25
	factor.xy = saturate( (factor.xx*half2(-1.0,-fresnel)) + half2(1.0,1.25) );

	//factor^4	
	factor.zw = factor.xy*factor.xy; 
	factor.zw *= factor.zw;
	
	//factor^5
	factor.xy = factor.xy*factor.zw;
	factor.yz = half2(specIntensity*factor.y, specIntensity);
	
	//put into gamma space if necessary
	return lerp(sqrt(factor.xyz), factor.xyz, IS_LINEAR);
}

float3 skyRotate(uniform float4x4 skyMatrix, float3 R) {
	#ifdef MARMO_SKY_ROTATION
		R = transposeMulVec3(skyMatrix,R);
	#endif
	return R;
}

float3 skyProject(uniform float4x4 skyMatrix, uniform float4x4 invSkyMatrix, uniform float3 skyMin, uniform float3 skyMax, float3 worldPos, float3 R) {
	#ifdef MARMO_BOX_PROJECTION
		//box projection happens in sky-space
		#ifdef MARMO_SKY_ROTATION
			R = transposeMulVec3(skyMatrix,R).xyz;
		#endif
		float3 invR = 1.0/R;
		#ifdef MARMO_SKY_ROTATION
			float3 P = mulPoint3(invSkyMatrix,worldPos);
		#else
			float3 P = worldPos - skyMatrix[3].xyz;
		#endif
		float3 rbminmax = (R>0.0) ? skyMax.xyz : skyMin.xyz;
		//float3 rbminmax = lerp(skyMin, skyMax, saturate(R*1000000.0));
		rbminmax = (rbminmax - P.xyz) * invR;
		float fa = min(min(rbminmax.x, rbminmax.y), rbminmax.z);
		//R in projected sky space
		return (R*fa) + P.xyz;
	#else
		#ifdef MARMO_SKY_ROTATION
			R = transposeMulVec3(skyMatrix,R);
		#endif		
		return R;
	#endif
}

//converts linear, HDR color to RGBM encoded data, ready for screen output
float4 HDRtoRGBM(float4 color) {
	float toLinear = 2.2;
	float toGamma = 1.0/2.2;
	color.rgb = pow(color.rgb, toGamma); //RGBM gamma compression is 1/2.2
	color *= 1.0/6.0;
	float m = max(max(color.r,color.g),color.b);
	m = saturate(m);
	m = ceil(m*255.0)/255.0;
	
	if( m > 0.0 ) {
		float inv_m = 1.0/m;
		color.rgb = saturate(color.rgb*inv_m);
		color.a = m;
	} else {
		color = half4(0.0,0.0,0.0,0.0);
	}	
	return color;
}

float3 SHLookup(float3 dir) {
	//l = 0 band (constant)
	float3 result = _SH0.xyz;

	//l = 1 band
	result += _SH1.xyz * dir.y;
	result += _SH2.xyz * dir.z;
	result += _SH3.xyz * dir.x;

	//l = 2 band
	float3 swz = dir.yyz * dir.xzx;
	result += _SH4.xyz * swz.x;
	result += _SH5.xyz * swz.y;
	result += _SH7.xyz * swz.z;
	float3 sqr = dir * dir;
	result += _SH6.xyz * ( 3.0*sqr.z - 1.0 );
	result += _SH8.xyz * ( sqr.x - sqr.y );
	
	return abs(result);
}

void SHLookup(float3 dir, out float3 band0, out float3 band1, out float3 band2) {
	//l = 0 band (constant)
	band0 = _SH0.xyz;

	//l = 1 band
	band1 =  _SH1.xyz * dir.y;
	band1 += _SH2.xyz * dir.z;
	band1 += _SH3.xyz * dir.x;

	//l = 2 band
	float3 swz = dir.yyz * dir.xzx;
	band2 =  _SH4.xyz * swz.x;
	band2 += _SH5.xyz * swz.y;
	band2 += _SH7.xyz * swz.z;
	float3 sqr = dir * dir;
	band2 += _SH6.xyz * ( 3.0*sqr.z - 1.0 );
	band2 += _SH8.xyz * ( sqr.x - sqr.y );
}

#ifdef MARMO_SKY_BLEND
float3 SHLookup1(float3 dir) {
	//l = 0 band (constant)
	float3 result = _SH01.xyz;

	//l = 1 band
	result += _SH11.xyz * dir.y;
	result += _SH21.xyz * dir.z;
	result += _SH31.xyz * dir.x;

	//l = 2 band
	float3 swz = dir.yyz * dir.xzx;
	result += _SH41.xyz * swz.x;
	result += _SH51.xyz * swz.y;
	result += _SH71.xyz * swz.z;
	float3 sqr = dir * dir;
	result += _SH61.xyz * ( 3.0*sqr.z - 1.0 );
	result += _SH81.xyz * ( sqr.x - sqr.y );
	
	return abs(result);
}
void SHLookup1(float3 dir, out float3 band0, out float3 band1, out float3 band2) {
	//l = 0 band (constant)
	band0 = _SH01.xyz;

	//l = 1 band
	band1 =  _SH11.xyz * dir.y;
	band1 += _SH21.xyz * dir.z;
	band1 += _SH31.xyz * dir.x;

	//l = 2 band
	float3 swz = dir.yyz * dir.xzx;
	band2 =  _SH41.xyz * swz.x;
	band2 += _SH51.xyz * swz.y;
	band2 += _SH71.xyz * swz.z;
	float3 sqr = dir * dir;
	band2 += _SH61.xyz * ( 3.0*sqr.z - 1.0 );
	band2 += _SH81.xyz * ( sqr.x - sqr.y );
}
#endif

float3 SHLookupUnity(float3 dir) {
	return ShadeSH9(half4(dir.x, dir.y, dir.z,1.0));
}
void SHLookupUnity(float3 dir, out float3 band0, out float3 band1, out float3 band2) {
	//constant term
	band0 = float3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w);

	// Linear term
	band1.r = dot(unity_SHAr.xyz, dir.xyz);
	band1.g = dot(unity_SHAg.xyz, dir.xyz);
	band1.b = dot(unity_SHAb.xyz, dir.xyz);
	
	// 4 of the quadratic polynomials
	half4 vB = dir.xyzz * dir.yzzx;
	band2.r = dot(unity_SHBr,vB);
	band2.g = dot(unity_SHBg,vB);
	band2.b = dot(unity_SHBb,vB);

	// Final quadratic polynomial
	float vC = dir.x*dir.x - dir.y*dir.y;
	band2 += unity_SHC.rgb * vC;
}

float3 SHConvolve(float3 band0, float3 band1, float3 band2, float3 weight) {
	float3 conv1 = lerp( float3(1.0,1.0,1.0), float3(0.6667,0.6667,0.6667), weight);
	float3 conv2 = lerp( float3(1.0,1.0,1.0), float3(0.25,0.25,0.25), weight);
	conv1 = lerp(conv1, conv1*conv1, weight);
	conv2 = lerp(conv2, conv2*conv2, weight);
	return abs(band0 + band1*conv1 + band2*conv2);
}

#endif