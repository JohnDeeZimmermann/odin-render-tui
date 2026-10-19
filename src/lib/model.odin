package ort

FontStyle :: struct {
	bold:      bool,
	italic:    bool,
	underline: bool,
	strikeout: bool,
	reverse:   bool,
}

CellStyle :: struct {
	fg_color:         Color,
	bg_color:         Color,
	using font_style: FontStyle,
}

Cell :: struct {
	rune:  rune,
	style: CellStyle,
}
