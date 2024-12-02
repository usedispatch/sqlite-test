local sqlite3 = require("lsqlite3")
local json = require("json")
DB = DB or sqlite3.open_memory()
DbAdmin = require('DbAdmin').new(DB)
-- DbAdmin = dbAdmin.new(DB)
function Configure()
    -- Create Todo table with basic fields
    DbAdmin:exec[[
    CREATE TABLE Todos (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        completed BOOLEAN DEFAULT 0
    );
    ]]

    Configured = true
end

if not Configured then Configure() end


function sendReply(msg, data)
    msg.reply({Data = data, Action = msg.Action .. "Response"})
end

function addTodo(data)
    DbAdmin:apply(
        'INSERT INTO Todos (id, title, completed) VALUES (?, ?, ?)',
        {
            data.id,
            data.title,
            data.completed or false
        }
    )
end

-- Get all todos
function getTodos()
    local results = DbAdmin:exec("SELECT * FROM Todos;")
    print(results)
    return json.encode(results)
end

-- Update todo
function updateTodo(data)
    DbAdmin:apply(
        'UPDATE Todos SET title = ?, completed = ? WHERE id = ?',
        {
            data.title,
            data.completed,
            data.id
        }
    )
end

-- Delete todo
function deleteTodo(id)
    DbAdmin:apply('DELETE FROM Todos WHERE id = ?', {id})
end

-- Add new todo
function addTodoProcessor(msg)
    local data = json.decode(msg.Data)
    addTodo(data)
    sendReply(msg, data)
end

-- Get all todos
function getTodosProcessor(msg)
    local data = getTodos()
    sendReply(msg, data)
end

-- Update todo
function updateTodoProcessor(msg)
    local data = json.decode(msg.Data)
    updateTodo(data)
    sendReply(msg, data)
end

-- Delete todo
function deleteTodoProcessor(msg)
    local data = json.decode(msg.Data)
    deleteTodo(data.id)
    sendReply(msg, {success = true})
end

-- Register handlers
Handlers.add("AddTodo", addTodoProcessor)
Handlers.add("GetTodos", getTodosProcessor)
Handlers.add("UpdateTodo", updateTodoProcessor)
Handlers.add("DeleteTodo", deleteTodoProcessor)