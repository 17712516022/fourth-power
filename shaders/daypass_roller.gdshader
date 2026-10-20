shader_type canvas_item;

// **这一层是"乘"上去的**，不是画上去的：
// render_mode blend_mul 让输出结果乘在滚筒表面素材上——底色（沟槽那一层）
// 由素材提供，这里只负责明暗。少了这一行，这层会**盖住**素材，
// 滚筒就变成一条光溜溜的渐变条，沟槽全没了。
render_mode blend_mul;

// ============================================================================
//  过场滚筒的**明暗层**：乘在滚筒表面素材上（material 的 blend_mode = MUL）。
//
//  这一层只做两件事——明暗和轮廓，**不加任何噪点**。
//  项目里 shaders/paper_menu.gdshader 已经定过规矩：全局是最近邻、画面是锐利的
//  像素格，而噪点是连续的高频信号，两者叠在一起会互相拆台。要颗粒感就画进素材
//  （滚筒的沟槽、墨上的网点都是画出来的），shader 只改亮度。
//
//  黑的两处用法：
//    上沿（v < 墨唇高度）输出 0 → 乘出来就是黑，读作"墨从滚筒边上挤出来"；
//    下沿（v → 1）一路压到 0 → 滚筒下半是背光的，正好接住下面那层接触阴影。
//
//  下面这些默认值和 .codebuddy/tools/daypass_art.py 里的常量**一一对应**
//  （那边用它渲染预览，这边给游戏用）。改一边就要改另一边。
// ============================================================================

uniform float base : hint_range(0.0, 1.5) = 0.55;         // 筒身基础亮度
uniform float sheen : hint_range(0.0, 2.0) = 0.75;        // 上沿高光强度
uniform float sheen_at : hint_range(0.0, 1.0) = 0.16;     // 高光位置（0 = 上沿）
uniform float sheen_wide : hint_range(0.01, 1.0) = 0.26;
uniform float falloff : hint_range(0.0, 1.5) = 0.62;      // 往下压暗多少
uniform float rim_at : hint_range(0.0, 1.0) = 0.87;       // 下沿反光的位置
uniform float rim_wide : hint_range(0.005, 0.2) = 0.025;
uniform float rim_gain : hint_range(0.0, 3.0) = 1.6;      // 下沿反光强度
uniform float side_dark : hint_range(0.0, 1.0) = 0.35;    // 左右两端压暗
uniform float lip : hint_range(0.0, 0.3) = 0.055;         // 墨唇厚度（占滚筒高）
uniform float lip_wave : hint_range(0.0, 1.0) = 0.5;      // 墨唇起伏幅度

void fragment() {
	float v = UV.y;

	// 圆柱的明暗：基础 + 上沿高光 + 下沿反光 - 下半逐渐背光
	float lum = base + sheen * exp(-pow((v - sheen_at) / sheen_wide, 2.0));
	lum += rim_gain * exp(-pow((v - rim_at) / rim_wide, 2.0));
	lum -= falloff * smoothstep(0.45, 1.0, v);

	// 左右两端压暗：读作"滚筒的端面在画面外"，也让画面有边。
	float edge = min(UV.x, 1.0 - UV.x);
	lum *= 1.0 - side_dark * smoothstep(0.10, 0.0, edge);

	// 上沿的墨唇：两个正弦叠出来的一条起伏黑边。
	// 用正弦而不是噪声——它是一条**形状**，硬边，和像素格不打架。
	float wave = (sin(UV.x * 48.0) + sin(UV.x * 19.0 + 1.7)) * 0.25;
	float lip_height = lip * (1.0 + lip_wave * wave);

	COLOR = vec4(vec3(v < lip_height ? 0.0 : max(lum, 0.0)), 1.0);
}
