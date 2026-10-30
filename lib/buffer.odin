package ort

import "core:math"
import "core:fmt"
import tbx "shared:odin-termbox2"

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

area_from :: proc(width: u16, height: u16) -> Area {
	return Area{width = width, height = height}
}

buffer_get_cell_idx :: proc(buffer: Buffer, x: u16, y: u16) -> int {
	area := buffer.area

	assert(x < area.width && y < area.height, "Provided value out of bounds for area.")

	return int(y * area.width + x)
}

buffer_set_cell :: proc(buffer: Buffer, x: u16, y: u16, cell: Cell) {
	area := buffer.area
	assert(x < area.width && y < area.height, "Provided value out of bounds for area.")

	cell_idx := buffer_get_cell_idx(buffer, x, y)
	buffer.content[cell_idx] = cell
}

buffer_get_cell :: proc(buffer: Buffer, x: u16, y: u16) -> Cell {
	idx := buffer_get_cell_idx(buffer, x, y)
	return buffer.content[idx]
}

buffer_fill_background_color :: proc(buffer: ^Buffer, area: Area, color: Color) {
	bg_cell := Cell {
		style = CellStyle{bg_color = color},
	}
	for y in area.y ..< math.min(area.height, buffer.area.height) {
		for x in area.x ..< math.min(area.width, buffer.area.width) {
			buffer_set_cell(buffer^, x, y, bg_cell)
		}
	}
}

create_screen_buffer :: proc(allocator := context.allocator) -> (buffer: Buffer, ok: bool) {
	area := Area {
		width  = u16(tbx.width()),
		height = u16(tbx.height()),
	}
	return create_buffer(area, allocator)
}

create_buffer :: proc(area: Area, allocator := context.allocator) -> (buffer: Buffer, ok: bool) {
	buffer = Buffer {
		area = area,
	}
	if !buffer_reset(&buffer, allocator) {
		return buffer, false
	}

	return buffer, true
}

buffer_reset :: proc(buffer: ^Buffer, allocator := context.allocator) -> (ok: bool) {
	size := buffer.area.width * buffer.area.height

	if (buffer.content == nil) {
		content, err := make([dynamic]Cell, size, allocator)
		if err != nil {
			fmt.eprintfln("Error allocating buffer memory")
			return false
		}
		buffer.content = content
		return true
	}

	clear(&buffer.content)
	if resize(&buffer.content, size) != nil {
		return false
	}
	return true
}
