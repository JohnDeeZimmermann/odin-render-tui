package ort

import "core:fmt"
import "core:math"
import "core:strings"
import "core:unicode/utf8"

ParagraphStyle :: struct {
	using cell_style:     CellStyle,
	padding:              Padding,
	horizontal_alignment: Alignment,
	vertical_alignment:   Alignment,
}

ParagraphWidget :: struct {
	style:             ParagraphStyle,
	widget_dimensions: WidgetDimensions,
	text:              string,
}

paragraph_widget_required_area :: proc(
	widget: ParagraphWidget,
	area: Area,
	allocator := context.allocator,
) -> (
	required_area: Area,
	ok: bool,
) {
	bounds := wd_get_bounds(widget.widget_dimensions, area)
	area := wd_usable_area(widget.widget_dimensions, area)

	runes, err_runes := utf8.string_to_runes(widget.text, allocator)
	if (err_runes != nil) {
		fmt.eprintfln("Failed to allocate runes")
		return {}, false
	}
	rune_count := u16(len(runes))
	padding := widget.style.padding

	// Height

	usable_height := math.max(0, area.height - padding.bottom - padding.top)
	extra_top_padding := _paragraph_widget_calc_extra_height_padding(
		widget,
		area,
		runes,
		usable_height,
	)
	start_y := padding.top + extra_top_padding + area.y
	possible_runes_per_row := area.width - padding.right - padding.left

	needed_rows := (rune_count / possible_runes_per_row)
	used_height := math.min(usable_height, needed_rows)
	end_y := start_y + used_height

	required_height := max(end_y - start_y + 1, bounds.min_h)

	// Width

	usable_width := math.max(0, area.width - padding.left - padding.right)
	extra_width_padding := _paragraph_widget_calc_extra_width_padding(
		widget,
		runes,
		usable_width,
		0,
	)

	start_x := padding.left + extra_width_padding + area.x
	required_width := math.max(u16(math.min(rune_count, possible_runes_per_row)), bounds.min_w)

	return Area{x = start_x, width = required_width, y = start_y, height = required_height}, true
}

paragraph_widget_render :: proc(
	widget: ParagraphWidget,
	buffer: ^Buffer,
	area: Area,
	allocator := context.allocator,
) -> (
	ok: bool,
) {
	padding := widget.style.padding
	v_align := widget.style.vertical_alignment
	area := wd_usable_area(widget.widget_dimensions, area)

	if (padding.left + padding.right >= area.width) {
		return false // Nothing to display
	}

	if (padding.top + padding.bottom >= area.height) {
		return false // Nothing to display
	}

	i := 0
	runes := utf8.string_to_runes(widget.text, allocator)
	usable_height := math.max(0, area.height - padding.bottom - padding.top)
	if usable_height == 0 {
		fmt.printfln("Not enough vertical space to draw paragraph widget")
		return false
	}

	// Bonus padding only necessary for vertical align
	extra_padding := _paragraph_widget_calc_extra_height_padding(
		widget,
		area,
		runes,
		usable_height,
	)

	for y in (padding.top + extra_padding) ..< area.height - padding.bottom {
		new_rune_idx, should_continue := _paragraph_widget_render_row(
			widget,
			buffer,
			area,
			runes,
			y,
			i,
		)
		i = new_rune_idx
		if (!should_continue) {
			break
		}
	}


	return true
}

_paragraph_widget_calc_extra_height_padding :: proc(
	widget: ParagraphWidget,
	area: Area,
	runes: []rune,
	usable_height: u16,
) -> u16 {
	if (widget.style.vertical_alignment == .BEGIN) {
		return 0
	}

	padding := widget.style.padding
	possible_runes_per_row := area.width - padding.right - padding.left
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
	area: Area,
	runes: []rune,
	y: u16,
	rune_idx: int,
) -> (
	new_rune_idx: int,
	should_continue: bool,
) {
	i := rune_idx
	padding := widget.style.padding

	usable_width := math.max(0, area.width - padding.left - padding.right)
	if usable_width == 0 {
		fmt.printfln("Not enough horizontal space to draw paragraph widget")
		return i, false
	}
	extra_padding := _paragraph_widget_calc_extra_width_padding(widget, runes, usable_width, i)

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
