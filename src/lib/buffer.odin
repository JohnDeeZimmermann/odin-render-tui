package ort

Position :: struct {
	x: u16,
	y: u16,
}

Dimensions :: struct {
	width:  u16,
	height: u16,
}

Area :: struct {
	using position:   Position,
	using dimensions: Dimensions,
}

Buffer :: struct {
	area:    Area,
	content: [dynamic]Cell,
}
