shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx, unshaded;

uniform vec3 albedo : source_color;
uniform sampler2D water_texture1;
uniform sampler2D water_texture2;

uniform vec2 scroll_speed1 = vec2(0.05, 0.0);
uniform vec2 scroll_speed2 = vec2(-0.03, 0.0);
uniform float blend_factor = 1.5;
uniform vec2 scale1 = vec2(2.0, 2.0);
uniform vec2 scale2 = vec2(1.0, 1.0);

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void vertex() {
	// displacement stuff maybe one day
}

void fragment() {
    vec2 scaledUV1 = UV * scale1;
    vec2 scaledUV2 = UV * scale2;
    vec2 scrolledUV1 = scaledUV1 + scroll_speed1 * TIME;
    vec2 scrolledUV2 = scaledUV2 + scroll_speed2 * TIME;
    scrolledUV1 = mod(scrolledUV1, vec2(1.0, 1.0));
    scrolledUV2 = mod(scrolledUV2, vec2(1.0, 1.0));
	
	vec4 water_color1 = texture(water_texture1, scrolledUV1);
	float cutout = max(water_color1.r, max(water_color1.g, water_color1.b));
	float mask = smoothstep(0.5, 0.55, cutout);
	
	vec4 water_color2 = texture(water_texture2, scrolledUV2);
	water_color2 = vec4(1.0- water_color2.rgb, water_color2.a);
	vec4 blended_water_color = mix(water_color1, water_color2, blend_factor);
	//vec4 blended_water_color = water_color1 * water_color2 * blend_factor;
	
	ALBEDO = mix(albedo.rgb, water_color1.rgb, mask);
	//ALBEDO = blended_water_color.rgb * albedo;
    METALLIC = 1.0;
    ROUGHNESS = 0.0;
}