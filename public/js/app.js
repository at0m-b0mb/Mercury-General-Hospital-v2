// Mercury General Hospital - CTF Frontend JS
// This file intentionally contains comments that hint at CTF challenges

// Hint: Check robots.txt and the /backup/ directory for hidden files
// Hint: The API supports both GET and POST requests
// Hint: Some API endpoints are not listed in the public documentation

// Useful API endpoints (for development reference):
// GET  /api/patients           - list all patients
// GET  /api/patients/:id       - get specific patient (try IDs 1-5)
// POST /api/login              - authenticate (default: admin/admin)
// GET  /api/prescriptions      - list prescriptions
// GET  /api/prescriptions/hidden - special encoded prescriptions
// GET  /security/logs/         - camera log file listing
// GET  /security/logs/:file    - read specific log (try .backup_camera_04_full.log)
// GET  /backup/prescription_encoded.txt - encoded prescription backup
// GET  /api/files?file=        - file reader utility (directory traversal possible)

console.log('Mercury General Hospital Patient Portal v2.4.1');
console.log('For IT support, call ext. 4477');

// Smooth scrolling for anchor links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function(e) {
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            e.preventDefault();
            target.scrollIntoView({ behavior: 'smooth' });
        }
    });
});

// Auto-dismiss alerts after 5 seconds
setTimeout(() => {
    document.querySelectorAll('.alert').forEach(el => {
        el.style.transition = 'opacity 0.5s';
        el.style.opacity = '0';
        setTimeout(() => { el.style.display = 'none'; }, 500);
    });
}, 5000);
