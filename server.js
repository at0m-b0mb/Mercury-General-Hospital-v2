const express = require('express');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = process.env.PORT || 80;

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, 'public')));

// Load data files
const patients = JSON.parse(fs.readFileSync(path.join(__dirname, 'data', 'patients.json'), 'utf8'));
const securityLogs = JSON.parse(fs.readFileSync(path.join(__dirname, 'data', 'security_logs.json'), 'utf8'));
const prescriptions = JSON.parse(fs.readFileSync(path.join(__dirname, 'data', 'prescriptions.json'), 'utf8'));
const users = JSON.parse(fs.readFileSync(path.join(__dirname, 'data', 'users.json'), 'utf8'));

// ============================================================
// ROUTES - Public Pages
// ============================================================

app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.get('/portal', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'portal.html'));
});

app.get('/login', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'login.html'));
});

// ============================================================
// FLAG 3 - "The Dental Record"
// Vulnerability: SQL-injection-style weak authentication + direct patient ID enumeration
// The login accepts admin/admin OR any ' OR '1'='1 style input
// Patient records are accessible by iterating patient IDs
// ============================================================

app.post('/api/login', (req, res) => {
    const { username, password } = req.body;

    // Intentionally vulnerable: simulates SQL injection bypass
    // Accepts: admin/admin OR any input containing ' OR ' (SQL injection pattern)
    const sqlInjectionPattern = /('|\bOR\b)/i;

    if ((username === 'admin' && password === 'admin') ||
        sqlInjectionPattern.test(username) ||
        sqlInjectionPattern.test(password)) {
        return res.json({
            success: true,
            message: 'Login successful',
            token: 'mercury_session_a3f8b2c1',
            redirect: '/dashboard'
        });
    }

    // Weak credentials hint: the error message leaks the username format
    res.status(401).json({
        success: false,
        message: 'Invalid credentials. Hint: Default hospital credentials may not have been changed.'
    });
});

app.get('/dashboard', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'dashboard.html'));
});

app.get('/appointments', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'appointments.html'));
});

// Admin panel — hinted at in robots.txt; reveals security misconfigurations
app.get('/admin', (req, res) => res.redirect('/admin/'));
app.get('/admin/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'admin', 'index.html'));
});

// Patient records endpoint - vulnerable to ID enumeration
app.get('/api/patients', (req, res) => {
    // Return patient list (names only, no sensitive data)
    const patientList = patients.map(p => ({
        id: p.id,
        name: p.name,
        admission_date: p.admission_date
    }));
    res.json(patientList);
});

// Individual patient record - FLAG 3 is in patient ID 3 (Stu Price)
app.get('/api/patients/:id', (req, res) => {
    const patientId = parseInt(req.params.id);
    const patient = patients.find(p => p.id === patientId);

    if (!patient) {
        return res.status(404).json({ error: 'Patient not found' });
    }

    res.json(patient);
});

// ============================================================
// FLAG 4 - "The Security Footage"
// Vulnerability: Directory traversal + hidden log files
// Security logs are in a "hidden" endpoint and a backup log file
// ============================================================

// Public security page (decoy - limited info)
app.get('/api/security/cameras', (req, res) => {
    res.json({
        cameras: [
            { id: 1, location: 'Main Entrance', status: 'online' },
            { id: 2, location: 'Emergency Room', status: 'online' },
            { id: 3, location: 'Parking Lot A', status: 'offline' },
            { id: 4, location: 'Parking Lot B', status: 'online' },
            { id: 5, location: 'Rear Loading Dock', status: 'maintenance' }
        ],
        message: 'Note: Full footage logs available at /security/logs/'
    });
});

// Hidden security logs endpoint - directory listing
app.get('/security/logs/', (req, res) => {
    res.json({
        files: [
            'camera_01_main_entrance.log',
            'camera_02_emergency_room.log',
            'camera_03_parking_lot_a.log',
            'camera_04_parking_lot_b.log',
            'camera_05_rear_loading_dock.log',
            '.backup_camera_04_full.log'
        ],
        note: 'Backup files contain unedited footage data'
    });
});

