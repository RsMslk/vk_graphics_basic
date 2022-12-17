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

vec3 Animate(vec3 position, vec3 normal)
{
    float time1;
    if ((transpose(params.mModel) ==  mat4(0.999889,  0.0, -0.0149171, 0.0, 0.0, 1.0, 0.0,-1.27, 0.0149171, 0.0, 0.999889, 0.0, 0.0, 0.0, 0.0, 1.0)
    || transpose(params.mModel) == mat4(1.0, 0.0, 0.0, 0.985493, 0.0, 1.0, 0.0, -1.27, 0.0, 0.0, 1.0, 0.512028, 0.0, 0.0, 0.0, 1.0)
    ))
    {
        float magnitude = abs(sin(0.15*Params.time)) * 2.25 * abs(sin(Params.time));;
        vec3 direction = normal  *  magnitude;
        time1 = Params.time;
        return position + direction;
    }
    return position;
} 

void main(void)
{
    vec3 normal = GetNormal();

    gs_out.wPos = Animate(gs_in[0].wPos, normal);
    gl_Position = params.mProjView * vec4(gs_out.wPos, 1.0);
    gs_out.wNorm    = normalize(mat3(params.mModel) * gs_in[0].wNorm.xyz);
    EmitVertex();
    
    gs_out.wPos = Animate(gs_in[1].wPos, normal);
    gl_Position = params.mProjView * vec4(gs_out.wPos, 1.0);
    gs_out.wNorm    = normalize(mat3(params.mModel) * gs_in[1].wNorm.xyz);
    EmitVertex();
    
    gs_out.wPos = Animate(gs_in[2].wPos, normal);
    gl_Position = params.mProjView * vec4(gs_out.wPos, 1.0);
    gs_out.wNorm    = normalize(mat3(params.mModel) * gs_in[2].wNorm.xyz);
    EmitVertex();

    EndPrimitive();
}