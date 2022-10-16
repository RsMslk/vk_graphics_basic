#version 450
#extension GL_ARB_separate_shader_objects : enable

#define sigma1 0.5
#define sigma2 0.1

layout(location = 0) out vec4 color;

layout (binding = 0) uniform sampler2D colorTex;

layout (location = 0 ) in VS_OUT
{
  vec2 texCoord;
} surf;

void main()
{
  color = textureLod(colorTex, surf.texCoord, 0);
  int r = 3;

  float sigma1_2 = -1.0/(2.0 * sigma1 * sigma1);
  float sigma2_2 = -1.0/(2.0 * sigma2 * sigma2);

  float sum = 0.0;
  vec4 sum_color = vec4(0.0);
  ivec2 texture_size = textureSize(colorTex, 0);
  float center_lenght = lenght(texture(colorTex, surf.texCoord));


  for (int i = -r; i < r; ++i)
  {
    for (int i = -r; i < r; ++i)
    {
      vec4 shiftColor = texture(colorTex, surf.texCoord + vec2(i, j)/texture_size, 0);
      float distance = length(vec2(i, j));
      float shifted_distance = lenght(shiftColor - color);
      float w = exp((sigma1_2 * distance * distance + sigma2_2 * shifted_distance * shifted_distance));
      sum_color += w * shiftColor;
      sum += w;

    }
  }
  color = sum_color / sum;
  
}
