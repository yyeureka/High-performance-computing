use Time;
use BlockDist;
use Barriers;
use terarec;
use terasort;
use Sort;
use IO;

config const f: string = "data.dat";
const data_filename: string = f;
const data_out_filename: string = f;
config const runcount = 10;

proc teravalidate(ref keys, ref counts) {
    var sorted_array: [0..numLocales-1] bool;
    for val in sorted_array {
        val = false;
    }

    coforall loc in Locales{
        on loc do {
            var block_sorted: bool = tera_is_sorted(keys, counts);
            var blocks_ordered: bool = true;
            if here.id > 0 {
                var prev_last: [1..10] uint(8) = keys[here.id - 1, counts[here.id - 1], 1..10];
                var curr_first: [1..10] uint(8) = keys[here.id, 1, 1..10];
                ref prev_last_ref = prev_last;
                ref curr_first_ref = curr_first;
                if kv_ref_tera_compare(prev_last_ref, curr_first_ref) > 0 {
                    blocks_ordered = false;
                }
            }
            
            sorted_array[here.id] = blocks_ordered && block_sorted;
        }
    }

    for val in sorted_array {
        if val == false {
            return false;
        }
    }

    return true;
}

proc main() {

    var recs_in_file: int(64) = terarec.teraRecsInFile(data_filename);
    var runtimes: [1..runcount] real(64);
    var inputTargetLocales = reshape(Locales, {1..Locales.size, 1..1});

    const keySpace = {1..recs_in_file, 1..10};
    const keyBlockSpace = keySpace dmapped Block(keySpace, targetLocales=inputTargetLocales);
    var keys: [keyBlockSpace] uint(8);
    var keys_backup: [keyBlockSpace] uint(8);
    ref keys_ref = keys;

    const valueSpace = {1..recs_in_file, 1..88};
    const valueBlockSpace = valueSpace dmapped Block(valueSpace, targetLocales=inputTargetLocales); 
    var values: [valueBlockSpace] uint(8);
    var values_backup: [valueBlockSpace] uint(8);
    ref values_ref = values;

    var outputTargetLocales = reshape(Locales, {1..Locales.size, 1..1, 1..1});

    const keyOutSpace = {0..(numLocales-1), 1..recs_in_file, 1..10};
    const keyOutBlockSpace = keyOutSpace dmapped Block(keyOutSpace, outputTargetLocales);
    var keys_out: [keyOutBlockSpace] uint(8);
    ref keys_out_ref = keys_out;

    const valueOutSpace = {0..(numLocales-1), 1..recs_in_file, 1..88};
    const valueOutBlockSpace = valueOutSpace dmapped Block(valueOutSpace, outputTargetLocales);
    var values_out: [valueOutBlockSpace] uint(8);
    ref values_out_ref = values_out;

    const countSpace = {0..(numLocales-1)};
    const countBlockSpace = countSpace dmapped Block(boundingBox = countSpace);
    var counts_out: [countBlockSpace] int(64);
    ref counts_out_ref = counts_out;

    terarec.read_share_of_data(data_filename=data_filename, keys = keys_ref, values = values_ref);

    forall i in 1..recs_in_file {
        on keys[i, 1] do {
            for j in 1..10 {
                keys_backup[i, j] = keys[i, j];
            }

            for j in 1..88 {
                values_backup[i, j] = values[i, j];
            }
        }
    }

    for run_num in 1..runcount {

        var start_time: real(64) = getCurrentTime(unit=TimeUnits.seconds);

        terasort(keys = keys_ref, values = values_ref, keys_out = keys_out_ref, values_out = values_out_ref, counts_out = counts_out_ref);

        var end_time: real(64) = getCurrentTime(unit=TimeUnits.seconds);
        var elapsed_time: real(64) = end_time - start_time;

        if teravalidate(keys_out_ref, counts_out_ref) == false {
            stderr.writeln("Solution had invalid results on loop iteration: ", run_num);
            exit(1);
        }

        runtimes[run_num] = elapsed_time;

        forall i in 1..recs_in_file {
            on keys[i, 1] do {
                for j in 1..10 {
                    keys[i, j] = keys_backup[i, j];
                }

                for j in 1..88 {
                    values[i, j] = values_backup[i, j];
                }
            }
        }
    }

    var real_comp: real_comparator;

    sort(runtimes, comparator=real_comp);

    var tmp: real(64);

    if runcount % 2 == 0 {
        tmp = (runtimes[runcount/2 + 1] + runtimes[runcount/2]) / 2.0;
    } else {
        tmp = runtimes[runcount/2 + 1];
    }

    writeln("Median time over ", runcount, " runs: ", tmp);
}
