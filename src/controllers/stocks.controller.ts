import { config } from "../config";
import { mongo } from "../helpers/mongo";
import { Stocks } from "../interfaces/stocks.interface";

const collection = config.mongo.collections.stocks;

export const checkAvailability = async (item: string, quantity: number) => {
  const existingItem = await mongo.findOne<Stocks>(collection, { item });
  if (!existingItem) {
    throw new Error("Aucun stock sur cet item");
  }
  if (existingItem.quantity < quantity) {
    throw new Error("Stock manquant sur cet item");
  }
};

export const addToStock = async (item: string, quantity: number) => {
  const existingItem = (await mongo.findOne<Stocks>(collection, { item })) ?? {
    item,
    quantity: 0,
  };
  existingItem.quantity += quantity;
  await mongo.upsert<Stocks>(collection, { item }, existingItem);
};

export const get = async () => {
  return mongo.find<Stocks>(collection, {});
};