// Individual log files
app.get('/security/logs/:filename', (req, res) => {
    const filename = req.params.filename;

    const logFiles = {
        'camera_01_main_entrance.log': securityLogs.camera_01,
        'camera_02_emergency_room.log': securityLogs.camera_02,
        'camera_03_parking_lot_a.log': securityLogs.camera_03,
        'camera_04_parking_lot_b.log': securityLogs.camera_04,
        'camera_05_rear_loading_dock.log': securityLogs.camera_05,
        '.backup_camera_04_full.log': securityLogs.backup_camera_04_full
    };

    if (logFiles[filename]) {
        res.type('text/plain').send(logFiles[filename]);
    } else {
        res.status(404).send('Log file not found');
    }
});

// Directory traversal vulnerability - can read files outside intended directory
app.get('/api/files', (req, res) => {
    const requestedFile = req.query.file;
    if (!requestedFile) {
        return res.json({ error: 'Please specify a file parameter' });
    }

    // Intentionally vulnerable: no path sanitization
    const filePath = path.join(__dirname, 'data', requestedFile);
    try {
        const content = fs.readFileSync(filePath, 'utf8');
        res.type('text/plain').send(content);
    } catch (err) {
        res.status(404).json({ error: 'File not found' });
    }
});

// ============================================================
// FLAG 5 - "The Prescription"
// Vulnerability: Hidden encoded prescription + Base64/ROT13 decoding
// ============================================================

// Prescriptions endpoint - public (decoy prescriptions)
app.get('/api/prescriptions', (req, res) => {
    res.json(prescriptions.public_prescriptions);
});

// Hidden prescription endpoint (hinted in HTML comments and robots.txt)
app.get('/api/prescriptions/hidden', (req, res) => {
    res.json(prescriptions.hidden_prescription);
});

// robots.txt - hints at hidden directories
app.get('/robots.txt', (req, res) => {
    res.type('text/plain').send(
        `User-agent: *
Disallow: /security/logs/
Disallow: /api/prescriptions/hidden
Disallow: /backup/
Disallow: /admin/

# Note: Prescription backup contains encoded patient coordinates
# Encoding: Base64 > ROT13
`
    );
});

// Backup directory hint
app.get('/backup/', (req, res) => {
    res.json({
        files: [
            'patient_db_backup_2024.sql',
            'prescription_encoded.txt',
            'system_config.bak'
        ]
    });
});

app.get('/backup/prescription_encoded.txt', (req, res) => {
    res.type('text/plain').send(prescriptions.encoded_file);
});

app.get('/backup/system_config.bak', (req, res) => {
    res.type('text/plain').send(fs.readFileSync(path.join(__dirname, 'data', 'system_config.bak'), 'utf8'));
});

// ============================================================
// Hint endpoints
// ============================================================

app.get('/api/hint', (req, res) => {
    res.json({
        hints: [
            'The patient portal uses default credentials...',
            'Security cameras have backup logs that weren\'t cleaned up',
            'Check robots.txt for hidden paths',
            'Some prescriptions contain more than medicine dosages',
            'Backup files often contain unredacted information'
        ]
    });
});

// ============================================================
// 404 handler — must be the last route registered
// ============================================================
app.use((req, res) => {
    res.status(404).sendFile(path.join(__dirname, 'public', '404.html'));
});

// Start server
app.listen(PORT, () => {
    const url = `http://localhost:${PORT}`;
    const urlLine = `║  Server running on: ${url}`.padEnd(63) + '║';
    console.log(`
╔══════════════════════════════════════════════════════════════╗
║           Mercury General Hospital - Patient Portal          ║
║                    CTF Machine 2 (3 Flags)                   ║
╠══════════════════════════════════════════════════════════════╣
${urlLine}
║                                                              ║
║  FLAGS:                                                      ║
║  FLAG 3 - The Dental Record (Patient Records)                ║
║  FLAG 4 - The Security Footage (Camera Logs)                 ║
║  FLAG 5 - The Prescription (Encoded Coordinates)             ║
╚══════════════════════════════════════════════════════════════╝
    `);
});

module.exports = app;
