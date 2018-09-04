if #ARGV ~= 3 then
  error("Register should be called with 3 arguments: username, password and current_ip. Actually called with " .. #ARGV .. " arguments")
end

local username = ARGV[1]
local password = ARGV[2]
local current_ip = ARGV[3]

if redis.call("EXISTS", "user:" .. username) == 0 then
  error("Unknown user. Aborting")
end

local hashed_pw = redis.call("GET", "user:" .. username)

if hashed_pw ~= redis.sha1hex(password) then
  error("Incorrect password. Aborting")
end

local known_ips = redis.call("SMEMBERS", "user:" .. username .. ":known_ips")
local included_in_known_ips = false

for i=1, #known_ips do
  if known_ips[i] == current_ip then
    included_in_known_ips = true
  end
end

-- Agregamos la IP como conocida tras el primer fallo
if not included_in_known_ips then
  redis.call("SADD", "user:" .. username .. ":known_ips", current_ip)
  error("Unknown IP. Aborting")
end

local current_seed = redis.call("GET", "random") or 3
math.randomseed(current_seed)
redis.call("SET", "random", math.random(99))

local uuid = string.gsub(
  "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx", "[xy]",
  function (c)
      local v = (c == "x") and math.random(0, 0xf) or math.random(8, 0xb)
      return string.format("%x", v)
  end)

-- TODO: Add a reasonable session value
redis.call("SETEX", "session:" .. uuid, 10 * 60, username)

return uuid
