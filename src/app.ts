import express from "express";
import bodyParser from "body-parser";

import { config } from "./config";

import playersRouter from "./routes/players.route";
import offersRouter from "./routes/offers.route";
import transactionsRouter from "./routes/transactions.route";
import { mongo } from "./helpers/mongo";

var app = express();

app.use(bodyParser.json());

app.use("/players", playersRouter);
app.use("/offers", offersRouter);
app.use("/transactions", transactionsRouter);

const init = async () => {
  await mongo.connect();
};

init().then(() => {
  app.listen(config.port, () => {
    console.log(`Application listening on port ${config.port}`);
  });
});
