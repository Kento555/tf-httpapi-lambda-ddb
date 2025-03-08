#!/bin/bash
# INVOKE_URL=https://n533ykbcil.execute-api.us-east-1.amazonaws.com
# INVOKE_URL=ws.sctp-sandbox.com

INVOKE_URL=$(terraform output -raw invoke_url)

# add movies
echo "> add movies"
for i in $(seq 1990 1995); do
    json="$(jq -n --arg year "$i" --arg title "MovieTitle$i" '{year: $year, title: $title}')"
    curl \
        -X PUT \
        -H "Content-Type: application/json" \
        -d "$json" \
        "$INVOKE_URL/topmovies";
    echo
done

# get movies by year
echo "> get movies by year"
for i in $(seq 1990 1995); do
    curl "$INVOKE_URL/topmovies/$i"
    echo
done

# # delete movie
# echo "> delete movie from 2002"
# curl -X DELETE "$INVOKE_URL/topmovies/2002"
# echo

# get movies
echo "> get movies"
curl "$INVOKE_URL/topmovies"
