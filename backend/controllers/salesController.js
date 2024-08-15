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
  const token = req.headers.authorization?.split(" ")[1];
  console.log(token);
  if (!token) throw new Error('Token not provided');

  const decodedToken = verifyToken(token);

  const expiryStatus = decodedToken.expiryStatus;
  const expiryDate = new Date(decodedToken.expiryDate);
  const currentDate = new Date();

  if (expiryStatus === 1 || expiryDate < currentDate) {
    return { expired: true, message: 'Company subscription has expired.' };
  }

  return { expired: false };
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
            WHERE BillTime >= '${startDate.toISOString()}' AND BillTime < '${endDate.toISOString()}'
        `);

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

    try {
        const dbSchemaName = getDbSchemaNameFromToken(req);
        const dashboardPool = await connectToDashboard();
        const request = dashboardPool.request();

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
                AND sm.BillTime >= '${startDate.toISOString()}' AND sm.BillTime < '${endDate.toISOString()}'
            GROUP BY 
                am.AreaName
        `);

        const areaSalesData = result.recordset.map(record => ({
            areaName: record.AreaName,
            totalSales: record.TotalSales,
        }));

        res.json(areaSalesData);
    } catch (err) {
        console.error('SQL error', err);
        res.status(500).send('Server Error');
    }
};
