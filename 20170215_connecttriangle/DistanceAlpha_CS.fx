uint vertexCount;

StructuredBuffer<float3> vertexBuffer;

float3 cameraPosition;
float maxDepth;

RWStructuredBuffer<float> Output : BACKBUFFER;

float pows(float a, float b) {return pow(abs(a),b)*sign(a);}

[numthreads(64,1,1)]
void CS(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= vertexCount) { return; }

	float3 src = vertexBuffer[dtid.x % vertexCount];
	float alpha = 1 - min(distance(src, cameraPosition) / maxDepth, 1);
	Output[dtid.x] = alpha;
}

technique11 Distance
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}

