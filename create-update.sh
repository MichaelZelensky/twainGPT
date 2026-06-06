#!/usr/bin/env bash
set -euo pipefail

DIR="./tokenizer"

mkdir -p "$DIR"

cat > "$DIR/bpe.ts" <<'EOF'
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
EOF

cat > "$DIR/encode.ts" <<'EOF'
import { mergeTokens } from "./bpe";

export const encode = (text: string, merges: string[]): string[] => {
  let tokens = Array.from(text);

  for (const merge of merges) {
    tokens = mergeTokens(tokens, merge);
  }

  return tokens;
};
EOF

cat > "$DIR/decode.ts" <<'EOF'
export const decode = (tokens: string[]): string => {
  return tokens.join("");
};
EOF

cat > "$DIR/train.ts" <<'EOF'
import { trainBPE } from "./bpe";
import fs from "fs";

const text = fs.readFileSync(process.argv[2], "utf-8");

const { merges } = trainBPE(text, 1000);

fs.writeFileSync(
  "./tokenizer/vocab.json",
  JSON.stringify(merges, null, 2)
);

console.log("done, merges:", merges.length);
EOF

cat > "$DIR/vocab.json" <<'EOF'
[]
EOF

echo "Tokenizer files created/updated in $DIR"