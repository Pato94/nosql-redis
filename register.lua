if #ARGV ~= 3 then
  error("Register should be called with 3 arguments: email, username and password. Actually called with " .. #ARGV .. " arguments")
end

local email = ARGV[1]
local username = ARGV[2]
local password = ARGV[3]

if redis.call("EXISTS", "email:" .. email) == 1 then
  error("Email is already in use. Aborting")
end

if redis.call("EXISTS", "user:" .. username .. ":password") == 1 then
  error("Username is already in use. Aborting")
end

redis.call("SET", "email:" .. email, username)
redis.call("SET", "user:" .. username .. ":password", redis.sha1hex(password))

-- Autocomplete stuff
for i=1, username:len() do
  redis.call("ZADD", "user_autocomplete", 0, username:sub(1, i))
end

redis.call("ZADD", "user_autocomplete", 0, username .. "*")
