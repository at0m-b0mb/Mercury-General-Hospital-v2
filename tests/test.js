// Mercury General Hospital CTF - Automated Tests
// Run with: node tests/test.js
// Optionally set PORT env var: PORT=3000 node tests/test.js

const http = require('http');

const PORT = parseInt(process.env.PORT || '80', 10);

let passed = 0;
let failed = 0;

function request(options, body = null) {
    return new Promise((resolve, reject) => {
        const req = http.request(options, (res) => {
            let data = '';
            res.on('data', chunk => data += chunk);
            res.on('end', () => {
                try { resolve({ status: res.statusCode, body: JSON.parse(data), raw: data }); }
                catch { resolve({ status: res.statusCode, body: null, raw: data }); }
            });
        });
        req.on('error', reject);
        if (body) req.write(body);
        req.end();
    });
}

function assert(condition, testName) {
    if (condition) {
        console.log(`  ✅ PASS: ${testName}`);
        passed++;
    } else {
        console.log(`  ❌ FAIL: ${testName}`);
        failed++;
    }
}

function opts(path, method = 'GET') {
    return { hostname: 'localhost', port: PORT, path, method };
}

async function runTests() {
    console.log(`\n🏥 Mercury General Hospital CTF - Test Suite (port ${PORT})\n`);

    // ---- FLAG 3 Tests ----
    console.log('--- FLAG 3: The Dental Record ---');

    // Test: admin/admin login works
    const loginOpts = {
        hostname: 'localhost', port: PORT, path: '/api/login',
        method: 'POST', headers: { 'Content-Type': 'application/json' }
    };
    const loginResp = await request(loginOpts, JSON.stringify({ username: 'admin', password: 'admin' }));
    assert(loginResp.status === 200 && loginResp.body && loginResp.body.success === true,
        'admin/admin login succeeds');

    // Test: SQL injection bypass
    const sqliResp = await request(loginOpts, JSON.stringify({ username: "' OR '1'='1", password: 'anything' }));
    assert(sqliResp.status === 200 && sqliResp.body && sqliResp.body.success === true,
        "SQL injection pattern login bypass works (' OR '1'='1)");

    // Test: Patient list loads
    const patientsResp = await request(opts('/api/patients', 'GET'));
    assert(patientsResp.status === 200 && Array.isArray(patientsResp.body) && patientsResp.body.length === 5,
        'Patient list returns 5 patients');

    // Test: Patient 3 contains the flag
    const patient3Resp = await request(opts('/api/patients/3', 'GET'));
    assert(patient3Resp.status === 200, 'Patient ID 3 record accessible');
    assert(patient3Resp.body && patient3Resp.body.name && patient3Resp.body.name.includes('Stu'),
        "Patient 3 is Stu Price");
    assert(patient3Resp.raw && patient3Resp.raw.includes('FLAG{dental_record_stu_2_47_am}'),
        '✅ FLAG 3 found in patient 3 record: FLAG{dental_record_stu_2_47_am}');

    // Test: Non-existent patient returns 404
    const patient99Resp = await request(opts('/api/patients/99', 'GET'));
    assert(patient99Resp.status === 404, 'Non-existent patient returns 404');

    // ---- FLAG 4 Tests ----
    console.log('\n--- FLAG 4: The Security Footage ---');

    // Test: robots.txt reveals hidden paths
    const robotsResp = await request(opts('/robots.txt', 'GET'));
    assert(robotsResp.status === 200, 'robots.txt accessible');
    assert(robotsResp.raw && robotsResp.raw.includes('/security/logs/'),
        'robots.txt reveals /security/logs/');

    // Test: Security camera API lists cameras + hint
    const cameraResp = await request(opts('/api/security/cameras', 'GET'));
    assert(cameraResp.status === 200 && cameraResp.body && cameraResp.body.cameras,
        'Security cameras endpoint accessible');
    assert(cameraResp.raw && cameraResp.raw.includes('/security/logs/'),
        'Camera API hints at /security/logs/ path');

    // Test: Security log directory listing
    const logDirResp = await request(opts('/security/logs/', 'GET'));
    assert(logDirResp.status === 200, '/security/logs/ directory listing accessible');
    assert(logDirResp.raw && logDirResp.raw.includes('.backup_camera_04_full.log'),
        'Directory listing reveals hidden .backup_camera_04_full.log');

    // Test: Backup camera 04 log contains the flag
    const backupLogResp = await request(opts('/security/logs/.backup_camera_04_full.log', 'GET'));
    assert(backupLogResp.status === 200, 'Backup camera log accessible');
    assert(backupLogResp.raw && backupLogResp.raw.includes('FLAG{security_footage_mercedes_3_15_am}'),
        '✅ FLAG 4 found in backup camera log: FLAG{security_footage_mercedes_3_15_am}');
    assert(backupLogResp.raw && backupLogResp.raw.includes('NV-CHOW-88'),
        'License plate NV-CHOW-88 visible in backup log');
    assert(backupLogResp.raw && backupLogResp.raw.includes('Mr. Chow'),
        'Mr. Chow identified in backup log');

    // Test: Normal camera 04 log has redacted footage
    const cam04Resp = await request(opts('/security/logs/camera_04_parking_lot_b.log', 'GET'));
    assert(cam04Resp.status === 200, 'Normal camera 04 log accessible');
    assert(cam04Resp.raw && cam04Resp.raw.includes('REDACTED'),
        'Normal camera 04 log has redacted footage (must use backup)');

    // ---- FLAG 5 Tests ----
    console.log('\n--- FLAG 5: The Prescription ---');

    // Test: robots.txt reveals prescription/backup paths
    assert(robotsResp.raw && robotsResp.raw.includes('/api/prescriptions/hidden'),
        'robots.txt reveals /api/prescriptions/hidden');
    assert(robotsResp.raw && robotsResp.raw.includes('/backup/'),
        'robots.txt reveals /backup/ directory');

    // Test: Backup directory listing
    const backupDirResp = await request(opts('/backup/', 'GET'));
    assert(backupDirResp.status === 200, '/backup/ directory accessible');
    assert(backupDirResp.raw && backupDirResp.raw.includes('prescription_encoded.txt'),
        'Backup directory reveals prescription_encoded.txt');

    // Test: Encoded prescription backup file accessible
    const encodedRxResp = await request(opts('/backup/prescription_encoded.txt', 'GET'));
    assert(encodedRxResp.status === 200, '/backup/prescription_encoded.txt accessible');
    assert(encodedRxResp.raw && encodedRxResp.raw.includes('RkxBR3twcmVzY3JpcHRpb25fd2FyZWhvdXNlX2Nvb3JkaW5hdGVzfQ=='),
        'Encoded prescription file contains Base64 payload');

    // Test: Hidden prescription endpoint
    const hiddenRxResp = await request(opts('/api/prescriptions/hidden', 'GET'));
    assert(hiddenRxResp.status === 200, '/api/prescriptions/hidden accessible');
    assert(hiddenRxResp.body && hiddenRxResp.body.encoded_coordinates,
        'Hidden prescription contains encoded_coordinates field');

    // Test: Decode the Base64 payload to get the flag
    const encoded = 'RkxBR3twcmVzY3JpcHRpb25fd2FyZWhvdXNlX2Nvb3JkaW5hdGVzfQ==';
    const decoded = Buffer.from(encoded, 'base64').toString('utf8');
    assert(decoded === 'FLAG{prescription_warehouse_coordinates}',
        '✅ FLAG 5 obtained by Base64 decoding the payload: FLAG{prescription_warehouse_coordinates}');

    // ---- Additional Tests ----
    console.log('\n--- Additional / Hint Tests ---');

    const hintResp = await request(opts('/api/hint', 'GET'));
    assert(hintResp.status === 200 && hintResp.body && Array.isArray(hintResp.body.hints),
        '/api/hint endpoint returns hint array');

    const filesResp = await request(opts('/api/files?file=patients.json', 'GET'));
    assert(filesResp.status === 200, '/api/files directory traversal endpoint accessible');

    // ---- New Page Tests ----
    console.log('\n--- New Pages & Routes ---');

    // Admin panel
    const adminResp = await request(opts('/admin/', 'GET'));
    assert(adminResp.status === 200, '/admin/ page accessible');
    assert(adminResp.raw && adminResp.raw.includes('admin / admin'),
        '/admin/ page leaks default credentials (admin / admin)');
    assert(adminResp.raw && adminResp.raw.includes('users.json'),
        '/admin/ panel hints at /api/files?file=users.json');

    // Appointments page
    const apptResp = await request(opts('/appointments', 'GET'));
    assert(apptResp.status === 200, '/appointments page accessible');
    assert(apptResp.raw && apptResp.raw.includes('Stuart Price'),
        '/appointments page lists Stuart Price appointment');

    // Custom 404 page
    const notFoundResp = await request(opts('/does-not-exist-xyz', 'GET'));
    assert(notFoundResp.status === 404, 'Missing pages return 404 status');
    assert(notFoundResp.raw && notFoundResp.raw.includes('/admin/'),
        '404 page hints at /admin/ path');

    // system_config.bak
    const configBakResp = await request(opts('/backup/system_config.bak', 'GET'));
    assert(configBakResp.status === 200, '/backup/system_config.bak accessible');
    assert(configBakResp.raw && configBakResp.raw.includes('admin_password=admin'),
        'system_config.bak contains plaintext admin password');

    // Redirect /admin → /admin/
    const adminRedirectResp = await request(opts('/admin', 'GET'));
    assert(adminRedirectResp.status === 301 || adminRedirectResp.status === 302,
        '/admin redirects to /admin/');

    // ---- Summary ----
    console.log(`\n========================================`);
    console.log(`Results: ${passed} passed, ${failed} failed`);
    console.log(`========================================`);
    if (failed === 0) {
        console.log('🎉 All tests passed! All 3 flags are correctly placed.\n');
    } else {
        console.log(`⚠️  Some tests failed. Check server is running on port ${PORT}.\n`);
        process.exit(1);
    }
}

runTests().catch(err => {
    console.error('Test runner error:', err.message);
    console.error('Make sure the server is running: node server.js');
    process.exit(1);
});
