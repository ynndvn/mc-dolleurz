import { config } from "../config";
import { mongo } from "../helpers/mongo";
import { Transaction } from "../interfaces/transactions.interface";
import { addToBalance, getExistingPlayer } from "./players.controller";

export const create = async (from: string, to: string, amount: number) => {
  if (!from) {
    throw new Error("from manquant");
  }
  if (!to) {
    throw new Error("to manquant");
  }
  if (amount < 0 || isNaN(amount)) {
    throw new Error("T'as voulu voler de l'argent à qui pelo");
  }
  await Promise.all([getExistingPlayer(from), getExistingPlayer(to)]);
  await addToBalance(from, amount * -1);
  await addToBalance(to, amount);
  await mongo.insertOne<Transaction>(config.mongo.collections.transactions, {
    from,
    to,
    amount,
  });
};
