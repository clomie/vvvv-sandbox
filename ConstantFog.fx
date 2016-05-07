//@author: 
//@help: standard fog shader based on constant shader
//@tags: fog
//@credits: 

struct vsInput
{
    float4 posObject : POSITION;
    float4 uv: TEXCOORD0;
};

struct psInput
{
    float4 posScreen : SV_Position;
    float4 uv: TEXCOORD0;
    float fogFactor : FOG;
};

    exture2D inputTexture <string uiname="Texture";>;

SamplerState linearSampler <string uiname="Sampler State";>
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};

cbuffer cbPerDraw : register(b0)
{
    float4x4 tVP : VIEWPROJECTION;
    float4x4 tV : VIEW;
};

cbuffer cbPerObj : register( b1 )
{
    float4x4 tW : WORLD;
    float Alpha <float uimin=0.0; float uimax=1.0;> = 1; 
    float4 cAmb <bool color=true;String uiname="Color";> = { 1.0f,1.0f,1.0f,1.0f };
    float4x4 tColor <string uiname="Color Transform";>;
};

cbuffer cbTextureData : register(b2)
{
    float4x4 tTex <string uiname="Texture Transform"; bool uvspace=true; >;
};

float4 FogColor <bool color=true;String uiname="Fog Color";> = { 0.0f, 0.0f, 0.0f, 1.0f };
float RangeFrom <string uiname="Range From";> = 0;
float RangeTo <string uiname="Range To";> = 1;
float Density = 0.5;
float ExpFactor = 2.71828;

psInput VS_Linear(vsInput input)
{
    psInput output;

    output.posScreen = mul(input.posObject,mul(tW,tVP));
    output.uv = mul(input.uv, tTex);

    float4 camera = mul(input.posObject, mul(tW,tV));
    output.fogFactor = saturate((RangeTo - camera.z) / (RangeTo - RangeFrom));

    return output;
}

psInput VS_Exp(vsInput input)
{
    psInput output;

    output.posScreen = mul(input.posObject,mul(tW,tVP));
    output.uv = mul(input.uv, tTex);

    float4 camera = mul(input.posObject, mul(tW,tV));
    output.fogFactor = pow((1.0 / abs(ExpFactor)), (camera.z * Density));

    return output;
}

psInput VS_Exp2(vsInput input)
{
    psInput output;

    output.posScreen = mul(input.posObject,mul(tW,tVP));
    output.uv = mul(input.uv, tTex);

    float4 camera = mul(input.posObject, mul(tW,tV));
    output.fogFactor = pow((1.0 / abs(ExpFactor)), pow((camera.z * Density), 2));

    return output;
}

float4 PS(psInput input): SV_Target
{
    float4 col = inputTexture.Sample(linearSampler,input.uv.xy) * cAmb;
    col = (input.fogFactor * col) + ((1.0 - input.fogFactor) * FogColor);
    col = mul(col, tColor);
    col.a *= Alpha;
    return col;
}

    echnique10 Linear
{
    pass P0
    {
        SetVertexShader( CompileShader( vs_4_0, VS_Linear() ) );
        SetPixelShader( CompileShader( ps_4_0, PS() ) );
    }
}

    echnique10 Exp
{
    pass P0
    {
        SetVertexShader( CompileShader( vs_4_0, VS_Exp() ) );
        SetPixelShader( CompileShader( ps_4_0, PS() ) );
    }
}

    echnique10 Exp2
{
    pass P0
    {
        SetVertexShader( CompileShader( vs_4_0, VS_Exp2() ) );
        SetPixelShader( CompileShader( ps_4_0, PS() ) );
    }
}
