import pg from 'pg';
const { Pool } = pg;

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
});

export const handler = async (event) => {
  const path = event.path;
  const queryStringParameters = event.queryStringParameters;

  if (path === '/totalmoney') {
    return await getTotalMoney();
  } else if (path === '/MenberName') {
    return await getMemberName();
  } else if (path === '/data') {
    return await getData(queryStringParameters.user_id);
  } else if (path === '/Input') {
    return await addInput(queryStringParameters.user_id, queryStringParameters.amount);
  } else {
    return {
      statusCode: 404,
      body: JSON.stringify('Path not found'),
    };
  }
};

const getTotalMoney = async () => {
  try {
    const result = await pool.query(`
      SELECT m.user_id, n.name, SUM(m.money) AS total_money
      FROM money m
      JOIN member n ON m.user_id = n.id
      GROUP BY m.user_id, n.name
      ORDER BY m.user_id;
    `);
    return {
      statusCode: 200,
      body: JSON.stringify(result.rows),
    };
  } catch (err) {
    console.error('Database query error:', err);
    return {
      statusCode: 500,
      body: JSON.stringify('Server error'),
    };
  }
};

const getMemberName = async () => {
  try {
    const result = await pool.query(`
      SELECT id, name
      FROM member
      ORDER BY id;
    `);
    return {
      statusCode: 200,
      body: JSON.stringify(result.rows),
    };
  } catch (err) {
    console.error('Database query error:', err);
    return {
      statusCode: 500,
      body: JSON.stringify('Server error'),
    };
  }
};

const getData = async (user_id) => {
  if (!user_id) {
    return {
      statusCode: 400,
      body: JSON.stringify('user_id parameter is required'),
    };
  }

  try {
    const result = await pool.query(
      `
      SELECT money, TO_CHAR(date, 'YYYY-MM-DD') AS date
      FROM money
      WHERE user_id = $1
      ORDER BY date DESC
      `,
      [user_id]
    );

    if (result.rows.length === 0) {
      return {
        statusCode: 404,
        body: JSON.stringify('No data found for the specified user_id'),
      };
    }

    return {
      statusCode: 200,
      body: JSON.stringify(result.rows),
    };
  } catch (err) {
    console.error('Database query error:', err);
    return {
      statusCode: 500,
      body: JSON.stringify('Server error'),
    };
  }
};

const addInput = async (user_id, amount) => {
  if (!user_id || !amount) {
    return {
      statusCode: 400,
      body: JSON.stringify('user_id and amount parameters are required'),
    };
  }

  try {
    await pool.query(
      `
      INSERT INTO public.money(
        user_id, money, date, memo)
        VALUES ($1, $2, CURRENT_DATE, '')
      `,
      [user_id, amount]
    );

    return {
      statusCode: 201,
      body: JSON.stringify('Data inserted successfully'),
    };
  } catch (err) {
    console.error('Database query error:', err);
    return {
      statusCode: 500,
      body: JSON.stringify('Server error'),
    };
  }
};
