export type Vocab = Map<string, number>;
export type Merges = Map<string, number>;

export const getPairs = (tokens: string[]): Map<string, number> => {
  const pairs = new Map<string, number>();

  for (let i = 0; i < tokens.length - 1; i++) {
    const pair = `${tokens[i]} ${tokens[i + 1]}`;
    pairs.set(pair, (pairs.get(pair) ?? 0) + 1);
  }

  return pairs;
};

export const mergeTokens = (tokens: string[], pair: string): string[] => {
  const [a, b] = pair.split(" ");
  const merged = `${a}${b}`;

  const result: string[] = [];

  for (let i = 0; i < tokens.length; ) {
    if (i < tokens.length - 1 && tokens[i] === a && tokens[i + 1] === b) {
      result.push(merged);
      i += 2;
    } else {
      result.push(tokens[i]);
      i += 1;
    }
  }

  return result;
};

export const trainBPE = (text: string, vocabSize = 1000) => {
  let tokens = Array.from(text);
  const merges: string[] = [];

  while (true) {
    const pairs = getPairs(tokens);
    if (pairs.size === 0) break;

    const best = [...pairs.entries()].sort((a, b) => b[1] - a[1])[0];
    const [pair] = best;

    tokens = mergeTokens(tokens, pair);
    merges.push(pair);

    if (merges.length >= vocabSize) break;
  }

  return { merges };
};
