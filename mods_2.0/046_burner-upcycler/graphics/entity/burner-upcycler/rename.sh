for file in *recycler*; do
    mv "$file" "$(echo $file | sed 's/recycler/burner-upcycler/g')"
done
