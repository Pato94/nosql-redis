if #ARGV ~= 3 then
  error("Register should be called with 3 arguments: title, content and token. Actually called with " .. #ARGV .. " arguments")
end

local title = ARGV[1]
local markdown = ARGV[2]
local uuid = ARGV[3]
local username = redis.call("GET", "session:" .. uuid)

if not username then
  error("Unauthorized. Unknown UUID")
end

redis.call("EXPIRE", "session:" .. uuid, 10 * 60)

local current_seed = redis.call("GET", "random") or 3
math.randomseed(current_seed)
redis.call("SET", "random", math.random(99))

local random_id = string.gsub(
  "xxxxxxxxxxxx", "[x]",
  function (c)
    return string.format("%x", math.random(0, 0xf))
  end)

redis.call("HMSET", "post:" .. random_id, "title", title, "markdown", markdown, "public", "false")
redis.call("SADD", "user:" .. username .. ":posts", random_id)

return random_id
