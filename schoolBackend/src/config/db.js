require("dotenv").config();
const { Pool } = require("pg");

const pool = new Pool({
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT),
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  ssl: {
    rejectUnauthorized: false, // Required for RDS in most cases
  },
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 60000, // Increased to 60s for high-latency RDS connections
});

pool.on('error', (err) => {
  console.error('[Postgres Shield Pool] Unexpected Error:', err.message);
});

// Compatibility Shim: Convert MySQL '?' placeholders to PostgreSQL '$1, $2...'
// and return [rows, fields] to match mysql2/promise behavior.
const originalQuery = pool.query.bind(pool);

// Function to transform MySQL queries to PostgreSQL ones
function transformQuery(text, params) {
  let queryText = text;
  let queryParams = params;
  const isInsert = queryText.trim().toUpperCase().startsWith("INSERT");
  
  if (isInsert && !queryText.toUpperCase().includes("RETURNING")) {
    queryText = queryText.trim().replace(/;?$/, " RETURNING *");
  }

  if (typeof text === "string" && params && Array.isArray(params)) {
    // Handle MySQL-style bulk inserts: INSERT INTO table (col1, col2) VALUES ?
    // where params is [[ [v1, v2], [v3, v4] ]]
    if (queryText.toUpperCase().includes("VALUES ?") && Array.isArray(params[0]) && Array.isArray(params[0][0])) {
      const rows = params[0];
      const placeholders = rows.map((row, i) => {
        return `(${row.map((_, j) => `$${(i * row.length) + j + 1}`).join(", ")})`;
      }).join(", ");
      
      queryText = queryText.replace(/VALUES\s+\?/i, `VALUES ${placeholders}`);
      queryParams = rows.flat();
    } else {
      let index = 1;
      queryText = queryText.replace(/\?/g, () => `$${index++}`);
      
      // Convert boolean params to 1/0 for PostgreSQL SMALLINT compatibility
      queryParams = params.map(p => {
        if (p === true) return 1;
        if (p === false) return 0;
        return p;
      });
    }
  }

  return { queryText, queryParams, isInsert };
}

pool.query = async (text, params) => {
  const { queryText, queryParams, isInsert } = transformQuery(text, params);

  try {
    const result = await originalQuery(queryText, queryParams);
    
    // Auto-cast strings to Numbers for common stat keys
    const castedRows = result.rows.map(row => {
      const newRow = { ...row };
      const numericKeys = [
        'count', 'total', 'pending', 'present', 'absent', 'holiday', 
        'percentage', 'present_count', 'absent_count', 'paid', 'amount', 'amount_paid', 'balance', 'fine',
        'total_students', 'pending_doubts', 'roll_number', 'id', 'student_id', 'teacher_id', 'user_id', 'absence_id', 'exam_id', 'mapping_id'
      ];
      numericKeys.forEach(key => {
        if (newRow[key] !== undefined && typeof newRow[key] === 'string') {
          const num = Number(newRow[key]);
          if (!isNaN(num)) newRow[key] = num;
        }
      });
      return newRow;
    });

    // CRITICAL FIX: Attach insertId and affectedRows to the first element of the returned [rows, fields] array
    // This ensures compatibility with both:
    // 1. const [rows] = await pool.query(...) -> rows.insertId
    // 2. const result = await pool.query(...) -> result[0].insertId
    const rows = castedRows;
    rows.affectedRows = result.rowCount;
    if (isInsert && castedRows.length > 0) {
      // Common insert ID candidates
      rows.insertId = castedRows[0].id || castedRows[0].user_id || castedRows[0].attempt_id || castedRows[0].notification_id || castedRows[0].mapping_id || castedRows[0].absence_id;
    }

    const mockResult = [rows, result.fields];
    mockResult.affectedRows = rows.affectedRows;
    mockResult.insertId = rows.insertId;
    
    return mockResult;
  } catch (err) {
    console.error("[Postgres Shield] Query Error:", err.message);
    console.error("[Postgres Shield] SQL:", queryText);
    throw err;
  }
};

// Shim getConnection for transactions (MySQL style)
pool.getConnection = async () => {
  const client = await pool.connect();
  const originalClientQuery = client.query.bind(client);

  client.query = async (text, params) => {
    const { queryText, queryParams, isInsert } = transformQuery(text, params);
    try {
      const result = await originalClientQuery(queryText, queryParams);
      
      const castedRows = result.rows.map(row => {
        const newRow = { ...row };
        const numericKeys = [
          'count', 'total', 'pending', 'present', 'absent', 'holiday', 
          'percentage', 'present_count', 'absent_count', 'paid', 'amount', 'amount_paid', 'balance', 'fine',
          'total_students', 'pending_doubts', 'roll_number', 'id', 'student_id', 'teacher_id', 'user_id', 'absence_id', 'exam_id', 'mapping_id'
        ];
        numericKeys.forEach(key => {
          if (newRow[key] !== undefined && typeof newRow[key] === 'string') {
            const num = Number(newRow[key]);
            if (!isNaN(num)) newRow[key] = num;
          }
        });
        return newRow;
      });

      const rows = castedRows;
      rows.affectedRows = result.rowCount;
      if (isInsert && castedRows.length > 0) {
        rows.insertId = castedRows[0].id || castedRows[0].user_id || castedRows[0].attempt_id || castedRows[0].mapping_id || castedRows[0].absence_id;
      }

      const mockResult = [rows, result.fields];
      mockResult.affectedRows = rows.affectedRows;
      mockResult.insertId = rows.insertId;

      return mockResult;
    } catch (err) {
      console.error("[Postgres Shield Client] Query Error:", err.message);
      console.error("[Postgres Shield Client] SQL:", queryText);
      throw err;
    }
  };

  client.beginTransaction = () => client.query("BEGIN");
  client.commit = () => client.query("COMMIT");
  client.rollback = () => client.query("ROLLBACK");
  // client.release() is already provided by pg

  return client;
};

module.exports = pool;

