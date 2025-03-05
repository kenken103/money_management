const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');

const app = express();
const port = 3000;

app.use(cors());

const pool = new Pool({
  user: 'postgres',
  host: 'moneymanagement.cv06u2wss6mi.ap-northeast-1.rds.amazonaws.com',
  database: 'moneymanagement',
  password: 'Kentarou103',
  port: 5432,
});

app.get('/', (req, res) => {
  res.send('Welcome to the API');
});

// 貯金総額取得API
app.get('/totalmoney', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT m.user_id, n.name, SUM(m.money) AS total_money
      FROM money m
      JOIN member n ON m.user_id = n.id
      GROUP BY m.user_id, n.name
      ORDER BY m.user_id;
    `);
    res.json(result.rows);
  } catch (err) {
    console.error('Database query error:', err); // 詳細なエラーメッセージをログ出力
    res.status(500).send('Server error');
  }
});

// メンバー取得API
app.get('/MenberName', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT id, name
      FROM member m
      ORDER BY id;
    `);
    res.json(result.rows);
  } catch (err) {
    console.error('Database query error:', err); // 詳細なエラーメッセージをログ出力
    res.status(500).send('Server error');
  }
});

// 月別の貯金額取得
app.get('/data', async (req, res) => {
  const { user_id } = req.query; // クエリパラメータからuser_idを取得

  if (!user_id) {
    return res.status(400).send('user_id parameter is required'); // user_idが指定されていない場合
  }

  try {
    const result = await pool.query(
      `
      SELECT money,TO_CHAR(date, 'YYYY-MM-DD') AS date
      FROM money
      WHERE user_id = $1
      ORDER BY date DESC
      `, // クエリの括弧を修正
      [user_id] // プレースホルダを使用
    );

    if (result.rows.length === 0) {
      return res.status(404).send('No data found for the specified user_id'); // 該当データがない場合
    }

    res.json(result.rows); // 全ての結果を返却
  } catch (err) {
    console.error('Database query error:', err); // エラーメッセージをログ出力
    res.status(500).send('Server error'); // サーバーエラー
  }
});

// 貯金追加
app.get('/Input', async (req, res) => {
  const { user_id, amount } = req.query; // クエリパラメータからuser_idとamountを取得

  if (!user_id || !amount) {
    return res.status(400).send('user_id and amount parameters are required'); // user_idまたはamountが指定されていない場合
  }

  try {
    const result = await pool.query(
      `
      INSERT INTO public.money(
        user_id, money, date, memo)
        VALUES ($1, $2, CURRENT_DATE, '')
      `, // クエリの括弧を修正
      [user_id, amount] // プレースホルダを使用
    );

    res.status(201).send('Data inserted successfully'); // 成功時のメッセージ
  } catch (err) {
    console.error('Database query error:', err); // エラーメッセージをログ出力
    res.status(500).send('Server error'); // サーバーエラー
  }
});


app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
