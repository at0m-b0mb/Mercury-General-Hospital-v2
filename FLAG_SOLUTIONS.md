# Flag Solutions — Mercury General Hospital CTF (Machine 2)

> **⚠️ INSTRUCTOR/ADMIN USE ONLY — Contains full flag answers and exploitation steps.**

---

## FLAG 3 — "The Dental Record"

**Flag value:** `FLAG{dental_record_stu_2_47_am}`

### Story context
Stu Price arrived at Mercury General Hospital at 2:47 AM having voluntarily extracted his own molar "to prove his love." He was dropped off by a short angry Asian man who identified himself as Mr. Chow. The medical record documents this.

### Vulnerability
- **Type:** Weak Authentication + Patient ID Enumeration
- **Affected endpoint:** `POST /api/login`, `GET /api/patients/:id`

### Exploitation

**Step 1 — Bypass login:**
```
Username: admin
Password: admin
```
OR inject via SQL-injection-style pattern:
```
Username: ' OR '1'='1
Password: anything
```

**Step 2 — Enumerate patient records:**
```
GET http://localhost/api/patients
```
Returns list of 5 patients. Patient #3 is Stuart Price.

**Step 3 — Read patient #3:**
```
GET http://localhost/api/patients/3
```

The `notes` field contains the flag:
> "Patient arrived at 2:47 AM with a freshly extracted molar. Patient claims he VOLUNTARILY pulled his own tooth 'to prove his love'... dropped off by a SHORT ANGRY ASIAN MAN who identified himself only as 'Mr. Chow'... `FLAG{dental_record_stu_2_47_am}`"

---

## FLAG 4 — "The Security Footage"

**Flag value:** `FLAG{security_footage_mercedes_3_15_am}`

### Story context
Security camera footage from Parking Lot B (camera 04) shows Phil, Stu, Alan, and Mr. Chow loading something heavy into a Mercedes trunk at 3:15 AM. The license plate `NV-CHOW-88` is captured and traces to Mr. Chow's warehouse.

### Vulnerability
- **Type:** Directory Listing + Hidden File Discovery (dot-prefixed backup file)
- **Affected endpoints:** `GET /security/logs/`, `GET /security/logs/.backup_camera_04_full.log`

### Exploitation

**Step 1 — Discover via robots.txt:**
```
GET http://localhost/robots.txt
```
Output includes:
```
Disallow: /security/logs/
```

**Step 2 — List log directory:**
```
GET http://localhost/security/logs/
```
Response lists all files including:
```json
".backup_camera_04_full.log"
```

**Step 3 — Access the hidden backup log:**
```
GET http://localhost/security/logs/.backup_camera_04_full.log
```

The backup log contains the unredacted footage entry at timestamp 03:15:00 with the flag.

**Note:** The normal `camera_04_parking_lot_b.log` has the critical footage `[REDACTED BY ADMIN]`. The backup file skips this redaction.

---

## FLAG 5 — "The Prescription"

**Flag value:** `FLAG{prescription_warehouse_coordinates}`

### Story context
A hidden prescription backup file contains coordinates encoded in Base64. When decoded, they reveal the location of Mr. Chow's warehouse — the next target.

### Vulnerability
- **Type:** Information Disclosure + Encoding/Decoding Challenge (Base64)
- **Affected endpoints:** `GET /backup/prescription_encoded.txt`, `GET /api/prescriptions/hidden`

### Exploitation

**Step 1 — Discover via robots.txt:**
```
GET http://localhost/robots.txt
```
Output includes:
```
Disallow: /backup/
Disallow: /api/prescriptions/hidden
# Prescription backup contains encoded patient coordinates
# Encoding: Base64 > ROT13
```

**Step 2 — List backup directory:**
```
GET http://localhost/backup/
```
Response lists `prescription_encoded.txt`.

**Step 3 — Read the encoded file:**
```
GET http://localhost/backup/prescription_encoded.txt
```
Contains:
```
ENCODED PAYLOAD (Base64):
RkxBR3twcmVzY3JpcHRpb25fd2FyZWhvdXNlX2Nvb3JkaW5hdGVzfQ==
```

**Step 4 — Decode Base64:**
```bash
echo "RkxBR3twcmVzY3JpcHRpb25fd2FyZWhvdXNlX2Nvb3JkaW5hdGVzfQ==" | base64 -d
```
**Result:** `FLAG{prescription_warehouse_coordinates}`

**Windows PowerShell alternative:**
```powershell
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("RkxBR3twcmVzY3JpcHRpb25fd2FyZWhvdXNlX2Nvb3JkaW5hdGVzfQ=="))
```

**Alternative path:** Access `GET /api/prescriptions/hidden` directly for the `encoded_coordinates` JSON field.

---

## Narrative Progression

After solving all 3 flags, players learn:
1. **FLAG 3** — Stu pulled his own tooth at 2:47 AM and was dropped off by Mr. Chow
2. **FLAG 4** — All four (Phil, Stu, Alan, Mr. Chow) loaded something heavy into a Mercedes trunk at 3:15 AM. License plate `NV-CHOW-88` → registered to Mr. Chow at 1547 Industrial Blvd, Las Vegas, NV
3. **FLAG 5** — Hidden prescription encodes coordinates: `36.1156 N, -115.1734 W` → Mr. Chow's Warehouse, 1547 Industrial Blvd, Las Vegas, NV 89101

This leads to **Machine 3: Mr. Chow's Server** at the warehouse address.
