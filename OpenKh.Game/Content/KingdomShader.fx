﻿#if OPENGL
	#define SV_POSITION POSITION
	#define VS_SHADERMODEL vs_3_0
	#define PS_SHADERMODEL ps_3_0
#else
	#define VS_SHADERMODEL vs_4_0_level_9_1
	#define PS_SHADERMODEL ps_4_0_level_9_1
#endif

matrix WorldView;
matrix ProjectionView;
float4 TextureRegion;
Texture2D Texture0;

sampler2D TextureSampler = sampler_state
{
	Texture = <Texture0>;
};

struct VertexShaderInput
{
	float4 Position : POSITION0;
	float4 Color : COLOR0;
	float2 TextureUv : TEXCOORD0;
};

struct VertexShaderOutput
{
	float4 Position : SV_POSITION;
	float4 Color : COLOR0;
	float2 TextureUv : TEXCOORD0;
};

float2 RegionClamp(float2 textureCoord)
{
	return float2(
		min(max(textureCoord.x, TextureRegion.x), TextureRegion.z),
		min(max(textureCoord.y, TextureRegion.y), TextureRegion.w)
		);
}

float2 RegionRepeat(float2 textureCoord)
{
	return float2(
		((textureCoord.x - TextureRegion.x) % (TextureRegion.z - TextureRegion.x)) + TextureRegion.x,
		((textureCoord.y - TextureRegion.y) % (TextureRegion.w - TextureRegion.y)) + TextureRegion.y
		);
}

VertexShaderOutput MainVS(in VertexShaderInput input)
{
	VertexShaderOutput output = (VertexShaderOutput)0;

	output.Position = mul(mul(input.Position, WorldView), ProjectionView);
	output.TextureUv = input.TextureUv;
	output.Color = input.Color;

	return output;
}

float4 MainPS(VertexShaderOutput input) : COLOR
{
	float4 tex = tex2D(TextureSampler, RegionRepeat(input.TextureUv));
	return tex * input.Color;
}

technique BasicColorDrawing
{
	pass P0
	{
		VertexShader = compile VS_SHADERMODEL MainVS();
		PixelShader = compile PS_SHADERMODEL MainPS();
	}
};