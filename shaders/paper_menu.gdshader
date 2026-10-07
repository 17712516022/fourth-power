shader_type canvas_item;

// 开始菜单的纸张背景。
//
// 这里**只做亮度类的动效**，不做颗粒噪点。
//
// 原因：项目在 project.godot 里设了 default_texture_filter = 0（最近邻），
// 整个游戏的质感是"锐利的像素格"。而噪点是连续的高频信号——
// 叠上去以后，画面上会同时存在两种互相拆台的质感：
// 纸纹是硬的，颗粒是软的，谁都不像谁。
//
// 暗角和扫光只改亮度，不产生新的高频细节，所以和像素风不打架。
// 想要颗粒感，应该画进素材里，而不是在 shader 里现加。

// --- 暗角呼吸 ---
// 边缘恒暗，但"有多暗"在缓慢地起伏。
//
// 幅度和周期都调过一轮：第一版是 40 秒、0.22 的幅度，
// 结果在这个暗背景上人眼完全分辨不出来——**慢不等于看不见**。
// 现在 9 秒一个来回、幅度 0.5，是"柔和但一眼能看出来"的程度。
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.42;
uniform float vignette_breath : hint_range(0.0, 1.0) = 0.50;
uniform float breath_period : hint_range(3.0, 180.0) = 9.0;

// --- 柔光扫过 ---
// 一道斜向亮带，从左扫到右。亮带经过时整屏加亮 16%。
// 像有人从纸上方缓缓走过，把灯带过去了。
uniform vec4 sweep_color : source_color = vec4(1.0, 0.97, 0.86, 1.0);
uniform float sweep_strength : hint_range(0.0, 0.4) = 0.16;
uniform float sweep_period : hint_range(4.0, 120.0) = 10.0;
uniform float sweep_tilt : hint_range(-1.0, 1.0) = 0.28;

void fragment() {
	vec4 col = texture(TEXTURE, UV);

	// 暗角：中心 0，边缘 1，中间用 smoothstep 过渡。
	// 乘以 breathing 让强度在 [1-幅度, 1] 之间缓慢摆动。
	float d = distance(UV, vec2(0.5));
	float breathing = 1.0 - vignette_breath * 0.5
		* (1.0 - cos(TAU * TIME / breath_period));
	float vig = smoothstep(0.22, 0.86, d) * vignette_strength * breathing;
	col.rgb *= 1.0 - vig;

	// 扫光：把 UV 投影到一条斜线上，得到 0~1 的进度 p，
	// 再让一个高斯亮斑沿着 p 从 -0.4 走到 1.4。周期末它会跑出画面，
	// 所以接缝不会被看到。
	float p = UV.x * (1.0 - sweep_tilt) + UV.y * sweep_tilt;
	float center = fract(TIME / sweep_period) * 1.8 - 0.4;
	float band = exp(-pow((p - center) * 3.5, 2.0));
	col.rgb += band * sweep_strength * sweep_color.rgb;

	COLOR = col;
}
