#include "StructLineConnection.fxh"

StructuredBuffer<LineConnection> lineBuffer;
StructuredBuffer<float3> vertexBuffer;

uint lineCount, vertexCount;
float distRange, distCenter;

AppendStructuredBuffer<Triangle> Output : BACKBUFFER;

float map(float v, float a1, float a2, float b1, float b2) {
	return b1 + (b2 - b1) * ((v - a1) / (a2 - a1));
}

float calcAlpha(float dist) {
	if (dist < distCenter) {
		return map(dist, distCenter - distRange, distCenter, 0, 1);
	} else {
		return map(dist, distCenter, distCenter + distRange, 1, 0);
	}
}

[numthreads(32,32,1)]
void CS(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= lineCount || dtid.y >= vertexCount) { return;	}
	
	uint lineIndex = dtid.x;
	uint vertexIndex = dtid.y;
	LineConnection input = lineBuffer[lineIndex];
	
	if (input.dstIndex >= vertexIndex) { return; }
	
	float3 target = vertexBuffer[vertexIndex];
	float distAC = distance(input.srcVertex, target);
	float distBC = distance(input.dstVertex, target);
	
	float minDistance = distCenter - distRange;
	float maxDistance = distCenter + distRange;
	
	if (minDistance < distAC && distAC < maxDistance
	&& minDistance < distBC && distBC < maxDistance) {
		
		float distAve = (input.distance + distAC + distBC) / 3;
		
		Triangle result = (Triangle)0;
		result.aPos = input.srcVertex;
		result.bPos = input.dstVertex;
		result.cPos = target;
		result.aIndex = input.srcIndex;
		result.bIndex = input.dstIndex;
		result.cIndex = vertexIndex;
		result.distance = distAve;
		result.alpha = calcAlpha(distAve);
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
