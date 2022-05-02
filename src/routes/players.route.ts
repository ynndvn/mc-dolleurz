import express from "express";
import * as playersController from "../controllers/players.controller";

const router = express.Router();

router.post("/:uuid", async (req, res) => {
  try {
    const player = await playersController.create(
      req.params.uuid,
      req.body.nickname
    );
    res.status(201).json(player);
  } catch (err: any) {
    console.error(err.stack);
    res.status(400).json({ message: err.message });
  }
});

router.put("/:uuid/nickname/:nickname", async (req, res) => {
  try {
    await playersController.updateOne(req.params.uuid, {
      nickname: req.params.nickname,
    });
    res.sendStatus(204);
  } catch (err: any) {
    console.error(err.stack);
    res.status(400).json({ message: err.message });
  }
});

router.get("/:uuid/balance", async (req, res) => {
  try {
    const balance = await playersController.getBalance(req.params.uuid);
    res.status(200).send(balance.toFixed(2));
  } catch (err: any) {
    console.error(err.stack);
    res.status(400).json({ message: err.message });
  }
});

router.post("/:uuid/balance/add", async (req, res) => {
  try {
    const balance = await playersController.addToBalance(
      req.params.uuid,
      req.body.amount ?? 0
    );
    res.status(200).send(balance.toFixed(2));
  } catch (err: any) {
    console.error(err.stack);
    res.status(400).json({ message: err.message });
  }
});

router.post("/:uuid/balance/remove", async (req, res) => {
  try {
    const balance = await playersController.addToBalance(
      req.params.uuid,
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
    res.status(200).send(players);
  } catch (err: any) {
    console.error(err.stack);
    res.status(400).json({ message: err.message });
  }
});

export default router;
