module terasort {
    use List;
    use qsort;
    use terarec;
    use Time;

    proc my_swap(ref keys, indx_a: int(64), indx_b: int(64)) {
        var tmp_key: [1..10] uint(8);

        for i in 1..10 {
            keys[indx_a, i] <=> keys[indx_b, i];
        }

        return;
    }

    proc my_qsort(ref keys, start: int(64), end: int(64)) {
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
                    my_swap(keys, mid, low);
                }
                if kv_tera_compare(keys, high, mid) < 0 {
                    my_swap(keys, high, mid);
                }
                if kv_tera_compare(keys, mid, low) < 0 {
                    my_swap(keys, mid, low);
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
                        my_swap(keys, left, right);
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
            my_swap(keys, tmp_index, low);
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
                    my_swap(keys, traverse_index, traverse_index - 1);
                    traverse_index -= 1;
                }

            }
            run_index += 1;
        }
        return;
    }

    proc get_samples(ref keys, start: int(64), end: int(64), ref samples) {
        var step: int(64) = ((end - start + 1) - (numLocales - 1)) / numLocales;  // TODO:
        var idx: int(64) = start;
        var sample_s: int(64) = here.id * (numLocales - 1) + 1;
        var sample_e: int(64) = (here.id + 1) * (numLocales - 1);

        for i in sample_s..sample_e {
            idx += step;
            samples[i, ..] = keys[idx, ..];
            idx += 1;
        }
    }

    proc get_splitters(ref samples, ref splitters, size: int(64)) {
        var step: int(64) = (size - (numLocales - 1)) / numLocales;  // TODO:
        var idx: int(64) = 1;

        // writeln("Splitters:");

        for i in 1..(numLocales - 1) {
            idx += step;
            splitters[i, ..] = samples[idx, ..];
            // writeln(idx, " ", samples[idx, 1]);
            idx += 1;
        }
    }

    proc partition(ref keys, ref values, start: int(64), end: int(64), ref splitters, ref sizes, ref idxes) {
        var i: int(64) = start;
        var j: int(64) = 1;

        idxes[here.id, j - 1] = start;
        sizes[here.id, j - 1] = 0;

        while (i <= end) && (j <= (numLocales - 1)) {  // TODO: binary search
            if kv_ref_tera_compare(keys[i, ..], splitters[j, ..]) < 0 {
                sizes[here.id, j - 1] += 1;
                i += 1;
            }
            else {
                j += 1;
                idxes[here.id, j - 1] = i;
                sizes[here.id, j - 1] = 0;
            }
        }
        while i <= end {
            sizes[here.id, j - 1] += 1;
            i += 1;
        }
    }

    proc exchange(ref keys, ref values, ref sizes, ref idxes, ref keys_out, ref values_out, ref counts_out) {
        var size: int(64);
        var start: int(64);
        var idx: int(64) = 1;

        counts_out[here.id] = 0;

        for i in 0..(numLocales - 1) {
            size = sizes[i, here.id];
            if 0 == size {
                continue;
            }

            start = idxes[i, here.id];
            counts_out[here.id] += size;

            for j in start..(start + size - 1) {
                keys_out[here.id, idx, ..] = keys[j, ..];
                values_out[here.id, idx, ..] = values[j, ..];
                // writeln(here.id, " before final sort: ", keys_out[here.id, idx, ..]);
                idx += 1;
            }

        }
    }

    proc terasort(ref keys, ref values, ref keys_out, ref values_out, ref counts_out) {
        var timer: Timer;

        var sample_size: int(64) = (numLocales - 1) * numLocales;
        var samples: [1..sample_size, 1..10] uint(8);

        var splitters: [1..(numLocales - 1), 1..10] uint(8);

        var sizes: [0..(numLocales - 1), 0..(numLocales - 1)] int(64);
        var idxes: [0..(numLocales - 1), 0..(numLocales - 1)] int(64);

        coforall loc in Locales {
            on loc do {
                var start: int(64) = keys.localSubdomain().dim(0).first;
                var end: int(64) = keys.localSubdomain().dim(0).last;
                
                // local sort
                kv_qsort(keys, values, start, end);

                // select p - 1 samples
                get_samples(keys, start, end, samples);
            }
        }

        // for i in 1..sample_size {
        //     writeln("samples before sort: ", samples[i, 1]);
        // }

        // Sort samples
        my_qsort(samples, 1, sample_size);
        // for i in 1..samples.dim(0).size {
        //     writeln("samples after sort: ", samples[i, 1]);
        // }

        // Select p - 1 splitters
        get_splitters(samples, splitters, sample_size);

        coforall loc in Locales {
            on loc do {
                var start: int(64) = keys.localSubdomain().dim(0).first;
                var end: int(64) = keys.localSubdomain().dim(0).last;

                // partition using splitters
                partition(keys, values, start, end, splitters, sizes, idxes);
            }
        }

        coforall loc in Locales {
            on loc do {
                // exchange values
                exchange(keys, values, sizes, idxes, keys_out, values_out, counts_out);

                // local sort
                kv_qsort(keys_out[here.id, .., ..], values_out[here.id, .., ..], 1, counts_out[here.id]);  // TODO:
                // for i in 1..counts_out[here.id] {
                //     writeln(here.id, " after final sort: ", keys_out[here.id, i, 1]);
                // }
            }
        }

        return;
    }

}