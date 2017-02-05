uint threadCount;

StructuredBuffer<float3> vertexBuffer;
StructuredBuffer<uint2> indexBuffer;

float3 cameraPosition;

float maxDistance;
float maxDepth;
float gamma;

RWStructuredBuffer<float> Output : BACKBUFFER;

uint bSize (StructuredBuffer<uint2> buffer)
{
	uint count, dummy;
	buffer.GetDimensions(count,dummy);
	return count;
}

uint bSize (StructuredBuffer<float3> buffer)
{
	uint count, dummy;
	buffer.GetDimensions(count,dummy);
	return count;
}

float pows(float a, float b) {return pow(abs(a),b)*sign(a);}

[numthreads(64,1,1)]
void CS(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x > threadCount) { return; }

	uint2 index = indexBuffer[dtid.x % bSize(indexBuffer)];
	float3 src = vertexBuffer[index.x % bSize(vertexBuffer)];
	float3 dst = vertexBuffer[index.y % bSize(vertexBuffer)];

	float alpha = 1;
	alpha *= 1 - min(distance(src, dst) / maxDistance, 1);
	alpha *= 1 - min(distance(src, cameraPosition) / maxDepth, 1);

	Output[dtid.x] = pows(alpha, gamma);
}

technique11 Distance
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}

