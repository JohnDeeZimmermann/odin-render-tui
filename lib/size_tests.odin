package ort

import "core:testing"

@(test)
test_wd_get_bounds :: proc(t: ^testing.T) {
	area := Area {
		width  = 10,
		height = 10,
	}


	wd_1 := [2]Size{SizeFitContent{}, SizeFitContent{}}
	area_1 := wd_usable_area(wd_1, area)

	wd_2 := [2]Size{SizeMax(5), SizeMin(5)}
	area_2 := wd_usable_area(wd_2, area)

	testing.expect_value(t, area_1.width, 10)
	testing.expect_value(t, area_1.height, 10)
	testing.expect_value(t, area_2.width, 5)
	testing.expect_value(t, area_2.height, 10)
}
