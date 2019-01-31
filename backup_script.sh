#!/bin/bash



    #data=$(`curl https://ddocker-registry.goabode.com/v2/_catalog | jq -r '.repositories[]'`)
#echo ${data[@]}



if [ ! -f data.txt ]; then
curl https://ddocker-registry.goabode.com/v2/_catalog | jq -r '.repositories[]' >> data.txt
else
rm -r data.txt
curl https://ddocker-registry.goabode.com/v2/_catalog | jq -r '.repositories[]' >> data.txt
fi


stuff=()
while IFS='' read -r line || [[ -n "$line" ]]; do
stuff+=( "$line" )
done < data.txt


stuff_len="${#stuff[@]}"
let stuff_len=$stuff_len-1

count=0


declare -A name_and_tags



if [  -e data_tags.txt ]; then
rm -r data_tags.txt
#curl https://ddocker-registry.goabode.com/v2/_catalog | jq -r '.repositories[]' >> data.txt
fi

all_reps=()
tags_array=()
reps_with_tags=()
while [ $count -le $stuff_len ];
do
tags_url="https://ddocker-registry.goabode.com/v2/${stuff[$count]}/tags/list"
#echo ${stuff[$count]} >> data_tags.txt

data_tags=`curl $tags_url | jq -r '.tags[]'`
#echo $data_tags

for tag in $data_tags
do
    all_reps+=("ddocker-registry.goabode.com/${stuff[$count]}:$tag") 
   reps_with_tags+=("${stuff[$count]}:$tag")
    
#>> data_tags.txt
    docker pull ddocker-registry.goabode.com/"${stuff[$count]}":$tag
done


let count=$count+1
echo;
done

total_len=${#all_reps[@]}

count1=0

docker run -d -p 5000:5000 --name registry registry:2

while [ $count1 -le $total_len ];
do

echo ${all_reps[$count1]}
local_name="localhost:5000/"${reps_with_tags[$count1]}


docker tag ${all_reps[$count1]} $local_name
docker push $local_name 

#str+=${all_reps[$count1]}" "
let count1=$count1+1
done


#echo "backing up all images..."
#docker save -o abode_images_backup.tar $str


##arr=$(jq '.repositories[]' json)
##printf '%s\n' "${arr[1]}"
