package ort

import "core:fmt"

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

buffer_get_cell_idx :: proc(buffer: Buffer, x: u16, y: u16) -> int {
	area := buffer.area

	assert(x < area.width && y < area.height, "Provided value out of bounds for area.")

	return int(y * area.width + x)
}

