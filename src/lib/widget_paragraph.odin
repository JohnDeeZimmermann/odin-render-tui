package ort

import "core:strings"
import "core:unicode/utf8"

ParagraphStyle :: struct {
	using cell_style:     CellStyle,
	padding:              Padding,
	horizontal_alignment: Alignment,
	vertical_alignment:   Alignment,
}

ParagraphWidget :: struct {
	style: ParagraphStyle,
	text:  string,
}

render_widget_paragraph :: proc(buffer: ^Buffer, widget: ParagraphWidget) -> (ok: bool) {
	area := buffer.area
	padding := widget.style.padding

	if (padding.left + padding.right >= area.width) {
		return false // Nothing to display
	}

	if (padding.top + padding.bottom >= area.height) {
		return false // Nothing to display
	}

	i := 0
	runes := utf8.string_to_runes(widget.text)
	for y in padding.top ..< area.height - padding.bottom {
		for x in padding.left ..< area.width - padding.right {
			if i >= len(runes) {
				break
			}

			cell_idx := buffer_get_cell_idx(buffer^, x, y)
			cell := Cell {
				rune  = runes[i],
				style = widget.style,
			}
			buffer.content[cell_idx] = cell

			i += 1
		}
	}

	return true
}
