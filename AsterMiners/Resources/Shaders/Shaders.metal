#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float3 position [[attribute(0)]];
    float2 uv [[attribute(1)]];
};

struct VSOut {
    float4 position [[position]];
    float2 uv;
    float4 color;
};

struct Uniforms {
    float4x4 modelMatrix;
};

vertex VSOut vertex_main(VertexIn in [[stage_in]], constant float4x4 &modelMatrix [[buffer(1)]], constant float4 &color [[buffer(2)]]) {
    VSOut out;
    float4 worldPos = modelMatrix * float4(in.position, 1.0);
    out.position = worldPos;
    out.uv = in.uv;
    out.color = color;
    return out;
}

fragment float4 fragment_main(VSOut in [[stage_in]]) {
    return in.color;
}

kernel void updateParticles(device float4 *positions [[buffer(0)]], uint id [[thread_position_in_grid]]) {
    positions[id] += float4(0.0, 0.002, 0.0, 0.0);
}

kernel void bloomKernel(texture2d<float, access::read_write> colorTexture [[texture(0)]], uint2 gid [[thread_position_in_grid]]) {
    if (gid.x >= colorTexture.get_width() || gid.y >= colorTexture.get_height()) { return; }
    float4 current = colorTexture.read(gid);
    float4 bloom = current * float4(0.1, 0.1, 0.2, 0.0);
    colorTexture.write(min(float4(1.0), current + bloom), gid);
}
