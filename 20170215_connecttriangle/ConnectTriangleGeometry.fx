#include "StructLineConnection.fxh"

float4x4 tW: WORLD;
float4x4 tVP: WORLDVIEWPROJECTION;

StructuredBuffer<Triangle> inputBuffer;
StructuredBuffer<float> alphaBuffer;

float4 lineColor <bool color=true;String uiname="Color";> = { 1.0f,1.0f,1.0f,1.0f };
float gamma = 1.0f;

struct VS_IN
{
	uint iv : SV_VertexID;
};

struct GS_IN
{
	float3 aPos : POSITION0;
	float3 bPos : POSITION1;
	float3 cPos : POSITION2;
	float4 aCol : TEXCOORD0;
	float4 bCol : TEXCOORD1;
	float4 cCol : TEXCOORD2;
};

struct PS_IN
{
	float4 pos : SV_POSITION;
	float4 col : COLOR;
};

float pows(float a, float b) {return pow(abs(a),b)*sign(a);}

GS_IN VS(VS_IN input)
{

	Triangle data = inputBuffer[input.iv];

	float tmpAlpha = lineColor.a * data.alpha;
	float aAlpha = tmpAlpha * alphaBuffer[data.aIndex];
	float bAlpha = tmpAlpha * alphaBuffer[data.bIndex];
	float cAlpha = tmpAlpha * alphaBuffer[data.cIndex];

	GS_IN output;
	output.aPos = data.aPos;
	output.bPos = data.bPos;
	output.cPos = data.cPos;
	output.aCol = float4(lineColor.rgb, pows(aAlpha, gamma));
	output.bCol = float4(lineColor.rgb, pows(bAlpha, gamma));
	output.cCol = float4(lineColor.rgb, pows(cAlpha, gamma));
	return output;
}

[maxvertexcount(3)]
void GS(point GS_IN points[1], inout TriangleStream<PS_IN> output)
{
	GS_IN input = points[0];

	float4x4 tWVP = mul(tW, tVP);

	PS_IN v0, v1, v2;
	v0.pos = mul(float4(input.aPos, 1), tWVP);
	v0.col = input.aCol;
	v1.pos = mul(float4(input.bPos, 1), tWVP);
	v1.col = input.bCol;
	v2.pos = mul(float4(input.cPos, 1), tWVP);
	v2.col = input.cCol;

	output.Append(v0);
	output.Append(v1);
	output.Append(v2);
	output.RestartStrip();
}

float4 PS(PS_IN input): SV_Target
{
	return input.col;
}

GeometryShader StreamOutGS =
	ConstructGSWithSO(CompileShader(gs_5_0, GS()), "SV_POSITION;COLOR;");

technique10 DrawTriangle
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_5_0, VS() ) );
		SetGeometryShader(StreamOutGS);
		SetPixelShader( CompileShader( ps_5_0, PS() ) );
	}
}
