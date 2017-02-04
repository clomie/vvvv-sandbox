uint threadCount;

StructuredBuffer<float3> vertexBuffer;
StructuredBuffer<float2> indexBuffer;

float4 color <bool color=true;String uiname="Color";> = { 1.0f,1.0f,1.0f,1.0f };

float3 cameraPosition;

float maxDistance;
float maxDepth;

float gamma;

RWStructuredBuffer<float4> Output : BACKBUFFER;

uint bSize (StructuredBuffer<float2> buffer)
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

	float2 indices = indexBuffer[dtid.x % bSize(indexBuffer)];
	float3 src = vertexBuffer[indices.x % bSize(vertexBuffer)];
	float3 dst = vertexBuffer[indices.y % bSize(vertexBuffer)];

	float alpha = 1;
	alpha *= 1 - min(distance(src, dst) / maxDistance, 1);
	alpha *= 1 - min(distance(src, cameraPosition) / maxDepth, 1);

	float4 result;
	result.x = color.x;
	result.y = color.y;
	result.z = color.z;
	result.w = pows(alpha, gamma);

	Output[dtid.x] = result;
}

technique11 Distance
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}

