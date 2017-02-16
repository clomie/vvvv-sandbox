uint threadCount;

float4 color;
StructuredBuffer<float> alphaBuffer;
RWStructuredBuffer<float4> Output : BACKBUFFER;

[numthreads(64,1,1)]
void CS(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }
	float alpha = alphaBuffer[dtid.x % threadCount];
	Output[dtid.x] = float4(color.rgb, alpha);
}

technique11 Distance
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}

