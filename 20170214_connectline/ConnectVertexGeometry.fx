#include "StructLineConnection.fxh"

float4x4 tW: WORLD;
float4x4 tVP: WORLDVIEWPROJECTION;

StructuredBuffer<LineConnection> inputBuffer;
StructuredBuffer<float> alphaBuffer;

float lineWidth = 1.0f;

float4 lineColor <bool color=true;String uiname="Color";> = { 1.0f,1.0f,1.0f,1.0f };
float gamma = 1.0f;

float3 cameraPosition = {0, 0, -1.0f};

struct VS_IN
{
	uint iv : SV_VertexID;
};

struct GS_IN
{
	float3 srcPos : POSITION;
	float3 dstPos : TEXCOORD0;
	float4 srcColor : TEXCOORD1;
	float4 dstColor : TEXCOORD2;
};

struct PS_IN
{
	float4 pos : SV_POSITION;
	float4 col : COLOR;
};

float pows(float a, float b) {return pow(abs(a),b)*sign(a);}

GS_IN VS(VS_IN input)
{
	uint count, dummy;
	inputBuffer.GetDimensions(count,dummy);

	LineConnection data = inputBuffer[input.iv];

	float srcAlpha = lineColor.a * data.closeness * alphaBuffer[data.srcIndex];
	float dstAlpha = lineColor.a * data.closeness * alphaBuffer[data.dstIndex];

	GS_IN output;
	output.srcPos = data.srcVertex; // mul(float4(data.srcVertex, 1), tWVP);
	output.dstPos = data.dstVertex; // mul(float4(data.dstVertex, 1), tWVP);
	output.srcColor = float4(lineColor.rgb, pows(srcAlpha, gamma));
	output.dstColor = float4(lineColor.rgb, pows(dstAlpha, gamma));
	return output;
}

[maxvertexcount(2)]
void GS_line(point GS_IN points[1], inout LineStream<PS_IN> output)
{
	GS_IN input = points[0];

	float4x4 tWVP = mul(tW, tVP);

	PS_IN v0, v1;
	v0.pos = mul(float4(input.srcPos, 1), tWVP);
	v0.col = input.srcColor;
	v1.pos = mul(float4(input.dstPos, 1), tWVP);
	v1.col = input.dstColor;

	output.Append(v0);
	output.Append(v1);
	output.RestartStrip();
}

[maxvertexcount(6)]
void GS_quad(point GS_IN points[1], inout TriangleStream<PS_IN> output)
{
	GS_IN input = points[0];
	float3 p0 = input.srcPos;
	float3 p1 = input.dstPos;

	float3 direction = normalize(p1 - p0);
    float3 normal = normalize(cross(cameraPosition, direction));

	float lw = lineWidth / 1000;
	float3 directionOffset = direction * lw;
	float3 normalScaled = normal * lw;
	
	float4x4 tWVP = mul(tW, tVP);

	PS_IN v0, v1, v2, v3;
	v0.pos = mul(float4(p0 - directionOffset - normalScaled, 1), tWVP);
	v0.col = input.srcColor;
	v1.pos = mul(float4(p0 - directionOffset + normalScaled, 1), tWVP);
	v1.col = input.srcColor;
	v2.pos = mul(float4(p1 + directionOffset + normalScaled, 1), tWVP);
	v2.col = input.dstColor;
	v3.pos = mul(float4(p1 + directionOffset - normalScaled, 1), tWVP);
	v3.col = input.dstColor;

	output.Append(v2);
	output.Append(v1);
	output.Append(v0);
	output.RestartStrip();

	output.Append(v3);
	output.Append(v2);
	output.Append(v0);
	output.RestartStrip();
}

float4 PS(PS_IN input): SV_Target
{
	return input.col;
}

GeometryShader StreamOutGSLine =
	ConstructGSWithSO(CompileShader(gs_5_0, GS_line()), "SV_POSITION;COLOR;");
GeometryShader StreamOutGSQuad =
	ConstructGSWithSO(CompileShader(gs_5_0, GS_quad()), "SV_POSITION;COLOR;");

technique10 Connect
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_5_0, VS() ) );
		SetGeometryShader(StreamOutGSLine);
		SetPixelShader( CompileShader( ps_5_0, PS() ) );
	}
}

technique10 ConnectWidth
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_5_0, VS() ) );
		SetGeometryShader(StreamOutGSQuad);
		SetPixelShader( CompileShader( ps_5_0, PS() ) );
	}
}