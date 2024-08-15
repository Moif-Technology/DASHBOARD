import express from 'express';
import { getAreaSales, getMonthlySales, getSalesDetails } from '../controllers/salesController.js';


const router = express.Router();

router.get("/salesDetails", getSalesDetails);
router.get("/monthlySales",getMonthlySales);
router.get("/areaSales",getAreaSales)

export default router;