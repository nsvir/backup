test="Hello world!"

rm -fr test
mkdir test
cp backup.sh test/
cd test/

# should return -1
./backup.sh && echo "Failed list.conf" && exit -1

echo "`pwd`/test.txt" >> list.conf
echo "`pwd`/test2.txt" >> list.conf
echo "$test" > test.txt
echo "$test$test" > test2.txt

./backup.sh

[ ! -e ./data/salt ] && echo "failed salt!" && exit -1
[ ! -e ./.secret ] && echo "failed secret!" && exit -1
[[ ! $(stat -c "%a" .secret) -eq "400" ]] && echo "failed secret chmod!" && exit -1

[ ! -e ./data/*.tar.gz.enc ] && echo "encryption failed!" && exit -1

rm -f .secret

./backup.sh -d

! [[ $(cat decrypted/`pwd`/test.txt) == $test ]] && echo "Decryption failed!" && exit -1
! [[ $(cat decrypted/`pwd`/test2.txt) == $test$test ]] && echo "Decryption failed!" && exit -1

(cd ..; rm -fr test)
echo "Success!"
