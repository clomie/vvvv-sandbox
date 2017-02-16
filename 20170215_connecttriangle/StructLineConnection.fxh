struct LineConnection {
	float3 srcVertex, dstVertex;
	uint srcIndex, dstIndex;
	float distance, alpha;
};

struct Triangle {
	float3 aPos, bPos, cPos;
	uint aIndex, bIndex, cIndex;
	float distance, alpha;
};
