if #ARGV ~= 2 then
  error("Verify IP should be called with 2 arguments: username, and verify_key. Actually called with " .. #ARGV .. " arguments")
end

local username = ARGV[1]
local verify_key = ARGV[2]

if redis.call("EXISTS", "user:" .. username .. ":password") == 0 then
  error("Unknown user. Aborting")
end

if redis.call("EXISTS", "verify_ip:" .. verify_key) == 0 then
  error("Unknown verify_key. Aborting")
end

local ip_to_verify = redis.call("GET", "verify_ip:" .. verify_key)
redis.call("SADD", "user:" .. username .. ":known_ips", ip_to_verify)
redis.call("DEL", "verify_ip:" .. verify_key)
