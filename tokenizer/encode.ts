import { mergeTokens } from "./bpe";

export const encode = (text: string, merges: string[]): string[] => {
  let tokens = Array.from(text);

  for (const merge of merges) {
    tokens = mergeTokens(tokens, merge);
  }

  return tokens;
};
