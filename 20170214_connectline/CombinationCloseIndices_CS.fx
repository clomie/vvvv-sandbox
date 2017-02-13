#include "StructLineConnection.fxh"

uint threadCount;

StructuredBuffer<float3> vertexBuffer;
float minDistance;
float maxDistance;

AppendStructuredBuffer<LineConnection> Output : BACKBUFFER;

[numthreads(32,32,1)]
void CS(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount || dtid.y >= threadCount) { return; }

	uint count, dummy;
	vertexBuffer.GetDimensions(count,dummy);
	
	uint srcIndex = dtid.x % count;
	uint dstIndex = dtid.y % count;

	float3 src = vertexBuffer[dtid.x % count];
	float3 dst = vertexBuffer[dtid.y % count];
	float dist = distance(src, dst);

	if (minDistance < dist && dist < maxDistance) {
		LineConnection result;
		result.srcIndex = srcIndex;
		result.dstIndex = dstIndex;
		result.srcVertex = src;
		result.dstVertex = dst;
		result.distance = dist;
		result.closeness = 1 - dist / maxDistance;
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
