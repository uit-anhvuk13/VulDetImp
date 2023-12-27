# VulDetImp

This is an implementation effort for [VulDetector](https://github.com/leontsui1987/VulDetector).

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/uit-anhvuk13/VulDetImp/master/setup.sh | sh
```

## Usage

Build the environment:
```bash
./build.sh
```

Run app:
```bash
./start.sh <options>
```

Interact with the app:
```bash
./exec.sh <options>
```

Stop app:
```bash
./stop.sh
```

## App

Make sure the container vuldetector is up, use the below commnds inside container

Fetch the CVE's affected software listed in DATA/CVE_App.txt:
```bash
./exec.sh cve
```

DataPrepare:
```bash
./exec.sh prepare [OPTION] [APP|VUL|PAT all|<Project>]

OPTIONS:
  --fun|-f     : Extract raw code for each function from sourcecode.
  --desc|-d    : Generate raw CFG description <ProjectDir>/tmp.log for a project.
  --cfg|-c     : Extract CFG description for each function from <ProjectDir>/tmp.log.

APP            : Extract data from a Software (/code/DATA/RAW/APP).
VUL            : Extract data from Vulnerable code (/code/DATA/RAW/VUL).
PAT            : Extract data from Patched code (/code/DATA/RAW/PAT).
all            : Process all projects in /code/DATA/RAW/{APP|VUL|PAT}.
<Project>      : Define a specific Software or Project (e.g., OpenSSL, CVE-2012-1165).

Example: ./exec.sh prepare -c -d -f APP OpenSSL \
                                    VUL CVE-2012-1165 \
                                    PAT all
```

### Default path:
- ./DATA/RAW/APP: put sourcecode of an app needs to be scanned here
- ./DATA/RAW/VUL: downloaded vulnerable software affected by specific CVE
- ./DATA/RAW/PAT: patched software versions that fix the specific CVE
- ./DATA/CVE_App.txt: list the CVEs and their affected software
- ./DATA/CVE_Fun.txt: CVEs' affected func#file code
