#version 450
#extension GL_ARB_separate_shader_objects : enable
#extension GL_GOOGLE_include_directive : require

#include "common.h"

layout(triangles) in;
layout(triangle_strip, max_vertices = 3) out;

layout(push_constant) uniform params_t
{
    mat4 mProjView;
    mat4 mModel;
} params;



layout (location = 0 ) in VS_IN
{
    vec3 wPos;
    vec3 wNorm;
    vec3 wTangent;
    vec2 texCoord;

} gs_in[];


layout (location = 0 ) out VS_OUT
{
    vec3 wPos;
    vec3 wNorm;
    vec3 wTangent;
    vec2 texCoord;

} gs_out;

layout(binding = 0, set = 0) uniform AppData
{
  UniformParams Params;
};



vec3 GetNormal() {
   vec3 a = vec3(gs_in[2].wPos) - vec3(gs_in[1].wPos);
   vec3 b = vec3(gs_in[0].wPos) - vec3(gs_in[1].wPos);
   return normalize(cross(a, b));
}

vec4 Animate(vec4 position, vec3 normal)
{
    
    float magnitude = exp(-0.2*Params.time) * abs(sin(Params.time));
    vec3 direction = normal  *  magnitude;
    return position + vec4(direction, 0.0);
} 

void main(void)
{
    vec3 normal = GetNormal();
    gl_Position = params.mProjView * Animate(vec4(gs_in[0].wPos, 1.0f), GetNormal());
    EmitVertex();

    gl_Position = params.mProjView * Animate(vec4(gs_in[1].wPos, 1.0f), GetNormal());
    EmitVertex();

    gl_Position = params.mProjView * Animate(vec4(gs_in[2].wPos, 1.0f), GetNormal());
    EmitVertex();

    EndPrimitive();
}