import express from "express";
import * as playersController from "../controllers/players.controller";
import { get } from "../helpers/money.helper";

const router = express.Router();

router.post("/", async (req, res) => {
  try {
    const player = await playersController.create(req.body.nickname);
    res.status(201).json(player);
  } catch (err: any) {
    console.error(err.stack);
    res.status(400).json({ message: err.message });
  }
});

router.get("/:nickname/balance", async (req, res) => {
  try {
    const balance = await playersController.getBalance(req.params.nickname);
    res.status(200).send(balance.toFixed(2));
  } catch (err: any) {
    console.error(err.stack);
    res.status(400).json({ message: err.message });
  }
});

router.post("/:nickname/balance/add", async (req, res) => {
  try {
    const balance = await playersController.addToBalance(
      req.params.nickname,
      req.body.amount ?? 0
    );
    res.status(200).send(balance.toFixed(2));
  } catch (err: any) {
    console.error(err.stack);
    res.status(400).json({ message: err.message });
  }
});

router.post("/:nickname/balance/remove", async (req, res) => {
  try {
    const balance = await playersController.addToBalance(
      req.params.nickname,
      (req.body.amount ?? 0) * -1
    );
    res.status(200).send(balance.toFixed(2));
  } catch (err: any) {
    console.error(err.stack);
    res.status(400).json({ message: err.message });
  }
});

router.get("/", async (_req, res) => {
  try {
    const players = await playersController.getAll();
    res
      .status(200)
      .send(players.map((player) => `${player.nickname} : ${get(player.balance)}`).join("|"));
  } catch (err: any) {
    console.error(err.stack);
    res.status(400).json({ message: err.message });
  }
});

export default router;
