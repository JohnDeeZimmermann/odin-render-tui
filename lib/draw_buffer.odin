package ort

import "core:fmt"
import "core:strings"
import tbx "shared:odin-termbox2"

// Draws the buffer to the screen, as is.
buffer_draw_screen :: proc(buffer: Buffer, app: App) -> (ok: bool = true) {
	if status_clear := tbx.clear(); status_clear != .Ok {
		fmt.eprintfln("Error trying to clear screen: %d", status_clear)
		return false
	}
	defer tbx.present()

	area := buffer.area
	for y in 0 ..< area.height {
		for x in 0 ..< area.width {
			cell_idx := int(y * area.width + x)
			if (cell_idx >= len(buffer.content)) {
				fmt.eprintfln(
					"Cell x: %d, y: %d (cell_idx: %d) exceeds buffer size of %d",
					x,
					y,
					cell_idx,
					len(buffer.content),
				)
				return false
			}

			buffer_cell := buffer.content[cell_idx]

			fg_color := _tbx_color_apply_style(
				_tbx_color_from_color(buffer_cell.style.fg_color),
				buffer_cell.style,
			)
			status := tbx.set_cell(
				i32(x),
				i32(y),
				buffer_cell.rune,
				fg_color,
				_tbx_color_from_color(buffer_cell.style.bg_color),
			)
			if status != tbx.Status.Ok {
				fmt.eprintfln(
					"Cell x: %d, y: %d (cell_idx: %d) caused error %d",
					x,
					y,
					cell_idx,
					status,
				)
				return false
			}
		}
	}

	return true
}

// Draws buffer source onto buffer target
buffer_draw_to_buffer :: proc(source: Buffer, target: ^Buffer) {
	src_area := source.area
	target_area := target.area

	for sy in 0 ..< src_area.height {
		ty := src_area.y + sy
		if ty >= target_area.height {
			break
		}

		for sx in 0 ..< src_area.width {
			tx := src_area.x + sx
			if tx >= target_area.width {
				break
			}

			source_cell := buffer_get_cell(source, sx, sy)
			cell_idx := buffer_get_cell_idx(target^, tx, ty)

			target.content[cell_idx] = source_cell
		}
	}
}
