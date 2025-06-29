# source ~/.bashrc
dataset_dir=$1
if [ -z ${dataset_dir} ]; then
    echo "Must give dataset_dir"
    exit 0;
fi

cd "$(dirname "$0")"

dirs=$(find "$dataset_dir" -maxdepth 1 -mindepth 1 -type d | sort)
total=$(echo "$dirs" | wc -l)
echo "Training ${dataset_name} with total count $total"
count=0
for dir in $dirs; do
    count=$((count + 1))
    
    dataset_name=$(basename "$dir")
    mkdir -p ${dataset_dir}/${dataset_name}/output

    if [ -f ${dataset_dir}/${dataset_name}/output/.processed ]; then
        echo "Skip ${dataset_name} folder since it has been already processed!"
        continue
    fi
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$count/$total]Training dataset: $dataset_name"
    max_gaussian_points=2000000
    python train.py -s ${dataset_dir}/${dataset_name} -m ${dataset_dir}/${dataset_name}/output --resolution 1 --densify_grad_threshold 0.0001 --max_gaussian_points ${max_gaussian_points}
    if [ -f ${dataset_dir}/${dataset_name}/output/point_cloud/iteration_${iterations}/point_cloud_object.ply ]; then
        touch ${dataset_dir}/${dataset_name}/output/.processed
    fi
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$count/$total]Training done: $dataset_name"
done

