package ort

import tbx "shared:odin-termbox2"

_tbx_color_modify :: proc(color: tbx.Color, color_modify: tbx.ColorModifier) -> tbx.Color {
	return tbx.Color(u64(color) | u64(color_modify))
}

_tbx_color_apply_style :: proc(color: tbx.Color, font_style: FontStyle) -> tbx.Color {
	color := color
	if (font_style.bold) {
		color = _tbx_color_modify(color, tbx.ColorModifier.Bold)
	}
	if (font_style.italic) {
		color = _tbx_color_modify(color, tbx.ColorModifier.Italic)
	}
	if (font_style.strikeout) {
		color = _tbx_color_modify(color, tbx.ColorModifier.Strikeout)
	}
	if (font_style.underline) {
		color = _tbx_color_modify(color, tbx.ColorModifier.Underline)
	}
	if (font_style.reverse) {
		color = _tbx_color_modify(color, tbx.ColorModifier.Reverse)
	}

	return color
}

_tbx_color_from_color :: proc(color: Color) -> tbx.Color {
	switch c in color {
	case AnsiColor:
		return _tbx_color_from_ansi_color(c)
	case RGB:
		return _tbx_color_from_rgb(c)
	case IndexedColor:
		return _tbx_color_from_indexed(c)
	}

	assert(false, "Unreachable")
	return tbx.Color(0)
}


_tbx_color_from_rgb :: proc(color: RGB) -> tbx.Color {
	// Colors must be in the form 0xRRGGBB (so 8 bit per color)
	encoded_color := (color.r << 16 | color.g << 8 | color.b)

	// Black must be sent as HI_BLACK and may not be sent as 0b00
	if (encoded_color == 0) {
		return tbx.Color(tbx.ColorModifier.Hi_black)
	}

	return tbx.Color(encoded_color)
}

_tbx_color_from_indexed :: proc(color: IndexedColor) -> tbx.Color {
	return tbx.Color(color)
}

_tbx_color_from_ansi_color :: proc(color: AnsiColor) -> tbx.Color {
	switch color {
	case .Reset:
		return tbx.Color(tbx.NormalColor.Default)
	case .Black:
		return tbx.Color(tbx.NormalColor.Black)
	case .Red:
		return tbx.Color(tbx.NormalColor.Red)
	case .Green:
		return tbx.Color(tbx.NormalColor.Green)
	case .Yellow:
		return tbx.Color(tbx.NormalColor.Yellow)
	case .Blue:
		return tbx.Color(tbx.NormalColor.Blue)
	case .Magenta:
		return tbx.Color(tbx.NormalColor.Magenta)
	case .Cyan:
		return tbx.Color(tbx.NormalColor.Cyan)
	case .Gray:
		return _tbx_color_modify(tbx.Color(tbx.NormalColor.White), tbx.ColorModifier.Bright)
	case .DarkGray:
		return _tbx_color_modify(tbx.Color(tbx.NormalColor.Black), tbx.ColorModifier.Dim)
	case .White:
		return tbx.Color(tbx.NormalColor.White)
	case .LightRed:
		return _tbx_color_modify(tbx.Color(tbx.NormalColor.Red), tbx.ColorModifier.Bright)
	case .LightGreen:
		return _tbx_color_modify(tbx.Color(tbx.NormalColor.Green), tbx.ColorModifier.Bright)
	case .LightYellow:
		return _tbx_color_modify(tbx.Color(tbx.NormalColor.Yellow), tbx.ColorModifier.Bright)
	case .LightBlue:
		return _tbx_color_modify(tbx.Color(tbx.NormalColor.Blue), tbx.ColorModifier.Bright)
	case .LightMagenta:
		return _tbx_color_modify(tbx.Color(tbx.NormalColor.Magenta), tbx.ColorModifier.Bright)
	case .LightCyan:
		return _tbx_color_modify(tbx.Color(tbx.NormalColor.Cyan), tbx.ColorModifier.Bright)
	}

	assert(false, "Unreachable")
	return tbx.Color(0)
}
