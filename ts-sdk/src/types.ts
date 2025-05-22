export interface FaucetResponse {
  status: string;
  coins_sent: Array<{
    amount: number;
    id: string;
    transferTxDigest: string;
  }>;
}

export type MoveBytecode = {
  modules: string[];
  dependencies: string[];
};
