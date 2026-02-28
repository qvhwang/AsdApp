const db = require('../config/db');

exports.getScreeningStats = async (from, to) => {
  let dateClause = '';
  const params = [];

  if (from && to) {
    dateClause = 'AND DATE(s.created_at) BETWEEN ? AND ?';
    params.push(from, to);
  } else if (from) {
    dateClause = 'AND DATE(s.created_at) >= ?';
    params.push(from);
  } else if (to) {
    dateClause = 'AND DATE(s.created_at) <= ?';
    params.push(to);
  }

  const [rows] = await db.execute(
    `SELECT
       COUNT(*) AS total,
       SUM(CASE WHEN s.risk_level = 'High' THEN 1 ELSE 0 END) AS high,
       SUM(CASE WHEN s.risk_level = 'Medium' THEN 1 ELSE 0 END) AS medium,
       SUM(CASE WHEN s.risk_level = 'Low' THEN 1 ELSE 0 END) AS low
     FROM mchat_sessions s
     JOIN users u ON s.user_id = u.id
     JOIN children c ON s.child_id = c.id
     WHERE u.role = 'USER'
     AND s.risk_level IS NOT NULL
     ${dateClause}`,
    [...params]
  );

  const [details] = await db.execute(
    `SELECT
       s.id,
       u.full_name AS user_name,
       c.full_name AS child_name,
       s.risk_level,
       s.total_score,
       s.created_at
     FROM mchat_sessions s
     JOIN users u ON s.user_id = u.id
     JOIN children c ON s.child_id = c.id
     WHERE u.role = 'USER'
     AND s.risk_level IS NOT NULL
     ${dateClause}
     ORDER BY s.created_at DESC`,
    [...params]
  );

  return {
    summary: rows[0],
    details,
  };
};

exports.getUserStats = async (sort) => {
  const orderMap = {
    count: 'total_screenings DESC',
    latest: 'last_screening DESC',
    name: 'u.full_name ASC',
  };

  const orderBy = orderMap[sort] || orderMap.count;

  const [rows] = await db.execute(
    `SELECT
       u.id,
       u.full_name,
       u.email,
       COUNT(DISTINCT c.id) AS total_children,
       COUNT(DISTINCT s.id) AS total_screenings,
       MAX(s.created_at) AS last_screening
     FROM users u
     LEFT JOIN children c ON c.user_id = u.id
     LEFT JOIN mchat_sessions s ON s.user_id = u.id AND s.risk_level IS NOT NULL
     WHERE u.role = 'USER'
     GROUP BY u.id, u.full_name, u.email
     ORDER BY ${orderBy}`
  );

  return rows;
};