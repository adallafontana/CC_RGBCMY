//--------------------------------------------------------------//
// SMOOTH CHROMA
//
//http://www.alessandrodallafontana.it/
//--------------------------------------------------------------//


int _LwksEffectInfo
<
   string EffectGroup = "GenericPixelShader";
   string Description = "SmoothChroma";
   string Category    = "Colour";
> = 0;

//--------------------------------------------------------------//
// Params
//--------------------------------------------------------------//
float BlurAmount
<
   string Description = "BlurAmount";
   float MinVal = 0.01;
   float MaxVal = 0.10;
> = 0.06;

//--------------------------------------------------------------//
// Inputs
//--------------------------------------------------------------//
texture fg;


//--------------------------------------------------------------//
// Samplers
//--------------------------------------------------------------//
sampler InputSampler = sampler_state { Texture = <fg>;
	MINFILTER = LINEAR;
        MIPFILTER = LINEAR;
        MAGFILTER = LINEAR;
        ADDRESSU  = MIRROR;
        ADDRESSV  = MIRROR; };


//--------------------------------------------------------------//
// Pixel Shader
//--------------------------------------------------------------//
float4 ps_main( float2 xy1 : TEXCOORD1 ) : COLOR
{
   float4 ret = tex2D( InputSampler, xy1 );
   float4 ret_NoBlur = ret;

   float amount = BlurAmount * 0.01;


   float4 blurred = ret;
   blurred += tex2D( InputSampler, xy1 + float2( -amount,  0.000 ) );
   blurred += tex2D( InputSampler, xy1 + float2(  amount,  0.000 ) );
   blurred += tex2D( InputSampler, xy1 + float2(  0.000, -amount ) );
   blurred += tex2D( InputSampler, xy1 + float2(  0.000,  amount ) );
   blurred += tex2D( InputSampler, xy1 + float2( -amount*2,  0.000 ) );
   blurred += tex2D( InputSampler, xy1 + float2(  amount*2,  0.000 ) );
   blurred += tex2D( InputSampler, xy1 + float2(  0.000, -amount*2 ) );
   blurred += tex2D( InputSampler, xy1 + float2(  0.000,  amount*2 ) );
   blurred /= 9.0;

   ret = blurred;


//RGB2YCbCr
  
   float Y = 0.065 + ( ret_NoBlur.r * 0.257 ) + ( ret_NoBlur.g * 0.504 ) + ( ret_NoBlur.b * 0.098 );
   float Cb = 0.5 - ( ret.r * 0.148 ) - ( ret.g * 0.291 ) + ( ret.b * 0.439 );
   float Cr = 0.5 + ( ret.r * 0.439 ) - ( ret.g * 0.368 ) - ( ret.b * 0.071 );



//YCbCr2RGB   
   float4 o_color;

   o_color.r = 1.164*(Y - 0.065) + 1.596*(Cr - 0.5);
   o_color.g = 1.164*(Y - 0.065) - 0.813*(Cr - 0.5) - 0.392*(Cb - 0.5);
   o_color.b = 1.164*(Y - 0.065) + 2.017*(Cb - 0.5);
   o_color.a = 1;


   return o_color;
}

//--------------------------------------------------------------//
// Techniques
//--------------------------------------------------------------//
technique singletechnique { pass Single_Pass { PixelShader = compile PROFILE ps_main(); } }
