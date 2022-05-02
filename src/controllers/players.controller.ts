import { config } from "../config";
import { get } from "../helpers/money.helper";
import { mongo } from "../helpers/mongo";
import { Player } from "../interfaces/players.interface";

const collection = config.mongo.collections.players;

export const getExistingPlayer = async (uuid: string): Promise<Player> => {
  const existing = await mongo.findOne<Player>(collection, { uuid });
  if (!existing) {
    throw new Error("Utilisateur inexistant");
  }
  return existing;
};

export const create = async (uuid: string, nickname: string) => {
  if (!uuid) {
    throw new Error("UUID manquant");
  }
  if (!nickname) {
    throw new Error("Nom manquant");
  }
  const existing = await mongo.findOne<Player>(collection, { uuid });
  if (existing) {
    throw new Error("Utilisateur existant");
  }
  return mongo.insertOne<Player>(collection, {
    uuid,
    nickname,
    balance: 0,
  });
};

export const updateOne = async (uuid: string, update: Partial<Player>) => {
  if (!uuid) {
    throw new Error("UUID manquant");
  }
  await getExistingPlayer(uuid);
  return mongo.updateOne<Player>(
    collection,
    {
      uuid,
    },
    {
      $set: update,
    }
  );
};

export const getBalance = async (uuid: string): Promise<number> => {
  const existing = await getExistingPlayer(uuid);
  return existing.balance;
};

export const addToBalance = async (
  uuid: string,
  amount: number
): Promise<number> => {
  const existing = await getExistingPlayer(uuid);
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
      uuid,
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
