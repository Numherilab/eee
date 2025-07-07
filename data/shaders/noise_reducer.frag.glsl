#ifdef GL_ES
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif

#if __VERSION__ >= 130
#define COMPAT_VARYING in
#define COMPAT_TEXTURE texture
out COMPAT_PRECISION vec4 FragColor;
#else
#define COMPAT_VARYING varying
#define FragColor gl_FragColor
#define COMPAT_TEXTURE texture2D
#endif

uniform sampler2D sol_texture;
uniform bool sol_vcolor_only;
uniform bool sol_alpha_mult;
COMPAT_VARYING vec2 sol_vtex_coord;
COMPAT_VARYING vec4 sol_vcolor;


vec4 sample_smooth(vec2 uvs) {
vec2 offs[4];
    offs[0] = vec2(0.375,0.125);
    offs[1] = vec2(0.875,0.375);
    offs[2] = vec2(0.125,0.625);
    offs[3] = vec2(0.625,0.875);
    
    float scale = 1.3;
    
    vec2 dx = dFdx(uvs)*scale;
    vec2 dy = dFdy(uvs)*scale;
    
    vec4 res = vec4(0.0);
    for(int i = 0; i < 4; i++) {
      vec2 off = offs[i]-vec2(0.5);
      res += COMPAT_TEXTURE(sol_texture, uvs+dx*off.y+dy*off.x);
    }
    return res*0.25;
}

void main() {
  if (!sol_vcolor_only) {
      vec4 tex_color = sample_smooth(sol_vtex_coord);
      FragColor = tex_color * sol_vcolor;
      if (sol_alpha_mult) {
          FragColor.rgb *= sol_vcolor.a; //Premultiply by opacity too
      }
  } else {
      FragColor = sol_vcolor;
  }
}