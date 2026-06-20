const bcrypt = require('bcryptjs');

const hash = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy';
const password = 'Password123!';

bcrypt.compare(password, hash, (err, result) => {
    if (err) console.error(err);
    console.log('✅ ¿Contraseña válida?', result);
});