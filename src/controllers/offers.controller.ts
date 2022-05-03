import { config } from "../config";
import { mongo } from "../helpers/mongo";
import { Offer } from "../interfaces/offers.interface";
import { addToBalance, getExistingPlayer } from "./players.controller";
import { addToStock, checkAvailability } from "./stocks.controller";

const collection = config.mongo.collections.offers;

export const getExistingOffer = async (name: string): Promise<Offer> => {
  const existing = await mongo.findOne<Offer>(collection, { name });
  if (!existing) {
    throw new Error("Offre en or inexistante");
  }
  return existing;
};

export const create = async (name: string, price: number) => {
  const existing = await mongo.findOne<Offer>(collection, { name });
  if (existing) {
    throw new Error("Offre en or existante");
  }
  return mongo.insertOne<Offer>(collection, { name, price });
};

export const del = async (name: string) => {
  await getExistingOffer(name);
  return mongo.deleteOne<Offer>(collection, { name });
};

export const updatePrice = async (name: string, price: number) => {
  await getExistingOffer(name);
  return mongo.updateOne<Offer>(collection, { name }, { $set: { price } });
};

export const get = async () => {
  return mongo.find<Offer>(collection, {});
};

export const buy = async (
  name: string,
  order: { amount: number; userId: string }
) => {
  if (!order.amount) {
    throw new Error("Tu crois on va te laisser rien acheter pelo ?");
  }
  const existingOffer = await getExistingOffer(name);
  const totalPrice = existingOffer.price * order.amount;
  await checkAvailability(name, order.amount);
  await addToBalance(order.userId, totalPrice * -1);
  await addToStock(name, order.amount * -1);
  const newUserInfos = await getExistingPlayer(order.userId);
  return newUserInfos.balance;
};

export const sell = async (
  name: string,
  order: { amount: number; userId: string }
) => {
  if (!order.amount) {
    throw new Error("Tu crois on va te laisser rien vendre pelo ?");
  }
  const existingOffer = await getExistingOffer(name);
  const totalPrice = existingOffer.price * order.amount * config.buySellRatio;
  await addToBalance(order.userId, totalPrice);
  await addToStock(name, order.amount);
  const newUserInfos = await getExistingPlayer(order.userId);
  return newUserInfos.balance;
};
