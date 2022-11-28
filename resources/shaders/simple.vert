#version 450
#extension GL_ARB_separate_shader_objects : enable
#extension GL_GOOGLE_include_directive : require

#include "unpack_attributes.h"
#include "common.h"

layout(location = 0) in vec4 vPosNorm;
layout(location = 1) in vec4 vTexCoordAndTang;

layout(binding = 0, set = 0) uniform AppData {
    UniformParams Params;
};


layout(push_constant) uniform params_t
{
    mat4 mProjView;
    mat4 mModel;
} params;


layout (location = 0 ) out VS_OUT
{
    vec3 wPos;
    vec3 wNorm;
    vec3 wTangent;
    vec2 texCoord;

} vOut;

out gl_PerVertex { vec4 gl_Position; };

mat4 Rotational_Matrix(vec3 angle) {
    mat4 r_x = mat4(
        1, 0, 0, 0,
        0, cos(angle.x), -sin(angle.x), 0,
        0, sin(angle.x), cos(angle.x), 0,
        0, 0, 0, 1);
    mat4 r_y = mat4(
        cos(angle.y), 0, sin(angle.y), 0,
        0, 1, 0, 0,
        -sin(angle.y), 0, cos(angle.y), 0,
        0, 0, 0, 1);
    mat4 r_z = mat4(
        cos(angle.z), -sin(angle.z), 0, 0,
        sin(angle.z), cos(angle.z), 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1);
    
    return r_x * r_y * r_z;   
}


void main(void)
{
    const vec4 wNorm = vec4(DecodeNormal(floatBitsToInt(vPosNorm.w)),         0.0f);
    const vec4 wTang = vec4(DecodeNormal(floatBitsToInt(vTexCoordAndTang.z)), 0.0f);

    vec3 Rotation_angle = vec3(0.01 * Params.time, 0.01 * Params.time, 0.01 * Params.time);

    mat4 Rotational_matrix = Rotational_Matrix(Rotation_angle);

    mat4 mModel = params.mModel;

    mModel *= Rotational_matrix;

    vOut.wPos     = (params.mModel * vec4(vPosNorm.xyz, 1.0f)).xyz;
    vOut.wNorm    = normalize(mat3(transpose(inverse(params.mModel))) * wNorm.xyz);
    vOut.wTangent = normalize(mat3(transpose(inverse(params.mModel))) * wTang.xyz);
    vOut.texCoord = vTexCoordAndTang.xy;

    gl_Position   = params.mProjView * vec4(vOut.wPos, 1.0);
}
