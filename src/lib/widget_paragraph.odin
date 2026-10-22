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

paragraph_widget_render :: proc(
	widget: ParagraphWidget,
	buffer: ^Buffer,
	allocator := context.allocator,
) -> (
	ok: bool,
) {
	area := buffer.area
	padding := widget.style.padding
	v_align := widget.style.vertical_alignment

	if (padding.left + padding.right >= area.width) {
		return false // Nothing to display
	}

	if (padding.top + padding.bottom >= area.height) {
		return false // Nothing to display
	}

	i := 0
	runes := utf8.string_to_runes(widget.text, allocator)
	usable_height := area.height - padding.bottom - padding.top

	// Bonus padding only necessary for vertical align
	extra_padding := _paragraph_widget_calc_extra_height_padding(
		widget,
		buffer^,
		runes,
		usable_height,
	)

	for y in (padding.top + extra_padding) ..< area.height - padding.bottom {
		new_rune_idx, should_continue := _paragraph_widget_render_row(widget, buffer, runes, y, i)
		i = new_rune_idx
		if (!should_continue) {
			break
		}
	}


	return true
}

_paragraph_widget_calc_extra_height_padding :: proc(
	widget: ParagraphWidget,
	buffer: Buffer,
	runes: []rune,
	usable_height: u16,
) -> u16 {
	if (widget.style.vertical_alignment == .BEGIN) {
		return 0
	}

	padding := widget.style.padding
	possible_runes_per_row := buffer.area.width - padding.right - padding.left
	if (possible_runes_per_row == 0) {
		return 0
	}

	rune_count := u16(len(runes))
	needed_rows := (rune_count / possible_runes_per_row)

	used_height := usable_height - needed_rows

	if (used_height <= 0) {
		return 0
	}

	if (widget.style.vertical_alignment == .CENTER) {
		return used_height / 2 - 1
	}

	return used_height - 1
}

_paragraph_widget_render_row :: proc(
	widget: ParagraphWidget,
	buffer: ^Buffer,
	runes: []rune,
	y: u16,
	rune_idx: int,
) -> (
	new_rune_idx: int,
	should_continue: bool,
) {
	i := rune_idx
	padding := widget.style.padding
	area := buffer.area

	usable_width := area.width - padding.left - padding.right
	extra_padding := _paragraph_widget_calc_extra_width_padding(
		widget,
		buffer^,
		runes,
		usable_width,
		i,
	)

	for x in padding.left + extra_padding ..< area.width - padding.right {
		x := x

		if i >= len(runes) {
			return i, false
		}

		cell_idx := buffer_get_cell_idx(buffer^, x, y)
		cell := Cell {
			rune  = runes[i],
			style = widget.style,
		}
		buffer.content[cell_idx] = cell

		i += 1
	}

	return i, true
}


_paragraph_widget_calc_extra_width_padding :: proc(
	widget: ParagraphWidget,
	buffer: Buffer,
	runes: []rune,
	usable_width: u16,
	rune_idx: int,
) -> u16 {
	if (widget.style.horizontal_alignment == .BEGIN) {
		return 0
	}

	rune_count := len(runes)
	remaining_runes := u16(rune_count - rune_idx)
	if (remaining_runes > usable_width) {
		return 0
	}

	if (widget.style.horizontal_alignment == .CENTER) {
		return (usable_width - remaining_runes) / 2
	}
	if (widget.style.horizontal_alignment == .END) {
		return usable_width - remaining_runes
	}

	return 0
}
