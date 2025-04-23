import bcrypt

password = "pass123"
hashed = bcrypt.hashpw(password.encode(), bcrypt.gensalt())

print("Copy this to SQL:")
print(hashed.decode())
