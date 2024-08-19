import { connectToDashboard } from "../config/dbConfig.js";
import { verifyToken } from "../config/auth.js";

const getDbSchemaNameFromToken = (req) => {
    const token = req.headers.authorization?.split(" ")[1];  
    if (!token) {
        throw new Error('Token not provided');
    }
    const decodedToken = verifyToken(token);  
    return decodedToken.dbSchemaName;  
};

const checkExpiryStatus = (req) => {
    const authHeader = req.headers.authorization;
  
    if (!authHeader) {
      // Handle missing Authorization header
      console.log('Authorization header missing');

      return { expired: true, message: 'Token not provided' }; // You might want to return a different status/message
    }
  
    const token = authHeader.split(" ")[1];
  
    if (!token) {
      // Handle missing token after "Bearer"
      console.log('Token missing in Authorization header');
      return { expired: true, message: 'Token not provided' };
    }
  
    try {
      const decodedToken = verifyToken(token);
  
      const expiryStatus = decodedToken.expiryStatus;
      const expiryDate = new Date(decodedToken.expiryDate);
      const currentDate = new Date();
  
      if (expiryStatus === 1 || expiryDate < currentDate) {
        return { expired: true, message: 'Company subscription has expired.' };
      }
  
      return { expired: false };
    } catch (error) {
      // Handle errors during token verification
      console.error('Error verifying token:', error.message);
      return { expired: true, message: 'Invalid or expired token' };
    }
  };
  

export const getSalesDetails = async (req, res) => {
    const { date } = req.query;
    const expiryCheck = checkExpiryStatus(req);
    if (expiryCheck.expired) {
        return res.status(403).json(expiryCheck);
    }

    const selectedDate = new Date(date);
    const startDate = new Date(selectedDate);
    startDate.setHours(5, 0, 0, 0);
    const endDate = new Date(startDate);
    endDate.setDate(startDate.getDate() + 1);
    endDate.setHours(5, 0, 0, 0);

    const formattedStartDate = `${startDate.toISOString().split('T')[0]} 05:00:00 AM`;
    console.log(formattedStartDate);
    const formattedEndDate = `${endDate.toISOString().split('T')[0]} 05:00:00 AM`;
    console.log(formattedEndDate);
    try {
        const dbSchemaName = getDbSchemaNameFromToken(req);
        const dashboardPool = await connectToDashboard();
        const request = dashboardPool.request();

        const result = await request.query(`
            SELECT 
                COUNT(*) AS totalSalesCount,
                COUNT(CASE WHEN Amount < 0 THEN 1 END) AS positiveAmountSalesCount,
                SUM(CashAmount) AS totalCashAmount,
                SUM(CreditAmount) AS totalCreditAmount,
                SUM(CreditCardAmount) AS totalCreditCardAmount
            FROM ${dbSchemaName}.SalesMaster
            WHERE BillTime >= '${formattedStartDate}' AND BillTime < '${formattedEndDate}'
        `);

//         const query = `
//     SELECT 
//         COUNT(*) AS totalSalesCount,
//         COUNT(CASE WHEN Amount < 0 THEN 1 END) AS positiveAmountSalesCount,
//         SUM(CashAmount) AS totalCashAmount,
//         SUM(CreditAmount) AS totalCreditAmount,
//         SUM(CreditCardAmount) AS totalCreditCardAmount
//     FROM ${dbSchemaName}.SalesMaster
//     WHERE BillTime >= '${startDate.toISOString()}' AND BillTime < '${endDate.toISOString()}'
// `;

// console.log(query,"Query enthyaaa");
        const { totalSalesCount, positiveAmountSalesCount, totalCashAmount, totalCreditAmount, totalCreditCardAmount } = result.recordset[0];

        res.json({
            totalSalesCount,
            positiveAmountSalesCount,
            totalCashAmount,
            totalCreditAmount,
            totalCreditCardAmount
        });
    } catch (err) {
        console.error('SQL error', err);
        res.status(500).send('Server Error');
    }
};

