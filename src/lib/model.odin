package ort

CellStyle :: struct {
	fg_color: Color,
	bg_color: Color,
	bold:     bool,
	italic:   bool,
}

Cell :: struct {
	rune:  rune,
	style: CellStyle,
}
