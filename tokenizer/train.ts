import { trainBPE } from "./bpe";
import fs from "fs";

const text = fs.readFileSync(process.argv[2], "utf-8");

const { merges } = trainBPE(text, 1000);

fs.writeFileSync(
  "./tokenizer/vocab.json",
  JSON.stringify(merges, null, 2)
);

console.log("done, merges:", merges.length);
