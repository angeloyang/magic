
function sr {
find . -type f -exec sed -i '' s/$1/$2/g {} +
    }


    function find_files_by_name {
    find . -type f -name $1
    }
