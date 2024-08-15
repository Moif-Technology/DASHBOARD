import { connectToDashboard } from "../config/dbConfig.js";
import { verifyToken } from "../config/auth.js";

export const getCountOfUniqueCustomers = async (req, res) => {
  const { date } = req.query;

  // Parse the date and set the time range from 5 AM today to 5 AM the next day
  const selectedDate = new Date(date);
  const startDate = new Date(selectedDate);
  startDate.setHours(5, 0, 0, 0);
  const endDate = new Date(startDate);
  endDate.setDate(startDate.getDate() + 1);
  endDate.setHours(5, 0, 0, 0);

  try {
    // Verify token and extract schema name
    const token = req.headers.authorization?.split(" ")[1];
    const decodedToken = verifyToken(token);
    const dbSchemaName = decodedToken.dbSchemaName;  // e.g., "adm" or "rws"

    // Connect to the DashBoard database
    const dashboardPool = await connectToDashboard();
    const request = dashboardPool.request();

    // Execute the query to get the total count of unique customers within the specified date range
    const query = `
      SELECT COUNT(DISTINCT CustomerID) AS totalCustomers
      FROM ${dbSchemaName}.SalesMaster
      WHERE BillTime >= '${startDate.toISOString()}' AND BillTime < '${endDate.toISOString()}'
    `;
    const countResult = await request.query(query);

    // Send the result
    res.status(200).json({
        totalCustomers: countResult.recordset[0].totalCustomers
    });
  } catch (err) {
    console.error('SQL error', err);
    res.status(500).send('Server Error');
  }
};
