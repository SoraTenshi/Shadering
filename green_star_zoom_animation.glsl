// Generated with BONOMATIC (GLFW edition)

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

#define time fGlobalTime

mat2 rot(float deg) {
  float s = sin(deg);
  float c = cos(deg);
  
  return mat2(c, -s, s, c);
}

float line(vec2 p1, vec2 p2) {
  vec2 point = gl_FragCoord.xy / v2Resolution.xy;

  float a = p1.y-p2.y;
  float b = p2.x-p1.x;
  return abs(a*point.x+b*point.y+p1.x*p2.y-p2.x*p1.y) / a*a+b*b;
}


#define tn .003
void main(void) {
  vec2 uv = gl_FragCoord.xy / v2Resolution.xy;
  float ang = .45 * 3.;
  
  uv.x -= .33;
  uv.y -= .555;
  uv *= (cos(time/2.*ang))/(cos(time/2.*ang))*(tan(time/2.*ang));
  uv.x *= v2Resolution.x / v2Resolution.y;
  vec2 pg = uv + vec2(cos(ang), uv.y);
  vec2 pt = vec2(pg.x, uv.y);
  
  float ln = line(uv, pt);
  float ln1 = line(uv, pg);
  float ln2 = line(pg, pt);
  float a = fract(smoothstep(tn*.3, tn, ln)*smoothstep(tn-5, .5*tn, ln1)*smoothstep(5.*tn, 1.5*tn, ln2));
 
  
  float ds = length(uv - vec2(.5));
  float ds1 = length(pg - vec2(.5));
  float ds2 = length(pt - vec2(.5));
  float d = step(ds, .03);
  float d1 = step(ds1,.03);
  float d2 = step(ds2, .03);
  
  vec3 col = vec3(.8, .1, .8);
  vec3 c = mix(vec3(0.,0.,0.), 1-col, a);
  /*c *= mix(col, 1-col, d);
  c *= mix(col, 1-col, d1);
  c *= mix(col, 1-col, d2);
  */
	out_color = vec4(c,1.0);
  
}
