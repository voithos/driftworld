shader_type canvas_item;

uniform sampler2D mask;
uniform float strength : hint_range(0, 1);

varying vec2 vertPos;

void vertex()
{
	vertPos = VERTEX;
}

void fragment()
{
	vec4 maskColor = texture(mask, UV);
	vec2 maskOffset = maskColor.rg;
	maskOffset *= vertPos * SCREEN_PIXEL_SIZE;
	maskOffset *= strength;
	
	vec2 uv = SCREEN_UV;
	uv.x -= maskOffset.x;
	uv.y += maskOffset.y;
	
	vec4 color = texture(SCREEN_TEXTURE, uv);
	color.rgb *= vec3(1.0) + (maskColor.rgb * 0.25);
	color.a = texture(TEXTURE, UV).a;
	
	COLOR = color;
}