PROJECT_DATABASE_NAME="DIMS" # Project databasae name
PROJECT_DIR="DIMS"           # Project directory
ENV='.env'

cd $PROJECT_DIR
printf "NODE_ENV=production 
MONGO_URI=mongodb://localhost:27017/$PROJECT_DATABASE_NAME
JWT_TOKEN=mom&dad" >>"./$ENV"
