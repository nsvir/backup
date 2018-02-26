# Backup
compress and encrypt directories openssl(MD5(salt + password) + AES-256-cbc)

# Usage
```
nano ./list.conf #directories to backup
./backup.sh      #encrypt in ./data/
./backup.sh -d   #decrypt in ./decrypted/
```

# Test
```
./test.sh
```

# TODO

- rotation
