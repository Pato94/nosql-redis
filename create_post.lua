redis.replicate_commands()

if #ARGV ~= 3 then
  error("Create post should be called with 3 arguments: title, content and token. Actually called with " .. #ARGV .. " arguments")
end

local title = ARGV[1]
local markdown = ARGV[2]
local uuid = ARGV[3]
local username = redis.call("GET", "session:" .. uuid)

if not username then
  error("Unauthorized. Unknown UUID")
end

redis.call("EXPIRE", "session:" .. uuid, 10 * 60)

math.randomseed(redis.call("TIME")[2])

local random_id = string.gsub(
  "xxxxxxxxxxxx", "[x]",
  function (c)
    return string.format("%x", math.random(0, 0xf))
  end)

redis.call("HMSET", "post:" .. random_id, "title", title, "markdown", markdown, "public", "false")
redis.call("SADD", "user:" .. username .. ":posts", random_id)

return random_id
