import express from "express";
import * as stocksController from "../controllers/stocks.controller";

const router = express.Router();

router.get("/", async (_req, res) => {
  try {
    const stocks = await stocksController.get();
    res.status(200).json(stocks);
  } catch (err: any) {
    console.error(err.stack);
    res.status(400).json({ message: err.message });
  }
});

export default router;
