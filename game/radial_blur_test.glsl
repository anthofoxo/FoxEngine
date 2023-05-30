input(vec3, inPosition, 0);
output(vec4, outColor, 0);

varying(vec2, vUv);
varying(vec3, vNormal);

uniform vec2 uResolution;
uniform float uTime;
uniform sampler2D uChannel0;

#ifdef FE_VERT

void main(void)
{
	gl_Position = vec4(inPosition.xy, 0.0, 1.0);
	vUv = inPosition.xy * 0.5 + 0.5;
}

#elif defined FE_FRAG

float hash12(vec2 p)
{
	vec3 p3  = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

vec4 getSample(vec2 coord)
{
    return texture(uChannel0, coord + uTime * 0.1);
}

void main(void)
{
	float strength = 1.0;
    vec2 center = vec2(0.5, 0.5);
    
	vec2 toCenter = (center - vUv) * uResolution;

    float jitter = hash12(gl_FragCoord.xy);
    
    float iterations = 40.0;

    vec3 color = vec3(0.0);
	float total = 0.0;

	for (float t = 0.0; t < iterations; t++)
	{
		float percent = (t + jitter) / iterations;
		float weight = 4.0 * (percent - percent * percent);
		vec3 _sample = getSample(vUv + toCenter * percent / uResolution).rgb;

		_sample.rgb *= strength;
		color += _sample.rgb * weight;
		total += weight;
	}

    outColor = vec4(color / total, 1.0);
}

#endif