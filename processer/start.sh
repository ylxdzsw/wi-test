cd input
for i in *; do
	rm ../output/$i/*
	for j in $i/*; do
		cat "$j" | python ../process.py > "../output/$j"
	done
done