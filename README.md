# kulko_reporter
This is a reporter shell script that was created according with the book "The Linux Command Line" by William E. Shots

# Usage
To execute the script type, for basic and interactive usage use:
```bash
./reporter.sh -i
```
You can also pass a path directly into the script
```bash
./reporter.sh -f /path/to/file.html
```
To be extra sure to not overwrite anything one can use a combination of `-i` and `-f`
```bash
./reporter.sh -f /path/to/file.html -i
```
That way a friendly prompt will ask you for your next action:
```txt
Provided file already exists. Overwrite? [y/n/q] 
```
If `n` option is choosen, a file will be generated but under a generic name _system_report_YYYYMMDDHHmmSS.html_ ensuring no files will be lost.