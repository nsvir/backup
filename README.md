# Backup
compress and encrypt directories openssl(MD5(salt + password) + AES-256-cbc)

# Usage
```
./backup.sh      #encrypt in ./data/
./backup.sh -d   #decrypt in ./decrypted/
```

# Test
```
./test.sh
```

# TODO

- rotation
