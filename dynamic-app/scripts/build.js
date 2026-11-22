import fs from 'node:fs';
for (const f of ['public/index.html','public/admin/index.html','public/site.js','public/admin.js','api/router.js','supabase/001_schema.sql']) if(!fs.existsSync(f))throw Error(`Missing ${f}`);
console.log('Static pages and server API ready. Database configuration is validated at runtime.');
