# 🛠️ Shell Scripts for System Operations

This repository contains a collection of Bash shell scripts designed for various system operation tasks, including data processing 📊, file organization 📁, and system analysis 🧐. Below is an overview of each script and its functionality.

## 📑 Scripts Overview

### 1. `optativo.sh` - Simulation Data Processor 📈

This script processes simulation results from Monte Carlo simulations of field-effect transistors (FETs) 🖥️ and extracts specific data points for analysis. It reads simulation output files, extracts the drain current at a specific flight time, and calculates the average current across simulations.

**Features:**
- Extracts current data for a predefined flight time from simulation files 🔍.
- Calculates the average current and outputs the result 📉.
- Generates a filtered data file with simulation IDs, flight times, and corresponding currents 📝.

### 2. `conferencia.sh` - Conference Video Organizer 📹

Designed to organize conference video files into structured directories based on the video metadata (room number, date, and resolution) extracted from file names. It also renames the video files according to a specified format.

**Features:**
- Automatically creates directory structures based on video metadata 🗂️.
- Renames and organizes video files into their respective directories 🔄.

### 3. `scriptFiltro.sh` - System Users Comparison Script 👥

This script processes a copy of the `passwd` file, sorts it, removes duplicates, and compares it to the system's current `/etc/passwd` file to check for differences.

**Features:**
- Sorts and deduplicates a copy of the `passwd` file 🗃️.
- Compares the processed file with the system's `/etc/passwd` 🔍.
- Outputs the result of the comparison 📊.

### 4. `accesos.sh` - Web Server Log Analyzer 🌐

Analyzes web server access logs to extract and report various metrics, such as request counts by type (GET/POST), response codes distribution, and site access statistics.

**Features:**
- Filters access logs based on request types and response codes 🔎.
- Calculates and reports website access statistics 📈.
- Supports multiple analysis options through command-line arguments 🛠️.

## 🚀 Getting Started

To use these scripts, clone this repository to your local machine or server where you want to perform the operations. Ensure you have the necessary permissions to execute the scripts and access the files or directories involved.

```
git clone https://github.com/yourusername/your-repository-name.git
cd your-repository-name
```

Make sure to mark the scripts as executable:
```
chmod +x *.sh
```

## 📖 Usage

Here is a quick example of how to run each script. Replace [options] with any specific arguments required by the script.
```
./optativo.sh [simulation_directory]
./conferencia.sh [source_directory] [destination_directory]
./archivo_passwd_processor.sh
./accesos.sh [option] [log_directory]
```

## 💡 Contributing

Contributions to improve or extend the functionality of these scripts are welcome. Please feel free to fork the repository, make your changes, and submit a pull request 🤝.

## ✍️ Authors

- Javier Pereira
- Pablo Seijo
