float4x4 tVP : VIEWPROJECTION;
float4x4 tW : WORLD;

float4 cDefault <bool color=true;String uiname="Color";> = { 1.0f,1.0f,1.0f,1.0f };

float alphaDefault = 1.0f;
StructuredBuffer<float> alphaBuffer;

uint bSize (StructuredBuffer<float> buffer)
{
	uint count, dummy;
	buffer.GetDimensions(count,dummy);
	return count;
}

float bLoad(StructuredBuffer<float> valueBuffer, float defaultValue, uint dtid)
{
	float value = defaultValue;
	uint count = bSize(valueBuffer);
	if (count > 0) value = valueBuffer[dtid.x % count];
	return value;
}

struct vsInput
{
	float4 PosO : POSITION;
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
	float4 color = cDefault;
	color.a *= bLoad(alphaBuffer, alphaDefault, primitiveID);
	output.Vcol = color;

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
