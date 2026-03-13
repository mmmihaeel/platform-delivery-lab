import type { Context } from "aws-lambda";

export const handler = async (_event: unknown, context: Context): Promise<Record<string, string>> => {
  return {
    runtime: "nodejs20-typescript",
    version: "1.0.0",
    status: "ok",
    requestId: context.awsRequestId
  };
};
