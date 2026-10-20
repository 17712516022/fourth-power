shader_type canvas_item;

// 开始菜单的"印刷层"：全屏叠在最上面，采样已经画好的画面再重新上色。
//
// 和 paper_menu.gdshader 一样只动亮度与色调，不做模糊、不做噪点。
// 项目是 default_texture_filter = 0 的锐利像素风，任何"软"的叠加都会显得脏，
// 所以这里的效果全部来自低频的正弦起伏和线性压暗，边缘保持硬。

uniform sampler2D screen_tex : hint_screen_texture, repeat_disable, filter_nearest;

// 油墨偏暖：整体往旧报纸的米褐色挪一点。
uniform vec4 paper_tint : source_color = vec4(0.97, 0.92, 0.80, 1.0);
uniform float tint_amount : hint_range(0.0, 1.0) = 0.30;

// 压墨边：印刷机滚过时，油墨被挤到纸边，四周比中心更暗更实。
uniform float press_edge : hint_range(0.0, 0.6) = 0.18;
uniform float press_width : hint_range(0.02, 0.6) = 0.16;

// 墨色不匀：三组极慢的正弦叠出来的明暗起伏，像滚筒压力不均。
// 不是随机噪声 —— 随机的高频信号会和纸纹打架。
uniform float uneven_amount : hint_range(0.0, 0.2) = 0.045;
uniform float uneven_period : hint_range(20.0, 240.0) = 80.0;

void fragment() {
	vec4 src = texture(screen_tex, SCREEN_UV);
	vec3 col = src.rgb;

	// 偏暖：亮部靠纸色、暗部保留墨色，避免整体糊成一片褐色。
	float l = dot(col, vec3(0.299, 0.587, 0.114));
	col = mix(col, col * paper_tint.rgb, tint_amount * (0.4 + 0.6 * l));

	// 压墨边：越靠画幅边缘越暗。
	float edge = min(min(UV.x, 1.0 - UV.x), min(UV.y, 1.0 - UV.y));
	float press = 1.0 - smoothstep(0.0, press_width, edge);
	col *= 1.0 - press * press_edge;

	// 墨色不匀：周期很长，慢到几乎察觉不到在动，只是画面不死板。
	float t = TIME / uneven_period;
	float uneven = sin((UV.x * 3.1 + UV.y * 1.7 + t) * TAU) * 0.6
		+ sin((UV.x * -1.3 + UV.y * 4.2 - t * 1.7) * TAU) * 0.3
		+ sin((UV.x * 0.7 - UV.y * 2.3 + t * 0.6) * TAU) * 0.1;
	col *= 1.0 + uneven * uneven_amount;

	COLOR = vec4(col, src.a);
}
