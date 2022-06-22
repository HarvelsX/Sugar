#!/bin/sh

readonly GIT_BASE=$(git rev-parse --show-toplevel)
readonly HOOKS_DIR="$GIT_BASE/.git/hooks"
readonly PUBLIC_HOOKS_DIR='.github/hooks'

for filename in "${GIT_BASE}/$PUBLIC_HOOKS_DIR"/*
do
    [ -e "$filename" ] || continue

    hookreal=`realpath --relative-to="$PUBLIC_HOOKS_DIR" $filename`
    hookpath=`realpath --relative-to="$GIT_BASE" $filename`

    if [ -e "$HOOKS_DIR/$hookreal" ]
    then
        [ -e "$HOOKS_DIR/${hookreal}.local" ] \
            && echo "Skip creating hooks because they already exist." \
            && echo "You can use '$HOOKS_DIR/${hookreal}.local' for your scripts" \
            && break

        echo "Rename local $hookreal hook to ${hookreal}.local"
        mv "$HOOKS_DIR/$hookreal" "$HOOKS_DIR/${hookreal}.local"
    fi
    
    cat << EOF > "$HOOKS_DIR/$hookreal"
#!/bin/sh
[ -e "./${hookreal}" ] && . $hookpath
[ -e "./${hookreal}.local" ] && . ./${hookreal}.local
exit 0
EOF
    echo "Added '${hookreal}' hook"
done