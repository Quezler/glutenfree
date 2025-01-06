for file in *recycler*; do
    mv "$file" "$(echo $file | sed 's/recycler/upcycler/g')"
done
