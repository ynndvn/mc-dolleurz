import { readFileSync } from "fs";
import { join } from "path";

const defaultConfig = {
  port: 4000,
  unit: "Bitcoin",
  units: "Bitcoins",
  buySellRatio: 0.65,
  mongo: {
    host: "localhost",
    port: 27017,
    auth: {
      user: "",
      password: "",
    },
    database: "",
    collections: {
      players: "players",
      offers: "offers",
      transactions: "transactions",
    },
  },
};

export const config: typeof defaultConfig = {
  ...defaultConfig,
  ...JSON.parse(
    readFileSync(join(process.cwd(), "config.json"), { encoding: "utf-8" })
  ),
};
