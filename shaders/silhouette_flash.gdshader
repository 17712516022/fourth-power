shader_type canvas_item;

// 过场剪影的高亮。
//
// 为什么不用 modulate：四张剪影贴图本身就是**纯黑**的（asserts/过场/农民.png 等），
// modulate 是乘法，黑乘任何颜色还是黑——只能压暗，不能提亮。
// 所以这里在片元里直接换色：flash = 0 时原样输出，flash = 1 时整个剪影变成 flash_color。
// 用贴图自己的 alpha 做混合，抗锯齿边缘不会留一圈黑边。

uniform vec4 flash_color : source_color = vec4(1.0, 0.97, 0.90, 1.0);
uniform float flash : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	tex.rgb = mix(tex.rgb, flash_color.rgb, flash * tex.a);
	COLOR = tex;
}
