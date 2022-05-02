import express from "express";
import * as transactionsController from "../controllers/transactions.controller";

const router = express.Router();

router.post("/", async (req, res) => {
  try {
    await transactionsController.create(
      req.body.from,
      req.body.to,
      parseFloat(req.body.amount)
    );
    res.sendStatus(204);
  } catch (err: any) {
    console.error(err.stack);
    res.status(400).json({ message: err.message });
  }
});

export default router;
