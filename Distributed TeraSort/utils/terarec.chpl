module terarec{

    use IO;
    import FileSystem;
    use BlockDist;
    use CommDiagnostics;
    const terarec_key_size = 10;
    const terarec_val_size = 88;
    const terarec_width_disk: int(64) = terarec_key_size + terarec_val_size + 2; // include the newline character in the file
    const terarec_width_mem: int(64) = terarec_key_size + terarec_val_size;

    record real_comparator {
        proc key(a) {
            return a;
        }
    }

    record terarec_t {
        var key: [1..10] uint(8);
        var value: [1..88] uint(8);
    }

    proc kv_tera_compare(ref keys, idx_a: int(64), idx_b: int(64)){
        var retval: int(8);

        for i in 1..10 {
            retval = (keys[idx_a, i] : int(8)) - (keys[idx_b, i] : int(8));
            if retval != 0{
                break;
            }
        }
        return retval;
    }

    proc kv_ref_tera_compare(ref key_a, ref key_b){
        var retval: int(8);

        for i in 1..10 {
            retval = (key_a[i] : int(8)) - (key_b[i] : int(8));
            if retval != 0{
                break;
            }
        }
        return retval;
    }

    proc tera_is_sorted(ref keys, ref counts){
        var sorted: bool = true;
        ref local_keys = keys[here.id, .., ..];

        for i in 1..(counts[here.id]-1) {
            if kv_tera_compare(local_keys, i, i+1) > 0 {
                writeln(here.id, ": records not sorted: ", i, " ", i+1);
                sorted = false;
                break;
            }
        }
        return sorted;
    }

    proc teraRecsInFile(input_filename: string): int(64) throws {
        var file_size_in_bytes: int(64) = FileSystem.getFileSize(input_filename);
        var recs_in_file: int(64) = file_size_in_bytes/terarec_width_disk;

        return recs_in_file;

    }

    proc read_share_of_data(data_filename: string, ref keys, ref values) throws {
        
        coforall loc in Locales {
            on loc do {
                var data_file: file = open(data_filename, iomode.rw);
                var data_reader = data_file.reader(locking=false);
                var number_read: int(64);
                var line: [1..100] uint(8);
                const indices = keys.localSubdomain().dim(0);
                var local_start_offset = terarec.terarec_width_disk * (indices.first - 1);

                data_reader.seek(start=local_start_offset);

                for i in indices {
                    data_reader.readLine(a=line, maxSize=100);
                    for j in 1..10 {
                        keys[i, j] = line[j];
                    }

                    for j in 1..88 {
                        values[i, j] = line[10 + j];
                    }
                }
            }
        }
        return;
    }

    proc write_share_of_data(data_filename: string, ref keys, ref values, ref counts) throws {

        for loc in Locales{
            on loc do { 
                var data_file: file = open(data_filename, iomode.rw);
                var line: [1..100] uint(8);
                var local_record_offset = + reduce counts[0..here.id-1];
                var local_bytes_offset = terarec.terarec_width_disk * local_record_offset;
                var data_writer = data_file.writer(kind=ionative, locking=false, start=local_bytes_offset);

                for j in 1..counts[here.id] {
                    for i in 1..10{
                        line[i] = keys[here.id, j, i];
                    }
                    for i in 1..88 {
                        line[i + 10] = values[here.id, j, i];
                    }
                    line[99] = 13;  // \r
                    line[100] = 10;  // \n
                    data_writer.write(line);
                }
                data_writer.flush();
                data_file.fsync();
                data_writer.close();
                data_file.close();
            }
        }
        return;
    }
}
