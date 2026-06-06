import fs from "fs";
import { encode } from "./tokenizer/encode";

const merges: string[] = JSON.parse(
  fs.readFileSync("./tokenizer/vocab.json", "utf-8")
);

const text = "hello world";

const tokens = encode(text, merges);

console.log(tokens);
