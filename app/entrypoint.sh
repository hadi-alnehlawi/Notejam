export FLASK_APP=notejam
if ! [ -d "migrations/" ]; then
  # Take action if $DIR exists. #
  echo "db is not existed"
  flask db init
fi
flask db migrate
flask db upgrade
python runserver.py