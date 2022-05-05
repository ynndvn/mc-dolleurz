import { config } from "../config";

export const get = (amount: number) => {
  if (amount > 2) {
    return `${amount.toFixed(2)} ${config.unit}s`;
  }
  return `${amount.toFixed(2)} ${config.unit}`;
};
