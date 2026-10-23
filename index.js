'use strict';

// Vercel's Express detector looks for a root index.js (or app/server entry).
// Reuse the same Express instance as the local Node server.
module.exports = require('./server');
