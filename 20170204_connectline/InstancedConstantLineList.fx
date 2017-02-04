float4x4 tVP : VIEWPROJECTION;
float4x4 tW : WORLD;

float4 cDefault <bool color=true;String uiname="Color";> = { 1.0f,1.0f,1.0f,1.0f };
StructuredBuffer<float4> vColBuffer;

uint bSize (StructuredBuffer<float4> buffer)
{
	uint count, dummy;
	buffer.GetDimensions(count,dummy);
	return count;
}

float4 bLoad(StructuredBuffer<float4> valueBuffer, float4 defaultValue, uint dtid)
{
	float4 value = defaultValue;
	uint count = bSize(valueBuffer);
	if (count > 0) value = valueBuffer[dtid.x % count];
	return value;
}

struct vsInput
{
	float4 PosO : POSITION;
	float4 TexCd : TEXCOORD0;
	uint vid : SV_VertexID ;
};

struct psInput
{
	float4 PosWVP: SV_POSITION;
	float4 Vcol : COL0;
};

psInput VS(vsInput input)
{
	psInput output;
	output.PosWVP  = mul(input.PosO, mul(tW, tVP));

	// Get Primitive ID
	uint primitiveID = floor(input.vid / 2);
	output.Vcol = bLoad(vColBuffer, cDefault, primitiveID);

	return output;
}

float4 PS(psInput input): SV_Target
{
	return input.Vcol;
}

technique10 Constant
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_5_0, VS() ) );
		SetPixelShader( CompileShader( ps_5_0, PS() ) );
	}
}
