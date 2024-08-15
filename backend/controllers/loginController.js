import mssql from "mssql";
import { connectToCompanyDetails } from "../config/dbConfig.js";
import { generateToken, verifyToken } from "../config/auth.js";

export const login = async (req, res) => {
  const { username, password } = req.body;
  console.log(req.body, "Req body Recieved");

  try {
    // Step 1: Connect to the CompanyDetails database
    const sql = await connectToCompanyDetails();

    // Check user credentials in dbo.UserLog table
    const userResult = await sql
      .request()
      .input("Login", mssql.VarChar, username)
      .query("SELECT * FROM CompanyDetails.dbo.UserLog WHERE Login = @Login");

    console.log(userResult, "User");
    if (userResult.recordset.length === 0) {
      return res.status(401).json({ message: "Invalid username or password" });
    }

    const user = userResult.recordset[0];

    // Check if the password matches
    if (password !== user.Password) {
      return res.status(401).json({ message: "Invalid username or password" });
    }

    // Step 2: Retrieve the CompanyID and check in dbo.CompanyLog table
    const companyId = user.CompanyID;
    const companyResult = await sql
      .request()
      .input("CompanyID", mssql.VarChar, companyId)
      .query(
        "SELECT * FROM CompanyDetails.dbo.CompanyLog WHERE CompanyID = @CompanyID"
      );

    console.log(companyResult, "Company Result");
    if (companyResult.recordset.length === 0) {
      return res.status(404).json({ message: "Company not found" });
    }

    const company = companyResult.recordset[0];
    const companyName = company.CompanyName;
    const dbSchemaName = company.DbSchemaName;
    let expiryStatus = company.ExpiryStatus;
    const expiryDate = new Date(company.ExpiryDate);

    console.log(`Initial Expiry Status: ${expiryStatus}`);
    console.log(`Current Date: ${new Date()}, Expiry Date: ${expiryDate}`);

    // Step 3: Check for ExpiryStatus and ExpiryDate
    const currentDate = new Date();

    if (expiryDate < currentDate && expiryStatus !== 1) {
      // Update the ExpiryStatus to 1 if the expiry date has passed and it wasn't updated already
      await sql.request().input("CompanyID", mssql.VarChar, companyId) // Bind the @CompanyID parameter
        .query(`
          UPDATE CompanyDetails.dbo.CompanyLog 
          SET ExpiryStatus = 1 
          WHERE CompanyID = @CompanyID
        `);
      expiryStatus = 1;
    }

    // Step 4: Generate JWT Token using the utility function, including ExpiryStatus and ExpiryDate
    const token = generateToken({
      username,
      companyId,
      companyName,
      dbSchemaName,
      expiryStatus,
      expiryDate: expiryDate.toISOString(), // Add expiryDate to the token payload
    });
    console.log(token, "Token Generated");

    // Respond with the token and company details
    res.json({
      token,
      companyId,
      companyName,
      dbSchemaName,
      expiryStatus,
      expiryDate: expiryDate.toISOString(),
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Internal server error" });
  }
};

export const logout = (req, res) => {
  try {
    const token = req.headers.authorization?.split(" ")[1];

    if (!token) {
      return res
        .status(401)
        .json({ message: "Authorization token is missing" });
    }

    // Verify the token
    const decodedToken = verifyToken(token);

    if (!decodedToken) {
      return res.status(401).json({ message: "Invalid token" });
    }

    console.log(`User ${decodedToken.username} logged out successfully`);

    // Since no token storage is involved, just respond with success
    res.status(200).json({ message: "Logged out successfully" });
  } catch (error) {
    console.error("Logout error:", error);
    res.status(500).json({ message: "Internal server error" });
  }
};
