import { config } from "../config";

export const get = (amount: number) => {
  if (amount > 2) {
    return `${amount} ${config.unit}s`;
  }
  return `${amount} ${config.unit}`;
};
