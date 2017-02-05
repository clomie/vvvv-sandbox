uint threadCount;

StructuredBuffer<float3> vertexBuffer;
float maxDistance;

AppendStructuredBuffer<uint2> Output : BACKBUFFER;

uint bSize (StructuredBuffer<float3> buffer)
{
	uint count, dummy;
	buffer.GetDimensions(count,dummy);
	return count;
}

[numthreads(64,1,1)]
void CS(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }

	uint size = bSize(vertexBuffer);
	uint srcIndex = dtid.x / size;
	uint dstIndex = dtid.x % size;

	float3 src = vertexBuffer[srcIndex];
	float3 dst = vertexBuffer[dstIndex];

	if (distance(src, dst) < maxDistance) {
		uint2 result = float2(srcIndex, dstIndex);
		Output.Append(result);
	}
}

technique11 Distance
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}
