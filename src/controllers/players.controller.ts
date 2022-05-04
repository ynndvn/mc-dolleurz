import { config } from "../config";
import { get } from "../helpers/money.helper";
import { mongo } from "../helpers/mongo";
import { Player } from "../interfaces/players.interface";

const collection = config.mongo.collections.players;

export const getExistingPlayer = async (nickname: string): Promise<Player> => {
  const existing = await mongo.findOne<Player>(collection, { nickname });
  if (!existing) {
    throw new Error("Utilisateur inexistant");
  }
  return existing;
};

export const create = async (nickname: string) => {
  if (!nickname) {
    throw new Error("Nom manquant");
  }
  const existing = await mongo.findOne<Player>(collection, { nickname });
  if (existing) {
    throw new Error("Utilisateur existant");
  }
  return mongo.insertOne<Player>(collection, {
    nickname,
    balance: 0,
  });
};

export const getBalance = async (nickname: string): Promise<number> => {
  const existing = await getExistingPlayer(nickname);
  return existing.balance;
};

export const addToBalance = async (
  nickname: string,
  amount: number
): Promise<number> => {
  const existing = await getExistingPlayer(nickname);
  const balance = existing.balance + amount;
  if (balance < 0) {
    throw new Error(
      `Balance négative. Solde restant : ${get(existing.balance)}. ${get(
        balance * -1
      )} manquants !`
    );
  }
  await mongo.updateOne<Player>(
    collection,
    {
      nickname,
    },
    {
      $set: { balance },
    }
  );
  return balance;
};

export const getAll = async (): Promise<Array<Player>> => {
  return mongo.find<Player>(collection, {});
};
