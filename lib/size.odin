package ort

SizeFitContent :: struct {}
SizeMax :: distinct u16
SizeFixed :: distinct u16
SizeMin :: distinct u16
SizeBetween :: struct {
	min: u16,
	max: u16,
}
SizePercentageMax :: distinct f32

Size :: union #no_nil {
	SizeFitContent,
	SizeMax,
	SizeMin,
	SizeBetween,
	SizePercentageMax,
}

WidgetDimensions :: [2]Size

WidgetBounds :: struct {
	max_w: u16,
	max_h: u16,
	min_w: u16,
	min_h: u16,
}

size_get_max :: proc(size: Size, outer_max: u16) -> Maybe(u16) {
	switch s in size {
	case SizeFitContent, SizeMin:
		return nil
	case SizeMax:
		return u16(s)
	case SizeBetween:
		return s.max
	case SizePercentageMax:
		return u16(f32(s) * f32(outer_max))
	}

	return nil
}

size_get_min :: proc(size: Size) -> Maybe(u16) {
	switch s in size {
	case SizeFitContent, SizeMax:
		return nil
	case SizeMin:
		return u16(s)
	case SizeBetween:
		return s.min
	case SizePercentageMax:
		return nil
	}

	return nil
}

wd_get_bounds :: proc(wd: WidgetDimensions, area: Area) -> WidgetBounds {
	return WidgetBounds {
		min_w = size_get_min(wd.x).? or_else 0,
		min_h = size_get_min(wd.y).? or_else 0,
		max_w = size_get_max(wd.x, area.width).? or_else area.width,
		max_h = size_get_max(wd.y, area.height).? or_else area.height,
	}
}

wd_usable_area :: proc(wd: WidgetDimensions, area: Area) -> Area {
	bounds := wd_get_bounds(wd, area)

	return Area{x = area.x, y = area.y, width = bounds.max_w, height = bounds.max_h}
}
