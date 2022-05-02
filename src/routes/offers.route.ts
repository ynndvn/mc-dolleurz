import express from "express";
import * as offersController from "../controllers/offers.controller";

const router = express.Router();

router.post("/:name", async (req, res) => {
  try {
    const offer = await offersController.create(
      req.params.name,
      req.body.price
    );
    res.status(201).json(offer);
  } catch (err: any) {
    console.error(err.stack);
    res.status(400).json({ message: err.message });
  }
});

router.delete("/:name", async (req, res) => {
  try {
    await offersController.del(req.params.name);
    res.sendStatus(204);
  } catch (err: any) {
    console.error(err.stack);
    res.status(400).json({ message: err.message });
  }
});

router.put("/:name/price/:price", async (req, res) => {
  try {
    await offersController.updatePrice(
      req.params.name,
      parseFloat(req.params.price)
    );
    res.sendStatus(204);
  } catch (err: any) {
    console.error(err.stack);
    res.status(400).json({ message: err.message });
  }
});

router.get("/", async (_req, res) => {
  try {
    const offers = await offersController.get();
    res.status(200).json(offers);
  } catch (err: any) {
    console.error(err.stack);
    res.status(400).json({ message: err.message });
  }
});

router.post("/:name/buy", async (req, res) => {
  try {
    const balance = await offersController.buy(req.params.name, {
      amount: req.body.amount,
      userId: req.body.userId,
    });
    res.status(200).send(balance.toFixed(2));
  } catch (err: any) {
    console.error(err.stack);
    res.status(400).json({ message: err.message });
  }
});

router.post("/:name/sell", async (req, res) => {
  try {
    const balance = await offersController.sell(req.params.name, {
      amount: req.body.amount,
      userId: req.body.userId,
    });
    res.status(200).send(balance.toFixed(2));
  } catch (err: any) {
    console.error(err.stack);
    res.status(400).json({ message: err.message });
  }
});

export default router;
