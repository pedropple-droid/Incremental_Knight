@tool
extends RichTextEffect
class_name GhostEffect

var bbcode = "ghost"

func process_custom_fx(char_fx: CharFXTransform) -> bool:
	var speed: float = float(char_fx.env.get("freq", 5.0))
	var span: float = float(char_fx.env.get("span", 10.0))

	var alpha := sin(
		char_fx.elapsed_time * speed +
		(float(char_fx.absolute_index) / span)
	) * 0.5 + 0.5

	char_fx.color.a = alpha
	return true
