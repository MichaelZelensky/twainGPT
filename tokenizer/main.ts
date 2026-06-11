import { mergeTokens, trainBPE } from "./bpe";
import fs from "fs";

const text = fs.readFileSync(process.argv[2], "utf-8");

const { merges } = trainBPE(text, 1000);

let tokens = Array.from(text);

for (const merge of merges) {
  tokens = mergeTokens(tokens, merge);
}

const vocabArray = Array.from(new Set(tokens));

const vocab = Object.fromEntries(
  vocabArray.map((token, index) => [token, index])
);

fs.writeFileSync(
  "./tokenizer/merges.json",
  JSON.stringify(merges, null, 2)
);

fs.writeFileSync(
  "./tokenizer/vocab.json",
  JSON.stringify(vocab, null, 2)
);

console.log("done, merges:", merges.length);