export const getMonthlySales = async (req, res) => {
    const expiryCheck = checkExpiryStatus(req);
    if (expiryCheck.expired) {
        return res.status(403).json(expiryCheck);
    }

    try {
        const year = 2023; 
        const dbSchemaName = getDbSchemaNameFromToken(req);
        const dashboardPool = await connectToDashboard();
        const request = dashboardPool.request();

        const result = await request.query(`
            SELECT 
                YEAR(billdate) AS Year,
                MONTH(billdate) AS Month,
                SUM(amount) AS TotalAmount
            FROM 
                ${dbSchemaName}.SalesMaster
            WHERE 
                YEAR(billdate) = ${year}
            GROUP BY 
                YEAR(billdate), 
                MONTH(billdate)
            ORDER BY 
                Month
        `);

        const data = result.recordset;
        const formattedData = [];

        for (let month = 1; month <= 12; month++) {
            const found = data.find(d => d.Month === month);
            formattedData.push({
                Year: year,
                Month: month,
                TotalAmount: found ? found.TotalAmount : 0
            });
        }

        res.status(200).json(formattedData);
    } catch (err) {
        console.error('SQL error', err);
        res.status(500).send('Server Error');
    }
};

export const getAreaSales = async (req, res) => {
    const expiryCheck = checkExpiryStatus(req);
    if (expiryCheck.expired) {
        return res.status(403).json(expiryCheck);
    }

    const { date } = req.query;
    const selectedDate = new Date(date);
    const startDate = new Date(selectedDate);
    startDate.setHours(5, 0, 0, 0);
    const endDate = new Date(startDate);
    endDate.setDate(startDate.getDate() + 1);
    endDate.setHours(5, 0, 0, 0);

    const formattedStartDate = `${startDate.toISOString().split('T')[0]} 05:00:00 AM`;
    const formattedEndDate = `${endDate.toISOString().split('T')[0]} 05:00:00 AM`;

    try {
        const dbSchemaName = getDbSchemaNameFromToken(req);
        const dashboardPool = await connectToDashboard();
        const request = dashboardPool.request();

        // Check if the AreaMaster table exists in the current schema
        const tableExistsResult = await request.query(`
            SELECT COUNT(*) as tableCount
            FROM information_schema.tables
            WHERE table_schema = '${dbSchemaName}' AND table_name = 'AreaMaster'
        `);

        const tableExists = tableExistsResult.recordset[0].tableCount > 0;

        if (!tableExists) {
            // If the table does not exist, return a response indicating that area sales data is unavailable.
            return res.status(404).json({
                error: true,
                message: 'Area sales data is not available for this company.',
            });
        }

        // Proceed with the main query if the table exists
        const result = await request.query(`
            SELECT 
                am.AreaName,
                SUM(sm.CashAmount + sm.CreditAmount + sm.CreditCardAmount) AS TotalSales
            FROM 
                ${dbSchemaName}.SalesMaster sm
            JOIN 
                ${dbSchemaName}.AreaMaster am ON sm.AreaID = am.AreaID
            WHERE 
                (sm.CashAmount > 0 OR sm.CreditAmount > 0 OR sm.CreditCardAmount > 0)
                AND sm.BillTime >= '${formattedStartDate}' 
                AND sm.BillTime < '${formattedEndDate}'
            GROUP BY 
                am.AreaName
        `);

        const areaSalesData = result.recordset.map(record => ({
            areaName: record.AreaName,
            totalSales: record.TotalSales,
        }));
console.log(areaSalesData,"Ith indo?");
        res.json(areaSalesData);
    } catch (err) {
        if (err.message.includes('Invalid object name') || err.message.includes('Table or view does not exist')) {
            // Handle SQL error indicating a missing table
            console.error('Area sales table does not exist in the schema:', err.message);
            return res.status(404).json({
                error: true,
                message: 'Area sales data is not available for this company.',
            });
        }

        // Handle other SQL errors
        console.error('SQL error', err);
        res.status(500).send('Server Error');
    }
};
