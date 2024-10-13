#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float4 position [[attribute(0)]];
    float2 texCoord [[attribute(1)]];
};

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

vertex VertexOut vertexShader(const device VertexIn* vertex_array [[buffer(0)]],
                              unsigned int vid [[vertex_id]]) {
    VertexIn vertexIn = vertex_array[vid];
    
    VertexOut vertexOut;
    vertexOut.position = vertexIn.position;
    vertexOut.texCoord = vertexIn.texCoord;
    
    return vertexOut;
}

fragment float4 fragmentShader(VertexOut fragmentIn [[stage_in]],
                               texture2d<float> texture [[texture(0)]]) {
    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);
    return texture.sample(textureSampler, fragmentIn.texCoord);
}