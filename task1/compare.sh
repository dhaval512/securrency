 
if ! comm -3 <(sort ./dev.json) <(sort ./prod.json) | grep -q '.*'; then
     echo "There are no changes in the versions"
else
   echo "versions are not same"
fi