# kulko_reporter
This is a reporter shell script that was created according with the book "The Linux Command Line" by William E. Shots

# Usage
To execute the script for basic and interactive usage use:
```bash
./kreport.sh -i
```
You can also pass a path directly into the script
```bash
./kreport.sh -f /path/to/file.html
```
To be extra sure to not overwrite anything one can use a combination of `-i` and `-f`
```bash
./kreport.sh -f /path/to/file.html -i
```
That way a friendly prompt will ask you for your next action:
```txt
Provided file already exists. Overwrite? [y/n/q] 
```
If `n` option is choosen, a file will be generated but under a generic name *system_report_YYYYMMDDHHmmSS.html* ensuring no files will be lost.

# Extra
In the extra folder one can find `loan_shark.sh`, this is a simple interactive calculator utilizing `bc` to calculate annunity formula. The annunity formula was directly taken from the [Wikipedia Page](https://en.wikipedia.org/wiki/Amortization_calculator).

## Usage
There are both `-i` for interactive mode, and positional argument mode. Unlike `kreport.sh` this script will not output anything into a file, rather it outputs its result into `stdout`.
```bash
./loan_shark.sh -p <int> -r <int> -n <int>
```
### Sample
```bash
./loan_shark.sh -p 250000 -r 0.07 -n 360
Calculation values={p=250000 i=0.07 n=360}
You shall ensure monthly payments of:
1663.26
```
The output is designed that way, so that the user can easliy manipulate the `stdout` for ones' liking, using different pipelines or redirections. An example pipeline would be to only output the final result into a file nammed `result.txt`
```bash
./loan_shark.sh -p 250000 -r 0.07 -n 360 | tail -n 1 > result.txt
```

For interactive mode, one can use the same schema as with the `kreport.sh`, by providing only `-i`. However unlike the `kreport.sh` the user is not allowed to provide any other value, rather this option is mutualy exclusive with any other. Thus the final execution shall look like this:
```bash
./loan_shark.sh -i
```
