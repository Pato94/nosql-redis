#!/bin/sh

# You may want to comment this line
redis-cli flushall

# Register tests
echo "Register - username: pato, password: pato"
redis-cli --eval register.lua , pato9406@gmail.com pato pato

echo "Trying to register with the same email"
redis-cli --eval register.lua , pato9406@gmail.com pato pato

echo "Trying to register with the same username"
redis-cli --eval register.lua , pato9407@gmail.com pato pato

echo "Register - username: pato2, password: pato"
redis-cli --eval register.lua , pato9407@gmail.com pato2 pato

# Login tests
echo "Login with a non-existent user"
redis-cli --eval login.lua , fruta loca 192.168.1.1

echo "Login with an incorrect password"
redis-cli --eval login.lua , pato fruta 192.168.1.1

# Should fail the first time because of Unknown IP
echo "Login - username: pato, password: pato"
verify_key=$(redis-cli --eval login.lua , pato pato 192.168.1.1)

echo "Verifying IP 1"
redis-cli --eval verify_ip.lua , pato $verify_key

echo "Login - username: pato, password: pato"
token=$(redis-cli --eval login.lua , pato pato 192.168.1.1)

echo "Login - username: pato2, password: pato"
verify_key2=$(redis-cli --eval login.lua , pato2 pato 192.168.1.1)

echo "Verifying IP 2"
redis-cli --eval verify_ip.lua , pato2 $verify_key2

echo "Login - username: pato2, password: pato"
token2=$(redis-cli --eval login.lua , pato2 pato 192.168.1.1)

# Create post tests
echo "Create post with an invalid token"
redis-cli --eval create_post.lua , "My Post" "<html><body>Test</body><html>" frula

echo "Create post 1"
private_post_url=$(redis-cli --eval create_post.lua , "My Post 1" "<html><body>Test 1</body><html>" $token)

echo "Create post 2"
post_url_to_delete=$(redis-cli --eval create_post.lua , "My Post 2" "<html><body>Test 2</body><html>" $token)

echo "Create post 3"
post_url=$(redis-cli --eval create_post.lua , "My Post 3" "<html><body>Test 3</body><html>" $token)

# Publish post tests
echo "Publish a non-existent post"
redis-cli --eval publish_post.lua , random $token

echo "Publish another user's post"
redis-cli --eval publish_post.lua , $post_url $token2

echo "Publish a post"
redis-cli --eval publish_post.lua , $post_url $token

# Delete post tests
echo "Delete a non-existent post"
redis-cli --eval delete_post.lua , random $token

echo "Delete another user's post"
redis-cli --eval delete_post.lua , $post_url_to_delete $token2

echo "Delete a post"
redis-cli --eval delete_post.lua , $post_url_to_delete $token

# View post tests
echo "View a non-existent post"
redis-cli --eval view_post.lua , random $token

echo  "View a post private post from another user"
redis-cli --eval view_post.lua , $private_post_url $token2

echo  "View a post private post"
redis-cli --eval view_post.lua , $private_post_url $token

echo "View a public post without token"
redis-cli --eval view_post.lua , $post_url

echo  "View a public post from another user"
redis-cli --eval view_post.lua , $post_url $token2

echo  "View a public post"
redis-cli --eval view_post.lua , $post_url $token

# List all posts test
echo "List all posts from another user"
redis-cli --eval list_all_posts.lua , pato $token2

echo "List all posts"
redis-cli --eval list_all_posts.lua , pato $token

# Profile posts tests
echo "Creating some posts"
seq 10 20 | while read f;
  do redis-cli --eval publish_post.lua , "$(redis-cli --eval create_post.lua , "My Post $f" "<html><body>Test $f</body><html>" $token2)" $token2;
  sleep 1
done

echo "Getting first 6 posts"
redis-cli --eval user_profile_posts.lua , pato2 0 5

echo "Getting posts from 3 to 8"
redis-cli --eval user_profile_posts.lua , pato2 3 8

# Last published date tests
echo "Get last published date"
redis-cli --eval last_published_time.lua , pato2

# Autocomplete tests
echo "Autocomplete with pat"
redis-cli --eval autocomplete.lua , pat
