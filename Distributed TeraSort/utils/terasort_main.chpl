use IO;
use terarec;
use BlockDist;
use terasort;
import Sort;

config const f: string = "data.dat";
config const o: string = f;
const data_filename: string = f;
const data_out_filename: string = o;

proc main() {

    var recs_in_file: int(64) = terarec.teraRecsInFile(data_filename);
    var inputTargetLocales = reshape(Locales, {1..Locales.size, 1..1});

    const keySpace = {1..recs_in_file, 1..10};
    const keyBlockSpace = keySpace dmapped Block(keySpace, targetLocales=inputTargetLocales);
    var keys: [keyBlockSpace] uint(8);
    ref keys_ref = keys;

    const valueSpace = {1..recs_in_file, 1..88};
    const valueBlockSpace = valueSpace dmapped Block(valueSpace, targetLocales=inputTargetLocales); 
    var values: [valueBlockSpace] uint(8);
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
    terasort(keys = keys_ref, values = values_ref, keys_out = keys_out_ref, values_out = values_out_ref, counts_out = counts_out_ref);
    write_share_of_data(data_filename = data_out_filename, keys = keys_out_ref, values = values_out_ref, counts = counts_out_ref);

}
