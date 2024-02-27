# Apache Log File Processor

This Bash script is crafted to analyze Apache web server log files, executing various operations based on the supplied input parameters. It provides the capability to display unique HTTP response codes, enumerate days without any server access, tally GET/POST requests that resulted in a 200 response, and compile a summary of the total data transmitted in KiB.

## Prerequisites

Before you can run this script, ensure you have the following:

- Bash shell, tested on GNU Bash version 4.4.20 or newer.
- Access to a Unix-like operating system, such as Linux or macOS.
- A log file from an Apache web server, adhering to the following format: `IP Address - - [Date Time Zone] "GET/POST URL" Response Bytes Sent`.

## Features

The script supports the following flags and functionalities:

- `-c`: Lists all unique HTTP response codes found in the log file, without duplicates.
- `-t`: Calculates the number of days with no access to the server, from the first to the last logged access.
- `GET/POST`: Counts the total number of GET or POST requests with a 200 OK response, displaying the tally.
- `-s`: Provides a summary of the total data transferred, in kilobytes (KiB), based on the log file.

## Usage

To use this script, follow the syntax given below:

```
./access.sh [-c | GET/POST | -s] /path/to/apache/logfile/access.log
```

Please note that the script requires exactly two arguments to function correctly. If this condition is not met, it will terminate with an error message and a usage example. Additionally, ensure that the log file specified as the second argument is a regular file with read permissions. Failure to meet these requirements will also result in an error message and a usage example.

## Examples

To display unique HTTP response codes from the log file:


```
./access.sh -c /path/to/apache/logfile/access.log
```

To find out how many days had no server access recorded:

```
./access.sh -t /path/to/apache/logfile/access.log
```

To count the number of GET requests with a 200 OK response:


```
./access.sh GET /path/to/apache/logfile/access.log
```

For a summary of the total data sent in KiB:

```
./access.sh -s /path/to/apache/logfile/access.log
```

# Note

The access.log file provided on the Virtual Campus serves as an example log file. This script is designed to be compatible with any Apache log file that conforms to the aforementioned format.

Replace `/path/to/apache/logfile/access.log` with the actual path to your log file when employing the script. This document is ready to be included in your GitHub repository, offering clear instructions and insights into the functionality of your Apache log file processor script.

