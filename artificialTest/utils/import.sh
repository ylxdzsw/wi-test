cd ../data
for i in *; do
	for j in $i/*; do
		cat "$j" | node ../utils/writeToMongo.js $i 2>/dev/null &
	done
done
wait