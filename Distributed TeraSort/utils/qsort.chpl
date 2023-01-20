// this module provides a version of qsort adapted to work in Chapel over arbitrary arrays.
// based on https://code.woboq.org/userspace/glibc/stdlib/qsort.c.html

module qsort {
    use terarec;
    use List;
    
    const BASE_SORT = 4; // following the stdlib qsort, insertion sort under 4

    proc kv_swap(ref keys, ref values, indx_a: int(64), indx_b: int(64)) {
        var tmp_key: [1..10] uint(8);
        var tmp_value: [1..88] uint(8);

        for i in 1..10 {
            keys[indx_a, i] <=> keys[indx_b, i];
        }
        for i in 1..88 {
            values[indx_a, i] <=> values[indx_b, i];
        }

        return;
    }

    proc kv_qsort(ref keys, ref values, start: int(64), end: int(64)) {
        var stack: list((int(64), int(64)));
        var low: int(64) = start;
        var high: int(64) = end;
        var size: int(64) = end - start + 1;

        stack.append((-1, -1));

        if size > BASE_SORT {
            var left: int(64);
            var right: int(64);
            var mid: int(64);

            while stack.size > 0 {

                mid = (low + high) >> 1;
                if kv_tera_compare(keys, mid, low) < 0 {
                    kv_swap(keys, values, mid, low);
                }
                if kv_tera_compare(keys, high, mid) < 0 {
                    kv_swap(keys, values, high, mid);
                }
                if kv_tera_compare(keys, mid, low) < 0 {
                    kv_swap(keys, values, mid, low);
                }

                left = low + 1;
                right = high - 1;

                do {
                    while (kv_tera_compare(keys, left, mid) < 0) && (left <= high) {
                        left += 1;
                    }
                    while (kv_tera_compare(keys, mid, right) < 0) && (right >= low) {
                        right -= 1;
                    }

                    if left < right {
                        kv_swap(keys, values, left, right);
                        if mid == left {
                            mid = right;
                        } else if mid == right {
                            mid = left;
                        }
                        left += 1;
                        right -= 1;
                    } else if left == right {
                        left += 1;
                        right -= 1;
                        break;
                    }
                } while (left <= right);

                if right - low <= BASE_SORT {
                    if high - left <= BASE_SORT {
                        var next: (int(64), int(64)) = stack.pop();
                        low = next(0);
                        high = next(1);

                    } else {
                        low = left;
                    }
                } else if high - left <= BASE_SORT {
                    high = right;
                } else if (right - low) > (high - left) {
                    stack.append((low, right));
                    low = left;
                } else {
                    stack.append((left, high));
                    high = right;
                }
            }
        }

        low = start;
        high = end;
        var tmp_index: int(64) = low;
        var run_index: int(64) = low + 1;

        for i in low+1..min(low+BASE_SORT, high) {
            if kv_tera_compare(keys, i, tmp_index) < 0 {
                tmp_index = i;
            }
        }

        if tmp_index > low {
            kv_swap(keys, values, tmp_index, low);
        }

        run_index = min(low + 2, high);
        while run_index <= high {
            tmp_index = run_index - 1;
            while (kv_tera_compare(keys, run_index, tmp_index) < 0) && (tmp_index > low) {
                tmp_index -= 1;
            }

            tmp_index += 1;
            if tmp_index != run_index {
                var traverse_index = run_index;
                while traverse_index > tmp_index {
                    kv_swap(keys, values, traverse_index, traverse_index - 1);
                    traverse_index -= 1;
                }

            }
            run_index += 1;
        }
        return;
    }
}
