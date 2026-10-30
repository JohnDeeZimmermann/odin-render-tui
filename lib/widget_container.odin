package ort

ContainerWidget :: struct {
	padding:        Padding,
	children:       []Widget,
	grow_direction: Direction,
}

container_widget_render :: proc(
	widget: ContainerWidget,
	buffer: ^Buffer,
	area: Area,
	allocator := context.allocator,
) -> (
	ok: bool,
) {
	for child in widget.children {
		render_ok := widget_render_any(child, area, buffer, allocator)
		if (!render_ok) {
			return false
		}
	}

	return
}
