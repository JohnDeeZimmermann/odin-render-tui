package ort

Position :: struct {
	x: int,
	y: int,
}
Dimensions :: struct {
	width:  int,
	height: int,
}

Area :: struct {
	using position:   Position,
	using dimensions: Dimensions,
}

Buffer :: struct {
	area:    Area,
	content: Cell,
}
