// Generated with BONZOMATIC (GLFW edition)

#version 410 core
uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

vec3 invert(vec3 mixed) {
  return vec3(1. - mixed.x, 1. - mixed.y, 1. - mixed.z);
}

float degtorad(float deg) {
  return (3.14 / 180.) * (deg * 100.);
}

vec2 rotate(vec2 what, float modifier) {
  float r1 = (what.x * cos(modifier) - what.y * sin(modifier));
  float r2 = (what.x * sin(modifier) + what.y * cos(modifier));
  return (vec2(r1, r2));
}

mat2 rotat(float angle) {
  return mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
}

vec3 hue2rgb(float hue) {
  hue = fract(hue);
  float r = abs(hue*6-3)-1;
  float g = 2-abs(hue*6-2);
  float b = 2-abs(hue*6-4);
  vec3 rgb = vec3(r,g,b);
  return rgb;
}

vec3 lerp(float v0, vec3 v1, float t) {
  float x = v0 + t*(v1.x-v0);
  float y = v0 + t*(v1.y-v0);
  float z = v0 + t*(v1.z-v0);
  return vec3(x,y,z);
}

vec3 rgb2hsv(vec3 rgb)
{
    float maxComponent = max(rgb.x, max(rgb.y, rgb.z));
    float minComponent = min(rgb.x, min(rgb.y, rgb.z));
    float diff = maxComponent - minComponent;
    float hue = 0;
    if(maxComponent == rgb.x) {
        hue = 0+(rgb.y-rgb.z)/diff;
    } else if(maxComponent == rgb.x) {
        hue = 2+(rgb.y-rgb.x)/diff;
    } else if(maxComponent == rgb.z) {
        hue = 4+(rgb.x-rgb.y)/diff;
    }
    hue = fract(hue / 6);
    float saturation = diff / maxComponent;
    float value = maxComponent;
    return vec3(hue, saturation, value);
}

vec3 hsv2rgb(vec3 hsv)
{
    vec3 rgb = hue2rgb(hsv.x); //apply hue
    rgb = lerp(1, rgb, hsv.y); //apply saturation
    rgb = rgb * hsv.z; //apply value
    return rgb;
}

void main(void)
{
  float factor = 0.1;
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
    
  uv.x -= 0.5;
  uv.x *= v2Resolution.x / v2Resolution.y + 1;
  uv.x += .5;
  
  uv -= .5;
  uv *= rotat(fGlobalTime - (fGlobalTime*factor))*(uv);
  uv += .5;
  //float rad = degtorad(factor*fGlobalTime);
  
  float dist = length(uv - vec2(0.5));
  float circle = step(dist, .05);
   
  vec3 gradient = vec3(1.,.2,1.);
  vec3 t = vec3(.0226, .0,.615);
  float mixed = distance(uv, vec2(.5,1));
  
  vec3 cola = mix(gradient,t,mixed);
  vec3 colb = rgb2hsv(invert(cola));
  colb.x += uv.x + fGlobalTime / 2;
  colb = hsv2rgb(colb);
  cola = invert(colb);
  
  vec3 col = mix(colb, cola, circle);
  
  out_color = vec4(col, 1.0);
}
