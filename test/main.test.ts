import aos from "aos";
import fs from "fs";
import path from "node:path";
import assert from "node:assert";
import { describe, test, before } from "node:test";
describe("AOS Tests", () => {
  let env: aos;

  before(async () => {
    const source = fs.readFileSync(
      path.join(__dirname, "./../src/main.lua"),
      "utf-8"
    );

    env = new aos(source);
    await env.init();
  });

  test("load DbAdmin module", async () => {
    const dbAdminCode = fs.readFileSync("./src/dbAdmin.lua", "utf-8");
    const result = await env.send({
      Action: "Eval",
      Data: `
  local function _load() 
    ${dbAdminCode}
  end
  _G.package.loaded["DbAdmin"] = _load()
  return "ok"
      `,
    });
    console.log("result DbAdmin Module", result);
    assert.equal(result.Output.data, "ok");
  });

  test("load source", async () => {
    const code = fs.readFileSync("./src/main.lua", "utf-8");
    const result = await env.send({ Action: "Eval", Data: code });
    console.log("result load source", result);
    // assert.equal(result.Output.data, "OK");
  });

  test("should add and get todo", async () => {
    const todo = {
      id: "1",
      title: "Test Todo",
      completed: false,
    };

    const response = await env.send({
      Action: "AddTodo",
      Data: JSON.stringify(todo),
    });

    console.log("add todo", response);
    // const response = await env.send({ Action: "GetTodos" });
    // const todos = JSON.parse(response.Messages[0].Data);
    // assert.deepEqual(todos[0], todo);
  });

  test("should get todos", async () => {
    const response = await env.send({ Action: "GetTodos" });
    console.log(response);
  });
});
